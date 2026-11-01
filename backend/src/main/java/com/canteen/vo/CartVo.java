package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class CartVo {
    private Long cartId;
    private List<CartItemVo> items;
    private int totalQuantity;
    private int dishCount;
    private BigDecimal totalAmount = BigDecimal.ZERO;
    private BigDecimal totalCalories = BigDecimal.ZERO;
    private List<String> warnings;
    private Boolean hasUnavailable;
}
