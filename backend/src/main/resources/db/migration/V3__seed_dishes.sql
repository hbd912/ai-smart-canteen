-- =============================================================
-- V3__seed_dishes.sql
-- 12 道课堂演示菜品（营养/价格为估算演示值，非实验室检测数据）
-- 幂等：dish_code 唯一；重复执行仅刷新种子基础字段
-- 列顺序严格对应 19.4 表格，避免列错位
-- =============================================================

-- D001 黑椒鸡排饭
INSERT INTO dish
(category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
 price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
 nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
 recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D001', '黑椒鸡排饭', '黑椒风味鸡排搭配米饭与时蔬',
       JSON_ARRAY('鸡排', '米饭', '西兰花'), JSON_ARRAY('可能含大豆', '可能含小麦'),
       '/assets/images/dishes/D001.webp',
       15.00, 528, 28.00, 16.00, 62.00, 4.00, 780,
       'ESTIMATED', '课堂演示估算值，非实验室检测数据', 40, 0, 'AVAILABLE', 'PUBLISHED',
       1, 1, JSON_ARRAY('人气', '主食', '高蛋白'), 1, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MAIN_MEAL'
ON DUPLICATE KEY UPDATE
  category_id = VALUES(category_id), name = VALUES(name), description = VALUES(description),
  ingredients_json = VALUES(ingredients_json), allergens_json = VALUES(allergens_json),
  image_url = VALUES(image_url), price = VALUES(price), calories = VALUES(calories),
  protein_g = VALUES(protein_g), fat_g = VALUES(fat_g), carbohydrate_g = VALUES(carbohydrate_g),
  fiber_g = VALUES(fiber_g), sodium_mg = VALUES(sodium_mg),
  nutrition_source = VALUES(nutrition_source), nutrition_note = VALUES(nutrition_note),
  supply_status = VALUES(supply_status), publish_status = VALUES(publish_status),
  recommend_flag = VALUES(recommend_flag), recommend_rank = VALUES(recommend_rank),
  tags_json = VALUES(tags_json), sort_order = VALUES(sort_order), updated_at = NOW();

-- D002 ~ D012
INSERT INTO dish
(category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
 price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
 nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
 recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, v.dish_code, v.name, v.description, v.ingredients_json, v.allergens_json, v.image_url,
       v.price, v.calories, v.protein_g, v.fat_g, v.carbohydrate_g, v.fiber_g, v.sodium_mg,
       'ESTIMATED', '课堂演示估算值，非实验室检测数据',
       v.stock, 0, 'AVAILABLE', 'PUBLISHED',
       v.recommend_flag, v.recommend_rank, v.tags_json, v.sort_order, NOW(), NOW(), 0
FROM (
  SELECT 'D002' AS dish_code, 'MAIN_MEAL' AS category_code, '番茄牛腩饭' AS name,
         '番茄牛腩搭配米饭与胡萝卜' AS description,
         JSON_ARRAY('牛腩', '番茄', '米饭', '胡萝卜') AS ingredients_json,
         JSON_ARRAY('以实际供餐配方核实') AS allergens_json,
         '/assets/images/dishes/D002.webp' AS image_url,
         18.00 AS price, 612 AS calories, 30.00 AS protein_g, 20.00 AS fat_g,
         68.00 AS carbohydrate_g, 5.00 AS fiber_g, 780.00 AS sodium_mg,
         35 AS stock, 1 AS recommend_flag, 2 AS recommend_rank,
         JSON_ARRAY('今日推荐', '主食') AS tags_json, 2 AS sort_order
  UNION ALL SELECT 'D003', 'MAIN_MEAL', '香菇滑鸡饭', '香菇鸡肉搭配米饭与青菜',
         JSON_ARRAY('鸡肉', '香菇', '米饭', '青菜'), JSON_ARRAY('可能含大豆'),
         '/assets/images/dishes/D003.webp', 16.00, 495, 27.00, 13.00, 60.00, 4.50, 720.00,
         35, 1, 3, JSON_ARRAY('今日推荐', '清淡'), 3
  UNION ALL SELECT 'D004', 'MAIN_MEAL', '宫保鸡丁饭', '宫保鸡丁搭配米饭',
         JSON_ARRAY('鸡肉', '花生', '黄瓜', '胡萝卜', '米饭'), JSON_ARRAY('花生'),
         '/assets/images/dishes/D004.webp', 15.00, 520, 26.00, 17.00, 59.00, 3.50, 690.00,
         30, 0, 0, JSON_ARRAY('经典', '主食'), 4
  UNION ALL SELECT 'D005', 'MAIN_MEAL', '鱼香肉丝饭', '鱼香肉丝搭配米饭',
         JSON_ARRAY('猪肉', '木耳', '胡萝卜', '米饭'), JSON_ARRAY('可能含大豆', '可能含小麦'),
         '/assets/images/dishes/D005.webp', 14.00, 483, 22.00, 15.00, 58.00, 4.00, 850.00,
         30, 0, 0, JSON_ARRAY('经典'), 5
  UNION ALL SELECT 'D006', 'VEGETABLE', '清炒时蔬', '当季绿叶蔬菜清炒',
         JSON_ARRAY('时令绿叶菜', '蒜'), JSON_ARRAY('以实际供餐配方核实'),
         '/assets/images/dishes/D006.webp', 10.00, 120, 5.00, 4.00, 16.00, 5.00, 320.00,
         50, 0, 0, JSON_ARRAY('低热量', '素食'), 6
  UNION ALL SELECT 'D007', 'NOODLE', '香菇鸡丝面', '鸡丝香菇汤面',
         JSON_ARRAY('面条', '鸡肉', '香菇', '青菜'), JSON_ARRAY('小麦', '可能含大豆'),
         '/assets/images/dishes/D007.webp', 13.00, 460, 23.00, 10.00, 65.00, 4.00, 900.00,
         25, 0, 0, JSON_ARRAY('面食'), 7
  UNION ALL SELECT 'D008', 'SOUP', '菌菇汤', '菌菇清汤，具体配方待食堂确认',
         JSON_ARRAY('菌菇', '豆腐/高汤（具体配方待确认）'), JSON_ARRAY('配方未确认'),
         '/assets/images/dishes/D008.webp', 4.00, 85, 4.00, 3.00, 9.00, 1.50, 380.00,
         50, 0, 0, JSON_ARRAY('汤品'), 8
  UNION ALL SELECT 'D009', 'MEAT', '红烧排骨', '红烧风味排骨',
         JSON_ARRAY('猪排骨', '葱', '姜'), JSON_ARRAY('可能含大豆', '可能含小麦'),
         '/assets/images/dishes/D009.webp', 18.00, 560, 29.00, 35.00, 22.00, 1.00, 920.00,
         20, 0, 0, JSON_ARRAY('荤菜'), 9
  UNION ALL SELECT 'D010', 'VEGETABLE', '蒜蓉西兰花', '蒜蓉清炒西兰花',
         JSON_ARRAY('西兰花', '大蒜'), JSON_ARRAY('以实际供餐配方核实'),
         '/assets/images/dishes/D010.webp', 9.00, 95, 5.00, 3.00, 12.00, 4.00, 260.00,
         40, 0, 0, JSON_ARRAY('低热量', '素食'), 10
  UNION ALL SELECT 'D011', 'DRINK', '柠檬蜂蜜水', '柠檬与蜂蜜调制饮品',
         JSON_ARRAY('柠檬', '蜂蜜', '水'), JSON_ARRAY('含蜂蜜'),
         '/assets/images/dishes/D011.webp', 5.00, 90, 0.20, 0.00, 23.00, 0.20, 8.00,
         60, 0, 0, JSON_ARRAY('饮品'), 11
  UNION ALL SELECT 'D012', 'DRINK', '无糖豆浆', '无额外添加糖的豆浆',
         JSON_ARRAY('大豆', '水'), JSON_ARRAY('大豆'),
         '/assets/images/dishes/D012.webp', 4.00, 75, 6.50, 3.50, 4.00, 0.50, 45.00,
         60, 0, 0, JSON_ARRAY('无添加糖', '饮品'), 12
) v
JOIN dish_category c ON c.code = v.category_code
ON DUPLICATE KEY UPDATE
  category_id = VALUES(category_id), name = VALUES(name), description = VALUES(description),
  ingredients_json = VALUES(ingredients_json), allergens_json = VALUES(allergens_json),
  image_url = VALUES(image_url), price = VALUES(price), calories = VALUES(calories),
  protein_g = VALUES(protein_g), fat_g = VALUES(fat_g), carbohydrate_g = VALUES(carbohydrate_g),
  fiber_g = VALUES(fiber_g), sodium_mg = VALUES(sodium_mg),
  nutrition_source = VALUES(nutrition_source), nutrition_note = VALUES(nutrition_note),
  supply_status = VALUES(supply_status), publish_status = VALUES(publish_status),
  recommend_flag = VALUES(recommend_flag), recommend_rank = VALUES(recommend_rank),
  tags_json = VALUES(tags_json), sort_order = VALUES(sort_order), updated_at = NOW();
