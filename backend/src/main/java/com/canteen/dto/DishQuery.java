package com.canteen.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 菜品查询条件（前台/后台共用，后台额外可查 DRAFT/UNPUBLISHED）。
 */
@Data
public class DishQuery {

    private long page = 1;
    private long pageSize = 12;
    private Long categoryId;
    private String categoryCode;
    private String keyword;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private BigDecimal minCalories;
    private BigDecimal maxCalories;
    /** 后台使用：DRAFT / PUBLISHED / UNPUBLISHED，前台忽略并强制 PUBLISHED */
    private String publishStatus;
    /** 后台使用：AVAILABLE / SOLD_OUT / PAUSED */
    private String supplyStatus;
    /** sales_desc | price_asc | price_desc | calories_asc | calories_desc | created_desc | stock_asc */
    private String sort = "sales_desc";
    private Boolean recommendOnly;
}
