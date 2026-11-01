-- =============================================================
-- V1__create_core_tables.sql
-- AI 智慧食堂 核心表结构（MySQL 8.x / utf8mb4）
-- 规范：主键 BIGINT、金额 DECIMAL(10,2)、营养 DECIMAL(8,2)、状态 VARCHAR
-- =============================================================

-- A. 普通用户
CREATE TABLE IF NOT EXISTS sys_user (
  id            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  username      VARCHAR(50)  NOT NULL COMMENT '登录账号',
  password_hash VARCHAR(100) NOT NULL COMMENT 'BCrypt 哈希',
  nickname      VARCHAR(50)  NOT NULL COMMENT '昵称',
  email         VARCHAR(100) NULL COMMENT '邮箱',
  phone         VARCHAR(20)  NULL COMMENT '手机号',
  avatar_url    VARCHAR(500) NULL COMMENT '头像地址',
  status        VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/DISABLED',
  created_at    DATETIME     NOT NULL,
  updated_at    DATETIME     NOT NULL,
  deleted       TINYINT      NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_user_username (username),
  UNIQUE KEY uk_sys_user_email (email),
  UNIQUE KEY uk_sys_user_phone (phone),
  KEY idx_sys_user_created_at (created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '普通用户';

-- B. 管理员
CREATE TABLE IF NOT EXISTS sys_admin (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  username      VARCHAR(50)  NOT NULL COMMENT '管理员账号/工号',
  password_hash VARCHAR(100) NOT NULL COMMENT 'BCrypt 哈希',
  display_name  VARCHAR(50)  NOT NULL,
  role_code     VARCHAR(30)  NOT NULL COMMENT 'SUPER_ADMIN/OPERATOR/NUTRITION_ADMIN',
  permissions   VARCHAR(500) NULL COMMENT '逗号分隔的权限点',
  status        VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
  last_login_at DATETIME     NULL,
  created_at    DATETIME     NOT NULL,
  updated_at    DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_sys_admin_username (username)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '管理员';

-- C. 菜品分类
CREATE TABLE IF NOT EXISTS dish_category (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  name        VARCHAR(50)  NOT NULL,
  code        VARCHAR(30)  NOT NULL,
  icon        VARCHAR(100) NULL COMMENT '前端图标名，不存 HTML',
  cover_image VARCHAR(500) NULL,
  sort_order  INT          NOT NULL DEFAULT 0,
  status      VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/INACTIVE',
  created_at  DATETIME     NOT NULL,
  updated_at  DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_dish_category_name (name),
  UNIQUE KEY uk_dish_category_code (code),
  KEY idx_dish_category_sort (sort_order)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '菜品分类';

-- D. 菜品
CREATE TABLE IF NOT EXISTS dish (
  id               BIGINT        NOT NULL AUTO_INCREMENT,
  category_id      BIGINT        NOT NULL,
  dish_code        VARCHAR(40)   NOT NULL,
  name             VARCHAR(100)  NOT NULL,
  description      VARCHAR(500)  NULL,
  ingredients_json JSON          NULL COMMENT '主要食材数组',
  allergens_json   JSON          NULL COMMENT '过敏原数组，未知时为空数组',
  image_url        VARCHAR(500)  NULL COMMENT '静态资源或上传返回 URL',
  price            DECIMAL(10,2) NOT NULL,
  calories         DECIMAL(8,2)  NULL COMMENT 'kcal/份',
  protein_g        DECIMAL(8,2)  NULL,
  fat_g            DECIMAL(8,2)  NULL,
  carbohydrate_g   DECIMAL(8,2)  NULL,
  fiber_g          DECIMAL(8,2)  NULL,
  sodium_mg        DECIMAL(8,2)  NULL,
  nutrition_source VARCHAR(30)   NOT NULL DEFAULT 'ESTIMATED' COMMENT 'ESTIMATED/LABEL/TESTED',
  nutrition_note   VARCHAR(255)  NULL,
  stock            INT           NOT NULL DEFAULT 0,
  daily_limit      INT           NULL,
  sold_count       INT           NOT NULL DEFAULT 0,
  supply_status    VARCHAR(20)   NOT NULL DEFAULT 'AVAILABLE' COMMENT 'AVAILABLE/SOLD_OUT/PAUSED',
  publish_status   VARCHAR(20)   NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT/PUBLISHED/UNPUBLISHED',
  recommend_flag   TINYINT       NOT NULL DEFAULT 0,
  recommend_rank   INT           NOT NULL DEFAULT 0,
  tags_json        JSON          NULL,
  sort_order       INT           NOT NULL DEFAULT 0,
  created_by       BIGINT        NULL,
  created_at       DATETIME      NOT NULL,
  updated_at       DATETIME      NOT NULL,
  deleted          TINYINT       NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uk_dish_code (dish_code),
  KEY idx_dish_category (category_id),
  KEY idx_dish_publish_status (publish_status),
  KEY idx_dish_supply_status (supply_status),
  KEY idx_dish_price (price),
  KEY idx_dish_calories (calories),
  KEY idx_dish_created_at (created_at),
  KEY idx_dish_combo (category_id, publish_status, supply_status),
  CONSTRAINT fk_dish_category FOREIGN KEY (category_id) REFERENCES dish_category (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '菜品主表';

-- E. 收藏关系
CREATE TABLE IF NOT EXISTS dish_favorite (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  user_id    BIGINT   NOT NULL,
  dish_id    BIGINT   NOT NULL,
  created_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_favorite_user_dish (user_id, dish_id),
  KEY idx_favorite_dish (dish_id),
  CONSTRAINT fk_favorite_user FOREIGN KEY (user_id) REFERENCES sys_user (id),
  CONSTRAINT fk_favorite_dish FOREIGN KEY (dish_id) REFERENCES dish (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '菜品收藏';

-- F. 购物车主表
CREATE TABLE IF NOT EXISTS shopping_cart (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  user_id    BIGINT   NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_cart_user (user_id),
  CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES sys_user (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '购物车主表';

-- G. 购物车明细（不保存可信价格，结算时重新读取 dish.price）
CREATE TABLE IF NOT EXISTS shopping_cart_item (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  cart_id    BIGINT   NOT NULL,
  dish_id    BIGINT   NOT NULL,
  quantity   INT      NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_cart_item (cart_id, dish_id),
  KEY idx_cart_item_dish (dish_id),
  CONSTRAINT fk_cart_item_cart FOREIGN KEY (cart_id) REFERENCES shopping_cart (id),
  CONSTRAINT fk_cart_item_dish FOREIGN KEY (dish_id) REFERENCES dish (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '购物车明细';

-- H. 订单主表
CREATE TABLE IF NOT EXISTS orders (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  order_no        VARCHAR(40)   NOT NULL,
  user_id         BIGINT        NOT NULL,
  total_amount    DECIMAL(10,2) NOT NULL,
  total_calories  DECIMAL(10,2) NULL,
  order_status    VARCHAR(30)   NOT NULL COMMENT 'PENDING/PREPARING/DELIVERING/DELIVERED/EATING/COMPLETED/CANCELLED',
  payment_status  VARCHAR(30)   NOT NULL DEFAULT 'DEMO_UNPAID' COMMENT 'DEMO_UNPAID/DEMO_CONFIRMED/PAID/REFUNDED',
  remark          VARCHAR(255)  NULL,
  created_at      DATETIME      NOT NULL,
  updated_at      DATETIME      NOT NULL,
  completed_at    DATETIME      NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_orders_order_no (order_no),
  KEY idx_orders_user (user_id),
  KEY idx_orders_created_at (created_at),
  KEY idx_orders_status (order_status),
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES sys_user (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '订单主表';

-- I. 订单明细快照
CREATE TABLE IF NOT EXISTS order_item (
  id                    BIGINT        NOT NULL AUTO_INCREMENT,
  order_id              BIGINT        NOT NULL,
  dish_id               BIGINT        NULL COMMENT '菜品软删除后可为空',
  dish_name_snapshot    VARCHAR(100)  NOT NULL,
  image_url_snapshot    VARCHAR(500)  NULL,
  unit_price_snapshot   DECIMAL(10,2) NOT NULL,
  quantity              INT           NOT NULL,
  subtotal              DECIMAL(10,2) NOT NULL,
  calories_snapshot     DECIMAL(8,2)  NULL,
  protein_snapshot      DECIMAL(8,2)  NULL,
  fat_snapshot          DECIMAL(8,2)  NULL,
  carbohydrate_snapshot DECIMAL(8,2)  NULL,
  created_at            DATETIME      NOT NULL,
  PRIMARY KEY (id),
  KEY idx_order_item_order (order_id),
  KEY idx_order_item_dish (dish_id),
  CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES orders (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '订单明细快照';

-- J. 库存流水
CREATE TABLE IF NOT EXISTS inventory_log (
  id                BIGINT       NOT NULL AUTO_INCREMENT,
  dish_id           BIGINT       NOT NULL,
  change_amount     INT          NOT NULL COMMENT '正数入库，负数出库',
  before_stock      INT          NOT NULL,
  after_stock       INT          NOT NULL,
  reason            VARCHAR(255) NOT NULL,
  operator_admin_id BIGINT       NULL,
  related_order_id  BIGINT       NULL,
  created_at        DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY idx_inventory_dish (dish_id),
  KEY idx_inventory_created_at (created_at),
  KEY idx_inventory_order (related_order_id),
  CONSTRAINT fk_inventory_dish FOREIGN KEY (dish_id) REFERENCES dish (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '库存调整流水';

-- K. 首页推荐
CREATE TABLE IF NOT EXISTS home_recommendation (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  dish_id    BIGINT      NOT NULL,
  title      VARCHAR(80) NULL,
  badge_text VARCHAR(40) NULL,
  sort_order INT         NOT NULL DEFAULT 0,
  enabled    TINYINT     NOT NULL DEFAULT 1,
  start_at   DATETIME    NULL,
  end_at     DATETIME    NULL,
  created_at DATETIME    NOT NULL,
  updated_at DATETIME    NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_home_rec_dish (dish_id),
  KEY idx_home_rec_sort (sort_order),
  CONSTRAINT fk_home_rec_dish FOREIGN KEY (dish_id) REFERENCES dish (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '首页推荐配置';

-- L. AI 会话
CREATE TABLE IF NOT EXISTS ai_conversation (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  user_id    BIGINT       NOT NULL,
  title      VARCHAR(100) NULL,
  created_at DATETIME     NOT NULL,
  updated_at DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY idx_ai_conv_user (user_id),
  CONSTRAINT fk_ai_conv_user FOREIGN KEY (user_id) REFERENCES sys_user (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT 'AI 会话';

-- M. AI 消息
CREATE TABLE IF NOT EXISTS ai_message (
  id              BIGINT      NOT NULL AUTO_INCREMENT,
  conversation_id BIGINT      NOT NULL,
  role            VARCHAR(20) NOT NULL COMMENT 'USER/ASSISTANT/SYSTEM',
  content         TEXT        NOT NULL,
  mode            VARCHAR(20) NULL COMMENT 'LLM/RULE_DEMO',
  created_at      DATETIME    NOT NULL,
  PRIMARY KEY (id),
  KEY idx_ai_msg_conv (conversation_id),
  CONSTRAINT fk_ai_msg_conv FOREIGN KEY (conversation_id) REFERENCES ai_conversation (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT 'AI 消息';

-- N. 订单状态流水
CREATE TABLE IF NOT EXISTS order_status_log (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  order_id      BIGINT       NOT NULL,
  from_status   VARCHAR(30)  NULL,
  to_status     VARCHAR(30)  NOT NULL,
  operator_type VARCHAR(20)  NOT NULL COMMENT 'USER/ADMIN/SYSTEM',
  operator_id   BIGINT       NULL,
  remark        VARCHAR(255) NULL,
  created_at    DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY idx_order_status_log_order (order_id),
  CONSTRAINT fk_order_status_log_order FOREIGN KEY (order_id) REFERENCES orders (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT '订单状态流水';
