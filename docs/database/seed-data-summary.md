# 初始化数据汇总（Seed Data Summary）

数据库：`canteen_system` ｜ 采集时间：首次完整初始化后（已清理自测产生的临时订单）

## 1. 各表初始数据条数

| 表 | 条数 | 来源 | 是否演示数据 |
| --- | --- | --- | --- |
| dish_category | 7 | Flyway `V2__seed_categories.sql` | 是（固定种子，code 幂等） |
| dish | 12 | Flyway `V3__seed_dishes.sql` | 是（价格/营养均为估算） |
| home_recommendation | 6 | Flyway `V4__seed_recommendations.sql` | 是 |
| sys_user | 2 | `DemoAccountInitializer`（BCrypt） | 是（演示账号） |
| sys_admin | 1 | `DemoAccountInitializer`（BCrypt） | 是（演示管理员） |
| orders | 36 | `DemoOrderInitializer`（DEMO- 前缀，固定随机种子） | 是 |
| order_item | 64 | `DemoOrderInitializer` | 是 |
| order_status_log | 约 72 | `DemoOrderInitializer` | 是 |
| inventory_log | 6 | `DemoOrderInitializer` | 是 |
| ai_conversation / ai_message | 0 | 运行时产生 | 否（用户交互数据） |
| dish_favorite / shopping_cart* | 0 | 运行时产生 | 否 |

## 2. 订单状态分布（36 笔演示订单）

| 状态 | 笔数 | 是否计入销售额 |
| --- | --- | --- |
| COMPLETED | 14 | 是 |
| EATING | 5 | 是 |
| DELIVERED | 5 | 是 |
| PREPARING | 4 | 是 |
| PENDING | 4 | 是 |
| CANCELLED | 4 | **否**（销售额统计显式排除） |

统计口径由 `Constants.OrderStatus.REVENUE_STATUSES` 统一定义，
`StatisticsService` 的所有销售额/订单量聚合都基于该集合。

## 3. 订单时间分布

- 分布在最近 7 天内（`daysAgo = (i * 3 + random(3)) % 7`）。
- 小时分布在 7:00 – 19:59 之间（`hour = 7 + random(13)`）。
- 固定随机种子 `RANDOM_SEED = 20260101L`，重置数据库后生成结果一致。

## 4. 幂等策略

| 数据 | 幂等方式 |
| --- | --- |
| 分类 | `code` 唯一 + `ON DUPLICATE KEY UPDATE` |
| 菜品 | `dish_code` 唯一 + `ON DUPLICATE KEY UPDATE` |
| 首页推荐 | `dish_id` 唯一 + `ON DUPLICATE KEY UPDATE` |
| 演示账号 | 按 `username` 查询，存在则跳过（**不重置已有密码**） |
| 演示订单 | 按 `DEMO-%` 前缀计数，已存在 ≥ 36 笔则整体跳过 |
| Flyway 迁移 | `flyway_schema_history` 版本表，已执行版本不再重复执行 |

## 5. 库存与销量口径

**采用的口径**：12 道菜的初始 `stock` 视为「当前剩余库存」，演示订单的销量只写入
`sold_count`，**不再重复扣减 `stock`**（避免初始化时库存被扣两次）。

- 初始总库存：475 份
- 演示订单累计销量（不含取消订单）：87 份
- 新订单产生时，`DishMapper.deductStock` 会在同一事务内原子扣减 `stock` 并累加 `sold_count`，
  同时写入 `inventory_log`；取消订单会回补库存并记录回补流水。

## 5.1 `dish.recommend_flag` 与 `home_recommendation` 的区别（重要）

这两个字段/表**不是同一个概念**，实现中刻意不做联动：

| 概念 | 载体 | 种子数据 | 含义 |
| --- | --- | --- | --- |
| 菜品推荐标记 | `dish.recommend_flag` | 仅 D001 / D002 / D003 = 1 | 菜单卡片上的「推荐」标记与 `/api/v1/dishes?recommendOnly=true` 筛选 |
| 首页推荐位 | `home_recommendation` 表 | 6 条（D001/D002/D003/D007/D006/D008） | 首页「今日推荐」区块展示的菜品、角标文案与顺序 |

后台「首页推荐管理」只操作 `home_recommendation`，**不会**改写 `dish.recommend_flag`；
管理员修改推荐位顺序或增删推荐菜品时，菜品的推荐标记保持不变。
（早期实现曾把两者联动，会导致「调整首页推荐 → 菜品的推荐标记被意外清空」，
已修正并加入回归验证。）

## 6. 演示账号

| 类型 | 账号 | 密码 | 密码存储 |
| --- | --- | --- | --- |
| 普通用户 | student_demo | `Demo@123456`（可用 `DEMO_USER_PASSWORD` 覆盖） | BCrypt 哈希 |
| 普通用户 | demo_user_02 | 同上 | BCrypt 哈希 |
| 管理员 | admin | `Admin@123456`（可用 `DEMO_ADMIN_PASSWORD` 覆盖） | BCrypt 哈希 |

密码由后端 `DataInitializer` 使用 `BCryptPasswordEncoder` 在运行时生成，
**SQL 脚本中不存在任何密码或密码哈希**。

## 7. 验收 SQL 与结果

```sql
SELECT COUNT(*) AS category_count FROM dish_category;              -- 7
SELECT COUNT(*) AS dish_count FROM dish WHERE deleted = 0;         -- 12
SELECT COUNT(*) AS order_count FROM orders WHERE order_no LIKE 'DEMO-%';  -- 36
SELECT COUNT(*) AS order_item_count FROM order_item;               -- 64
SELECT COUNT(*) AS admin_count FROM sys_admin;                     -- 1
SELECT COUNT(*) AS user_count FROM sys_user;                       -- 2
SELECT COUNT(*) AS inventory_log_count FROM inventory_log;         -- 6
```

预期最低值（需求文档 19.8）：category_count=7、dish_count≥12、order_count≥30、
order_item_count≥30、admin_count≥1、user_count≥1、inventory_log_count≥5 —— **全部满足**。
