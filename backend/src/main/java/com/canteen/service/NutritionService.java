package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.canteen.common.BizException;
import com.canteen.common.Constants;
import com.canteen.common.ErrorCode;
import com.canteen.common.PageResult;
import com.canteen.entity.DishCategory;
import com.canteen.entity.Order;
import com.canteen.entity.OrderItem;
import com.canteen.entity.SysUser;
import com.canteen.mapper.DishCategoryMapper;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.OrderItemMapper;
import com.canteen.mapper.OrderMapper;
import com.canteen.mapper.SysUserMapper;
import com.canteen.vo.NutritionSummaryVo;
import com.canteen.vo.NutritionTrendPointVo;
import com.canteen.vo.UserVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 营养分析业务。所有数值都由订单明细快照聚合而来，属于估算值，不是真实体检数据。
 */
@Service
@RequiredArgsConstructor
public class NutritionService {

    private static final BigDecimal TARGET_CALORIES = BigDecimal.valueOf(2000);
    private static final BigDecimal TARGET_PROTEIN = BigDecimal.valueOf(70);
    private static final BigDecimal TARGET_WATER = BigDecimal.valueOf(1500);
    private static final BigDecimal DEMO_WATER_ML = BigDecimal.valueOf(800);
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("MM-dd");

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final SysUserMapper userMapper;
    private final DishMapper dishMapper;
    private final DishCategoryMapper categoryMapper;

    /**
     * @param days 统计最近 N 天（含今天），默认 7 天
     */
    public NutritionSummaryVo summary(Long userId, int days) {
        int span = days <= 0 ? 7 : Math.min(days, 90);
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(span - 1L);
        List<Order> orders = orderMapper.selectList(new LambdaQueryWrapper<Order>()
                .eq(Order::getUserId, userId)
                .in(Order::getOrderStatus, Constants.OrderStatus.REVENUE_STATUSES)
                .ge(Order::getCreatedAt, start.atStartOfDay())
                .lt(Order::getCreatedAt, end.plusDays(1).atStartOfDay()));
        List<Long> orderIds = orders.stream().map(Order::getId).toList();
        List<OrderItem> items = orderIds.isEmpty() ? List.of()
                : orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                .in(OrderItem::getOrderId, orderIds));

        BigDecimal calories = BigDecimal.ZERO;
        BigDecimal protein = BigDecimal.ZERO;
        BigDecimal fat = BigDecimal.ZERO;
        BigDecimal carbohydrate = BigDecimal.ZERO;
        BigDecimal fiber = BigDecimal.ZERO;
        int dishCount = 0;
        for (OrderItem item : items) {
            calories = calories.add(nz(item.getCaloriesSnapshot()));
            protein = protein.add(nz(item.getProteinSnapshot()));
            fat = fat.add(nz(item.getFatSnapshot()));
            carbohydrate = carbohydrate.add(nz(item.getCarbohydrateSnapshot()));
            dishCount += item.getQuantity() == null ? 0 : item.getQuantity();
        }
        // 膳食纤维来自菜品当前营养字段（订单快照未包含纤维），标注为估算
        BigDecimal fiberEstimate = estimateFiber(items);

        NutritionSummaryVo vo = new NutritionSummaryVo();
        vo.setPeriod("最近 " + span + " 天");
        vo.setTotalCalories(scale(calories));
        vo.setTotalProtein(scale(protein));
        vo.setTotalFat(scale(fat));
        vo.setTotalCarbohydrate(scale(carbohydrate));
        vo.setTotalFiber(scale(fiberEstimate));
        vo.setTotalSodium(BigDecimal.ZERO);
        vo.setOrderCount(orders.size());
        vo.setDishCount(dishCount);
        vo.setTargetCalories(TARGET_CALORIES);
        vo.setTargetProtein(TARGET_PROTEIN);
        vo.setTargetWater(TARGET_WATER);
        vo.setWaterMl(DEMO_WATER_ML);
        // 达成率口径：日均摄入 / 每日参考值（避免把 N 天累计值直接对比单日目标）
        BigDecimal dayCount = BigDecimal.valueOf(Math.max(span, 1));
        BigDecimal dailyCalories = calories.divide(dayCount, 1, RoundingMode.HALF_UP);
        BigDecimal dailyProtein = protein.divide(dayCount, 1, RoundingMode.HALF_UP);
        BigDecimal dailyFiber = fiberEstimate.divide(dayCount, 1, RoundingMode.HALF_UP);
        vo.setDailyCalories(dailyCalories.setScale(1, RoundingMode.HALF_UP));
        vo.setDailyProtein(dailyProtein.setScale(1, RoundingMode.HALF_UP));
        vo.setCalorieRate(rate(dailyCalories, TARGET_CALORIES));
        vo.setProteinRate(rate(dailyProtein, TARGET_PROTEIN));
        vo.setWaterRate(rate(DEMO_WATER_ML, TARGET_WATER));
        vo.setSuggestions(buildSuggestions(dailyCalories, dailyProtein, dailyFiber, orders.size()));
        vo.setNote("营养数值基于菜品估算数据聚合，为课堂演示估算值，不是医学检测结果。");
        vo.setTrend(trend(userId, span));
        return vo;
    }

    public List<NutritionTrendPointVo> trend(Long userId, int days) {
        int span = days <= 0 ? 7 : Math.min(days, 90);
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(span - 1L);
        List<Order> orders = orderMapper.selectList(new LambdaQueryWrapper<Order>()
                .eq(Order::getUserId, userId)
                .in(Order::getOrderStatus, Constants.OrderStatus.REVENUE_STATUSES)
                .ge(Order::getCreatedAt, start.atStartOfDay())
                .lt(Order::getCreatedAt, end.plusDays(1).atStartOfDay()));
        Map<Long, LocalDate> orderDates = orders.stream()
                .collect(Collectors.toMap(Order::getId,
                        o -> o.getCreatedAt() == null ? LocalDate.now() : o.getCreatedAt().toLocalDate()));
        List<OrderItem> items = orders.isEmpty() ? List.of()
                : orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                .in(OrderItem::getOrderId, orderDates.keySet()));

        Map<LocalDate, NutritionTrendPointVo> bucket = new java.util.LinkedHashMap<>();
        for (int i = 0; i < span; i++) {
            LocalDate date = start.plusDays(i);
            NutritionTrendPointVo point = new NutritionTrendPointVo();
            point.setDate(date.format(DATE_FORMAT));
            bucket.put(date, point);
        }
        for (OrderItem item : items) {
            LocalDate date = orderDates.get(item.getOrderId());
            if (date == null) {
                continue;
            }
            NutritionTrendPointVo point = bucket.get(date);
            if (point == null) {
                continue;
            }
            point.setCalories(point.getCalories().add(nz(item.getCaloriesSnapshot())).setScale(2, RoundingMode.HALF_UP));
            point.setProtein(point.getProtein().add(nz(item.getProteinSnapshot())).setScale(2, RoundingMode.HALF_UP));
            point.setFat(point.getFat().add(nz(item.getFatSnapshot())).setScale(2, RoundingMode.HALF_UP));
            point.setCarbohydrate(point.getCarbohydrate().add(nz(item.getCarbohydrateSnapshot()))
                    .setScale(2, RoundingMode.HALF_UP));
        }
        for (Order order : orders) {
            LocalDate date = order.getCreatedAt() == null ? LocalDate.now() : order.getCreatedAt().toLocalDate();
            NutritionTrendPointVo point = bucket.get(date);
            if (point != null) {
                point.setOrderCount(point.getOrderCount() + 1);
            }
        }
        return new ArrayList<>(bucket.values());
    }

    private BigDecimal estimateFiber(List<OrderItem> items) {
        if (items.isEmpty()) {
            return BigDecimal.ZERO;
        }
        List<Long> dishIds = items.stream().map(OrderItem::getDishId).filter(java.util.Objects::nonNull).distinct().toList();
        if (dishIds.isEmpty()) {
            return BigDecimal.ZERO;
        }
        Map<Long, com.canteen.entity.Dish> dishes = dishMapper.selectBatchIds(dishIds).stream()
                .collect(Collectors.toMap(com.canteen.entity.Dish::getId, d -> d, (a, b) -> a));
        BigDecimal fiber = BigDecimal.ZERO;
        for (OrderItem item : items) {
            com.canteen.entity.Dish dish = dishes.get(item.getDishId());
            if (dish != null && dish.getFiberG() != null && item.getQuantity() != null) {
                fiber = fiber.add(dish.getFiberG().multiply(BigDecimal.valueOf(item.getQuantity())));
            }
        }
        return fiber;
    }

    private List<String> buildSuggestions(BigDecimal calories, BigDecimal protein, BigDecimal fiber, int orderCount) {
        List<String> suggestions = new ArrayList<>();
        if (orderCount == 0) {
            suggestions.add("还没有用餐记录，去点一份营养均衡的套餐吧。");
            return suggestions;
        }
        if (calories.compareTo(TARGET_CALORIES) < 0) {
            suggestions.add("当前热量摄入低于每日参考值，可适当增加主食或蛋白质。");
        } else if (calories.compareTo(TARGET_CALORIES.multiply(BigDecimal.valueOf(1.2))) > 0) {
            suggestions.add("热量摄入偏高，下一餐可以选清淡一些的菜品。");
        }
        if (protein.compareTo(TARGET_PROTEIN) < 0) {
            suggestions.add("蛋白质偏少，建议补充鸡蛋、豆制品或瘦肉。");
        }
        if (fiber.compareTo(BigDecimal.valueOf(10)) < 0) {
            suggestions.add("膳食纤维摄入不足，可以加一份绿叶蔬菜。");
        }
        suggestions.add("记得多喝水，按需取餐、珍惜粮食。");
        return suggestions;
    }

    private BigDecimal rate(BigDecimal value, BigDecimal target) {
        if (target.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        return value.multiply(BigDecimal.valueOf(100))
                .divide(target, 1, RoundingMode.HALF_UP)
                .min(BigDecimal.valueOf(999));
    }

    private BigDecimal nz(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    private BigDecimal scale(BigDecimal value) {
        return value.setScale(1, RoundingMode.HALF_UP);
    }

    // ---------------------------------------------------------------
    // 管理端：用户列表（营养管理页使用）
    // ---------------------------------------------------------------

    public PageResult<UserVo> listUsers(long page, long pageSize, String keyword, String status) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            String kw = keyword.trim();
            wrapper.and(w -> w.like(SysUser::getUsername, kw).or().like(SysUser::getNickname, kw)
                    .or().like(SysUser::getPhone, kw));
        }
        if (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status)) {
            wrapper.eq(SysUser::getStatus, status);
        }
        wrapper.orderByDesc(SysUser::getCreatedAt);
        Page<SysUser> paged = userMapper.selectPage(new Page<>(Math.max(page, 1),
                Math.min(Math.max(pageSize, 1), 100)), wrapper);
        List<UserVo> records = paged.getRecords().stream().map(user -> {
            UserVo vo = new UserVo();
            vo.setId(user.getId());
            vo.setUsername(user.getUsername());
            vo.setNickname(user.getNickname());
            vo.setEmail(user.getEmail());
            vo.setPhone(user.getPhone());
            vo.setAvatarUrl(user.getAvatarUrl());
            vo.setStatus(user.getStatus());
            vo.setCreatedAt(user.getCreatedAt());
            vo.setOrderCount(orderMapper.selectCount(new LambdaQueryWrapper<Order>()
                    .eq(Order::getUserId, user.getId())));
            return vo;
        }).toList();
        return PageResult.of(records, paged.getTotal(), paged.getCurrent(), paged.getSize());
    }

    @Transactional
    public void changeUserStatus(Long userId, String status) {
        if (!List.of(Constants.UserStatus.ACTIVE, Constants.UserStatus.DISABLED).contains(status)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "不支持的用户状态：" + status);
        }
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "用户不存在");
        }
        user.setStatus(status);
        userMapper.updateById(user);
    }

    public List<UserVo> userOrderHistory(Long userId) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "用户不存在");
        }
        UserVo vo = new UserVo();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setNickname(user.getNickname());
        vo.setOrderCount(orderMapper.selectCount(new LambdaQueryWrapper<Order>()
                .eq(Order::getUserId, userId)));
        return List.of(vo);
    }

    /** 管理端：营养缺失菜品提示 */
    public List<Map<String, Object>> nutritionGaps() {
        Map<Long, DishCategory> categories = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(DishCategory::getId, c -> c, (a, b) -> a));
        return dishMapper.selectList(new LambdaQueryWrapper<com.canteen.entity.Dish>()
                        .orderByAsc(com.canteen.entity.Dish::getId))
                .stream()
                .filter(d -> d.getCalories() == null || d.getProteinG() == null
                        || d.getFatG() == null || d.getCarbohydrateG() == null)
                .map(d -> {
                    Map<String, Object> map = new java.util.LinkedHashMap<>();
                    map.put("dishId", d.getId());
                    map.put("dishCode", d.getDishCode());
                    map.put("name", d.getName());
                    DishCategory category = categories.get(d.getCategoryId());
                    map.put("categoryName", category == null ? null : category.getName());
                    map.put("calories", d.getCalories());
                    map.put("proteinG", d.getProteinG());
                    map.put("fatG", d.getFatG());
                    map.put("carbohydrateG", d.getCarbohydrateG());
                    map.put("updatedAt", d.getUpdatedAt());
                    return map;
                }).toList();
    }
}
