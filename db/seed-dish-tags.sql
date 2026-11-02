-- =============================================================
-- seed-dish-tags.sql
-- 扩充菜品标签为多维度（品类 + 口感 + 营养 + 人气）
-- 生成脚本：tools/seed_tags.py（幂等，按 dish_code 更新）
-- =============================================================

SET NAMES utf8mb4;

-- D001 黑椒鸡排饭
UPDATE dish SET tags_json = JSON_ARRAY('主食', '鲜香', '高蛋白', '高纤维'), updated_at = NOW() WHERE dish_code = 'D001';
-- D002 番茄牛腩饭
UPDATE dish SET tags_json = JSON_ARRAY('主食', '酸甜', '高蛋白', '高纤维'), updated_at = NOW() WHERE dish_code = 'D002';
-- D003 香菇滑鸡饭
UPDATE dish SET tags_json = JSON_ARRAY('主食', '鲜香', '高蛋白', '高纤维'), updated_at = NOW() WHERE dish_code = 'D003';
-- D004 宫保鸡丁饭
UPDATE dish SET tags_json = JSON_ARRAY('主食', '鲜香', '高蛋白'), updated_at = NOW() WHERE dish_code = 'D004';
-- D005 鱼香肉丝饭
UPDATE dish SET tags_json = JSON_ARRAY('主食', '鲜香', '高蛋白', '高纤维'), updated_at = NOW() WHERE dish_code = 'D005';
-- D006 清炒时蔬
UPDATE dish SET tags_json = JSON_ARRAY('素菜', '清淡', '低脂', '低热量'), updated_at = NOW() WHERE dish_code = 'D006';
-- D007 香菇鸡丝面
UPDATE dish SET tags_json = JSON_ARRAY('面食', '鲜香', '高蛋白', '低脂'), updated_at = NOW() WHERE dish_code = 'D007';
-- D008 菌菇汤
UPDATE dish SET tags_json = JSON_ARRAY('汤品', '清淡', '低脂', '低热量'), updated_at = NOW() WHERE dish_code = 'D008';
-- D009 红烧排骨
UPDATE dish SET tags_json = JSON_ARRAY('荤菜', '鲜香', '高蛋白'), updated_at = NOW() WHERE dish_code = 'D009';
-- D010 蒜蓉西兰花
UPDATE dish SET tags_json = JSON_ARRAY('素菜', '清淡', '低脂', '低热量'), updated_at = NOW() WHERE dish_code = 'D010';
-- D011 柠檬蜂蜜水
UPDATE dish SET tags_json = JSON_ARRAY('饮品', '清甜', '低热量', '无添加糖'), updated_at = NOW() WHERE dish_code = 'D011';
-- D012 无糖豆浆
UPDATE dish SET tags_json = JSON_ARRAY('饮品', '清甜', '低热量', '无添加糖'), updated_at = NOW() WHERE dish_code = 'D012';
-- D016 卤水双拼饭
UPDATE dish SET tags_json = JSON_ARRAY('主食', '鲜香', '高蛋白'), updated_at = NOW() WHERE dish_code = 'D016';
-- D017 腊味煲仔饭
UPDATE dish SET tags_json = JSON_ARRAY('主食', '鲜香', '今日推荐'), updated_at = NOW() WHERE dish_code = 'D017';
-- D018 窝蛋牛肉煲仔饭
UPDATE dish SET tags_json = JSON_ARRAY('主食', '鲜香'), updated_at = NOW() WHERE dish_code = 'D018';
-- D019 黑椒牛柳铁板饭
UPDATE dish SET tags_json = JSON_ARRAY('主食', '鲜香', '高蛋白', '高纤维'), updated_at = NOW() WHERE dish_code = 'D019';
-- D020 香辣鸡腿铁板饭
UPDATE dish SET tags_json = JSON_ARRAY('主食', '微辣', '高蛋白', '高纤维'), updated_at = NOW() WHERE dish_code = 'D020';
-- D021 水煮肉片
UPDATE dish SET tags_json = JSON_ARRAY('荤菜', '微辣', '高蛋白', '今日推荐'), updated_at = NOW() WHERE dish_code = 'D021';
-- D022 麻辣香锅小份
UPDATE dish SET tags_json = JSON_ARRAY('荤菜', '微辣', '高蛋白', '今日推荐'), updated_at = NOW() WHERE dish_code = 'D022';
-- D023 新疆大盘鸡
UPDATE dish SET tags_json = JSON_ARRAY('荤菜', '鲜香', '高蛋白'), updated_at = NOW() WHERE dish_code = 'D023';
-- D024 牛肉小炒
UPDATE dish SET tags_json = JSON_ARRAY('荤菜', '鲜香', '高蛋白'), updated_at = NOW() WHERE dish_code = 'D024';
-- D025 红烧肉
UPDATE dish SET tags_json = JSON_ARRAY('荤菜', '鲜香', '高蛋白', '今日推荐'), updated_at = NOW() WHERE dish_code = 'D025';
-- D026 豉汁蒸凤爪
UPDATE dish SET tags_json = JSON_ARRAY('荤菜', '鲜香', '高蛋白'), updated_at = NOW() WHERE dish_code = 'D026';
-- D027 麻婆豆腐
UPDATE dish SET tags_json = JSON_ARRAY('素菜', '清淡', '低脂', '低热量'), updated_at = NOW() WHERE dish_code = 'D027';
-- D028 干煸豆角
UPDATE dish SET tags_json = JSON_ARRAY('素菜', '微辣', '低脂', '低热量'), updated_at = NOW() WHERE dish_code = 'D028';
-- D029 素菜香锅
UPDATE dish SET tags_json = JSON_ARRAY('素菜', '微辣', '低脂', '高纤维'), updated_at = NOW() WHERE dish_code = 'D029';
-- D030 韭菜鸡蛋水饺
UPDATE dish SET tags_json = JSON_ARRAY('素菜', '清淡', '低脂', '低热量'), updated_at = NOW() WHERE dish_code = 'D030';
-- D031 番茄炒蛋
UPDATE dish SET tags_json = JSON_ARRAY('素菜', '酸甜', '低脂', '低热量'), updated_at = NOW() WHERE dish_code = 'D031';
-- D032 牛肉拉面
UPDATE dish SET tags_json = JSON_ARRAY('面食', '鲜香', '今日推荐'), updated_at = NOW() WHERE dish_code = 'D032';
-- D033 番茄鸡蛋面
UPDATE dish SET tags_json = JSON_ARRAY('面食', '酸甜'), updated_at = NOW() WHERE dish_code = 'D033';
-- D034 老北京炸酱面
UPDATE dish SET tags_json = JSON_ARRAY('面食', '鲜香'), updated_at = NOW() WHERE dish_code = 'D034';
-- D035 山西刀削面
UPDATE dish SET tags_json = JSON_ARRAY('面食', '鲜香', '高纤维', '今日推荐'), updated_at = NOW() WHERE dish_code = 'D035';
-- D036 豉汁蒸肠粉
UPDATE dish SET tags_json = JSON_ARRAY('面食', '鲜香', '高蛋白', '低脂'), updated_at = NOW() WHERE dish_code = 'D036';
-- D037 羊肉泡馍
UPDATE dish SET tags_json = JSON_ARRAY('汤品', '清淡', '低脂', '低热量'), updated_at = NOW() WHERE dish_code = 'D037';
-- D038 两荤一素套餐
UPDATE dish SET tags_json = JSON_ARRAY('汤品', '清淡', '低脂', '低热量'), updated_at = NOW() WHERE dish_code = 'D038';
-- D039 一荤两素套餐
UPDATE dish SET tags_json = JSON_ARRAY('汤品', '清淡'), updated_at = NOW() WHERE dish_code = 'D039';
-- D040 杨枝甘露
UPDATE dish SET tags_json = JSON_ARRAY('饮品', '清甜', '低热量', '今日推荐'), updated_at = NOW() WHERE dish_code = 'D040';
-- D041 顺德双皮奶
UPDATE dish SET tags_json = JSON_ARRAY('饮品', '清甜', '低热量', '无添加糖'), updated_at = NOW() WHERE dish_code = 'D041';
-- D042 黑糖珍珠奶茶
UPDATE dish SET tags_json = JSON_ARRAY('饮品', '清甜', '低热量', '无添加糖'), updated_at = NOW() WHERE dish_code = 'D042';
-- D043 芋泥啵啵奶茶
UPDATE dish SET tags_json = JSON_ARRAY('饮品', '清甜'), updated_at = NOW() WHERE dish_code = 'D043';
-- D044 烤羊肉串
UPDATE dish SET tags_json = JSON_ARRAY('小吃', '香脆', '低脂'), updated_at = NOW() WHERE dish_code = 'D044';
-- D045 水晶虾饺皇
UPDATE dish SET tags_json = JSON_ARRAY('小吃', '香脆', '低脂', '今日推荐'), updated_at = NOW() WHERE dish_code = 'D045';
-- D046 爆浆流沙包
UPDATE dish SET tags_json = JSON_ARRAY('小吃', '香脆', '低热量'), updated_at = NOW() WHERE dish_code = 'D046';
-- D047 糯米鸡
UPDATE dish SET tags_json = JSON_ARRAY('小吃', '香脆'), updated_at = NOW() WHERE dish_code = 'D047';

SELECT dish_code, name, tags_json FROM dish WHERE deleted = 0 ORDER BY dish_code;
