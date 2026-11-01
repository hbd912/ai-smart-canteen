-- =============================================================
-- V4__seed_recommendations.sql
-- 首页推荐配置：6 条，引用已上架菜品
-- =============================================================
INSERT INTO home_recommendation
(dish_id, title, badge_text, sort_order, enabled, created_at, updated_at)
SELECT d.id, v.title, v.badge_text, v.sort_order, 1, NOW(), NOW()
FROM (
  SELECT 'D001' AS dish_code, '本周人气之选' AS title, '人气TOP1' AS badge_text, 1 AS sort_order
  UNION ALL SELECT 'D002', '番茄慢炖牛腩', '今日推荐', 2
  UNION ALL SELECT 'D003', '清淡不油腻', '今日推荐', 3
  UNION ALL SELECT 'D007', '一碗暖胃面', '面食', 4
  UNION ALL SELECT 'D006', '清爽绿叶菜', '低热量', 5
  UNION ALL SELECT 'D008', '饭前一碗汤', '汤品', 6
) v
JOIN dish d ON d.dish_code = v.dish_code
ON DUPLICATE KEY UPDATE
  title = VALUES(title), badge_text = VALUES(badge_text),
  sort_order = VALUES(sort_order), enabled = VALUES(enabled), updated_at = NOW();
