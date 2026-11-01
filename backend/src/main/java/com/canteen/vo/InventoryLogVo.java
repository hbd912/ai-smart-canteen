package com.canteen.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class InventoryLogVo {
    private Long id;
    private Long dishId;
    private String dishName;
    private Integer changeAmount;
    private Integer beforeStock;
    private Integer afterStock;
    private String reason;
    private Long operatorAdminId;
    private String operatorName;
    private Long relatedOrderId;
    private LocalDateTime createdAt;
}
