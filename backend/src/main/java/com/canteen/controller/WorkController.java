package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.dto.WorkPublishRequest;
import com.canteen.security.SecurityUtils;
import com.canteen.service.MediaService;
import com.canteen.service.WorkService;
import com.canteen.vo.UploadResultVo;
import com.canteen.vo.WorkCommentVo;
import com.canteen.vo.WorkVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Tag(name = "10. 精选作品", description = "作品流、详情、点赞、评论")
@RestController
@RequestMapping("/api/v1/works")
@RequiredArgsConstructor
public class WorkController {

    private final WorkService workService;
    private final MediaService mediaService;

    @Operation(summary = "精选作品流（sort=hot 按点赞 / latest 按时间）")
    @GetMapping
    public ApiResponse<List<WorkVo>> feed(@RequestParam(defaultValue = "hot") String sort,
                                          @RequestParam(defaultValue = "1") long page,
                                          @RequestParam(defaultValue = "40") long pageSize) {
        return ApiResponse.ok(workService.feed(sort, page, pageSize, optionalUserId()));
    }

    @Operation(summary = "作品详情（含评论）")
    @GetMapping("/{id}")
    public ApiResponse<WorkVo> detail(@PathVariable Long id) {
        return ApiResponse.ok(workService.detail(id, optionalUserId()));
    }

    @Operation(summary = "点赞 / 取消点赞")
    @PostMapping("/{id}/like")
    public ApiResponse<Map<String, Boolean>> toggleLike(@PathVariable Long id) {
        boolean liked = workService.toggleLike(SecurityUtils.currentUserId(), id);
        return ApiResponse.ok(liked ? "已点赞" : "已取消点赞", Map.of("liked", liked));
    }

    @Operation(summary = "作品评论列表")
    @GetMapping("/{id}/comments")
    public ApiResponse<List<WorkCommentVo>> comments(@PathVariable Long id) {
        return ApiResponse.ok(workService.listComments(id));
    }

    @Operation(summary = "发表评论")
    @PostMapping("/{id}/comments")
    public ApiResponse<WorkCommentVo> addComment(@PathVariable Long id,
                                                 @RequestBody Map<String, String> body) {
        String content = body == null ? null : body.get("content");
        return ApiResponse.ok("评论已发表",
                workService.addComment(SecurityUtils.currentUserId(), id, content));
    }

    private Long optionalUserId() {
        try {
            return SecurityUtils.currentUserId();
        } catch (RuntimeException ex) {
            return null;
        }
    }

    @Operation(summary = "发布作品（图片 + 文字 + 可选关联历史订单/菜品）")
    @PostMapping
    public ApiResponse<WorkVo> publish(@Valid @RequestBody WorkPublishRequest request) {
        Long userId = SecurityUtils.currentUserId();
        return ApiResponse.ok("作品已发布", workService.publish(userId, request));
    }

    @Operation(summary = "上传作品图片（普通用户）")
    @PostMapping("/images")
    public ApiResponse<UploadResultVo> uploadImage(@RequestParam("file") MultipartFile file) {
        return ApiResponse.ok("上传成功", mediaService.uploadDishImage(file));
    }
}
