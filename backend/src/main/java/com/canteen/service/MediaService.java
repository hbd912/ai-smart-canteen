package com.canteen.service;

import com.canteen.common.BizException;
import com.canteen.common.ErrorCode;
import com.canteen.config.CanteenProperties;
import com.canteen.vo.UploadResultVo;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

/**
 * 图片上传（本地 uploads 目录）。
 * 说明：这是课堂演示用的本地存储实现，换机/部署时需一并拷贝 uploads 目录；
 * 真实部署应替换为对象存储并返回稳定 URL。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MediaService {

    private static final Set<String> ALLOWED_EXTENSIONS = Set.of("jpg", "jpeg", "png", "webp");
    private static final Set<String> ALLOWED_CONTENT_TYPES =
            Set.of("image/jpeg", "image/png", "image/webp", "image/jpg");
    private static final DateTimeFormatter DATE_DIR = DateTimeFormatter.ofPattern("yyyyMM");

    private final CanteenProperties properties;

    /**
     * 通过文件头魔数判断是否为受支持的图片格式。
     * 支持 JPEG / PNG / WEBP / GIF。
     */
    private boolean isImageMagic(byte[] b, int len) {
        if (len < 12) {
            return false;
        }
        // JPEG: FF D8 FF
        if ((b[0] & 0xFF) == 0xFF && (b[1] & 0xFF) == 0xD8 && (b[2] & 0xFF) == 0xFF) {
            return true;
        }
        // PNG: 89 50 4E 47
        if ((b[0] & 0xFF) == 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G') {
            return true;
        }
        // GIF: GIF87a / GIF89a
        if (b[0] == 'G' && b[1] == 'I' && b[2] == 'F') {
            return true;
        }
        // WEBP: RIFF....WEBP
        if (b[0] == 'R' && b[1] == 'I' && b[2] == 'F' && b[3] == 'F'
                && b[8] == 'W' && b[9] == 'E' && b[10] == 'B' && b[11] == 'P') {
            return true;
        }
        return false;
    }

    public UploadResultVo uploadDishImage(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "请选择要上传的图片");
        }
        long maxBytes = properties.getUpload().getMaxSizeMb() * 1024L * 1024L;
        if (file.getSize() > maxBytes) {
            throw BizException.of(ErrorCode.BAD_REQUEST,
                    "图片大小不能超过 " + properties.getUpload().getMaxSizeMb() + "MB");
        }
        String originalName = file.getOriginalFilename() == null ? "" : file.getOriginalFilename();
        String extension = StringUtils.getFilenameExtension(originalName);
        if (!StringUtils.hasText(extension)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "图片缺少扩展名");
        }
        extension = extension.toLowerCase(Locale.ROOT);
        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "仅支持 jpg / jpeg / png / webp 格式");
        }
        String contentType = file.getContentType();
        if (!StringUtils.hasText(contentType) || !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase(Locale.ROOT))) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "文件类型不合法，仅支持图片");
        }
        // 真实内容校验：读取文件头魔数，判断是否真的是图片。
        //
        // 说明：不能用 ImageIO.read()，JDK 原生不支持 webp，
        // 而本项目菜品图本身就是 webp，会导致合法图片被拒。
        int width = 0;
        int height = 0;
        byte[] head = new byte[32];
        int read;
        try (InputStream in = file.getInputStream()) {
            read = in.readNBytes(head, 0, head.length);
        } catch (IOException ex) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "图片读取失败，请重新选择");
        }
        if (!isImageMagic(head, read)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "文件不是有效的图片");
        }
        // 能解码时顺带取尺寸（png / jpg 可解，webp 交给前端按原图显示）
        try (InputStream in = file.getInputStream()) {
            BufferedImage image = ImageIO.read(in);
            if (image != null) {
                width = image.getWidth();
                height = image.getHeight();
            }
        } catch (IOException ignored) {
            // 解码失败但魔数已确认是图片，允许通过
        }

        String subDir = "dishes/" + LocalDate.now().format(DATE_DIR);
        Path baseDir = Paths.get(properties.getUpload().getDir()).toAbsolutePath().normalize();
        Path targetDir = baseDir.resolve(subDir).normalize();
        if (!targetDir.startsWith(baseDir)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "非法的上传路径");
        }
        String fileName = UUID.randomUUID().toString().replace("-", "") + "." + extension;
        Path target = targetDir.resolve(fileName);
        try {
            Files.createDirectories(targetDir);
            try (InputStream in = file.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException ex) {
            log.error("保存上传图片失败", ex);
            throw BizException.of(ErrorCode.SERVER_ERROR, "图片保存失败，请稍后重试");
        }

        UploadResultVo vo = new UploadResultVo();
        vo.setUrl("/uploads/" + subDir + "/" + fileName);
        vo.setFileName(fileName);
        vo.setSize(file.getSize());
        vo.setContentType(contentType);
        vo.setWidth(width);
        vo.setHeight(height);
        vo.setNote("图片保存在后端 uploads 目录，课堂演示环境换机时需一并拷贝该目录。");
        return vo;
    }

    public Path uploadBaseDir() {
        return Paths.get(properties.getUpload().getDir()).toAbsolutePath().normalize();
    }
}
