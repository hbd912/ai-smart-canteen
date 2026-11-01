package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.common.PageResult;
import com.canteen.dto.UpdateUserStatusRequest;
import com.canteen.service.NutritionService;
import com.canteen.vo.UserVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "14. 后台-用户管理", description = "用户查询与禁用/启用（不展示密码）")
@RestController
@RequestMapping("/api/v1/admin/users")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminUserController {

    private final NutritionService nutritionService;

    @Operation(summary = "用户分页列表")
    @GetMapping
    public ApiResponse<PageResult<UserVo>> list(@RequestParam(defaultValue = "1") long page,
                                                @RequestParam(defaultValue = "10") long pageSize,
                                                @RequestParam(required = false) String keyword,
                                                @RequestParam(required = false) String status) {
        return ApiResponse.ok(nutritionService.listUsers(page, pageSize, keyword, status));
    }

    @Operation(summary = "禁用/启用用户")
    @PatchMapping("/{id}/status")
    public ApiResponse<Void> changeStatus(@PathVariable Long id,
                                          @Valid @RequestBody UpdateUserStatusRequest request) {
        nutritionService.changeUserStatus(id, request.getStatus());
        return ApiResponse.ok("用户状态已更新", null);
    }
}
