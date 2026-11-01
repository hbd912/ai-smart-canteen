<script setup lang="ts">
/**
 * 数据统计页：4+ 张 ECharts 图表，全部数据来自后端统计接口。
 * 支持周/月切换、空数据状态、Tooltip。
 */
import { computed, onMounted, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import EChart from '@/components/admin/EChart.vue'
import { adminApi } from '@/api/modules'
import type { CategorySales, HourlyDistribution, Ranking, StatisticsOverview, Trend, UserGrowth } from '@/types/api'
import { formatMoney } from '@/utils/format'

const loading = ref(true)
const error = ref<string | null>(null)
const overview = ref<StatisticsOverview | null>(null)
const trend = ref<Trend | null>(null)
const ranking = ref<Ranking | null>(null)
const categorySales = ref<CategorySales | null>(null)
const hourly = ref<HourlyDistribution | null>(null)
const userGrowth = ref<UserGrowth | null>(null)
const period = ref<'week' | 'month'>('week')

const kpiCards = computed(() => {
  const data = overview.value
  if (!data) {
    return []
  }
  return [
    { label: '近 7 天订单', value: data.weekOrders, unit: '笔', icon: 'clipboard-list' },
    { label: '近 7 天销售额', value: `¥${formatMoney(data.weekSales)}`, unit: '', icon: 'trend-up' },
    { label: '近 30 天订单', value: data.monthOrders, unit: '笔', icon: 'calendar' },
    { label: '近 30 天销售额', value: `¥${formatMoney(data.monthSales)}`, unit: '', icon: 'pie-chart' },
    { label: '客单价', value: `¥${formatMoney(data.avgOrderAmount)}`, unit: '', icon: 'award' },
    { label: '注册用户', value: data.userCount, unit: '人', icon: 'users' }
  ]
})

const trendOption = computed(() => {
  const data = trend.value
  if (!data || data.labels.length === 0 || data.orderCounts.every((v) => v === 0)) {
    return null
  }
  return {
    tooltip: { trigger: 'axis' },
    legend: { data: ['订单量', '销售额'], bottom: 0, icon: 'roundRect', itemWidth: 10, itemHeight: 10, textStyle: { fontSize: 11 } },
    grid: { left: 14, right: 18, top: 26, bottom: 44, containLabel: true },
    xAxis: {
      type: 'category',
      data: data.labels,
      axisTick: { show: false },
      axisLine: { lineStyle: { color: 'rgba(124,143,90,0.3)' } },
      axisLabel: { fontSize: 10, color: '#8B8478' }
    },
    yAxis: [
      { type: 'value', name: '订单量', nameTextStyle: { fontSize: 10 }, splitLine: { lineStyle: { color: 'rgba(124,143,90,0.1)' } }, axisLabel: { fontSize: 10 } },
      { type: 'value', name: '销售额', nameTextStyle: { fontSize: 10 }, splitLine: { show: false }, axisLabel: { fontSize: 10 } }
    ],
    series: [
      {
        name: '订单量',
        type: 'line',
        smooth: true,
        data: data.orderCounts,
        symbol: 'circle',
        symbolSize: 7,
        lineStyle: { width: 2.6, color: '#5F7850' },
        itemStyle: { color: '#5F7850' },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(95,120,80,0.26)' },
              { offset: 1, color: 'rgba(95,120,80,0)' }
            ]
          }
        }
      },
      {
        name: '销售额',
        type: 'bar',
        yAxisIndex: 1,
        data: data.salesAmounts,
        barWidth: 14,
        itemStyle: { borderRadius: [5, 5, 0, 0], color: '#E8A95A' }
      }
    ]
  }
})

const rankingOption = computed(() => {
  const items = ranking.value?.items ?? []
  if (items.length === 0) {
    return null
  }
  const sorted = [...items].reverse()
  return {
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: 10, right: 46, top: 14, bottom: 10, containLabel: true },
    xAxis: { type: 'value', splitLine: { lineStyle: { color: 'rgba(124,143,90,0.1)' } }, axisLabel: { fontSize: 10 } },
    yAxis: {
      type: 'category',
      data: sorted.map((item) => item.name),
      axisTick: { show: false },
      axisLine: { lineStyle: { color: 'rgba(124,143,90,0.3)' } },
      axisLabel: { fontSize: 11, color: '#514C44' }
    },
    series: [
      {
        type: 'bar',
        data: sorted.map((item) => item.quantity),
        barWidth: 14,
        itemStyle: {
          borderRadius: [0, 6, 6, 0],
          color: {
            type: 'linear', x: 0, y: 0, x2: 1, y2: 0,
            colorStops: [
              { offset: 0, color: '#D3DCC4' },
              { offset: 1, color: '#5F7850' }
            ]
          }
        },
        label: { show: true, position: 'right', fontSize: 10, color: '#6B6459', formatter: '{c} 份' }
      }
    ]
  }
})

const categoryOption = computed(() => {
  const items = categorySales.value?.items ?? []
  if (items.length === 0) {
    return null
  }
  return {
    tooltip: { trigger: 'item', formatter: '{b}<br/>销量 {c} 份（{d}%）' },
    legend: { bottom: 0, icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 11 } },
    series: [
      {
        type: 'pie',
        radius: ['42%', '68%'],
        center: ['50%', '43%'],
        itemStyle: { borderColor: '#FFFDF8', borderWidth: 2, borderRadius: 4 },
        label: { fontSize: 10, color: '#6B6459', formatter: '{b}\n{d}%' },
        labelLine: { length: 8, length2: 8 },
        data: items.map((item) => ({ name: item.categoryName, value: item.quantity }))
      }
    ]
  }
})

const hourlyOption = computed(() => {
  const data = hourly.value
  if (!data || data.counts.every((v) => v === 0)) {
    return null
  }
  return {
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: 12, right: 16, top: 20, bottom: 26, containLabel: true },
    xAxis: {
      type: 'category',
      data: data.labels,
      axisTick: { show: false },
      axisLine: { lineStyle: { color: 'rgba(124,143,90,0.3)' } },
      axisLabel: { fontSize: 9, color: '#8B8478', interval: 2 }
    },
    yAxis: { type: 'value', splitLine: { lineStyle: { color: 'rgba(124,143,90,0.1)' } }, axisLabel: { fontSize: 10 } },
    series: [
      {
        type: 'bar',
        data: data.counts,
        barWidth: '58%',
        itemStyle: { borderRadius: [4, 4, 0, 0], color: '#97A97A' }
      }
    ]
  }
})

const growthOption = computed(() => {
  const data = userGrowth.value
  if (!data || data.labels.length === 0) {
    return null
  }
  return {
    tooltip: { trigger: 'axis' },
    legend: { data: ['新增用户', '累计用户'], bottom: 0, icon: 'roundRect', itemWidth: 10, itemHeight: 10, textStyle: { fontSize: 11 } },
    grid: { left: 12, right: 18, top: 22, bottom: 42, containLabel: true },
    xAxis: {
      type: 'category',
      data: data.labels,
      axisTick: { show: false },
      axisLine: { lineStyle: { color: 'rgba(124,143,90,0.3)' } },
      axisLabel: { fontSize: 10, color: '#8B8478' }
    },
    yAxis: { type: 'value', splitLine: { lineStyle: { color: 'rgba(124,143,90,0.1)' } }, axisLabel: { fontSize: 10 } },
    series: [
      {
        name: '新增用户',
        type: 'bar',
        data: data.newUsers,
        barWidth: 14,
        itemStyle: { borderRadius: [4, 4, 0, 0], color: '#B6C4A0' }
      },
      {
        name: '累计用户',
        type: 'line',
        data: data.cumulativeUsers,
        smooth: true,
        symbol: 'circle',
        symbolSize: 6,
        lineStyle: { width: 2.4, color: '#D98F38' },
        itemStyle: { color: '#D98F38' }
      }
    ]
  }
})

async function loadTrend() {
  try {
    trend.value = (await adminApi.statisticsTrend(period.value)) as unknown as Trend
  } catch {
    trend.value = null
  }
}

async function load() {
  loading.value = true
  error.value = null
  try {
    const [ov, rank, cat, hour, growth] = await Promise.allSettled([
      adminApi.statisticsOverview(),
      adminApi.statisticsRanking(10),
      adminApi.statisticsCategorySales(),
      adminApi.statisticsHourly(),
      adminApi.statisticsUserGrowth()
    ])
    if (ov.status === 'fulfilled') {
      overview.value = ov.value as unknown as StatisticsOverview
    }
    if (rank.status === 'fulfilled') {
      ranking.value = rank.value as unknown as Ranking
    }
    if (cat.status === 'fulfilled') {
      categorySales.value = cat.value as unknown as CategorySales
    }
    if (hour.status === 'fulfilled') {
      hourly.value = hour.value as unknown as HourlyDistribution
    }
    if (growth.status === 'fulfilled') {
      userGrowth.value = growth.value as unknown as UserGrowth
    }
    await loadTrend()
    if (ov.status === 'rejected') {
      error.value = '统计数据加载失败，请稍后重试'
    }
  } finally {
    loading.value = false
  }
}

function switchPeriod(next: 'week' | 'month') {
  period.value = next
  loadTrend()
}

onMounted(load)
</script>

<template>
  <div class="stats-page">
    <header class="page-head">
      <div>
        <h2 class="page-head__title">数据统计</h2>
        <p class="page-head__desc">
          全部图表数据由 Spring Boot 统计接口从 orders / order_item / dish / sys_user 聚合而来，
          取消订单不计入销售额；课堂演示数据为初始化模拟数据。
        </p>
      </div>
      <div class="seg">
        <button class="seg__btn" :class="{ 'seg__btn--active': period === 'week' }" type="button" @click="switchPeriod('week')">近 7 天</button>
        <button class="seg__btn" :class="{ 'seg__btn--active': period === 'month' }" type="button" @click="switchPeriod('month')">近 30 天</button>
      </div>
    </header>

    <div v-if="error" class="alert-bar">
      <AppIcon name="alert-triangle" :size="15" />
      <span>{{ error }}</span>
      <button class="btn btn--ghost btn--sm" type="button" @click="load">重试</button>
    </div>

    <section class="kpi-row">
      <template v-if="loading && !overview">
        <div v-for="i in 6" :key="i" class="skeleton" style="height: 78px; border-radius: 14px"></div>
      </template>
      <template v-else>
        <article v-for="card in kpiCards" :key="card.label" class="kpi">
          <span class="kpi__icon"><AppIcon :name="card.icon" :size="16" /></span>
          <div>
            <span class="kpi__label">{{ card.label }}</span>
            <p class="kpi__value num">{{ card.value }}<small v-if="card.unit">{{ card.unit }}</small></p>
          </div>
        </article>
      </template>
    </section>

    <section class="chart-block">
      <article class="admin-card">
        <header class="admin-card__head">
          <div>
            <h3 class="admin-card__title">订单量与销售额趋势</h3>
            <p class="admin-card__sub">{{ period === 'week' ? '近 7 天' : '近 30 天' }} · 按日聚合</p>
          </div>
        </header>
        <EChart :option="trendOption" :loading="loading" :empty="!trendOption" height="300px" empty-text="该时间范围内没有订单数据" />
      </article>
    </section>

    <section class="chart-grid">
      <article class="admin-card">
        <header class="admin-card__head">
          <div>
            <h3 class="admin-card__title">菜品销量 TOP 10</h3>
            <p class="admin-card__sub">按销量排序</p>
          </div>
        </header>
        <EChart :option="rankingOption" :loading="loading" :empty="!rankingOption" height="300px" empty-text="暂无菜品销量数据" />
      </article>

      <article class="admin-card">
        <header class="admin-card__head">
          <div>
            <h3 class="admin-card__title">分类销售占比</h3>
            <p class="admin-card__sub">按销量与金额聚合</p>
          </div>
        </header>
        <EChart :option="categoryOption" :loading="loading" :empty="!categoryOption" height="300px" empty-text="暂无分类销售数据" />
      </article>
    </section>

    <section class="chart-grid">
      <article class="admin-card">
        <header class="admin-card__head">
          <div>
            <h3 class="admin-card__title">时段订单分布</h3>
            <p class="admin-card__sub">按订单创建小时聚合</p>
          </div>
        </header>
        <EChart :option="hourlyOption" :loading="loading" :empty="!hourlyOption" height="260px" empty-text="暂无时段分布数据" />
      </article>

      <article class="admin-card">
        <header class="admin-card__head">
          <div>
            <h3 class="admin-card__title">用户增长趋势</h3>
            <p class="admin-card__sub">近 7 天注册用户</p>
          </div>
        </header>
        <EChart :option="growthOption" :loading="loading" :empty="!growthOption" height="260px" empty-text="暂无用户增长数据" />
      </article>
    </section>

    <section v-if="ranking && ranking.items.length > 0" class="admin-card">
      <header class="admin-card__head">
        <div>
          <h3 class="admin-card__title">菜品销量明细</h3>
          <p class="admin-card__sub">与左侧 TOP 10 图表同源数据</p>
        </div>
      </header>
      <table class="data-table">
        <thead>
          <tr>
            <th style="width: 60px">排名</th>
            <th>菜品</th>
            <th style="width: 110px">分类</th>
            <th style="width: 90px">销量</th>
            <th style="width: 110px">销售额</th>
            <th style="width: 90px">占比</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in ranking.items" :key="item.dishId">
            <td class="num">{{ index + 1 }}</td>
            <td>{{ item.name }}</td>
            <td class="text-muted">{{ item.categoryName || '—' }}</td>
            <td class="num">{{ item.quantity }} 份</td>
            <td class="num">¥{{ formatMoney(item.amount) }}</td>
            <td class="num">{{ Number(item.share).toFixed(1) }}%</td>
          </tr>
        </tbody>
      </table>
    </section>

    <p v-if="overview?.note" class="data-note">
      <AppIcon name="info" :size="12" />{{ overview.note }}
    </p>
  </div>
</template>

<style scoped>
.stats-page {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.page-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.page-head__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.page-head__desc {
  font-size: 10.5px;
  color: var(--ink-400);
  margin-top: 2px;
  max-width: 760px;
  line-height: 1.55;
}

.seg {
  display: flex;
  gap: 3px;
  padding: 3px;
  border-radius: var(--radius-pill);
  background: rgba(232, 238, 221, 0.7);
  flex: none;
}

.seg__btn {
  height: 28px;
  padding: 0 14px;
  border-radius: var(--radius-pill);
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--ink-600);
}

.seg__btn--active {
  background: #fff;
  color: var(--sage-700);
  box-shadow: var(--shadow-xs);
}

.alert-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  border-radius: var(--radius-md);
  background: var(--danger-100);
  color: var(--danger-600);
  font-size: var(--font-sm);
}

.kpi-row {
  display: grid;
  grid-template-columns: repeat(6, minmax(0, 1fr));
  gap: var(--space-3);
}

.kpi {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 13px 14px;
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.kpi__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  flex: none;
  border-radius: var(--radius-sm);
  background: var(--sage-100);
  color: var(--sage-600);
}

.kpi__label {
  font-size: 10.5px;
  color: var(--ink-500);
  white-space: nowrap;
}

.kpi__value {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--ink-900);
  line-height: 1.3;
}

.kpi__value small {
  font-size: 10px;
  font-weight: 500;
  color: var(--ink-400);
  margin-left: 2px;
}

.chart-block {
  display: grid;
  grid-template-columns: 1fr;
}

.chart-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
}

.admin-card {
  padding: var(--space-5);
  border-radius: var(--radius-lg);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.admin-card__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  margin-bottom: var(--space-3);
}

.admin-card__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.admin-card__sub {
  font-size: 10.5px;
  color: var(--ink-400);
  margin-top: 1px;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: var(--font-xs);
}

.data-table th {
  text-align: left;
  padding: 8px;
  font-size: 10.5px;
  font-weight: 600;
  color: var(--ink-500);
  border-bottom: 1px solid rgba(124, 143, 90, 0.16);
}

.data-table td {
  padding: 9px 8px;
  border-bottom: 1px solid rgba(124, 143, 90, 0.07);
  color: var(--ink-700);
}

.data-table tbody tr:hover {
  background: var(--sage-50);
}

.data-note {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 10.5px;
  color: var(--ink-400);
}

@media (max-width: 1439px) {
  .kpi-row {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 1180px) {
  .chart-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 767px) {
  .kpi-row {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
