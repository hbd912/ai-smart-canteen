package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.common.PageResult;
import com.canteen.dto.DishQuery;
import com.canteen.dto.DishSaveRequest;
import com.canteen.service.DishService;
import com.canteen.vo.DishVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@Tag(name = "10. 后台-菜品管理", description = "菜品增删改查、上下架（需管理员权限）")
@RestController
@RequestMapping("/api/v1/admin/dishes")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminDishController {

    private final DishService dishService;

    @Operation(summary = "后台菜品分页查询")
    @GetMapping
    public ApiResponse<PageResult<DishVo>> list(DishQuery query) {
        return ApiResponse.ok(dishService.listForAdmin(query));
    }

    @Operation(summary = "后台菜品详情")
    @GetMapping("/{id}")
    public ApiResponse<DishVo> detail(@PathVariable Long id) {
        return ApiResponse.ok(dishService.getForAdmin(id));
    }

    @Operation(summary = "新增菜品")
    @PostMapping
    public ApiResponse<DishVo> create(@Valid @RequestBody DishSaveRequest request) {
        return ApiResponse.ok("菜品已创建", dishService.create(request));
    }

    @Operation(summary = "编辑菜品")
    @PutMapping("/{id}")
    public ApiResponse<DishVo> update(@PathVariable Long id, @Valid @RequestBody DishSaveRequest request) {
        return ApiResponse.ok("菜品已更新", dishService.update(id, request));
    }

    @Operation(summary = "上架/下架/草稿")
    @PatchMapping("/{id}/status")
    public ApiResponse<Void> changePublishStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        dishService.changePublishStatus(id, body == null ? null : body.get("status"));
        return ApiResponse.ok("状态已更新", null);
    }

    @Operation(summary = "供应状态（供应中/售罄/暂停）")
    @PatchMapping("/{id}/supply-status")
    public ApiResponse<Void> changeSupplyStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        dishService.changeSupplyStatus(id, body == null ? null : body.get("status"));
        return ApiResponse.ok("供应状态已更新", null);
    }

    @Operation(summary = "复制菜品")
    @PostMapping("/{id}/copy")
    public ApiResponse<DishVo> copy(@PathVariable Long id) {
        return ApiResponse.ok("已复制菜品（草稿状态）", dishService.copy(id));
    }

    @Operation(summary = "删除菜品（逻辑删除，保留历史订单快照）")
    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        dishService.delete(id);
        return ApiResponse.ok("菜品已删除（历史订单快照保留）", null);
    }
}
