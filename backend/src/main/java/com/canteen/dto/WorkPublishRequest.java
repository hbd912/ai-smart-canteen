package com.canteen.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

/**
 * 发布精选作品请求。
 *
 * <p>图片与文字必填；菜品与订单可选，若关联订单则后端会校验订单归属，
 * 并根据订单明细补全菜品或校验菜品确实在该订单中。</p>
 */
@Data
public class WorkPublishRequest {

    @Size(max = 100, message = "标题不能超过 100 字")
    private String title;

    @NotBlank(message = "请填写文字描述")
    @Size(max = 1000, message = "文字描述不能超过 1000 字")
    private String content;

    /** 可选：关联菜品 */
    private Long dishId;

    /** 可选：关联历史订单 */
    private Long orderId;

    @NotEmpty(message = "请至少上传一张图片")
    @Size(max = 9, message = "最多上传 9 张图片")
    private List<@NotBlank(message = "图片地址不能为空") String> images;
}
