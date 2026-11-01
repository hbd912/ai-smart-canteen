package com.canteen.common;

import java.util.Map;

/**
 * 状态码到中文标签的统一映射，前后端展示一致。
 */
public final class Labels {

    private static final Map<String, String> ORDER_STATUS = Map.of(
            "PENDING", "已提交",
            "PREPARING", "备餐中",
            "DELIVERING", "送餐中",
            "DELIVERED", "已送达",
            "EATING", "用餐中",
            "COMPLETED", "已完成",
            "CANCELLED", "已取消");

    private static final Map<String, String> PAYMENT_STATUS = Map.of(
            "DEMO_UNPAID", "课堂演示·未支付",
            "DEMO_CONFIRMED", "课堂演示·已确认",
            "PAID", "已支付",
            "REFUNDED", "已退款");

    private static final Map<String, String> PUBLISH_STATUS = Map.of(
            "DRAFT", "草稿",
            "PUBLISHED", "已上架",
            "UNPUBLISHED", "已下架");

    private static final Map<String, String> SUPPLY_STATUS = Map.of(
            "AVAILABLE", "供应中",
            "SOLD_OUT", "已售罄",
            "PAUSED", "暂停供应");

    private static final Map<String, String> ROLE = Map.of(
            "SUPER_ADMIN", "超级管理员",
            "OPERATOR", "食堂运营管理员",
            "NUTRITION_ADMIN", "内容/营养管理员");

    private Labels() {
    }

    public static String orderStatus(String code) {
        return code == null ? "" : ORDER_STATUS.getOrDefault(code, code);
    }

    public static String paymentStatus(String code) {
        return code == null ? "" : PAYMENT_STATUS.getOrDefault(code, code);
    }

    public static String publishStatus(String code) {
        return code == null ? "" : PUBLISH_STATUS.getOrDefault(code, code);
    }

    public static String supplyStatus(String code) {
        return code == null ? "" : SUPPLY_STATUS.getOrDefault(code, code);
    }

    public static String role(String code) {
        return code == null ? "" : ROLE.getOrDefault(code, code);
    }
}
