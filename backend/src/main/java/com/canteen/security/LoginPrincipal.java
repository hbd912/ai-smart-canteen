package com.canteen.security;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * JWT 中携带的最小身份信息，不包含密码等敏感字段。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginPrincipal {

    private Long id;
    private String username;
    private String displayName;
    private PrincipalType type;
    private String role;

    public boolean isAdmin() {
        return type == PrincipalType.ADMIN;
    }
}
