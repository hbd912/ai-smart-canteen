package com.canteen.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreateOrderRequest {

    @Size(max = 255, message = "备注不能超过 255 个字符")
    private String remark;

    /** 幂等标识，防止重复点击结算生成重复订单 */
    @Size(max = 64, message = "幂等标识过长")
    private String idempotencyKey;
}
