package com.canteen.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class StatisticsOverviewVo {
    private long todayOrders;
    private BigDecimal todaySales = BigDecimal.ZERO;
    private int todayDishesSold;
    private long weekOrders;
    private BigDecimal weekSales = BigDecimal.ZERO;
    private long monthOrders;
    private BigDecimal monthSales = BigDecimal.ZERO;
    private BigDecimal avgOrderAmount = BigDecimal.ZERO;
    private long dishCount;
    private long publishedDishCount;
    private long lowStockCount;
    private long soldOutCount;
    private long pendingOrderCount;
    private long userCount;
    private long activeUserCount;
    private long totalOrders;
    private BigDecimal totalSales = BigDecimal.ZERO;
    private String note;
}
