package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.common.PageResult;
import com.canteen.dto.CreateOrderRequest;
import com.canteen.security.SecurityUtils;
import com.canteen.service.OrderService;
import com.canteen.vo.OrderVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@Tag(name = "04. 订单", description = "结算下单、订单查询、场景状态同步")
@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @Operation(summary = "提交结算并创建订单（后端重新计价 + 校验库存 + 事务扣减）")
    @PostMapping
    public ApiResponse<OrderVo> create(@Valid @RequestBody CreateOrderRequest request) {
        OrderVo vo = orderService.createOrder(SecurityUtils.currentUserId(), request);
        return ApiResponse.ok("订单已提交（课堂演示订单，未发生真实支付）", vo);
    }

    @Operation(summary = "当前用户订单分页列表")
    @GetMapping
    public ApiResponse<PageResult<OrderVo>> list(@RequestParam(defaultValue = "1") long page,
                                                 @RequestParam(defaultValue = "10") long pageSize,
                                                 @RequestParam(required = false) String status) {
        return ApiResponse.ok(orderService.listUserOrders(SecurityUtils.currentUserId(), page, pageSize, status));
    }

    @Operation(summary = "订单详情")
    @GetMapping("/{id}")
    public ApiResponse<OrderVo> detail(@PathVariable Long id) {
        return ApiResponse.ok(orderService.getUserOrder(SecurityUtils.currentUserId(), id));
    }

    @Operation(summary = "当前进行中的订单（用于刷新后恢复场景）")
    @GetMapping("/active")
    public ApiResponse<OrderVo> active() {
        return ApiResponse.ok(orderService.getCurrentActiveOrder(SecurityUtils.currentUserId()));
    }

    @Operation(summary = "前端场景推进订单状态（送餐中/已送达/用餐中/已完成）")
    @PatchMapping("/{id}/scene-status")
    public ApiResponse<OrderVo> syncSceneStatus(@PathVariable Long id,
                                                @RequestBody Map<String, String> body) {
        String status = body == null ? null : body.get("status");
        return ApiResponse.ok(orderService.syncSceneStatus(SecurityUtils.currentUserId(), id, status));
    }
}
