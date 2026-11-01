package com.canteen.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class UserVo {
    private Long id;
    private String username;
    private String nickname;
    private String email;
    private String phone;
    private String avatarUrl;
    private String status;
    private LocalDateTime createdAt;
    private long orderCount;
    private List<String> preferences;
}
