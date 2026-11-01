package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.dto.CategorySaveRequest;
import com.canteen.dto.CategorySortRequest;
import com.canteen.service.CategoryService;
import com.canteen.vo.CategoryVo;
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

import java.util.List;
import java.util.Map;

@Tag(name = "11. 后台-分类管理", description = "分类增删改、排序、启用停用")
@RestController
@RequestMapping("/api/v1/admin/categories")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminCategoryController {

    private final CategoryService categoryService;

    @Operation(summary = "后台分类列表")
    @GetMapping
    public ApiResponse<List<CategoryVo>> list() {
        return ApiResponse.ok(categoryService.listForAdmin());
    }

    @Operation(summary = "新增分类")
    @PostMapping
    public ApiResponse<CategoryVo> create(@Valid @RequestBody CategorySaveRequest request) {
        return ApiResponse.ok("分类已创建", categoryService.create(request));
    }

    @Operation(summary = "修改分类")
    @PutMapping("/{id}")
    public ApiResponse<CategoryVo> update(@PathVariable Long id, @Valid @RequestBody CategorySaveRequest request) {
        return ApiResponse.ok("分类已更新", categoryService.update(id, request));
    }

    @Operation(summary = "启用/停用分类")
    @PatchMapping("/{id}/status")
    public ApiResponse<Void> changeStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        categoryService.changeStatus(id, body == null ? null : body.get("status"));
        return ApiResponse.ok("分类状态已更新", null);
    }

    @Operation(summary = "调整分类排序")
    @PatchMapping("/sort")
    public ApiResponse<Void> sort(@Valid @RequestBody CategorySortRequest request) {
        categoryService.sort(request);
        return ApiResponse.ok("排序已保存", null);
    }

    @Operation(summary = "删除分类（有菜品时禁止）")
    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        categoryService.delete(id);
        return ApiResponse.ok("分类已删除", null);
    }
}
