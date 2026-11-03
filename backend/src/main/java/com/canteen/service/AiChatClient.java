package com.canteen.service;

import com.canteen.config.CanteenProperties;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;

import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 大模型 JSON 调用客户端（OpenAI 兼容的 /chat/completions）。
 *
 * 只负责「发请求 + 取 content」，业务提示词与结果校验由各 Service 负责；
 * API Key 仅从后端配置读取，不写日志、不返回前端。
 */
@Component
@RequiredArgsConstructor
public class AiChatClient {

    private final CanteenProperties properties;
    private final ObjectMapper objectMapper;

    public boolean isConfigured() {
        CanteenProperties.Ai ai = properties.getAi();
        return ai.isEnabled() && StringUtils.hasText(ai.getApiKey());
    }

    /**
     * @param systemPrompt 系统提示词
     * @param userPrompt   用户数据与任务
     * @return 模型返回的 content 原文（约定为 JSON 字符串）
     */
    public String chatJson(String systemPrompt, String userPrompt) throws Exception {
        CanteenProperties.Ai ai = properties.getAi();
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        Duration timeout = Duration.ofSeconds(Math.max(ai.getTimeoutSeconds(), 5));
        factory.setConnectTimeout((int) timeout.toMillis());
        factory.setReadTimeout((int) timeout.toMillis());
        RestClient client = RestClient.builder()
                .baseUrl(ai.getBaseUrl())
                .requestFactory(factory)
                .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + ai.getApiKey())
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .build();

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("model", ai.getModel());
        payload.put("temperature", ai.getTemperature());
        // GLM 系列模型默认思考时间较长，可配置 low/high/max 控制耗时
        if (StringUtils.hasText(ai.getReasoningEffort())) {
            payload.put("reasoning_effort", ai.getReasoningEffort());
        }
        payload.put("messages", List.of(
                Map.of("role", "system", "content", systemPrompt),
                Map.of("role", "user", "content", userPrompt)));
        payload.put("response_format", Map.of("type", "json_object"));

        String raw = client.post()
                .uri("/chat/completions")
                .body(payload)
                .retrieve()
                .body(String.class);
        if (!StringUtils.hasText(raw)) {
            throw new IllegalStateException("大模型返回为空");
        }
        JsonNode content = objectMapper.readTree(raw)
                .path("choices").path(0).path("message").path("content");
        if (content.isMissingNode() || !StringUtils.hasText(content.asText())) {
            throw new IllegalStateException("大模型响应缺少内容");
        }
        return content.asText();
    }
}
