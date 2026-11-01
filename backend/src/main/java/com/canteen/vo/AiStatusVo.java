package com.canteen.vo;

import lombok.Data;

@Data
public class AiStatusVo {
    private boolean configured;
    private boolean available;
    private String mode;
    private String modeLabel;
    private String model;
    private String message;
    private String lastError;
}
