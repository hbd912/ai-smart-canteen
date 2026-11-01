package com.canteen.vo;

import lombok.Data;

import java.util.List;

@Data
public class HomeContentVo {
    private List<HomeRecommendationVo> recommendations;
    private List<DishVo> featuredDishes;
    private List<CategoryVo> categories;
    private List<String> quickTags;
    private String aiMode;
    private boolean aiConfigured;
}
