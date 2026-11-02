-- =============================================================
-- V6__add_dish_review.sql
-- 新增菜品评价体系 + 菜品评分字段
-- 幂等：IF NOT EXISTS / 存储过程判断列是否存在
-- =============================================================

SET NAMES utf8mb4;

-- -------------------------------------------------------------
-- 1. 菜品评价表 dish_review
--    语义参考自 canteen-feedback-system.db.dish_review，
--    但按本项目结构重建：主键自增、关联 order/user/dish，
--    评分 1~5 星，内容允许为空（只打分不写评语）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dish_review (
  id          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  dish_id     BIGINT        NOT NULL COMMENT '菜品 ID',
  user_id     BIGINT        NULL COMMENT '评价人（演示数据可为 NULL）',
  order_id    BIGINT        NULL COMMENT '关联订单 ID（可空）',
  rating      TINYINT       NOT NULL COMMENT '评分 1-5 星',
  content     VARCHAR(500)  NULL COMMENT '评价内容，可为空',
  anonymous   TINYINT       NOT NULL DEFAULT 0 COMMENT '是否匿名：1-是 0-否',
  status      VARCHAR(20)   NOT NULL DEFAULT 'APPROVED' COMMENT 'PENDING/APPROVED/REJECTED',
  created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  KEY idx_review_dish (dish_id),
  KEY idx_review_rating (rating),
  KEY idx_review_created (created_at),
  CONSTRAINT fk_review_dish FOREIGN KEY (dish_id) REFERENCES dish (id) ON DELETE CASCADE,
  CONSTRAINT chk_review_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品评价';

-- -------------------------------------------------------------
-- 2. 给 dish 表补充评分聚合字段（冗余存储，避免每次列表都做聚合查询）
--    MySQL 8.0 不支持 ADD COLUMN IF NOT EXISTS，用存储过程判断
-- -------------------------------------------------------------
DROP PROCEDURE IF EXISTS add_dish_rating_columns;

DELIMITER $$
CREATE PROCEDURE add_dish_rating_columns()
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dish' AND COLUMN_NAME = 'avg_rating'
  ) THEN
    ALTER TABLE dish ADD COLUMN avg_rating DECIMAL(2, 1) NOT NULL DEFAULT 0 COMMENT '平均评分 0.0~5.0';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'dish' AND COLUMN_NAME = 'review_count'
  ) THEN
    ALTER TABLE dish ADD COLUMN review_count INT NOT NULL DEFAULT 0 COMMENT '评价数量';
  END IF;
END$$
DELIMITER ;

CALL add_dish_rating_columns();
DROP PROCEDURE IF EXISTS add_dish_rating_columns;
