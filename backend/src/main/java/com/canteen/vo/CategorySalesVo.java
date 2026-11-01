package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class CategorySalesVo {
    private long totalQuantity;
    private BigDecimal totalAmount = BigDecimal.ZERO;
    private List<Item> items;

    @Data
    public static class Item {
        private Long categoryId;
        private String categoryName;
        private long quantity;
        private BigDecimal amount = BigDecimal.ZERO;
        private BigDecimal share = BigDecimal.ZERO;
    }
}
