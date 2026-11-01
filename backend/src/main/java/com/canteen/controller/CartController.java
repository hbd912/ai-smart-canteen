package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.dto.AddCartItemRequest;
import com.canteen.dto.UpdateCartItemRequest;
import com.canteen.security.SecurityUtils;
import com.canteen.service.CartService;
import com.canteen.vo.CartVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "03. 购物车", description = "购物车增删改查（不产生订单）")
@RestController
@RequestMapping("/api/v1/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @Operation(summary = "读取当前用户购物车")
    @GetMapping
    public ApiResponse<CartVo> get() {
        return ApiResponse.ok(cartService.getCart(SecurityUtils.currentUserId()));
    }

    @Operation(summary = "加入购物车")
    @PostMapping("/items")
    public ApiResponse<CartVo> add(@Valid @RequestBody AddCartItemRequest request) {
        return ApiResponse.ok(cartService.addItem(SecurityUtils.currentUserId(), request));
    }

    @Operation(summary = "修改购物车商品数量（0 表示移除）")
    @PutMapping("/items/{id}")
    public ApiResponse<CartVo> update(@PathVariable Long id,
                                      @Valid @RequestBody UpdateCartItemRequest request) {
        return ApiResponse.ok(cartService.updateItem(SecurityUtils.currentUserId(), id, request.getQuantity()));
    }

    @Operation(summary = "移除购物车商品")
    @DeleteMapping("/items/{id}")
    public ApiResponse<CartVo> remove(@PathVariable Long id) {
        return ApiResponse.ok(cartService.removeItem(SecurityUtils.currentUserId(), id));
    }

    @Operation(summary = "清空购物车")
    @DeleteMapping
    public ApiResponse<CartVo> clear() {
        return ApiResponse.ok(cartService.clear(SecurityUtils.currentUserId()));
    }
}
