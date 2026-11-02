package com.canteen.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 菜品评价（前端展示用）
 */
@Data
public class DishReviewVo {
    private Long id;
    private Long dishId;
    private String dishName;
    private Long userId;
    /** 匿名或用户已注销时显示「匿名同学」 */
    private String authorNickname;
    private String authorInitial;
    /** 1-5 星 */
    private Integer rating;
    private String content;
    private Boolean anonymous;
    private LocalDateTime createdAt;
}
