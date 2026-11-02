package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.canteen.entity.Dish;
import com.canteen.entity.DishCategory;
import com.canteen.entity.Order;
import com.canteen.entity.OrderItem;
import com.canteen.mapper.DishCategoryMapper;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.OrderItemMapper;
import com.canteen.mapper.OrderMapper;
import com.canteen.vo.NutritionAdviceVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 营养 AI 建议。
 *
 * 逻辑：
 * 1. 取最近 N 天已完成订单，聚合蛋白质、纤维、热量、蔬菜情况；
 * 2. 与参考目标对比，找出「明显不足」的项（达标率 < 60%）；
 * 3. 从在售菜品中挑出最能补对应缺口的，按匹配度排序；
 * 4. 用自然语言生成推荐理由（AI 助手语气）。
 *
 * 说明：这是规则驱动的「AI 建议」演示，不调用外部大模型；
 * 数值均基于菜品估算数据，非医学检测结果。
 */
@Service
@RequiredArgsConstructor
public class NutritionAdviceService {

    /** 每日参考目标 */
    private static final BigDecimal TARGET_PROTEIN = BigDecimal.valueOf(70);
    private static final BigDecimal TARGET_FIBER = BigDecimal.valueOf(25);
    private static final BigDecimal TARGET_CALORIES = BigDecimal.valueOf(2000);
    /** 判定「不足」的阈值：达标率低于 60% */
    private static final BigDecimal LOW_THRESHOLD = BigDecimal.valueOf(60);

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final DishMapper dishMapper;
    private final DishCategoryMapper categoryMapper;

    public NutritionAdviceVo advice(Long userId, int days) {
        int span = Math.max(days, 1);
        LocalDateTime since = LocalDateTime.now().minusDays(span);

        List<Order> orders = orderMapper.selectList(new LambdaQueryWrapper<Order>()
                .eq(Order::getUserId, userId)
                .ge(Order::getCreatedAt, since)
                .ne(Order::getOrderStatus, "CANCELLED"));
        List<Long> orderIds = orders.stream().map(Order::getId).toList();

        List<OrderItem> items = orderIds.isEmpty() ? List.of()
                : orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                .in(OrderItem::getOrderId, orderIds));

        // 聚合
        BigDecimal totalProtein = BigDecimal.ZERO;
        BigDecimal totalFiber = BigDecimal.ZERO;
        BigDecimal totalCalories = BigDecimal.ZERO;
        for (OrderItem it : items) {
            BigDecimal qty = BigDecimal.valueOf(it.getQuantity() == null ? 1 : it.getQuantity());
            totalProtein = totalProtein.add(nz(it.getProteinSnapshot()).multiply(qty));
            totalFiber = totalFiber.add(nz(it.getCarbohydrateSnapshot()).multiply(BigDecimal.ZERO));
            totalCalories = totalCalories.add(nz(it.getCaloriesSnapshot()).multiply(qty));
        }
        // 纤维没有快照字段，改用当前菜品营养值估算
        if (!items.isEmpty()) {
            List<Long> dishIds = items.stream().map(OrderItem::getDishId)
                    .filter(java.util.Objects::nonNull).distinct().toList();
            if (!dishIds.isEmpty()) {
                Map<Long, Dish> dishMap = dishMapper.selectBatchIds(dishIds).stream()
                        .collect(Collectors.toMap(Dish::getId, d -> d, (a, b) -> a));
                for (OrderItem it : items) {
                    Dish d = dishMap.get(it.getDishId());
                    if (d == null) {
                        continue;
                    }
                    BigDecimal qty = BigDecimal.valueOf(it.getQuantity() == null ? 1 : it.getQuantity());
                    totalFiber = totalFiber.add(nz(d.getFiberG()).multiply(qty));
                }
            }
        }

        BigDecimal dailyProtein = totalProtein.divide(BigDecimal.valueOf(span), 1, RoundingMode.HALF_UP);
        BigDecimal dailyFiber = totalFiber.divide(BigDecimal.valueOf(span), 1, RoundingMode.HALF_UP);
        BigDecimal dailyCalories = totalCalories.divide(BigDecimal.valueOf(span), 1, RoundingMode.HALF_UP);

        BigDecimal proteinRate = rate(dailyProtein, TARGET_PROTEIN);
        BigDecimal fiberRate = rate(dailyFiber, TARGET_FIBER);
        BigDecimal calorieRate = rate(dailyCalories, TARGET_CALORIES);

        List<NutritionAdviceVo.Gap> gaps = new ArrayList<>();
        gaps.add(buildGap("protein", "蛋白质", dailyProtein, TARGET_PROTEIN, proteinRate,
                proteinRate.compareTo(LOW_THRESHOLD) < 0,
                "蛋白质摄入偏少，容易饿得快、也影响肌肉恢复"));
        gaps.add(buildGap("fiber", "膳食纤维", dailyFiber, TARGET_FIBER, fiberRate,
                fiberRate.compareTo(LOW_THRESHOLD) < 0,
                "膳食纤维不足，建议加点绿叶蔬菜或粗粮"));
        gaps.add(buildGap("calorie", "热量", dailyCalories, TARGET_CALORIES, calorieRate,
                calorieRate.compareTo(LOW_THRESHOLD) < 0,
                "总热量偏低，可能影响下午的精力"));

        // 找出需要补的缺口（按缺失程度排序）
        List<NutritionAdviceVo.Gap> weak = gaps.stream()
                .filter(g -> g.getStatus().equals("LOW"))
                .sorted(Comparator.comparing(NutritionAdviceVo.Gap::getRate))
                .toList();

        List<NutritionAdviceVo.Recommendation> recs = recommend(weak, span);

        NutritionAdviceVo vo = new NutritionAdviceVo();
        vo.setGaps(gaps);
        vo.setRecommendations(recs);
        vo.setHeadline(buildHeadline(weak, recs, span, items.size()));
        vo.setNote("以上基于你已经结算的订单与菜品估算营养值分析，为课堂演示数据，不是医学建议。");
        return vo;
    }

    // ---------------------------------------------------------------
    // 推荐逻辑
    // ---------------------------------------------------------------

    private List<NutritionAdviceVo.Recommendation> recommend(List<NutritionAdviceVo.Gap> weak, int span) {
        List<Dish> dishes = dishMapper.selectList(new LambdaQueryWrapper<Dish>()
                .eq(Dish::getPublishStatus, "PUBLISHED")
                .eq(Dish::getSupplyStatus, "AVAILABLE"));
        if (dishes.isEmpty()) {
            return List.of();
        }
        Map<Long, DishCategory> cats = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(DishCategory::getId, c -> c, (a, b) -> a));

        List<NutritionAdviceVo.Recommendation> out = new ArrayList<>();
        for (Dish d : dishes) {
            if (d.getStock() != null && d.getStock() <= 0) {
                continue;
            }
            BigDecimal score = BigDecimal.ZERO;
            List<String> benefits = new ArrayList<>();
            StringBuilder reason = new StringBuilder();

            for (NutritionAdviceVo.Gap g : weak) {
                switch (g.getKey()) {
                    case "protein" -> {
                        BigDecimal p = nz(d.getProteinG());
                        if (p.compareTo(BigDecimal.valueOf(15)) >= 0) {
                            score = score.add(p.multiply(BigDecimal.valueOf(2)));
                            benefits.add("+" + p.setScale(0, RoundingMode.HALF_UP) + "g 蛋白质");
                        }
                    }
                    case "fiber" -> {
                        BigDecimal f = nz(d.getFiberG());
                        if (f.compareTo(BigDecimal.valueOf(2)) >= 0) {
                            score = score.add(f.multiply(BigDecimal.valueOf(12)));
                            benefits.add("+" + f.setScale(1, RoundingMode.HALF_UP) + "g 膳食纤维");
                        }
                    }
                    case "calorie" -> {
                        BigDecimal cal = nz(d.getCalories());
                        if (cal.compareTo(BigDecimal.valueOf(300)) >= 0) {
                            score = score.add(cal.divide(BigDecimal.TEN, 1, RoundingMode.HALF_UP));
                            benefits.add(Math.round(cal.doubleValue()) + " kcal");
                        }
                    }
                    default -> {
                    }
                }
            }

            if (score.compareTo(BigDecimal.ZERO) <= 0) {
                continue;
            }

            // 如果有蛋白质缺口，优先高蛋白低脂
            boolean needProtein = weak.stream().anyMatch(g -> g.getKey().equals("protein"));
            if (needProtein && nz(d.getFatG()).compareTo(BigDecimal.valueOf(15)) < 0) {
                score = score.add(BigDecimal.valueOf(8));
            }
            // 有销量加成（大众认可度）
            if (d.getSoldCount() != null && d.getSoldCount() > 0) {
                score = score.add(BigDecimal.valueOf(Math.min(d.getSoldCount() / 5, 10)));
            }
            // 高评分加成
            if (d.getAvgRating() != null) {
                score = score.add(d.getAvgRating());
            }

            reason.append("你今天");
            if (needProtein) {
                reason.append("蛋白质还没吃够，");
            }
            reason.append("这道菜能补上 ").append(String.join("、", benefits));
            reason.append("，下一餐吃它会更均衡哦。");

            NutritionAdviceVo.Recommendation r = new NutritionAdviceVo.Recommendation();
            r.setDishId(d.getId());
            r.setDishName(d.getName());
            r.setImageUrl(d.getImageUrl());
            r.setPrice(d.getPrice());
            r.setCalories(d.getCalories());
            r.setProteinG(d.getProteinG());
            r.setFiberG(d.getFiberG());
            r.setBenefit(String.join(" · ", benefits));
            r.setReason(reason.toString());
            r.setScore(score.setScale(1, RoundingMode.HALF_UP));
            DishCategory c = cats.get(d.getCategoryId());
            r.setCategoryName(c == null ? null : c.getName());
            out.add(r);
        }

        return out.stream()
                .sorted(Comparator.comparing(NutritionAdviceVo.Recommendation::getScore).reversed())
                .limit(4)
                .toList();
    }

    private String buildHeadline(List<NutritionAdviceVo.Gap> weak, List<NutritionAdviceVo.Recommendation> recs,
                                 int span, int itemCount) {
        if (itemCount == 0) {
            return "最近 " + span + " 天还没有用餐记录，先点一餐吧，我会根据你的营养情况给建议。";
        }
        if (weak.isEmpty()) {
            return "最近 " + span + " 天营养摄入比较均衡，继续保持这个节奏就很棒！";
        }
        String first = weak.get(0).getLabel();
        if (recs.isEmpty()) {
            return "你最近 " + first + " 摄入偏少，建议下一餐注意补充。";
        }
        return "你最近 " + first + " 摄入偏少，试试下面这道「" + recs.get(0).getDishName() + "」，能帮你补上缺口。";
    }

    private NutritionAdviceVo.Gap buildGap(String key, String label, BigDecimal current,
                                           BigDecimal target, BigDecimal rate,
                                           boolean low, String message) {
        NutritionAdviceVo.Gap g = new NutritionAdviceVo.Gap();
        g.setKey(key);
        g.setLabel(label);
        g.setCurrent(current);
        g.setTarget(target);
        g.setRate(rate);
        g.setStatus(low ? "LOW" : (rate.compareTo(BigDecimal.valueOf(120)) > 0 ? "HIGH" : "OK"));
        g.setMessage(low ? message : "摄入情况良好");
        return g;
    }

    private BigDecimal rate(BigDecimal current, BigDecimal target) {
        if (target.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        return current.multiply(BigDecimal.valueOf(100))
                .divide(target, 1, RoundingMode.HALF_UP);
    }

    private BigDecimal nz(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}
