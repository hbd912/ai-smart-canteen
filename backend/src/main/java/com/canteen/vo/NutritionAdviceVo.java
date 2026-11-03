package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * 营养 AI 建议：分析最近订单的营养缺口，推荐能补齐缺口的真实菜品。
 *
 * 示例文案：
 * 「你最近一直在吃主食类，蛋白质摄入偏少。试试这道香煎鸡胸，能补充 38g 蛋白质，
 *   下一餐吃这个会更好哦。」
 */
@Data
public class NutritionAdviceVo {

    /** 一句话总评（AI 风格） */
    private String headline;

    /** 缺口分析明细 */
    private List<Gap> gaps;

    /** 推荐菜品 */
    private List<Recommendation> recommendations;

    /** 补充说明（估算值声明） */
    private String note;

    /** 文案生成方式：LLM（大模型）/ RULE（规则兜底） */
    private String mode;

    /** 前端展示的模式标签，如「大模型分析」 */
    private String modeLabel;

    @Data
    public static class Gap {
        /** protein / fiber / calorie / vegetable / water */
        private String key;
        private String label;
        /** 当前日均值 */
        private BigDecimal current;
        /** 参考目标值 */
        private BigDecimal target;
        /** 达标率（百分比） */
        private BigDecimal rate;
        /** 状态：LOW（不足）/ OK（达标）/ HIGH（偏高） */
        private String status;
        /** 缺口描述 */
        private String message;
    }

    @Data
    public static class Recommendation {
        private Long dishId;
        private String dishName;
        private String imageUrl;
        private BigDecimal price;
        private BigDecimal calories;
        private BigDecimal proteinG;
        private BigDecimal fiberG;
        /** 这道菜能补上的营养点，如「+38g 蛋白质」 */
        private String benefit;
        /** 推荐理由（AI 语气） */
        private String reason;
        /** 匹配度得分，用于排序 */
        private BigDecimal score;
        /** 分类名 */
        private String categoryName;
    }
}
