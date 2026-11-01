package com.canteen.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 项目自定义配置（canteen.*）。
 */
@Data
@Component
@ConfigurationProperties(prefix = "canteen")
public class CanteenProperties {

    private Jwt jwt = new Jwt();
    private Cors cors = new Cors();
    private Demo demo = new Demo();
    private Upload upload = new Upload();
    private Ai ai = new Ai();

    @Data
    public static class Jwt {
        private String secret = "canteen-demo-jwt-secret-key-please-change-in-production-2026";
        private long expireMinutes = 720;
        private String issuer = "canteen-system";
    }

    @Data
    public static class Cors {
        private List<String> allowedOrigins = List.of("http://localhost:5173");
    }

    @Data
    public static class Demo {
        private boolean enabled = true;
        /** 普通演示账号密码（默认 123456，可用 DEMO_USER_PASSWORD 覆盖） */
        private String userPassword = "123456";
        private String adminPassword = "Admin@123456";
        private boolean orderSeedEnabled = true;
    }

    @Data
    public static class Upload {
        private String dir = "./uploads";
        private int maxSizeMb = 5;
    }

    @Data
    public static class Ai {
        private boolean enabled = true;
        private String baseUrl = "https://api.deepseek.com/v1";
        private String apiKey = "";
        private String model = "deepseek-chat";
        private int timeoutSeconds = 20;
        private double temperature = 0.3;
    }
}
