package com.canteen.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class InventoryItemVo {
    private Long dishId;
    private String dishCode;
    private String name;
    private String imageUrl;
    private String categoryName;
    private Integer stock;
    private Integer dailyLimit;
    private Integer soldCount;
    private Integer remaining;
    private String supplyStatus;
    private String publishStatus;
    private Boolean lowStock;
    private Boolean soldOut;
    private LocalDateTime updatedAt;
}
