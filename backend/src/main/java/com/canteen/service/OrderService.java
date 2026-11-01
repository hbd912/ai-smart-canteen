package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.canteen.common.BizException;
import com.canteen.common.Constants;
import com.canteen.common.ErrorCode;
import com.canteen.common.Labels;
import com.canteen.common.PageResult;
import com.canteen.dto.CreateOrderRequest;
import com.canteen.entity.Dish;
import com.canteen.entity.InventoryLog;
import com.canteen.entity.Order;
import com.canteen.entity.OrderItem;
import com.canteen.entity.OrderStatusLog;
import com.canteen.entity.ShoppingCart;
import com.canteen.entity.ShoppingCartItem;
import com.canteen.entity.SysUser;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.InventoryLogMapper;
import com.canteen.mapper.OrderItemMapper;
import com.canteen.mapper.OrderMapper;
import com.canteen.mapper.OrderStatusLogMapper;
import com.canteen.mapper.SysUserMapper;
import com.canteen.security.SecurityUtils;
import com.canteen.vo.OrderItemVo;
import com.canteen.vo.OrderStatusLogVo;
import com.canteen.vo.OrderVo;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ThreadLocalRandom;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 订单业务。核心约束：
 * 1. 结算由后端重新读取菜品价格/状态/库存，绝不信任前端传入的金额。
 * 2. 订单创建与库存扣减在同一事务中完成，库存不足则整体回滚。
 * 3. 订单明细写入菜品快照，菜品后续改价不影响历史订单。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {

    private static final DateTimeFormatter NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final OrderStatusLogMapper statusLogMapper;
    private final InventoryLogMapper inventoryLogMapper;
    private final DishMapper dishMapper;
    private final SysUserMapper userMapper;
    private final CartService cartService;

    // ---------------------------------------------------------------
    // 用户端
    // ---------------------------------------------------------------

    @Transactional
    public OrderVo createOrder(Long userId, CreateOrderRequest request) {
        ShoppingCart cart = cartService.findOrCreateCart(userId);
        List<ShoppingCartItem> cartItems = cartService.listItems(cart.getId());
        if (cartItems.isEmpty()) {
            throw BizException.of(ErrorCode.CART_EMPTY);
        }
        // 幂等：同一幂等标识已生成过订单则直接返回（防止重复点击）
        if (StringUtils.hasText(request.getIdempotencyKey())) {
            Order existing = orderMapper.selectOne(new LambdaQueryWrapper<Order>()
                    .eq(Order::getUserId, userId)
                    .eq(Order::getRemark, "idem:" + request.getIdempotencyKey())
                    .last("LIMIT 1"));
            if (existing != null) {
                return toVo(existing, true);
            }
        }

        List<Long> dishIds = cartItems.stream().map(ShoppingCartItem::getDishId).toList();
        Map<Long, Dish> dishMap = dishMapper.selectBatchIds(dishIds).stream()
                .collect(Collectors.toMap(Dish::getId, Function.identity(), (a, b) -> a));

        List<OrderItem> orderItems = new ArrayList<>();
        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalCalories = BigDecimal.ZERO;

        for (ShoppingCartItem cartItem : cartItems) {
            Dish dish = dishMap.get(cartItem.getDishId());
            if (dish == null) {
                throw BizException.of(ErrorCode.DISH_UNAVAILABLE, "购物车中有菜品已被删除，请刷新购物车");
            }
            if (!Constants.PublishStatus.PUBLISHED.equals(dish.getPublishStatus())) {
                throw BizException.of(ErrorCode.DISH_UNAVAILABLE, dish.getName() + " 已下架，请移除后再结算");
            }
            if (!Constants.SupplyStatus.AVAILABLE.equals(dish.getSupplyStatus())) {
                throw BizException.of(ErrorCode.DISH_UNAVAILABLE, dish.getName() + " 已售罄或暂停供应，请移除后再结算");
            }
            int quantity = cartItem.getQuantity();
            int updated = dishMapper.deductStock(dish.getId(), quantity);
            if (updated == 0) {
                Dish latest = dishMapper.selectById(dish.getId());
                int left = latest == null || latest.getStock() == null ? 0 : latest.getStock();
                throw BizException.of(ErrorCode.STOCK_NOT_ENOUGH,
                        dish.getName() + " 库存不足（仅剩 " + left + " 份），请调整数量");
            }
            BigDecimal subtotal = dish.getPrice().multiply(BigDecimal.valueOf(quantity))
                    .setScale(2, RoundingMode.HALF_UP);
            BigDecimal calories = dish.getCalories() == null ? BigDecimal.ZERO
                    : dish.getCalories().multiply(BigDecimal.valueOf(quantity)).setScale(2, RoundingMode.HALF_UP);

            OrderItem item = new OrderItem();
            item.setDishId(dish.getId());
            item.setDishNameSnapshot(dish.getName());
            item.setImageUrlSnapshot(dish.getImageUrl());
            item.setUnitPriceSnapshot(dish.getPrice());
            item.setQuantity(quantity);
            item.setSubtotal(subtotal);
            item.setCaloriesSnapshot(calories);
            item.setProteinSnapshot(multiply(dish.getProteinG(), quantity));
            item.setFatSnapshot(multiply(dish.getFatG(), quantity));
            item.setCarbohydrateSnapshot(multiply(dish.getCarbohydrateG(), quantity));
            orderItems.add(item);

            totalAmount = totalAmount.add(subtotal);
            totalCalories = totalCalories.add(calories);
        }

        Order order = new Order();
        order.setOrderNo(generateOrderNo());
        order.setUserId(userId);
        order.setTotalAmount(totalAmount.setScale(2, RoundingMode.HALF_UP));
        order.setTotalCalories(totalCalories.setScale(2, RoundingMode.HALF_UP));
        order.setOrderStatus(Constants.OrderStatus.PENDING);
        order.setPaymentStatus(Constants.PaymentStatus.DEMO_CONFIRMED);
        order.setRemark(StringUtils.hasText(request.getIdempotencyKey())
                ? "idem:" + request.getIdempotencyKey()
                : request.getRemark());
        orderMapper.insert(order);

        for (OrderItem item : orderItems) {
            item.setOrderId(order.getId());
            orderItemMapper.insert(item);
            // 库存流水
            Dish latest = dishMapper.selectById(item.getDishId());
            InventoryLog inventoryLog = new InventoryLog();
            inventoryLog.setDishId(item.getDishId());
            inventoryLog.setChangeAmount(-item.getQuantity());
            inventoryLog.setBeforeStock(latest.getStock() + item.getQuantity());
            inventoryLog.setAfterStock(latest.getStock());
            inventoryLog.setReason(Constants.InventoryReason.ORDER_DEDUCT + " 订单 " + order.getOrderNo() + " 扣减库存");
            inventoryLog.setRelatedOrderId(order.getId());
            inventoryLogMapper.insert(inventoryLog);
        }
        writeStatusLog(order.getId(), null, Constants.OrderStatus.PENDING,
                Constants.OperatorType.USER, userId, "用户确认结算，订单已提交");

        // 结算成功后清空购物车
        cartService.clearByCartId(cart.getId());
        return toVo(order, true);
    }

    private BigDecimal multiply(BigDecimal value, int quantity) {
        if (value == null) {
            return null;
        }
        return value.multiply(BigDecimal.valueOf(quantity)).setScale(2, RoundingMode.HALF_UP);
    }

    public PageResult<OrderVo> listUserOrders(Long userId, long page, long pageSize, String status) {
        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<Order>()
                .eq(Order::getUserId, userId)
                .orderByDesc(Order::getCreatedAt);
        if (StringUtils.hasText(status) && !"ALL".equalsIgnoreCase(status)) {
            wrapper.eq(Order::getOrderStatus, status);
        }
        Page<Order> paged = orderMapper.selectPage(new Page<>(Math.max(page, 1),
                Math.min(Math.max(pageSize, 1), 50)), wrapper);
        List<OrderVo> records = paged.getRecords().stream()
                .map(o -> toVo(o, true)).toList();
        return PageResult.of(records, paged.getTotal(), paged.getCurrent(), paged.getSize());
    }

    public OrderVo getUserOrder(Long userId, Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            throw BizException.of(ErrorCode.NOT_FOUND, "订单不存在");
        }
        return toVo(order, true);
    }

    /**
     * 当前用户"正在进行"的订单（未取消、未完成）。前端据此恢复场景状态。
     */
    public OrderVo getCurrentActiveOrder(Long userId) {
        Order order = orderMapper.selectOne(new LambdaQueryWrapper<Order>()
                .eq(Order::getUserId, userId)
                .in(Order::getOrderStatus, Constants.OrderStatus.ACTIVE_STATUSES)
                .orderByDesc(Order::getCreatedAt)
                .last("LIMIT 1"));
        return order == null ? null : toVo(order, true);
    }

    /**
     * 前端场景推进时同步订单状态（送餐开始 / 已送达 / 用餐中）。只允许向前推进。
     */
    @Transactional
    public OrderVo syncSceneStatus(Long userId, Long orderId, String targetStatus) {
        Order order = orderMapper.selectById(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            throw BizException.of(ErrorCode.NOT_FOUND, "订单不存在");
        }
        if (!Set.of(Constants.OrderStatus.DELIVERING, Constants.OrderStatus.DELIVERED,
                Constants.OrderStatus.EATING, Constants.OrderStatus.COMPLETED)
                .contains(targetStatus)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "不支持由用户端推进的订单状态：" + targetStatus);
        }
        List<String> flow = List.of(Constants.OrderStatus.PENDING, Constants.OrderStatus.PREPARING,
                Constants.OrderStatus.DELIVERING, Constants.OrderStatus.DELIVERED,
                Constants.OrderStatus.EATING, Constants.OrderStatus.COMPLETED);
        int currentIndex = flow.indexOf(order.getOrderStatus());
        int targetIndex = flow.indexOf(targetStatus);
        if (Constants.OrderStatus.CANCELLED.equals(order.getOrderStatus())) {
            throw BizException.of(ErrorCode.ORDER_STATE_INVALID, "订单已取消，无法推进状态");
        }
        if (targetIndex <= currentIndex) {
            return toVo(order, true);
        }
        String from = order.getOrderStatus();
        order.setOrderStatus(targetStatus);
        if (Constants.OrderStatus.COMPLETED.equals(targetStatus)) {
            order.setCompletedAt(LocalDateTime.now());
        }
        orderMapper.updateById(order);
        writeStatusLog(order.getId(), from, targetStatus, Constants.OperatorType.USER, userId,
                "前端场景推进：" + Labels.orderStatus(targetStatus));
        return toVo(order, true);
    }

    // ---------------------------------------------------------------
    // 管理端
    // ---------------------------------------------------------------

    public PageResult<OrderVo> listAdminOrders(long page, long pageSize, String keyword, String status,
                                               LocalDate startDate, LocalDate endDate) {
        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            String kw = keyword.trim();
            List<Long> userIds = userMapper.selectList(new LambdaQueryWrapper<SysUser>()
                            .like(SysUser::getUsername, kw).or().like(SysUser::getNickname, kw))
                    .stream().map(SysUser::getId).toList();
            wrapper.and(w -> {
                w.like(Order::getOrderNo, kw);
                if (!userIds.isEmpty()) {
                    w.or().in(Order::getUserId, userIds);
                }
            });
        }
        if (StringUtils.hasText(status) && !"ALL".equalsIgnoreCase(status)) {
            wrapper.eq(Order::getOrderStatus, status);
        }
        if (startDate != null) {
            wrapper.ge(Order::getCreatedAt, startDate.atStartOfDay());
        }
        if (endDate != null) {
            wrapper.lt(Order::getCreatedAt, endDate.plusDays(1).atStartOfDay());
        }
        wrapper.orderByDesc(Order::getCreatedAt);
        Page<Order> paged = orderMapper.selectPage(new Page<>(Math.max(page, 1),
                Math.min(Math.max(pageSize, 1), 100)), wrapper);
        List<OrderVo> records = paged.getRecords().stream().map(o -> toVo(o, true)).toList();
        return PageResult.of(records, paged.getTotal(), paged.getCurrent(), paged.getSize());
    }

    public OrderVo getAdminOrder(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "订单不存在");
        }
        return toVo(order, true);
    }

    @Transactional
    public OrderVo updateStatusByAdmin(Long orderId, String status, String remark, Long adminId) {
        if (!Constants.OrderStatus.ALL.contains(status)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "不支持的订单状态：" + status);
        }
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "订单不存在");
        }
        String from = order.getOrderStatus();
        if (from.equals(status)) {
            return toVo(order, true);
        }
        if (Constants.OrderStatus.CANCELLED.equals(from)) {
            throw BizException.of(ErrorCode.ORDER_STATE_INVALID, "已取消订单不可再变更状态");
        }
        if (Constants.OrderStatus.CANCELLED.equals(status)) {
            // 取消订单回补库存
            List<OrderItem> items = orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId()));
            for (OrderItem item : items) {
                if (item.getDishId() == null) {
                    continue;
                }
                dishMapper.restoreStock(item.getDishId(), item.getQuantity());
                Dish latest = dishMapper.selectById(item.getDishId());
                if (latest != null) {
                    InventoryLog log = new InventoryLog();
                    log.setDishId(item.getDishId());
                    log.setChangeAmount(item.getQuantity());
                    log.setBeforeStock(latest.getStock() - item.getQuantity());
                    log.setAfterStock(latest.getStock());
                    log.setReason(Constants.InventoryReason.ORDER_CANCEL_RESTORE
                            + " 订单 " + order.getOrderNo() + " 取消回补");
                    log.setOperatorAdminId(adminId);
                    log.setRelatedOrderId(order.getId());
                    inventoryLogMapper.insert(log);
                }
            }
            order.setPaymentStatus(Constants.PaymentStatus.REFUNDED);
        }
        order.setOrderStatus(status);
        if (Constants.OrderStatus.COMPLETED.equals(status)) {
            order.setCompletedAt(LocalDateTime.now());
        }
        orderMapper.updateById(order);
        writeStatusLog(order.getId(), from, status, Constants.OperatorType.ADMIN, adminId,
                StringUtils.hasText(remark) ? remark : "管理员更新订单状态");
        return toVo(order, true);
    }

    // ---------------------------------------------------------------
    // 转换
    // ---------------------------------------------------------------

    public OrderVo toVo(Order order, boolean withItems) {
        OrderVo vo = new OrderVo();
        vo.setId(order.getId());
        vo.setOrderNo(order.getOrderNo());
        vo.setUserId(order.getUserId());
        vo.setTotalAmount(order.getTotalAmount());
        vo.setTotalCalories(order.getTotalCalories());
        vo.setOrderStatus(order.getOrderStatus());
        vo.setOrderStatusLabel(Labels.orderStatus(order.getOrderStatus()));
        vo.setPaymentStatus(order.getPaymentStatus());
        vo.setPaymentStatusLabel(Labels.paymentStatus(order.getPaymentStatus()));
        String remark = order.getRemark();
        vo.setRemark(remark != null && remark.startsWith("idem:") ? null : remark);
        vo.setCreatedAt(order.getCreatedAt());
        vo.setUpdatedAt(order.getUpdatedAt());
        vo.setCompletedAt(order.getCompletedAt());
        vo.setDemo(order.getOrderNo() != null && order.getOrderNo().startsWith("DEMO-"));

        SysUser user = userMapper.selectById(order.getUserId());
        if (user != null) {
            vo.setUserNickname(user.getNickname());
            vo.setUserAccount(user.getUsername());
        }
        if (withItems) {
            List<OrderItem> items = orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId()).orderByAsc(OrderItem::getId));
            List<OrderItemVo> itemVos = items.stream().map(this::toItemVo).toList();
            vo.setItems(itemVos);
            vo.setItemCount(itemVos.size());
            vo.setTotalQuantity(itemVos.stream().mapToInt(OrderItemVo::getQuantity).sum());
            List<OrderStatusLog> logs = statusLogMapper.selectList(new LambdaQueryWrapper<OrderStatusLog>()
                    .eq(OrderStatusLog::getOrderId, order.getId()).orderByAsc(OrderStatusLog::getId));
            vo.setStatusLogs(logs.stream().map(this::toLogVo).toList());
        }
        return vo;
    }

    private OrderItemVo toItemVo(OrderItem item) {
        OrderItemVo vo = new OrderItemVo();
        vo.setId(item.getId());
        vo.setDishId(item.getDishId());
        vo.setDishName(item.getDishNameSnapshot());
        vo.setImageUrl(item.getImageUrlSnapshot());
        vo.setUnitPrice(item.getUnitPriceSnapshot());
        vo.setQuantity(item.getQuantity());
        vo.setSubtotal(item.getSubtotal());
        vo.setCalories(item.getCaloriesSnapshot());
        vo.setProtein(item.getProteinSnapshot());
        vo.setFat(item.getFatSnapshot());
        vo.setCarbohydrate(item.getCarbohydrateSnapshot());
        return vo;
    }

    private OrderStatusLogVo toLogVo(OrderStatusLog log) {
        OrderStatusLogVo vo = new OrderStatusLogVo();
        vo.setId(log.getId());
        vo.setFromStatus(log.getFromStatus());
        vo.setToStatus(log.getToStatus());
        vo.setToStatusLabel(Labels.orderStatus(log.getToStatus()));
        vo.setOperatorType(log.getOperatorType());
        vo.setRemark(log.getRemark());
        vo.setCreatedAt(log.getCreatedAt());
        return vo;
    }

    public void writeStatusLog(Long orderId, String from, String to, String operatorType,
                               Long operatorId, String remark) {
        OrderStatusLog log = new OrderStatusLog();
        log.setOrderId(orderId);
        log.setFromStatus(from);
        log.setToStatus(to);
        log.setOperatorType(operatorType);
        log.setOperatorId(operatorId);
        log.setRemark(remark);
        statusLogMapper.insert(log);
    }

    private String generateOrderNo() {
        String prefix = "ORD" + LocalDateTime.now().format(NO_FORMATTER);
        String orderNo;
        int guard = 0;
        do {
            orderNo = prefix + String.format("%04d", ThreadLocalRandom.current().nextInt(10000));
            guard++;
        } while (guard < 10 && orderMapper.selectCount(new LambdaQueryWrapper<Order>()
                .eq(Order::getOrderNo, orderNo)) > 0);
        return orderNo;
    }

    public List<OrderItem> listItems(Long orderId) {
        return orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, orderId));
    }

    public Order requireOrder(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "订单不存在");
        }
        return order;
    }

    public Long currentUserIdOrNull() {
        try {
            return SecurityUtils.currentUserId();
        } catch (RuntimeException ex) {
            return null;
        }
    }
}
