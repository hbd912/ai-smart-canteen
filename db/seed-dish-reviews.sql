-- =============================================================
-- seed-dish-reviews.sql
-- 来源：参考项目 canteen-feedback-system 的中文评价语料
-- 生成脚本：tools/import_dish_reviews.py（幂等，可重复执行）
--
-- 共 694 条评价，覆盖 12 道菜
-- 评分分布：5星45% / 4星30% / 3星12% / 2星8% / 1星5%
-- 时间重分布到今天往前 90 天；评语已改写为与菜品对应
-- 重置数据请先执行 db/reset-dish-reviews.sql
-- =============================================================

SET NAMES utf8mb4;

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D001' AS code, 5 AS rating, '黑椒鸡排饭份量实在，师傅给肉很大方' AS content, '2026-10-22 12:45:06' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-08-09 18:37:34' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-10-05 19:02:18' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-10-13 19:40:46' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '挺下饭的，黑椒鸡排饭稍微咸了一点点' AS content, '2026-08-29 19:47:09' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '黑椒鸡排饭的肉肥瘦相间，蜜汁调得正好' AS content, '2026-10-16 12:58:59' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-09-02 13:49:13' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '黑椒鸡排饭的肉给得挺多，一个人吃完全够' AS content, '2026-08-26 13:58:14' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-10-15 12:20:40' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '这次黑椒鸡排饭的肉有点发干，不入味' AS content, '2026-10-08 12:44:06' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '每天都想吃黑椒鸡排饭，可惜是限量的' AS content, '2026-08-29 18:04:24' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '师傅颠勺很利索，黑椒鸡排饭出锅就端走' AS content, '2026-10-30 13:14:35' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '黑椒鸡排饭出品挺稳，偶尔肉会偏柴' AS content, '2026-09-24 19:32:35' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-08-27 18:49:08' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '不知道吃什么的时候就来点一份黑椒鸡排饭' AS content, '2026-10-18 13:11:02' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-08-13 13:20:06' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '麻辣鲜香，黑椒鸡排饭在食堂里算做得好的了' AS content, '2026-10-30 11:19:32' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '黑椒鸡排饭配菜比较敷衍，就两片青菜' AS content, '2026-09-02 17:21:20' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '肉很正，就是黑椒鸡排饭的饭给得少了点' AS content, '2026-10-22 18:41:40' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '黑椒鸡排饭算是普通盒饭水平' AS content, '2026-09-19 12:49:43' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-09-27 12:00:59' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '食堂里能吃到这个水平的黑椒鸡排饭挺惊喜' AS content, '2026-08-29 19:54:40' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '整体不错，会推荐给室友' AS content, '2026-08-05 13:28:57' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '黑椒鸡排饭很下饭，配米饭能多来半碗' AS content, '2026-10-02 19:17:24' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '黑椒鸡排饭好吃，就是辣度对我来说有点顶' AS content, '2026-09-01 17:58:32' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-10-15 13:50:48' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '黑椒鸡排饭配的卤蛋入味，青菜也清爽' AS content, '2026-08-14 13:27:00' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '黑椒鸡排饭肉质很嫩，蘸料也地道' AS content, '2026-10-16 11:46:03' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-08-10 17:30:21' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '整体满意，黑椒鸡排饭价格稍微高一点' AS content, '2026-10-07 17:40:32' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '可以要求微辣，黑椒鸡排饭对不吃辣的人也友好' AS content, '2026-08-11 19:22:28' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-08-11 18:25:17' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '油大还咸，吃完黑椒鸡排饭不太舒服' AS content, '2026-10-17 19:42:26' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '黑椒鸡排饭份量实在，师傅给肉很大方，整体很满意' AS content, '2026-08-22 17:28:15' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '还行，黑椒鸡排饭没有很惊艳' AS content, '2026-10-05 18:18:10' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '配菜新鲜，整体满意，整体很满意' AS content, '2026-09-27 17:22:04' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '味道稳定，已经连吃三天了，整体很满意' AS content, '2026-10-05 18:49:44' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '黑椒鸡排饭的辣度不太稳定，时重时淡' AS content, '2026-08-19 13:40:18' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 3 AS rating, '味道一般，黑椒鸡排饭价格偏贵' AS content, '2026-10-28 12:46:58' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 3 AS rating, '又贵又少，黑椒鸡排饭完全不值' AS content, '2026-09-04 18:11:33' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-10-05 18:46:03' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-10-30 19:46:58' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 3 AS rating, '太油腻了，这份黑椒鸡排饭肥肉太多' AS content, '2026-09-09 19:41:18' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 3 AS rating, '黑椒鸡排饭有点凉了，像是提前炒好的' AS content, '2026-08-14 13:53:18' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 2 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-08-21 19:57:51' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 2 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-10-17 19:15:07' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 2 AS rating, '黑椒鸡排饭味道不错，就是分量偏少' AS content, '2026-09-25 19:43:29' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 2 AS rating, '味道一般，黑椒鸡排饭价格偏贵，有点失望' AS content, '2026-10-24 11:07:35' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 1 AS rating, '又贵又少，黑椒鸡排饭完全不值，有点失望' AS content, '2026-09-08 17:11:44' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 1 AS rating, '味道不错，就是油稍微大了点，有点失望' AS content, '2026-10-17 11:29:53' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D001' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，整体很满意' AS content, '2026-09-10 13:08:40' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '挺下饭的，黑椒鸡排饭稍微咸了一点点，整体很满意' AS content, '2026-10-05 13:37:15' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '黑椒鸡排饭的肉肥瘦相间，蜜汁调得正好，整体很满意' AS content, '2026-08-25 11:52:13' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，整体很满意' AS content, '2026-10-11 11:58:11' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '番茄牛腩饭肉质很嫩，蘸料也地道' AS content, '2026-09-27 11:11:34' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-09-06 17:10:21' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '偏甜，番茄牛腩饭个人不太习惯' AS content, '2026-10-07 17:06:04' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-09-24 19:57:26' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '番茄牛腩饭算是普通盒饭水平' AS content, '2026-10-16 11:37:55' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '每天都想吃番茄牛腩饭，可惜是限量的' AS content, '2026-08-22 19:01:11' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '番茄牛腩饭的肉肥瘦相间，蜜汁调得正好' AS content, '2026-09-16 13:01:34' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-09-29 12:55:12' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-08-14 13:22:49' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '肉有股怪味，番茄牛腩饭不太新鲜' AS content, '2026-08-28 12:22:47' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-09-23 18:57:14' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-11-02 17:58:08' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-10-08 12:58:03' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-10-31 18:21:04' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-09-29 19:24:20' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '味道不错，就是油稍微大了点，有点失望' AS content, '2026-08-15 19:49:38' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，有点失望' AS content, '2026-09-10 12:40:37' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 2 AS rating, '有点咸，下次希望能少放点盐，有点失望' AS content, '2026-09-05 18:53:44' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 2 AS rating, '中午排队等了十几分钟，出餐可以再快点，有点失望' AS content, '2026-10-28 13:32:31' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 2 AS rating, '味道不错，就是油稍微大了点，不太推荐' AS content, '2026-10-05 17:17:45' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 2 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，不太推荐' AS content, '2026-09-16 19:21:25' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 1 AS rating, '有点咸，下次希望能少放点盐，不太推荐' AS content, '2026-10-31 17:56:47' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 1 AS rating, '中午排队等了十几分钟，出餐可以再快点，不太推荐' AS content, '2026-08-10 17:28:59' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-11-02 17:21:11' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '整体不错，会推荐给室友' AS content, '2026-09-14 18:17:06' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-10-18 19:31:24' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-10-19 17:20:56' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '番茄牛腩饭出品挺稳，偶尔肉会偏柴' AS content, '2026-09-25 18:07:38' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-10-19 19:34:56' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-10-27 12:58:20' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-11-01 11:24:41' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '番茄牛腩饭肉质很嫩，蘸料也地道，整体很满意' AS content, '2026-10-08 19:36:20' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '偏甜，番茄牛腩饭个人不太习惯，整体很满意' AS content, '2026-08-16 12:12:05' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '番茄牛腩饭算是普通盒饭水平，整体很满意' AS content, '2026-09-28 19:45:09' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '每天都想吃番茄牛腩饭，可惜是限量的，整体很满意' AS content, '2026-10-21 18:15:02' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '番茄牛腩饭的肉肥瘦相间，蜜汁调得正好，整体很满意' AS content, '2026-10-27 12:12:19' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '出餐很快，拿到手还是热的，整体很满意' AS content, '2026-10-15 12:18:48' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '肉有股怪味，番茄牛腩饭不太新鲜，整体很满意' AS content, '2026-09-04 18:18:22' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，整体很满意' AS content, '2026-09-13 11:29:45' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，整体很满意' AS content, '2026-10-27 18:33:21' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '整体不错，会推荐给室友，整体很满意' AS content, '2026-08-20 11:11:32' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，整体很满意' AS content, '2026-10-01 13:55:56' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '味道稳定，已经连吃三天了，整体很满意' AS content, '2026-08-24 17:53:10' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '番茄牛腩饭出品挺稳，偶尔肉会偏柴，整体很满意' AS content, '2026-08-20 18:15:41' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，整体很满意' AS content, '2026-10-07 18:57:14' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '肉给得很大方，师傅人也好，整体很满意' AS content, '2026-10-18 11:08:24' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D002' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-08-18 18:14:11' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-08-21 17:17:14' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '配菜新鲜，整体满意，整体很满意' AS content, '2026-09-04 18:01:00' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '番茄牛腩饭肉质很嫩，蘸料也地道，下次还会点' AS content, '2026-09-11 18:16:32' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，整体还行' AS content, '2026-09-20 19:31:08' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '偏甜，番茄牛腩饭个人不太习惯，下次还会点' AS content, '2026-08-31 19:09:09' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '口味偏淡，适合清淡党，但希望能改进' AS content, '2026-09-28 13:33:38' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '整体不错，会推荐给室友' AS content, '2026-09-20 12:57:16' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-08-13 17:06:39' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-08-23 18:46:41' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-08-06 12:52:49' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-08-12 17:16:32' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-10-24 12:35:06' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-10-25 13:01:29' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-09-12 13:28:30' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-08-16 19:15:10' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '整体不错，会推荐给室友，整体很满意' AS content, '2026-09-04 12:18:06' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，整体很满意' AS content, '2026-10-27 18:12:44' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，整体很满意' AS content, '2026-09-21 17:52:06' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '出餐很快，拿到手还是热的，整体很满意' AS content, '2026-09-14 11:28:19' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，整体很满意' AS content, '2026-10-09 18:57:12' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '味道稳定，已经连吃三天了，整体很满意' AS content, '2026-10-18 19:07:52' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '肉给得很大方，师傅人也好，整体很满意' AS content, '2026-09-14 11:56:06' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '配菜新鲜，整体满意，整体很满意' AS content, '2026-10-19 12:02:31' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，整体很满意' AS content, '2026-08-24 11:02:37' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '整体不错，会推荐给室友，下次还会点' AS content, '2026-08-31 13:36:20' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '分量很足，米饭给得实在，男生也吃得饱，下次还会点' AS content, '2026-10-02 17:21:23' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '份量对女生来说偏多，吃不完，下次还会点' AS content, '2026-10-23 19:11:29' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-10-27 13:44:13' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-10-23 11:58:26' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-10-20 18:23:38' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，整体还行' AS content, '2026-09-11 17:38:01' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '出餐很快，拿到手还是热的，下次还会点' AS content, '2026-09-13 18:32:15' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '荤素搭配合理，营养比较均衡，下次还会点' AS content, '2026-08-17 12:15:00' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '味道稳定，已经连吃三天了，下次还会点' AS content, '2026-08-24 11:29:25' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-09-11 12:55:33' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '肉给得很大方，师傅人也好，下次还会点' AS content, '2026-10-30 18:12:32' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-10-03 11:05:24' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，但希望能改进' AS content, '2026-09-13 19:34:49' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '配菜新鲜，整体满意，下次还会点' AS content, '2026-09-19 18:40:27' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '价格实惠，性价比高，常来吃，下次还会点' AS content, '2026-10-29 19:50:45' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-08-09 13:27:16' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-10-05 19:35:33' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-09-08 12:59:14' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-11-02 18:07:09' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '味道不错，就是油稍微大了点，有点失望' AS content, '2026-09-26 19:25:28' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点，有点失望' AS content, '2026-09-04 17:12:29' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 2 AS rating, '有点咸，下次希望能少放点盐，有点失望' AS content, '2026-09-03 18:18:27' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 2 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，有点失望' AS content, '2026-10-27 11:42:53' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 2 AS rating, '味道不错，就是油稍微大了点，不太推荐' AS content, '2026-08-14 18:52:55' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D003' AS code, 2 AS rating, '中午排队等了十几分钟，出餐可以再快点，不太推荐' AS content, '2026-08-08 17:11:50' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 1 AS rating, '有点咸，下次希望能少放点盐，不太推荐' AS content, '2026-11-02 11:03:18' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 1 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，不太推荐' AS content, '2026-09-06 17:38:05' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 1 AS rating, '味道不错，就是油稍微大了点，希望改进' AS content, '2026-08-09 18:51:15' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '整体不错，会推荐给室友，希望保持这个水准' AS content, '2026-10-08 12:43:12' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，希望保持这个水准' AS content, '2026-09-09 11:49:17' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，希望保持这个水准' AS content, '2026-08-31 12:28:47' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '出餐很快，拿到手还是热的，希望保持这个水准' AS content, '2026-09-18 11:43:31' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，希望保持这个水准' AS content, '2026-09-20 17:16:29' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '味道稳定，已经连吃三天了，希望保持这个水准' AS content, '2026-08-06 12:41:34' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '肉给得很大方，师傅人也好，希望保持这个水准' AS content, '2026-09-10 11:40:15' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '配菜新鲜，整体满意，希望保持这个水准' AS content, '2026-08-14 13:55:09' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，希望保持这个水准' AS content, '2026-08-23 18:53:22' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '整体不错，会推荐给室友，值得推荐' AS content, '2026-10-19 17:17:15' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，值得推荐' AS content, '2026-10-30 17:25:32' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，值得推荐' AS content, '2026-10-30 13:48:02' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '出餐很快，拿到手还是热的，值得推荐' AS content, '2026-10-22 17:15:13' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，值得推荐' AS content, '2026-10-24 17:16:06' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '味道稳定，已经连吃三天了，值得推荐' AS content, '2026-09-10 11:17:10' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '肉给得很大方，师傅人也好，值得推荐' AS content, '2026-08-12 11:27:49' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '配菜新鲜，整体满意，值得推荐' AS content, '2026-10-26 17:18:32' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-09-04 18:33:05' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-10-03 17:52:56' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-09-24 18:41:02' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-10-25 17:56:41' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-09-14 19:34:10' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-09-19 19:58:09' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点，有点失望' AS content, '2026-08-28 19:08:10' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，有点失望' AS content, '2026-09-11 19:36:14' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 2 AS rating, '有点咸，下次希望能少放点盐，有点失望' AS content, '2026-10-18 19:40:57' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 2 AS rating, '味道不错，就是油稍微大了点，有点失望' AS content, '2026-10-02 11:50:24' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 2 AS rating, '中午排队等了十几分钟，出餐可以再快点，不太推荐' AS content, '2026-09-20 17:35:27' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 2 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，不太推荐' AS content, '2026-08-25 13:35:21' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 1 AS rating, '有点咸，下次希望能少放点盐，不太推荐' AS content, '2026-09-16 17:10:23' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 1 AS rating, '味道不错，就是油稍微大了点，不太推荐' AS content, '2026-09-30 17:49:16' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 1 AS rating, '中午排队等了十几分钟，出餐可以再快点，希望改进' AS content, '2026-10-09 13:40:30' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-09-19 11:54:16' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-10-31 18:29:04' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-08-26 19:16:47' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-10-13 17:06:54' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-08-23 12:09:41' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-08-13 17:36:36' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '整体不错，会推荐给室友' AS content, '2026-10-09 18:24:40' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-09-02 13:12:57' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，整体很满意' AS content, '2026-10-25 17:31:16' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '肉给得很大方，师傅人也好，整体很满意' AS content, '2026-10-18 12:00:52' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，整体很满意' AS content, '2026-10-19 13:00:28' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '配菜新鲜，整体满意，整体很满意' AS content, '2026-09-07 17:24:01' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '味道稳定，已经连吃三天了，整体很满意' AS content, '2026-10-09 17:32:10' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '出餐很快，拿到手还是热的，整体很满意' AS content, '2026-09-15 11:05:37' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D004' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，整体很满意' AS content, '2026-08-08 19:49:22' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '整体不错，会推荐给室友，整体很满意' AS content, '2026-08-12 11:24:44' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，整体很满意' AS content, '2026-10-22 19:30:54' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，下次还会点' AS content, '2026-08-19 18:21:25' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '肉给得很大方，师傅人也好，下次还会点' AS content, '2026-08-06 12:33:44' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，下次还会点' AS content, '2026-10-27 11:19:35' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '配菜新鲜，整体满意，下次还会点' AS content, '2026-08-13 11:40:17' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '味道稳定，已经连吃三天了，下次还会点' AS content, '2026-09-23 13:54:26' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-08-18 18:47:52' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '出餐很快，拿到手还是热的，下次还会点' AS content, '2026-10-23 19:30:13' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '荤素搭配合理，营养比较均衡，下次还会点' AS content, '2026-09-27 11:36:45' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '整体不错，会推荐给室友，下次还会点' AS content, '2026-10-24 18:07:37' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-09-19 19:15:21' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，整体还行' AS content, '2026-08-26 18:25:12' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-08-10 11:03:38' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '价格实惠，性价比高，常来吃，下次还会点' AS content, '2026-10-29 13:05:45' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-09-07 13:52:02' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '分量很足，米饭给得实在，男生也吃得饱，希望保持这个水准' AS content, '2026-09-09 17:14:07' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，但希望能改进' AS content, '2026-10-31 19:58:58' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '肉给得很大方，师傅人也好，希望保持这个水准' AS content, '2026-10-10 13:00:40' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '份量对女生来说偏多，吃不完，希望保持这个水准' AS content, '2026-10-27 17:55:40' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，但希望能改进' AS content, '2026-09-29 11:07:59' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '口味偏淡，适合清淡党，但希望能改进' AS content, '2026-11-01 18:51:49' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，希望改进' AS content, '2026-08-23 11:57:53' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '有点咸，下次希望能少放点盐，希望改进' AS content, '2026-09-06 19:11:34' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '味道不错，就是油稍微大了点，希望改进' AS content, '2026-10-26 11:03:53' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点，下次可能不点了' AS content, '2026-09-18 19:45:59' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，下次可能不点了' AS content, '2026-10-05 18:03:21' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '有点咸，下次希望能少放点盐，下次可能不点了' AS content, '2026-09-25 17:44:51' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 2 AS rating, '味道不错，就是油稍微大了点，下次可能不点了' AS content, '2026-10-09 19:59:56' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 2 AS rating, '中午排队等了十几分钟，出餐可以再快点，体验一般' AS content, '2026-08-11 11:41:36' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-08-18 13:22:00' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-08-15 18:35:49' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-09-12 12:32:53' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-11-01 11:40:18' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-08-12 18:14:26' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-09-24 18:17:50' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '整体不错，会推荐给室友' AS content, '2026-10-15 11:20:27' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-10-14 13:13:54' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-10-29 19:25:57' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-10-30 19:26:36' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '价格实惠，性价比高，常来吃，整体很满意' AS content, '2026-09-29 19:34:45' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-09-09 18:35:57' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-10-08 19:23:13' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '配菜新鲜，整体满意，整体很满意' AS content, '2026-09-03 13:04:51' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-11-01 17:06:45' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '出餐很快，拿到手还是热的，整体很满意' AS content, '2026-09-20 12:33:05' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '味道稳定，已经连吃三天了，整体很满意' AS content, '2026-09-20 12:29:40' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，整体还行' AS content, '2026-10-23 17:26:13' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '份量对女生来说偏多，吃不完，整体很满意' AS content, '2026-10-29 18:42:12' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D005' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-08-31 17:21:34' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '肉给得很大方，师傅人也好，整体很满意' AS content, '2026-10-27 19:31:56' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '整体不错，会推荐给室友，整体很满意' AS content, '2026-09-04 12:26:15' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-10-12 12:45:55' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-11-01 17:11:27' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-09-06 12:13:07' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-10-11 13:25:58' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点，有点失望' AS content, '2026-09-26 19:00:38' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '有点咸，下次希望能少放点盐，有点失望' AS content, '2026-08-18 19:02:03' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 2 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，有点失望' AS content, '2026-10-23 18:07:50' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 2 AS rating, '味道不错，就是油稍微大了点，有点失望' AS content, '2026-10-20 17:40:09' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 2 AS rating, '中午排队等了十几分钟，出餐可以再快点，不太推荐' AS content, '2026-08-23 17:58:43' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 2 AS rating, '有点咸，下次希望能少放点盐，不太推荐' AS content, '2026-09-02 12:19:06' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 1 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，不太推荐' AS content, '2026-09-09 19:42:00' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 1 AS rating, '味道不错，就是油稍微大了点，不太推荐' AS content, '2026-10-26 13:38:24' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 1 AS rating, '中午排队等了十几分钟，出餐可以再快点，希望改进' AS content, '2026-08-06 13:22:20' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，整体很满意' AS content, '2026-09-02 18:04:06' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，整体很满意' AS content, '2026-09-04 19:21:05' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，下次还会点' AS content, '2026-09-21 11:29:52' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '配菜新鲜，整体满意，下次还会点' AS content, '2026-10-19 12:03:10' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '出餐很快，拿到手还是热的，下次还会点' AS content, '2026-08-07 18:14:47' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '味道稳定，已经连吃三天了，下次还会点' AS content, '2026-10-11 12:49:03' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，下次还会点' AS content, '2026-10-28 11:54:09' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '肉给得很大方，师傅人也好，下次还会点' AS content, '2026-10-04 11:27:30' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '整体不错，会推荐给室友，下次还会点' AS content, '2026-08-11 17:13:48' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，下次还会点' AS content, '2026-10-07 18:43:16' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，下次还会点' AS content, '2026-09-19 19:02:38' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，希望保持这个水准' AS content, '2026-09-23 13:02:36' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '配菜新鲜，整体满意，希望保持这个水准' AS content, '2026-08-09 12:51:52' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '出餐很快，拿到手还是热的，希望保持这个水准' AS content, '2026-10-04 19:05:00' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '味道稳定，已经连吃三天了，希望保持这个水准' AS content, '2026-08-05 17:38:08' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，希望保持这个水准' AS content, '2026-08-19 17:34:49' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '肉给得很大方，师傅人也好，希望保持这个水准' AS content, '2026-10-30 13:57:34' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '整体不错，会推荐给室友，希望保持这个水准' AS content, '2026-08-09 13:08:21' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，希望保持这个水准' AS content, '2026-10-13 13:57:16' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '分量偏少，一份不太够' AS content, '2026-08-08 13:23:36' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 2 AS rating, '有点老，梗比较硬' AS content, '2026-10-05 12:00:47' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 2 AS rating, '排队二十分钟，清炒时蔬不太值当' AS content, '2026-09-10 11:16:02' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 2 AS rating, '清炒时蔬味道不错，就是分量偏少' AS content, '2026-09-28 12:46:02' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 2 AS rating, '温度不太够，感觉放了有一会儿' AS content, '2026-08-28 12:25:32' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 1 AS rating, '好吃，就是清炒时蔬高峰期排队久' AS content, '2026-08-27 11:09:25' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 1 AS rating, '味道一般，清炒时蔬价格偏贵' AS content, '2026-10-14 11:20:07' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 1 AS rating, '分量偏少，一份不太够，有点失望' AS content, '2026-08-06 18:17:22' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '食堂里能吃到这个水平的清炒时蔬挺惊喜' AS content, '2026-10-26 12:42:54' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好' AS content, '2026-08-15 12:03:48' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '又干又柴，清炒时蔬不想吃第二次' AS content, '2026-10-23 18:35:39' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '面是坨的，清炒时蔬的汤也是凉的' AS content, '2026-09-11 11:20:14' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '这次清炒时蔬的肉有点发干，不入味' AS content, '2026-10-01 19:37:22' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '清淡健康，常点' AS content, '2026-09-26 13:32:23' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '清炒时蔬肉质很嫩，蘸料也地道' AS content, '2026-10-11 12:49:59' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D006' AS code, 5 AS rating, '清炒时蔬出品挺稳，偶尔肉会偏柴' AS content, '2026-08-19 19:58:11' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '整体满意，清炒时蔬价格稍微高一点' AS content, '2026-08-08 19:49:18' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '清炒时蔬算是普通盒饭水平' AS content, '2026-09-05 18:25:28' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '青菜很新鲜，颜色好看' AS content, '2026-09-20 19:26:01' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '在食堂能吃上这碗清炒时蔬挺满足的' AS content, '2026-08-19 12:01:15' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '总体满意，偶尔清炒时蔬的面会有点坨' AS content, '2026-08-05 19:36:04' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '今天的清炒时蔬汤底比较寡淡' AS content, '2026-10-27 11:45:19' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌' AS content, '2026-10-16 17:13:40' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '清炒时蔬的肉给得挺多，一个人吃完全够' AS content, '2026-10-18 13:40:40' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '面条筋道，清炒时蔬是师傅手工拉的' AS content, '2026-09-14 13:53:55' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '油不多，适合减脂' AS content, '2026-08-29 11:31:03' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '想吃面的时候随便来碗清炒时蔬' AS content, '2026-09-11 13:14:59' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '清炒时蔬的肉肥瘦相间，蜜汁调得正好' AS content, '2026-09-27 11:18:58' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '清炒时蔬不错，汤稍微淡了点' AS content, '2026-08-11 19:59:54' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '清炒时蔬的面有点煮过了，软塌塌的' AS content, '2026-08-17 13:21:55' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '还行，清炒时蔬没有很惊艳' AS content, '2026-09-13 11:08:08' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '每天都想吃清炒时蔬，可惜是限量的' AS content, '2026-08-11 12:45:41' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '分量确实少，男生吃清炒时蔬根本不够' AS content, '2026-10-14 12:16:56' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '清炒时蔬配的卤蛋入味，青菜也清爽' AS content, '2026-09-12 13:19:19' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '清炒时蔬好吃，配的青菜有点凉' AS content, '2026-08-17 12:14:57' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '清炒时蔬的面软了，口感不好' AS content, '2026-10-06 19:07:10' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '肉有点干，清炒时蔬不像现烤出来的口感' AS content, '2026-09-29 13:03:48' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '清炒时蔬浇头给得实在，不是清汤寡水' AS content, '2026-09-11 13:41:55' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '调味偏淡，但对身体好' AS content, '2026-10-09 17:47:56' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '冬天来一碗清炒时蔬特别舒服' AS content, '2026-09-25 17:55:03' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '希望多几种时令菜轮换' AS content, '2026-08-13 13:17:24' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '肉很正，就是清炒时蔬的饭给得少了点' AS content, '2026-09-19 11:59:07' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '性价比可以，希望清炒时蔬多几种浇头' AS content, '2026-08-23 17:02:48' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '面条口感好，清炒时蔬的肉给得少了些' AS content, '2026-09-25 18:51:58' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 4 AS rating, '还行，清炒时蔬没有很惊艳，整体还行' AS content, '2026-10-01 12:55:28' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '有点老，梗比较硬，有点失望' AS content, '2026-08-08 18:53:03' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '排队二十分钟，清炒时蔬不太值当，有点失望' AS content, '2026-08-29 19:17:11' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '清炒时蔬味道不错，就是分量偏少，有点失望' AS content, '2026-10-04 13:49:21' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿，有点失望' AS content, '2026-08-05 12:47:25' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '好吃，就是清炒时蔬高峰期排队久，有点失望' AS content, '2026-10-17 17:21:45' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '味道一般，清炒时蔬价格偏贵，有点失望' AS content, '2026-09-20 17:25:12' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 2 AS rating, '分量偏少，一份不太够，不太推荐' AS content, '2026-09-27 12:59:29' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 2 AS rating, '有点老，梗比较硬，不太推荐' AS content, '2026-09-09 19:43:39' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 2 AS rating, '排队二十分钟，清炒时蔬不太值当，不太推荐' AS content, '2026-10-21 19:52:26' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面条有嚼劲，比外面的馆子不差' AS content, '2026-08-21 19:55:01' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '汤底很鲜，喝着舒服' AS content, '2026-09-28 18:32:12' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '汤有点浑，看着不太清爽' AS content, '2026-08-24 11:32:53' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '香菇鸡丝面很下饭，配米饭能多来半碗' AS content, '2026-08-21 11:54:45' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜' AS content, '2026-08-07 17:27:16' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '加个卤蛋会更好' AS content, '2026-09-26 19:50:44' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '等了快二十分钟才拿到' AS content, '2026-08-13 18:34:39' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '价格小贵，香菇鸡丝面的量一般' AS content, '2026-09-28 13:50:23' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '不知道吃什么的时候就来点一份香菇鸡丝面' AS content, '2026-10-21 13:33:28' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '麻辣到位，香菇鸡丝面的米饭还要另算钱' AS content, '2026-08-08 18:17:04' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说' AS content, '2026-10-12 19:36:47' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D007' AS code, 4 AS rating, '香菇鸡丝面份量实在，师傅给肉很大方' AS content, '2026-09-14 18:05:33' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '师傅颠勺很利索，香菇鸡丝面出锅就端走' AS content, '2026-08-22 17:01:20' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '可以要求微辣，香菇鸡丝面对不吃辣的人也友好' AS content, '2026-08-29 19:58:05' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '汤里飘着一层油，有点腻' AS content, '2026-10-18 17:47:59' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '香菇鸡丝面的辣度不太稳定，时重时淡' AS content, '2026-08-18 13:09:03' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '价格合适，学生党友好' AS content, '2026-08-11 13:50:01' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '味道偏淡，需要自己加调料' AS content, '2026-08-10 19:37:45' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 3 AS rating, '有点咸，下次少放点盐' AS content, '2026-08-23 11:58:20' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 3 AS rating, '端上来就凉了，希望能保温' AS content, '2026-09-29 19:25:24' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 3 AS rating, '面条煮得有点过，坨了' AS content, '2026-08-05 13:31:35' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 3 AS rating, '分量偏少，一碗没吃饱' AS content, '2026-09-24 17:25:29' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 3 AS rating, '有点咸，下次少放点盐，有点失望' AS content, '2026-08-25 11:57:33' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 3 AS rating, '端上来就凉了，希望能保温，有点失望' AS content, '2026-10-13 19:03:47' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 2 AS rating, '面条煮得有点过，坨了，有点失望' AS content, '2026-09-22 18:03:46' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 2 AS rating, '分量偏少，一碗没吃饱，有点失望' AS content, '2026-08-29 11:53:13' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 2 AS rating, '有点咸，下次少放点盐，不太推荐' AS content, '2026-10-15 18:23:52' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 2 AS rating, '端上来就凉了，希望能保温，不太推荐' AS content, '2026-10-25 13:53:42' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 1 AS rating, '面条煮得有点过，坨了，不太推荐' AS content, '2026-08-24 13:17:38' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 1 AS rating, '分量偏少，一碗没吃饱，不太推荐' AS content, '2026-09-26 19:52:37' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 1 AS rating, '有点咸，下次少放点盐，希望改进' AS content, '2026-11-01 11:04:58' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '配料给得实在，牛肉块也不小' AS content, '2026-09-03 12:01:14' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面条是手擀的，口感很好' AS content, '2026-08-08 12:34:23' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '加辣很带劲，推荐重口的试试' AS content, '2026-08-16 11:28:57' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '香菇鸡丝面锅气很足，现炒出来的就是香' AS content, '2026-09-23 11:41:12' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '麻辣鲜香，香菇鸡丝面在食堂里算做得好的了' AS content, '2026-09-05 11:20:29' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '汤头浓郁，喝到见底' AS content, '2026-09-09 11:29:52' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '分量足，一碗吃得很饱' AS content, '2026-09-19 12:56:50' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面条断得比较多，碎' AS content, '2026-09-27 19:43:45' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '香菜给得太多，盖过了面的味道' AS content, '2026-08-25 11:04:58' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面条粘成一团，拌不开' AS content, '2026-11-01 17:29:04' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面汤温度刚好，冬天吃很舒服' AS content, '2026-08-27 19:29:22' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '整体稳定，每周会来两三次' AS content, '2026-10-13 18:37:35' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '出餐快，热乎的' AS content, '2026-09-17 12:37:02' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '挺下饭的，香菇鸡丝面稍微咸了一点点' AS content, '2026-08-19 13:31:29' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '香菇鸡丝面感觉炒过头了，菜都蔫了' AS content, '2026-09-30 12:51:09' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '香菇鸡丝面好吃，就是辣度对我来说有点顶' AS content, '2026-09-18 18:48:53' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '碗太大汤太少，比例奇怪' AS content, '2026-10-26 13:56:19' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面条劲道，汤头不错' AS content, '2026-10-04 11:56:05' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '早上去人少，出餐特别快' AS content, '2026-09-01 17:53:41' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '葱花撒得均匀，卖相不错' AS content, '2026-09-18 17:01:39' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面条有嚼劲，比外面的馆子不差，整体很满意' AS content, '2026-10-25 19:32:29' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '汤底很鲜，喝着舒服，整体很满意' AS content, '2026-09-10 13:50:48' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '面有点硬，像是没煮透' AS content, '2026-08-15 11:35:24' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，整体还行' AS content, '2026-09-05 19:07:48' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '汤有点浑，看着不太清爽，整体很满意' AS content, '2026-08-24 13:34:27' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '价格小贵，香菇鸡丝面的量一般，整体还行' AS content, '2026-10-21 19:46:43' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '香菇鸡丝面很下饭，配米饭能多来半碗，整体很满意' AS content, '2026-10-14 12:37:25' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，整体还行' AS content, '2026-10-14 19:35:42' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '加个卤蛋会更好，整体很满意' AS content, '2026-10-02 18:59:43' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '香菇鸡丝面的辣度不太稳定，时重时淡，整体还行' AS content, '2026-10-28 11:44:03' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D007' AS code, 4 AS rating, '味道偏淡，需要自己加调料，整体还行' AS content, '2026-08-27 13:50:40' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '等了快二十分钟才拿到，整体很满意' AS content, '2026-08-16 17:07:05' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '面有点硬，像是没煮透，整体还行' AS content, '2026-09-27 11:54:30' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，但希望能改进' AS content, '2026-08-21 18:54:01' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '勺子有点小，捞料不太方便' AS content, '2026-08-15 17:30:48' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '香菜味太重，不吃香菜的慎点' AS content, '2026-09-22 17:35:57' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '想吃面的时候随便来碗菌菇汤' AS content, '2026-08-10 18:38:36' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '整整一碗都喝完了，很满足' AS content, '2026-08-25 11:11:40' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '稍微有点油花，不碍事' AS content, '2026-09-03 18:49:46' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '汤色清亮，看着干净' AS content, '2026-09-29 18:30:43' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '料有点少，主要是汤' AS content, '2026-10-29 18:07:20' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '味道稳定，每次水平差不多' AS content, '2026-09-29 19:10:03' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '份量偏小，几口就见底了' AS content, '2026-09-10 13:31:39' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '价格便宜，性价比高' AS content, '2026-08-24 17:17:37' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '汤面飘着葱花，看着有食欲' AS content, '2026-08-17 17:29:57' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '温度刚好，暖胃' AS content, '2026-09-12 12:37:27' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '汤里料很实在，不止是清汤' AS content, '2026-11-02 18:52:46' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '汤和料的比例有点失衡' AS content, '2026-08-30 19:31:45' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '喝完不口干，说明味精不多' AS content, '2026-09-08 17:36:56' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '上得很快，配饭刚好' AS content, '2026-08-17 13:54:10' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '料切的块有点大，不太好舀' AS content, '2026-10-27 13:55:02' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '汤是温的，不够热' AS content, '2026-10-10 18:16:10' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '端过来的时候碗沿有点烫手' AS content, '2026-08-12 18:14:03' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '料给得足，捞得到东西' AS content, '2026-09-19 19:38:35' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '汤底很鲜，饭前喝一碗很舒服' AS content, '2026-08-25 18:03:12' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '面条口感好，菌菇汤的肉给得少了些' AS content, '2026-09-10 12:39:45' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '汤有点浑浊，不像现熬的' AS content, '2026-09-10 12:42:15' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '希望能加个配汤的面包或馒头' AS content, '2026-10-19 13:02:25' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '菌菇的香味很浓，喝完很舒服' AS content, '2026-10-26 12:53:12' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '冬天喝这个很治愈' AS content, '2026-10-30 12:38:24' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '比想象中清淡，适合减脂期' AS content, '2026-11-01 11:33:25' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '面条口感好，菌菇汤的肉给得少了些，整体还行' AS content, '2026-10-09 18:38:29' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '希望能加个配汤的面包或馒头，整体还行' AS content, '2026-08-25 12:16:42' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '分量足，一碗喝得很满足' AS content, '2026-08-12 19:58:16' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '味道清淡，适合搭配主食' AS content, '2026-10-12 18:36:46' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '面条口感好，菌菇汤的肉给得少了些，但希望能改进' AS content, '2026-08-27 11:55:39' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '勺子有点小，捞料不太方便，整体很满意' AS content, '2026-08-09 12:10:46' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '希望能加个配汤的面包或馒头，但希望能改进' AS content, '2026-10-21 12:07:39' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '面条口感好，菌菇汤的肉给得少了些，不功不过' AS content, '2026-08-15 18:37:37' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '香菜味太重，不吃香菜的慎点，整体很满意' AS content, '2026-09-21 19:42:12' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 3 AS rating, '偶尔会有点咸，不太稳定' AS content, '2026-11-02 17:20:54' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 3 AS rating, '有点咸，希望淡一点' AS content, '2026-10-04 11:15:41' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 3 AS rating, '喝到最后有点咸' AS content, '2026-09-23 11:17:34' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 3 AS rating, '偶尔会有点咸，不太稳定，有点失望' AS content, '2026-09-12 17:59:56' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 3 AS rating, '有点咸，希望淡一点，有点失望' AS content, '2026-08-23 17:28:10' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 3 AS rating, '喝到最后有点咸，有点失望' AS content, '2026-08-10 13:33:33' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 2 AS rating, '偶尔会有点咸，不太稳定，不太推荐' AS content, '2026-08-25 18:32:43' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 2 AS rating, '有点咸，希望淡一点，不太推荐' AS content, '2026-09-07 13:33:09' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 2 AS rating, '喝到最后有点咸，不太推荐' AS content, '2026-08-27 11:16:24' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 2 AS rating, '偶尔会有点咸，不太稳定，希望改进' AS content, '2026-10-08 19:33:47' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D008' AS code, 1 AS rating, '有点咸，希望淡一点，希望改进' AS content, '2026-09-21 19:17:28' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 1 AS rating, '喝到最后有点咸，希望改进' AS content, '2026-10-19 11:31:19' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '想吃面的时候随便来碗菌菇汤，整体很满意' AS content, '2026-08-21 11:59:36' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '整整一碗都喝完了，很满足，整体很满意' AS content, '2026-09-26 12:47:06' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '稍微有点油花，不碍事，整体很满意' AS content, '2026-09-29 13:03:06' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '汤色清亮，看着干净，整体很满意' AS content, '2026-10-25 12:09:16' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '料有点少，主要是汤，整体很满意' AS content, '2026-10-22 19:23:47' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '味道稳定，每次水平差不多，整体很满意' AS content, '2026-08-13 18:58:32' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '价格小贵，红烧排骨的量一般' AS content, '2026-09-07 13:14:48' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '师傅颠勺很利索，红烧排骨出锅就端走' AS content, '2026-09-26 13:56:26' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '红烧排骨的辣度不太稳定，时重时淡' AS content, '2026-09-03 12:12:20' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定' AS content, '2026-10-29 18:57:24' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '肉炖得很烂，入口即化' AS content, '2026-09-03 17:13:25' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '价格小贵，红烧排骨的量一般，整体还行' AS content, '2026-10-04 13:36:55' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '麻辣鲜香，红烧排骨在食堂里算做得好的了' AS content, '2026-09-08 11:04:51' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '酱汁很下饭，能多来半碗饭' AS content, '2026-09-19 12:17:55' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '红烧排骨锅气很足，现炒出来的就是香' AS content, '2026-09-19 19:19:45' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 3 AS rating, '分量一般，价格偏贵了点' AS content, '2026-09-12 13:32:41' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 3 AS rating, '味道正宗，就是等的时间长' AS content, '2026-09-18 13:20:28' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 3 AS rating, '有点咸，配米饭刚好' AS content, '2026-09-07 13:55:57' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 3 AS rating, '今天这份有点凉了，希望保温做好' AS content, '2026-10-02 13:32:38' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 3 AS rating, '给的骨头偏多，肉少了些' AS content, '2026-09-29 18:14:04' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 3 AS rating, '分量一般，价格偏贵了点，有点失望' AS content, '2026-08-09 18:50:37' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 2 AS rating, '味道正宗，就是等的时间长，有点失望' AS content, '2026-08-05 13:59:54' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 2 AS rating, '有点咸，配米饭刚好，有点失望' AS content, '2026-10-15 17:44:15' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 2 AS rating, '今天这份有点凉了，希望保温做好，有点失望' AS content, '2026-10-18 19:55:06' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 2 AS rating, '给的骨头偏多，肉少了些，有点失望' AS content, '2026-08-07 17:52:20' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 1 AS rating, '分量一般，价格偏贵了点，不太推荐' AS content, '2026-09-12 13:45:48' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 1 AS rating, '味道正宗，就是等的时间长，不太推荐' AS content, '2026-08-15 12:26:01' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '不知道吃什么的时候就来点一份红烧排骨' AS content, '2026-09-04 17:36:17' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '颜色好看，看着就有食欲' AS content, '2026-08-25 13:50:03' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '挺下饭的，红烧排骨稍微咸了一点点' AS content, '2026-09-29 17:19:05' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '红烧排骨份量实在，师傅给肉很大方' AS content, '2026-09-18 12:55:21' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '现炒很香，就是红烧排骨高峰期要等七八分钟' AS content, '2026-10-28 18:58:17' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '肥瘦相间，不腻' AS content, '2026-08-09 19:23:41' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '炖得入味，比外面的还香' AS content, '2026-08-26 13:46:00' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '可以要求微辣，红烧排骨对不吃辣的人也友好' AS content, '2026-09-23 12:41:19' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '红烧排骨很下饭，配米饭能多来半碗' AS content, '2026-10-19 11:15:14' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '味道可以，但红烧排骨没第一次惊艳' AS content, '2026-08-26 13:16:29' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '师傅颠勺很利索，红烧排骨出锅就端走，整体很满意' AS content, '2026-08-05 12:36:33' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '肉炖得很烂，入口即化，整体很满意' AS content, '2026-10-06 19:35:19' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '麻辣鲜香，红烧排骨在食堂里算做得好的了，整体很满意' AS content, '2026-08-08 18:06:59' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '酱汁很下饭，能多来半碗饭，整体很满意' AS content, '2026-10-23 12:24:54' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '红烧排骨锅气很足，现炒出来的就是香，整体很满意' AS content, '2026-09-18 18:55:04' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '不知道吃什么的时候就来点一份红烧排骨，整体很满意' AS content, '2026-10-02 18:30:36' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '颜色好看，看着就有食欲，整体很满意' AS content, '2026-09-18 18:40:30' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '挺下饭的，红烧排骨稍微咸了一点点，整体很满意' AS content, '2026-09-23 18:20:50' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '红烧排骨份量实在，师傅给肉很大方，整体很满意' AS content, '2026-10-29 19:44:50' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '现炒很香，就是红烧排骨高峰期要等七八分钟，整体很满意' AS content, '2026-09-13 12:40:59' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '肥瘦相间，不腻，整体很满意' AS content, '2026-08-15 13:36:32' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D009' AS code, 5 AS rating, '炖得入味，比外面的还香，整体很满意' AS content, '2026-09-28 19:41:53' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 5 AS rating, '可以要求微辣，红烧排骨对不吃辣的人也友好，整体很满意' AS content, '2026-09-04 13:09:46' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '红烧排骨很下饭，配米饭能多来半碗，整体很满意' AS content, '2026-10-27 18:52:29' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '味道可以，但红烧排骨没第一次惊艳，整体很满意' AS content, '2026-10-07 12:16:32' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '师傅颠勺很利索，红烧排骨出锅就端走，下次还会点' AS content, '2026-08-26 17:13:45' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '红烧排骨的辣度不太稳定，时重时淡，整体还行' AS content, '2026-10-27 18:52:00' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，整体还行' AS content, '2026-10-11 13:59:57' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '肉炖得很烂，入口即化，下次还会点' AS content, '2026-09-07 17:37:22' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '价格小贵，红烧排骨的量一般，但希望能改进' AS content, '2026-09-04 17:46:47' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '麻辣鲜香，红烧排骨在食堂里算做得好的了，下次还会点' AS content, '2026-09-07 13:14:02' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '红烧排骨的辣度不太稳定，时重时淡，但希望能改进' AS content, '2026-10-30 13:10:41' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，但希望能改进' AS content, '2026-08-18 17:16:22' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '酱汁很下饭，能多来半碗饭，下次还会点' AS content, '2026-08-10 19:15:39' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '价格小贵，红烧排骨的量一般，不功不过' AS content, '2026-09-19 11:48:15' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '红烧排骨锅气很足，现炒出来的就是香，下次还会点' AS content, '2026-10-09 12:05:01' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '不知道吃什么的时候就来点一份红烧排骨，下次还会点' AS content, '2026-08-27 19:31:34' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '清淡健康，常点' AS content, '2026-10-22 11:57:15' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜蓉西兰花好吃，就是辣度对我来说有点顶' AS content, '2026-09-08 19:48:48' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好' AS content, '2026-10-24 13:52:05' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '油不多，适合减脂' AS content, '2026-08-28 13:45:41' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌' AS content, '2026-09-16 13:21:17' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜蓉西兰花份量实在，师傅给肉很大方' AS content, '2026-09-24 19:31:20' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '青菜很新鲜，颜色好看' AS content, '2026-09-22 18:11:11' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '清淡健康，常点，整体很满意' AS content, '2026-08-30 11:40:29' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜蓉西兰花好吃，就是辣度对我来说有点顶，整体很满意' AS content, '2026-08-18 17:15:16' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，整体很满意' AS content, '2026-08-13 17:59:22' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '油不多，适合减脂，整体很满意' AS content, '2026-10-01 18:44:33' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，整体很满意' AS content, '2026-10-21 19:09:47' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜蓉西兰花份量实在，师傅给肉很大方，整体很满意' AS content, '2026-10-28 18:33:13' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '青菜很新鲜，颜色好看，整体很满意' AS content, '2026-08-29 18:40:04' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '清淡健康，常点，下次还会点' AS content, '2026-10-15 11:43:42' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '蒜蓉西兰花好吃，就是辣度对我来说有点顶，下次还会点' AS content, '2026-08-31 18:59:10' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '调味偏淡，但对身体好' AS content, '2026-09-22 18:27:12' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '蔬菜很嫩，火候掌握得好，下次还会点' AS content, '2026-09-23 11:38:10' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '希望多几种时令菜轮换' AS content, '2026-09-28 19:48:55' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '调味偏淡，但对身体好，整体还行' AS content, '2026-08-05 12:45:11' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '希望多几种时令菜轮换，整体还行' AS content, '2026-09-25 11:09:42' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '调味偏淡，但对身体好，但希望能改进' AS content, '2026-08-25 13:08:33' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '油不多，适合减脂，下次还会点' AS content, '2026-09-26 17:29:33' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '蒜香味足，炒得刚好不塌，下次还会点' AS content, '2026-09-09 11:27:49' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '希望多几种时令菜轮换，但希望能改进' AS content, '2026-10-03 17:32:52' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '调味偏淡，但对身体好，不功不过' AS content, '2026-09-27 13:58:06' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '蒜蓉西兰花份量实在，师傅给肉很大方，下次还会点' AS content, '2026-08-25 11:31:58' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '青菜很新鲜，颜色好看，下次还会点' AS content, '2026-08-23 19:49:58' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '希望多几种时令菜轮换，不功不过' AS content, '2026-09-29 12:13:15' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '清淡健康，常点，希望保持这个水准' AS content, '2026-08-09 11:19:13' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿' AS content, '2026-09-05 17:05:18' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 3 AS rating, '分量偏少，一份不太够' AS content, '2026-10-28 11:51:45' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 3 AS rating, '有点老，梗比较硬' AS content, '2026-08-12 11:15:06' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿，有点失望' AS content, '2026-10-02 19:08:13' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D010' AS code, 3 AS rating, '分量偏少，一份不太够，有点失望' AS content, '2026-09-28 18:24:52' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 3 AS rating, '有点老，梗比较硬，有点失望' AS content, '2026-08-09 11:08:04' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 2 AS rating, '温度不太够，感觉放了有一会儿，不太推荐' AS content, '2026-09-18 18:34:34' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 2 AS rating, '分量偏少，一份不太够，不太推荐' AS content, '2026-09-24 13:50:58' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 2 AS rating, '有点老，梗比较硬，不太推荐' AS content, '2026-10-06 17:34:46' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 2 AS rating, '温度不太够，感觉放了有一会儿，希望改进' AS content, '2026-10-16 18:02:13' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 1 AS rating, '分量偏少，一份不太够，希望改进' AS content, '2026-08-19 13:43:08' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 1 AS rating, '有点老，梗比较硬，希望改进' AS content, '2026-09-27 19:47:58' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜蓉西兰花好吃，就是辣度对我来说有点顶，希望保持这个水准' AS content, '2026-08-31 18:15:22' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，希望保持这个水准' AS content, '2026-09-10 19:53:04' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '油不多，适合减脂，希望保持这个水准' AS content, '2026-08-08 12:54:55' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，希望保持这个水准' AS content, '2026-09-01 19:30:24' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜蓉西兰花份量实在，师傅给肉很大方，希望保持这个水准' AS content, '2026-10-20 12:28:56' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '青菜很新鲜，颜色好看，希望保持这个水准' AS content, '2026-08-22 19:42:17' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '清淡健康，常点，值得推荐' AS content, '2026-08-22 13:32:32' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜蓉西兰花好吃，就是辣度对我来说有点顶，值得推荐' AS content, '2026-10-08 17:40:47' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，值得推荐' AS content, '2026-10-11 18:09:59' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '油不多，适合减脂，值得推荐' AS content, '2026-10-01 11:34:43' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，值得推荐' AS content, '2026-08-10 19:30:32' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜蓉西兰花份量实在，师傅给肉很大方，值得推荐' AS content, '2026-10-18 17:18:57' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '青菜很新鲜，颜色好看，值得推荐' AS content, '2026-10-29 13:36:03' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '清淡健康，常点，室友也觉得不错' AS content, '2026-08-18 18:23:19' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜蓉西兰花好吃，就是辣度对我来说有点顶，室友也觉得不错' AS content, '2026-08-05 18:22:06' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，室友也觉得不错' AS content, '2026-10-24 18:36:47' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '油不多，适合减脂，室友也觉得不错' AS content, '2026-08-10 11:27:56' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，室友也觉得不错' AS content, '2026-08-18 13:31:50' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜蓉西兰花份量实在，师傅给肉很大方，室友也觉得不错' AS content, '2026-09-27 17:47:39' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '青菜很新鲜，颜色好看，室友也觉得不错' AS content, '2026-10-16 17:12:17' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '清淡健康，常点，会安利给同学' AS content, '2026-10-14 19:51:43' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜蓉西兰花好吃，就是辣度对我来说有点顶，会安利给同学' AS content, '2026-09-09 17:23:45' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，会安利给同学' AS content, '2026-10-26 11:46:25' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '油不多，适合减脂，会安利给同学' AS content, '2026-08-26 12:53:58' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 3 AS rating, '有点太甜了，希望能选无糖' AS content, '2026-10-14 13:00:32' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 3 AS rating, '量有点少，价格可以再低点' AS content, '2026-08-19 19:39:22' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 3 AS rating, '有点太甜了，希望能选无糖，有点失望' AS content, '2026-08-29 17:15:39' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 2 AS rating, '量有点少，价格可以再低点，有点失望' AS content, '2026-10-22 19:08:14' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 2 AS rating, '有点太甜了，希望能选无糖，不太推荐' AS content, '2026-09-26 17:40:05' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 2 AS rating, '量有点少，价格可以再低点，不太推荐' AS content, '2026-09-27 17:46:41' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 2 AS rating, '有点太甜了，希望能选无糖，希望改进' AS content, '2026-09-02 19:55:09' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 1 AS rating, '量有点少，价格可以再低点，希望改进' AS content, '2026-09-29 11:14:03' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 1 AS rating, '有点太甜了，希望能选无糖，下次可能不点了' AS content, '2026-10-12 11:33:45' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '冰的量很足，夏天喝着爽' AS content, '2026-08-05 17:42:48' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '甜度控制得不错，不会太腻' AS content, '2026-10-25 18:55:39' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '价格便宜，解渴' AS content, '2026-10-25 11:19:07' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '杯子偏小，几口就没了' AS content, '2026-10-10 19:23:37' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '喝着清爽，饭后解腻' AS content, '2026-10-31 12:50:06' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '口味稳定，常买' AS content, '2026-10-24 19:41:08' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '包装干净，吸管给得很到位' AS content, '2026-09-03 19:19:59' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '温度合适，不会太冰' AS content, '2026-09-01 12:47:20' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '冰的量很足，夏天喝着爽，整体很满意' AS content, '2026-10-30 19:28:05' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D011' AS code, 5 AS rating, '甜度控制得不错，不会太腻，整体很满意' AS content, '2026-10-08 12:22:11' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '价格便宜，解渴，整体很满意' AS content, '2026-10-09 12:15:48' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '杯子偏小，几口就没了，整体很满意' AS content, '2026-10-02 18:41:58' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '喝着清爽，饭后解腻，整体很满意' AS content, '2026-09-07 18:27:02' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '口味稳定，常买，整体很满意' AS content, '2026-10-30 12:58:08' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '包装干净，吸管给得很到位，整体很满意' AS content, '2026-08-31 11:13:48' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '温度合适，不会太冰，整体很满意' AS content, '2026-09-30 19:58:11' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '冰的量很足，夏天喝着爽，下次还会点' AS content, '2026-09-22 11:46:38' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '甜度控制得不错，不会太腻，下次还会点' AS content, '2026-09-29 12:15:07' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '价格便宜，解渴，下次还会点' AS content, '2026-10-21 11:44:41' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '杯子偏小，几口就没了，下次还会点' AS content, '2026-08-30 12:13:20' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '喝着清爽，饭后解腻，下次还会点' AS content, '2026-08-21 13:38:16' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '口味稳定，常买，下次还会点' AS content, '2026-09-21 17:14:47' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '包装干净，吸管给得很到位，下次还会点' AS content, '2026-10-23 19:22:08' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '温度合适，不会太冰，下次还会点' AS content, '2026-10-07 18:20:41' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '冰的量很足，夏天喝着爽，希望保持这个水准' AS content, '2026-09-23 12:20:46' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '甜度控制得不错，不会太腻，希望保持这个水准' AS content, '2026-10-22 18:28:35' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '价格便宜，解渴，希望保持这个水准' AS content, '2026-08-07 17:00:02' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '杯子偏小，几口就没了，希望保持这个水准' AS content, '2026-08-23 18:29:05' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '喝着清爽，饭后解腻，希望保持这个水准' AS content, '2026-10-01 18:12:37' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '口味稳定，常买，希望保持这个水准' AS content, '2026-09-03 11:18:35' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '包装干净，吸管给得很到位，希望保持这个水准' AS content, '2026-10-27 17:41:26' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '温度合适，不会太冰，希望保持这个水准' AS content, '2026-08-12 18:54:04' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '冰的量很足，夏天喝着爽，值得推荐' AS content, '2026-08-18 19:28:18' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '甜度控制得不错，不会太腻，值得推荐' AS content, '2026-08-19 17:17:06' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '价格便宜，解渴，值得推荐' AS content, '2026-09-06 12:19:06' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '杯子偏小，几口就没了，值得推荐' AS content, '2026-10-23 19:22:58' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '喝着清爽，饭后解腻，值得推荐' AS content, '2026-09-25 19:44:52' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '口味稳定，常买，值得推荐' AS content, '2026-09-18 13:19:10' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 3 AS rating, '量有点少，价格可以再低点，下次可能不点了' AS content, '2026-09-18 12:45:41' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 3 AS rating, '有点太甜了，希望能选无糖，体验一般' AS content, '2026-08-30 19:48:49' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 3 AS rating, '量有点少，价格可以再低点，体验一般' AS content, '2026-08-05 12:25:18' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '包装干净，吸管给得很到位' AS content, '2026-09-18 17:10:07' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '肉很正，就是无糖豆浆的饭给得少了点' AS content, '2026-10-07 13:55:39' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '肉有股怪味，无糖豆浆不太新鲜' AS content, '2026-09-21 18:51:23' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '无糖豆浆的肉给得挺多，一个人吃完全够' AS content, '2026-10-26 11:58:27' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '冰的量很足，夏天喝着爽' AS content, '2026-10-24 17:42:21' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '喝着清爽，饭后解腻' AS content, '2026-09-22 11:02:08' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '无糖豆浆算是普通盒饭水平' AS content, '2026-08-11 18:38:49' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '甜度控制得不错，不会太腻' AS content, '2026-08-06 18:13:52' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '每天都想吃无糖豆浆，可惜是限量的' AS content, '2026-09-14 11:23:59' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '杯子偏小，几口就没了' AS content, '2026-08-09 17:42:44' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '无糖豆浆出品挺稳，偶尔肉会偏柴' AS content, '2026-08-19 19:10:35' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '无糖豆浆配的卤蛋入味，青菜也清爽' AS content, '2026-09-28 13:05:49' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '整体满意，无糖豆浆价格稍微高一点' AS content, '2026-08-26 13:22:41' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '温度合适，不会太冰' AS content, '2026-08-22 17:44:15' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '无糖豆浆好吃，配的青菜有点凉' AS content, '2026-09-21 19:21:36' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '价格便宜，解渴' AS content, '2026-09-18 11:52:00' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '无糖豆浆好吃，配的青菜有点凉，整体还行' AS content, '2026-08-29 18:15:18' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '无糖豆浆好吃，配的青菜有点凉，但希望能改进' AS content, '2026-09-04 18:28:45' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D012' AS code, 4 AS rating, '这次无糖豆浆的肉有点发干，不入味' AS content, '2026-10-04 17:48:43' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '无糖豆浆好吃，配的青菜有点凉，不功不过' AS content, '2026-08-15 12:16:37' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '无糖豆浆好吃，配的青菜有点凉，还可以再优化' AS content, '2026-09-18 19:36:28' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '口味稳定，常买' AS content, '2026-08-10 11:12:43' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '有点太甜了，希望能选无糖' AS content, '2026-10-01 18:45:17' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '味道一般，无糖豆浆价格偏贵' AS content, '2026-10-21 11:23:29' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '量有点少，价格可以再低点' AS content, '2026-09-12 19:29:13' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '有点太甜了，希望能选无糖，有点失望' AS content, '2026-10-08 11:45:52' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '味道一般，无糖豆浆价格偏贵，有点失望' AS content, '2026-08-18 12:15:57' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '量有点少，价格可以再低点，有点失望' AS content, '2026-08-17 12:53:17' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 2 AS rating, '有点太甜了，希望能选无糖，不太推荐' AS content, '2026-09-12 19:33:44' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 2 AS rating, '味道一般，无糖豆浆价格偏贵，不太推荐' AS content, '2026-10-05 11:50:29' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 2 AS rating, '量有点少，价格可以再低点，不太推荐' AS content, '2026-09-17 17:01:50' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 2 AS rating, '有点太甜了，希望能选无糖，希望改进' AS content, '2026-09-18 18:19:59' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 1 AS rating, '味道一般，无糖豆浆价格偏贵，希望改进' AS content, '2026-10-02 19:15:37' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 1 AS rating, '量有点少，价格可以再低点，希望改进' AS content, '2026-08-13 19:05:59' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '无糖豆浆的肉肥瘦相间，蜜汁调得正好' AS content, '2026-10-01 18:46:03' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '包装干净，吸管给得很到位，整体很满意' AS content, '2026-08-18 13:02:30' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '肉很正，就是无糖豆浆的饭给得少了点，整体很满意' AS content, '2026-10-23 17:35:41' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '肉有股怪味，无糖豆浆不太新鲜，整体很满意' AS content, '2026-09-08 11:29:02' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '无糖豆浆的肉给得挺多，一个人吃完全够，整体很满意' AS content, '2026-08-21 11:39:06' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '冰的量很足，夏天喝着爽，整体很满意' AS content, '2026-08-16 11:24:24' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '喝着清爽，饭后解腻，整体很满意' AS content, '2026-10-04 13:08:55' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '无糖豆浆算是普通盒饭水平，整体很满意' AS content, '2026-10-18 12:20:18' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '甜度控制得不错，不会太腻，整体很满意' AS content, '2026-08-21 13:19:23' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '每天都想吃无糖豆浆，可惜是限量的，整体很满意' AS content, '2026-10-14 19:11:59' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '杯子偏小，几口就没了，整体很满意' AS content, '2026-10-05 12:37:22' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '无糖豆浆出品挺稳，偶尔肉会偏柴，整体很满意' AS content, '2026-08-26 18:42:29' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '无糖豆浆配的卤蛋入味，青菜也清爽，整体很满意' AS content, '2026-08-18 18:58:07' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '整体满意，无糖豆浆价格稍微高一点，整体很满意' AS content, '2026-08-10 12:30:41' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '温度合适，不会太冰，整体很满意' AS content, '2026-08-19 19:52:14' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '价格便宜，解渴，整体很满意' AS content, '2026-08-30 11:28:31' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '这次无糖豆浆的肉有点发干，不入味，整体很满意' AS content, '2026-10-05 18:54:37' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '口味稳定，常买，整体很满意' AS content, '2026-11-01 11:19:04' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '无糖豆浆的肉肥瘦相间，蜜汁调得正好，整体很满意' AS content, '2026-09-30 17:41:45' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '包装干净，吸管给得很到位，下次还会点' AS content, '2026-10-11 13:21:28' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '肉很正，就是无糖豆浆的饭给得少了点，下次还会点' AS content, '2026-08-29 12:11:38' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '肉有股怪味，无糖豆浆不太新鲜，下次还会点' AS content, '2026-08-21 18:04:09' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '无糖豆浆的肉给得挺多，一个人吃完全够，下次还会点' AS content, '2026-10-29 18:26:23' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '冰的量很足，夏天喝着爽，下次还会点' AS content, '2026-10-29 11:41:04' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '喝着清爽，饭后解腻，下次还会点' AS content, '2026-10-05 18:59:17' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '无糖豆浆算是普通盒饭水平，下次还会点' AS content, '2026-10-31 17:59:10' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '甜度控制得不错，不会太腻，下次还会点' AS content, '2026-09-06 18:09:49' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '每天都想吃无糖豆浆，可惜是限量的，下次还会点' AS content, '2026-10-11 11:17:37' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

-- 回填菜品评分聚合
UPDATE dish d SET
  avg_rating = COALESCE((SELECT ROUND(AVG(r.rating), 1) FROM dish_review r WHERE r.dish_id = d.id AND r.status = 'APPROVED'), 0),
  review_count = (SELECT COUNT(*) FROM dish_review r WHERE r.dish_id = d.id AND r.status = 'APPROVED');

SELECT d.dish_code, d.name, d.avg_rating, d.review_count
FROM dish d WHERE d.deleted = 0 ORDER BY d.dish_code;

SELECT rating AS star, COUNT(*) AS cnt,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dish_review), 1) AS pct
FROM dish_review GROUP BY rating ORDER BY rating DESC;
