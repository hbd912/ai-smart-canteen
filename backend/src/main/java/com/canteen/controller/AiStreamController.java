package com.canteen.controller;

import com.canteen.dto.AiRecommendRequest;
import com.canteen.security.SecurityUtils;
import com.canteen.service.AiRecommendationService;
import com.canteen.vo.AiRecommendVo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * AI 小助手流式接口（SSE）。
 *
 * 事件格式：
 * <pre>
 * event: meta   data: {"conversationId":24,"modeLabel":"大模型模式"}
 * event: delta  data: {"text":"增量片段"}   ← 多次
 * event: done   data: {"answer":{完整推荐结果，含菜品卡}}
 * event: error  data: {"message":"..."}
 * </pre>
 *
 * 说明：推荐结果（菜品、价格、营养）仍由后端一次性计算并校验，
 * 这里只把已经生成的回复按小块推送，前端得到逐字出现的「流动输出」效果，
 * 同时保证菜品卡数据完整、不会被 JSON 片段污染。
 */
@Slf4j
@Tag(name = "07. AI 智能推荐")
@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class AiStreamController {

    private final AiRecommendationService aiService;

    /** SSE 专用线程池：模型调用耗时较长，不能占用 Tomcat 工作线程 */
    private static final ExecutorService EXECUTOR = Executors.newFixedThreadPool(6, r -> {
        Thread thread = new Thread(r, "ai-sse");
        thread.setDaemon(true);
        return thread;
    });

    @Operation(summary = "流式推荐（SSE）：逐字输出回复，结束后返回菜品卡")
    @PostMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter stream(@Valid @RequestBody AiRecommendRequest request) {
        // SecurityContext 基于 ThreadLocal，异步线程读不到，必须先取用户 id
        Long userId = SecurityUtils.currentUserId();
        SseEmitter emitter = new SseEmitter(0L);
        EXECUTOR.execute(() -> {
            try {
                AiRecommendVo vo = aiService.recommend(userId, request);
                emitter.send(SseEmitter.event()
                        .name("meta")
                        .data(Map.of(
                                "conversationId", vo.getConversationId() == null ? 0 : vo.getConversationId(),
                                "modeLabel", vo.getModeLabel() == null ? "" : vo.getModeLabel()),
                                MediaType.APPLICATION_JSON));
                streamText(emitter, vo.getReply());
                emitter.send(SseEmitter.event()
                        .name("done")
                        .data(Map.of("answer", vo), MediaType.APPLICATION_JSON));
                emitter.complete();
            } catch (Exception ex) {
                log.warn("AI 流式推荐失败：{}", ex.getMessage());
                try {
                    emitter.send(SseEmitter.event()
                            .name("error")
                            .data(Map.of("message", String.valueOf(ex.getMessage())),
                                    MediaType.APPLICATION_JSON));
                } catch (Exception ignored) {
                    // 客户端已断开
                }
                emitter.complete();
            }
        });
        return emitter;
    }

    private void streamText(SseEmitter emitter, String text) throws Exception {
        if (text == null || text.isEmpty()) {
            return;
        }
        int step = text.length() > 120 ? 3 : 2;
        int delayMs = text.length() > 120 ? 18 : 26;
        for (int i = 0; i < text.length(); ) {
            int end = Math.min(text.length(), i + step);
            // 避免把 emoji 的代理对切成两半
            if (end < text.length() && Character.isLowSurrogate(text.charAt(end))) {
                end++;
            }
            emitter.send(SseEmitter.event()
                    .name("delta")
                    .data(Map.of("text", text.substring(i, end)), MediaType.APPLICATION_JSON));
            i = end;
            Thread.sleep(delayMs);
        }
    }

    /** SSE 异常必须返回纯文本，避免被全局异常处理器包装成 JSON */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleException(Exception ex) {
        log.warn("AI 流式请求异常：{}", ex.getMessage());
        String message = ex.getMessage() == null ? "请求失败" : ex.getMessage();
        return ResponseEntity.status(500)
                .contentType(MediaType.TEXT_PLAIN)
                .body(message);
    }
}
