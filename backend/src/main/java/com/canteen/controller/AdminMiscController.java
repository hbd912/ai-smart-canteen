package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.service.AuthService;
import com.canteen.service.NutritionService;
import com.canteen.vo.AdminVo;
import com.canteen.vo.DishVo;
import com.canteen.service.DishService;
import com.canteen.dto.DishQuery;
import com.canteen.common.PageResult;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@Tag(name = "17. 后台-营养信息与管理员", description = "营养字段维护提示、管理员列表")
@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminMiscController {

    private final NutritionService nutritionService;
    private final DishService dishService;
    private final AuthService authService;

    @Operation(summary = "营养信息缺失的菜品")
    @GetMapping("/nutrition/dishes")
    public ApiResponse<List<Map<String, Object>>> nutritionGaps() {
        return ApiResponse.ok(nutritionService.nutritionGaps());
    }

    @Operation(summary = "营养管理：菜品营养列表")
    @GetMapping("/nutrition/dish-list")
    public ApiResponse<PageResult<DishVo>> nutritionDishes(DishQuery query) {
        query.setPageSize(Math.min(Math.max(query.getPageSize(), 1), 100));
        return ApiResponse.ok(dishService.listForAdmin(query));
    }

    @Operation(summary = "管理员列表")
    @GetMapping("/admins")
    public ApiResponse<List<AdminVo>> admins() {
        return ApiResponse.ok(authService.listAdmins());
    }
}
