-- =============================================================
-- V8__work_publish_order_link.sql
-- 精选作品发布能力完善：
-- 1. work.dish_id 改为可空：允许「纯图片 + 文字」发布，不强制关联菜品；
-- 2. work 新增 order_id：发布时可关联一条历史订单，作品详情展示订单凭证；
-- 3. order_id 建立索引与外键，订单删除时自动置空，避免作品被级联删除。
-- =============================================================

SET NAMES utf8mb4;

ALTER TABLE work
  MODIFY COLUMN dish_id BIGINT NULL COMMENT '关联菜品，可空（点击可跳转点餐）';

ALTER TABLE work
  ADD COLUMN order_id BIGINT NULL COMMENT '关联历史订单，可空' AFTER dish_id;

ALTER TABLE work
  ADD KEY idx_work_order (order_id);

ALTER TABLE work
  ADD CONSTRAINT fk_work_order
    FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE SET NULL;
