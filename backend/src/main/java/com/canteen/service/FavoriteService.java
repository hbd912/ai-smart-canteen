package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.canteen.common.BizException;
import com.canteen.common.ErrorCode;
import com.canteen.entity.Dish;
import com.canteen.entity.DishFavorite;
import com.canteen.mapper.DishFavoriteMapper;
import com.canteen.mapper.DishMapper;
import com.canteen.vo.DishVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 收藏业务。收藏状态在首页推荐卡、菜单卡片、详情弹窗之间共享同一份数据。
 */
@Service
@RequiredArgsConstructor
public class FavoriteService {

    private final DishFavoriteMapper favoriteMapper;
    private final DishMapper dishMapper;
    private final DishService dishService;

    public List<DishVo> list(Long userId) {
        List<DishFavorite> favorites = favoriteMapper.selectList(new LambdaQueryWrapper<DishFavorite>()
                .eq(DishFavorite::getUserId, userId)
                .orderByDesc(DishFavorite::getCreatedAt));
        if (favorites.isEmpty()) {
            return List.of();
        }
        List<Long> dishIds = favorites.stream().map(DishFavorite::getDishId).toList();
        List<Dish> dishes = dishMapper.selectBatchIds(dishIds);
        return dishService.toVoList(dishes, userId);
    }

    @Transactional
    public void add(Long userId, Long dishId) {
        Dish dish = dishMapper.selectById(dishId);
        if (dish == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "菜品不存在");
        }
        long exists = favoriteMapper.selectCount(new LambdaQueryWrapper<DishFavorite>()
                .eq(DishFavorite::getUserId, userId)
                .eq(DishFavorite::getDishId, dishId));
        if (exists > 0) {
            return;
        }
        DishFavorite favorite = new DishFavorite();
        favorite.setUserId(userId);
        favorite.setDishId(dishId);
        favoriteMapper.insert(favorite);
    }

    @Transactional
    public void remove(Long userId, Long dishId) {
        favoriteMapper.delete(new LambdaQueryWrapper<DishFavorite>()
                .eq(DishFavorite::getUserId, userId)
                .eq(DishFavorite::getDishId, dishId));
    }

    @Transactional
    public boolean toggle(Long userId, Long dishId) {
        long exists = favoriteMapper.selectCount(new LambdaQueryWrapper<DishFavorite>()
                .eq(DishFavorite::getUserId, userId)
                .eq(DishFavorite::getDishId, dishId));
        if (exists > 0) {
            remove(userId, dishId);
            return false;
        }
        add(userId, dishId);
        return true;
    }
}
