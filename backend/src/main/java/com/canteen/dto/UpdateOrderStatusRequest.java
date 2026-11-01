package com.canteen.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateOrderStatusRequest {

    @NotBlank(message = "请选择目标状态")
    private String status;

    @Size(max = 255, message = "备注不能超过 255 个字符")
    private String remark;
}
