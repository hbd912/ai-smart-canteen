package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.canteen.common.BizException;
import com.canteen.common.Constants;
import com.canteen.common.ErrorCode;
import com.canteen.common.JsonUtils;
import com.canteen.common.Labels;
import com.canteen.common.PageResult;
import com.canteen.dto.DishQuery;
import com.canteen.dto.DishSaveRequest;
import com.canteen.entity.Dish;
import com.canteen.entity.DishCategory;
import com.canteen.entity.DishFavorite;
import com.canteen.entity.HomeRecommendation;
import com.canteen.entity.InventoryLog;
import com.canteen.mapper.DishCategoryMapper;
import com.canteen.mapper.DishFavoriteMapper;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.HomeRecommendationMapper;
import com.canteen.mapper.InventoryLogMapper;
import com.canteen.security.SecurityUtils;
import com.canteen.vo.DishVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 菜品业务：前台查询（仅上架）/ 后台查询（全部）/ 增删改 / 上下架。
 * 前后台共用同一张 dish 表与同一套 Service，保证数据联动。
 */
@Service
@RequiredArgsConstructor
public class DishService {

    private final DishMapper dishMapper;
    private final DishCategoryMapper categoryMapper;
    private final DishFavoriteMapper favoriteMapper;
    private final HomeRecommendationMapper recommendationMapper;
    private final InventoryLogMapper inventoryLogMapper;

    // ---------------------------------------------------------------
    // 前台查询
    // ---------------------------------------------------------------

    public PageResult<DishVo> listForCustomer(DishQuery query, Long currentUserId) {
        LambdaQueryWrapper<Dish> wrapper = buildCustomerWrapper(query);
        long page = Math.max(query.getPage(), 1);
        long pageSize = Math.min(Math.max(query.getPageSize(), 1), 100);
        Page<Dish> paged = dishMapper.selectPage(new Page<>(page, pageSize), wrapper);
        List<DishVo> records = toVoList(paged.getRecords(), currentUserId);
        return PageResult.of(records, paged.getTotal(), page, pageSize);
    }

    public List<DishVo> listAllForCustomer(Long currentUserId) {
        DishQuery query = new DishQuery();
        query.setPage(1);
        query.setPageSize(100);
        List<Dish> dishes = dishMapper.selectList(buildCustomerWrapper(query));
        return toVoList(dishes, currentUserId);
    }

    private LambdaQueryWrapper<Dish> buildCustomerWrapper(DishQuery query) {
        LambdaQueryWrapper<Dish> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Dish::getPublishStatus, Constants.PublishStatus.PUBLISHED);
        if (StringUtils.hasText(query.getKeyword())) {
            String keyword = query.getKeyword().trim();
            wrapper.and(w -> w.like(Dish::getName, keyword)
                    .or().like(Dish::getDescription, keyword)
                    .or().like(Dish::getTagsJson, keyword));
        }
        Long categoryId = resolveCategoryId(query);
        if (categoryId != null) {
            wrapper.eq(Dish::getCategoryId, categoryId);
        }
        if (query.getMinPrice() != null) {
            wrapper.ge(Dish::getPrice, query.getMinPrice());
        }
        if (query.getMaxPrice() != null) {
            wrapper.le(Dish::getPrice, query.getMaxPrice());
        }
        if (query.getMinCalories() != null) {
            wrapper.ge(Dish::getCalories, query.getMinCalories());
        }
        if (query.getMaxCalories() != null) {
            wrapper.le(Dish::getCalories, query.getMaxCalories());
        }
        if (Boolean.TRUE.equals(query.getRecommendOnly())) {
            wrapper.eq(Dish::getRecommendFlag, 1);
        }
        applySort(wrapper, query.getSort());
        return wrapper;
    }

    private Long resolveCategoryId(DishQuery query) {
        if (query.getCategoryId() != null) {
            return query.getCategoryId();
        }
        if (StringUtils.hasText(query.getCategoryCode()) && !"ALL".equalsIgnoreCase(query.getCategoryCode())) {
            DishCategory category = categoryMapper.selectOne(new LambdaQueryWrapper<DishCategory>()
                    .eq(DishCategory::getCode, query.getCategoryCode()));
            return category == null ? -1L : category.getId();
        }
        return null;
    }

    private void applySort(LambdaQueryWrapper<Dish> wrapper, String sort) {
        String key = sort == null ? "sales_desc" : sort;
        switch (key) {
            case "price_asc" -> wrapper.orderByAsc(Dish::getPrice);
            case "price_desc" -> wrapper.orderByDesc(Dish::getPrice);
            case "calories_asc" -> wrapper.orderByAsc(Dish::getCalories);
            case "calories_desc" -> wrapper.orderByDesc(Dish::getCalories);
            case "created_desc" -> wrapper.orderByDesc(Dish::getCreatedAt);
            case "created_asc" -> wrapper.orderByAsc(Dish::getCreatedAt);
            case "stock_asc" -> wrapper.orderByAsc(Dish::getStock);
            case "sort_asc" -> wrapper.orderByAsc(Dish::getSortOrder);
            default -> wrapper.orderByDesc(Dish::getSoldCount);
        }
        wrapper.orderByAsc(Dish::getSortOrder).orderByAsc(Dish::getId);
    }

    // ---------------------------------------------------------------
    // 后台查询
    // ---------------------------------------------------------------

    public PageResult<DishVo> listForAdmin(DishQuery query) {
        LambdaQueryWrapper<Dish> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(query.getKeyword())) {
            String keyword = query.getKeyword().trim();
            wrapper.and(w -> w.like(Dish::getName, keyword).or().like(Dish::getDishCode, keyword));
        }
        Long categoryId = resolveCategoryId(query);
        if (categoryId != null) {
            wrapper.eq(Dish::getCategoryId, categoryId);
        }
        if (StringUtils.hasText(query.getPublishStatus())) {
            wrapper.eq(Dish::getPublishStatus, query.getPublishStatus());
        }
        if (StringUtils.hasText(query.getSupplyStatus())) {
            wrapper.eq(Dish::getSupplyStatus, query.getSupplyStatus());
        }
        if (query.getMinPrice() != null) {
            wrapper.ge(Dish::getPrice, query.getMinPrice());
        }
        if (query.getMaxPrice() != null) {
            wrapper.le(Dish::getPrice, query.getMaxPrice());
        }
        if (query.getMinCalories() != null) {
            wrapper.ge(Dish::getCalories, query.getMinCalories());
        }
        if (query.getMaxCalories() != null) {
            wrapper.le(Dish::getCalories, query.getMaxCalories());
        }
        applySort(wrapper, query.getSort());
        long page = Math.max(query.getPage(), 1);
        long pageSize = Math.min(Math.max(query.getPageSize(), 1), 100);
        Page<Dish> paged = dishMapper.selectPage(new Page<>(page, pageSize), wrapper);
        return PageResult.of(toVoList(paged.getRecords(), null), paged.getTotal(), page, pageSize);
    }

    public DishVo getForCustomer(Long id, Long currentUserId) {
        Dish dish = requireDish(id);
        if (!Constants.PublishStatus.PUBLISHED.equals(dish.getPublishStatus())) {
            throw BizException.of(ErrorCode.NOT_FOUND, "菜品不存在或已下架");
        }
        return toVo(dish, currentUserId, null, null);
    }

    public DishVo getForAdmin(Long id) {
        return toVo(requireDish(id), null, null, null);
    }

    public Dish requireDish(Long id) {
        Dish dish = dishMapper.selectById(id);
        if (dish == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "菜品不存在");
        }
        return dish;
    }

    // ---------------------------------------------------------------
    // 后台写入
    // ---------------------------------------------------------------

    @Transactional
    public DishVo create(DishSaveRequest request) {
        DishCategory category = requireCategory(request.getCategoryId());
        Dish dish = new Dish();
        applyRequest(dish, request);
        dish.setCategoryId(category.getId());
        dish.setDishCode(StringUtils.hasText(request.getDishCode())
                ? request.getDishCode().trim()
                : generateDishCode());
        dish.setSoldCount(0);
        dish.setCreatedBy(SecurityUtils.currentAdminIdOrNull());
        if (!StringUtils.hasText(dish.getImageUrl())) {
            dish.setImageUrl("/assets/images/dishes/dish-placeholder.webp");
        }
        normalizeSupplyStatus(dish);
        dishMapper.insert(dish);

        // 初始库存流水
        if (dish.getStock() != null && dish.getStock() > 0) {
            recordInventory(dish.getId(), dish.getStock(), 0, dish.getStock(),
                    Constants.InventoryReason.INITIAL_STOCK + " 新建菜品初始库存",
                    SecurityUtils.currentAdminIdOrNull(), null);
        }
        if (Boolean.TRUE.equals(request.getHomeRecommendation())) {
            upsertRecommendation(dish, request.getRecommendationBadge());
        }
        return toVo(dish, null, category, null);
    }

    @Transactional
    public DishVo update(Long id, DishSaveRequest request) {
        Dish dish = requireDish(id);
        DishCategory category = requireCategory(request.getCategoryId());
        int beforeStock = dish.getStock() == null ? 0 : dish.getStock();

        applyRequest(dish, request);
        dish.setCategoryId(category.getId());
        if (StringUtils.hasText(request.getDishCode())) {
            dish.setDishCode(request.getDishCode().trim());
        }
        normalizeSupplyStatus(dish);
        dishMapper.updateById(dish);

        int afterStock = dish.getStock() == null ? 0 : dish.getStock();
        if (afterStock != beforeStock) {
            recordInventory(dish.getId(), afterStock - beforeStock, beforeStock, afterStock,
                    Constants.InventoryReason.MANUAL_ADJUST + " 菜品编辑调整库存",
                    SecurityUtils.currentAdminIdOrNull(), null);
        }
        if (Boolean.TRUE.equals(request.getHomeRecommendation())) {
            upsertRecommendation(dish, request.getRecommendationBadge());
        } else {
            recommendationMapper.delete(new LambdaQueryWrapper<HomeRecommendation>()
                    .eq(HomeRecommendation::getDishId, dish.getId()));
        }
        return toVo(dish, null, category, null);
    }

    @Transactional
    public void changePublishStatus(Long id, String status) {
        if (!Set.of(Constants.PublishStatus.DRAFT, Constants.PublishStatus.PUBLISHED,
                Constants.PublishStatus.UNPUBLISHED).contains(status)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "不支持的上架状态：" + status);
        }
        Dish dish = requireDish(id);
        if (Constants.PublishStatus.PUBLISHED.equals(status)) {
            validateBeforePublish(dish);
        }
        dish.setPublishStatus(status);
        dish.setUpdatedAt(LocalDateTime.now());
        dishMapper.updateById(dish);
    }

    @Transactional
    public void changeSupplyStatus(Long id, String status) {
        if (!Set.of(Constants.SupplyStatus.AVAILABLE, Constants.SupplyStatus.SOLD_OUT,
                Constants.SupplyStatus.PAUSED).contains(status)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "不支持的供应状态：" + status);
        }
        Dish dish = requireDish(id);
        dish.setSupplyStatus(status);
        dish.setUpdatedAt(LocalDateTime.now());
        dishMapper.updateById(dish);
    }

    /**
     * 逻辑删除。已关联历史订单的菜品会被标记停用而非物理删除，订单明细本身使用快照。
     */
    @Transactional
    public void delete(Long id) {
        Dish dish = requireDish(id);
        dishMapper.deleteById(id);
        recommendationMapper.delete(new LambdaQueryWrapper<HomeRecommendation>()
                .eq(HomeRecommendation::getDishId, dish.getId()));
    }

    @Transactional
    public DishVo copy(Long id) {
        Dish source = requireDish(id);
        Dish copy = new Dish();
        copy.setCategoryId(source.getCategoryId());
        copy.setDishCode(generateDishCode());
        copy.setName(source.getName() + "（副本）");
        copy.setDescription(source.getDescription());
        copy.setIngredientsJson(source.getIngredientsJson());
        copy.setAllergensJson(source.getAllergensJson());
        copy.setImageUrl(source.getImageUrl());
        copy.setPrice(source.getPrice());
        copy.setCalories(source.getCalories());
        copy.setProteinG(source.getProteinG());
        copy.setFatG(source.getFatG());
        copy.setCarbohydrateG(source.getCarbohydrateG());
        copy.setFiberG(source.getFiberG());
        copy.setSodiumMg(source.getSodiumMg());
        copy.setNutritionSource(source.getNutritionSource());
        copy.setNutritionNote(source.getNutritionNote());
        copy.setStock(0);
        copy.setDailyLimit(source.getDailyLimit());
        copy.setSoldCount(0);
        copy.setSupplyStatus(Constants.SupplyStatus.AVAILABLE);
        copy.setPublishStatus(Constants.PublishStatus.DRAFT);
        copy.setRecommendFlag(0);
        copy.setRecommendRank(0);
        copy.setTagsJson(source.getTagsJson());
        copy.setSortOrder(source.getSortOrder());
        copy.setCreatedBy(SecurityUtils.currentAdminIdOrNull());
        dishMapper.insert(copy);
        return toVo(copy, null, null, null);
    }

    private void validateBeforePublish(Dish dish) {
        List<String> missing = new ArrayList<>();
        if (!StringUtils.hasText(dish.getName())) {
            missing.add("菜品名称");
        }
        if (dish.getCategoryId() == null) {
            missing.add("菜品分类");
        }
        if (dish.getPrice() == null || dish.getPrice().compareTo(BigDecimal.ZERO) < 0) {
            missing.add("售价");
        }
        if (dish.getCalories() == null) {
            missing.add("热量");
        }
        if (!missing.isEmpty()) {
            throw BizException.of(ErrorCode.BUSINESS_ERROR,
                    "上架前请补全必要字段：" + String.join("、", missing));
        }
    }

    private void normalizeSupplyStatus(Dish dish) {
        if (dish.getStock() == null) {
            dish.setStock(0);
        }
        if (dish.getStock() <= 0) {
            if (Constants.SupplyStatus.AVAILABLE.equals(dish.getSupplyStatus())) {
                dish.setSupplyStatus(Constants.SupplyStatus.SOLD_OUT);
            }
        } else if (Constants.SupplyStatus.SOLD_OUT.equals(dish.getSupplyStatus())) {
            dish.setSupplyStatus(Constants.SupplyStatus.AVAILABLE);
        }
        if (dish.getSupplyStatus() == null) {
            dish.setSupplyStatus(Constants.SupplyStatus.AVAILABLE);
        }
        if (dish.getPublishStatus() == null) {
            dish.setPublishStatus(Constants.PublishStatus.DRAFT);
        }
        if (dish.getRecommendRank() == null) {
            dish.setRecommendRank(0);
        }
        if (dish.getSortOrder() == null) {
            dish.setSortOrder(0);
        }
        if (dish.getDailyLimit() == null) {
            dish.setDailyLimit(0);
        }
    }

    private void applyRequest(Dish dish, DishSaveRequest request) {
        dish.setName(request.getName().trim());
        dish.setDescription(request.getDescription());
        dish.setIngredientsJson(JsonUtils.toJson(request.getIngredients()));
        dish.setAllergensJson(JsonUtils.toJson(request.getAllergens()));
        dish.setTagsJson(JsonUtils.toJson(request.getTags()));
        dish.setImageUrl(StringUtils.hasText(request.getImageUrl())
                ? request.getImageUrl().trim()
                : "/assets/images/dishes/dish-placeholder.webp");
        dish.setPrice(scale(request.getPrice(), 2));
        dish.setCalories(scale(request.getCalories(), 2));
        dish.setProteinG(scale(request.getProteinG(), 2));
        dish.setFatG(scale(request.getFatG(), 2));
        dish.setCarbohydrateG(scale(request.getCarbohydrateG(), 2));
        dish.setFiberG(scale(request.getFiberG(), 2));
        dish.setSodiumMg(scale(request.getSodiumMg(), 2));
        dish.setNutritionSource(StringUtils.hasText(request.getNutritionSource())
                ? request.getNutritionSource() : "ESTIMATED");
        dish.setNutritionNote(request.getNutritionNote());
        dish.setStock(request.getStock());
        dish.setDailyLimit(request.getDailyLimit());
        dish.setPublishStatus(request.getPublishStatus());
        dish.setSupplyStatus(request.getSupplyStatus());
        dish.setRecommendFlag(Boolean.TRUE.equals(request.getRecommendFlag()) ? 1 : 0);
        dish.setRecommendRank(request.getRecommendRank() == null ? 0 : request.getRecommendRank());
        dish.setSortOrder(request.getSortOrder() == null ? 0 : request.getSortOrder());
    }

    private BigDecimal scale(BigDecimal value, int scale) {
        return value == null ? null : value.setScale(scale, RoundingMode.HALF_UP);
    }

    /**
     * 生成下一个可用菜品编码。
     * 注意：dish_code 唯一索引不含 deleted 字段，软删除的菜品仍占用编码，
     * 因此必须用包含已删除记录的查询判断占用情况，否则会触发 Duplicate entry。
     */
    private String generateDishCode() {
        Long maxNumber = dishMapper.selectMaxDishCodeNumber();
        long next = (maxNumber == null ? 0L : maxNumber) + 1;
        String code = String.format("D%03d", next);
        // 双保险：即使存在不连续或非数字的历史编码，也逐个向前探测
        int guard = 0;
        while (dishMapper.countByCodeIncludingDeleted(code) > 0 && guard < 10000) {
            next++;
            code = String.format("D%03d", next);
            guard++;
        }
        return code;
    }

    private DishCategory requireCategory(Long categoryId) {
        DishCategory category = categoryMapper.selectById(categoryId);
        if (category == null) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "所选分类不存在");
        }
        return category;
    }

    private void upsertRecommendation(Dish dish, String badge) {
        HomeRecommendation existing = recommendationMapper.selectOne(
                new LambdaQueryWrapper<HomeRecommendation>().eq(HomeRecommendation::getDishId, dish.getId()));
        if (existing == null) {
            HomeRecommendation recommendation = new HomeRecommendation();
            recommendation.setDishId(dish.getId());
            recommendation.setTitle(dish.getName());
            recommendation.setBadgeText(StringUtils.hasText(badge) ? badge : "今日推荐");
            recommendation.setSortOrder(dish.getRecommendRank() == null ? 0 : dish.getRecommendRank());
            recommendation.setEnabled(1);
            recommendationMapper.insert(recommendation);
        } else {
            existing.setEnabled(1);
            if (StringUtils.hasText(badge)) {
                existing.setBadgeText(badge);
            }
            recommendationMapper.updateById(existing);
        }
    }

    private void recordInventory(Long dishId, int change, int before, int after, String reason,
                                 Long adminId, Long orderId) {
        InventoryLog log = new InventoryLog();
        log.setDishId(dishId);
        log.setChangeAmount(change);
        log.setBeforeStock(before);
        log.setAfterStock(after);
        log.setReason(reason);
        log.setOperatorAdminId(adminId);
        log.setRelatedOrderId(orderId);
        inventoryLogMapper.insert(log);
    }

    // ---------------------------------------------------------------
    // VO 转换
    // ---------------------------------------------------------------

    public List<DishVo> toVoList(Collection<Dish> dishes, Long currentUserId) {
        if (dishes == null || dishes.isEmpty()) {
            return new ArrayList<>();
        }
        Map<Long, DishCategory> categories = loadCategoryMap();
        Map<Long, HomeRecommendation> recommendations = loadRecommendationMap();
        Set<Long> favorites = loadFavoriteIds(currentUserId);
        return dishes.stream()
                .map(dish -> toVo(dish, currentUserId, categories.get(dish.getCategoryId()),
                        recommendations.get(dish.getId()), favorites))
                .collect(Collectors.toList());
    }

    public DishVo toVo(Dish dish, Long currentUserId, DishCategory category, HomeRecommendation recommendation) {
        return toVo(dish, currentUserId, category, recommendation, loadFavoriteIds(currentUserId));
    }

    private DishVo toVo(Dish dish, Long currentUserId, DishCategory category,
                        HomeRecommendation recommendation, Set<Long> favorites) {
        DishVo vo = new DishVo();
        vo.setId(dish.getId());
        vo.setCategoryId(dish.getCategoryId());
        vo.setCategoryName(category == null ? null : category.getName());
        vo.setCategoryCode(category == null ? null : category.getCode());
        vo.setDishCode(dish.getDishCode());
        vo.setName(dish.getName());
        vo.setDescription(dish.getDescription());
        vo.setIngredients(JsonUtils.toList(dish.getIngredientsJson()));
        vo.setAllergens(JsonUtils.toList(dish.getAllergensJson()));
        vo.setTags(JsonUtils.toList(dish.getTagsJson()));
        vo.setImageUrl(dish.getImageUrl());
        vo.setPrice(dish.getPrice());
        vo.setCalories(dish.getCalories());
        vo.setProteinG(dish.getProteinG());
        vo.setFatG(dish.getFatG());
        vo.setCarbohydrateG(dish.getCarbohydrateG());
        vo.setFiberG(dish.getFiberG());
        vo.setSodiumMg(dish.getSodiumMg());
        vo.setNutritionSource(dish.getNutritionSource());
        vo.setNutritionNote(dish.getNutritionNote());
        vo.setStock(dish.getStock());
        vo.setDailyLimit(dish.getDailyLimit());
        vo.setSoldCount(dish.getSoldCount());
        vo.setSupplyStatus(dish.getSupplyStatus());
        vo.setPublishStatus(dish.getPublishStatus());
        vo.setRecommendFlag(dish.getRecommendFlag() != null && dish.getRecommendFlag() == 1);
        vo.setRecommendRank(dish.getRecommendRank());
        vo.setSortOrder(dish.getSortOrder());
        vo.setCreatedAt(dish.getCreatedAt());
        vo.setUpdatedAt(dish.getUpdatedAt());

        boolean published = Constants.PublishStatus.PUBLISHED.equals(dish.getPublishStatus());
        boolean supplyOk = Constants.SupplyStatus.AVAILABLE.equals(dish.getSupplyStatus());
        boolean stockOk = dish.getStock() != null && dish.getStock() > 0;
        vo.setAvailable(published && supplyOk && stockOk);
        vo.setAvailabilityText(availabilityText(dish, published, supplyOk, stockOk));
        vo.setFavorited(currentUserId != null && favorites.contains(dish.getId()));
        if (recommendation != null && Integer.valueOf(1).equals(recommendation.getEnabled())) {
            vo.setRecommendationBadge(recommendation.getBadgeText());
            vo.setRecommendationSort(recommendation.getSortOrder());
        }
        return vo;
    }

    private String availabilityText(Dish dish, boolean published, boolean supplyOk, boolean stockOk) {
        if (!published) {
            return Labels.publishStatus(dish.getPublishStatus());
        }
        if (!supplyOk) {
            return Labels.supplyStatus(dish.getSupplyStatus());
        }
        if (!stockOk) {
            return "今日售罄";
        }
        return "供应中";
    }

    public Map<Long, DishCategory> loadCategoryMap() {
        return categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(DishCategory::getId, c -> c, (a, b) -> a));
    }

    private Map<Long, HomeRecommendation> loadRecommendationMap() {
        Map<Long, HomeRecommendation> map = new HashMap<>();
        for (HomeRecommendation recommendation : recommendationMapper.selectList(null)) {
            map.put(recommendation.getDishId(), recommendation);
        }
        return map;
    }

    public Set<Long> loadFavoriteIds(Long userId) {
        if (userId == null) {
            return new HashSet<>();
        }
        return favoriteMapper.selectList(new LambdaQueryWrapper<DishFavorite>()
                        .eq(DishFavorite::getUserId, userId))
                .stream().map(DishFavorite::getDishId).filter(Objects::nonNull)
                .collect(Collectors.toSet());
    }
}
