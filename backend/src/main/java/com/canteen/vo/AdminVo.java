package com.canteen.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class AdminVo {
    private Long id;
    private String username;
    private String displayName;
    private String roleCode;
    private String roleLabel;
    private String status;
    private List<String> permissions;
    private LocalDateTime lastLoginAt;
}
