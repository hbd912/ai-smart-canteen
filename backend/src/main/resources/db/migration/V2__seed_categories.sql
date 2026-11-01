-- =============================================================
-- V2__seed_categories.sql
-- 7 个固定分类，code 稳定，幂等写入
-- =============================================================
INSERT INTO dish_category
(name, code, icon, sort_order, status, created_at, updated_at)
VALUES
('主食套餐', 'MAIN_MEAL', 'rice-bowl', 1, 'ACTIVE', NOW(), NOW()),
('荤菜', 'MEAT', 'drumstick', 2, 'ACTIVE', NOW(), NOW()),
('素菜', 'VEGETABLE', 'salad', 3, 'ACTIVE', NOW(), NOW()),
('面食', 'NOODLE', 'soup', 4, 'ACTIVE', NOW(), NOW()),
('汤品', 'SOUP', 'soup', 5, 'ACTIVE', NOW(), NOW()),
('饮品', 'DRINK', 'cup-soda', 6, 'ACTIVE', NOW(), NOW()),
('其他', 'OTHER', 'utensils', 7, 'ACTIVE', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  icon = VALUES(icon),
  sort_order = VALUES(sort_order),
  updated_at = NOW();
