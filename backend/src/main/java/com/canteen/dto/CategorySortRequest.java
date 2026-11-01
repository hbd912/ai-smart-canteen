package com.canteen.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class CategorySortRequest {

    @NotEmpty(message = "排序列表不能为空")
    @Valid
    private List<Item> items;

    @Data
    public static class Item {
        @NotNull(message = "分类 ID 不能为空")
        private Long id;

        @NotNull(message = "排序值不能为空")
        @Min(value = 0, message = "排序值不能为负")
        private Integer sortOrder;
    }
}
