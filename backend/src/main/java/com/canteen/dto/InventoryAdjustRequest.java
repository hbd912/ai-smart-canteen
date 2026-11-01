package com.canteen.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class InventoryAdjustRequest {

    @NotNull(message = "请选择菜品")
    private Long dishId;

    /** 正数入库，负数出库；与 targetStock 二选一 */
    private Integer changeAmount;

    /** 直接设置目标库存；与 changeAmount 二选一 */
    @Min(value = 0, message = "目标库存不能为负")
    private Integer targetStock;

    @NotBlank(message = "请填写调整原因")
    @Size(max = 200, message = "调整原因不能超过 200 个字符")
    private String reason;
}
