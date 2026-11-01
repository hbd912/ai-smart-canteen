package com.canteen.vo;

import lombok.Data;

import java.util.List;

@Data
public class UserGrowthVo {
    private List<String> labels;
    private List<Long> newUsers;
    private List<Long> cumulativeUsers;
    private String note;
}
