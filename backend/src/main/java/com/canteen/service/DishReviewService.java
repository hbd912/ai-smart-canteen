package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.canteen.common.BizException;
import com.canteen.common.ErrorCode;
import com.canteen.common.PageResult;
import com.canteen.dto.DishReviewRequest;
import com.canteen.entity.Dish;
import com.canteen.entity.DishReview;
import com.canteen.entity.SysUser;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.DishReviewMapper;
import com.canteen.mapper.SysUserMapper;
import com.canteen.vo.DishRatingSummaryVo;
import com.canteen.vo.DishReviewVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 菜品评价与评分。
 *
 * 设计要点：
 * 1. dish 表冗余 avg_rating / review_count，写入评价后调用 refreshDishRating 刷新，
 *    避免列表页每行都做子查询聚合。
 * 2. 同一用户对同一菜品只保留一条评价，重复提交视为更新。
 * 3. 演示数据允许 user_id 为 NULL，展示为「匿名同学」。
 */
@Service
@RequiredArgsConstructor
public class DishReviewService {

    private static final String STATUS_APPROVED = "APPROVED";
    private static final String ANONYMOUS_NAME = "匿名同学";

    private final DishReviewMapper reviewMapper;
    private final DishMapper dishMapper;
    private final SysUserMapper userMapper;

    /** 菜品评分汇总（含最近评价） */
    public DishRatingSummaryVo summary(Long dishId, Long currentUserId) {
        Dish dish = dishMapper.selectById(dishId);
        if (dish == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "菜品不存在");
        }

        List<DishReview> all = reviewMapper.selectList(new LambdaQueryWrapper<DishReview>()
                .eq(DishReview::getDishId, dishId)
                .eq(DishReview::getStatus, STATUS_APPROVED)
                .orderByDesc(DishReview::getCreatedAt));

        Map<Integer, Integer> dist = new HashMap<>();
        for (DishReview r : all) {
            dist.merge(r.getRating(), 1, Integer::sum);
        }
        int total = all.size();
        int s5 = dist.getOrDefault(5, 0);
        int s4 = dist.getOrDefault(4, 0);
        int s3 = dist.getOrDefault(3, 0);
        int s2 = dist.getOrDefault(2, 0);
        int s1 = dist.getOrDefault(1, 0);
        double goodRate = total == 0 ? 0d : Math.round((s5 + s4) * 1000.0 / total) / 10.0;

        DishRatingSummaryVo vo = new DishRatingSummaryVo();
        vo.setDishId(dishId);
        vo.setAvgRating(dish.getAvgRating() == null ? 0d : dish.getAvgRating().doubleValue());
        vo.setReviewCount(total);
        vo.setStar5(s5);
        vo.setStar4(s4);
        vo.setStar3(s3);
        vo.setStar2(s2);
        vo.setStar1(s1);
        vo.setGoodRate(goodRate);
        vo.setReviewed(currentUserId != null && all.stream()
                .anyMatch(r -> Objects.equals(r.getUserId(), currentUserId)));
        vo.setRecentReviews(toVoList(all.stream().limit(5).toList()));
        return vo;
    }

    /** 菜品评价分页列表 */
    public PageResult<DishReviewVo> list(Long dishId, long page, long pageSize) {
        LambdaQueryWrapper<DishReview> wrapper = new LambdaQueryWrapper<DishReview>()
                .eq(DishReview::getDishId, dishId)
                .eq(DishReview::getStatus, STATUS_APPROVED)
                .orderByDesc(DishReview::getCreatedAt);
        Page<DishReview> paged = reviewMapper.selectPage(
                new Page<>(Math.max(page, 1), Math.min(Math.max(pageSize, 1), 100)), wrapper);
        return PageResult.of(toVoList(paged.getRecords()), paged.getTotal(), paged.getCurrent(), paged.getSize());
    }

    /** 我的评价 */
    public List<DishReviewVo> listMine(Long userId) {
        List<DishReview> list = reviewMapper.selectList(new LambdaQueryWrapper<DishReview>()
                .eq(DishReview::getUserId, userId)
                .eq(DishReview::getStatus, STATUS_APPROVED)
                .orderByDesc(DishReview::getCreatedAt));
        return toVoList(list);
    }

    /** 提交或更新评价 */
    @Transactional
    public DishReviewVo submit(Long userId, DishReviewRequest request) {
        Dish dish = dishMapper.selectById(request.getDishId());
        if (dish == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "菜品不存在");
        }

        DishReview existing = reviewMapper.selectOne(new LambdaQueryWrapper<DishReview>()
                .eq(DishReview::getUserId, userId)
                .eq(DishReview::getDishId, request.getDishId()));

        DishReview review;
        if (existing != null) {
            existing.setRating(request.getRating());
            existing.setContent(StringUtils.hasText(request.getContent()) ? request.getContent().trim() : null);
            existing.setAnonymous(Boolean.TRUE.equals(request.getAnonymous()) ? 1 : 0);
            if (request.getOrderId() != null) {
                existing.setOrderId(request.getOrderId());
            }
            reviewMapper.updateById(existing);
            review = existing;
        } else {
            review = new DishReview();
            review.setDishId(request.getDishId());
            review.setUserId(userId);
            review.setOrderId(request.getOrderId());
            review.setRating(request.getRating());
            review.setContent(StringUtils.hasText(request.getContent()) ? request.getContent().trim() : null);
            review.setAnonymous(Boolean.TRUE.equals(request.getAnonymous()) ? 1 : 0);
            review.setStatus(STATUS_APPROVED);
            reviewMapper.insert(review);
        }

        // 刷新 dish 表冗余评分
        reviewMapper.refreshDishRating(request.getDishId());
        return toVoList(List.of(reviewMapper.selectById(review.getId()))).get(0);
    }

    /** 删除自己的评价 */
    @Transactional
    public void remove(Long userId, Long reviewId) {
        DishReview review = reviewMapper.selectById(reviewId);
        if (review == null) {
            return;
        }
        if (!Objects.equals(review.getUserId(), userId)) {
            throw BizException.of(ErrorCode.FORBIDDEN, "只能删除自己的评价");
        }
        reviewMapper.deleteById(reviewId);
        reviewMapper.refreshDishRating(review.getDishId());
    }

    // ---------------------------------------------------------------
    // 转换
    // ---------------------------------------------------------------

    private List<DishReviewVo> toVoList(List<DishReview> reviews) {
        if (reviews == null || reviews.isEmpty()) {
            return List.of();
        }
        List<Long> userIds = reviews.stream().map(DishReview::getUserId)
                .filter(Objects::nonNull).distinct().toList();
        Map<Long, SysUser> users = userIds.isEmpty() ? Map.of()
                : userMapper.selectBatchIds(userIds).stream()
                .collect(Collectors.toMap(SysUser::getId, u -> u, (a, b) -> a));
        List<Long> dishIds = reviews.stream().map(DishReview::getDishId).distinct().toList();
        Map<Long, Dish> dishes = dishIds.isEmpty() ? Map.of()
                : dishMapper.selectBatchIds(dishIds).stream()
                .collect(Collectors.toMap(Dish::getId, d -> d, (a, b) -> a));

        return reviews.stream().map(r -> {
            DishReviewVo vo = new DishReviewVo();
            vo.setId(r.getId());
            vo.setDishId(r.getDishId());
            Dish d = dishes.get(r.getDishId());
            vo.setDishName(d == null ? null : d.getName());
            vo.setUserId(r.getUserId());
            boolean anon = r.getAnonymous() != null && r.getAnonymous() == 1;
            SysUser u = r.getUserId() == null ? null : users.get(r.getUserId());
            String nickname = anon || u == null ? ANONYMOUS_NAME : u.getNickname();
            vo.setAuthorNickname(nickname);
            vo.setAuthorInitial(nickname.isEmpty() ? "食" : nickname.substring(0, 1));
            vo.setRating(r.getRating());
            vo.setContent(r.getContent());
            vo.setAnonymous(anon);
            vo.setCreatedAt(r.getCreatedAt());
            return vo;
        }).toList();
    }
}
