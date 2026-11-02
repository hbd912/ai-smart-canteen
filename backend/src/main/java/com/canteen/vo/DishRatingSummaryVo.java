package com.canteen.vo;

import lombok.Data;

import java.util.List;

/**
 * 菜品评分汇总：平均分、评价数、各星级分布、好评率
 */
@Data
public class DishRatingSummaryVo {
    private Long dishId;
    private Double avgRating;
    private Integer reviewCount;
    /** 5 星数量 */
    private Integer star5;
    private Integer star4;
    private Integer star3;
    private Integer star2;
    private Integer star1;
    /** 好评率（4-5 星占比，百分比，保留 1 位小数） */
    private Double goodRate;
    /** 当前用户是否已评价过 */
    private Boolean reviewed;
    private List<DishReviewVo> recentReviews;
}
