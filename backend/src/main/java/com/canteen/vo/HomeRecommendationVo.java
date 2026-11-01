package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class HomeRecommendationVo {
    private Long id;
    private Long dishId;
    private String title;
    private String badgeText;
    private Integer sortOrder;
    private Boolean enabled;
    private DishVo dish;
}
