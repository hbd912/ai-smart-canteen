package com.canteen.config;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.canteen.common.Constants;
import com.canteen.common.Permissions;
import com.canteen.entity.SysAdmin;
import com.canteen.entity.SysUser;
import com.canteen.mapper.SysAdminMapper;
import com.canteen.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * 演示账号初始化。密码使用 BCrypt 编码后写入，SQL 脚本中不出现任何密码哈希。
 * 已存在的账号不会被覆盖或重置密码。
 */
@Slf4j
@Component
@Order(1)
@RequiredArgsConstructor
public class DemoAccountInitializer implements ApplicationRunner {

    private final SysUserMapper userMapper;
    private final SysAdminMapper adminMapper;
    private final PasswordEncoder passwordEncoder;
    private final CanteenProperties properties;

    @Override
    public void run(ApplicationArguments args) {
        if (!properties.getDemo().isEnabled()) {
            log.info("演示账号初始化已关闭（canteen.demo.enabled=false）");
            return;
        }
        createUserIfAbsent("student", "课堂演示用户", properties.getDemo().getUserPassword());
        createUserIfAbsent("demo_user_02", "演示用户二", properties.getDemo().getUserPassword());
        createAdminIfAbsent("admin", "食堂超级管理员",
                Constants.AdminRole.SUPER_ADMIN, properties.getDemo().getAdminPassword());
    }

    private void createUserIfAbsent(String username, String nickname, String rawPassword) {
        long exists = userMapper.selectCount(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getUsername, username));
        if (exists > 0) {
            log.debug("演示用户 {} 已存在，跳过创建", username);
            return;
        }
        SysUser user = new SysUser();
        user.setUsername(username);
        user.setNickname(nickname);
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        user.setStatus(Constants.UserStatus.ACTIVE);
        user.setAvatarUrl(null);
        userMapper.insert(user);
        log.info("已创建演示用户：{}（密码来自 DEMO_USER_PASSWORD 或默认演示密码）", username);
    }

    private void createAdminIfAbsent(String username, String displayName, String role, String rawPassword) {
        long exists = adminMapper.selectCount(new LambdaQueryWrapper<SysAdmin>()
                .eq(SysAdmin::getUsername, username));
        if (exists > 0) {
            log.debug("管理员 {} 已存在，跳过创建", username);
            return;
        }
        SysAdmin admin = new SysAdmin();
        admin.setUsername(username);
        admin.setDisplayName(displayName);
        admin.setPasswordHash(passwordEncoder.encode(rawPassword));
        admin.setRoleCode(role);
        admin.setPermissions(String.join(",", Permissions.ofRole(role)));
        admin.setStatus("ACTIVE");
        adminMapper.insert(admin);
        log.info("已创建管理员：{}（角色 {}，密码来自 DEMO_ADMIN_PASSWORD 或默认演示密码）", username, role);
    }
}
