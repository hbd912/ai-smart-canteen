package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.canteen.common.BizException;
import com.canteen.common.Constants;
import com.canteen.common.ErrorCode;
import com.canteen.dto.AddCartItemRequest;
import com.canteen.entity.Dish;
import com.canteen.entity.ShoppingCart;
import com.canteen.entity.ShoppingCartItem;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.ShoppingCartItemMapper;
import com.canteen.mapper.ShoppingCartMapper;
import com.canteen.vo.CartItemVo;
import com.canteen.vo.CartVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 购物车业务。购物车不保存可信价格，每次读取都从 dish 表重新取价与库存状态。
 */
@Service
@RequiredArgsConstructor
public class CartService {

    private static final int MAX_QUANTITY = 99;

    private final ShoppingCartMapper cartMapper;
    private final ShoppingCartItemMapper cartItemMapper;
    private final DishMapper dishMapper;

    @Transactional
    public CartVo getCart(Long userId) {
        ShoppingCart cart = findOrCreateCart(userId);
        List<ShoppingCartItem> items = cartItemMapper.selectList(new LambdaQueryWrapper<ShoppingCartItem>()
                .eq(ShoppingCartItem::getCartId, cart.getId())
                .orderByAsc(ShoppingCartItem::getId));
        CartVo vo = new CartVo();
        vo.setCartId(cart.getId());
        vo.setItems(new ArrayList<>());
        vo.setWarnings(new ArrayList<>());

        if (items.isEmpty()) {
            vo.setTotalQuantity(0);
            vo.setDishCount(0);
            vo.setHasUnavailable(false);
            return vo;
        }
        Map<Long, Dish> dishMap = dishMapper.selectBatchIds(
                        items.stream().map(ShoppingCartItem::getDishId).toList())
                .stream().collect(Collectors.toMap(Dish::getId, Function.identity(), (a, b) -> a));

        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalCalories = BigDecimal.ZERO;
        int totalQuantity = 0;
        boolean hasUnavailable = false;

        for (ShoppingCartItem item : items) {
            Dish dish = dishMap.get(item.getDishId());
            if (dish == null) {
                hasUnavailable = true;
                vo.getWarnings().add("购物车中有菜品已被删除，请移除后再结算");
                continue;
            }
            CartItemVo itemVo = new CartItemVo();
            itemVo.setId(item.getId());
            itemVo.setDishId(dish.getId());
            itemVo.setDishName(dish.getName());
            itemVo.setImageUrl(dish.getImageUrl());
            itemVo.setQuantity(item.getQuantity());
            itemVo.setUnitPrice(dish.getPrice());
            itemVo.setSubtotal(dish.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()))
                    .setScale(2, RoundingMode.HALF_UP));
            itemVo.setCalories(dish.getCalories());
            itemVo.setSubtotalCalories(dish.getCalories() == null ? BigDecimal.ZERO
                    : dish.getCalories().multiply(BigDecimal.valueOf(item.getQuantity()))
                    .setScale(2, RoundingMode.HALF_UP));
            itemVo.setStock(dish.getStock());
            itemVo.setSupplyStatus(dish.getSupplyStatus());
            itemVo.setPublishStatus(dish.getPublishStatus());

            String reason = unavailableReason(dish, item.getQuantity());
            itemVo.setAvailable(reason == null);
            itemVo.setUnavailableReason(reason);
            if (reason != null) {
                hasUnavailable = true;
                vo.getWarnings().add(dish.getName() + "：" + reason);
            }
            totalAmount = totalAmount.add(itemVo.getSubtotal());
            totalCalories = totalCalories.add(itemVo.getSubtotalCalories());
            totalQuantity += item.getQuantity();
            vo.getItems().add(itemVo);
        }
        vo.setTotalAmount(totalAmount.setScale(2, RoundingMode.HALF_UP));
        vo.setTotalCalories(totalCalories.setScale(2, RoundingMode.HALF_UP));
        vo.setTotalQuantity(totalQuantity);
        vo.setDishCount(vo.getItems().size());
        vo.setHasUnavailable(hasUnavailable);
        return vo;
    }

    private String unavailableReason(Dish dish, int quantity) {
        if (!Constants.PublishStatus.PUBLISHED.equals(dish.getPublishStatus())) {
            return "菜品已下架，无法购买";
        }
        if (!Constants.SupplyStatus.AVAILABLE.equals(dish.getSupplyStatus())) {
            return Constants.SupplyStatus.SOLD_OUT.equals(dish.getSupplyStatus())
                    ? "菜品已售罄，请移除后再结算" : "菜品暂停供应，请移除后再结算";
        }
        int stock = dish.getStock() == null ? 0 : dish.getStock();
        if (stock <= 0) {
            return "菜品已售罄，请移除后再结算";
        }
        if (quantity > stock) {
            return "库存仅剩 " + stock + " 份，请调整数量";
        }
        return null;
    }

    @Transactional
    public CartVo addItem(Long userId, AddCartItemRequest request) {
        Dish dish = dishMapper.selectById(request.getDishId());
        if (dish == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "菜品不存在");
        }
        if (!Constants.PublishStatus.PUBLISHED.equals(dish.getPublishStatus())
                || !Constants.SupplyStatus.AVAILABLE.equals(dish.getSupplyStatus())
                || dish.getStock() == null || dish.getStock() <= 0) {
            throw BizException.of(ErrorCode.DISH_UNAVAILABLE, "该菜品当前不可购买");
        }
        ShoppingCart cart = findOrCreateCart(userId);
        ShoppingCartItem existing = cartItemMapper.selectOne(new LambdaQueryWrapper<ShoppingCartItem>()
                .eq(ShoppingCartItem::getCartId, cart.getId())
                .eq(ShoppingCartItem::getDishId, dish.getId()));
        int target = request.getQuantity();
        if (existing != null) {
            target = Math.min(existing.getQuantity() + request.getQuantity(), MAX_QUANTITY);
            if (target > dish.getStock()) {
                throw BizException.of(ErrorCode.STOCK_NOT_ENOUGH,
                        "库存仅剩 " + dish.getStock() + " 份，无法继续增加");
            }
            existing.setQuantity(target);
            cartItemMapper.updateById(existing);
        } else {
            if (target > dish.getStock()) {
                throw BizException.of(ErrorCode.STOCK_NOT_ENOUGH,
                        "库存仅剩 " + dish.getStock() + " 份，无法加入");
            }
            ShoppingCartItem item = new ShoppingCartItem();
            item.setCartId(cart.getId());
            item.setDishId(dish.getId());
            item.setQuantity(target);
            cartItemMapper.insert(item);
        }
        return getCart(userId);
    }

    @Transactional
    public CartVo updateItem(Long userId, Long itemId, int quantity) {
        ShoppingCart cart = findOrCreateCart(userId);
        ShoppingCartItem item = cartItemMapper.selectById(itemId);
        if (item == null || !item.getCartId().equals(cart.getId())) {
            throw BizException.of(ErrorCode.NOT_FOUND, "购物车中找不到该商品");
        }
        if (quantity <= 0) {
            cartItemMapper.deleteById(itemId);
            return getCart(userId);
        }
        if (quantity > MAX_QUANTITY) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "单道菜最多 99 份");
        }
        Dish dish = dishMapper.selectById(item.getDishId());
        if (dish == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "菜品不存在");
        }
        if (dish.getStock() == null || quantity > dish.getStock()) {
            throw BizException.of(ErrorCode.STOCK_NOT_ENOUGH,
                    "库存仅剩 " + (dish.getStock() == null ? 0 : dish.getStock()) + " 份");
        }
        item.setQuantity(quantity);
        cartItemMapper.updateById(item);
        return getCart(userId);
    }

    @Transactional
    public CartVo removeItem(Long userId, Long itemId) {
        ShoppingCart cart = findOrCreateCart(userId);
        ShoppingCartItem item = cartItemMapper.selectById(itemId);
        if (item == null || !item.getCartId().equals(cart.getId())) {
            throw BizException.of(ErrorCode.NOT_FOUND, "购物车中找不到该商品");
        }
        cartItemMapper.deleteById(itemId);
        return getCart(userId);
    }

    @Transactional
    public CartVo clear(Long userId) {
        ShoppingCart cart = findOrCreateCart(userId);
        cartItemMapper.delete(new LambdaQueryWrapper<ShoppingCartItem>()
                .eq(ShoppingCartItem::getCartId, cart.getId()));
        return getCart(userId);
    }

    public ShoppingCart findOrCreateCart(Long userId) {
        ShoppingCart cart = cartMapper.selectOne(new LambdaQueryWrapper<ShoppingCart>()
                .eq(ShoppingCart::getUserId, userId));
        if (cart == null) {
            cart = new ShoppingCart();
            cart.setUserId(userId);
            cartMapper.insert(cart);
        }
        return cart;
    }

    public List<ShoppingCartItem> listItems(Long cartId) {
        return cartItemMapper.selectList(new LambdaQueryWrapper<ShoppingCartItem>()
                .eq(ShoppingCartItem::getCartId, cartId));
    }

    public void clearByCartId(Long cartId) {
        cartItemMapper.delete(new LambdaQueryWrapper<ShoppingCartItem>()
                .eq(ShoppingCartItem::getCartId, cartId));
    }
}
