-- =============================================================
-- seed-dish-reviews.sql
-- 来源：参考项目 canteen-feedback-system 的中文评价语料
-- 生成脚本：tools/seed_reviews2.py（幂等，可重复执行）
--
-- 共 1228 条评价，覆盖 44 道菜
-- 评分分布：5星45%% / 4星30%% / 3星12%% / 2星8%% / 1星5%%
-- 评语情感与星级匹配；时间重分布到今天往前 90 天
-- 重置数据请先执行 db/reset-dish-reviews.sql
-- =============================================================

SET NAMES utf8mb4;

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D001' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-10-22 17:55:31' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-09-06 19:10:50' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-08-08 17:18:16' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-11-01 11:38:55' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '铁板很烫，端上来还在响' AS content, '2026-09-01 12:57:35' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-10-12 17:52:11' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-10-20 11:03:08' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-08-24 19:04:58' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-10-13 11:43:25' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '出餐很快，拿到手还是热的，整体很满意' AS content, '2026-09-17 13:45:34' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，整体很满意' AS content, '2026-10-08 18:57:49' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '味道稳定，已经连吃三天了，整体很满意' AS content, '2026-09-06 11:40:36' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '配菜新鲜，整体满意，整体很满意' AS content, '2026-11-02 12:22:14' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '铁板很烫，端上来还在响，整体很满意' AS content, '2026-08-07 12:55:37' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，整体很满意' AS content, '2026-10-27 19:04:15' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '肉给得很大方，师傅人也好，整体很满意' AS content, '2026-10-09 11:42:23' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，整体很满意' AS content, '2026-08-23 17:45:21' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，整体很满意' AS content, '2026-10-09 13:10:16' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '出餐很快，拿到手还是热的，下次还会点' AS content, '2026-10-24 18:02:49' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，下次还会点' AS content, '2026-08-25 19:28:43' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '味道稳定，已经连吃三天了，下次还会点' AS content, '2026-10-04 12:58:13' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '配菜新鲜，整体满意，下次还会点' AS content, '2026-09-29 18:21:08' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 5 AS rating, '铁板很烫，端上来还在响，下次还会点' AS content, '2026-10-18 12:43:02' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-08-07 13:17:09' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-08-18 11:11:39' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-08-09 17:21:55' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，整体还行' AS content, '2026-10-23 11:16:25' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-10-06 12:37:18' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-08-30 11:15:20' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，但希望能改进' AS content, '2026-09-06 19:29:10' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，但希望能改进' AS content, '2026-08-27 12:28:05' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '口味偏淡，适合清淡党，但希望能改进' AS content, '2026-08-12 11:40:23' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，不功不过' AS content, '2026-08-16 13:59:40' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，不功不过' AS content, '2026-09-01 17:47:57' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '口味偏淡，适合清淡党，不功不过' AS content, '2026-08-06 18:35:38' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，还可以再优化' AS content, '2026-11-01 17:51:55' AS created_at
  UNION ALL
  SELECT 'D001' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，还可以再优化' AS content, '2026-10-05 17:38:12' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-09-21 12:42:16' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-08-16 17:42:06' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-08-14 19:52:20' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-11-02 13:19:13' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-09-19 17:21:12' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-10-28 18:04:33' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-09-18 11:48:06' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-08-07 19:13:02' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，整体还行' AS content, '2026-08-09 19:56:07' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-10-10 18:58:41' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '口味偏淡，适合清淡党，但希望能改进' AS content, '2026-08-09 12:19:53' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，但希望能改进' AS content, '2026-08-28 12:01:42' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，但希望能改进' AS content, '2026-10-21 19:18:24' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D002' AS code, 4 AS rating, '口味偏淡，适合清淡党，不功不过' AS content, '2026-08-09 18:42:39' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，不功不过' AS content, '2026-09-25 13:19:49' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，不功不过' AS content, '2026-10-03 13:11:52' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '口味偏淡，适合清淡党，还可以再优化' AS content, '2026-09-20 19:58:50' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，还可以再优化' AS content, '2026-09-21 12:16:49' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，还可以再优化' AS content, '2026-10-13 11:43:52' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-11-02 19:59:43' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-08-18 17:13:25' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-09-13 19:58:44' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '锅巴很香，就是等的时间长' AS content, '2026-10-09 17:22:11' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-09-25 11:54:06' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，有点失望' AS content, '2026-08-31 19:53:13' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 2 AS rating, '中午排队等了十几分钟，出餐可以再快点，有点失望' AS content, '2026-10-01 11:55:42' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 2 AS rating, '味道不错，就是油稍微大了点，有点失望' AS content, '2026-08-25 17:59:57' AS created_at
  UNION ALL
  SELECT 'D002' AS code, 2 AS rating, '锅巴很香，就是等的时间长，有点失望' AS content, '2026-09-14 18:06:00' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-10-27 11:35:59' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-08-10 19:24:25' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-10-29 12:42:57' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-09-18 18:19:26' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-10-09 12:30:25' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-08-20 18:12:57' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-10-20 12:32:48' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-08-17 18:07:27' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-10-06 19:40:19' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '锅巴很香，就是等的时间长' AS content, '2026-08-30 13:37:16' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 3 AS rating, '味道不错，就是油稍微大了点，有点失望' AS content, '2026-11-02 17:58:42' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 2 AS rating, '中午排队等了十几分钟，出餐可以再快点，有点失望' AS content, '2026-10-19 18:37:22' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 2 AS rating, '有点咸，下次希望能少放点盐，有点失望' AS content, '2026-09-10 13:41:27' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 2 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，有点失望' AS content, '2026-09-29 18:26:47' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 2 AS rating, '锅巴很香，就是等的时间长，有点失望' AS content, '2026-09-01 18:20:29' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 1 AS rating, '味道不错，就是油稍微大了点，不太推荐' AS content, '2026-10-26 17:26:05' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 1 AS rating, '中午排队等了十几分钟，出餐可以再快点，不太推荐' AS content, '2026-09-04 11:03:00' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 1 AS rating, '有点咸，下次希望能少放点盐，不太推荐' AS content, '2026-08-09 17:48:05' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-10-08 12:23:03' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-09-04 11:59:28' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-09-20 17:39:32' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '铁板很烫，端上来还在响' AS content, '2026-10-02 12:55:06' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-08-11 13:11:49' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-09-13 12:50:14' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-10-22 18:18:06' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-09-03 17:15:24' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-09-24 18:25:01' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '出餐很快，拿到手还是热的，整体很满意' AS content, '2026-10-02 17:21:47' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，整体很满意' AS content, '2026-09-08 12:38:09' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，整体很满意' AS content, '2026-10-07 12:01:56' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '铁板很烫，端上来还在响，整体很满意' AS content, '2026-10-27 11:33:37' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '味道稳定，已经连吃三天了，整体很满意' AS content, '2026-09-20 11:13:05' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '肉给得很大方，师傅人也好，整体很满意' AS content, '2026-09-27 18:30:30' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，整体很满意' AS content, '2026-09-07 19:59:59' AS created_at
  UNION ALL
  SELECT 'D003' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，整体很满意' AS content, '2026-09-17 19:25:26' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D003' AS code, 5 AS rating, '配菜新鲜，整体满意，整体很满意' AS content, '2026-10-02 13:59:37' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-10-01 11:49:40' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-09-17 19:40:35' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '铁板很烫，端上来还在响' AS content, '2026-08-29 12:01:40' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-10-26 18:42:09' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-10-27 11:31:28' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-10-09 17:13:55' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-10-19 19:57:13' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-10-12 19:11:06' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-10-15 18:48:10' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，整体很满意' AS content, '2026-10-14 11:32:17' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '味道稳定，已经连吃三天了，整体很满意' AS content, '2026-08-30 18:31:18' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '铁板很烫，端上来还在响，整体很满意' AS content, '2026-08-19 17:39:07' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '配菜新鲜，整体满意，整体很满意' AS content, '2026-10-19 19:22:26' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，整体很满意' AS content, '2026-09-13 13:31:34' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，整体很满意' AS content, '2026-10-18 17:01:03' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '出餐很快，拿到手还是热的，整体很满意' AS content, '2026-09-16 17:24:51' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，整体很满意' AS content, '2026-10-02 19:42:06' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '肉给得很大方，师傅人也好，整体很满意' AS content, '2026-10-26 12:47:51' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，下次还会点' AS content, '2026-09-28 19:24:46' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '味道稳定，已经连吃三天了，下次还会点' AS content, '2026-10-17 11:31:37' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '铁板很烫，端上来还在响，下次还会点' AS content, '2026-11-02 19:14:48' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 5 AS rating, '配菜新鲜，整体满意，下次还会点' AS content, '2026-10-06 12:14:05' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-10-11 12:53:33' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-09-10 19:03:35' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-10-20 11:58:35' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-10-27 13:04:11' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，整体还行' AS content, '2026-09-20 17:55:04' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-09-17 13:39:19' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '口味偏淡，适合清淡党，但希望能改进' AS content, '2026-09-15 12:33:13' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，但希望能改进' AS content, '2026-10-05 17:55:43' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，但希望能改进' AS content, '2026-08-28 11:34:58' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '口味偏淡，适合清淡党，不功不过' AS content, '2026-10-12 17:52:45' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，不功不过' AS content, '2026-10-10 11:23:18' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，不功不过' AS content, '2026-10-06 13:48:01' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '口味偏淡，适合清淡党，还可以再优化' AS content, '2026-09-20 11:23:08' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，还可以再优化' AS content, '2026-08-14 11:39:21' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，还可以再优化' AS content, '2026-09-16 12:53:39' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-10-16 11:25:26' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '锅巴很香，就是等的时间长' AS content, '2026-09-11 12:56:01' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-09-05 13:47:39' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-09-01 18:53:51' AS created_at
  UNION ALL
  SELECT 'D004' AS code, 3 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-09-13 11:17:07' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-10-12 13:14:09' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-08-19 12:59:58' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-10-18 12:30:19' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-10-28 12:48:15' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-09-23 19:32:21' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-08-18 18:35:10' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，整体还行' AS content, '2026-10-22 11:14:24' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D005' AS code, 4 AS rating, '口味偏淡，适合清淡党，但希望能改进' AS content, '2026-09-10 17:48:03' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，但希望能改进' AS content, '2026-10-02 13:25:15' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，但希望能改进' AS content, '2026-10-09 11:32:12' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '口味偏淡，适合清淡党，不功不过' AS content, '2026-09-13 19:23:20' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，不功不过' AS content, '2026-09-22 13:21:28' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，不功不过' AS content, '2026-08-20 11:42:42' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '口味偏淡，适合清淡党，还可以再优化' AS content, '2026-09-14 13:03:13' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，还可以再优化' AS content, '2026-10-28 13:21:57' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，还可以再优化' AS content, '2026-09-30 17:59:37' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '锅巴很香，就是等的时间长' AS content, '2026-09-01 13:52:22' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-08-08 11:20:32' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-09-06 12:48:09' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-09-28 11:39:50' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-09-17 12:09:23' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 3 AS rating, '锅巴很香，就是等的时间长，有点失望' AS content, '2026-10-28 18:27:51' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 2 AS rating, '味道不错，就是油稍微大了点，有点失望' AS content, '2026-10-02 11:32:19' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 2 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，有点失望' AS content, '2026-08-05 19:34:56' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 2 AS rating, '中午排队等了十几分钟，出餐可以再快点，有点失望' AS content, '2026-09-16 19:00:34' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 2 AS rating, '有点咸，下次希望能少放点盐，有点失望' AS content, '2026-10-16 19:23:09' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 1 AS rating, '锅巴很香，就是等的时间长，不太推荐' AS content, '2026-09-12 11:36:35' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 1 AS rating, '味道不错，就是油稍微大了点，不太推荐' AS content, '2026-09-08 17:40:29' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 1 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，不太推荐' AS content, '2026-09-01 17:34:10' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-09-21 18:43:27' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-09-23 18:15:02' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-08-24 11:19:57' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-10-31 19:33:01' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-08-19 11:03:36' AS created_at
  UNION ALL
  SELECT 'D005' AS code, 5 AS rating, '铁板很烫，端上来还在响' AS content, '2026-09-30 19:51:56' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '有点老，梗比较硬' AS content, '2026-10-21 11:10:55' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿' AS content, '2026-08-25 18:32:47' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '分量偏少，一份不太够' AS content, '2026-08-06 13:36:38' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '有点老，梗比较硬，有点失望' AS content, '2026-08-21 12:00:57' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿，有点失望' AS content, '2026-08-16 19:24:34' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 2 AS rating, '分量偏少，一份不太够，有点失望' AS content, '2026-09-06 19:09:02' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 2 AS rating, '有点老，梗比较硬，不太推荐' AS content, '2026-10-20 19:36:55' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 2 AS rating, '温度不太够，感觉放了有一会儿，不太推荐' AS content, '2026-10-08 18:11:23' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 2 AS rating, '分量偏少，一份不太够，不太推荐' AS content, '2026-09-28 12:39:18' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 1 AS rating, '有点老，梗比较硬，希望改进' AS content, '2026-08-28 19:52:04' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 1 AS rating, '温度不太够，感觉放了有一会儿，希望改进' AS content, '2026-10-10 19:30:57' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '油不多，适合减脂' AS content, '2026-10-02 19:24:22' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好' AS content, '2026-10-14 11:19:05' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '青菜很新鲜，颜色好看' AS content, '2026-10-19 19:41:40' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌' AS content, '2026-08-27 11:55:14' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '清淡健康，常点' AS content, '2026-10-12 17:54:44' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '油不多，适合减脂，整体很满意' AS content, '2026-08-12 17:52:34' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，整体很满意' AS content, '2026-10-07 13:00:17' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '青菜很新鲜，颜色好看，整体很满意' AS content, '2026-10-13 17:02:41' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，整体很满意' AS content, '2026-10-07 12:21:26' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '清淡健康，常点，整体很满意' AS content, '2026-10-15 18:49:58' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '油不多，适合减脂，下次还会点' AS content, '2026-09-28 11:48:09' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D006' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，下次还会点' AS content, '2026-10-29 11:28:22' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '青菜很新鲜，颜色好看，下次还会点' AS content, '2026-10-06 17:01:48' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，下次还会点' AS content, '2026-09-28 19:30:42' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '清淡健康，常点，下次还会点' AS content, '2026-10-25 17:42:03' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '油不多，适合减脂，希望保持这个水准' AS content, '2026-08-11 11:21:31' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，希望保持这个水准' AS content, '2026-10-18 13:26:19' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '青菜很新鲜，颜色好看，希望保持这个水准' AS content, '2026-10-13 18:25:47' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，希望保持这个水准' AS content, '2026-10-31 11:39:58' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '清淡健康，常点，希望保持这个水准' AS content, '2026-09-25 11:01:37' AS created_at
  UNION ALL
  SELECT 'D006' AS code, 5 AS rating, '油不多，适合减脂，值得推荐' AS content, '2026-10-25 12:28:53' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面条劲道，汤头不错' AS content, '2026-08-12 18:47:48' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '汤底很鲜，喝着舒服' AS content, '2026-09-08 18:37:50' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面条是手擀的，口感很好' AS content, '2026-08-25 13:51:00' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '加个卤蛋会更好' AS content, '2026-09-24 18:51:43' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '分量足，一碗吃得很饱' AS content, '2026-10-14 18:11:15' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '配料给得实在' AS content, '2026-08-19 11:28:32' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '汤头浓郁，喝到见底' AS content, '2026-09-06 12:49:19' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '等了快二十分钟才拿到' AS content, '2026-10-31 17:16:27' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '出餐快，热乎的' AS content, '2026-09-25 13:48:07' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面汤温度刚好，冬天吃很舒服' AS content, '2026-09-08 11:49:04' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面条劲道，汤头不错，整体很满意' AS content, '2026-09-21 12:22:21' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '汤底很鲜，喝着舒服，整体很满意' AS content, '2026-08-07 17:47:20' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '面条是手擀的，口感很好，整体很满意' AS content, '2026-10-19 19:19:12' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '加个卤蛋会更好，整体很满意' AS content, '2026-10-17 18:12:00' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '分量足，一碗吃得很饱，整体很满意' AS content, '2026-10-25 13:33:29' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '配料给得实在，整体很满意' AS content, '2026-08-14 19:47:37' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '汤头浓郁，喝到见底，整体很满意' AS content, '2026-10-30 12:59:41' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 5 AS rating, '等了快二十分钟才拿到，整体很满意' AS content, '2026-10-17 13:26:57' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜' AS content, '2026-08-07 13:15:45' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说' AS content, '2026-08-29 18:39:57' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，整体还行' AS content, '2026-10-06 12:33:57' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，整体还行' AS content, '2026-08-05 19:18:36' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，但希望能改进' AS content, '2026-09-27 18:57:31' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，但希望能改进' AS content, '2026-09-05 11:34:52' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，不功不过' AS content, '2026-08-28 12:04:23' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，不功不过' AS content, '2026-09-22 12:20:39' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，还可以再优化' AS content, '2026-10-11 12:27:00' AS created_at
  UNION ALL
  SELECT 'D007' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，还可以再优化' AS content, '2026-08-12 12:50:22' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '冬天喝这个很治愈' AS content, '2026-11-02 19:34:06' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '料给得足，捞得到东西' AS content, '2026-08-22 17:00:15' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '份量偏小，几口就见底了' AS content, '2026-09-12 19:33:07' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 5 AS rating, '温度刚好，暖胃' AS content, '2026-10-03 19:39:46' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '汤底很鲜，饭前喝一碗很舒服' AS content, '2026-10-17 17:53:31' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '上得很快，配饭刚好' AS content, '2026-09-06 13:59:15' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '料有点少，主要是汤' AS content, '2026-08-17 13:38:02' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '分量足，一碗喝得很满足' AS content, '2026-10-13 18:52:28' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '稍微有点油花，不碍事' AS content, '2026-10-25 17:16:50' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '汤色清亮，看着干净' AS content, '2026-09-24 19:33:47' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '汤里料很实在，不止是清汤' AS content, '2026-08-22 11:11:39' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '味道清淡，适合搭配主食' AS content, '2026-09-04 17:00:20' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D008' AS code, 4 AS rating, '冬天喝这个很治愈，整体很满意' AS content, '2026-09-11 19:11:19' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '料给得足，捞得到东西，整体很满意' AS content, '2026-09-18 11:49:42' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '份量偏小，几口就见底了，整体很满意' AS content, '2026-10-24 11:03:50' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '温度刚好，暖胃，整体很满意' AS content, '2026-09-28 12:59:02' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '汤底很鲜，饭前喝一碗很舒服，整体很满意' AS content, '2026-10-09 17:28:40' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '上得很快，配饭刚好，整体很满意' AS content, '2026-08-14 12:16:52' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 4 AS rating, '料有点少，主要是汤，整体很满意' AS content, '2026-08-07 11:40:42' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 3 AS rating, '有点咸，希望淡一点' AS content, '2026-08-20 11:32:33' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 3 AS rating, '有点咸，希望淡一点，有点失望' AS content, '2026-08-19 17:10:04' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 3 AS rating, '有点咸，希望淡一点，不太推荐' AS content, '2026-08-19 18:10:47' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 3 AS rating, '有点咸，希望淡一点，希望改进' AS content, '2026-08-09 19:21:32' AS created_at
  UNION ALL
  SELECT 'D008' AS code, 3 AS rating, '有点咸，希望淡一点，下次可能不点了' AS content, '2026-08-22 17:09:30' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定' AS content, '2026-08-16 12:49:44' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，整体还行' AS content, '2026-09-27 12:47:04' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，但希望能改进' AS content, '2026-09-22 19:55:36' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，不功不过' AS content, '2026-08-25 17:40:36' AS created_at
  UNION ALL
  SELECT 'D009' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，还可以再优化' AS content, '2026-09-21 11:47:37' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '希望多几种时令菜轮换' AS content, '2026-09-01 18:38:09' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '调味偏淡，但对身体好' AS content, '2026-08-08 13:58:41' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '希望多几种时令菜轮换，整体还行' AS content, '2026-09-03 11:20:11' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '调味偏淡，但对身体好，整体还行' AS content, '2026-08-25 13:32:42' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 3 AS rating, '分量偏少，一份不太够' AS content, '2026-09-24 17:52:46' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿' AS content, '2026-09-24 12:04:34' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 3 AS rating, '有点老，梗比较硬' AS content, '2026-08-06 11:08:55' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 3 AS rating, '分量偏少，一份不太够，有点失望' AS content, '2026-09-25 12:47:19' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿，有点失望' AS content, '2026-10-29 17:07:25' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 3 AS rating, '有点老，梗比较硬，有点失望' AS content, '2026-10-26 12:59:16' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 2 AS rating, '分量偏少，一份不太够，不太推荐' AS content, '2026-09-25 17:34:47' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 2 AS rating, '温度不太够，感觉放了有一会儿，不太推荐' AS content, '2026-08-18 19:10:31' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 2 AS rating, '有点老，梗比较硬，不太推荐' AS content, '2026-08-12 12:01:12' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 2 AS rating, '分量偏少，一份不太够，希望改进' AS content, '2026-08-09 11:30:57' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 1 AS rating, '温度不太够，感觉放了有一会儿，希望改进' AS content, '2026-09-22 12:56:56' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 1 AS rating, '有点老，梗比较硬，希望改进' AS content, '2026-09-05 13:48:49' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 1 AS rating, '分量偏少，一份不太够，下次可能不点了' AS content, '2026-10-16 17:15:28' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '油不多，适合减脂' AS content, '2026-08-27 13:59:14' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好' AS content, '2026-10-09 13:43:02' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '青菜很新鲜，颜色好看' AS content, '2026-10-26 13:51:39' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌' AS content, '2026-10-15 18:50:18' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '清淡健康，常点' AS content, '2026-08-22 17:29:59' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '油不多，适合减脂，整体很满意' AS content, '2026-10-11 17:10:22' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，整体很满意' AS content, '2026-08-22 11:18:36' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '青菜很新鲜，颜色好看，整体很满意' AS content, '2026-10-14 18:14:38' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，整体很满意' AS content, '2026-08-22 18:46:25' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '清淡健康，常点，整体很满意' AS content, '2026-10-23 19:07:54' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '油不多，适合减脂，下次还会点' AS content, '2026-10-13 13:59:21' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，下次还会点' AS content, '2026-09-15 18:18:40' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '青菜很新鲜，颜色好看，下次还会点' AS content, '2026-08-27 11:49:25' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，下次还会点' AS content, '2026-09-17 11:55:46' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '清淡健康，常点，下次还会点' AS content, '2026-11-01 19:29:59' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '油不多，适合减脂，希望保持这个水准' AS content, '2026-08-08 12:25:48' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D010' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，希望保持这个水准' AS content, '2026-08-30 18:42:45' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '青菜很新鲜，颜色好看，希望保持这个水准' AS content, '2026-09-01 13:33:19' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，希望保持这个水准' AS content, '2026-10-14 18:12:27' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '清淡健康，常点，希望保持这个水准' AS content, '2026-09-09 12:12:52' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '油不多，适合减脂，值得推荐' AS content, '2026-10-29 17:31:26' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，值得推荐' AS content, '2026-11-01 17:00:30' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '希望多几种时令菜轮换，但希望能改进' AS content, '2026-08-09 18:50:55' AS created_at
  UNION ALL
  SELECT 'D010' AS code, 4 AS rating, '调味偏淡，但对身体好，但希望能改进' AS content, '2026-09-29 12:25:10' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '冰的量很足，夏天喝着爽' AS content, '2026-10-31 11:38:41' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '价格便宜，解渴' AS content, '2026-10-06 12:46:14' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '甜度控制得不错，不会太腻' AS content, '2026-08-30 17:55:35' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '口味稳定，常买' AS content, '2026-08-29 11:33:31' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '杯子偏小，几口就没了' AS content, '2026-10-25 11:53:06' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '料给得实在，捞得到果肉' AS content, '2026-11-01 13:49:49' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '温度合适，不会太冰' AS content, '2026-10-31 11:46:18' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '喝着清爽，饭后解腻' AS content, '2026-08-21 18:23:16' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '奶味很浓，甜度刚好' AS content, '2026-10-24 17:42:52' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '包装干净，吸管给得很到位' AS content, '2026-08-16 11:29:32' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '冰的量很足，夏天喝着爽，整体很满意' AS content, '2026-10-13 11:07:41' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '价格便宜，解渴，整体很满意' AS content, '2026-09-07 11:27:34' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '甜度控制得不错，不会太腻，整体很满意' AS content, '2026-08-24 11:02:36' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '口味稳定，常买，整体很满意' AS content, '2026-09-18 11:26:12' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '杯子偏小，几口就没了，整体很满意' AS content, '2026-08-28 12:16:45' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '料给得实在，捞得到果肉，整体很满意' AS content, '2026-09-24 19:30:58' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '温度合适，不会太冰，整体很满意' AS content, '2026-09-01 11:34:16' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '喝着清爽，饭后解腻，整体很满意' AS content, '2026-09-14 18:47:24' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 5 AS rating, '奶味很浓，甜度刚好，整体很满意' AS content, '2026-10-06 17:35:17' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '包装干净，吸管给得很到位，整体很满意' AS content, '2026-09-24 17:30:53' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '冰的量很足，夏天喝着爽，下次还会点' AS content, '2026-10-13 13:33:17' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '价格便宜，解渴，下次还会点' AS content, '2026-09-20 12:12:34' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '甜度控制得不错，不会太腻，下次还会点' AS content, '2026-08-05 12:43:45' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '口味稳定，常买，下次还会点' AS content, '2026-09-19 13:07:42' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '杯子偏小，几口就没了，下次还会点' AS content, '2026-09-13 17:26:04' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '料给得实在，捞得到果肉，下次还会点' AS content, '2026-09-26 17:56:49' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '温度合适，不会太冰，下次还会点' AS content, '2026-10-05 12:03:58' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '喝着清爽，饭后解腻，下次还会点' AS content, '2026-10-25 12:11:32' AS created_at
  UNION ALL
  SELECT 'D011' AS code, 4 AS rating, '奶味很浓，甜度刚好，下次还会点' AS content, '2026-10-16 17:45:53' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '包装干净，吸管给得很到位' AS content, '2026-08-14 19:54:03' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '甜度控制得不错，不会太腻' AS content, '2026-09-07 13:03:55' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '料给得实在，捞得到果肉' AS content, '2026-10-29 13:32:05' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 5 AS rating, '冰的量很足，夏天喝着爽' AS content, '2026-08-20 13:35:18' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '口味稳定，常买' AS content, '2026-10-16 17:47:28' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '奶味很浓，甜度刚好' AS content, '2026-09-20 17:24:36' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '价格便宜，解渴' AS content, '2026-10-25 12:08:37' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '喝着清爽，饭后解腻' AS content, '2026-09-17 19:28:04' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '温度合适，不会太冰' AS content, '2026-09-10 12:49:24' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '杯子偏小，几口就没了' AS content, '2026-09-02 18:39:12' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '包装干净，吸管给得很到位，整体很满意' AS content, '2026-08-15 18:04:33' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '甜度控制得不错，不会太腻，整体很满意' AS content, '2026-09-18 13:32:41' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '料给得实在，捞得到果肉，整体很满意' AS content, '2026-09-21 19:38:18' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D012' AS code, 4 AS rating, '冰的量很足，夏天喝着爽，整体很满意' AS content, '2026-09-27 12:34:45' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '口味稳定，常买，整体很满意' AS content, '2026-08-29 19:00:31' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '奶味很浓，甜度刚好，整体很满意' AS content, '2026-09-02 17:52:27' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '价格便宜，解渴，整体很满意' AS content, '2026-09-20 13:10:38' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '喝着清爽，饭后解腻，整体很满意' AS content, '2026-11-01 17:12:25' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 4 AS rating, '温度合适，不会太冰，整体很满意' AS content, '2026-09-05 19:50:37' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '量有点少，价格可以再低点' AS content, '2026-10-19 18:15:51' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '有点太甜了，希望能选无糖' AS content, '2026-08-23 18:19:39' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '量有点少，价格可以再低点，有点失望' AS content, '2026-09-27 12:18:36' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '有点太甜了，希望能选无糖，有点失望' AS content, '2026-08-14 18:13:34' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '量有点少，价格可以再低点，不太推荐' AS content, '2026-11-01 19:40:38' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 3 AS rating, '有点太甜了，希望能选无糖，不太推荐' AS content, '2026-08-26 12:16:55' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 2 AS rating, '量有点少，价格可以再低点，希望改进' AS content, '2026-08-06 18:08:17' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 2 AS rating, '有点太甜了，希望能选无糖，希望改进' AS content, '2026-10-14 18:53:29' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 2 AS rating, '量有点少，价格可以再低点，下次可能不点了' AS content, '2026-08-16 18:21:38' AS created_at
  UNION ALL
  SELECT 'D012' AS code, 2 AS rating, '有点太甜了，希望能选无糖，下次可能不点了' AS content, '2026-09-14 19:24:50' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 4 AS rating, '麻婆豆腐的辣度不太稳定，时重时淡' AS content, '2026-10-11 18:50:34' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 4 AS rating, '麻婆豆腐好吃，就是辣度对我来说有点顶' AS content, '2026-09-10 19:12:33' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-10-22 19:05:13' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-10-02 18:56:43' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-10-03 13:27:48' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-10-12 13:47:41' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 3 AS rating, '麻婆豆腐有点凉了，像是提前炒好的' AS content, '2026-09-02 17:34:32' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 3 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-08-25 17:44:38' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-09-24 19:26:21' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 3 AS rating, '锅巴很香，就是等的时间长' AS content, '2026-10-25 19:26:25' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-09-17 19:00:33' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 2 AS rating, '味道不错，就是油稍微大了点，有点失望' AS content, '2026-10-29 19:36:21' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 2 AS rating, '麻婆豆腐有点凉了，像是提前炒好的，有点失望' AS content, '2026-09-20 17:33:20' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 2 AS rating, '有点咸，下次希望能少放点盐，有点失望' AS content, '2026-09-10 13:59:07' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 2 AS rating, '中午排队等了十几分钟，出餐可以再快点，有点失望' AS content, '2026-10-20 17:20:16' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 1 AS rating, '锅巴很香，就是等的时间长，有点失望' AS content, '2026-09-23 12:10:30' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 1 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，有点失望' AS content, '2026-10-23 11:26:54' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 5 AS rating, '麻婆豆腐很下饭，配米饭能多来半碗' AS content, '2026-08-31 11:58:25' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 5 AS rating, '不知道吃什么的时候就来点一份麻婆豆腐' AS content, '2026-09-23 17:22:59' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-08-25 13:00:34' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 5 AS rating, '油大还咸，吃完麻婆豆腐不太舒服' AS content, '2026-09-16 18:08:26' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 5 AS rating, '麻辣鲜香，麻婆豆腐在食堂里算做得好的了' AS content, '2026-08-08 12:09:44' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-10-16 19:20:57' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-09-01 17:57:15' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 5 AS rating, '麻婆豆腐份量实在，师傅给肉很大方' AS content, '2026-08-08 17:52:16' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-08-05 18:01:29' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 5 AS rating, '师傅颠勺很利索，麻婆豆腐出锅就端走' AS content, '2026-08-12 18:50:41' AS created_at
  UNION ALL
  SELECT 'D016' AS code, 5 AS rating, '铁板很烫，端上来还在响' AS content, '2026-10-17 18:38:17' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 2 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-10-01 17:48:32' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 1 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-10-23 13:35:27' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 1 AS rating, '锅巴很香，就是等的时间长' AS content, '2026-10-18 19:56:47' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-08-06 13:37:27' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-10-02 18:14:54' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-10-17 19:38:10' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D017' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-08-27 18:42:45' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-10-01 17:35:11' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-08-27 11:52:23' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '铁板很烫，端上来还在响' AS content, '2026-11-01 18:07:52' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-10-27 19:26:13' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-08-21 12:52:06' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，整体很满意' AS content, '2026-09-19 13:14:44' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '出餐很快，拿到手还是热的，整体很满意' AS content, '2026-10-30 17:53:42' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，整体很满意' AS content, '2026-08-08 11:06:03' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '配菜新鲜，整体满意，整体很满意' AS content, '2026-08-08 19:36:40' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，整体很满意' AS content, '2026-10-25 17:22:18' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '肉给得很大方，师傅人也好，整体很满意' AS content, '2026-09-16 19:28:04' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '铁板很烫，端上来还在响，整体很满意' AS content, '2026-10-30 13:56:00' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，整体很满意' AS content, '2026-09-15 11:34:27' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '味道稳定，已经连吃三天了，整体很满意' AS content, '2026-10-02 18:15:07' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，下次还会点' AS content, '2026-09-09 11:33:31' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '出餐很快，拿到手还是热的，下次还会点' AS content, '2026-08-21 19:44:34' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，下次还会点' AS content, '2026-09-14 19:04:41' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '配菜新鲜，整体满意，下次还会点' AS content, '2026-09-24 19:25:51' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，下次还会点' AS content, '2026-10-27 11:51:50' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-08-17 19:19:44' AS created_at
  UNION ALL
  SELECT 'D017' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-10-05 18:30:13' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '豉汁排骨饭出品挺稳，偶尔肉会偏柴' AS content, '2026-08-15 18:05:31' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '豉汁排骨饭的肉肥瘦相间，蜜汁调得正好' AS content, '2026-08-09 13:56:24' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '肉有股怪味，豉汁排骨饭不太新鲜' AS content, '2026-09-27 19:55:38' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '偏甜，豉汁排骨饭个人不太习惯' AS content, '2026-10-18 13:54:38' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '豉汁排骨饭算是普通盒饭水平' AS content, '2026-08-10 17:19:42' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '每天都想吃豉汁排骨饭，可惜是限量的' AS content, '2026-08-19 13:45:03' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-10-03 13:35:36' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-10-23 18:02:12' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '豉汁排骨饭肉质很嫩，蘸料也地道' AS content, '2026-08-24 13:56:50' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-08-10 11:06:01' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-10-26 13:57:50' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-08-19 13:16:13' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-09-21 17:09:54' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-10-24 17:48:24' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-09-05 19:27:06' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-09-13 11:12:26' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，整体还行' AS content, '2026-08-12 17:51:22' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-09-05 17:56:02' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，但希望能改进' AS content, '2026-08-17 18:02:30' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，但希望能改进' AS content, '2026-10-01 18:50:19' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '口味偏淡，适合清淡党，但希望能改进' AS content, '2026-09-22 18:10:51' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，不功不过' AS content, '2026-10-05 12:54:15' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，不功不过' AS content, '2026-08-13 13:48:19' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '口味偏淡，适合清淡党，不功不过' AS content, '2026-10-10 17:33:20' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，还可以再优化' AS content, '2026-11-02 13:32:11' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，还可以再优化' AS content, '2026-08-12 18:29:51' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 4 AS rating, '口味偏淡，适合清淡党，还可以再优化' AS content, '2026-08-25 19:20:30' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 3 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-09-17 12:44:25' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D018' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-09-16 12:06:14' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-09-09 11:38:26' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-10-07 18:30:39' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 3 AS rating, '锅巴很香，就是等的时间长' AS content, '2026-08-19 19:24:30' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 3 AS rating, '有点咸，下次希望能少放点盐，有点失望' AS content, '2026-09-15 12:40:56' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 2 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，有点失望' AS content, '2026-08-19 19:33:20' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 2 AS rating, '中午排队等了十几分钟，出餐可以再快点，有点失望' AS content, '2026-11-01 18:23:00' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 2 AS rating, '味道不错，就是油稍微大了点，有点失望' AS content, '2026-08-20 19:09:48' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 2 AS rating, '锅巴很香，就是等的时间长，有点失望' AS content, '2026-10-21 18:47:01' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 1 AS rating, '有点咸，下次希望能少放点盐，不太推荐' AS content, '2026-09-10 11:21:31' AS created_at
  UNION ALL
  SELECT 'D018' AS code, 1 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，不太推荐' AS content, '2026-10-25 11:36:57' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-09-24 12:23:25' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-10-09 18:47:53' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-08-13 18:33:14' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-08-20 19:31:01' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-10-27 18:27:47' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，整体还行' AS content, '2026-09-14 13:00:12' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，但希望能改进' AS content, '2026-10-26 12:44:19' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下' AS content, '2026-10-09 18:28:14' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 3 AS rating, '中午排队等了十几分钟，出餐可以再快点' AS content, '2026-09-08 18:05:12' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 3 AS rating, '有点咸，下次希望能少放点盐' AS content, '2026-09-11 11:31:37' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 3 AS rating, '味道不错，就是油稍微大了点' AS content, '2026-09-09 12:28:07' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 3 AS rating, '锅巴很香，就是等的时间长' AS content, '2026-09-16 17:53:33' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 3 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，有点失望' AS content, '2026-08-30 13:37:39' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 2 AS rating, '中午排队等了十几分钟，出餐可以再快点，有点失望' AS content, '2026-09-13 13:58:02' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 2 AS rating, '有点咸，下次希望能少放点盐，有点失望' AS content, '2026-10-17 18:03:09' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 2 AS rating, '味道不错，就是油稍微大了点，有点失望' AS content, '2026-08-09 17:06:15' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 2 AS rating, '锅巴很香，就是等的时间长，有点失望' AS content, '2026-10-25 12:27:14' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 1 AS rating, '菜码偏少，米饭多，希望荤素比例调一下，不太推荐' AS content, '2026-09-10 17:53:31' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 1 AS rating, '中午排队等了十几分钟，出餐可以再快点，不太推荐' AS content, '2026-10-11 19:19:23' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 1 AS rating, '有点咸，下次希望能少放点盐，不太推荐' AS content, '2026-09-08 19:02:53' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-10-04 11:26:49' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-08-12 19:01:51' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-09-20 19:05:35' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-10-28 19:06:57' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-08-09 12:22:16' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-10-21 17:12:32' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-09-06 19:07:12' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-08-21 13:45:09' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '铁板很烫，端上来还在响' AS content, '2026-09-17 13:56:26' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，整体很满意' AS content, '2026-09-28 11:06:22' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，整体很满意' AS content, '2026-08-05 19:36:25' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '肉给得很大方，师傅人也好，整体很满意' AS content, '2026-10-20 13:19:22' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，整体很满意' AS content, '2026-10-26 11:29:29' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '味道稳定，已经连吃三天了，整体很满意' AS content, '2026-09-10 19:15:21' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '出餐很快，拿到手还是热的，整体很满意' AS content, '2026-10-28 13:56:21' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '配菜新鲜，整体满意，整体很满意' AS content, '2026-08-10 18:19:46' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，整体很满意' AS content, '2026-09-30 19:28:22' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '铁板很烫，端上来还在响，整体很满意' AS content, '2026-09-05 18:05:08' AS created_at
  UNION ALL
  SELECT 'D019' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，下次还会点' AS content, '2026-08-29 17:53:05' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D020' AS code, 5 AS rating, '配菜新鲜，整体满意' AS content, '2026-08-23 19:58:04' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱' AS content, '2026-10-02 17:10:21' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '肉给得很大方，师傅人也好' AS content, '2026-09-10 13:36:20' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡' AS content, '2026-09-13 12:12:00' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '份量对女生来说偏多，吃不完' AS content, '2026-10-19 18:08:08' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '出餐很快，拿到手还是热的' AS content, '2026-10-19 12:38:28' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '味道稳定，已经连吃三天了' AS content, '2026-09-21 19:31:13' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '铁板很烫，端上来还在响' AS content, '2026-08-11 19:11:07' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '价格实惠，性价比高，常来吃' AS content, '2026-08-30 17:38:39' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '配菜新鲜，整体满意，整体很满意' AS content, '2026-08-27 18:57:19' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，整体很满意' AS content, '2026-08-25 18:30:18' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '肉给得很大方，师傅人也好，整体很满意' AS content, '2026-10-18 19:49:10' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，整体很满意' AS content, '2026-08-10 12:32:37' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，整体很满意' AS content, '2026-08-11 19:31:35' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '出餐很快，拿到手还是热的，整体很满意' AS content, '2026-10-18 11:19:08' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '味道稳定，已经连吃三天了，整体很满意' AS content, '2026-08-30 13:45:37' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '铁板很烫，端上来还在响，整体很满意' AS content, '2026-08-15 18:34:44' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '价格实惠，性价比高，常来吃，整体很满意' AS content, '2026-08-13 11:16:40' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '配菜新鲜，整体满意，下次还会点' AS content, '2026-10-04 11:43:27' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '分量很足，米饭给得实在，男生也吃得饱，下次还会点' AS content, '2026-10-31 17:42:23' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '肉给得很大方，师傅人也好，下次还会点' AS content, '2026-10-12 19:49:24' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '荤素搭配合理，营养比较均衡，下次还会点' AS content, '2026-09-12 18:18:13' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 5 AS rating, '份量对女生来说偏多，吃不完，下次还会点' AS content, '2026-10-22 11:00:31' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 4 AS rating, '米饭有点硬，菜的味道还行' AS content, '2026-10-26 19:01:32' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 4 AS rating, '口味偏淡，适合清淡党' AS content, '2026-08-24 12:51:22' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了' AS content, '2026-09-17 11:00:31' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，整体还行' AS content, '2026-09-03 13:10:22' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 4 AS rating, '口味偏淡，适合清淡党，整体还行' AS content, '2026-09-08 19:44:30' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，整体还行' AS content, '2026-09-24 18:00:57' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，但希望能改进' AS content, '2026-10-02 19:23:52' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 4 AS rating, '口味偏淡，适合清淡党，但希望能改进' AS content, '2026-08-18 18:54:34' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 4 AS rating, '汤汁有点多，米饭有点泡软了，但希望能改进' AS content, '2026-09-22 12:10:25' AS created_at
  UNION ALL
  SELECT 'D020' AS code, 4 AS rating, '米饭有点硬，菜的味道还行，不功不过' AS content, '2026-09-22 11:43:15' AS created_at
  UNION ALL
  SELECT 'D021' AS code, 5 AS rating, '辣度可以选，这点很贴心' AS content, '2026-10-04 17:18:22' AS created_at
  UNION ALL
  SELECT 'D021' AS code, 5 AS rating, '肥瘦相间，不腻' AS content, '2026-10-06 18:46:23' AS created_at
  UNION ALL
  SELECT 'D021' AS code, 5 AS rating, '酱汁很下饭，能多来半碗饭' AS content, '2026-09-22 18:25:15' AS created_at
  UNION ALL
  SELECT 'D021' AS code, 5 AS rating, '颜色好看，看着就有食欲' AS content, '2026-09-26 13:53:53' AS created_at
  UNION ALL
  SELECT 'D021' AS code, 5 AS rating, '炖得入味，比外面的还香' AS content, '2026-09-22 12:07:40' AS created_at
  UNION ALL
  SELECT 'D021' AS code, 5 AS rating, '肉炖得很烂，入口即化' AS content, '2026-08-24 18:07:34' AS created_at
  UNION ALL
  SELECT 'D021' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定' AS content, '2026-09-22 13:14:45' AS created_at
  UNION ALL
  SELECT 'D021' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，整体还行' AS content, '2026-08-31 17:27:45' AS created_at
  UNION ALL
  SELECT 'D021' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，但希望能改进' AS content, '2026-11-02 13:49:40' AS created_at
  UNION ALL
  SELECT 'D021' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，不功不过' AS content, '2026-08-15 13:17:34' AS created_at
  UNION ALL
  SELECT 'D021' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，还可以再优化' AS content, '2026-09-25 18:55:23' AS created_at
  UNION ALL
  SELECT 'D022' AS code, 5 AS rating, '辣度可以选，这点很贴心' AS content, '2026-11-02 11:09:37' AS created_at
  UNION ALL
  SELECT 'D022' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定' AS content, '2026-10-29 12:16:27' AS created_at
  UNION ALL
  SELECT 'D022' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，整体还行' AS content, '2026-09-30 12:24:55' AS created_at
  UNION ALL
  SELECT 'D022' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，但希望能改进' AS content, '2026-09-25 11:19:21' AS created_at
  UNION ALL
  SELECT 'D022' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，不功不过' AS content, '2026-10-08 12:04:11' AS created_at
  UNION ALL
  SELECT 'D022' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，还可以再优化' AS content, '2026-10-05 12:52:44' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D023' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定' AS content, '2026-10-23 18:11:41' AS created_at
  UNION ALL
  SELECT 'D023' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，整体还行' AS content, '2026-10-12 11:23:34' AS created_at
  UNION ALL
  SELECT 'D023' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，但希望能改进' AS content, '2026-08-12 12:58:00' AS created_at
  UNION ALL
  SELECT 'D023' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，不功不过' AS content, '2026-10-05 13:27:07' AS created_at
  UNION ALL
  SELECT 'D023' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，还可以再优化' AS content, '2026-10-14 12:34:52' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 4 AS rating, '干煸豆角的辣度不太稳定，时重时淡' AS content, '2026-10-01 18:02:26' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 4 AS rating, '干煸豆角锅气很足，现炒出来的就是香' AS content, '2026-09-04 12:29:40' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 4 AS rating, '价格小贵，干煸豆角的量一般' AS content, '2026-08-12 17:33:22' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 4 AS rating, '现炒很香，就是干煸豆角高峰期要等七八分钟' AS content, '2026-10-10 11:49:11' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定' AS content, '2026-08-28 19:31:15' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 4 AS rating, '干煸豆角的辣度不太稳定，时重时淡，整体还行' AS content, '2026-09-03 17:42:14' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 4 AS rating, '干煸豆角锅气很足，现炒出来的就是香，整体还行' AS content, '2026-08-18 12:34:18' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 4 AS rating, '价格小贵，干煸豆角的量一般，整体还行' AS content, '2026-08-18 13:07:26' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 4 AS rating, '现炒很香，就是干煸豆角高峰期要等七八分钟，整体还行' AS content, '2026-08-29 12:02:52' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，整体还行' AS content, '2026-10-13 18:49:04' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 3 AS rating, '今天这份有点凉了，希望保温做好' AS content, '2026-10-01 17:21:13' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 3 AS rating, '分量一般，价格偏贵了点' AS content, '2026-08-21 11:34:15' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 3 AS rating, '给的骨头偏多，肉少了些' AS content, '2026-08-31 17:22:08' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 3 AS rating, '有点咸，配米饭刚好' AS content, '2026-08-23 18:12:18' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 3 AS rating, '味道正宗，就是等的时间长' AS content, '2026-09-15 12:17:54' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 3 AS rating, '今天这份有点凉了，希望保温做好，有点失望' AS content, '2026-09-20 19:05:16' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 2 AS rating, '分量一般，价格偏贵了点，有点失望' AS content, '2026-09-23 11:01:06' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 2 AS rating, '给的骨头偏多，肉少了些，有点失望' AS content, '2026-10-21 19:43:25' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 2 AS rating, '有点咸，配米饭刚好，有点失望' AS content, '2026-08-10 17:49:52' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 2 AS rating, '味道正宗，就是等的时间长，有点失望' AS content, '2026-09-29 12:30:44' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 1 AS rating, '今天这份有点凉了，希望保温做好，不太推荐' AS content, '2026-09-02 13:43:30' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 1 AS rating, '分量一般，价格偏贵了点，不太推荐' AS content, '2026-09-21 19:04:12' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 1 AS rating, '给的骨头偏多，肉少了些，不太推荐' AS content, '2026-08-12 19:13:28' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 5 AS rating, '干煸豆角份量实在，师傅给肉很大方' AS content, '2026-08-31 11:32:24' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 5 AS rating, '师傅颠勺很利索，干煸豆角出锅就端走' AS content, '2026-10-04 17:41:32' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 5 AS rating, '挺下饭的，干煸豆角稍微咸了一点点' AS content, '2026-08-19 12:12:43' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 5 AS rating, '味道可以，但干煸豆角没第一次惊艳' AS content, '2026-09-17 19:36:46' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 5 AS rating, '麻辣鲜香，干煸豆角在食堂里算做得好的了' AS content, '2026-08-28 12:42:15' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 5 AS rating, '肉炖得很烂，入口即化' AS content, '2026-10-18 18:37:43' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 5 AS rating, '肥瘦相间，不腻' AS content, '2026-09-09 12:32:37' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 5 AS rating, '辣度可以选，这点很贴心' AS content, '2026-10-09 11:36:48' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 5 AS rating, '颜色好看，看着就有食欲' AS content, '2026-10-23 13:36:18' AS created_at
  UNION ALL
  SELECT 'D024' AS code, 5 AS rating, '炖得入味，比外面的还香' AS content, '2026-10-27 19:11:31' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 2 AS rating, '今天这份有点凉了，希望保温做好' AS content, '2026-09-22 11:44:32' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 2 AS rating, '分量一般，价格偏贵了点' AS content, '2026-09-28 17:11:41' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 2 AS rating, '味道正宗，就是等的时间长' AS content, '2026-10-04 12:01:35' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 2 AS rating, '给的骨头偏多，肉少了些' AS content, '2026-10-29 11:33:51' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 1 AS rating, '有点咸，配米饭刚好' AS content, '2026-09-05 18:53:49' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 1 AS rating, '今天这份有点凉了，希望保温做好，有点失望' AS content, '2026-10-19 17:51:32' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '酱汁很下饭，能多来半碗饭' AS content, '2026-09-15 17:21:14' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '肉炖得很烂，入口即化' AS content, '2026-08-08 12:29:02' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '颜色好看，看着就有食欲' AS content, '2026-08-19 12:32:46' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '辣度可以选，这点很贴心' AS content, '2026-10-15 11:18:59' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '炖得入味，比外面的还香' AS content, '2026-09-30 13:21:25' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '肥瘦相间，不腻' AS content, '2026-11-02 19:39:30' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D025' AS code, 5 AS rating, '酱汁很下饭，能多来半碗饭，整体很满意' AS content, '2026-08-22 17:54:27' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '肉炖得很烂，入口即化，整体很满意' AS content, '2026-10-22 19:48:50' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '颜色好看，看着就有食欲，整体很满意' AS content, '2026-08-18 12:26:29' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '辣度可以选，这点很贴心，整体很满意' AS content, '2026-08-27 18:13:31' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '炖得入味，比外面的还香，整体很满意' AS content, '2026-09-26 17:52:05' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '肥瘦相间，不腻，整体很满意' AS content, '2026-08-12 19:31:38' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '酱汁很下饭，能多来半碗饭，下次还会点' AS content, '2026-09-05 19:14:20' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '肉炖得很烂，入口即化，下次还会点' AS content, '2026-09-11 17:46:50' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '颜色好看，看着就有食欲，下次还会点' AS content, '2026-08-10 11:45:56' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '辣度可以选，这点很贴心，下次还会点' AS content, '2026-09-19 13:16:06' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '炖得入味，比外面的还香，下次还会点' AS content, '2026-10-24 12:58:02' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '肥瘦相间，不腻，下次还会点' AS content, '2026-10-10 19:46:41' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '酱汁很下饭，能多来半碗饭，希望保持这个水准' AS content, '2026-10-09 17:25:01' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '肉炖得很烂，入口即化，希望保持这个水准' AS content, '2026-10-18 11:08:23' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '颜色好看，看着就有食欲，希望保持这个水准' AS content, '2026-10-06 12:55:00' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '辣度可以选，这点很贴心，希望保持这个水准' AS content, '2026-09-28 13:56:06' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 5 AS rating, '炖得入味，比外面的还香，希望保持这个水准' AS content, '2026-09-07 17:07:57' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定' AS content, '2026-10-11 18:55:56' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，整体还行' AS content, '2026-10-10 18:43:09' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，但希望能改进' AS content, '2026-09-07 17:33:08' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，不功不过' AS content, '2026-10-24 18:29:31' AS created_at
  UNION ALL
  SELECT 'D025' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，还可以再优化' AS content, '2026-10-14 12:49:01' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '肉炖得很烂，入口即化' AS content, '2026-09-03 13:11:49' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '颜色好看，看着就有食欲' AS content, '2026-10-09 13:04:13' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '酱汁很下饭，能多来半碗饭' AS content, '2026-10-13 17:05:42' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '炖得入味，比外面的还香' AS content, '2026-10-10 18:17:46' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '肥瘦相间，不腻' AS content, '2026-09-10 19:07:02' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '辣度可以选，这点很贴心' AS content, '2026-08-10 19:26:07' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '肉炖得很烂，入口即化，整体很满意' AS content, '2026-10-19 12:47:47' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '颜色好看，看着就有食欲，整体很满意' AS content, '2026-10-13 13:21:25' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '酱汁很下饭，能多来半碗饭，整体很满意' AS content, '2026-10-01 19:00:52' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '炖得入味，比外面的还香，整体很满意' AS content, '2026-09-20 11:54:28' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '肥瘦相间，不腻，整体很满意' AS content, '2026-08-28 19:12:51' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 5 AS rating, '辣度可以选，这点很贴心，整体很满意' AS content, '2026-08-19 19:47:58' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定' AS content, '2026-08-19 13:29:42' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，整体还行' AS content, '2026-08-06 18:24:15' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，但希望能改进' AS content, '2026-09-03 12:55:24' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，不功不过' AS content, '2026-10-05 12:55:04' AS created_at
  UNION ALL
  SELECT 'D026' AS code, 4 AS rating, '偶尔会有筋膜，口感不太稳定，还可以再优化' AS content, '2026-10-12 11:30:02' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好' AS content, '2026-09-22 12:51:20' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 5 AS rating, '青菜很新鲜，颜色好看' AS content, '2026-09-09 11:21:07' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 5 AS rating, '油不多，适合减脂' AS content, '2026-09-27 13:02:57' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 4 AS rating, '调味偏淡，但对身体好' AS content, '2026-08-26 17:22:26' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 4 AS rating, '希望多几种时令菜轮换' AS content, '2026-10-22 17:41:53' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 4 AS rating, '调味偏淡，但对身体好，整体还行' AS content, '2026-09-21 17:10:57' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 4 AS rating, '希望多几种时令菜轮换，整体还行' AS content, '2026-08-14 12:00:22' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 4 AS rating, '调味偏淡，但对身体好，但希望能改进' AS content, '2026-10-19 13:37:27' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 4 AS rating, '希望多几种时令菜轮换，但希望能改进' AS content, '2026-10-19 17:49:37' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 4 AS rating, '调味偏淡，但对身体好，不功不过' AS content, '2026-09-27 17:17:15' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 4 AS rating, '希望多几种时令菜轮换，不功不过' AS content, '2026-08-26 12:42:24' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D027' AS code, 4 AS rating, '调味偏淡，但对身体好，还可以再优化' AS content, '2026-10-27 17:34:04' AS created_at
  UNION ALL
  SELECT 'D027' AS code, 4 AS rating, '希望多几种时令菜轮换，还可以再优化' AS content, '2026-08-28 12:07:35' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '宫保鸡丁好吃，就是辣度对我来说有点顶' AS content, '2026-08-30 11:33:43' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '希望多几种时令菜轮换' AS content, '2026-10-07 18:09:54' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '调味偏淡，但对身体好' AS content, '2026-09-28 13:40:54' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '宫保鸡丁好吃，就是辣度对我来说有点顶，整体还行' AS content, '2026-08-29 11:02:00' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '希望多几种时令菜轮换，整体还行' AS content, '2026-09-05 11:44:18' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '调味偏淡，但对身体好，整体还行' AS content, '2026-08-23 13:09:52' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '宫保鸡丁好吃，就是辣度对我来说有点顶，但希望能改进' AS content, '2026-10-10 18:28:51' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '希望多几种时令菜轮换，但希望能改进' AS content, '2026-09-21 19:13:27' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '调味偏淡，但对身体好，但希望能改进' AS content, '2026-09-23 19:54:22' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '宫保鸡丁好吃，就是辣度对我来说有点顶，不功不过' AS content, '2026-10-04 19:52:34' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '希望多几种时令菜轮换，不功不过' AS content, '2026-10-09 19:52:14' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 4 AS rating, '调味偏淡，但对身体好，不功不过' AS content, '2026-10-27 11:43:52' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 3 AS rating, '分量偏少，一份不太够' AS content, '2026-10-22 18:40:57' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿' AS content, '2026-08-21 17:45:23' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 3 AS rating, '有点老，梗比较硬' AS content, '2026-08-25 19:40:42' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 3 AS rating, '分量偏少，一份不太够，有点失望' AS content, '2026-09-19 19:10:12' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿，有点失望' AS content, '2026-08-26 19:37:16' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 3 AS rating, '有点老，梗比较硬，有点失望' AS content, '2026-10-16 12:06:15' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 2 AS rating, '分量偏少，一份不太够，不太推荐' AS content, '2026-08-29 13:49:36' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 2 AS rating, '温度不太够，感觉放了有一会儿，不太推荐' AS content, '2026-09-29 17:28:44' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 2 AS rating, '有点老，梗比较硬，不太推荐' AS content, '2026-08-06 11:51:06' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 2 AS rating, '分量偏少，一份不太够，希望改进' AS content, '2026-09-01 12:57:30' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 1 AS rating, '温度不太够，感觉放了有一会儿，希望改进' AS content, '2026-09-20 11:30:37' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 1 AS rating, '有点老，梗比较硬，希望改进' AS content, '2026-08-16 11:22:59' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 5 AS rating, '宫保鸡丁份量实在，师傅给肉很大方' AS content, '2026-09-15 19:49:15' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌' AS content, '2026-09-14 19:29:15' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 5 AS rating, '油不多，适合减脂' AS content, '2026-08-13 13:54:33' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 5 AS rating, '清淡健康，常点' AS content, '2026-08-29 19:07:24' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 5 AS rating, '青菜很新鲜，颜色好看' AS content, '2026-08-12 19:41:20' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好' AS content, '2026-11-02 19:42:21' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 5 AS rating, '宫保鸡丁份量实在，师傅给肉很大方，整体很满意' AS content, '2026-09-17 11:16:41' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，整体很满意' AS content, '2026-09-18 11:03:29' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 5 AS rating, '油不多，适合减脂，整体很满意' AS content, '2026-11-01 17:26:12' AS created_at
  UNION ALL
  SELECT 'D028' AS code, 5 AS rating, '清淡健康，常点，整体很满意' AS content, '2026-10-01 12:54:21' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿' AS content, '2026-10-19 11:06:11' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 2 AS rating, '分量偏少，一份不太够' AS content, '2026-09-10 11:32:18' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 2 AS rating, '有点老，梗比较硬' AS content, '2026-08-12 11:56:41' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 2 AS rating, '温度不太够，感觉放了有一会儿，有点失望' AS content, '2026-09-07 19:08:37' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 2 AS rating, '分量偏少，一份不太够，有点失望' AS content, '2026-08-27 17:50:23' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 1 AS rating, '有点老，梗比较硬，有点失望' AS content, '2026-10-17 18:19:36' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 1 AS rating, '温度不太够，感觉放了有一会儿，不太推荐' AS content, '2026-09-23 18:17:08' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '清淡健康，常点' AS content, '2026-10-30 18:54:28' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌' AS content, '2026-08-19 11:28:34' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '青菜很新鲜，颜色好看' AS content, '2026-09-14 13:25:43' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '油不多，适合减脂' AS content, '2026-10-03 11:28:42' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好' AS content, '2026-09-15 19:08:18' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '清淡健康，常点，整体很满意' AS content, '2026-09-23 18:33:05' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，整体很满意' AS content, '2026-10-23 18:21:13' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D029' AS code, 5 AS rating, '青菜很新鲜，颜色好看，整体很满意' AS content, '2026-10-13 19:19:13' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '油不多，适合减脂，整体很满意' AS content, '2026-10-03 18:32:48' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，整体很满意' AS content, '2026-09-25 12:32:15' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '清淡健康，常点，下次还会点' AS content, '2026-09-13 13:14:06' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，下次还会点' AS content, '2026-08-15 12:12:04' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '青菜很新鲜，颜色好看，下次还会点' AS content, '2026-08-29 11:36:55' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '油不多，适合减脂，下次还会点' AS content, '2026-08-22 18:08:09' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，下次还会点' AS content, '2026-08-20 17:12:55' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '清淡健康，常点，希望保持这个水准' AS content, '2026-10-25 18:16:53' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，希望保持这个水准' AS content, '2026-08-26 17:01:54' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '青菜很新鲜，颜色好看，希望保持这个水准' AS content, '2026-09-13 17:26:26' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '油不多，适合减脂，希望保持这个水准' AS content, '2026-09-26 18:44:18' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，希望保持这个水准' AS content, '2026-10-02 12:29:31' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '清淡健康，常点，值得推荐' AS content, '2026-09-18 17:05:54' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，值得推荐' AS content, '2026-10-02 11:48:33' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 5 AS rating, '青菜很新鲜，颜色好看，值得推荐' AS content, '2026-09-11 19:29:14' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 4 AS rating, '调味偏淡，但对身体好' AS content, '2026-10-30 19:13:21' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 4 AS rating, '希望多几种时令菜轮换' AS content, '2026-08-08 19:08:19' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 4 AS rating, '调味偏淡，但对身体好，整体还行' AS content, '2026-09-19 17:01:57' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 4 AS rating, '希望多几种时令菜轮换，整体还行' AS content, '2026-09-26 19:21:19' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 4 AS rating, '调味偏淡，但对身体好，但希望能改进' AS content, '2026-09-07 12:10:14' AS created_at
  UNION ALL
  SELECT 'D029' AS code, 4 AS rating, '希望多几种时令菜轮换，但希望能改进' AS content, '2026-09-12 13:01:27' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '青菜很新鲜，颜色好看' AS content, '2026-08-19 18:16:34' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌' AS content, '2026-09-30 11:32:09' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '清淡健康，常点' AS content, '2026-10-15 18:54:27' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好' AS content, '2026-10-22 17:56:34' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '油不多，适合减脂' AS content, '2026-09-12 17:10:59' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '青菜很新鲜，颜色好看，整体很满意' AS content, '2026-09-19 11:11:07' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，整体很满意' AS content, '2026-09-18 17:44:23' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '清淡健康，常点，整体很满意' AS content, '2026-10-22 11:10:45' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，整体很满意' AS content, '2026-10-27 12:29:10' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '油不多，适合减脂，整体很满意' AS content, '2026-09-19 19:24:54' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '青菜很新鲜，颜色好看，下次还会点' AS content, '2026-08-26 17:05:29' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，下次还会点' AS content, '2026-08-17 13:55:52' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 4 AS rating, '希望多几种时令菜轮换' AS content, '2026-09-12 18:26:14' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 4 AS rating, '调味偏淡，但对身体好' AS content, '2026-09-23 19:17:16' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 4 AS rating, '希望多几种时令菜轮换，整体还行' AS content, '2026-10-11 17:23:41' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 4 AS rating, '调味偏淡，但对身体好，整体还行' AS content, '2026-10-29 18:46:30' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 4 AS rating, '希望多几种时令菜轮换，但希望能改进' AS content, '2026-10-18 11:14:42' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 4 AS rating, '调味偏淡，但对身体好，但希望能改进' AS content, '2026-09-13 12:21:28' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 4 AS rating, '希望多几种时令菜轮换，不功不过' AS content, '2026-10-06 17:26:21' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 4 AS rating, '调味偏淡，但对身体好，不功不过' AS content, '2026-10-18 17:47:45' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 4 AS rating, '希望多几种时令菜轮换，还可以再优化' AS content, '2026-09-29 19:33:41' AS created_at
  UNION ALL
  SELECT 'D030' AS code, 4 AS rating, '调味偏淡，但对身体好，还可以再优化' AS content, '2026-10-09 13:06:12' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 5 AS rating, '想吃面的时候随便来碗牛肉拉面' AS content, '2026-08-29 17:29:54' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '面条口感好，牛肉拉面的肉给得少了些' AS content, '2026-10-26 12:07:34' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '希望多几种时令菜轮换' AS content, '2026-08-05 13:19:57' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '调味偏淡，但对身体好' AS content, '2026-08-14 11:17:49' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '面条口感好，牛肉拉面的肉给得少了些，整体还行' AS content, '2026-09-14 11:00:41' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '希望多几种时令菜轮换，整体还行' AS content, '2026-10-19 13:13:51' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D031' AS code, 4 AS rating, '调味偏淡，但对身体好，整体还行' AS content, '2026-08-07 18:34:37' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '面条口感好，牛肉拉面的肉给得少了些，但希望能改进' AS content, '2026-08-29 11:09:42' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '希望多几种时令菜轮换，但希望能改进' AS content, '2026-08-08 19:29:45' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '调味偏淡，但对身体好，但希望能改进' AS content, '2026-10-18 11:25:30' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '面条口感好，牛肉拉面的肉给得少了些，不功不过' AS content, '2026-10-24 11:26:06' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '希望多几种时令菜轮换，不功不过' AS content, '2026-11-01 11:39:28' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '调味偏淡，但对身体好，不功不过' AS content, '2026-08-13 11:44:05' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '面条口感好，牛肉拉面的肉给得少了些，还可以再优化' AS content, '2026-10-21 12:38:44' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '希望多几种时令菜轮换，还可以再优化' AS content, '2026-09-23 11:44:30' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 4 AS rating, '调味偏淡，但对身体好，还可以再优化' AS content, '2026-08-17 13:01:26' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 3 AS rating, '有点老，梗比较硬' AS content, '2026-08-29 13:47:46' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 3 AS rating, '分量偏少，一份不太够' AS content, '2026-10-11 19:22:21' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿' AS content, '2026-10-14 18:47:24' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 3 AS rating, '有点老，梗比较硬，有点失望' AS content, '2026-09-01 11:01:28' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 3 AS rating, '分量偏少，一份不太够，有点失望' AS content, '2026-09-16 13:12:03' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 3 AS rating, '温度不太够，感觉放了有一会儿，有点失望' AS content, '2026-10-01 18:02:52' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 2 AS rating, '有点老，梗比较硬，不太推荐' AS content, '2026-08-06 12:31:26' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 2 AS rating, '分量偏少，一份不太够，不太推荐' AS content, '2026-08-24 12:18:01' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 2 AS rating, '温度不太够，感觉放了有一会儿，不太推荐' AS content, '2026-09-11 12:42:41' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 2 AS rating, '有点老，梗比较硬，希望改进' AS content, '2026-08-19 11:21:37' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 1 AS rating, '分量偏少，一份不太够，希望改进' AS content, '2026-09-11 19:41:01' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 1 AS rating, '温度不太够，感觉放了有一会儿，希望改进' AS content, '2026-08-13 12:09:52' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 5 AS rating, '油不多，适合减脂' AS content, '2026-09-20 11:02:21' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌' AS content, '2026-09-23 12:32:49' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好' AS content, '2026-09-10 12:32:02' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 5 AS rating, '青菜很新鲜，颜色好看' AS content, '2026-10-02 17:38:45' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 5 AS rating, '清淡健康，常点' AS content, '2026-09-14 11:57:43' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 5 AS rating, '想吃面的时候随便来碗牛肉拉面，整体很满意' AS content, '2026-08-08 12:02:56' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 5 AS rating, '油不多，适合减脂，整体很满意' AS content, '2026-08-15 13:43:58' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 5 AS rating, '蒜香味足，炒得刚好不塌，整体很满意' AS content, '2026-09-25 17:09:17' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 5 AS rating, '蔬菜很嫩，火候掌握得好，整体很满意' AS content, '2026-09-18 13:18:55' AS created_at
  UNION ALL
  SELECT 'D031' AS code, 5 AS rating, '青菜很新鲜，颜色好看，整体很满意' AS content, '2026-08-24 19:03:55' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 3 AS rating, '面条煮得有点过，坨了' AS content, '2026-09-02 18:15:07' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 3 AS rating, '端上来就凉了，希望能保温' AS content, '2026-08-08 11:48:21' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 3 AS rating, '有点咸，下次少放点盐' AS content, '2026-08-11 17:11:56' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 2 AS rating, '面条煮得有点过，坨了，有点失望' AS content, '2026-08-08 19:47:32' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 2 AS rating, '端上来就凉了，希望能保温，有点失望' AS content, '2026-09-07 12:18:46' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 2 AS rating, '有点咸，下次少放点盐，有点失望' AS content, '2026-08-31 19:02:50' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 2 AS rating, '面条煮得有点过，坨了，不太推荐' AS content, '2026-09-23 12:11:38' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 1 AS rating, '端上来就凉了，希望能保温，不太推荐' AS content, '2026-09-26 18:15:32' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 1 AS rating, '有点咸，下次少放点盐，不太推荐' AS content, '2026-08-12 17:50:57' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '加个卤蛋会更好' AS content, '2026-08-13 19:16:04' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '出餐快，热乎的' AS content, '2026-09-20 18:11:28' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '面条是手擀的，口感很好' AS content, '2026-10-08 19:08:16' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '汤头浓郁，喝到见底' AS content, '2026-08-27 13:08:45' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '面条劲道，汤头不错' AS content, '2026-10-25 11:16:40' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '等了快二十分钟才拿到' AS content, '2026-09-02 17:18:16' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '面汤温度刚好，冬天吃很舒服' AS content, '2026-08-23 11:43:52' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '汤底很鲜，喝着舒服' AS content, '2026-10-21 18:43:10' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '配料给得实在' AS content, '2026-10-12 13:27:15' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D032' AS code, 5 AS rating, '分量足，一碗吃得很饱' AS content, '2026-09-29 12:33:35' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '加个卤蛋会更好，整体很满意' AS content, '2026-10-30 18:15:52' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '出餐快，热乎的，整体很满意' AS content, '2026-08-17 11:44:25' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '面条是手擀的，口感很好，整体很满意' AS content, '2026-08-12 19:00:44' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '汤头浓郁，喝到见底，整体很满意' AS content, '2026-09-02 13:51:46' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '面条劲道，汤头不错，整体很满意' AS content, '2026-10-20 17:04:26' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '等了快二十分钟才拿到，整体很满意' AS content, '2026-11-02 19:11:36' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '面汤温度刚好，冬天吃很舒服，整体很满意' AS content, '2026-10-22 11:44:08' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '汤底很鲜，喝着舒服，整体很满意' AS content, '2026-10-31 13:18:15' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '配料给得实在，整体很满意' AS content, '2026-10-30 13:27:46' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '分量足，一碗吃得很饱，整体很满意' AS content, '2026-08-16 13:08:40' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '加个卤蛋会更好，下次还会点' AS content, '2026-10-05 17:23:46' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '出餐快，热乎的，下次还会点' AS content, '2026-10-14 12:36:19' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 5 AS rating, '面条是手擀的，口感很好，下次还会点' AS content, '2026-10-05 12:46:32' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜' AS content, '2026-10-07 13:21:44' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说' AS content, '2026-10-10 19:27:37' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，整体还行' AS content, '2026-08-27 17:40:39' AS created_at
  UNION ALL
  SELECT 'D032' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，整体还行' AS content, '2026-10-22 18:26:48' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '汤头浓郁，喝到见底' AS content, '2026-09-12 17:54:40' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '面条是手擀的，口感很好' AS content, '2026-08-24 11:26:01' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '面条劲道，汤头不错' AS content, '2026-08-05 17:31:01' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '加个卤蛋会更好' AS content, '2026-10-21 17:46:11' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '面汤温度刚好，冬天吃很舒服' AS content, '2026-09-21 17:37:59' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '汤底很鲜，喝着舒服' AS content, '2026-10-12 12:00:52' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '配料给得实在' AS content, '2026-10-26 13:39:43' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '分量足，一碗吃得很饱' AS content, '2026-08-15 17:04:56' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '出餐快，热乎的' AS content, '2026-08-26 19:32:24' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '等了快二十分钟才拿到' AS content, '2026-08-13 19:34:21' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '汤头浓郁，喝到见底，整体很满意' AS content, '2026-10-04 11:22:51' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '面条是手擀的，口感很好，整体很满意' AS content, '2026-09-24 13:03:56' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '面条劲道，汤头不错，整体很满意' AS content, '2026-10-05 11:30:17' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 5 AS rating, '加个卤蛋会更好，整体很满意' AS content, '2026-10-30 13:36:23' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜' AS content, '2026-08-31 12:04:17' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说' AS content, '2026-10-05 18:36:00' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，整体还行' AS content, '2026-08-30 13:25:56' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，整体还行' AS content, '2026-08-15 17:15:00' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，但希望能改进' AS content, '2026-08-23 19:17:27' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，但希望能改进' AS content, '2026-09-04 17:46:13' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，不功不过' AS content, '2026-10-09 17:50:52' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，不功不过' AS content, '2026-09-16 19:02:07' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，还可以再优化' AS content, '2026-10-20 12:45:23' AS created_at
  UNION ALL
  SELECT 'D033' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，还可以再优化' AS content, '2026-08-23 13:35:05' AS created_at
  UNION ALL
  SELECT 'D034' AS code, 5 AS rating, '出餐快，热乎的' AS content, '2026-10-10 18:31:50' AS created_at
  UNION ALL
  SELECT 'D034' AS code, 5 AS rating, '分量足，一碗吃得很饱' AS content, '2026-08-15 13:23:36' AS created_at
  UNION ALL
  SELECT 'D034' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜' AS content, '2026-09-05 13:52:15' AS created_at
  UNION ALL
  SELECT 'D034' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说' AS content, '2026-11-01 18:23:21' AS created_at
  UNION ALL
  SELECT 'D034' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，整体还行' AS content, '2026-08-24 17:43:22' AS created_at
  UNION ALL
  SELECT 'D034' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，整体还行' AS content, '2026-09-04 12:46:06' AS created_at
  UNION ALL
  SELECT 'D034' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，但希望能改进' AS content, '2026-10-08 11:38:55' AS created_at
  UNION ALL
  SELECT 'D034' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，但希望能改进' AS content, '2026-08-30 12:32:59' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D034' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，不功不过' AS content, '2026-09-06 19:48:35' AS created_at
  UNION ALL
  SELECT 'D034' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，不功不过' AS content, '2026-08-09 13:39:44' AS created_at
  UNION ALL
  SELECT 'D034' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，还可以再优化' AS content, '2026-08-23 12:58:21' AS created_at
  UNION ALL
  SELECT 'D034' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，还可以再优化' AS content, '2026-10-28 11:18:13' AS created_at
  UNION ALL
  SELECT 'D035' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说' AS content, '2026-08-14 18:45:56' AS created_at
  UNION ALL
  SELECT 'D035' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜' AS content, '2026-08-22 18:12:57' AS created_at
  UNION ALL
  SELECT 'D035' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，整体还行' AS content, '2026-08-10 13:22:48' AS created_at
  UNION ALL
  SELECT 'D035' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，整体还行' AS content, '2026-10-04 18:07:10' AS created_at
  UNION ALL
  SELECT 'D035' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，但希望能改进' AS content, '2026-10-07 19:36:44' AS created_at
  UNION ALL
  SELECT 'D035' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，但希望能改进' AS content, '2026-10-29 11:54:43' AS created_at
  UNION ALL
  SELECT 'D035' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，不功不过' AS content, '2026-10-03 18:45:27' AS created_at
  UNION ALL
  SELECT 'D035' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，不功不过' AS content, '2026-08-23 18:39:06' AS created_at
  UNION ALL
  SELECT 'D035' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，还可以再优化' AS content, '2026-08-05 12:19:27' AS created_at
  UNION ALL
  SELECT 'D035' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，还可以再优化' AS content, '2026-10-26 19:15:59' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说' AS content, '2026-10-31 12:30:37' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜' AS content, '2026-08-14 11:17:42' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，整体还行' AS content, '2026-09-07 18:12:05' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，整体还行' AS content, '2026-10-18 17:35:29' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 4 AS rating, '面条偏软，喜欢更硬的可以提前说，但希望能改进' AS content, '2026-10-31 12:43:44' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 4 AS rating, '配菜少了一些，希望能加点青菜，但希望能改进' AS content, '2026-09-27 11:45:50' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 3 AS rating, '端上来就凉了，希望能保温' AS content, '2026-08-20 13:18:23' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 3 AS rating, '面条煮得有点过，坨了' AS content, '2026-09-20 17:23:08' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 3 AS rating, '有点咸，下次少放点盐' AS content, '2026-10-29 19:37:40' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 3 AS rating, '端上来就凉了，希望能保温，有点失望' AS content, '2026-09-21 11:48:06' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 3 AS rating, '面条煮得有点过，坨了，有点失望' AS content, '2026-10-22 19:26:09' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 3 AS rating, '有点咸，下次少放点盐，有点失望' AS content, '2026-10-08 11:20:51' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 2 AS rating, '端上来就凉了，希望能保温，不太推荐' AS content, '2026-10-16 11:43:28' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 2 AS rating, '面条煮得有点过，坨了，不太推荐' AS content, '2026-09-26 13:59:19' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 2 AS rating, '有点咸，下次少放点盐，不太推荐' AS content, '2026-08-15 13:45:31' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 2 AS rating, '端上来就凉了，希望能保温，希望改进' AS content, '2026-10-10 12:39:16' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 1 AS rating, '面条煮得有点过，坨了，希望改进' AS content, '2026-09-15 18:16:52' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 1 AS rating, '有点咸，下次少放点盐，希望改进' AS content, '2026-08-14 18:20:58' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '出餐快，热乎的' AS content, '2026-10-13 18:48:21' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '汤底很鲜，喝着舒服' AS content, '2026-08-19 11:37:51' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '加个卤蛋会更好' AS content, '2026-10-04 13:28:47' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '分量足，一碗吃得很饱' AS content, '2026-09-10 12:33:52' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '等了快二十分钟才拿到' AS content, '2026-09-15 11:51:36' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '汤头浓郁，喝到见底' AS content, '2026-10-07 19:24:09' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '面条是手擀的，口感很好' AS content, '2026-08-15 12:17:40' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '配料给得实在' AS content, '2026-09-27 12:18:03' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '面条劲道，汤头不错' AS content, '2026-09-21 19:33:51' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '面汤温度刚好，冬天吃很舒服' AS content, '2026-08-28 11:20:48' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '出餐快，热乎的，整体很满意' AS content, '2026-10-17 12:27:09' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '汤底很鲜，喝着舒服，整体很满意' AS content, '2026-09-01 19:57:42' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '加个卤蛋会更好，整体很满意' AS content, '2026-08-26 11:05:17' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '分量足，一碗吃得很饱，整体很满意' AS content, '2026-09-27 11:24:11' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '等了快二十分钟才拿到，整体很满意' AS content, '2026-08-24 18:29:53' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '汤头浓郁，喝到见底，整体很满意' AS content, '2026-11-02 17:50:32' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '面条是手擀的，口感很好，整体很满意' AS content, '2026-08-17 17:26:18' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '配料给得实在，整体很满意' AS content, '2026-09-11 13:49:50' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D036' AS code, 5 AS rating, '面条劲道，汤头不错，整体很满意' AS content, '2026-09-28 11:17:18' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '面汤温度刚好，冬天吃很舒服，整体很满意' AS content, '2026-09-22 13:15:34' AS created_at
  UNION ALL
  SELECT 'D036' AS code, 5 AS rating, '出餐快，热乎的，下次还会点' AS content, '2026-09-08 17:40:28' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '汤色清亮，看着干净' AS content, '2026-09-25 12:13:57' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '稍微有点油花，不碍事' AS content, '2026-10-05 17:53:06' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '上得很快，配饭刚好' AS content, '2026-08-18 13:17:22' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '汤底很鲜，饭前喝一碗很舒服' AS content, '2026-10-03 12:47:21' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '温度刚好，暖胃' AS content, '2026-10-16 19:19:51' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '料有点少，主要是汤' AS content, '2026-08-28 17:24:19' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '分量足，一碗喝得很满足' AS content, '2026-10-19 17:46:55' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '冬天喝这个很治愈' AS content, '2026-09-19 11:26:30' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '味道清淡，适合搭配主食' AS content, '2026-09-28 17:55:53' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '汤里料很实在，不止是清汤' AS content, '2026-09-04 17:32:02' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '料给得足，捞得到东西' AS content, '2026-09-09 17:40:32' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '份量偏小，几口就见底了' AS content, '2026-09-06 12:27:13' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '汤色清亮，看着干净，整体很满意' AS content, '2026-08-08 18:11:04' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '稍微有点油花，不碍事，整体很满意' AS content, '2026-08-17 17:14:26' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '上得很快，配饭刚好，整体很满意' AS content, '2026-10-11 13:03:19' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '汤底很鲜，饭前喝一碗很舒服，整体很满意' AS content, '2026-08-23 17:08:30' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '温度刚好，暖胃，整体很满意' AS content, '2026-10-16 11:18:33' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '料有点少，主要是汤，整体很满意' AS content, '2026-09-08 11:07:51' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '分量足，一碗喝得很满足，整体很满意' AS content, '2026-08-07 17:16:17' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '冬天喝这个很治愈，整体很满意' AS content, '2026-08-30 13:37:38' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 5 AS rating, '味道清淡，适合搭配主食，整体很满意' AS content, '2026-10-13 19:18:57' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '汤里料很实在，不止是清汤，整体很满意' AS content, '2026-09-05 11:47:49' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '料给得足，捞得到东西，整体很满意' AS content, '2026-08-15 18:20:14' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '份量偏小，几口就见底了，整体很满意' AS content, '2026-10-11 17:32:11' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '汤色清亮，看着干净，下次还会点' AS content, '2026-10-21 12:08:37' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '稍微有点油花，不碍事，下次还会点' AS content, '2026-09-05 13:11:17' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '上得很快，配饭刚好，下次还会点' AS content, '2026-10-25 19:01:58' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '汤底很鲜，饭前喝一碗很舒服，下次还会点' AS content, '2026-10-12 18:38:07' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '温度刚好，暖胃，下次还会点' AS content, '2026-10-16 18:53:34' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '料有点少，主要是汤，下次还会点' AS content, '2026-09-19 11:10:09' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '分量足，一碗喝得很满足，下次还会点' AS content, '2026-08-16 18:36:52' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '冬天喝这个很治愈，下次还会点' AS content, '2026-08-10 11:22:29' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '味道清淡，适合搭配主食，下次还会点' AS content, '2026-10-05 18:18:54' AS created_at
  UNION ALL
  SELECT 'D037' AS code, 4 AS rating, '汤里料很实在，不止是清汤，下次还会点' AS content, '2026-10-09 17:35:06' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 5 AS rating, '上得很快，配饭刚好' AS content, '2026-10-03 19:56:05' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 5 AS rating, '料给得足，捞得到东西' AS content, '2026-10-02 11:45:13' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 5 AS rating, '味道清淡，适合搭配主食' AS content, '2026-09-14 19:49:55' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 5 AS rating, '稍微有点油花，不碍事' AS content, '2026-10-29 13:36:23' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '汤里料很实在，不止是清汤' AS content, '2026-10-12 12:20:38' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '分量足，一碗喝得很满足' AS content, '2026-08-07 19:38:06' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '份量偏小，几口就见底了' AS content, '2026-09-11 17:43:00' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '冬天喝这个很治愈' AS content, '2026-09-08 17:32:04' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '料有点少，主要是汤' AS content, '2026-10-10 13:36:25' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '温度刚好，暖胃' AS content, '2026-09-09 18:47:25' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '汤底很鲜，饭前喝一碗很舒服' AS content, '2026-08-21 12:11:01' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '汤色清亮，看着干净' AS content, '2026-09-02 11:33:04' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '上得很快，配饭刚好，整体很满意' AS content, '2026-09-10 12:48:29' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D038' AS code, 4 AS rating, '料给得足，捞得到东西，整体很满意' AS content, '2026-10-15 12:08:44' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '味道清淡，适合搭配主食，整体很满意' AS content, '2026-09-03 18:31:26' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '稍微有点油花，不碍事，整体很满意' AS content, '2026-09-06 12:01:31' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '汤里料很实在，不止是清汤，整体很满意' AS content, '2026-09-29 13:43:00' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '分量足，一碗喝得很满足，整体很满意' AS content, '2026-09-13 19:58:51' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 4 AS rating, '份量偏小，几口就见底了，整体很满意' AS content, '2026-10-26 17:49:59' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 3 AS rating, '有点咸，希望淡一点' AS content, '2026-09-27 12:42:26' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 3 AS rating, '有点咸，希望淡一点，有点失望' AS content, '2026-08-23 12:12:17' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 3 AS rating, '有点咸，希望淡一点，不太推荐' AS content, '2026-09-08 19:38:37' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 3 AS rating, '有点咸，希望淡一点，希望改进' AS content, '2026-10-27 12:38:30' AS created_at
  UNION ALL
  SELECT 'D038' AS code, 3 AS rating, '有点咸，希望淡一点，下次可能不点了' AS content, '2026-10-02 11:59:33' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 4 AS rating, '上得很快，配饭刚好' AS content, '2026-10-15 18:15:52' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 4 AS rating, '冬天喝这个很治愈' AS content, '2026-08-08 19:48:00' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 4 AS rating, '稍微有点油花，不碍事' AS content, '2026-09-05 17:23:11' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 4 AS rating, '汤底很鲜，饭前喝一碗很舒服' AS content, '2026-09-24 11:10:33' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 4 AS rating, '汤色清亮，看着干净' AS content, '2026-08-20 18:47:11' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 4 AS rating, '料有点少，主要是汤' AS content, '2026-08-23 18:27:42' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 4 AS rating, '料给得足，捞得到东西' AS content, '2026-09-09 18:23:26' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 3 AS rating, '有点咸，希望淡一点' AS content, '2026-10-31 11:55:27' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 3 AS rating, '有点咸，希望淡一点，有点失望' AS content, '2026-09-01 18:34:24' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 3 AS rating, '有点咸，希望淡一点，不太推荐' AS content, '2026-09-07 19:41:44' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 3 AS rating, '有点咸，希望淡一点，希望改进' AS content, '2026-10-22 11:33:42' AS created_at
  UNION ALL
  SELECT 'D039' AS code, 3 AS rating, '有点咸，希望淡一点，下次可能不点了' AS content, '2026-10-21 17:40:52' AS created_at
  UNION ALL
  SELECT 'D040' AS code, 4 AS rating, '奶味很浓，甜度刚好' AS content, '2026-09-30 11:58:44' AS created_at
  UNION ALL
  SELECT 'D040' AS code, 3 AS rating, '量有点少，价格可以再低点' AS content, '2026-08-20 19:57:40' AS created_at
  UNION ALL
  SELECT 'D040' AS code, 3 AS rating, '有点太甜了，希望能选无糖' AS content, '2026-10-22 11:36:29' AS created_at
  UNION ALL
  SELECT 'D040' AS code, 3 AS rating, '量有点少，价格可以再低点，有点失望' AS content, '2026-10-22 18:16:25' AS created_at
  UNION ALL
  SELECT 'D040' AS code, 3 AS rating, '有点太甜了，希望能选无糖，有点失望' AS content, '2026-08-28 17:27:52' AS created_at
  UNION ALL
  SELECT 'D040' AS code, 3 AS rating, '量有点少，价格可以再低点，不太推荐' AS content, '2026-09-29 13:00:20' AS created_at
  UNION ALL
  SELECT 'D040' AS code, 3 AS rating, '有点太甜了，希望能选无糖，不太推荐' AS content, '2026-10-29 13:36:59' AS created_at
  UNION ALL
  SELECT 'D040' AS code, 2 AS rating, '量有点少，价格可以再低点，希望改进' AS content, '2026-09-30 13:10:45' AS created_at
  UNION ALL
  SELECT 'D040' AS code, 2 AS rating, '有点太甜了，希望能选无糖，希望改进' AS content, '2026-09-11 18:42:18' AS created_at
  UNION ALL
  SELECT 'D040' AS code, 2 AS rating, '量有点少，价格可以再低点，下次可能不点了' AS content, '2026-08-28 13:45:54' AS created_at
  UNION ALL
  SELECT 'D040' AS code, 2 AS rating, '有点太甜了，希望能选无糖，下次可能不点了' AS content, '2026-08-31 13:43:53' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 3 AS rating, '量有点少，价格可以再低点' AS content, '2026-09-30 17:09:59' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 3 AS rating, '有点太甜了，希望能选无糖' AS content, '2026-09-30 11:51:23' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 2 AS rating, '量有点少，价格可以再低点，有点失望' AS content, '2026-09-09 12:11:26' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 2 AS rating, '有点太甜了，希望能选无糖，有点失望' AS content, '2026-10-08 19:57:50' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 2 AS rating, '量有点少，价格可以再低点，不太推荐' AS content, '2026-10-01 13:55:55' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 2 AS rating, '有点太甜了，希望能选无糖，不太推荐' AS content, '2026-10-03 13:41:08' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 1 AS rating, '量有点少，价格可以再低点，希望改进' AS content, '2026-09-06 11:04:43' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 1 AS rating, '有点太甜了，希望能选无糖，希望改进' AS content, '2026-09-12 13:46:24' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '喝着清爽，饭后解腻' AS content, '2026-10-04 12:05:44' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '冰的量很足，夏天喝着爽' AS content, '2026-11-01 11:55:17' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '奶味很浓，甜度刚好' AS content, '2026-10-04 17:25:54' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '价格便宜，解渴' AS content, '2026-10-08 13:17:46' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '温度合适，不会太冰' AS content, '2026-10-13 12:08:24' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '甜度控制得不错，不会太腻' AS content, '2026-09-03 12:45:08' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '杯子偏小，几口就没了' AS content, '2026-09-23 11:11:43' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '料给得实在，捞得到果肉' AS content, '2026-09-23 18:55:23' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D041' AS code, 5 AS rating, '口味稳定，常买' AS content, '2026-09-23 12:06:21' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '包装干净，吸管给得很到位' AS content, '2026-10-04 13:28:58' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '喝着清爽，饭后解腻，整体很满意' AS content, '2026-08-26 11:47:32' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '冰的量很足，夏天喝着爽，整体很满意' AS content, '2026-10-26 19:41:00' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '奶味很浓，甜度刚好，整体很满意' AS content, '2026-10-24 19:50:01' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '价格便宜，解渴，整体很满意' AS content, '2026-08-24 19:13:13' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '温度合适，不会太冰，整体很满意' AS content, '2026-10-31 17:07:35' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '甜度控制得不错，不会太腻，整体很满意' AS content, '2026-10-13 12:16:41' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '杯子偏小，几口就没了，整体很满意' AS content, '2026-09-16 18:48:28' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '料给得实在，捞得到果肉，整体很满意' AS content, '2026-08-31 19:33:24' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '口味稳定，常买，整体很满意' AS content, '2026-11-02 17:38:55' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '包装干净，吸管给得很到位，整体很满意' AS content, '2026-09-10 12:13:54' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '喝着清爽，饭后解腻，下次还会点' AS content, '2026-09-14 11:06:37' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '冰的量很足，夏天喝着爽，下次还会点' AS content, '2026-09-11 13:25:26' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 5 AS rating, '奶味很浓，甜度刚好，下次还会点' AS content, '2026-09-09 19:19:57' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 4 AS rating, '价格便宜，解渴，下次还会点' AS content, '2026-10-14 11:18:52' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 4 AS rating, '温度合适，不会太冰，下次还会点' AS content, '2026-08-31 18:40:03' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 4 AS rating, '甜度控制得不错，不会太腻，下次还会点' AS content, '2026-09-21 18:06:55' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 4 AS rating, '杯子偏小，几口就没了，下次还会点' AS content, '2026-09-03 11:44:04' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 4 AS rating, '料给得实在，捞得到果肉，下次还会点' AS content, '2026-10-10 13:32:58' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 4 AS rating, '口味稳定，常买，下次还会点' AS content, '2026-08-29 13:20:08' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 4 AS rating, '包装干净，吸管给得很到位，下次还会点' AS content, '2026-08-15 13:07:47' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 4 AS rating, '喝着清爽，饭后解腻，希望保持这个水准' AS content, '2026-09-13 11:54:47' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 4 AS rating, '冰的量很足，夏天喝着爽，希望保持这个水准' AS content, '2026-08-25 19:58:12' AS created_at
  UNION ALL
  SELECT 'D041' AS code, 4 AS rating, '奶味很浓，甜度刚好，希望保持这个水准' AS content, '2026-09-20 17:54:18' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 5 AS rating, '杯子偏小，几口就没了' AS content, '2026-10-23 17:18:05' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 5 AS rating, '包装干净，吸管给得很到位' AS content, '2026-09-25 13:12:20' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 5 AS rating, '温度合适，不会太冰' AS content, '2026-10-19 19:22:40' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 5 AS rating, '口味稳定，常买' AS content, '2026-10-03 13:47:14' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 5 AS rating, '喝着清爽，饭后解腻' AS content, '2026-09-04 13:10:31' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 5 AS rating, '价格便宜，解渴' AS content, '2026-08-13 19:08:38' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 5 AS rating, '甜度控制得不错，不会太腻' AS content, '2026-08-09 13:50:26' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 5 AS rating, '料给得实在，捞得到果肉' AS content, '2026-10-11 12:59:41' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 5 AS rating, '冰的量很足，夏天喝着爽' AS content, '2026-08-26 19:08:07' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 5 AS rating, '奶味很浓，甜度刚好' AS content, '2026-08-28 17:50:39' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '杯子偏小，几口就没了，整体很满意' AS content, '2026-08-22 18:22:31' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '包装干净，吸管给得很到位，整体很满意' AS content, '2026-08-09 19:18:01' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '温度合适，不会太冰，整体很满意' AS content, '2026-10-25 17:20:09' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '口味稳定，常买，整体很满意' AS content, '2026-09-18 19:09:22' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '喝着清爽，饭后解腻，整体很满意' AS content, '2026-10-22 18:15:21' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '价格便宜，解渴，整体很满意' AS content, '2026-09-20 17:48:03' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '甜度控制得不错，不会太腻，整体很满意' AS content, '2026-08-09 11:43:51' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '料给得实在，捞得到果肉，整体很满意' AS content, '2026-09-06 11:53:46' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '冰的量很足，夏天喝着爽，整体很满意' AS content, '2026-08-08 19:52:37' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '奶味很浓，甜度刚好，整体很满意' AS content, '2026-08-23 18:47:05' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '杯子偏小，几口就没了，下次还会点' AS content, '2026-08-30 19:21:34' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '包装干净，吸管给得很到位，下次还会点' AS content, '2026-09-04 17:42:44' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '温度合适，不会太冰，下次还会点' AS content, '2026-10-19 19:14:50' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '口味稳定，常买，下次还会点' AS content, '2026-08-15 13:11:38' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 4 AS rating, '喝着清爽，饭后解腻，下次还会点' AS content, '2026-10-22 12:30:40' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D042' AS code, 3 AS rating, '量有点少，价格可以再低点' AS content, '2026-10-07 12:24:39' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 3 AS rating, '有点太甜了，希望能选无糖' AS content, '2026-09-29 17:00:37' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 3 AS rating, '量有点少，价格可以再低点，有点失望' AS content, '2026-08-20 17:58:07' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 3 AS rating, '有点太甜了，希望能选无糖，有点失望' AS content, '2026-09-16 12:40:01' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 3 AS rating, '量有点少，价格可以再低点，不太推荐' AS content, '2026-08-18 18:40:59' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 3 AS rating, '有点太甜了，希望能选无糖，不太推荐' AS content, '2026-10-12 19:58:55' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 2 AS rating, '量有点少，价格可以再低点，希望改进' AS content, '2026-11-01 17:58:39' AS created_at
  UNION ALL
  SELECT 'D042' AS code, 2 AS rating, '有点太甜了，希望能选无糖，希望改进' AS content, '2026-09-24 12:07:12' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 4 AS rating, '肉很正，就是烧鸭饭的饭给得少了点' AS content, '2026-09-08 17:46:09' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 4 AS rating, '烧鸭饭好吃，配的青菜有点凉' AS content, '2026-08-13 18:57:19' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 4 AS rating, '肉很正，就是烧鸭饭的饭给得少了点，整体还行' AS content, '2026-09-11 12:52:45' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 4 AS rating, '烧鸭饭好吃，配的青菜有点凉，整体还行' AS content, '2026-08-18 17:10:15' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 4 AS rating, '肉很正，就是烧鸭饭的饭给得少了点，但希望能改进' AS content, '2026-09-12 13:54:11' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 4 AS rating, '烧鸭饭好吃，配的青菜有点凉，但希望能改进' AS content, '2026-10-11 19:06:19' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 4 AS rating, '肉很正，就是烧鸭饭的饭给得少了点，不功不过' AS content, '2026-08-05 11:57:34' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 4 AS rating, '烧鸭饭好吃，配的青菜有点凉，不功不过' AS content, '2026-08-30 12:37:45' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 4 AS rating, '肉很正，就是烧鸭饭的饭给得少了点，还可以再优化' AS content, '2026-10-10 13:19:28' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 3 AS rating, '味道一般，烧鸭饭价格偏贵' AS content, '2026-08-17 12:35:02' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 3 AS rating, '有点太甜了，希望能选无糖' AS content, '2026-08-17 19:10:15' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 3 AS rating, '量有点少，价格可以再低点' AS content, '2026-10-17 19:32:46' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 3 AS rating, '味道一般，烧鸭饭价格偏贵，有点失望' AS content, '2026-10-11 11:18:34' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 3 AS rating, '有点太甜了，希望能选无糖，有点失望' AS content, '2026-10-10 19:05:56' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 3 AS rating, '量有点少，价格可以再低点，有点失望' AS content, '2026-08-16 11:49:54' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 2 AS rating, '味道一般，烧鸭饭价格偏贵，不太推荐' AS content, '2026-10-18 13:37:35' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 2 AS rating, '有点太甜了，希望能选无糖，不太推荐' AS content, '2026-10-03 18:41:27' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 2 AS rating, '量有点少，价格可以再低点，不太推荐' AS content, '2026-09-12 11:07:10' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 2 AS rating, '味道一般，烧鸭饭价格偏贵，希望改进' AS content, '2026-09-24 13:23:01' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 1 AS rating, '有点太甜了，希望能选无糖，希望改进' AS content, '2026-09-11 13:44:04' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 1 AS rating, '量有点少，价格可以再低点，希望改进' AS content, '2026-08-20 17:29:05' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '价格便宜，解渴' AS content, '2026-10-29 19:18:16' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '喝着清爽，饭后解腻' AS content, '2026-10-15 12:41:18' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '烧鸭饭算是普通盒饭水平' AS content, '2026-10-25 11:48:55' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '烧鸭饭配的卤蛋入味，青菜也清爽' AS content, '2026-09-11 17:16:31' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '杯子偏小，几口就没了' AS content, '2026-10-12 19:10:57' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '这次烧鸭饭的肉有点发干，不入味' AS content, '2026-09-21 17:10:16' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '冰的量很足，夏天喝着爽' AS content, '2026-08-10 19:29:44' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '包装干净，吸管给得很到位' AS content, '2026-10-28 17:10:16' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '每天都想吃烧鸭饭，可惜是限量的' AS content, '2026-10-11 12:42:43' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '口味稳定，常买' AS content, '2026-08-08 17:10:54' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '烧鸭饭的肉肥瘦相间，蜜汁调得正好' AS content, '2026-10-26 11:20:59' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '烧鸭饭的肉给得挺多，一个人吃完全够' AS content, '2026-08-15 19:47:06' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '整体满意，烧鸭饭价格稍微高一点' AS content, '2026-09-13 11:13:39' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '甜度控制得不错，不会太腻' AS content, '2026-08-08 11:03:53' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '肉有股怪味，烧鸭饭不太新鲜' AS content, '2026-09-30 12:03:53' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '烧鸭饭出品挺稳，偶尔肉会偏柴' AS content, '2026-08-18 19:47:18' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '料给得实在，捞得到果肉' AS content, '2026-10-17 13:42:40' AS created_at
  UNION ALL
  SELECT 'D043' AS code, 5 AS rating, '温度合适，不会太冰' AS content, '2026-08-21 13:59:49' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 1 AS rating, '有点油炸味，希望换新油' AS content, '2026-08-09 17:06:06' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 1 AS rating, '味道不错，就是数量偏少' AS content, '2026-10-13 17:18:01' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '价格对学生党友好' AS content, '2026-10-22 17:10:02' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D044' AS code, 5 AS rating, '当加餐刚好，不会太撑' AS content, '2026-09-25 19:57:12' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '个头不小，性价比可以' AS content, '2026-08-27 19:03:02' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '现做的，拿到手还是烫的' AS content, '2026-09-21 11:00:20' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '外皮酥脆，内里软嫩' AS content, '2026-10-24 13:50:59' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '价格对学生党友好，整体很满意' AS content, '2026-10-20 17:55:44' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '当加餐刚好，不会太撑，整体很满意' AS content, '2026-08-22 12:26:15' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '个头不小，性价比可以，整体很满意' AS content, '2026-09-22 17:33:51' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '现做的，拿到手还是烫的，整体很满意' AS content, '2026-08-07 17:27:32' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '外皮酥脆，内里软嫩，整体很满意' AS content, '2026-08-22 17:20:14' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '价格对学生党友好，下次还会点' AS content, '2026-09-07 12:37:11' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '当加餐刚好，不会太撑，下次还会点' AS content, '2026-08-21 17:00:23' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '个头不小，性价比可以，下次还会点' AS content, '2026-09-26 19:14:02' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '现做的，拿到手还是烫的，下次还会点' AS content, '2026-09-15 17:19:39' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '外皮酥脆，内里软嫩，下次还会点' AS content, '2026-08-26 18:44:38' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '价格对学生党友好，希望保持这个水准' AS content, '2026-09-17 12:59:14' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '当加餐刚好，不会太撑，希望保持这个水准' AS content, '2026-10-19 19:55:21' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '个头不小，性价比可以，希望保持这个水准' AS content, '2026-08-22 13:19:06' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '现做的，拿到手还是烫的，希望保持这个水准' AS content, '2026-08-12 12:39:34' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '外皮酥脆，内里软嫩，希望保持这个水准' AS content, '2026-09-07 18:20:28' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '价格对学生党友好，值得推荐' AS content, '2026-08-06 11:01:01' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 5 AS rating, '当加餐刚好，不会太撑，值得推荐' AS content, '2026-08-12 13:44:06' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 4 AS rating, '个头不小，性价比可以，值得推荐' AS content, '2026-08-08 17:57:09' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 4 AS rating, '现做的，拿到手还是烫的，值得推荐' AS content, '2026-08-07 13:57:12' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 4 AS rating, '外皮酥脆，内里软嫩，值得推荐' AS content, '2026-10-31 18:22:39' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 4 AS rating, '价格对学生党友好，会安利给同学' AS content, '2026-08-18 13:47:52' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 4 AS rating, '当加餐刚好，不会太撑，会安利给同学' AS content, '2026-10-27 18:59:19' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 4 AS rating, '个头不小，性价比可以，会安利给同学' AS content, '2026-11-02 12:37:35' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 4 AS rating, '现做的，拿到手还是烫的，会安利给同学' AS content, '2026-09-30 19:01:04' AS created_at
  UNION ALL
  SELECT 'D044' AS code, 4 AS rating, '外皮酥脆，内里软嫩，会安利给同学' AS content, '2026-10-10 13:50:26' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 5 AS rating, '当加餐刚好，不会太撑' AS content, '2026-09-30 18:51:08' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 5 AS rating, '价格对学生党友好' AS content, '2026-10-26 18:18:09' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 5 AS rating, '个头不小，性价比可以' AS content, '2026-10-23 11:21:08' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 5 AS rating, '外皮酥脆，内里软嫩' AS content, '2026-09-19 19:32:34' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 5 AS rating, '现做的，拿到手还是烫的' AS content, '2026-10-23 12:43:00' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 5 AS rating, '当加餐刚好，不会太撑，整体很满意' AS content, '2026-08-15 18:17:35' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 5 AS rating, '价格对学生党友好，整体很满意' AS content, '2026-08-22 18:42:11' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 5 AS rating, '个头不小，性价比可以，整体很满意' AS content, '2026-10-18 12:36:34' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '外皮酥脆，内里软嫩，整体很满意' AS content, '2026-10-29 19:25:33' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '现做的，拿到手还是烫的，整体很满意' AS content, '2026-10-10 18:20:23' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '当加餐刚好，不会太撑，下次还会点' AS content, '2026-10-13 18:18:04' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '价格对学生党友好，下次还会点' AS content, '2026-08-13 18:29:28' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '个头不小，性价比可以，下次还会点' AS content, '2026-09-18 18:26:32' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '外皮酥脆，内里软嫩，下次还会点' AS content, '2026-08-05 19:03:43' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '现做的，拿到手还是烫的，下次还会点' AS content, '2026-09-30 17:34:23' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '当加餐刚好，不会太撑，希望保持这个水准' AS content, '2026-10-21 12:14:32' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '价格对学生党友好，希望保持这个水准' AS content, '2026-09-26 12:09:15' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '个头不小，性价比可以，希望保持这个水准' AS content, '2026-11-01 17:03:32' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '外皮酥脆，内里软嫩，希望保持这个水准' AS content, '2026-08-16 13:05:30' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '现做的，拿到手还是烫的，希望保持这个水准' AS content, '2026-08-06 13:00:28' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '当加餐刚好，不会太撑，值得推荐' AS content, '2026-08-27 11:42:00' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D045' AS code, 4 AS rating, '价格对学生党友好，值得推荐' AS content, '2026-10-19 18:24:23' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 4 AS rating, '个头不小，性价比可以，值得推荐' AS content, '2026-08-24 12:26:02' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 3 AS rating, '味道不错，就是数量偏少' AS content, '2026-08-25 18:20:23' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 3 AS rating, '有点油炸味，希望换新油' AS content, '2026-10-08 11:36:52' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 3 AS rating, '冷了以后口感差挺多，建议趁热吃' AS content, '2026-10-26 11:40:59' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 3 AS rating, '味道不错，就是数量偏少，有点失望' AS content, '2026-11-02 18:22:50' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 3 AS rating, '有点油炸味，希望换新油，有点失望' AS content, '2026-08-23 19:24:57' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 3 AS rating, '冷了以后口感差挺多，建议趁热吃，有点失望' AS content, '2026-08-16 19:21:47' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 2 AS rating, '味道不错，就是数量偏少，不太推荐' AS content, '2026-08-28 18:30:32' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 2 AS rating, '有点油炸味，希望换新油，不太推荐' AS content, '2026-09-24 12:25:33' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 2 AS rating, '冷了以后口感差挺多，建议趁热吃，不太推荐' AS content, '2026-10-16 12:25:14' AS created_at
  UNION ALL
  SELECT 'D045' AS code, 2 AS rating, '味道不错，就是数量偏少，希望改进' AS content, '2026-08-24 12:10:32' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 4 AS rating, '现做的，拿到手还是烫的' AS content, '2026-09-20 17:28:08' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 4 AS rating, '价格对学生党友好' AS content, '2026-08-05 17:04:07' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 4 AS rating, '当加餐刚好，不会太撑' AS content, '2026-08-21 13:02:10' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 4 AS rating, '外皮酥脆，内里软嫩' AS content, '2026-11-02 17:42:33' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 4 AS rating, '个头不小，性价比可以' AS content, '2026-10-02 19:24:23' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 4 AS rating, '现做的，拿到手还是烫的，整体很满意' AS content, '2026-10-07 11:50:14' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 4 AS rating, '价格对学生党友好，整体很满意' AS content, '2026-09-09 17:30:42' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 3 AS rating, '冷了以后口感差挺多，建议趁热吃' AS content, '2026-09-01 12:07:32' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 3 AS rating, '有点油炸味，希望换新油' AS content, '2026-10-02 17:04:40' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 3 AS rating, '味道不错，就是数量偏少' AS content, '2026-08-05 17:25:57' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 3 AS rating, '冷了以后口感差挺多，建议趁热吃，有点失望' AS content, '2026-11-01 12:25:41' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 3 AS rating, '有点油炸味，希望换新油，有点失望' AS content, '2026-08-29 12:50:29' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 3 AS rating, '味道不错，就是数量偏少，有点失望' AS content, '2026-08-05 11:53:34' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 2 AS rating, '冷了以后口感差挺多，建议趁热吃，不太推荐' AS content, '2026-08-07 19:19:41' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 2 AS rating, '有点油炸味，希望换新油，不太推荐' AS content, '2026-09-17 11:38:13' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 2 AS rating, '味道不错，就是数量偏少，不太推荐' AS content, '2026-08-29 19:06:45' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 2 AS rating, '冷了以后口感差挺多，建议趁热吃，希望改进' AS content, '2026-08-31 11:48:46' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 1 AS rating, '有点油炸味，希望换新油，希望改进' AS content, '2026-09-13 17:02:34' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 1 AS rating, '味道不错，就是数量偏少，希望改进' AS content, '2026-10-14 18:22:57' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '当加餐刚好，不会太撑，整体很满意' AS content, '2026-09-06 17:04:47' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '外皮酥脆，内里软嫩，整体很满意' AS content, '2026-09-04 19:21:03' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '个头不小，性价比可以，整体很满意' AS content, '2026-10-11 19:42:21' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '现做的，拿到手还是烫的，下次还会点' AS content, '2026-08-13 11:22:56' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '价格对学生党友好，下次还会点' AS content, '2026-08-26 19:38:42' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '当加餐刚好，不会太撑，下次还会点' AS content, '2026-09-13 13:47:32' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '外皮酥脆，内里软嫩，下次还会点' AS content, '2026-09-12 19:29:40' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '个头不小，性价比可以，下次还会点' AS content, '2026-10-23 13:50:23' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '现做的，拿到手还是烫的，希望保持这个水准' AS content, '2026-08-27 11:41:37' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '价格对学生党友好，希望保持这个水准' AS content, '2026-09-21 11:16:25' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '当加餐刚好，不会太撑，希望保持这个水准' AS content, '2026-10-22 18:48:54' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '外皮酥脆，内里软嫩，希望保持这个水准' AS content, '2026-08-20 11:04:12' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '个头不小，性价比可以，希望保持这个水准' AS content, '2026-10-10 13:57:24' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '现做的，拿到手还是烫的，值得推荐' AS content, '2026-10-13 19:20:10' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '价格对学生党友好，值得推荐' AS content, '2026-10-09 11:21:18' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '当加餐刚好，不会太撑，值得推荐' AS content, '2026-10-01 18:06:37' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '外皮酥脆，内里软嫩，值得推荐' AS content, '2026-10-01 19:41:50' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '个头不小，性价比可以，值得推荐' AS content, '2026-09-18 13:31:34' AS created_at
  UNION ALL
  SELECT 'D046' AS code, 5 AS rating, '现做的，拿到手还是烫的，会安利给同学' AS content, '2026-09-30 12:28:56' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at
FROM (
  SELECT 'D046' AS code, 5 AS rating, '价格对学生党友好，会安利给同学' AS content, '2026-08-13 18:43:07' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '白切鸡饭配的卤蛋入味，青菜也清爽' AS content, '2026-10-27 19:45:11' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '白切鸡饭的肉给得挺多，一个人吃完全够' AS content, '2026-10-11 19:39:11' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '个头不小，性价比可以' AS content, '2026-09-21 12:24:58' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '白切鸡饭的肉肥瘦相间，蜜汁调得正好' AS content, '2026-10-25 19:52:34' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '外皮酥脆，内里软嫩' AS content, '2026-09-25 19:24:35' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '食堂里能吃到这个水平的白切鸡饭挺惊喜' AS content, '2026-09-06 13:36:18' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '当加餐刚好，不会太撑' AS content, '2026-10-07 13:30:48' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '白切鸡饭肉质很嫩，蘸料也地道' AS content, '2026-10-27 18:40:58' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '现做的，拿到手还是烫的' AS content, '2026-09-08 17:50:37' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '价格对学生党友好' AS content, '2026-09-06 19:39:35' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '这次白切鸡饭的肉有点发干，不入味' AS content, '2026-10-19 13:56:28' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '整体满意，白切鸡饭价格稍微高一点' AS content, '2026-09-04 18:04:07' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '白切鸡饭配菜比较敷衍，就两片青菜' AS content, '2026-08-11 13:24:09' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '每天都想吃白切鸡饭，可惜是限量的' AS content, '2026-08-12 18:17:54' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '白切鸡饭算是普通盒饭水平' AS content, '2026-10-30 19:27:41' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '白切鸡饭出品挺稳，偶尔肉会偏柴' AS content, '2026-10-01 13:03:26' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '白切鸡饭配的卤蛋入味，青菜也清爽，整体很满意' AS content, '2026-08-27 12:30:07' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '白切鸡饭的肉给得挺多，一个人吃完全够，整体很满意' AS content, '2026-09-03 12:25:15' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '个头不小，性价比可以，整体很满意' AS content, '2026-08-15 13:22:51' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '白切鸡饭的肉肥瘦相间，蜜汁调得正好，整体很满意' AS content, '2026-08-14 12:24:18' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '外皮酥脆，内里软嫩，整体很满意' AS content, '2026-09-27 17:11:06' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 5 AS rating, '食堂里能吃到这个水平的白切鸡饭挺惊喜，整体很满意' AS content, '2026-10-30 17:37:35' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 4 AS rating, '肉很正，就是白切鸡饭的饭给得少了点' AS content, '2026-10-22 12:45:23' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 4 AS rating, '肉很正，就是白切鸡饭的饭给得少了点，整体还行' AS content, '2026-08-15 19:10:35' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 4 AS rating, '肉很正，就是白切鸡饭的饭给得少了点，但希望能改进' AS content, '2026-08-16 12:48:56' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 4 AS rating, '肉很正，就是白切鸡饭的饭给得少了点，不功不过' AS content, '2026-08-18 18:24:07' AS created_at
  UNION ALL
  SELECT 'D047' AS code, 4 AS rating, '肉很正，就是白切鸡饭的饭给得少了点，还可以再优化' AS content, '2026-09-18 18:35:55' AS created_at
) v
JOIN dish d ON d.dish_code = v.code AND d.deleted = 0
WHERE NOT EXISTS (
  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content
);

UPDATE dish d SET
  avg_rating = COALESCE((SELECT ROUND(AVG(r.rating), 1) FROM dish_review r WHERE r.dish_id = d.id AND r.status = 'APPROVED'), 0),
  review_count = (SELECT COUNT(*) FROM dish_review r WHERE r.dish_id = d.id AND r.status = 'APPROVED');

SELECT rating AS star, COUNT(*) AS cnt,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dish_review), 1) AS pct
FROM dish_review GROUP BY rating ORDER BY rating DESC;
