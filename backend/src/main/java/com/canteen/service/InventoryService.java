package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.canteen.common.BizException;
import com.canteen.common.Constants;
import com.canteen.common.ErrorCode;
import com.canteen.dto.InventoryAdjustRequest;
import com.canteen.common.PageResult;
import com.canteen.entity.Dish;
import com.canteen.entity.DishCategory;
import com.canteen.entity.InventoryLog;
import com.canteen.entity.SysAdmin;
import com.canteen.mapper.DishCategoryMapper;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.InventoryLogMapper;
import com.canteen.mapper.SysAdminMapper;
import com.canteen.vo.InventoryItemVo;
import com.canteen.vo.InventoryLogVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 库存业务：库存调整必须记录流水（前后数量、原因、操作管理员）。
 */
@Service
@RequiredArgsConstructor
public class InventoryService {

    private static final int LOW_STOCK_THRESHOLD = 10;

    private final DishMapper dishMapper;
    private final DishCategoryMapper categoryMapper;
    private final InventoryLogMapper inventoryLogMapper;
    private final SysAdminMapper adminMapper;

    public List<InventoryItemVo> list(String keyword, Boolean lowStockOnly) {
        LambdaQueryWrapper<Dish> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like(Dish::getName, keyword.trim()).or().like(Dish::getDishCode, keyword.trim()));
        }
        wrapper.orderByAsc(Dish::getStock).orderByAsc(Dish::getId);
        Map<Long, DishCategory> categories = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(DishCategory::getId, Function.identity(), (a, b) -> a));
        return dishMapper.selectList(wrapper).stream()
                .map(dish -> toItemVo(dish, categories.get(dish.getCategoryId())))
                .filter(vo -> !Boolean.TRUE.equals(lowStockOnly) || Boolean.TRUE.equals(vo.getLowStock()))
                .toList();
    }

    private InventoryItemVo toItemVo(Dish dish, DishCategory category) {
        InventoryItemVo vo = new InventoryItemVo();
        vo.setDishId(dish.getId());
        vo.setDishCode(dish.getDishCode());
        vo.setName(dish.getName());
        vo.setImageUrl(dish.getImageUrl());
        vo.setCategoryName(category == null ? null : category.getName());
        vo.setStock(dish.getStock());
        vo.setDailyLimit(dish.getDailyLimit());
        vo.setSoldCount(dish.getSoldCount());
        vo.setRemaining(dish.getStock());
        vo.setSupplyStatus(dish.getSupplyStatus());
        vo.setPublishStatus(dish.getPublishStatus());
        vo.setLowStock(dish.getStock() != null && dish.getStock() <= LOW_STOCK_THRESHOLD);
        vo.setSoldOut(dish.getStock() == null || dish.getStock() <= 0);
        vo.setUpdatedAt(dish.getUpdatedAt());
        return vo;
    }

    @Transactional
    public InventoryItemVo adjust(InventoryAdjustRequest request, Long adminId) {
        Dish dish = dishMapper.selectById(request.getDishId());
        if (dish == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "菜品不存在");
        }
        int before = dish.getStock() == null ? 0 : dish.getStock();
        int after;
        if (request.getTargetStock() != null) {
            after = request.getTargetStock();
        } else if (request.getChangeAmount() != null) {
            after = before + request.getChangeAmount();
        } else {
            throw BizException.of(ErrorCode.BAD_REQUEST, "请提供调整数量或目标库存");
        }
        if (after < 0) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "调整后库存不能小于 0");
        }
        if (after > 99999) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "库存数量超出合理范围");
        }
        dish.setStock(after);
        if (after == 0) {
            dish.setSupplyStatus(Constants.SupplyStatus.SOLD_OUT);
        } else if (Constants.SupplyStatus.SOLD_OUT.equals(dish.getSupplyStatus())) {
            dish.setSupplyStatus(Constants.SupplyStatus.AVAILABLE);
        }
        dishMapper.updateById(dish);

        InventoryLog log = new InventoryLog();
        log.setDishId(dish.getId());
        log.setChangeAmount(after - before);
        log.setBeforeStock(before);
        log.setAfterStock(after);
        log.setReason(request.getReason());
        log.setOperatorAdminId(adminId);
        inventoryLogMapper.insert(log);

        DishCategory category = categoryMapper.selectById(dish.getCategoryId());
        return toItemVo(dish, category);
    }

    @Transactional
    public void changeSupplyStatus(Long dishId, String status) {
        if (!List.of(Constants.SupplyStatus.AVAILABLE, Constants.SupplyStatus.SOLD_OUT,
                Constants.SupplyStatus.PAUSED).contains(status)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "不支持的供应状态：" + status);
        }
        Dish dish = dishMapper.selectById(dishId);
        if (dish == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "菜品不存在");
        }
        dish.setSupplyStatus(status);
        dishMapper.updateById(dish);
    }

    public PageResult<InventoryLogVo> listLogs(long page, long pageSize, Long dishId) {
        LambdaQueryWrapper<InventoryLog> wrapper = new LambdaQueryWrapper<>();
        if (dishId != null) {
            wrapper.eq(InventoryLog::getDishId, dishId);
        }
        wrapper.orderByDesc(InventoryLog::getCreatedAt).orderByDesc(InventoryLog::getId);
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<InventoryLog> paged =
                inventoryLogMapper.selectPage(new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(
                        Math.max(page, 1), Math.min(Math.max(pageSize, 1), 100)), wrapper);

        Map<Long, Dish> dishes = paged.getRecords().isEmpty() ? Map.of()
                : dishMapper.selectBatchIds(paged.getRecords().stream().map(InventoryLog::getDishId).distinct().toList())
                .stream().collect(Collectors.toMap(Dish::getId, Function.identity(), (a, b) -> a));
        Map<Long, SysAdmin> admins = adminMapper.selectList(null).stream()
                .collect(Collectors.toMap(SysAdmin::getId, Function.identity(), (a, b) -> a));

        List<InventoryLogVo> records = paged.getRecords().stream().map(log -> {
            InventoryLogVo vo = new InventoryLogVo();
            vo.setId(log.getId());
            vo.setDishId(log.getDishId());
            Dish dish = dishes.get(log.getDishId());
            vo.setDishName(dish == null ? "（已删除菜品）" : dish.getName());
            vo.setChangeAmount(log.getChangeAmount());
            vo.setBeforeStock(log.getBeforeStock());
            vo.setAfterStock(log.getAfterStock());
            vo.setReason(log.getReason());
            vo.setOperatorAdminId(log.getOperatorAdminId());
            SysAdmin admin = log.getOperatorAdminId() == null ? null : admins.get(log.getOperatorAdminId());
            vo.setOperatorName(admin == null ? "系统/订单业务" : admin.getDisplayName());
            vo.setRelatedOrderId(log.getRelatedOrderId());
            vo.setCreatedAt(log.getCreatedAt());
            return vo;
        }).toList();
        return PageResult.of(records, paged.getTotal(), paged.getCurrent(), paged.getSize());
    }

    public int lowStockThreshold() {
        return LOW_STOCK_THRESHOLD;
    }
}
