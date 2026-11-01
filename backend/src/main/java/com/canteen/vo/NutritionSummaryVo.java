package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * 当前用户营养摄入汇总。所有数值均基于订单菜品估算，明确标注为估算值。
 */
@Data
public class NutritionSummaryVo {
    private String period;
    private BigDecimal totalCalories = BigDecimal.ZERO;
    private BigDecimal totalProtein = BigDecimal.ZERO;
    private BigDecimal totalFat = BigDecimal.ZERO;
    private BigDecimal totalCarbohydrate = BigDecimal.ZERO;
    private BigDecimal totalFiber = BigDecimal.ZERO;
    private BigDecimal totalSodium = BigDecimal.ZERO;
    private BigDecimal vegetableGrams = BigDecimal.ZERO;
    private int orderCount;
    private int dishCount;
    /** 每日参考目标值（非用户真实身体指标） */
    private BigDecimal targetCalories = BigDecimal.valueOf(2000);
    private BigDecimal targetProtein = BigDecimal.valueOf(70);
    private BigDecimal targetWater = BigDecimal.valueOf(1500);
    /** 日均摄入（用于与每日目标对比，达成率口径清晰） */
    private BigDecimal dailyCalories = BigDecimal.ZERO;
    private BigDecimal dailyProtein = BigDecimal.ZERO;
    private BigDecimal calorieRate = BigDecimal.ZERO;
    private BigDecimal proteinRate = BigDecimal.ZERO;
    private BigDecimal waterRate = BigDecimal.ZERO;
    private BigDecimal waterMl = BigDecimal.valueOf(800);
    private List<String> suggestions;
    private String note;
    private List<NutritionTrendPointVo> trend;
}
