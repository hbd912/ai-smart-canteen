package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class OrderVo {
    private Long id;
    private String orderNo;
    private Long userId;
    private String userNickname;
    private String userAccount;
    private BigDecimal totalAmount;
    private BigDecimal totalCalories;
    private String orderStatus;
    private String orderStatusLabel;
    private String paymentStatus;
    private String paymentStatusLabel;
    private String remark;
    private Integer itemCount;
    private Integer totalQuantity;
    private List<OrderItemVo> items;
    private List<OrderStatusLogVo> statusLogs;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime completedAt;
    /** 是否为课堂演示订单（DEMO- 前缀） */
    private Boolean demo;
}
