package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.common.PageResult;
import com.canteen.dto.InventoryAdjustRequest;
import com.canteen.security.SecurityUtils;
import com.canteen.service.InventoryService;
import com.canteen.vo.InventoryItemVo;
import com.canteen.vo.InventoryLogVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@Tag(name = "12. 后台-库存管理", description = "库存查询、调整与流水")
@RestController
@RequestMapping("/api/v1/admin/inventory")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminInventoryController {

    private final InventoryService inventoryService;

    @Operation(summary = "库存列表")
    @GetMapping
    public ApiResponse<List<InventoryItemVo>> list(@RequestParam(required = false) String keyword,
                                                   @RequestParam(required = false) Boolean lowStockOnly) {
        return ApiResponse.ok(inventoryService.list(keyword, lowStockOnly));
    }

    @Operation(summary = "库存调整（记录前后数量与原因）")
    @PostMapping("/adjust")
    public ApiResponse<InventoryItemVo> adjust(@Valid @RequestBody InventoryAdjustRequest request) {
        return ApiResponse.ok("库存已调整", inventoryService.adjust(request, SecurityUtils.currentAdminIdOrNull()));
    }

    @Operation(summary = "设置供应状态")
    @PatchMapping("/{dishId}/supply-status")
    public ApiResponse<Void> changeSupplyStatus(@PathVariable Long dishId,
                                                @RequestBody Map<String, String> body) {
        inventoryService.changeSupplyStatus(dishId, body == null ? null : body.get("status"));
        return ApiResponse.ok("供应状态已更新", null);
    }

    @Operation(summary = "库存流水")
    @GetMapping("/logs")
    public ApiResponse<PageResult<InventoryLogVo>> logs(@RequestParam(defaultValue = "1") long page,
                                                        @RequestParam(defaultValue = "20") long pageSize,
                                                        @RequestParam(required = false) Long dishId) {
        return ApiResponse.ok(inventoryService.listLogs(page, pageSize, dishId));
    }

    @Operation(summary = "库存预警阈值")
    @GetMapping("/threshold")
    public ApiResponse<Map<String, Integer>> threshold() {
        return ApiResponse.ok(Map.of("lowStockThreshold", inventoryService.lowStockThreshold()));
    }
}
