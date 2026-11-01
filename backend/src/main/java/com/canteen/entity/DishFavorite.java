package com.canteen.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 菜品收藏 dish_favorite
 */
@Data
@TableName("dish_favorite")
public class DishFavorite {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;
    private Long dishId;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
