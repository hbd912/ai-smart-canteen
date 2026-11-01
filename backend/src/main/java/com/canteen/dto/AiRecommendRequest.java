package com.canteen.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class AiRecommendRequest {

    @NotBlank(message = "请输入你的用餐需求")
    @Size(max = 300, message = "描述请控制在 300 字以内")
    private String message;

    private Long conversationId;

    /** 可选：预算上限（元），用于规则降级与 Prompt 约束 */
    private BigDecimal budgetMax;
}
