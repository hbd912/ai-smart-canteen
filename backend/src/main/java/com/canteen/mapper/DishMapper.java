package com.canteen.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.canteen.entity.Dish;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface DishMapper extends BaseMapper<Dish> {

    /**
     * 查询当前最大的数字菜品编码（含软删除记录）。
     * 说明：uk_dish_code 唯一索引不区分 deleted，生成新编码时必须考虑软删除占用的编码，
     * 否则会出现 Duplicate entry 冲突。
     */
    @Select("SELECT MAX(CAST(SUBSTRING(dish_code, 2) AS UNSIGNED)) FROM dish "
            + "WHERE dish_code REGEXP '^D[0-9]+$'")
    Long selectMaxDishCodeNumber();

    /**
     * 检查菜品编码是否已被占用（含软删除记录）。
     */
    @Select("SELECT COUNT(*) FROM dish WHERE dish_code = #{code}")
    long countByCodeIncludingDeleted(@Param("code") String code);

    /**
     * 原子扣减库存：仅当库存充足且菜品已上架可售时才扣减，返回影响行数。
     * 用于避免并发超卖。
     */
    @Update("UPDATE dish SET stock = stock - #{quantity}, sold_count = sold_count + #{quantity}, "
            + "supply_status = CASE WHEN stock - #{quantity} <= 0 THEN 'SOLD_OUT' ELSE supply_status END, "
            + "updated_at = NOW() "
            + "WHERE id = #{dishId} AND deleted = 0 AND publish_status = 'PUBLISHED' "
            + "AND supply_status = 'AVAILABLE' AND stock >= #{quantity}")
    int deductStock(@Param("dishId") Long dishId, @Param("quantity") int quantity);

    /**
     * 回补库存（订单取消时使用）。
     */
    @Update("UPDATE dish SET stock = stock + #{quantity}, sold_count = GREATEST(sold_count - #{quantity}, 0), "
            + "supply_status = CASE WHEN supply_status = 'SOLD_OUT' THEN 'AVAILABLE' ELSE supply_status END, "
            + "updated_at = NOW() WHERE id = #{dishId}")
    int restoreStock(@Param("dishId") Long dishId, @Param("quantity") int quantity);
}
