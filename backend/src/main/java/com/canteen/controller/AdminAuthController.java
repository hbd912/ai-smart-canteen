package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.dto.LoginRequest;
import com.canteen.service.AuthService;
import com.canteen.vo.AuthTokenVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "20. 管理员认证", description = "管理员独立登录入口")
@RestController
@RequestMapping("/api/v1/admin/auth")
@RequiredArgsConstructor
public class AdminAuthController {

    private final AuthService authService;

    @Operation(summary = "管理员登录")
    @PostMapping("/login")
    public ApiResponse<AuthTokenVo> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok("登录成功", authService.adminLogin(request));
    }
}
