package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class RankingVo {
    private List<Item> items;

    @Data
    public static class Item {
        private Long dishId;
        private String name;
        private String imageUrl;
        private String categoryName;
        private long quantity;
        private BigDecimal amount = BigDecimal.ZERO;
        private BigDecimal share = BigDecimal.ZERO;
    }
}
