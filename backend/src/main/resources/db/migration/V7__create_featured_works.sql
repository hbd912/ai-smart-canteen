-- =============================================================
-- V7__create_featured_works.sql
-- 「精选」作品流：用户发布菜品作品，支持点赞、评论、关联菜品
--
-- 设计要点：
-- 1. work 关联 dish（作品就是某道菜的真实照片 + 评价）
-- 2. work_like 记录点赞，唯一约束防重复
-- 3. work_comment 记录评论
-- 4. 所有表幂等创建
-- =============================================================

SET NAMES utf8mb4;

-- -------------------------------------------------------------
-- 1. 作品表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS work (
  id             BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  user_id        BIGINT        NOT NULL COMMENT '作者',
  dish_id        BIGINT        NOT NULL COMMENT '关联菜品（点击可跳转点餐）',
  title          VARCHAR(100)  NULL COMMENT '标题',
  content        VARCHAR(1000) NULL COMMENT '正文评价',
  images_json    JSON          NULL COMMENT '图片 URL 数组',
  like_count     INT           NOT NULL DEFAULT 0 COMMENT '点赞数',
  comment_count  INT           NOT NULL DEFAULT 0 COMMENT '评论数',
  status         VARCHAR(20)   NOT NULL DEFAULT 'APPROVED' COMMENT 'PENDING/APPROVED/REJECTED',
  created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_work_user (user_id),
  KEY idx_work_dish (dish_id),
  KEY idx_work_status (status),
  KEY idx_work_created (created_at),
  KEY idx_work_like (like_count),
  CONSTRAINT fk_work_user2 FOREIGN KEY (user_id) REFERENCES sys_user (id) ON DELETE CASCADE,
  CONSTRAINT fk_work_dish FOREIGN KEY (dish_id) REFERENCES dish (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '精选作品';

-- -------------------------------------------------------------
-- 2. 点赞表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS work_like (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  work_id    BIGINT   NOT NULL,
  user_id    BIGINT   NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_wl (work_id, user_id),
  KEY idx_wl_user (user_id),
  CONSTRAINT fk_wl_work2 FOREIGN KEY (work_id) REFERENCES work (id) ON DELETE CASCADE,
  CONSTRAINT fk_wl_user2 FOREIGN KEY (user_id) REFERENCES sys_user (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '作品点赞';

-- -------------------------------------------------------------
-- 3. 评论表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS work_comment (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  work_id    BIGINT       NOT NULL,
  user_id    BIGINT       NOT NULL,
  content    VARCHAR(500) NOT NULL,
  status     VARCHAR(20)  NOT NULL DEFAULT 'APPROVED',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_wc_work (work_id),
  KEY idx_wc_user (user_id),
  CONSTRAINT fk_wc_work2 FOREIGN KEY (work_id) REFERENCES work (id) ON DELETE CASCADE,
  CONSTRAINT fk_wc_user2 FOREIGN KEY (user_id) REFERENCES sys_user (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '作品评论';
