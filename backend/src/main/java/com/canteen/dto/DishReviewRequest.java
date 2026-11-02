package com.canteen.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class DishReviewRequest {

    @NotNull(message = "请选择菜品")
    private Long dishId;

    @NotNull(message = "请选择评分")
    @Min(value = 1, message = "评分最低 1 星")
    @Max(value = 5, message = "评分最高 5 星")
    private Integer rating;

    @Size(max = 500, message = "评价内容不能超过 500 字")
    private String content;

    private Boolean anonymous;

    /** 可选：关联订单 */
    private Long orderId;
}
