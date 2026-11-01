package com.canteen.vo;

import lombok.Data;

@Data
public class AuthTokenVo {
    private String token;
    private String tokenType = "Bearer";
    private long expiresIn;
    private UserVo user;
    private AdminVo admin;
}
