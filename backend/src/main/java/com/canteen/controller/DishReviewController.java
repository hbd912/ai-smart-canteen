package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.common.PageResult;
import com.canteen.dto.DishReviewRequest;
import com.canteen.security.SecurityUtils;
import com.canteen.service.DishReviewService;
import com.canteen.vo.DishRatingSummaryVo;
import com.canteen.vo.DishReviewVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "09. 菜品评价", description = "评分汇总、评价列表、提交评价")
@RestController
@RequestMapping("/api/v1/reviews")
@RequiredArgsConstructor
public class DishReviewController {

    private final DishReviewService reviewService;

    @Operation(summary = "菜品评分汇总（平均分/分布/好评率/最近评价）")
    @GetMapping("/dishes/{dishId}/summary")
    public ApiResponse<DishRatingSummaryVo> summary(@PathVariable Long dishId) {
        return ApiResponse.ok(reviewService.summary(dishId, optionalUserId()));
    }

    @Operation(summary = "菜品评价分页列表")
    @GetMapping("/dishes/{dishId}")
    public ApiResponse<PageResult<DishReviewVo>> list(@PathVariable Long dishId,
                                                      @RequestParam(defaultValue = "1") long page,
                                                      @RequestParam(defaultValue = "10") long pageSize) {
        return ApiResponse.ok(reviewService.list(dishId, page, pageSize));
    }

    @Operation(summary = "我的评价列表")
    @GetMapping("/mine")
    public ApiResponse<List<DishReviewVo>> mine() {
        return ApiResponse.ok(reviewService.listMine(SecurityUtils.currentUserId()));
    }

    @Operation(summary = "提交或更新评价")
    @PostMapping
    public ApiResponse<DishReviewVo> submit(@Valid @RequestBody DishReviewRequest request) {
        return ApiResponse.ok("评价已提交", reviewService.submit(SecurityUtils.currentUserId(), request));
    }

    @Operation(summary = "删除自己的评价")
    @DeleteMapping("/{reviewId}")
    public ApiResponse<Void> remove(@PathVariable Long reviewId) {
        reviewService.remove(SecurityUtils.currentUserId(), reviewId);
        return ApiResponse.ok("评价已删除", null);
    }

    private Long optionalUserId() {
        try {
            return SecurityUtils.currentUserId();
        } catch (RuntimeException ex) {
            return null;
        }
    }
}
