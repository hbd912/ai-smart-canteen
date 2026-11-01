package com.canteen.security;

/**
 * 登录主体类型：普通用户 / 管理员。用于 JWT claim 与权限前缀区分。
 */
public enum PrincipalType {
    USER,
    ADMIN
}
