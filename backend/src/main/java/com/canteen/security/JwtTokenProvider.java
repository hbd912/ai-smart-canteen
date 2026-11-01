package com.canteen.security;

import com.canteen.common.BizException;
import com.canteen.common.ErrorCode;
import com.canteen.config.CanteenProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;

/**
 * JWT 签发与解析。密钥只从后端配置/环境变量读取，绝不下发前端。
 */
@Component
public class JwtTokenProvider {

    private static final String CLAIM_TYPE = "type";
    private static final String CLAIM_ROLE = "role";
    private static final String CLAIM_NAME = "name";

    private final CanteenProperties properties;
    private final SecretKey key;

    public JwtTokenProvider(CanteenProperties properties) {
        this.properties = properties;
        byte[] secret = properties.getJwt().getSecret().getBytes(StandardCharsets.UTF_8);
        if (secret.length < 32) {
            throw new IllegalStateException("canteen.jwt.secret 长度必须不少于 32 字节");
        }
        this.key = Keys.hmacShaKeyFor(secret);
    }

    public String createToken(LoginPrincipal principal) {
        Instant now = Instant.now();
        Instant expiry = now.plusSeconds(properties.getJwt().getExpireMinutes() * 60);
        return Jwts.builder()
                .issuer(properties.getJwt().getIssuer())
                .subject(String.valueOf(principal.getId()))
                .claim(CLAIM_TYPE, principal.getType().name())
                .claim(CLAIM_ROLE, principal.getRole())
                .claim(CLAIM_NAME, principal.getUsername())
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiry))
                .signWith(key)
                .compact();
    }

    public long getExpireSeconds() {
        return properties.getJwt().getExpireMinutes() * 60;
    }

    public LoginPrincipal parseToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(key)
                    .requireIssuer(properties.getJwt().getIssuer())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            LoginPrincipal principal = new LoginPrincipal();
            principal.setId(Long.valueOf(claims.getSubject()));
            principal.setUsername(claims.get(CLAIM_NAME, String.class));
            principal.setDisplayName(claims.get(CLAIM_NAME, String.class));
            principal.setType(PrincipalType.valueOf(claims.get(CLAIM_TYPE, String.class)));
            principal.setRole(claims.get(CLAIM_ROLE, String.class));
            return principal;
        } catch (JwtException | IllegalArgumentException ex) {
            throw BizException.of(ErrorCode.UNAUTHORIZED);
        }
    }
}
