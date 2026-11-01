package com.canteen.common;

import lombok.Getter;

/**
 * 业务异常。所有可预期的业务错误都应抛出该异常，由统一异常处理器转成标准响应。
 */
@Getter
public class BizException extends RuntimeException {

    private final ErrorCode errorCode;

    public BizException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }

    public BizException(ErrorCode errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public static BizException of(ErrorCode code) {
        return new BizException(code);
    }

    public static BizException of(ErrorCode code, String message) {
        return new BizException(code, message);
    }
}
