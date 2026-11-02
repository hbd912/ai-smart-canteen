package com.canteen.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 菜品评价 dish_review
 */
@Data
@TableName("dish_review")
public class DishReview {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long dishId;
    private Long userId;
    private Long orderId;
    /** 评分 1-5 星 */
    private Integer rating;
    /** 评价内容，可为空（只打分不写评语） */
    private String content;
    /** 是否匿名：1-是 0-否 */
    private Integer anonymous;
    /** PENDING / APPROVED / REJECTED */
    private String status;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
