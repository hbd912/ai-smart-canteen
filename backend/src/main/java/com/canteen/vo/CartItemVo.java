package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class CartItemVo {
    private Long id;
    private Long dishId;
    private String dishName;
    private String imageUrl;
    private Integer quantity;
    /** 当前数据库价格（仅用于展示，结算仍由后端重新计算） */
    private BigDecimal unitPrice;
    private BigDecimal subtotal;
    private BigDecimal calories;
    private BigDecimal subtotalCalories;
    private Boolean available;
    private String unavailableReason;
    private Integer stock;
    private String supplyStatus;
    private String publishStatus;
}
