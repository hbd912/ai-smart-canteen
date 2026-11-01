package com.canteen.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank(message = "请输入账号")
    @Size(min = 3, max = 20, message = "账号长度需在 3-20 个字符之间")
    @Pattern(regexp = "^[A-Za-z0-9_@.\\-]+$", message = "账号只能包含字母、数字、下划线、@ . -")
    private String username;

    @NotBlank(message = "请输入昵称")
    @Size(min = 1, max = 20, message = "昵称长度需在 1-20 个字符之间")
    private String nickname;

    @NotBlank(message = "请输入密码")
    @Size(min = 6, max = 32, message = "密码长度需在 6-32 个字符之间")
    private String password;

    @NotBlank(message = "请再次输入密码")
    private String confirmPassword;

    @Email(message = "邮箱格式不正确")
    @Size(max = 100, message = "邮箱长度超出限制")
    private String email;

    @Pattern(regexp = "^$|^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;
}
