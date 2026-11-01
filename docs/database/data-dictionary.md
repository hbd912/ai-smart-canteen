# 数据库数据字典（canteen_system）

数据库：MySQL 8.0+ ｜ 字符集：utf8mb4 ｜ 排序规则：utf8mb4_0900_ai_ci

约定：主键统一 BIGINT AUTO_INCREMENT；金额 DECIMAL(10,2)；营养 DECIMAL(8,2)；状态 VARCHAR。
业务表均含 `created_at` / `updated_at`；支持软删除的表含 `deleted`（MyBatis-Plus 逻辑删除）。

## 1. sys_user（普通用户）

| 字段 | 类型 | 允许空 | 默认 | 说明 |
| --- | --- | --- | --- | --- |
| id | BIGINT | 否 | AUTO | 主键 |
| username | VARCHAR(50) | 否 | — | 登录账号，唯一 |
| password_hash | VARCHAR(100) | 否 | — | BCrypt 哈希，禁止明文 |
| nickname | VARCHAR(50) | 否 | — | 昵称 |
| email | VARCHAR(100) | 是 | NULL | 邮箱，唯一 |
| phone | VARCHAR(20) | 是 | NULL | 手机号，唯一 |
| avatar_url | VARCHAR(500) | 是 | NULL | 头像地址 |
| status | VARCHAR(20) | 否 | ACTIVE | ACTIVE / DISABLED |
| created_at | DATETIME | 否 | — | 创建时间 |
| updated_at | DATETIME | 否 | — | 更新时间 |
| deleted | TINYINT | 否 | 0 | 逻辑删除 |

索引：`uk_sys_user_username(username)`、`uk_sys_user_email(email)`、`uk_sys_user_phone(phone)`、`idx_sys_user_created_at(created_at)`

## 2. sys_admin（管理员）

| 字段 | 类型 | 允许空 | 默认 | 说明 |
| --- | --- | --- | --- | --- |
| id | BIGINT | 否 | AUTO | 主键 |
| username | VARCHAR(50) | 否 | — | 管理员账号，唯一 |
| password_hash | VARCHAR(100) | 否 | — | BCrypt 哈希 |
| display_name | VARCHAR(50) | 否 | — | 显示名称 |
| role_code | VARCHAR(30) | 否 | — | SUPER_ADMIN / OPERATOR / NUTRITION_ADMIN |
| permissions | VARCHAR(500) | 是 | NULL | 逗号分隔权限点（便于扩展） |
| status | VARCHAR(20) | 否 | ACTIVE | ACTIVE / DISABLED |
| last_login_at | DATETIME | 是 | NULL | 最近登录时间 |
| created_at / updated_at | DATETIME | 否 | — | 时间戳 |

## 3. dish_category（菜品分类）

| 字段 | 类型 | 允许空 | 默认 | 说明 |
| --- | --- | --- | --- | --- |
| id | BIGINT | 否 | AUTO | 主键 |
| name | VARCHAR(50) | 否 | — | 分类名称，唯一 |
| code | VARCHAR(30) | 否 | — | 分类编码，唯一（种子数据固定） |
| icon | VARCHAR(100) | 是 | NULL | 前端图标名，不存 HTML |
| cover_image | VARCHAR(500) | 是 | NULL | 封面图 |
| sort_order | INT | 否 | 0 | 排序值，前台按此升序 |
| status | VARCHAR(20) | 否 | ACTIVE | ACTIVE / INACTIVE |
| created_at / updated_at | DATETIME | 否 | — | 时间戳 |

## 4. dish（菜品主表）

| 字段 | 类型 | 允许空 | 默认 | 说明 |
| --- | --- | --- | --- | --- |
| id | BIGINT | 否 | AUTO | 主键 |
| category_id | BIGINT | 否 | — | 外键 → dish_category.id |
| dish_code | VARCHAR(40) | 否 | — | 菜品编码，唯一（D001…） |
| name | VARCHAR(100) | 否 | — | 菜品名称 |
| description | VARCHAR(500) | 是 | NULL | 简介 |
| ingredients_json | JSON | 是 | NULL | 主要食材数组 |
| allergens_json | JSON | 是 | NULL | 过敏原数组，未知时为空数组 |
| image_url | VARCHAR(500) | 是 | NULL | 静态资源或上传返回 URL |
| price | DECIMAL(10,2) | 否 | — | 售价（元），≥ 0 |
| calories | DECIMAL(8,2) | 是 | NULL | 热量 kcal/份 |
| protein_g / fat_g / carbohydrate_g / fiber_g | DECIMAL(8,2) | 是 | NULL | 营养素（g） |
| sodium_mg | DECIMAL(8,2) | 是 | NULL | 钠（mg） |
| nutrition_source | VARCHAR(30) | 否 | ESTIMATED | ESTIMATED / LABEL / TESTED |
| nutrition_note | VARCHAR(255) | 是 | NULL | 营养说明 |
| stock | INT | 否 | 0 | 库存，≥ 0 |
| daily_limit | INT | 是 | NULL | 每日供应量 |
| sold_count | INT | 否 | 0 | 销量，仅由订单业务更新 |
| supply_status | VARCHAR(20) | 否 | AVAILABLE | AVAILABLE / SOLD_OUT / PAUSED |
| publish_status | VARCHAR(20) | 否 | DRAFT | DRAFT / PUBLISHED / UNPUBLISHED |
| recommend_flag | TINYINT | 否 | 0 | 是否推荐 |
| recommend_rank | INT | 否 | 0 | 推荐排序 |
| tags_json | JSON | 是 | NULL | 标签数组 |
| sort_order | INT | 否 | 0 | 前台排序 |
| created_by | BIGINT | 是 | NULL | 创建管理员 ID |
| created_at / updated_at | DATETIME | 否 | — | 时间戳 |
| deleted | TINYINT | 否 | 0 | 逻辑删除 |

索引：`uk_dish_code`、`idx_dish_category`、`idx_dish_publish_status`、`idx_dish_supply_status`、
`idx_dish_price`、`idx_dish_calories`、`idx_dish_created_at`、`idx_dish_combo(category_id, publish_status, supply_status)`

## 5. dish_favorite（收藏关系）

| 字段 | 类型 | 允许空 | 说明 |
| --- | --- | --- | --- |
| id | BIGINT | 否 | 主键 |
| user_id | BIGINT | 否 | 外键 → sys_user.id |
| dish_id | BIGINT | 否 | 外键 → dish.id |
| created_at | DATETIME | 否 | 收藏时间 |

唯一约束：`uk_favorite_user_dish(user_id, dish_id)`

## 6. shopping_cart（购物车主表）

| 字段 | 类型 | 允许空 | 说明 |
| --- | --- | --- | --- |
| id | BIGINT | 否 | 主键 |
| user_id | BIGINT | 否 | 外键 → sys_user.id，唯一（一人一车） |
| created_at / updated_at | DATETIME | 否 | 时间戳 |

## 7. shopping_cart_item（购物车明细）

| 字段 | 类型 | 允许空 | 说明 |
| --- | --- | --- | --- |
| id | BIGINT | 否 | 主键 |
| cart_id | BIGINT | 否 | 外键 → shopping_cart.id |
| dish_id | BIGINT | 否 | 外键 → dish.id |
| quantity | INT | 否 | 数量 > 0（业务上限 99） |

唯一约束：`uk_cart_item(cart_id, dish_id)`
**注意**：购物车不保存价格，结算时必须重新从 dish 表读取价格。

## 8. orders（订单主表）

| 字段 | 类型 | 允许空 | 默认 | 说明 |
| --- | --- | --- | --- | --- |
| id | BIGINT | 否 | AUTO | 主键 |
| order_no | VARCHAR(40) | 否 | — | 订单号，唯一（DEMO- 前缀为演示数据） |
| user_id | BIGINT | 否 | — | 外键 → sys_user.id |
| total_amount | DECIMAL(10,2) | 否 | — | 订单总额（后端计算） |
| total_calories | DECIMAL(10,2) | 是 | NULL | 总热量估算 |
| order_status | VARCHAR(30) | 否 | — | PENDING/PREPARING/DELIVERING/DELIVERED/EATING/COMPLETED/CANCELLED |
| payment_status | VARCHAR(30) | 否 | DEMO_UNPAID | DEMO_UNPAID/DEMO_CONFIRMED/PAID/REFUNDED |
| remark | VARCHAR(255) | 是 | NULL | 备注（含幂等键） |
| created_at / updated_at | DATETIME | 否 | — | 时间戳 |
| completed_at | DATETIME | 是 | NULL | 完成时间 |

索引：`uk_orders_order_no`、`idx_orders_user`、`idx_orders_created_at`、`idx_orders_status`

## 9. order_item（订单明细快照）

| 字段 | 类型 | 允许空 | 说明 |
| --- | --- | --- | --- |
| id | BIGINT | 否 | 主键 |
| order_id | BIGINT | 否 | 外键 → orders.id |
| dish_id | BIGINT | 是 | 菜品软删除后可为空 |
| dish_name_snapshot | VARCHAR(100) | 否 | 下单时菜名快照 |
| image_url_snapshot | VARCHAR(500) | 是 | 下单时图片快照 |
| unit_price_snapshot | DECIMAL(10,2) | 否 | 成交单价快照 |
| quantity | INT | 否 | 数量 |
| subtotal | DECIMAL(10,2) | 否 | 小计 |
| calories_snapshot / protein_snapshot / fat_snapshot / carbohydrate_snapshot | DECIMAL(8,2) | 是 | 营养快照 |
| created_at | DATETIME | 否 | 创建时间 |

**历史订单只读快照字段，绝不 join 当前 dish 数据。**

## 10. inventory_log（库存流水）

| 字段 | 类型 | 允许空 | 说明 |
| --- | --- | --- | --- |
| id | BIGINT | 否 | 主键 |
| dish_id | BIGINT | 否 | 外键 → dish.id |
| change_amount | INT | 否 | 正数入库，负数出库 |
| before_stock | INT | 否 | 调整前库存 |
| after_stock | INT | 否 | 调整后库存 |
| reason | VARCHAR(255) | 否 | 调整原因（含原因代码前缀） |
| operator_admin_id | BIGINT | 是 | 操作管理员 |
| related_order_id | BIGINT | 是 | 关联订单 |
| created_at | DATETIME | 否 | 时间 |

## 11. home_recommendation（首页推荐）

| 字段 | 类型 | 允许空 | 说明 |
| --- | --- | --- | --- |
| id | BIGINT | 否 | 主键 |
| dish_id | BIGINT | 否 | 外键 → dish.id，唯一 |
| title | VARCHAR(80) | 是 | 推荐标题 |
| badge_text | VARCHAR(40) | 是 | 角标文案 |
| sort_order | INT | 否 | 排序 |
| enabled | TINYINT | 否 | 是否展示 |
| start_at / end_at | DATETIME | 是 | 生效时间窗（预留） |
| created_at / updated_at | DATETIME | 否 | 时间戳 |

## 12. ai_conversation / ai_message（AI 会话，可选但已实现）

| ai_conversation | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT | 主键 |
| user_id | BIGINT | 外键 → sys_user.id |
| title | VARCHAR(100) | 会话标题（用户首句截断） |
| created_at / updated_at | DATETIME | 时间戳 |

| ai_message | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT | 主键 |
| conversation_id | BIGINT | 外键 → ai_conversation.id |
| role | VARCHAR(20) | USER / ASSISTANT / SYSTEM |
| content | TEXT | 消息内容 |
| mode | VARCHAR(20) | LLM / RULE_DEMO |
| created_at | DATETIME | 时间戳 |

**不保存任何模型 API Key，也不记录与演示无关的个人敏感信息。**

## 13. order_status_log（订单状态流水）

| 字段 | 类型 | 允许空 | 说明 |
| --- | --- | --- | --- |
| id | BIGINT | 否 | 主键 |
| order_id | BIGINT | 否 | 外键 → orders.id |
| from_status | VARCHAR(30) | 是 | 变更前状态 |
| to_status | VARCHAR(30) | 否 | 变更后状态 |
| operator_type | VARCHAR(20) | 否 | USER / ADMIN / SYSTEM |
| operator_id | BIGINT | 是 | 操作人 ID |
| remark | VARCHAR(255) | 是 | 备注 |
| created_at | DATETIME | 否 | 时间 |

## 状态码总表

| 域 | 取值 |
| --- | --- |
| 上架状态 | DRAFT（草稿，前台不可见）/ PUBLISHED（已上架）/ UNPUBLISHED（已下架） |
| 供应状态 | AVAILABLE（供应中）/ SOLD_OUT（已售罄）/ PAUSED（暂停供应） |
| 订单状态 | PENDING / PREPARING / DELIVERING / DELIVERED / EATING / COMPLETED / CANCELLED |
| 支付状态 | DEMO_UNPAID / DEMO_CONFIRMED / PAID / REFUNDED（课堂演示只有前两种） |
| 用户状态 | ACTIVE / DISABLED |
| 分类状态 | ACTIVE / INACTIVE |
| 管理员角色 | SUPER_ADMIN / OPERATOR / NUTRITION_ADMIN |
