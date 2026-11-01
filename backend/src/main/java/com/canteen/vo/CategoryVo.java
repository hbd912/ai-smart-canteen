package com.canteen.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CategoryVo {
    private Long id;
    private String name;
    private String code;
    private String icon;
    private String coverImage;
    private Integer sortOrder;
    private String status;
    private LocalDateTime createdAt;
    private long dishCount;
}
