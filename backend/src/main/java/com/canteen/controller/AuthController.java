package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.dto.LoginRequest;
import com.canteen.dto.RegisterRequest;
import com.canteen.dto.UpdateProfileRequest;
import com.canteen.security.SecurityUtils;
import com.canteen.service.AuthService;
import com.canteen.vo.AdminVo;
import com.canteen.vo.AuthTokenVo;
import com.canteen.vo.UserVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "01. 认证与用户", description = "注册、登录、个人资料")
@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "用户注册")
    @PostMapping("/auth/register")
    public ApiResponse<AuthTokenVo> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.ok("注册成功", authService.register(request));
    }

    @Operation(summary = "用户登录")
    @PostMapping("/auth/login")
    public ApiResponse<AuthTokenVo> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok("登录成功", authService.login(request));
    }

    @Operation(summary = "退出登录（无状态 JWT，由前端清理本地凭证）")
    @PostMapping("/auth/logout")
    public ApiResponse<Void> logout() {
        return ApiResponse.ok("已退出登录", null);
    }

    @Operation(summary = "当前登录用户信息")
    @GetMapping("/users/me")
    public ApiResponse<UserVo> me() {
        return ApiResponse.ok(authService.getCurrentUser(SecurityUtils.currentUserId()));
    }

    @Operation(summary = "修改个人资料")
    @PutMapping("/users/me")
    public ApiResponse<UserVo> updateMe(@Valid @RequestBody UpdateProfileRequest request) {
        return ApiResponse.ok("资料已更新", authService.updateProfile(SecurityUtils.currentUserId(), request));
    }

    @Operation(summary = "当前管理员身份与权限")
    @GetMapping("/admin/auth/me")
    public ApiResponse<AdminVo> adminMe() {
        return ApiResponse.ok(authService.getCurrentAdmin(SecurityUtils.currentAdminIdOrNull()));
    }
}
