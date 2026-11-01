package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.security.SecurityUtils;
import com.canteen.service.NutritionService;
import com.canteen.vo.NutritionSummaryVo;
import com.canteen.vo.NutritionTrendPointVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "06. 营养分析", description = "基于订单快照的营养估算（非医学检测）")
@RestController
@RequestMapping("/api/v1/nutrition")
@RequiredArgsConstructor
public class NutritionController {

    private final NutritionService nutritionService;

    @Operation(summary = "当前用户营养摄入汇总")
    @GetMapping("/summary")
    public ApiResponse<NutritionSummaryVo> summary(@RequestParam(defaultValue = "7") int days) {
        return ApiResponse.ok(nutritionService.summary(SecurityUtils.currentUserId(), days));
    }

    @Operation(summary = "营养摄入趋势")
    @GetMapping("/trends")
    public ApiResponse<List<NutritionTrendPointVo>> trends(@RequestParam(defaultValue = "7") int days) {
        return ApiResponse.ok(nutritionService.trend(SecurityUtils.currentUserId(), days));
    }
}
