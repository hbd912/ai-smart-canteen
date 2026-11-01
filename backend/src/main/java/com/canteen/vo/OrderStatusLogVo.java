package com.canteen.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class OrderStatusLogVo {
    private Long id;
    private String fromStatus;
    private String toStatus;
    private String toStatusLabel;
    private String operatorType;
    private String remark;
    private LocalDateTime createdAt;
}
