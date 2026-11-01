<script setup lang="ts">
/**
 * 后台工作台：核心指标 + 订单趋势 + 热销 TOP5 + 分类占比 + 最近订单 + 库存预警。
 * 所有数据来自统计接口，页面内不写死任何业务数字。
 */
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import AppIcon from '@/components/common/AppIcon.vue'
import EChart from '@/components/admin/EChart.vue'
import { adminApi } from '@/api/modules'
import type { InventoryItem, Order, StatisticsOverview, Trend } from '@/types/api'
import { formatDateTime, formatMoney, orderStatusTone } from '@/utils/format'

const router = useRouter()

const loading = ref(true)
const error = ref<string | null>(null)
const overview = ref<StatisticsOverview | null>(null)
const trend = ref<Trend | null>(null)
const ranking = ref<{ dishId: number; name: string; quantity: number; amount: number }[]>([])
const categorySales = ref<{ categoryName: string; quantity: number; amount: number; share: number }[]>([])
const recentOrders = ref<Order[]>([])
const inventory = ref<InventoryItem[]>([])
const trendPeriod = ref<'week' | 'month'>('week')

const metricCards = computed(() => {
  const data = overview.value
  if (!data) {
    return []
  }
  return [
    { key: 'orders', label: '今日订单数', value: data.todayOrders, suffix: '笔', icon: 'clipboard-list', tone: 'sage' },
    { key: 'sales', label: '今日销售额', value: `¥${formatMoney(data.todaySales)}`, suffix: '', icon: 'trend-up', tone: 'amber' },
    { key: 'dishes', label: '今日售出菜品', value: data.todayDishesSold, suffix: '份', icon: 'dish', tone: 'sage' },
    { key: 'published', label: '在架菜品', value: data.publishedDishCount, suffix: '道', icon: 'tag', tone: 'sage' },
    { key: 'lowStock', label: '库存预警', value: data.lowStockCount + data.soldOutCount, suffix: '道', icon: 'alert-triangle', tone: 'danger' },
    { key: 'pending', label: '待处理订单', value: data.pendingOrderCount, suffix: '笔', icon: 'clock', tone: 'amber' }
  ]
})

const trendOption = computed(() => {
  const data = trend.value
  if (!data || data.labels.length === 0) {
    return null
  }
  return {
    tooltip: { trigger: 'axis', axisPointer: { type: 'cross' } },
    legend: { data: ['订单量', '销售额'], bottom: 0, icon: 'roundRect', itemWidth: 10, itemHeight: 10, textStyle: { fontSize: 11 } },
    grid: { left: 12, right: 16, top: 24, bottom: 42, containLabel: true },
    xAxis: {
      type: 'category',
      data: data.labels,
      axisLine: { lineStyle: { color: 'rgba(124,143,90,0.3)' } },
      axisTick: { show: false },
      axisLabel: { fontSize: 10, color: '#8B8478' }
    },
    yAxis: [
      {
        type: 'value',
        name: '订单量',
        nameTextStyle: { fontSize: 10, color: '#A9A294' },
        splitLine: { lineStyle: { color: 'rgba(124,143,90,0.1)' } },
        axisLabel: { fontSize: 10, color: '#8B8478' }
      },
      {
        type: 'value',
        name: '销售额(元)',
        nameTextStyle: { fontSize: 10, color: '#A9A294' },
        splitLine: { show: false },
        axisLabel: { fontSize: 10, color: '#8B8478' }
      }
    ],
    series: [
      {
        name: '订单量',
        type: 'bar',
        data: data.orderCounts,
        barWidth: 16,
        itemStyle: { borderRadius: [6, 6, 0, 0], color: '#B6C4A0' }
      },
      {
        name: '销售额',
        type: 'line',
        yAxisIndex: 1,
        data: data.salesAmounts,
        smooth: true,
        symbol: 'circle',
        symbolSize: 6,
        lineStyle: { width: 2.4, color: '#D98F38' },
        itemStyle: { color: '#D98F38' },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(217,143,56,0.24)' },
              { offset: 1, color: 'rgba(217,143,56,0)' }
            ]
          }
        }
      }
    ]
  }
})

const rankingOption = computed(() => {
  const data = ranking.value
  if (data.length === 0) {
    return null
  }
  const sorted = [...data].reverse()
  return {
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: 8, right: 28, top: 12, bottom: 8, containLabel: true },
    xAxis: {
      type: 'value',
      splitLine: { lineStyle: { color: 'rgba(124,143,90,0.1)' } },
      axisLabel: { fontSize: 10, color: '#8B8478' }
    },
    yAxis: {
      type: 'category',
      data: sorted.map((item) => item.name),
      axisLine: { lineStyle: { color: 'rgba(124,143,90,0.3)' } },
      axisTick: { show: false },
      axisLabel: { fontSize: 11, color: '#514C44' }
    },
    series: [
      {
        type: 'bar',
        data: sorted.map((item) => item.quantity),
        barWidth: 13,
        itemStyle: {
          borderRadius: [0, 6, 6, 0],
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 1,
            y2: 0,
            colorStops: [
              { offset: 0, color: '#B6C4A0' },
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
  const data = categorySales.value
  if (data.length === 0) {
    return null
  }
  return {
    tooltip: { trigger: 'item', formatter: '{b}<br/>{c} 份（{d}%）' },
    legend: { bottom: 0, icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 11 } },
    series: [
      {
        type: 'pie',
        radius: ['44%', '66%'],
        center: ['50%', '44%'],
        avoidLabelOverlap: true,
        itemStyle: { borderColor: '#FFFDF8', borderWidth: 2, borderRadius: 4 },
        label: { show: false },
        emphasis: { label: { show: true, fontSize: 12, fontWeight: 700, formatter: '{b}\n{d}%' } },
        data: data.map((item) => ({ name: item.categoryName, value: item.quantity }))
      }
    ]
  }
})

async function loadTrend() {
  try {
    trend.value = (await adminApi.statisticsTrend(trendPeriod.value)) as unknown as Trend
  } catch {
    trend.value = null
  }
}

async function load() {
  loading.value = true
  error.value = null
  try {
    const [ov, rank, cat, orders, inv] = await Promise.allSettled([
      adminApi.statisticsOverview(),
      adminApi.statisticsRanking(5),
      adminApi.statisticsCategorySales(),
      adminApi.orders({ page: 1, pageSize: 6 }),
      adminApi.inventory({ lowStockOnly: true })
    ])
    if (ov.status === 'fulfilled') {
      overview.value = ov.value as unknown as StatisticsOverview
    }
    if (rank.status === 'fulfilled') {
      ranking.value = ((rank.value as { items?: typeof ranking.value }).items ?? [])
    }
    if (cat.status === 'fulfilled') {
      categorySales.value = ((cat.value as { items?: typeof categorySales.value }).items ?? [])
    }
    if (orders.status === 'fulfilled') {
      recentOrders.value = (orders.value as { records: Order[] }).records
    }
    if (inv.status === 'fulfilled') {
      inventory.value = inv.value as unknown as InventoryItem[]
    }
    await loadTrend()
    if (ov.status === 'rejected') {
      error.value = '统计数据加载失败，请稍后重试'
    }
  } finally {
    loading.value = false
  }
}

function switchPeriod(period: 'week' | 'month') {
  trendPeriod.value = period
  loadTrend()
}

onMounted(load)
</script>

<template>
  <div class="dash">
    <div v-if="error" class="alert-bar">
      <AppIcon name="alert-triangle" :size="15" />
      <span>{{ error }}</span>
      <button class="btn btn--ghost btn--sm" type="button" @click="load">重试</button>
    </div>

    <!-- 指标卡 -->
    <section class="metric-row">
      <template v-if="loading && !overview">
        <div v-for="i in 6" :key="i" class="skeleton" style="height: 92px; border-radius: 16px"></div>
      </template>
      <template v-else>
        <article v-for="card in metricCards" :key="card.key" class="metric" :class="`metric--${card.tone}`">
          <span class="metric__icon"><AppIcon :name="card.icon" :size="17" /></span>
          <div class="metric__body">
            <span class="metric__label">{{ card.label }}</span>
            <p class="metric__value num">
              {{ card.value }}<small v-if="card.suffix">{{ card.suffix }}</small>
            </p>
          </div>
        </article>
      </template>
    </section>

    <p v-if="overview?.note" class="data-note">
      <AppIcon name="info" :size="12" />{{ overview.note }}
    </p>

    <!-- 图表区 -->
    <section class="chart-row">
      <article class="admin-card chart-card">
        <header class="admin-card__head">
          <div>
            <h2 class="admin-card__title">订单量与销售额趋势</h2>
            <p class="admin-card__sub">取消订单不计入统计</p>
          </div>
          <div class="seg">
            <button class="seg__btn" :class="{ 'seg__btn--active': trendPeriod === 'week' }" type="button" @click="switchPeriod('week')">近 7 天</button>
            <button class="seg__btn" :class="{ 'seg__btn--active': trendPeriod === 'month' }" type="button" @click="switchPeriod('month')">近 30 天</button>
          </div>
        </header>
        <EChart :option="trendOption" :loading="loading" :empty="!trendOption" height="272px" empty-text="暂无订单数据，初始化演示订单后可查看趋势" />
      </article>

      <article class="admin-card chart-card chart-card--narrow">
        <header class="admin-card__head">
          <div>
            <h2 class="admin-card__title">分类销售占比</h2>
            <p class="admin-card__sub">按订单明细聚合</p>
          </div>
        </header>
        <EChart :option="categoryOption" :loading="loading" :empty="!categoryOption" height="272px" empty-text="暂无分类销售数据" />
      </article>
    </section>

    <section class="chart-row">
      <article class="admin-card chart-card chart-card--narrow">
        <header class="admin-card__head">
          <div>
            <h2 class="admin-card__title">热销菜品 TOP 5</h2>
            <p class="admin-card__sub">按销量排序</p>
          </div>
        </header>
        <EChart :option="rankingOption" :loading="loading" :empty="!rankingOption" height="248px" empty-text="暂无销量数据" />
      </article>

      <article class="admin-card">
        <header class="admin-card__head">
          <div>
            <h2 class="admin-card__title">最近订单</h2>
            <p class="admin-card__sub">最新 6 笔订单</p>
          </div>
          <button class="link-btn" type="button" @click="router.push('/admin/orders')">
            全部订单<AppIcon name="chevron-right" :size="13" />
          </button>
        </header>

        <div v-if="loading" class="skeleton" style="height: 200px; border-radius: 12px"></div>
        <div v-else-if="recentOrders.length === 0" class="empty-mini">暂无订单</div>
        <table v-else class="mini-table">
          <thead>
            <tr>
              <th>订单号</th>
              <th>用户</th>
              <th>金额</th>
              <th>状态</th>
              <th>时间</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="order in recentOrders" :key="order.id">
              <td class="num">{{ order.orderNo }}</td>
              <td>{{ order.userNickname || '—' }}</td>
              <td class="num">¥{{ formatMoney(order.totalAmount) }}</td>
              <td>
                <span class="status-dot" :class="`status-dot--${orderStatusTone(order.orderStatus)}`">
                  {{ order.orderStatusLabel }}
                </span>
              </td>
              <td class="text-muted">{{ formatDateTime(order.createdAt) }}</td>
            </tr>
          </tbody>
        </table>
      </article>
    </section>

    <!-- 库存预警 -->
    <article class="admin-card">
      <header class="admin-card__head">
        <div>
          <h2 class="admin-card__title">库存预警</h2>
          <p class="admin-card__sub">库存 ≤ 10 份或已售罄的菜品</p>
        </div>
        <button class="link-btn" type="button" @click="router.push('/admin/inventory')">
          库存管理<AppIcon name="chevron-right" :size="13" />
        </button>
      </header>

      <div v-if="loading" class="skeleton" style="height: 90px; border-radius: 12px"></div>
      <div v-else-if="inventory.length === 0" class="empty-mini">
        <AppIcon name="check-circle" :size="16" /> 所有菜品库存充足
      </div>
      <div v-else class="warn-list">
        <div v-for="item in inventory.slice(0, 8)" :key="item.dishId" class="warn-item">
          <img :src="item.imageUrl || '/assets/images/dishes/dish-placeholder.webp'" :alt="item.name" />
          <div class="warn-item__info">
            <span class="warn-item__name">{{ item.name }}</span>
            <span class="warn-item__meta">{{ item.categoryName }} · {{ item.dishCode }}</span>
          </div>
          <span class="warn-item__stock num" :class="{ 'warn-item__stock--zero': item.stock <= 0 }">
            剩余 {{ item.stock }} 份
          </span>
        </div>
      </div>
    </article>
  </div>
</template>

<style scoped>
.dash {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
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

.metric-row {
  display: grid;
  grid-template-columns: repeat(6, minmax(0, 1fr));
  gap: var(--space-3);
}

.metric {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 16px;
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
  box-shadow: var(--shadow-xs);
  transition: transform var(--motion-normal) var(--ease-standard),
    box-shadow var(--motion-normal) var(--ease-standard);
}

.metric:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-sm);
}

.metric__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  flex: none;
  border-radius: var(--radius-sm);
  background: var(--sage-100);
  color: var(--sage-600);
}

.metric--amber .metric__icon {
  background: var(--amber-100);
  color: var(--amber-600);
}

.metric--danger .metric__icon {
  background: var(--danger-100);
  color: var(--danger-600);
}

.metric__body {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.metric__label {
  font-size: 10.5px;
  color: var(--ink-500);
  white-space: nowrap;
}

.metric__value {
  font-size: var(--font-xl);
  font-weight: 700;
  color: var(--ink-900);
  line-height: 1.25;
}

.metric__value small {
  font-size: 10.5px;
  font-weight: 500;
  color: var(--ink-400);
  margin-left: 2px;
}

.data-note {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 10.5px;
  color: var(--ink-400);
}

.chart-row {
  display: grid;
  grid-template-columns: minmax(0, 1.6fr) minmax(0, 1fr);
  gap: var(--space-4);
}

.admin-card {
  padding: var(--space-5);
  border-radius: var(--radius-lg);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
  box-shadow: var(--shadow-xs);
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

.seg {
  display: flex;
  gap: 2px;
  padding: 2px;
  border-radius: var(--radius-pill);
  background: var(--sage-50);
}

.seg__btn {
  height: 26px;
  padding: 0 10px;
  border-radius: var(--radius-pill);
  font-size: 10.5px;
  font-weight: 600;
  color: var(--ink-500);
}

.seg__btn--active {
  background: #fff;
  color: var(--sage-700);
  box-shadow: var(--shadow-xs);
}

.link-btn {
  display: inline-flex;
  align-items: center;
  gap: 2px;
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--sage-600);
  flex: none;
}

.link-btn:hover {
  text-decoration: underline;
}

.mini-table {
  width: 100%;
  border-collapse: collapse;
  font-size: var(--font-xs);
}

.mini-table th {
  text-align: left;
  padding: 7px 8px;
  font-weight: 600;
  color: var(--ink-500);
  border-bottom: 1px solid rgba(124, 143, 90, 0.14);
  font-size: 10.5px;
}

.mini-table td {
  padding: 9px 8px;
  color: var(--ink-700);
  border-bottom: 1px solid rgba(124, 143, 90, 0.07);
}

.mini-table tbody tr:hover {
  background: var(--sage-50);
}

.status-dot {
  display: inline-flex;
  align-items: center;
  padding: 2px 8px;
  border-radius: var(--radius-pill);
  font-size: 10px;
  font-weight: 600;
}

.status-dot--sage {
  background: var(--success-100);
  color: var(--success-600);
}

.status-dot--amber {
  background: var(--amber-100);
  color: var(--amber-600);
}

.status-dot--danger {
  background: var(--danger-100);
  color: var(--danger-600);
}

.status-dot--muted {
  background: rgba(139, 132, 120, 0.14);
  color: var(--ink-500);
}

.warn-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 10px;
}

.warn-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 11px;
  border-radius: var(--radius-sm);
  background: rgba(253, 240, 221, 0.6);
  border: 1px solid rgba(217, 143, 56, 0.2);
}

.warn-item img {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-xs);
  object-fit: cover;
  flex: none;
}

.warn-item__info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.warn-item__name {
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--ink-800);
}

.warn-item__meta {
  font-size: 10px;
  color: var(--ink-400);
}

.warn-item__stock {
  font-size: 10.5px;
  font-weight: 700;
  color: var(--amber-600);
  flex: none;
}

.warn-item__stock--zero {
  color: var(--danger-600);
}

.empty-mini {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: var(--space-6);
  color: var(--ink-400);
  font-size: var(--font-xs);
}

@media (max-width: 1439px) {
  .metric-row {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 1180px) {
  .chart-row {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 767px) {
  .metric-row {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
