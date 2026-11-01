package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.canteen.common.Constants;
import com.canteen.entity.Dish;
import com.canteen.entity.DishCategory;
import com.canteen.entity.Order;
import com.canteen.entity.OrderItem;
import com.canteen.entity.SysUser;
import com.canteen.mapper.DishCategoryMapper;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.OrderItemMapper;
import com.canteen.mapper.OrderMapper;
import com.canteen.mapper.SysUserMapper;
import com.canteen.vo.CategorySalesVo;
import com.canteen.vo.HourlyDistributionVo;
import com.canteen.vo.RankingVo;
import com.canteen.vo.StatisticsOverviewVo;
import com.canteen.vo.TrendVo;
import com.canteen.vo.UserGrowthVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 数据统计业务。所有图表数据均由 orders / order_item / dish / sys_user 聚合而来，
 * 取消订单不计入销售额（Constants.OrderStatus.REVENUE_STATUSES）。
 */
@Service
@RequiredArgsConstructor
public class StatisticsService {

    private static final DateTimeFormatter DATE_LABEL = DateTimeFormatter.ofPattern("MM-dd");
    private static final int LOW_STOCK_THRESHOLD = 10;

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final DishMapper dishMapper;
    private final DishCategoryMapper categoryMapper;
    private final SysUserMapper userMapper;

    public StatisticsOverviewVo overview() {
        LocalDate today = LocalDate.now();
        LocalDateTime todayStart = today.atStartOfDay();
        LocalDateTime weekStart = today.minusDays(6).atStartOfDay();
        LocalDateTime monthStart = today.minusDays(29).atStartOfDay();

        List<Order> allOrders = orderMapper.selectList(null);
        List<Order> revenueOrders = allOrders.stream()
                .filter(o -> Constants.OrderStatus.REVENUE_STATUSES.contains(o.getOrderStatus()))
                .toList();

        StatisticsOverviewVo vo = new StatisticsOverviewVo();
        vo.setTodayOrders(countBetween(revenueOrders, todayStart, null));
        vo.setTodaySales(sumBetween(revenueOrders, todayStart, null));
        vo.setWeekOrders(countBetween(revenueOrders, weekStart, null));
        vo.setWeekSales(sumBetween(revenueOrders, weekStart, null));
        vo.setMonthOrders(countBetween(revenueOrders, monthStart, null));
        vo.setMonthSales(sumBetween(revenueOrders, monthStart, null));
        vo.setTotalOrders(revenueOrders.size());
        vo.setTotalSales(revenueOrders.stream().map(Order::getTotalAmount)
                .filter(java.util.Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add).setScale(2, RoundingMode.HALF_UP));
        vo.setAvgOrderAmount(revenueOrders.isEmpty() ? BigDecimal.ZERO
                : vo.getTotalSales().divide(BigDecimal.valueOf(revenueOrders.size()), 2, RoundingMode.HALF_UP));

        List<OrderItem> todayItems = itemsOf(revenueOrders.stream()
                .filter(o -> o.getCreatedAt() != null && !o.getCreatedAt().isBefore(todayStart))
                .map(Order::getId).toList());
        vo.setTodayDishesSold(todayItems.stream().mapToInt(i -> i.getQuantity() == null ? 0 : i.getQuantity()).sum());

        List<Dish> dishes = dishMapper.selectList(null);
        vo.setDishCount(dishes.size());
        vo.setPublishedDishCount(dishes.stream()
                .filter(d -> Constants.PublishStatus.PUBLISHED.equals(d.getPublishStatus())).count());
        vo.setLowStockCount(dishes.stream().filter(d -> d.getStock() != null
                && d.getStock() > 0 && d.getStock() <= LOW_STOCK_THRESHOLD).count());
        vo.setSoldOutCount(dishes.stream().filter(d -> d.getStock() == null || d.getStock() <= 0).count());
        vo.setPendingOrderCount(allOrders.stream()
                .filter(o -> Constants.OrderStatus.PENDING.equals(o.getOrderStatus())
                        || Constants.OrderStatus.PREPARING.equals(o.getOrderStatus())).count());
        vo.setUserCount(userMapper.selectCount(null));
        vo.setActiveUserCount(userMapper.selectCount(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getStatus, Constants.UserStatus.ACTIVE)));
        vo.setNote("统计基于数据库订单聚合；课堂演示数据为初始化模拟数据，金额为模拟订单金额，非真实支付流水。");
        return vo;
    }

    private long countBetween(List<Order> orders, LocalDateTime start, LocalDateTime end) {
        return orders.stream()
                .filter(o -> o.getCreatedAt() != null && !o.getCreatedAt().isBefore(start))
                .filter(o -> end == null || o.getCreatedAt().isBefore(end))
                .count();
    }

    private BigDecimal sumBetween(List<Order> orders, LocalDateTime start, LocalDateTime end) {
        return orders.stream()
                .filter(o -> o.getCreatedAt() != null && !o.getCreatedAt().isBefore(start))
                .filter(o -> end == null || o.getCreatedAt().isBefore(end))
                .map(Order::getTotalAmount).filter(java.util.Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * @param period week（近 7 天）/ month（近 30 天）
     */
    public TrendVo ordersTrend(String period) {
        int days = "month".equalsIgnoreCase(period) ? 30 : 7;
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(days - 1L);
        List<Order> orders = orderMapper.selectList(new LambdaQueryWrapper<Order>()
                .ge(Order::getCreatedAt, start.atStartOfDay())
                .lt(Order::getCreatedAt, end.plusDays(1).atStartOfDay()));
        List<Order> revenueOrders = orders.stream()
                .filter(o -> Constants.OrderStatus.REVENUE_STATUSES.contains(o.getOrderStatus())).toList();

        Map<LocalDate, long[]> counts = new LinkedHashMap<>();
        Map<LocalDate, BigDecimal> amounts = new LinkedHashMap<>();
        for (int i = 0; i < days; i++) {
            LocalDate date = start.plusDays(i);
            counts.put(date, new long[]{0});
            amounts.put(date, BigDecimal.ZERO);
        }
        for (Order order : revenueOrders) {
            LocalDate date = order.getCreatedAt().toLocalDate();
            if (!counts.containsKey(date)) {
                continue;
            }
            counts.get(date)[0]++;
            amounts.put(date, amounts.get(date).add(order.getTotalAmount() == null
                    ? BigDecimal.ZERO : order.getTotalAmount()));
        }
        TrendVo vo = new TrendVo();
        vo.setPeriod(days == 30 ? "month" : "week");
        vo.setLabels(counts.keySet().stream().map(d -> d.format(DATE_LABEL)).toList());
        vo.setOrderCounts(counts.values().stream().map(v -> v[0]).toList());
        vo.setSalesAmounts(amounts.values().stream()
                .map(a -> a.setScale(2, RoundingMode.HALF_UP)).toList());
        vo.setNote("取消订单不计入订单量与销售额统计。");
        return vo;
    }

    public RankingVo dishRanking(int limit) {
        int top = limit <= 0 ? 10 : Math.min(limit, 50);
        List<Order> revenueOrders = orderMapper.selectList(new LambdaQueryWrapper<Order>()
                .in(Order::getOrderStatus, Constants.OrderStatus.REVENUE_STATUSES));
        List<OrderItem> items = itemsOf(revenueOrders.stream().map(Order::getId).toList());

        Map<Long, long[]> quantities = new LinkedHashMap<>();
        Map<Long, BigDecimal> amounts = new LinkedHashMap<>();
        Map<Long, String> names = new LinkedHashMap<>();
        Map<Long, String> images = new LinkedHashMap<>();
        for (OrderItem item : items) {
            Long key = item.getDishId() != null ? item.getDishId() : -1L;
            quantities.computeIfAbsent(key, k -> new long[]{0})[0] +=
                    item.getQuantity() == null ? 0 : item.getQuantity();
            amounts.merge(key, item.getSubtotal() == null ? BigDecimal.ZERO : item.getSubtotal(), BigDecimal::add);
            names.putIfAbsent(key, item.getDishNameSnapshot());
            images.putIfAbsent(key, item.getImageUrlSnapshot());
        }
        Map<Long, DishCategory> categories = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(DishCategory::getId, Function.identity(), (a, b) -> a));
        Map<Long, Dish> dishes = dishMapper.selectList(null).stream()
                .collect(Collectors.toMap(Dish::getId, Function.identity(), (a, b) -> a));

        BigDecimal totalAmount = amounts.values().stream()
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        List<RankingVo.Item> list = quantities.entrySet().stream()
                .map(entry -> {
                    RankingVo.Item item = new RankingVo.Item();
                    item.setDishId(entry.getKey());
                    item.setName(names.getOrDefault(entry.getKey(), "（历史菜品）"));
                    item.setImageUrl(images.get(entry.getKey()));
                    Dish dish = dishes.get(entry.getKey());
                    item.setCategoryName(dish == null ? null
                            : categories.getOrDefault(dish.getCategoryId(), null) == null ? null
                            : categories.get(dish.getCategoryId()).getName());
                    item.setQuantity(entry.getValue()[0]);
                    BigDecimal amount = amounts.getOrDefault(entry.getKey(), BigDecimal.ZERO)
                            .setScale(2, RoundingMode.HALF_UP);
                    item.setAmount(amount);
                    item.setShare(totalAmount.compareTo(BigDecimal.ZERO) == 0 ? BigDecimal.ZERO
                            : amount.multiply(BigDecimal.valueOf(100))
                            .divide(totalAmount, 1, RoundingMode.HALF_UP));
                    return item;
                })
                .sorted(Comparator.comparingLong(RankingVo.Item::getQuantity).reversed())
                .limit(top)
                .toList();
        RankingVo vo = new RankingVo();
        vo.setItems(list);
        return vo;
    }

    public CategorySalesVo categorySales() {
        List<Order> revenueOrders = orderMapper.selectList(new LambdaQueryWrapper<Order>()
                .in(Order::getOrderStatus, Constants.OrderStatus.REVENUE_STATUSES));
        List<OrderItem> items = itemsOf(revenueOrders.stream().map(Order::getId).toList());
        Map<Long, Dish> dishes = dishMapper.selectList(null).stream()
                .collect(Collectors.toMap(Dish::getId, Function.identity(), (a, b) -> a));
        Map<Long, DishCategory> categories = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(DishCategory::getId, Function.identity(), (a, b) -> a));

        Map<String, long[]> quantities = new LinkedHashMap<>();
        Map<String, BigDecimal> amounts = new LinkedHashMap<>();
        Map<String, Long> categoryIds = new LinkedHashMap<>();
        for (OrderItem item : items) {
            Dish dish = item.getDishId() == null ? null : dishes.get(item.getDishId());
            DishCategory category = dish == null ? null : categories.get(dish.getCategoryId());
            String name = category == null ? "其他/历史菜品" : category.getName();
            quantities.computeIfAbsent(name, k -> new long[]{0})[0] +=
                    item.getQuantity() == null ? 0 : item.getQuantity();
            amounts.merge(name, item.getSubtotal() == null ? BigDecimal.ZERO : item.getSubtotal(), BigDecimal::add);
            if (category != null) {
                categoryIds.putIfAbsent(name, category.getId());
            }
        }
        long totalQuantity = quantities.values().stream().mapToLong(v -> v[0]).sum();
        BigDecimal totalAmount = amounts.values().stream().reduce(BigDecimal.ZERO, BigDecimal::add);

        List<CategorySalesVo.Item> list = quantities.entrySet().stream()
                .map(entry -> {
                    CategorySalesVo.Item item = new CategorySalesVo.Item();
                    item.setCategoryId(categoryIds.get(entry.getKey()));
                    item.setCategoryName(entry.getKey());
                    item.setQuantity(entry.getValue()[0]);
                    BigDecimal amount = amounts.getOrDefault(entry.getKey(), BigDecimal.ZERO)
                            .setScale(2, RoundingMode.HALF_UP);
                    item.setAmount(amount);
                    item.setShare(totalAmount.compareTo(BigDecimal.ZERO) == 0 ? BigDecimal.ZERO
                            : amount.multiply(BigDecimal.valueOf(100))
                            .divide(totalAmount, 1, RoundingMode.HALF_UP));
                    return item;
                })
                .sorted(Comparator.comparingLong(CategorySalesVo.Item::getQuantity).reversed())
                .toList();

        CategorySalesVo vo = new CategorySalesVo();
        vo.setTotalQuantity(totalQuantity);
        vo.setTotalAmount(totalAmount.setScale(2, RoundingMode.HALF_UP));
        vo.setItems(list);
        return vo;
    }

    public HourlyDistributionVo hourlyDistribution() {
        List<Order> revenueOrders = orderMapper.selectList(new LambdaQueryWrapper<Order>()
                .in(Order::getOrderStatus, Constants.OrderStatus.REVENUE_STATUSES));
        long[] counts = new long[24];
        for (Order order : revenueOrders) {
            if (order.getCreatedAt() != null) {
                counts[order.getCreatedAt().getHour()]++;
            }
        }
        HourlyDistributionVo vo = new HourlyDistributionVo();
        List<String> labels = new ArrayList<>();
        List<Long> values = new ArrayList<>();
        for (int i = 0; i < 24; i++) {
            labels.add(String.format("%02d:00", i));
            values.add(counts[i]);
        }
        vo.setLabels(labels);
        vo.setCounts(values);
        vo.setNote("按订单创建时间的小时分布统计（全部有效订单）。");
        return vo;
    }

    public UserGrowthVo userGrowth() {
        int days = 7;
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(days - 1L);
        List<SysUser> users = userMapper.selectList(null);
        Map<LocalDate, Long> newUsers = new LinkedHashMap<>();
        for (int i = 0; i < days; i++) {
            newUsers.put(start.plusDays(i), 0L);
        }
        long beforeStart = 0;
        for (SysUser user : users) {
            if (user.getCreatedAt() == null) {
                continue;
            }
            LocalDate date = user.getCreatedAt().toLocalDate();
            if (date.isBefore(start)) {
                beforeStart++;
            } else if (newUsers.containsKey(date)) {
                newUsers.put(date, newUsers.get(date) + 1);
            }
        }
        List<Long> cumulative = new ArrayList<>();
        long running = beforeStart;
        for (Long value : newUsers.values()) {
            running += value;
            cumulative.add(running);
        }
        UserGrowthVo vo = new UserGrowthVo();
        vo.setLabels(newUsers.keySet().stream().map(d -> d.format(DATE_LABEL)).toList());
        vo.setNewUsers(new ArrayList<>(newUsers.values()));
        vo.setCumulativeUsers(cumulative);
        vo.setNote("基于 sys_user.created_at 统计的注册用户增长。");
        return vo;
    }

    private List<OrderItem> itemsOf(List<Long> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return List.of();
        }
        // 分批查询，避免 IN 列表过长
        List<OrderItem> all = new ArrayList<>();
        int batch = 500;
        for (int i = 0; i < orderIds.size(); i += batch) {
            List<Long> slice = orderIds.subList(i, Math.min(i + batch, orderIds.size()));
            all.addAll(orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                    .in(OrderItem::getOrderId, slice)));
        }
        return all;
    }
}
