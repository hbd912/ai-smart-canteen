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
import com.canteen.entity.Order;
import com.canteen.entity.OrderItem;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.OrderItemMapper;
import com.canteen.mapper.OrderMapper;
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
    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;

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

        // 业务规则：只有真正下过单（该订单包含此菜品）才能评价，避免刷评价
        Order order = null;
        if (request.getOrderId() != null) {
            order = orderMapper.selectById(request.getOrderId());
            if (order == null || !Objects.equals(order.getUserId(), userId)) {
                throw BizException.of(ErrorCode.FORBIDDEN, "订单不存在或不属于当前用户");
            }
            boolean bought = orderItemMapper.selectCount(new LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
                    .eq(OrderItem::getDishId, request.getDishId())) > 0;
            if (!bought) {
                throw BizException.of(ErrorCode.BAD_REQUEST, "该订单中没有这道菜，无法评价");
            }
        } else if (!hasPurchased(userId, request.getDishId())) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "只有点过这道菜才能评价");
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
    // 购买校验 / 待评价 / 已评价
    // ---------------------------------------------------------------

    /** 该用户是否点过某道菜（订单未取消即算） */
    public boolean hasPurchased(Long userId, Long dishId) {
        List<Order> orders = orderMapper.selectList(new LambdaQueryWrapper<Order>()
                .eq(Order::getUserId, userId)
                .ne(Order::getOrderStatus, "CANCELLED"));
        if (orders.isEmpty()) {
            return false;
        }
        List<Long> orderIds = orders.stream().map(Order::getId).toList();
        return orderItemMapper.selectCount(new LambdaQueryWrapper<OrderItem>()
                .in(OrderItem::getOrderId, orderIds)
                .eq(OrderItem::getDishId, dishId)) > 0;
    }

    /**
     * 评价中心：按订单明细聚合，区分「待评价 / 已评价」。
     *
     * 返回每一条购买记录（订单 + 菜品），供前端列表展示与跳转评价。
     */
    public List<java.util.Map<String, Object>> reviewCenter(Long userId) {
        List<Order> orders = orderMapper.selectList(new LambdaQueryWrapper<Order>()
                .eq(Order::getUserId, userId)
                .ne(Order::getOrderStatus, "CANCELLED")
                .orderByDesc(Order::getCreatedAt));
        if (orders.isEmpty()) {
            return List.of();
        }
        List<Long> orderIds = orders.stream().map(Order::getId).toList();
        List<OrderItem> items = orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                .in(OrderItem::getOrderId, orderIds));
        Map<Long, Order> orderMap = orders.stream()
                .collect(Collectors.toMap(Order::getId, o -> o, (a, b) -> a));

        // 我已评价的菜品 -> 评价记录
        List<DishReview> mine = reviewMapper.selectList(new LambdaQueryWrapper<DishReview>()
                .eq(DishReview::getUserId, userId)
                .eq(DishReview::getStatus, STATUS_APPROVED));
        Map<Long, DishReview> reviewedByDish = mine.stream()
                .collect(Collectors.toMap(DishReview::getDishId, r -> r, (a, b) -> a));

        List<java.util.Map<String, Object>> out = new java.util.ArrayList<>();
        for (OrderItem it : items) {
            Order o = orderMap.get(it.getOrderId());
            if (o == null || it.getDishId() == null) {
                continue;
            }
            DishReview rv = reviewedByDish.get(it.getDishId());
            Map<String, Object> row = new java.util.LinkedHashMap<>();
            row.put("orderId", o.getId());
            row.put("orderNo", o.getOrderNo());
            row.put("orderStatus", o.getOrderStatus());
            row.put("orderCreatedAt", o.getCreatedAt());
            row.put("dishId", it.getDishId());
            row.put("dishName", it.getDishNameSnapshot());
            row.put("imageUrl", it.getImageUrlSnapshot());
            row.put("quantity", it.getQuantity());
            row.put("unitPrice", it.getUnitPriceSnapshot());
            row.put("reviewed", rv != null);
            row.put("myRating", rv == null ? null : rv.getRating());
            row.put("myContent", rv == null ? null : rv.getContent());
            row.put("reviewedAt", rv == null ? null : rv.getCreatedAt());
            out.add(row);
        }
        return out;
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
