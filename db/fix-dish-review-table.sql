-- =============================================================
-- fix-dish-review-table.sql
-- 重建 dish_review 表为 V6 定义的结构
--
-- 背景：项目里曾存在一版旧的 dish_review（缺少 anonymous 列），
-- 与 V6 迁移的目标结构不一致，导致评价导入失败。
-- 旧表只含演示性质数据，重建不会丢失真实业务数据。
--
-- 执行顺序：先备份旧数据 -> 删表 -> 按 V6 结构重建 -> 回填可迁移的数据
-- =============================================================

SET NAMES utf8mb4;

-- 1. 备份旧表（若存在）
DROP TABLE IF EXISTS dish_review_backup;
RENAME TABLE dish_review TO dish_review_backup;

-- 2. 按 V6 结构重建
CREATE TABLE dish_review (
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

-- 3. 把旧数据迁移过来（user_id 允许为空，长度截断到 500）
INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)
SELECT dish_id,
       NULLIF(user_id, 0),
       order_id,
       LEAST(GREATEST(rating, 1), 5),
       LEFT(content, 500),
       0,
       COALESCE(status, 'APPROVED'),
       COALESCE(created_at, NOW())
FROM dish_review_backup
WHERE EXISTS (SELECT 1 FROM dish d WHERE d.id = dish_review_backup.dish_id);

-- 4. 删除备份表
DROP TABLE dish_review_backup;

-- 5. 核验
SELECT COUNT(*) AS review_count FROM dish_review;
SELECT rating, COUNT(*) AS cnt FROM dish_review GROUP BY rating ORDER BY rating DESC;
