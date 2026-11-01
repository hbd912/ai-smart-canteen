package com.canteen.common;

import lombok.Getter;
import org.springframework.http.HttpStatus;

/**
 * 业务错误码。与 HTTP 状态码保持语义一致，便于前端拦截器统一处理。
 */
@Getter
public enum ErrorCode {

    SUCCESS(0, "success", HttpStatus.OK),
    BAD_REQUEST(40000, "请求参数有误", HttpStatus.BAD_REQUEST),
    UNAUTHORIZED(40100, "登录状态已失效，请重新登录", HttpStatus.UNAUTHORIZED),
    BAD_CREDENTIALS(40101, "账号或密码错误", HttpStatus.UNAUTHORIZED),
    FORBIDDEN(40300, "没有权限执行该操作", HttpStatus.FORBIDDEN),
    NOT_FOUND(40400, "资源不存在", HttpStatus.NOT_FOUND),
    CONFLICT(40900, "数据冲突，请刷新后重试", HttpStatus.CONFLICT),
    STOCK_NOT_ENOUGH(40910, "库存不足，请调整数量", HttpStatus.CONFLICT),
    DISH_UNAVAILABLE(40911, "菜品已下架或已售罄", HttpStatus.CONFLICT),
    ORDER_STATE_INVALID(40912, "订单状态不允许该操作", HttpStatus.CONFLICT),
    CART_EMPTY(40913, "购物车为空，无法结算", HttpStatus.CONFLICT),
    BUSINESS_ERROR(42200, "业务处理失败", HttpStatus.UNPROCESSABLE_ENTITY),
    AI_UNAVAILABLE(50300, "AI 服务暂时不可用", HttpStatus.SERVICE_UNAVAILABLE),
    SERVER_ERROR(50000, "服务器开小差了，请稍后再试", HttpStatus.INTERNAL_SERVER_ERROR);

    private final int code;
    private final String message;
    private final HttpStatus status;

    ErrorCode(int code, String message, HttpStatus status) {
        this.code = code;
        this.message = message;
        this.status = status;
    }
}
