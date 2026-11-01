package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class NutritionTrendPointVo {
    private String date;
    private BigDecimal calories = BigDecimal.ZERO;
    private BigDecimal protein = BigDecimal.ZERO;
    private BigDecimal fat = BigDecimal.ZERO;
    private BigDecimal carbohydrate = BigDecimal.ZERO;
    private int orderCount;
}
