package com.canteen.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/** 精选作品 */
@Data
@TableName("work")
public class Work {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;
    /** 关联菜品，点击作品可跳转点餐；可为空（纯图文作品） */
    private Long dishId;
    /** 关联历史订单，可为空；作品详情展示订单凭证 */
    private Long orderId;
    private String title;
    private String content;
    private String imagesJson;
    private Integer likeCount;
    private Integer commentCount;
    private String status;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
