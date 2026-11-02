package com.canteen.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.canteen.entity.Work;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface WorkMapper extends BaseMapper<Work> {

    @Update("UPDATE work SET like_count = GREATEST(like_count + #{delta}, 0) WHERE id = #{workId}")
    int adjustLikeCount(@Param("workId") Long workId, @Param("delta") int delta);

    @Update("UPDATE work SET comment_count = GREATEST(comment_count + #{delta}, 0) WHERE id = #{workId}")
    int adjustCommentCount(@Param("workId") Long workId, @Param("delta") int delta);
}
