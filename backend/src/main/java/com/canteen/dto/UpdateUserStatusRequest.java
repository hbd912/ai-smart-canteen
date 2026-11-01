package com.canteen.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdateUserStatusRequest {

    /** ACTIVE / DISABLED */
    @NotBlank(message = "请选择用户状态")
    private String status;
}
