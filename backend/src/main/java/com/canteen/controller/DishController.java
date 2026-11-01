package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.common.PageResult;
import com.canteen.dto.DishQuery;
import com.canteen.security.SecurityUtils;
import com.canteen.service.DishService;
import com.canteen.vo.CategoryVo;
import com.canteen.vo.DishVo;
import com.canteen.vo.HomeContentVo;
import com.canteen.vo.HomeRecommendationVo;
import com.canteen.service.CategoryService;
import com.canteen.service.RecommendationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "02. 前台菜品与分类", description = "用户端菜单、分类、首页推荐（仅展示已上架数据）")
@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class DishController {

    private final DishService dishService;
    private final CategoryService categoryService;
    private final RecommendationService recommendationService;

    @Operation(summary = "前台菜品列表（分页、筛选、排序）")
    @GetMapping("/dishes")
    public ApiResponse<PageResult<DishVo>> list(DishQuery query) {
        Long userId = optionalUserId();
        return ApiResponse.ok(dishService.listForCustomer(query, userId));
    }

    @Operation(summary = "前台菜品详情")
    @GetMapping("/dishes/{id}")
    public ApiResponse<DishVo> detail(@PathVariable Long id) {
        return ApiResponse.ok(dishService.getForCustomer(id, optionalUserId()));
    }

    @Operation(summary = "前台启用分类")
    @GetMapping("/categories")
    public ApiResponse<List<CategoryVo>> categories() {
        return ApiResponse.ok(categoryService.listForCustomer());
    }

    @Operation(summary = "首页推荐菜品")
    @GetMapping("/recommendations/home")
    public ApiResponse<List<HomeRecommendationVo>> homeRecommendations() {
        return ApiResponse.ok(recommendationService.listForCustomer(optionalUserId()));
    }

    @Operation(summary = "首页聚合内容（推荐 + 分类 + 快捷标签）")
    @GetMapping("/home/content")
    public ApiResponse<HomeContentVo> homeContent() {
        HomeContentVo vo = new HomeContentVo();
        Long userId = optionalUserId();
        vo.setRecommendations(recommendationService.listForCustomer(userId));
        vo.setCategories(categoryService.listForCustomer());
        vo.setQuickTags(List.of("减脂轻食", "增加蛋白", "清淡健康", "快速饱腹"));
        return ApiResponse.ok(vo);
    }

    private Long optionalUserId() {
        try {
            return SecurityUtils.currentUserId();
        } catch (RuntimeException ex) {
            return null;
        }
    }
}
