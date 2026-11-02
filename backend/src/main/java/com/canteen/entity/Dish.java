package com.canteen.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 菜品 dish。JSON 字段以字符串形式读写，由 Service 层用 Jackson 解析。
 */
@Data
@TableName("dish")
public class Dish {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long categoryId;
    private String dishCode;
    private String name;
    private String description;
    private String ingredientsJson;
    private String allergensJson;
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
    private Integer recommendFlag;
    private Integer recommendRank;
    private String tagsJson;
    private Integer sortOrder;
    private Long createdBy;

    /** 平均评分 0.0~5.0（由 dish_review 聚合而来，冗余存储） */
    private BigDecimal avgRating;
    /** 评价数量 */
    private Integer reviewCount;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    private Integer deleted;
}
