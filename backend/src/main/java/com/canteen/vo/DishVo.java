package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class DishVo {
    private Long id;
    private Long categoryId;
    private String categoryName;
    private String categoryCode;
    private String dishCode;
    private String name;
    private String description;
    private List<String> ingredients;
    private List<String> allergens;
    private String imageUrl;
    private BigDecimal price;
    private BigDecimal calories;
    private BigDecimal proteinG;
    private BigDecimal fatG;
    private BigDecimal carbohydrateG;
    private BigDecimal fiberG;
    private BigDecimal sodiumMg;
    private String nutritionSource;
    private String nutritionNote;
    private Integer stock;
    private Integer dailyLimit;
    private Integer soldCount;
    private String supplyStatus;
    private String publishStatus;
    private Boolean recommendFlag;
    private Integer recommendRank;
    private List<String> tags;
    private Integer sortOrder;
    /** 平均评分 0.0~5.0 */
    private BigDecimal avgRating;
    /** 评价数量 */
    private Integer reviewCount;
    /** 好评率（4-5 星占比，百分比） */
    private BigDecimal goodRate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /** 前台展示用派生字段 */
    private Boolean available;
    private Boolean favorited;
    private String availabilityText;
    private String recommendationBadge;
    private Integer recommendationSort;
}
