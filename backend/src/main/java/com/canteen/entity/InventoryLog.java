package com.canteen.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 库存调整流水 inventory_log
 */
@Data
@TableName("inventory_log")
public class InventoryLog {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long dishId;
    private Integer changeAmount;
    private Integer beforeStock;
    private Integer afterStock;
    private String reason;
    private Long operatorAdminId;
    private Long relatedOrderId;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
