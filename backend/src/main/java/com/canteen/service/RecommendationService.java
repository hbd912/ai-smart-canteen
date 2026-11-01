package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.canteen.common.BizException;
import com.canteen.common.Constants;
import com.canteen.common.ErrorCode;
import com.canteen.dto.RecommendationSaveRequest;
import com.canteen.entity.Dish;
import com.canteen.entity.HomeRecommendation;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.HomeRecommendationMapper;
import com.canteen.vo.HomeRecommendationVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 首页推荐业务：后台配置 <-> 前台展示，同一份 home_recommendation 数据。
 */
@Service
@RequiredArgsConstructor
public class RecommendationService {

    private final HomeRecommendationMapper recommendationMapper;
    private final DishMapper dishMapper;
    private final DishService dishService;

    public List<HomeRecommendationVo> listForCustomer(Long currentUserId) {
        List<HomeRecommendation> recommendations = recommendationMapper.selectList(
                new LambdaQueryWrapper<HomeRecommendation>()
                        .eq(HomeRecommendation::getEnabled, 1)
                        .orderByAsc(HomeRecommendation::getSortOrder)
                        .orderByAsc(HomeRecommendation::getId));
        if (recommendations.isEmpty()) {
            return List.of();
        }
        List<Long> dishIds = recommendations.stream().map(HomeRecommendation::getDishId).toList();
        Map<Long, Dish> dishMap = dishMapper.selectBatchIds(dishIds).stream()
                .collect(Collectors.toMap(Dish::getId, Function.identity(), (a, b) -> a));
        List<HomeRecommendationVo> result = new ArrayList<>();
        for (HomeRecommendation recommendation : recommendations) {
            Dish dish = dishMap.get(recommendation.getDishId());
            if (dish == null || !Constants.PublishStatus.PUBLISHED.equals(dish.getPublishStatus())) {
                continue;
            }
            HomeRecommendationVo vo = new HomeRecommendationVo();
            vo.setId(recommendation.getId());
            vo.setDishId(recommendation.getDishId());
            vo.setTitle(recommendation.getTitle());
            vo.setBadgeText(recommendation.getBadgeText());
            vo.setSortOrder(recommendation.getSortOrder());
            vo.setEnabled(Integer.valueOf(1).equals(recommendation.getEnabled()));
            vo.setDish(dishService.toVo(dish, currentUserId, null, recommendation));
            result.add(vo);
        }
        result.sort(Comparator.comparing(HomeRecommendationVo::getSortOrder,
                Comparator.nullsLast(Comparator.naturalOrder())));
        return result;
    }

    public List<HomeRecommendationVo> listForAdmin() {
        List<HomeRecommendation> recommendations = recommendationMapper.selectList(
                new LambdaQueryWrapper<HomeRecommendation>()
                        .orderByAsc(HomeRecommendation::getSortOrder)
                        .orderByAsc(HomeRecommendation::getId));
        if (recommendations.isEmpty()) {
            return List.of();
        }
        Map<Long, Dish> dishMap = dishMapper.selectBatchIds(
                        recommendations.stream().map(HomeRecommendation::getDishId).toList())
                .stream().collect(Collectors.toMap(Dish::getId, Function.identity(), (a, b) -> a));
        List<HomeRecommendationVo> result = new ArrayList<>();
        for (HomeRecommendation recommendation : recommendations) {
            HomeRecommendationVo vo = new HomeRecommendationVo();
            vo.setId(recommendation.getId());
            vo.setDishId(recommendation.getDishId());
            vo.setTitle(recommendation.getTitle());
            vo.setBadgeText(recommendation.getBadgeText());
            vo.setSortOrder(recommendation.getSortOrder());
            vo.setEnabled(Integer.valueOf(1).equals(recommendation.getEnabled()));
            Dish dish = dishMap.get(recommendation.getDishId());
            if (dish != null) {
                vo.setDish(dishService.toVo(dish, null, null, null));
            }
            result.add(vo);
        }
        return result;
    }

    @Transactional
    public void save(RecommendationSaveRequest request) {
        List<Long> dishIds = request.getItems().stream()
                .map(RecommendationSaveRequest.Item::getDishId).toList();
        Map<Long, Dish> dishMap = dishMapper.selectBatchIds(dishIds).stream()
                .collect(Collectors.toMap(Dish::getId, Function.identity(), (a, b) -> a));
        for (RecommendationSaveRequest.Item item : request.getItems()) {
            if (!dishMap.containsKey(item.getDishId())) {
                throw BizException.of(ErrorCode.BAD_REQUEST, "推荐菜品不存在：ID " + item.getDishId());
            }
        }
        // 全量替换推荐配置（保持与前端提交一致）
        recommendationMapper.delete(null);
        int index = 1;
        for (RecommendationSaveRequest.Item item : request.getItems()) {
            Dish dish = dishMap.get(item.getDishId());
            HomeRecommendation recommendation = new HomeRecommendation();            recommendation.setDishId(item.getDishId());
            recommendation.setTitle(item.getTitle() == null || item.getTitle().isBlank()
                    ? dish.getName() : item.getTitle());
            recommendation.setBadgeText(item.getBadgeText());
            recommendation.setSortOrder(item.getSortOrder() == null ? index : item.getSortOrder());
            recommendation.setEnabled(Boolean.FALSE.equals(item.getEnabled()) ? 0 : 1);
            recommendationMapper.insert(recommendation);
            index++;
        }
        // 说明：dish.recommend_flag 是「菜单卡片推荐标记」，home_recommendation 是「首页推荐位」，
        // 两者是不同概念（种子数据中前者 3 条、后者 6 条），此处不做联动改写，
        // 避免管理首页推荐时意外清掉菜品的推荐标记。
    }

    @Transactional
    public void remove(Long dishId) {
        recommendationMapper.delete(new LambdaQueryWrapper<HomeRecommendation>()
                .eq(HomeRecommendation::getDishId, dishId));
    }
}
