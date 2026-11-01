package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.canteen.common.BizException;
import com.canteen.common.Constants;
import com.canteen.common.ErrorCode;
import com.canteen.common.Permissions;
import com.canteen.config.CanteenProperties;
import com.canteen.dto.LoginRequest;
import com.canteen.dto.RegisterRequest;
import com.canteen.dto.UpdateProfileRequest;
import com.canteen.entity.SysAdmin;
import com.canteen.entity.SysUser;
import com.canteen.mapper.SysAdminMapper;
import com.canteen.mapper.SysUserMapper;
import com.canteen.security.JwtTokenProvider;
import com.canteen.security.LoginPrincipal;
import com.canteen.security.PrincipalType;
import com.canteen.vo.AdminVo;
import com.canteen.vo.AuthTokenVo;
import com.canteen.vo.UserVo;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户与管理员认证。密码一律 BCrypt 哈希，接口不返回任何密码字段。
 */
@Service
@RequiredArgsConstructor
public class AuthService {

    private final SysUserMapper userMapper;
    private final SysAdminMapper adminMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final CanteenProperties properties;

    @Transactional
    public AuthTokenVo register(RegisterRequest request) {
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw BizException.of(ErrorCode.BAD_REQUEST, "两次输入的密码不一致");
        }
        if (userMapper.selectCount(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getUsername, request.getUsername().trim())) > 0) {
            throw BizException.of(ErrorCode.CONFLICT, "该账号已被注册，请更换");
        }
        if (StringUtils.hasText(request.getEmail())
                && userMapper.selectCount(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getEmail, request.getEmail().trim())) > 0) {
            throw BizException.of(ErrorCode.CONFLICT, "该邮箱已被使用");
        }
        if (StringUtils.hasText(request.getPhone())
                && userMapper.selectCount(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getPhone, request.getPhone().trim())) > 0) {
            throw BizException.of(ErrorCode.CONFLICT, "该手机号已被使用");
        }
        SysUser user = new SysUser();
        user.setUsername(request.getUsername().trim());
        user.setNickname(request.getNickname().trim());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setEmail(StringUtils.hasText(request.getEmail()) ? request.getEmail().trim() : null);
        user.setPhone(StringUtils.hasText(request.getPhone()) ? request.getPhone().trim() : null);
        user.setStatus(Constants.UserStatus.ACTIVE);
        user.setAvatarUrl(null);
        userMapper.insert(user);
        return buildUserToken(user);
    }

    public AuthTokenVo login(LoginRequest request) {
        SysUser user = userMapper.selectOne(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getUsername, request.getUsername().trim()));
        if (user == null || !passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw BizException.of(ErrorCode.BAD_CREDENTIALS);
        }
        if (Constants.UserStatus.DISABLED.equals(user.getStatus())) {
            throw BizException.of(ErrorCode.FORBIDDEN, "该账号已被禁用，请联系管理员");
        }
        return buildUserToken(user);
    }

    public AuthTokenVo adminLogin(LoginRequest request) {
        SysAdmin admin = adminMapper.selectOne(new LambdaQueryWrapper<SysAdmin>()
                .eq(SysAdmin::getUsername, request.getUsername().trim()));
        if (admin == null || !passwordEncoder.matches(request.getPassword(), admin.getPasswordHash())) {
            throw BizException.of(ErrorCode.BAD_CREDENTIALS, "管理员账号或密码错误");
        }
        if (!"ACTIVE".equals(admin.getStatus())) {
            throw BizException.of(ErrorCode.FORBIDDEN, "该管理员账号已被停用");
        }
        admin.setLastLoginAt(LocalDateTime.now());
        adminMapper.updateById(admin);

        LoginPrincipal principal = new LoginPrincipal(admin.getId(), admin.getUsername(),
                admin.getDisplayName(), PrincipalType.ADMIN, admin.getRoleCode());
        AuthTokenVo vo = new AuthTokenVo();
        vo.setToken(tokenProvider.createToken(principal));
        vo.setExpiresIn(tokenProvider.getExpireSeconds());
        vo.setAdmin(toAdminVo(admin));
        return vo;
    }

    private AuthTokenVo buildUserToken(SysUser user) {
        LoginPrincipal principal = new LoginPrincipal(user.getId(), user.getUsername(),
                user.getNickname(), PrincipalType.USER, "USER");
        AuthTokenVo vo = new AuthTokenVo();
        vo.setToken(tokenProvider.createToken(principal));
        vo.setExpiresIn(tokenProvider.getExpireSeconds());
        vo.setUser(toUserVo(user));
        return vo;
    }

    public UserVo getCurrentUser(Long userId) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw BizException.of(ErrorCode.UNAUTHORIZED);
        }
        return toUserVo(user);
    }

    @Transactional
    public UserVo updateProfile(Long userId, UpdateProfileRequest request) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw BizException.of(ErrorCode.UNAUTHORIZED);
        }
        if (StringUtils.hasText(request.getNickname())) {
            user.setNickname(request.getNickname().trim());
        }
        if (StringUtils.hasText(request.getEmail())) {
            SysUser sameEmail = userMapper.selectOne(new LambdaQueryWrapper<SysUser>()
                    .eq(SysUser::getEmail, request.getEmail().trim()).ne(SysUser::getId, userId));
            if (sameEmail != null) {
                throw BizException.of(ErrorCode.CONFLICT, "该邮箱已被其他账号使用");
            }
            user.setEmail(request.getEmail().trim());
        }
        if (request.getPhone() != null) {
            String phone = request.getPhone().trim();
            if (!phone.isEmpty()) {
                SysUser samePhone = userMapper.selectOne(new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getPhone, phone).ne(SysUser::getId, userId));
                if (samePhone != null) {
                    throw BizException.of(ErrorCode.CONFLICT, "该手机号已被其他账号使用");
                }
            }
            user.setPhone(phone.isEmpty() ? null : phone);
        }
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl());
        }
        userMapper.updateById(user);
        return toUserVo(user);
    }

    public AdminVo getCurrentAdmin(Long adminId) {
        SysAdmin admin = adminMapper.selectById(adminId);
        if (admin == null) {
            throw BizException.of(ErrorCode.UNAUTHORIZED);
        }
        return toAdminVo(admin);
    }

    public List<AdminVo> listAdmins() {
        return adminMapper.selectList(new LambdaQueryWrapper<SysAdmin>().orderByAsc(SysAdmin::getId))
                .stream().map(this::toAdminVo).toList();
    }

    public UserVo toUserVo(SysUser user) {
        UserVo vo = new UserVo();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setNickname(user.getNickname());
        vo.setEmail(user.getEmail());
        vo.setPhone(user.getPhone());
        vo.setAvatarUrl(user.getAvatarUrl());
        vo.setStatus(user.getStatus());
        vo.setCreatedAt(user.getCreatedAt());
        return vo;
    }

    public AdminVo toAdminVo(SysAdmin admin) {
        AdminVo vo = new AdminVo();
        vo.setId(admin.getId());
        vo.setUsername(admin.getUsername());
        vo.setDisplayName(admin.getDisplayName());
        vo.setRoleCode(admin.getRoleCode());
        vo.setRoleLabel(com.canteen.common.Labels.role(admin.getRoleCode()));
        vo.setStatus(admin.getStatus());
        vo.setLastLoginAt(admin.getLastLoginAt());
        vo.setPermissions(Permissions.ofRole(admin.getRoleCode()));
        return vo;
    }

    public boolean isDemoMode() {
        return properties.getDemo().isEnabled();
    }
}
