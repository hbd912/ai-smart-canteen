package com.canteen.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 首页推荐 home_recommendation
 */
@Data
@TableName("home_recommendation")
public class HomeRecommendation {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long dishId;
    private String title;
    private String badgeText;
    private Integer sortOrder;
    private Integer enabled;
    private LocalDateTime startAt;
    private LocalDateTime endAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
