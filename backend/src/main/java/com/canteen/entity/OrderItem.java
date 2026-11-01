package com.canteen.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单明细快照 order_item。历史订单只读取这里的快照字段，绝不 join 当前 dish 数据。
 */
@Data
@TableName("order_item")
public class OrderItem {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;
    private Long dishId;
    private String dishNameSnapshot;
    private String imageUrlSnapshot;
    private BigDecimal unitPriceSnapshot;
    private Integer quantity;
    private BigDecimal subtotal;
    private BigDecimal caloriesSnapshot;
    private BigDecimal proteinSnapshot;
    private BigDecimal fatSnapshot;
    private BigDecimal carbohydrateSnapshot;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
