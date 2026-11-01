package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class AiRecommendVo {
    /** LLM 或 RULE_DEMO */
    private String mode;
    private String modeLabel;
    private String reply;
    private List<AiDishSuggestionVo> dishes;
    private List<String> tips;
    private Long conversationId;
    private long elapsedMs;

    @Data
    public static class AiDishSuggestionVo {
        private Long dishId;
        private String name;
        private String imageUrl;
        private BigDecimal price;
        private BigDecimal calories;
        private String categoryName;
        private String reason;
        private List<String> tags;
    }
}
