package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.dto.AiRecommendRequest;
import com.canteen.security.SecurityUtils;
import com.canteen.service.AiRecommendationService;
import com.canteen.vo.AiRecommendVo;
import com.canteen.vo.AiStatusVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "07. AI 智能推荐", description = "大模型推荐与规则降级模式")
@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class AiController {

    private final AiRecommendationService aiService;

    @Operation(summary = "AI 服务状态（不返回任何密钥）")
    @GetMapping("/status")
    public ApiResponse<AiStatusVo> status() {
        return ApiResponse.ok(aiService.status());
    }

    @Operation(summary = "根据自然语言需求推荐菜品")
    @PostMapping("/recommend")
    public ApiResponse<AiRecommendVo> recommend(@Valid @RequestBody AiRecommendRequest request) {
        return ApiResponse.ok(aiService.recommend(SecurityUtils.currentUserId(), request));
    }
}
