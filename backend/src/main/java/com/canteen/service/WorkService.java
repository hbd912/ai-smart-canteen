package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.canteen.common.BizException;
import com.canteen.common.ErrorCode;
import com.canteen.common.JsonUtils;
import com.canteen.entity.Dish;
import com.canteen.entity.SysUser;
import com.canteen.entity.Work;
import com.canteen.entity.WorkComment;
import com.canteen.entity.WorkLike;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.SysUserMapper;
import com.canteen.mapper.WorkCommentMapper;
import com.canteen.mapper.WorkLikeMapper;
import com.canteen.mapper.WorkMapper;
import com.canteen.vo.WorkCommentVo;
import com.canteen.vo.WorkVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 精选作品：用户发布菜品实拍 + 评价，支持点赞与评论。
 * 作品关联 dish，点击可跳转点餐页下单。
 */
@Service
@RequiredArgsConstructor
public class WorkService {

    private static final String STATUS_APPROVED = "APPROVED";

    private final WorkMapper workMapper;
    private final WorkLikeMapper likeMapper;
    private final WorkCommentMapper commentMapper;
    private final SysUserMapper userMapper;
    private final DishMapper dishMapper;

    /** 作品流：sort = hot（按点赞）/ latest（按时间） */
    public List<WorkVo> feed(String sort, long page, long pageSize, Long currentUserId) {
        LambdaQueryWrapper<Work> wrapper = new LambdaQueryWrapper<Work>()
                .eq(Work::getStatus, STATUS_APPROVED);
        if ("hot".equalsIgnoreCase(sort)) {
            wrapper.orderByDesc(Work::getLikeCount).orderByDesc(Work::getCreatedAt);
        } else {
            wrapper.orderByDesc(Work::getCreatedAt);
        }
        Page<Work> paged = workMapper.selectPage(
                new Page<>(Math.max(page, 1), Math.min(Math.max(pageSize, 1), 50)), wrapper);
        return toVoList(paged.getRecords(), currentUserId);
    }

    /** 作品详情（含评论） */
    public WorkVo detail(Long id, Long currentUserId) {
        Work work = workMapper.selectById(id);
        if (work == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "作品不存在");
        }
        WorkVo vo = toVoList(List.of(work), currentUserId).get(0);
        vo.setComments(listComments(id));
        return vo;
    }

    /** 点赞 / 取消点赞 */
    @Transactional
    public boolean toggleLike(Long userId, Long workId) {
        Work work = workMapper.selectById(workId);
        if (work == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "作品不存在");
        }
        WorkLike existing = likeMapper.selectOne(new LambdaQueryWrapper<WorkLike>()
                .eq(WorkLike::getUserId, userId).eq(WorkLike::getWorkId, workId));
        if (existing != null) {
            likeMapper.deleteById(existing.getId());
            workMapper.adjustLikeCount(workId, -1);
            return false;
        }
        WorkLike like = new WorkLike();
        like.setUserId(userId);
        like.setWorkId(workId);
        likeMapper.insert(like);
        workMapper.adjustLikeCount(workId, 1);
        return true;
    }

    /** 评论列表 */
    public List<WorkCommentVo> listComments(Long workId) {
        List<WorkComment> list = commentMapper.selectList(new LambdaQueryWrapper<WorkComment>()
                .eq(WorkComment::getWorkId, workId)
                .eq(WorkComment::getStatus, STATUS_APPROVED)
                .orderByAsc(WorkComment::getCreatedAt));
        if (list.isEmpty()) {
            return List.of();
        }
        Map<Long, SysUser> users = loadUsers(list.stream().map(WorkComment::getUserId).toList());
        return list.stream().map(c -> {
            WorkCommentVo vo = new WorkCommentVo();
            vo.setId(c.getId());
            vo.setWorkId(c.getWorkId());
            vo.setUserId(c.getUserId());
            SysUser u = users.get(c.getUserId());
            String nick = u == null ? "匿名用户" : u.getNickname();
            vo.setAuthorNickname(nick);
            vo.setAuthorInitial(nick.isEmpty() ? "食" : nick.substring(0, 1));
            vo.setContent(c.getContent());
            vo.setCreatedAt(c.getCreatedAt());
            return vo;
        }).toList();
    }

    /** 发表评论 */
    @Transactional
    public WorkCommentVo addComment(Long userId, Long workId, String content) {
        if (!StringUtils.hasText(content)) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "评论内容不能为空");
        }
        Work work = workMapper.selectById(workId);
        if (work == null) {
            throw BizException.of(ErrorCode.NOT_FOUND, "作品不存在");
        }
        WorkComment c = new WorkComment();
        c.setWorkId(workId);
        c.setUserId(userId);
        c.setContent(content.trim());
        c.setStatus(STATUS_APPROVED);
        commentMapper.insert(c);
        workMapper.adjustCommentCount(workId, 1);

        SysUser u = userMapper.selectById(userId);
        String nick = u == null ? "匿名用户" : u.getNickname();
        WorkCommentVo vo = new WorkCommentVo();
        vo.setId(c.getId());
        vo.setWorkId(workId);
        vo.setUserId(userId);
        vo.setAuthorNickname(nick);
        vo.setAuthorInitial(nick.isEmpty() ? "食" : nick.substring(0, 1));
        vo.setContent(c.getContent());
        vo.setCreatedAt(c.getCreatedAt());
        return vo;
    }

    // ---------------------------------------------------------------
    // 转换
    // ---------------------------------------------------------------

    private List<WorkVo> toVoList(List<Work> works, Long currentUserId) {
        if (works == null || works.isEmpty()) {
            return List.of();
        }
        Map<Long, SysUser> users = loadUsers(works.stream().map(Work::getUserId).toList());
        List<Long> dishIds = works.stream().map(Work::getDishId).filter(Objects::nonNull).distinct().toList();
        Map<Long, Dish> dishes = dishIds.isEmpty() ? Map.of()
                : dishMapper.selectBatchIds(dishIds).stream()
                .collect(Collectors.toMap(Dish::getId, d -> d, (a, b) -> a));
        Set<Long> likedIds = currentUserId == null ? Set.of()
                : likeMapper.selectList(new LambdaQueryWrapper<WorkLike>()
                .eq(WorkLike::getUserId, currentUserId))
                .stream().map(WorkLike::getWorkId).collect(Collectors.toSet());

        return works.stream().map(w -> {
            WorkVo vo = new WorkVo();
            vo.setId(w.getId());
            vo.setUserId(w.getUserId());
            SysUser u = users.get(w.getUserId());
            String nick = u == null ? "匿名用户" : u.getNickname();
            vo.setAuthorNickname(nick);
            vo.setAuthorInitial(nick.isEmpty() ? "食" : nick.substring(0, 1));
            vo.setDishId(w.getDishId());
            Dish d = w.getDishId() == null ? null : dishes.get(w.getDishId());
            vo.setDishName(d == null ? null : d.getName());
            vo.setDishPrice(d == null ? null : d.getPrice());
            vo.setTitle(w.getTitle());
            vo.setContent(w.getContent());
            vo.setImages(JsonUtils.toList(w.getImagesJson()));
            vo.setLikeCount(w.getLikeCount() == null ? 0 : w.getLikeCount());
            vo.setCommentCount(w.getCommentCount() == null ? 0 : w.getCommentCount());
            vo.setLiked(likedIds.contains(w.getId()));
            vo.setStatus(w.getStatus());
            vo.setCreatedAt(w.getCreatedAt());
            return vo;
        }).toList();
    }

    private Map<Long, SysUser> loadUsers(List<Long> ids) {
        List<Long> distinct = ids.stream().filter(Objects::nonNull).distinct().toList();
        if (distinct.isEmpty()) {
            return Map.of();
        }
        return userMapper.selectBatchIds(distinct).stream()
                .collect(Collectors.toMap(SysUser::getId, u -> u, (a, b) -> a));
    }
}
