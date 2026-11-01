package com.canteen.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class RecommendationSaveRequest {

    @NotNull(message = "推荐列表不能为空")
    @Valid
    private List<Item> items;

    @Data
    public static class Item {
        @NotNull(message = "菜品 ID 不能为空")
        private Long dishId;

        private String title;
        private String badgeText;

        @Min(value = 0, message = "排序值不能为负")
        private Integer sortOrder;

        private Boolean enabled = Boolean.TRUE;
    }
}
