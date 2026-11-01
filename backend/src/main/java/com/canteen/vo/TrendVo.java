package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class TrendVo {
    private String period;
    private List<String> labels;
    private List<Long> orderCounts;
    private List<BigDecimal> salesAmounts;
    private String note;
}
