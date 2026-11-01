package com.canteen.common;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.List;

/**
 * JSON 字段读写工具。数据库中的 ingredients_json / tags_json 等以字符串形式保存。
 */
@Slf4j
public final class JsonUtils {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private JsonUtils() {
    }

    public static List<String> toList(String json) {
        if (json == null || json.isBlank()) {
            return new ArrayList<>();
        }
        try {
            List<String> list = MAPPER.readValue(json, new TypeReference<List<String>>() {
            });
            return list == null ? new ArrayList<>() : new ArrayList<>(list);
        } catch (Exception ex) {
            log.warn("解析 JSON 数组失败，返回空列表：{}", json);
            return new ArrayList<>();
        }
    }

    public static String toJson(List<String> list) {
        try {
            return MAPPER.writeValueAsString(list == null ? List.of() : list);
        } catch (Exception ex) {
            return "[]";
        }
    }

    public static <T> String write(T value) {
        try {
            return MAPPER.writeValueAsString(value);
        } catch (Exception ex) {
            return "{}";
        }
    }
}
