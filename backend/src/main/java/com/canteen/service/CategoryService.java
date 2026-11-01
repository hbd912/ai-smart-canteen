package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.canteen.common.BizException;
import com.canteen.common.Constants;
import com.canteen.common.ErrorCode;
import com.canteen.dto.CategorySaveRequest;
import com.canteen.dto.CategorySortRequest;
import com.canteen.entity.Dish;
import com.canteen.entity.DishCategory;
import com.canteen.mapper.DishCategoryMapper;
import com.canteen.mapper.DishMapper;
import com.canteen.vo.CategoryVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 菜品分类业务。前台只返回启用的分类，后台可管理全部；前后台同一数据源。
 */
@Service
@RequiredArgsConstructor
public class CategoryService {

    private final DishCategoryMapper categoryMapper;
    private final DishMapper dishMapper;

    public List<CategoryVo> listForCustomer() {
        List<DishCategory> categories = categoryMapper.selectList(new LambdaQueryWrapper<DishCategory>()
                .eq(DishCategory::getStatus, "ACTIVE")
                .orderByAsc(DishCategory::getSortOrder)
                .orderByAsc(DishCategory::getId));
        return toVoList(categories, true);
    }

    public List<CategoryVo> listForAdmin() {
        List<DishCategory> categories = categoryMapper.selectList(new LambdaQueryWrapper<DishCategory>()
                .orderByAsc(DishCategory::getSortOrder)
                .orderByAsc(DishCategory::getId));
        return toVoList(categories, false);
    }

    private List<CategoryVo> toVoList(List<DishCategory> categories, boolean onlyPublishedDishes) {
        Map<Long, Long> counts = dishMapper.selectList(new LambdaQueryWrapper<Dish>()
                        .eq(onlyPublishedDishes, Dish::getPublishStatus, Constants.PublishStatus.PUBLISHED))
                .stream()
                .filter(d -> d.getCategoryId() != null)
                .collect(Collectors.groupingBy(Dish::getCategoryId, Collectors.counting()));
        List<CategoryVo> list = new ArrayList<>();
        for (DishCategory category : categories) {
            CategoryVo vo = new CategoryVo();
            vo.setId(category.getId());
            vo.setName(category.getName());
            vo.setCode(category.getCode());
            vo.setIcon(category.getIcon());
            vo.setCoverImage(category.getCoverImage());
            vo.setSortOrder(category.getSortOrder());
            vo.setStatus(category.getStatus());
            vo.setCreatedAt(category.getCreatedAt());
            vo.setDishCount(counts.getOrDefault(category.getId(), 0L));
            list.add(vo);
        }
        return list;
    }

    @Transactional
    public CategoryVo create(CategorySaveRequest request) {
        String code = StringUtils.hasText(request.getCode())
                ? request.getCode().trim().toUpperCase()
                : generateCode(request.getName());
        if (categoryMapper.selectCount(new LambdaQueryWrapper<DishCategory>()
                .eq(DishCategory::getCode, code)) > 0) {
            throw BizException.of(ErrorCode.CONFLICT, "分类编码已存在：" + code);
        }
        if (categoryMapper.selectCount(new LambdaQueryWrapper<DishCategory>()
                .eq(DishCategory::getName, request.getName().trim())) > 0) {
            throw BizException.of(ErrorCode.CONFLICT, "分类名称已存在：" + request.getName());
        }
        DishCategory category = new DishCategory();
        category.setName(request.getName().trim());
        category.setCode(code);
        category.setIcon(request.getIcon());
        category.setCoverImage(request.getCoverImage());
        category.setSortOrder(request.getSortOrder() == null ? nextSortOrder() : request.getSortOrder());
        category.setStatus(StringUtils.hasText(request.getStatus()) ? request.getStatus() : "ACTIVE");
        categoryMapper.insert(category);
        return toVoList(List.of(category), false).get(0);
    }

    @Transactional
    public CategoryVo update(Long id, CategorySaveRequest request) {
        DishCategory category = requireCategory(id);
        if (StringUtils.hasText(request.getCode())
                && !request.getCode().equalsIgnoreCase(category.getCode())) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "分类编码创建后不可修改");
        }
        DishCategory sameName = categoryMapper.selectOne(new LambdaQueryWrapper<DishCategory>()
                .eq(DishCategory::getName, request.getName().trim()).ne(DishCategory::getId, id));
        if (sameName != null) {
            throw BizException.of(ErrorCode.CONFLICT, "分类名称已存在：" + request.getName());
        }
        category.setName(request.getName().trim());
        category.setIcon(request.getIcon());
        category.setCoverImage(request.getCoverImage());
        if (request.getSortOrder() != null) {
            category.setSortOrder(request.getSortOrder());
        }
        if (StringUtils.hasText(request.getStatus())) {
            category.setStatus(request.getStatus());
        }
        categoryMapper.updateById(category);
        return toVoList(List.of(category), false).get(0);
    }

    @Transactional
    public void changeStatus(Long id, String status) {
        if (!Set.of("ACTIVE", "INACTIVE").contains(status)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "不支持的分类状态：" + status);
        }
        DishCategory category = requireCategory(id);
        category.setStatus(status);
        categoryMapper.updateById(category);
    }

    @Transactional
    public void sort(CategorySortRequest request) {
        for (CategorySortRequest.Item item : request.getItems()) {
            DishCategory category = categoryMapper.selectById(item.getId());
            if (category == null) {
                continue;
            }
            category.setSortOrder(item.getSortOrder());
            categoryMapper.updateById(category);
        }
    }

    @Transactional
    public void delete(Long id) {
        DishCategory category = requireCategory(id);
        long dishCount = dishMapper.selectCount(new LambdaQueryWrapper<Dish>()
                .eq(Dish::getCategoryId, category.getId()));
        if (dishCount > 0) {
            throw BizException.of(ErrorCode.CONFLICT,
                    "该分类下仍有 " + dishCount + " 道菜品，请先迁移分类或下架菜品后再删除");
        }
        categoryMapper.deleteById(id);
    }

    private DishCategory requireCategory(Long id) {
        DishCategory category = categoryMapper.selectById(id);
        if (category == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "分类不存在");
        }
        return category;
    }

    private int nextSortOrder() {
        List<DishCategory> all = categoryMapper.selectList(new LambdaQueryWrapper<DishCategory>()
                .orderByDesc(DishCategory::getSortOrder).last("LIMIT 1"));
        return all.isEmpty() ? 1 : all.get(0).getSortOrder() + 1;
    }

    private String generateCode(String name) {
        String base = "CAT_" + Math.abs(name.hashCode() % 100000);
        String code = base;
        int suffix = 0;
        while (categoryMapper.selectCount(new LambdaQueryWrapper<DishCategory>()
                .eq(DishCategory::getCode, code)) > 0) {
            suffix++;
            code = base + "_" + suffix;
        }
        return code;
    }
}
