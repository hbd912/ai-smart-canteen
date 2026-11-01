package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.security.SecurityUtils;
import com.canteen.service.FavoriteService;
import com.canteen.vo.DishVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@Tag(name = "05. 收藏", description = "菜品收藏与取消收藏")
@RestController
@RequestMapping("/api/v1/favorites")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;

    @Operation(summary = "当前用户收藏列表")
    @GetMapping
    public ApiResponse<List<DishVo>> list() {
        return ApiResponse.ok(favoriteService.list(SecurityUtils.currentUserId()));
    }

    @Operation(summary = "收藏菜品")
    @PostMapping("/{dishId}")
    public ApiResponse<Void> add(@PathVariable Long dishId) {
        favoriteService.add(SecurityUtils.currentUserId(), dishId);
        return ApiResponse.ok("已加入收藏", null);
    }

    @Operation(summary = "取消收藏")
    @DeleteMapping("/{dishId}")
    public ApiResponse<Void> remove(@PathVariable Long dishId) {
        favoriteService.remove(SecurityUtils.currentUserId(), dishId);
        return ApiResponse.ok("已取消收藏", null);
    }

    @Operation(summary = "切换收藏状态")
    @PostMapping("/{dishId}/toggle")
    public ApiResponse<Map<String, Boolean>> toggle(@PathVariable Long dishId) {
        boolean favorited = favoriteService.toggle(SecurityUtils.currentUserId(), dishId);
        return ApiResponse.ok(favorited ? "已加入收藏" : "已取消收藏", Map.of("favorited", favorited));
    }
}
