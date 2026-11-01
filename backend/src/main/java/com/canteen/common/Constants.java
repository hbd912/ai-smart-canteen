package com.canteen.common;

import java.util.Set;

/**
 * 业务状态常量，全项目统一使用 VARCHAR 存这些代码。
 */
public final class Constants {

    private Constants() {
    }

    public static final class PublishStatus {
        public static final String DRAFT = "DRAFT";
        public static final String PUBLISHED = "PUBLISHED";
        public static final String UNPUBLISHED = "UNPUBLISHED";
        private PublishStatus() {
        }
    }

    public static final class SupplyStatus {
        public static final String AVAILABLE = "AVAILABLE";
        public static final String SOLD_OUT = "SOLD_OUT";
        public static final String PAUSED = "PAUSED";
        private SupplyStatus() {
        }
    }

    public static final class OrderStatus {
        public static final String PENDING = "PENDING";
        public static final String PREPARING = "PREPARING";
        public static final String DELIVERING = "DELIVERING";
        public static final String DELIVERED = "DELIVERED";
        public static final String EATING = "EATING";
        public static final String COMPLETED = "COMPLETED";
        public static final String CANCELLED = "CANCELLED";

        /** 计入销售额的有效订单状态（取消订单不计入）。 */
        public static final Set<String> REVENUE_STATUSES =
                Set.of(PENDING, PREPARING, DELIVERING, DELIVERED, EATING, COMPLETED);

        /** 占用用户"当前用餐"名额的状态。 */
        public static final Set<String> ACTIVE_STATUSES =
                Set.of(PENDING, PREPARING, DELIVERING, DELIVERED, EATING);

        public static final Set<String> ALL =
                Set.of(PENDING, PREPARING, DELIVERING, DELIVERED, EATING, COMPLETED, CANCELLED);

        private OrderStatus() {
        }
    }

    public static final class PaymentStatus {
        public static final String DEMO_UNPAID = "DEMO_UNPAID";
        public static final String DEMO_CONFIRMED = "DEMO_CONFIRMED";
        public static final String PAID = "PAID";
        public static final String REFUNDED = "REFUNDED";
        private PaymentStatus() {
        }
    }

    public static final class UserStatus {
        public static final String ACTIVE = "ACTIVE";
        public static final String DISABLED = "DISABLED";
        private UserStatus() {
        }
    }

    public static final class AdminRole {
        public static final String SUPER_ADMIN = "SUPER_ADMIN";
        public static final String OPERATOR = "OPERATOR";
        public static final String NUTRITION_ADMIN = "NUTRITION_ADMIN";
        private AdminRole() {
        }
    }

    public static final class OperatorType {
        public static final String USER = "USER";
        public static final String ADMIN = "ADMIN";
        public static final String SYSTEM = "SYSTEM";
        private OperatorType() {
        }
    }

    public static final class AiMode {
        public static final String LLM = "LLM";
        public static final String RULE_DEMO = "RULE_DEMO";
        private AiMode() {
        }
    }

    /** 库存调整原因代码（同时用于 inventory_log.reason 前缀）。 */
    public static final class InventoryReason {
        public static final String INITIAL_STOCK = "INITIAL_STOCK";
        public static final String ORDER_DEDUCT = "ORDER_DEDUCT";
        public static final String MANUAL_ADJUST = "MANUAL_ADJUST";
        public static final String ORDER_CANCEL_RESTORE = "ORDER_CANCEL_RESTORE";
        public static final String DEMO_SEED = "DEMO_SEED";
        private InventoryReason() {
        }
    }
}
