package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.dto.RecommendationSaveRequest;
import com.canteen.service.RecommendationService;
import com.canteen.vo.HomeRecommendationVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "15. 后台-首页推荐管理", description = "首页推荐菜品、标签与排序")
@RestController
@RequestMapping("/api/v1/admin/recommendations")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminRecommendationController {

    private final RecommendationService recommendationService;

    @Operation(summary = "后台推荐配置列表")
    @GetMapping
    public ApiResponse<List<HomeRecommendationVo>> list() {
        return ApiResponse.ok(recommendationService.listForAdmin());
    }

    @Operation(summary = "保存推荐配置（全量替换）")
    @PutMapping
    public ApiResponse<Void> save(@Valid @RequestBody RecommendationSaveRequest request) {
        recommendationService.save(request);
        return ApiResponse.ok("推荐配置已保存，前台首页将同步更新", null);
    }

    @Operation(summary = "移除单个推荐")
    @DeleteMapping("/{dishId}")
    public ApiResponse<Void> remove(@PathVariable Long dishId) {
        recommendationService.remove(dishId);
        return ApiResponse.ok("已移除推荐", null);
    }
}
