package com.canteen.security;

import com.canteen.common.BizException;
import com.canteen.common.ErrorCode;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * 当前登录主体读取工具。禁止组件自行从请求参数取 userId。
 */
public final class SecurityUtils {

    private SecurityUtils() {
    }

    public static LoginPrincipal currentPrincipalOrNull() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof LoginPrincipal principal) {
            return principal;
        }
        return null;
    }

    public static LoginPrincipal currentUser() {
        LoginPrincipal principal = currentPrincipalOrNull();
        if (principal == null || principal.isAdmin()) {
            throw BizException.of(ErrorCode.UNAUTHORIZED);
        }
        return principal;
    }

    public static Long currentUserId() {
        return currentUser().getId();
    }

    public static LoginPrincipal currentAdmin() {
        LoginPrincipal principal = currentPrincipalOrNull();
        if (principal == null || !principal.isAdmin()) {
            throw BizException.of(ErrorCode.FORBIDDEN);
        }
        return principal;
    }

    public static Long currentAdminIdOrNull() {
        LoginPrincipal principal = currentPrincipalOrNull();
        return principal != null && principal.isAdmin() ? principal.getId() : null;
    }
}
