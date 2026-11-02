package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class WorkVo {
    private Long id;
    private Long userId;
    private String authorNickname;
    private String authorInitial;
    private Long dishId;
    private String dishName;
    private BigDecimal dishPrice;
    /** 关联的历史订单（发布时选择，可为空） */
    private Long orderId;
    private String orderNo;
    private LocalDateTime orderCreatedAt;
    private BigDecimal orderTotalAmount;
    private String title;
    private String content;
    private List<String> images;
    private Integer likeCount;
    private Integer commentCount;
    private Boolean liked;
    private String status;
    private List<WorkCommentVo> comments;
    private LocalDateTime createdAt;
}
