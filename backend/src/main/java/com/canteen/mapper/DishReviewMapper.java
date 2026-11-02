package com.canteen.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.canteen.entity.DishReview;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.Map;

@Mapper
public interface DishReviewMapper extends BaseMapper<DishReview> {

    /**
     * 统计某菜品的星级分布，返回 [{rating, count}] 按星级降序。
     */
    @Select("SELECT rating AS rating, COUNT(*) AS cnt FROM dish_review "
            + "WHERE dish_id = #{dishId} AND status = 'APPROVED' "
            + "GROUP BY rating ORDER BY rating DESC")
    List<Map<String, Object>> countByRating(@Param("dishId") Long dishId);

    /**
     * 重新计算某菜品的平均分与评价数，并写回 dish 表（冗余字段）。
     */
    @Update("UPDATE dish SET "
            + "  avg_rating = COALESCE((SELECT ROUND(AVG(r.rating), 1) FROM dish_review r "
            + "    WHERE r.dish_id = #{dishId} AND r.status = 'APPROVED'), 0), "
            + "  review_count = (SELECT COUNT(*) FROM dish_review r "
            + "    WHERE r.dish_id = #{dishId} AND r.status = 'APPROVED') "
            + "WHERE id = #{dishId}")
    int refreshDishRating(@Param("dishId") Long dishId);

    /**
     * 批量刷新全部菜品的评分聚合（数据导入后调用一次即可）。
     */
    @Update("UPDATE dish d SET "
            + "  avg_rating = COALESCE((SELECT ROUND(AVG(r.rating), 1) FROM dish_review r "
            + "    WHERE r.dish_id = d.id AND r.status = 'APPROVED'), 0), "
            + "  review_count = (SELECT COUNT(*) FROM dish_review r "
            + "    WHERE r.dish_id = d.id AND r.status = 'APPROVED')")
    int refreshAllDishRatings();
}
