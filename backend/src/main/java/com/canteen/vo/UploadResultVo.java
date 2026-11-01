package com.canteen.vo;

import lombok.Data;

@Data
public class UploadResultVo {
    private String url;
    private String fileName;
    private long size;
    private String contentType;
    private Integer width;
    private Integer height;
    private String note;
}
