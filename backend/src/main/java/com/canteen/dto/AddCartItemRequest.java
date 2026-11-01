package com.canteen.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddCartItemRequest {

    @NotNull(message = "请选择菜品")
    private Long dishId;

    @NotNull(message = "请输入数量")
    @Min(value = 1, message = "数量至少为 1")
    @Max(value = 99, message = "单道菜最多 99 份")
    private Integer quantity = 1;
}
