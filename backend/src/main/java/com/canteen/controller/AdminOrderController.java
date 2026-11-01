package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.common.PageResult;
import com.canteen.dto.UpdateOrderStatusRequest;
import com.canteen.security.SecurityUtils;
import com.canteen.service.OrderService;
import com.canteen.vo.OrderVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@Tag(name = "13. 后台-订单管理", description = "订单查询、详情与状态管理")
@RestController
@RequestMapping("/api/v1/admin/orders")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminOrderController {

    private final OrderService orderService;

    @Operation(summary = "后台订单分页查询")
    @GetMapping
    public ApiResponse<PageResult<OrderVo>> list(
            @RequestParam(defaultValue = "1") long page,
            @RequestParam(defaultValue = "10") long pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ApiResponse.ok(orderService.listAdminOrders(page, pageSize, keyword, status, startDate, endDate));
    }

    @Operation(summary = "后台订单详情")
    @GetMapping("/{id}")
    public ApiResponse<OrderVo> detail(@PathVariable Long id) {
        return ApiResponse.ok(orderService.getAdminOrder(id));
    }

    @Operation(summary = "管理员更新订单状态")
    @PatchMapping("/{id}/status")
    public ApiResponse<OrderVo> updateStatus(@PathVariable Long id,
                                             @Valid @RequestBody UpdateOrderStatusRequest request) {
        return ApiResponse.ok("订单状态已更新",
                orderService.updateStatusByAdmin(id, request.getStatus(), request.getRemark(),
                        SecurityUtils.currentAdminIdOrNull()));
    }
}
