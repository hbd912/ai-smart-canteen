package com.canteen.controller;

import com.canteen.common.ApiResponse;
import com.canteen.service.MediaService;
import com.canteen.vo.UploadResultVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "18. 后台-媒体上传", description = "菜品图片上传（校验类型与大小）")
@RestController
@RequestMapping("/api/v1/admin/media")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminMediaController {

    private final MediaService mediaService;

    @Operation(summary = "上传菜品图片")
    @PostMapping("/dishes")
    public ApiResponse<UploadResultVo> uploadDishImage(@RequestParam("file") MultipartFile file) {
        return ApiResponse.ok("上传成功", mediaService.uploadDishImage(file));
    }
}
