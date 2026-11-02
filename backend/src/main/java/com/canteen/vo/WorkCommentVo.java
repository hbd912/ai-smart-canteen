package com.canteen.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class WorkCommentVo {
    private Long id;
    private Long workId;
    private Long userId;
    private String authorNickname;
    private String authorInitial;
    private String content;
    private LocalDateTime createdAt;
}
