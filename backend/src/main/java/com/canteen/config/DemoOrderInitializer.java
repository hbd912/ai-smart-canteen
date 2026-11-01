package com.canteen.config;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.canteen.common.Constants;
import com.canteen.entity.Dish;
import com.canteen.entity.InventoryLog;
import com.canteen.entity.Order;
import com.canteen.entity.OrderItem;
import com.canteen.entity.OrderStatusLog;
import com.canteen.entity.SysUser;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.InventoryLogMapper;
import com.canteen.mapper.OrderItemMapper;
import com.canteen.mapper.OrderMapper;
import com.canteen.mapper.OrderStatusLogMapper;
import com.canteen.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 演示订单初始化：生成足够支撑统计图表的订单数据（默认 36 笔，分布最近 7 天）。
 * <p>
 * 幂等：以 DEMO- 前缀 + 固定序号检查，已存在则跳过，重启不会重复生成。
 * 口径说明：菜品初始库存视为"当前剩余库存"，演示订单的销量同时写入 sold_count，
 * 因此库存与销量保持一致（不重复扣减初始库存）。
 */
@Slf4j
@Component
@org.springframework.core.annotation.Order(2)
@RequiredArgsConstructor
public class DemoOrderInitializer implements ApplicationRunner {

    private static final String DEMO_PREFIX = "DEMO-";
    private static final int DEMO_ORDER_COUNT = 36;
    private static final DateTimeFormatter NO_FORMAT = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    private static final long RANDOM_SEED = 20260101L;

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final OrderStatusLogMapper statusLogMapper;
    private final InventoryLogMapper inventoryLogMapper;
    private final DishMapper dishMapper;
    private final SysUserMapper userMapper;
    private final CanteenProperties properties;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (!properties.getDemo().isEnabled() || !properties.getDemo().isOrderSeedEnabled()) {
            log.info("演示订单初始化已关闭");
            return;
        }
        List<SysUser> users = userMapper.selectList(new LambdaQueryWrapper<SysUser>()
                .orderByAsc(SysUser::getId));
        if (users.isEmpty()) {
            log.warn("没有可用用户，跳过演示订单初始化");
            return;
        }
        List<Dish> dishes = dishMapper.selectList(new LambdaQueryWrapper<Dish>()
                .eq(Dish::getPublishStatus, Constants.PublishStatus.PUBLISHED)
                .orderByAsc(Dish::getId));
        if (dishes.size() < 3) {
            log.warn("可用菜品不足，跳过演示订单初始化");
            return;
        }

        long existing = orderMapper.selectCount(new LambdaQueryWrapper<Order>()
                .likeRight(Order::getOrderNo, DEMO_PREFIX));
        if (existing >= DEMO_ORDER_COUNT) {
            log.info("演示订单已存在 {} 笔，跳过初始化", existing);
            return;
        }

        Random random = new Random(RANDOM_SEED);
        Map<Long, Dish> dishMap = dishes.stream()
                .collect(Collectors.toMap(Dish::getId, Function.identity(), (a, b) -> a));
        String[] statuses = {
                Constants.OrderStatus.COMPLETED, Constants.OrderStatus.COMPLETED,
                Constants.OrderStatus.COMPLETED, Constants.OrderStatus.DELIVERED,
                Constants.OrderStatus.EATING, Constants.OrderStatus.PREPARING,
                Constants.OrderStatus.PENDING, Constants.OrderStatus.CANCELLED
        };
        int created = 0;
        for (int i = 1; i <= DEMO_ORDER_COUNT; i++) {
            String orderNo = DEMO_PREFIX + String.format("%04d", i);
            if (orderMapper.selectCount(new LambdaQueryWrapper<Order>()
                    .eq(Order::getOrderNo, orderNo)) > 0) {
                continue;
            }
            SysUser user = users.get(i % users.size());
            // 最近 7 天分布：0..6 天前
            int daysAgo = (i * 3 + random.nextInt(3)) % 7;
            int hour = 7 + random.nextInt(13);   // 7:00 - 19:59
            int minute = random.nextInt(60);
            LocalDateTime createdAt = LocalDate.now().minusDays(daysAgo)
                    .atTime(hour, minute, random.nextInt(60));
            if (createdAt.isAfter(LocalDateTime.now())) {
                createdAt = LocalDateTime.now().minusHours(1);
            }
            String status = statuses[i % statuses.length];

            int itemCount = 1 + random.nextInt(3);
            java.util.Set<Long> picked = new java.util.LinkedHashSet<>();
            while (picked.size() < itemCount) {
                picked.add(dishes.get(random.nextInt(dishes.size())).getId());
            }

            BigDecimal totalAmount = BigDecimal.ZERO;
            BigDecimal totalCalories = BigDecimal.ZERO;
            List<OrderItem> items = new java.util.ArrayList<>();
            for (Long dishId : picked) {
                Dish dish = dishMap.get(dishId);
                int quantity = 1 + random.nextInt(2);
                BigDecimal subtotal = dish.getPrice().multiply(BigDecimal.valueOf(quantity))
                        .setScale(2, RoundingMode.HALF_UP);
                BigDecimal calories = dish.getCalories() == null ? BigDecimal.ZERO
                        : dish.getCalories().multiply(BigDecimal.valueOf(quantity))
                        .setScale(2, RoundingMode.HALF_UP);
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
                item.setCreatedAt(createdAt);
                items.add(item);
                totalAmount = totalAmount.add(subtotal);
                totalCalories = totalCalories.add(calories);
            }

            Order order = new Order();
            order.setOrderNo(orderNo);
            order.setUserId(user.getId());
            order.setTotalAmount(totalAmount.setScale(2, RoundingMode.HALF_UP));
            order.setTotalCalories(totalCalories.setScale(2, RoundingMode.HALF_UP));
            order.setOrderStatus(status);
            order.setPaymentStatus(Constants.OrderStatus.CANCELLED.equals(status)
                    ? Constants.PaymentStatus.REFUNDED : Constants.PaymentStatus.DEMO_CONFIRMED);
            order.setRemark("课堂演示初始化订单");
            order.setCreatedAt(createdAt);
            order.setUpdatedAt(createdAt);
            if (Constants.OrderStatus.COMPLETED.equals(status)) {
                order.setCompletedAt(createdAt.plusMinutes(25));
            }
            orderMapper.insert(order);

            for (OrderItem item : items) {
                item.setOrderId(order.getId());
                orderItemMapper.insert(item);
                if (!Constants.OrderStatus.CANCELLED.equals(status)) {
                    Dish dish = dishMap.get(item.getDishId());
                    dish.setSoldCount((dish.getSoldCount() == null ? 0 : dish.getSoldCount()) + item.getQuantity());
                }
            }
            // 每个订单保留一条状态流水，便于后台查看订单轨迹
            OrderStatusLog logEntry = new OrderStatusLog();
            logEntry.setOrderId(order.getId());
            logEntry.setFromStatus(null);
            logEntry.setToStatus(Constants.OrderStatus.PENDING);
            logEntry.setOperatorType(Constants.OperatorType.USER);
            logEntry.setOperatorId(user.getId());
            logEntry.setRemark("演示订单初始化");
            logEntry.setCreatedAt(createdAt);
            statusLogMapper.insert(logEntry);
            if (!Constants.OrderStatus.PENDING.equals(status)) {
                OrderStatusLog latest = new OrderStatusLog();
                latest.setOrderId(order.getId());
                latest.setFromStatus(Constants.OrderStatus.PENDING);
                latest.setToStatus(status);
                latest.setOperatorType(Constants.OperatorType.SYSTEM);
                latest.setRemark("演示数据状态初始化");
                latest.setCreatedAt(createdAt.plusMinutes(10));
                statusLogMapper.insert(latest);
            }
            created++;
        }

        // 同步菜品销量到数据库（一次性写回）
        for (Dish dish : dishMap.values()) {
            Dish latest = dishMapper.selectById(dish.getId());
            if (latest != null && !java.util.Objects.equals(latest.getSoldCount(), dish.getSoldCount())) {
                latest.setSoldCount(dish.getSoldCount());
                dishMapper.updateById(latest);
            }
        }

        // 初始化库存流水（至少 5 条，体现入库/售出/人工调整）
        long logCount = inventoryLogMapper.selectCount(null);
        if (logCount < 5) {
            seedInventoryLogs(dishes);
        }
        log.info("演示订单初始化完成，本次新增 {} 笔（前缀 {}）", created, DEMO_PREFIX);
    }

    private void seedInventoryLogs(List<Dish> dishes) {
        LocalDateTime base = LocalDateTime.now().minusDays(7);
        int index = 0;
        for (Dish dish : dishes.subList(0, Math.min(6, dishes.size()))) {
            InventoryLog entry = new InventoryLog();
            entry.setDishId(dish.getId());
            int stock = dish.getStock() == null ? 0 : dish.getStock();
            int initial = stock + 10;
            entry.setChangeAmount(10);
            entry.setBeforeStock(stock);
            entry.setAfterStock(initial);
            entry.setReason(Constants.InventoryReason.DEMO_SEED + " 课堂演示初始入库");
            entry.setCreatedAt(base.plusHours(index));
            inventoryLogMapper.insert(entry);
            index++;
        }
    }

    private BigDecimal multiply(BigDecimal value, int quantity) {
        return value == null ? null
                : value.multiply(BigDecimal.valueOf(quantity)).setScale(2, RoundingMode.HALF_UP);
    }

    @SuppressWarnings("unused")
    private String formatNo(LocalDateTime time) {
        return time.format(NO_FORMAT);
    }
}
