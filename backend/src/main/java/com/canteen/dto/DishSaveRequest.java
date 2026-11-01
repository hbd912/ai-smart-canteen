package com.canteen.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class DishSaveRequest {

    @NotBlank(message = "请输入菜品名称")
    @Size(max = 100, message = "菜品名称不能超过 100 个字符")
    private String name;

    @NotNull(message = "请选择菜品分类")
    private Long categoryId;

    @Size(max = 40, message = "菜品编码不能超过 40 个字符")
    private String dishCode;

    @Size(max = 500, message = "简介不能超过 500 个字符")
    private String description;

    private List<String> ingredients;
    private List<String> allergens;
    private List<String> tags;

    @Size(max = 500, message = "图片地址过长")
    private String imageUrl;

    @NotNull(message = "请输入售价")
    @DecimalMin(value = "0.00", message = "售价不能为负数")
    @DecimalMax(value = "9999.99", message = "售价超出合理范围")
    private BigDecimal price;

    @DecimalMin(value = "0.00", message = "热量不能为负数")
    private BigDecimal calories;

    @DecimalMin(value = "0.00", message = "蛋白质不能为负数")
    private BigDecimal proteinG;

    @DecimalMin(value = "0.00", message = "脂肪不能为负数")
    private BigDecimal fatG;

    @DecimalMin(value = "0.00", message = "碳水不能为负数")
    private BigDecimal carbohydrateG;

    @DecimalMin(value = "0.00", message = "膳食纤维不能为负数")
    private BigDecimal fiberG;

    @DecimalMin(value = "0.00", message = "钠不能为负数")
    private BigDecimal sodiumMg;

    /** ESTIMATED / LABEL / TESTED */
    private String nutritionSource = "ESTIMATED";

    @Size(max = 255, message = "营养说明不能超过 255 个字符")
    private String nutritionNote;

    @NotNull(message = "请输入库存")
    @Min(value = 0, message = "库存必须是非负整数")
    private Integer stock;

    @Min(value = 0, message = "每日供应量必须是非负整数")
    private Integer dailyLimit;

    /** DRAFT / PUBLISHED / UNPUBLISHED */
    private String publishStatus = "DRAFT";

    /** AVAILABLE / SOLD_OUT / PAUSED */
    private String supplyStatus = "AVAILABLE";

    private Boolean recommendFlag = Boolean.FALSE;
    private Integer recommendRank = 0;
    private Integer sortOrder = 0;
    private Boolean homeRecommendation = Boolean.FALSE;
    private String recommendationBadge;
}
