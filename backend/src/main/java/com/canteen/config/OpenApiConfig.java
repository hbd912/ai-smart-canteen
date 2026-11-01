package com.canteen.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    private static final String SECURITY_SCHEME = "bearerAuth";

    @Bean
    public OpenAPI canteenOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("AI 智慧食堂 API")
                        .version("v1")
                        .description("Spring Boot 3 + Vue 3 课程大作业：用户端沉浸式点餐 + 管理员后台 + AI 智能推荐")
                        .contact(new Contact().name("Canteen Team")))
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME))
                .components(new Components().addSecuritySchemes(SECURITY_SCHEME,
                        new SecurityScheme()
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("登录后获得的 JWT，请填入纯 token（无需 Bearer 前缀）")));
    }
}
