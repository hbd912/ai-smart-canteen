package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.service.StatisticsService;
import com.canteen.vo.CategorySalesVo;
import com.canteen.vo.HourlyDistributionVo;
import com.canteen.vo.RankingVo;
import com.canteen.vo.StatisticsOverviewVo;
import com.canteen.vo.TrendVo;
import com.canteen.vo.UserGrowthVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "16. 后台-数据统计", description = "工作台指标与 ECharts 图表数据（全部由数据库聚合）")
@RestController
@RequestMapping("/api/v1/admin/statistics")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminStatisticsController {

    private final StatisticsService statisticsService;

    @Operation(summary = "核心指标总览")
    @GetMapping("/overview")
    public ApiResponse<StatisticsOverviewVo> overview() {
        return ApiResponse.ok(statisticsService.overview());
    }

    @Operation(summary = "订单量与销售额趋势（week/month）")
    @GetMapping("/orders-trend")
    public ApiResponse<TrendVo> ordersTrend(@RequestParam(defaultValue = "week") String period) {
        return ApiResponse.ok(statisticsService.ordersTrend(period));
    }

    @Operation(summary = "菜品销量排行")
    @GetMapping("/dish-ranking")
    public ApiResponse<RankingVo> dishRanking(@RequestParam(defaultValue = "10") int limit) {
        return ApiResponse.ok(statisticsService.dishRanking(limit));
    }

    @Operation(summary = "菜品分类销售占比")
    @GetMapping("/category-sales")
    public ApiResponse<CategorySalesVo> categorySales() {
        return ApiResponse.ok(statisticsService.categorySales());
    }

    @Operation(summary = "时段订单分布")
    @GetMapping("/hourly-distribution")
    public ApiResponse<HourlyDistributionVo> hourlyDistribution() {
        return ApiResponse.ok(statisticsService.hourlyDistribution());
    }

    @Operation(summary = "用户增长趋势")
    @GetMapping("/user-growth")
    public ApiResponse<UserGrowthVo> userGrowth() {
        return ApiResponse.ok(statisticsService.userGrowth());
    }
}
