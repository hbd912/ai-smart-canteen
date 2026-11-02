-- =============================================================
-- seed-more-dishes.sql
-- 扩充菜品：从参考项目复用菜名与真实图片
-- 生成脚本：tools/expand_dishes.py（幂等，按 dish_code 判重）
--
-- 新增 35 道菜（D013 起），图片已同步到 assets/images/dishes/
-- =============================================================

SET NAMES utf8mb4;

-- 蜜汁叉烧饭
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D013', '蜜汁叉烧饭', '半肥瘦叉烧，配青菜卤蛋', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D013.webp',
  15.00, 492, 18.5, 19.7, 65, 3.9, 612, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  46, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('主食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MAIN_MEAL'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 烧鸭饭
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D014', '烧鸭饭', '广式烧鸭，皮脆肉嫩', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D014.webp',
  16.00, 425, 24.1, 17.2, 57, 5.0, 865, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  49, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('主食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MAIN_MEAL'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 豉汁排骨饭
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D015', '豉汁排骨饭', '豉汁蒸排骨，配米饭', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D015.webp',
  13.00, 444, 24.4, 19.2, 64, 2.6, 836, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  46, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('主食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MAIN_MEAL'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 卤水双拼饭
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D016', '卤水双拼饭', '卤水双拼，可选两样', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D016.webp',
  17.00, 492, 24.4, 16.7, 51, 3.6, 806, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  23, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('主食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MAIN_MEAL'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 腊味煲仔饭
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D017', '腊味煲仔饭', '腊肠腊肉，锅巴香脆', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D017.webp',
  18.00, 501, 18.7, 19.0, 47, 3.6, 900, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  54, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('主食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MAIN_MEAL'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 窝蛋牛肉煲仔饭
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D018', '窝蛋牛肉煲仔饭', '窝蛋牛肉，镬气十足', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D018.webp',
  16.00, 420, 18.2, 14.9, 63, 3.6, 770, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  60, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('主食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MAIN_MEAL'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 黑椒牛柳铁板饭
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D019', '黑椒牛柳铁板饭', '黑椒牛柳，铁板现打', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D019.webp',
  20.00, 512, 24.1, 19.8, 52, 4.0, 855, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  26, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('主食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MAIN_MEAL'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 香辣鸡腿铁板饭
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D020', '香辣鸡腿铁板饭', '香辣鸡腿，铁板滋滋响', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D020.webp',
  18.00, 457, 25.1, 16.2, 58, 4.4, 696, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  60, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('主食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MAIN_MEAL'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 水煮肉片
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D021', '水煮肉片', '里脊肉片，红油现泼', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D021.webp',
  16.00, 525, 32.9, 31.2, 38, 1.0, 661, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  50, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('荤菜', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MEAT'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 麻辣香锅小份
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D022', '麻辣香锅小份', '三十余种食材自选，称重计费', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D022.webp',
  20.00, 385, 33.2, 22.0, 51, 1.6, 775, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  53, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('荤菜', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MEAT'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 新疆大盘鸡
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D023', '新疆大盘鸡', '大盘鸡，配皮带面', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D023.webp',
  22.00, 491, 23.6, 21.0, 44, 1.1, 739, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  36, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('荤菜', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MEAT'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 牛肉小炒
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D024', '牛肉小炒', '鲜切牛肉，猛火爆炒', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D024.webp',
  16.00, 380, 25.2, 21.1, 38, 1.6, 675, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  36, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('荤菜', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MEAT'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 红烧肉
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D025', '红烧肉', '肥瘦相间，浓油赤酱', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D025.webp',
  10.00, 497, 28.0, 30.6, 32, 1.7, 647, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  26, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('荤菜', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MEAT'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 豉汁蒸凤爪
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D026', '豉汁蒸凤爪', '豉汁凤爪，软糯脱骨', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D026.webp',
  12.00, 535, 23.7, 22.7, 35, 1.0, 994, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  31, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('荤菜', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'MEAT'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 麻婆豆腐
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D027', '麻婆豆腐', '嫩豆腐配牛肉末，麻辣鲜香', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D027.webp',
  8.00, 131, 7.3, 6.4, 13, 4.3, 266, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  38, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('素菜', '清淡'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'VEGETABLE'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 干煸豆角
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D028', '干煸豆角', '四季豆干煸，配肉末', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D028.webp',
  9.00, 196, 6.2, 7.2, 18, 4.7, 558, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  47, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('素菜', '清淡'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'VEGETABLE'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 素菜香锅
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D029', '素菜香锅', '十余种素菜自选，称重计费', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D029.webp',
  15.00, 214, 5.6, 10.9, 19, 6.9, 224, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  36, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('素菜', '清淡'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'VEGETABLE'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 韭菜鸡蛋水饺
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D030', '韭菜鸡蛋水饺', '韭菜鸡蛋馅，素馅清爽', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D030.webp',
  11.00, 192, 8.3, 3.7, 8, 6.3, 442, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  32, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('素菜', '清淡'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'VEGETABLE'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 番茄炒蛋
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D031', '番茄炒蛋', '家常番茄炒蛋，酸甜下饭', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D031.webp',
  6.00, 169, 5.0, 9.0, 9, 4.5, 521, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  44, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('素菜', '清淡'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'VEGETABLE'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 牛肉拉面
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D032', '牛肉拉面', '一清二白三红四绿', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D032.webp',
  12.00, 407, 12.2, 16.8, 50, 3.1, 817, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  42, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('面食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'NOODLE'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 番茄鸡蛋面
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D033', '番茄鸡蛋面', '酸甜开胃，手工细面', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D033.webp',
  10.00, 498, 19.1, 12.5, 61, 3.7, 637, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  44, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('面食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'NOODLE'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 老北京炸酱面
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D034', '老北京炸酱面', '手擀面配六必居酱', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D034.webp',
  11.00, 481, 14.1, 15.0, 70, 2.7, 550, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  47, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('面食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'NOODLE'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 山西刀削面
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D035', '山西刀削面', '刀削面，面片筋道', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D035.webp',
  12.00, 480, 19.8, 15.0, 56, 4.0, 799, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  45, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('面食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'NOODLE'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 豉汁蒸肠粉
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D036', '豉汁蒸肠粉', '现蒸肠粉，滑嫩爽口', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D036.webp',
  10.00, 482, 20.0, 11.7, 70, 3.8, 654, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  26, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('面食', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'NOODLE'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 羊肉泡馍
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D037', '羊肉泡馍', '羊汤配馍，自己掰更香', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D037.webp',
  18.00, 192, 17.9, 11.4, 22, 2.4, 738, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  32, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('汤品', '暖胃'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'SOUP'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 两荤一素套餐
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D038', '两荤一素套餐', '自选两荤一素，配例汤', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D038.webp',
  14.00, 145, 13.6, 5.6, 29, 2.5, 577, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  23, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('汤品', '暖胃'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'SOUP'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 一荤两素套餐
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D039', '一荤两素套餐', '自选一荤两素，配例汤', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D039.webp',
  12.00, 213, 13.6, 14.2, 38, 2.4, 565, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  51, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('汤品', '暖胃'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'SOUP'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 杨枝甘露
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D040', '杨枝甘露', '芒果西柚西米，港式经典', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D040.webp',
  12.00, 180, 0.2, 6.5, 45, 0.9, 26, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  52, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('饮品', '无添加糖'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'DRINK'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 顺德双皮奶
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D041', '顺德双皮奶', '顺德双皮奶，奶味浓郁', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D041.webp',
  8.00, 110, 4.1, 4.3, 30, 1.0, 52, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  48, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('饮品', '无添加糖'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'DRINK'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 黑糖珍珠奶茶
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D042', '黑糖珍珠奶茶', '黑糖珍珠，现煮弹牙', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D042.webp',
  7.00, 107, 1.8, 2.3, 38, 0.6, 56, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  45, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('饮品', '无添加糖'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'DRINK'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 芋泥啵啵奶茶
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D043', '芋泥啵啵奶茶', '芋泥啵啵，口感绵密', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D043.webp',
  9.00, 254, 3.5, 5.6, 37, 0.1, 59, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  24, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('饮品', '无添加糖'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'DRINK'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 烤羊肉串
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D044', '烤羊肉串', '现烤羊肉串，孜然味足', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D044.webp',
  5.00, 223, 13.6, 7.1, 32, 2.1, 263, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  52, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('小吃', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'OTHER'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 水晶虾饺皇
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D045', '水晶虾饺皇', '水晶皮透亮，整只虾仁', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D045.webp',
  18.00, 311, 14.4, 6.4, 16, 1.8, 637, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  41, 0, 'AVAILABLE', 'PUBLISHED', 1, 0, JSON_ARRAY('小吃', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'OTHER'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 爆浆流沙包
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D046', '爆浆流沙包', '咸蛋黄流沙，爆浆留心', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D046.webp',
  12.00, 185, 14.8, 12.8, 43, 2.3, 333, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  37, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('小吃', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'OTHER'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 糯米鸡
INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,
  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,
  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,
  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)
SELECT c.id, 'D047', '糯米鸡', '荷叶糯米鸡，料足实在', JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), '/assets/images/dishes/D047.webp',
  10.00, 297, 8.8, 12.8, 21, 1.7, 566, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',
  52, 0, 'AVAILABLE', 'PUBLISHED', 0, 0, JSON_ARRAY('小吃', '经典'), 200, NOW(), NOW(), 0
FROM dish_category c WHERE c.code = 'OTHER'
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();

-- 核验
SELECT c.code AS category, COUNT(d.id) AS cnt
FROM dish_category c LEFT JOIN dish d ON d.category_id = c.id AND d.deleted = 0
GROUP BY c.id ORDER BY c.sort_order;

SELECT COUNT(*) AS total_dishes FROM dish WHERE deleted = 0;
