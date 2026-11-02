-- =============================================================
-- reset-dish-reviews.sql
-- 清空菜品评价并重置评分聚合
-- 仅用于重新导入演示评价数据，不影响其他业务表
-- =============================================================

SET NAMES utf8mb4;

-- 1. 清空评价（dish_review 只含演示数据）
DELETE FROM dish_review;

-- 2. 重置 dish 表的评分聚合字段
UPDATE dish SET avg_rating = 0, review_count = 0;

-- 3. 核验
SELECT COUNT(*) AS review_count FROM dish_review;
SELECT COUNT(*) AS dishes_with_rating FROM dish WHERE avg_rating > 0;
