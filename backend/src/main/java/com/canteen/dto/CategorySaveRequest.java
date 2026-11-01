package com.canteen.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CategorySaveRequest {

    @NotBlank(message = "请输入分类名称")
    @Size(max = 50, message = "分类名称不能超过 50 个字符")
    private String name;

    @Size(max = 30, message = "分类编码不能超过 30 个字符")
    private String code;

    @Size(max = 100, message = "图标名不能超过 100 个字符")
    private String icon;

    @Size(max = 500, message = "封面图地址过长")
    private String coverImage;

    private Integer sortOrder = 0;

    /** ACTIVE / INACTIVE */
    private String status = "ACTIVE";
}
