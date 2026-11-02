-- =============================================================
-- seed-works.sql
-- 「精选」作品流种子数据
-- 生成脚本：tools/seed_works.py（幂等）
--
-- 作品关联真实菜品，图片使用菜品实拍图；点赞数与评论数一并生成
-- =============================================================

SET NAMES utf8mb4;

-- 作品：今天的午饭
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 2, d.id, '今天的午饭', '黑椒鸡排还是稳定的好吃，鸡排外酥里嫩，配的米饭量也足。就是中午排队有点久，建议错峰来。', JSON_ARRAY('/assets/images/dishes/D001.webp'), 128, 0, 'APPROVED', '2026-11-02 14:39:10', '2026-11-02 14:39:10'
FROM dish d WHERE d.dish_code = 'D001'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 2 AND w.title = '今天的午饭');

-- 作品：宫保鸡丁永远的神
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 7, d.id, '宫保鸡丁永远的神', '花生米很脆，鸡丁给得很大方，辣度刚好不呛。这道是我食堂必点，性价比很高。', JSON_ARRAY('/assets/images/dishes/D004.webp'), 96, 0, 'APPROVED', '2026-11-01 14:39:10', '2026-11-01 14:39:10'
FROM dish d WHERE d.dish_code = 'D004'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 7 AND w.title = '宫保鸡丁永远的神');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '求问是哪个窗口的？', 'APPROVED', '2026-11-01 08:39:10' FROM work w WHERE w.title = '宫保鸡丁永远的神'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '求问是哪个窗口的？');
-- 作品：红烧排骨也太香了
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 2, d.id, '红烧排骨也太香了', '排骨炖得很烂，轻轻一抿就脱骨。酱汁拌饭绝了，我每次都多要一点汤汁。', JSON_ARRAY('/assets/images/dishes/D009.webp'), 214, 0, 'APPROVED', '2026-10-31 14:39:10', '2026-10-31 14:39:10'
FROM dish d WHERE d.dish_code = 'D009'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 2 AND w.title = '红烧排骨也太香了');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '照片拍得真好看', 'APPROVED', '2026-10-31 07:39:10' FROM work w WHERE w.title = '红烧排骨也太香了'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '照片拍得真好看');
-- 作品：番茄牛腩饭测评
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 7, d.id, '番茄牛腩饭测评', '牛腩炖得软烂，番茄味很浓，汤汁泡饭非常好吃。唯一缺点是稍微咸了一点点。', JSON_ARRAY('/assets/images/dishes/D002.webp'), 67, 0, 'APPROVED', '2026-10-30 14:39:10', '2026-10-30 14:39:10'
FROM dish d WHERE d.dish_code = 'D002'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 7 AND w.title = '番茄牛腩饭测评');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '这种分享多来点，很有参考价值', 'APPROVED', '2026-10-29 18:39:10' FROM work w WHERE w.title = '番茄牛腩饭测评'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '这种分享多来点，很有参考价值');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '看起来比图片上的还香', 'APPROVED', '2026-10-30 09:39:10' FROM work w WHERE w.title = '番茄牛腩饭测评'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '看起来比图片上的还香');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '刚刚去吃了，确实没让我失望', 'APPROVED', '2026-10-30 12:39:10' FROM work w WHERE w.title = '番茄牛腩饭测评'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '刚刚去吃了，确实没让我失望');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '有点小贵，不过偶尔吃一次可以', 'APPROVED', '2026-10-29 21:39:10' FROM work w WHERE w.title = '番茄牛腩饭测评'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '有点小贵，不过偶尔吃一次可以');
-- 作品：香菇滑鸡煲仔饭
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 2, d.id, '香菇滑鸡煲仔饭', '锅巴很香，香菇和鸡块的搭配很经典。等的时间有点长，大概15分钟，但值得。', JSON_ARRAY('/assets/images/dishes/D003.webp'), 45, 0, 'APPROVED', '2026-10-29 14:39:10', '2026-10-29 14:39:10'
FROM dish d WHERE d.dish_code = 'D003'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 2 AND w.title = '香菇滑鸡煲仔饭');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '有点小贵，不过偶尔吃一次可以', 'APPROVED', '2026-10-28 21:39:10' FROM work w WHERE w.title = '香菇滑鸡煲仔饭'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '有点小贵，不过偶尔吃一次可以');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '我也是每天必点这个', 'APPROVED', '2026-10-28 21:39:10' FROM work w WHERE w.title = '香菇滑鸡煲仔饭'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '我也是每天必点这个');
-- 作品：夏天必点饮品
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 7, d.id, '夏天必点饮品', '柠檬蜂蜜水很清爽，甜度刚好不腻。吃完重口味的菜来一杯很解腻，价格也便宜。', JSON_ARRAY('/assets/images/dishes/D011.webp'), 158, 0, 'APPROVED', '2026-10-28 14:39:10', '2026-10-28 14:39:10'
FROM dish d WHERE d.dish_code = 'D011'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 7 AND w.title = '夏天必点饮品');

-- 作品：无糖豆浆好评
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 2, d.id, '无糖豆浆好评', '真的没加糖，喝起来是纯粹的豆香。配早饭很合适，比外面那些甜豆浆健康多了。', JSON_ARRAY('/assets/images/dishes/D012.webp'), 82, 0, 'APPROVED', '2026-10-27 14:39:10', '2026-10-27 14:39:10'
FROM dish d WHERE d.dish_code = 'D012'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 2 AND w.title = '无糖豆浆好评');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '坐窗边吃这个心情会变好', 'APPROVED', '2026-10-26 23:39:10' FROM work w WHERE w.title = '无糖豆浆好评'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '坐窗边吃这个心情会变好');
-- 作品：减脂期的救星
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 7, d.id, '减脂期的救星', '油很少，青菜很新鲜，颜色也很好看。减脂期间我几乎每天都点这个，热量很低。', JSON_ARRAY('/assets/images/dishes/D006.webp'), 173, 0, 'APPROVED', '2026-10-26 14:39:10', '2026-10-26 14:39:10'
FROM dish d WHERE d.dish_code = 'D006'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 7 AND w.title = '减脂期的救星');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '这家我也常吃，确实不错', 'APPROVED', '2026-10-26 03:39:10' FROM work w WHERE w.title = '减脂期的救星'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '这家我也常吃，确实不错');
-- 作品：水煮肉片够辣
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 2, d.id, '水煮肉片够辣', '红油很香，肉片很嫩，底下还有豆芽和白菜。辣度对我来说有点顶，但真的好吃。', JSON_ARRAY('/assets/images/dishes/D021.webp'), 119, 0, 'APPROVED', '2026-10-25 14:39:10', '2026-10-25 14:39:10'
FROM dish d WHERE d.dish_code = 'D021'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 2 AND w.title = '水煮肉片够辣');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '我也是减脂党，学到了', 'APPROVED', '2026-10-24 21:39:10' FROM work w WHERE w.title = '水煮肉片够辣'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '我也是减脂党，学到了');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '这个组合不错，下次试试', 'APPROVED', '2026-10-25 08:39:10' FROM work w WHERE w.title = '水煮肉片够辣'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '这个组合不错，下次试试');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '照片拍得真好看', 'APPROVED', '2026-10-25 03:39:10' FROM work w WHERE w.title = '水煮肉片够辣'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '照片拍得真好看');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '同意，就是中午排队太久', 'APPROVED', '2026-10-25 03:39:10' FROM work w WHERE w.title = '水煮肉片够辣'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '同意，就是中午排队太久');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '我吃过，味道确实稳定', 'APPROVED', '2026-10-24 23:39:10' FROM work w WHERE w.title = '水煮肉片够辣'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '我吃过，味道确实稳定');
-- 作品：麻婆豆腐测评
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 7, d.id, '麻婆豆腐测评', '豆腐很嫩，麻辣味很足，配米饭能吃两碗。价格只要8块，性价比无敌。', JSON_ARRAY('/assets/images/dishes/D027.webp'), 201, 0, 'APPROVED', '2026-10-24 14:39:10', '2026-10-24 14:39:10'
FROM dish d WHERE d.dish_code = 'D027'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 7 AND w.title = '麻婆豆腐测评');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '同意，就是中午排队太久', 'APPROVED', '2026-10-24 03:39:10' FROM work w WHERE w.title = '麻婆豆腐测评'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '同意，就是中午排队太久');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '我吃过，味道确实稳定', 'APPROVED', '2026-10-23 23:39:10' FROM work w WHERE w.title = '麻婆豆腐测评'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '我吃过，味道确实稳定');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '这种分享多来点，很有参考价值', 'APPROVED', '2026-10-24 07:39:10' FROM work w WHERE w.title = '麻婆豆腐测评'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '这种分享多来点，很有参考价值');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '看起来比图片上的还香', 'APPROVED', '2026-10-24 06:39:10' FROM work w WHERE w.title = '麻婆豆腐测评'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '看起来比图片上的还香');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '刚刚去吃了，确实没让我失望', 'APPROVED', '2026-10-23 21:39:10' FROM work w WHERE w.title = '麻婆豆腐测评'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '刚刚去吃了，确实没让我失望');
-- 作品：面条劲道
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 2, d.id, '面条劲道', '面条是现拉的，很筋道。汤底清亮，牛肉片给得也不少。就是有点咸，下次让少放盐。', JSON_ARRAY('/assets/images/dishes/D032.webp'), 76, 0, 'APPROVED', '2026-10-23 14:39:10', '2026-10-23 14:39:10'
FROM dish d WHERE d.dish_code = 'D032'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 2 AND w.title = '面条劲道');

-- 作品：港式杨枝甘露
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 7, d.id, '港式杨枝甘露', '芒果给得很实在，西米也够多。奶味浓郁，甜度适中。比外面奶茶店便宜一半还多。', JSON_ARRAY('/assets/images/dishes/D040.webp'), 145, 0, 'APPROVED', '2026-10-22 14:39:10', '2026-10-22 14:39:10'
FROM dish d WHERE d.dish_code = 'D040'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 7 AND w.title = '港式杨枝甘露');

-- 作品：虾饺真的很透亮
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 2, d.id, '虾饺真的很透亮', '皮薄得能看到里面的虾仁，一笼三个。虾仁很新鲜，吃起来有弹性。价格小贵但值得。', JSON_ARRAY('/assets/images/dishes/D045.webp'), 89, 0, 'APPROVED', '2026-10-21 14:39:10', '2026-10-21 14:39:10'
FROM dish d WHERE d.dish_code = 'D045'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 2 AND w.title = '虾饺真的很透亮');

-- 作品：清淡好吃
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 7, d.id, '清淡好吃', '蒜香味很足，西兰花炒得刚好，不塌也不生。很适合配重口味的菜一起吃。', JSON_ARRAY('/assets/images/dishes/D010.webp'), 54, 0, 'APPROVED', '2026-10-20 14:39:10', '2026-10-20 14:39:10'
FROM dish d WHERE d.dish_code = 'D010'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 7 AND w.title = '清淡好吃');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '感谢分享，正愁不知道吃啥', 'APPROVED', '2026-10-20 07:39:10' FROM work w WHERE w.title = '清淡好吃'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '感谢分享，正愁不知道吃啥');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '看着就好吃，明天也去点一份', 'APPROVED', '2026-10-19 21:39:10' FROM work w WHERE w.title = '清淡好吃'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '看着就好吃，明天也去点一份');
-- 作品：最家常的番茄炒蛋
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 2, d.id, '最家常的番茄炒蛋', '酸甜口，鸡蛋炒得很嫩，番茄给得也足。只要6块钱，是我吃土期的首选。', JSON_ARRAY('/assets/images/dishes/D031.webp'), 167, 0, 'APPROVED', '2026-10-19 14:39:10', '2026-10-19 14:39:10'
FROM dish d WHERE d.dish_code = 'D031'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 2 AND w.title = '最家常的番茄炒蛋');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '份量看着挺足的，价格也合适', 'APPROVED', '2026-10-19 06:39:10' FROM work w WHERE w.title = '最家常的番茄炒蛋'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '份量看着挺足的，价格也合适');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '求问是哪个窗口的？', 'APPROVED', '2026-10-19 10:39:10' FROM work w WHERE w.title = '最家常的番茄炒蛋'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '求问是哪个窗口的？');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '我也是减脂党，学到了', 'APPROVED', '2026-10-19 01:39:10' FROM work w WHERE w.title = '最家常的番茄炒蛋'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '我也是减脂党，学到了');
-- 作品：铁板滋滋响
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 7, d.id, '铁板滋滋响', '端上来的时候还在响，很香。鸡腿肉很嫩，配菜有青椒和洋葱。铁板很烫不要碰。', JSON_ARRAY('/assets/images/dishes/D020.webp'), 133, 0, 'APPROVED', '2026-10-18 14:39:10', '2026-10-18 14:39:10'
FROM dish d WHERE d.dish_code = 'D020'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 7 AND w.title = '铁板滋滋响');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '这个组合不错，下次试试', 'APPROVED', '2026-10-18 12:39:10' FROM work w WHERE w.title = '铁板滋滋响'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '这个组合不错，下次试试');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '照片拍得真好看', 'APPROVED', '2026-10-18 11:39:10' FROM work w WHERE w.title = '铁板滋滋响'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '照片拍得真好看');
-- 作品：大盘鸡分量足
INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)
SELECT 2, d.id, '大盘鸡分量足', '两个人吃一份刚好，土豆很入味，鸡肉也不柴。配皮带面吸满汤汁，很绝。', JSON_ARRAY('/assets/images/dishes/D023.webp'), 98, 0, 'APPROVED', '2026-10-17 14:39:10', '2026-10-17 14:39:10'
FROM dish d WHERE d.dish_code = 'D023'
AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = 2 AND w.title = '大盘鸡分量足');

INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '我吃过，味道确实稳定', 'APPROVED', '2026-10-17 09:39:10' FROM work w WHERE w.title = '大盘鸡分量足'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '我吃过，味道确实稳定');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 2, '这种分享多来点，很有参考价值', 'APPROVED', '2026-10-17 07:39:10' FROM work w WHERE w.title = '大盘鸡分量足'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '这种分享多来点，很有参考价值');
INSERT INTO work_comment (work_id, user_id, content, status, created_at)
SELECT w.id, 7, '看起来比图片上的还香', 'APPROVED', '2026-10-16 19:39:10' FROM work w WHERE w.title = '大盘鸡分量足'
AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = '看起来比图片上的还香');

-- 回填评论数与点赞数
UPDATE work w SET
  comment_count = (SELECT COUNT(*) FROM work_comment c WHERE c.work_id = w.id AND c.status='APPROVED'),
  like_count = GREATEST(w.like_count, (SELECT COUNT(*) FROM work_like l WHERE l.work_id = w.id));

SELECT w.id, w.title, d.name AS dish, w.like_count, w.comment_count
FROM work w JOIN dish d ON d.id = w.dish_id ORDER BY w.like_count DESC;
