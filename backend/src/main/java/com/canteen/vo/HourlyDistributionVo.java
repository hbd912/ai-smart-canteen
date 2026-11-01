package com.canteen.vo;

import lombok.Data;

import java.util.List;

@Data
public class HourlyDistributionVo {
    /** 0-23 点，长度固定 24 */
    private List<String> labels;
    private List<Long> counts;
    private String note;
}
