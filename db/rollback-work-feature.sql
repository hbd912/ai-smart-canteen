-- =============================================================
-- rollback-work-feature.sql
-- 回退「作品广场 / 个人主页」改版引入的数据库变更
--
-- 保留：
--   - 原有 12 道菜（D001~D012）、7 个分类、36 笔 DEMO 订单
--   - dish_review 表（菜品评价数据仍可作为演示数据保留，不参与 UI）
-- 删除：
--   - work / work_comment / work_like / work_favorite 四张表及其数据
--   - 从参考项目补进来的 32 道菜（dish_code 以 R 开头）
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. 删除作品相关表（先删子表再删主表）
DROP TABLE IF EXISTS work_comment;
DROP TABLE IF EXISTS work_like;
DROP TABLE IF EXISTS work_favorite;
DROP TABLE IF EXISTS work;

-- 2. 删除从参考项目补进来的菜品（R001~R032）
--    先清理引用它们的关联记录，避免外键约束
DELETE FROM dish_review WHERE dish_id IN (SELECT id FROM dish WHERE dish_code LIKE 'R%');
DELETE FROM inventory_log WHERE dish_id IN (SELECT id FROM dish WHERE dish_code LIKE 'R%');
DELETE FROM order_item WHERE dish_id IN (SELECT id FROM dish WHERE dish_code LIKE 'R%');
DELETE FROM home_recommendation WHERE dish_id IN (SELECT id FROM dish WHERE dish_code LIKE 'R%');
DELETE FROM dish WHERE dish_code LIKE 'R%';

-- 3. 恢复原 12 道菜的上架与库存状态
UPDATE dish SET
  publish_status = 'PUBLISHED',
  supply_status = 'AVAILABLE',
  deleted = 0
WHERE dish_code LIKE 'D%';

SET FOREIGN_KEY_CHECKS = 1;

-- 4. 核验
SELECT 'dish' AS item, COUNT(*) AS cnt FROM dish WHERE deleted = 0
UNION ALL SELECT 'dish_category', COUNT(*) FROM dish_category
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'dish_review', COUNT(*) FROM dish_review
UNION ALL SELECT 'home_recommendation', COUNT(*) FROM home_recommendation;

-- 5. 确认作品表已不存在
SELECT COUNT(*) AS work_tables_remaining
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'canteen_system' AND TABLE_NAME LIKE 'work%';
