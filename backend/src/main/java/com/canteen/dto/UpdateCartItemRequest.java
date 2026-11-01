package com.canteen.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UpdateCartItemRequest {

    /** 0 表示移除该商品 */
    @NotNull(message = "请输入数量")
    @Min(value = 0, message = "数量不能为负数")
    @Max(value = 99, message = "单道菜最多 99 份")
    private Integer quantity;
}
