<script setup lang="ts">
/**
 * 营养管理面板：基于订单快照聚合的估算数据，明确标注"估算值/演示数据"。
 * 使用轻量内联图表（不额外引入图表库，后台才用 ECharts）。
 */
import { computed, onMounted, ref, watch } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import NutritionAdvice from '@/components/order/NutritionAdvice.vue'
import ProgressRing from '@/components/common/ProgressRing.vue'
import { nutritionApi } from '@/api/modules'
import type { NutritionSummary, NutritionTrendPoint } from '@/types/api'

const loading = ref(true)
const error = ref<string | null>(null)
const summary = ref<NutritionSummary | null>(null)
const range = ref<7 | 14 | 30>(7)

const metrics = computed(() => {
  const data = summary.value
  if (!data) {
    return []
  }
  return [
    { key: 'calories', label: '日均热量', icon: 'flame', value: data.dailyCalories, unit: 'kcal', target: data.targetCalories, rate: data.calorieRate, color: 'var(--sage-500)' },
    { key: 'protein', label: '日均蛋白质', icon: 'dumbbell', value: data.dailyProtein, unit: 'g', target: data.targetProtein, rate: data.proteinRate, color: 'var(--amber-500)' },
    { key: 'fat', label: '日均脂肪', icon: 'water', value: Number(data.totalFat) / range.value, unit: 'g', target: 60, rate: Math.min(Number(((Number(data.totalFat) / range.value / 60) * 100).toFixed(1)), 999), color: 'var(--apricot-200)' },
    { key: 'carbs', label: '日均碳水', icon: 'rice-bowl', value: Number(data.totalCarbohydrate) / range.value, unit: 'g', target: 260, rate: Math.min(Number(((Number(data.totalCarbohydrate) / range.value / 260) * 100).toFixed(1)), 999), color: 'var(--sage-300)' },
    { key: 'fiber', label: '日均纤维', icon: 'leaf', value: Number(data.totalFiber) / range.value, unit: 'g', target: 25, rate: Math.min(Number(((Number(data.totalFiber) / range.value / 25) * 100).toFixed(1)), 999), color: 'var(--success-500)' },
    { key: 'water', label: '饮水量', icon: 'water', value: data.waterMl, unit: 'ml', target: data.targetWater, rate: data.waterRate, color: 'var(--info-500)' }
  ]
})

const trend = computed(() => summary.value?.trend ?? [])

/** 三大营养素提供的热量占比（蛋白 4kcal/g、碳水 4kcal/g、脂肪 9kcal/g） */
const macroShare = computed(() => {
  const s = summary.value
  if (!s) {
    return []
  }
  const p = Number(s.totalProtein ?? 0) * 4
  const c = Number(s.totalCarbohydrate ?? 0) * 4
  const f = Number(s.totalFat ?? 0) * 9
  const sum = p + c + f
  if (sum <= 0) {
    return []
  }
  return [
    { key: 'protein', label: '蛋白质', kilo: Math.round(p), pct: Math.round((p / sum) * 100), color: 'var(--sage-500)' },
    { key: 'carb', label: '碳水', kilo: Math.round(c), pct: Math.round((c / sum) * 100), color: 'var(--amber-500)' },
    { key: 'fat', label: '脂肪', kilo: Math.round(f), pct: Math.round((f / sum) * 100), color: 'var(--apricot-300, #f0b45c)' }
  ]
})

/** 环形图 conic-gradient 色段 */
const macroGradient = computed(() => {
  const m = macroShare.value
  if (m.length === 0) {
    return 'conic-gradient(rgba(124,143,90,0.15) 0% 100%)'
  }
  let acc = 0
  const parts = m.map((x) => {
    const from = acc
    acc += x.pct
    return x.color + ' ' + from + '% ' + acc + '%'
  })
  return 'conic-gradient(' + parts.join(', ') + ')'
})

/** 趋势图每天的热量上限（用于计算堆叠柱高） */
const trendMax = computed(() => Math.max(...trend.value.map((p) => Number(p.calories)), 1))

/** 每天某类营养素折算成热量的柱高（百分比），用于三色堆叠 */
function stackHeight(point: NutritionTrendPoint, kind: 'protein' | 'carb' | 'fat') {
  const total = trendMax.value || 1
  const factor = kind === 'protein' ? 4 : kind === 'carb' ? 4 : 9
  const raw = kind === 'protein'
    ? Number(point.protein)
    : kind === 'carb'
      ? Number(point.carbohydrate)
      : Number(point.fat)
  const val = (raw || 0) * factor
  return Math.max((val / total) * 100, 0).toFixed(1) + '%'
}

/** 每条趋势柱子的总热量 */
function totalOf(point: NutritionTrendPoint) {
  return Math.round(Number(point.calories) || 0)
}
const maxCalories = computed(() => Math.max(...trend.value.map((p) => Number(p.calories)), 1))

function barHeight(value: number) {
  return `${Math.max((Number(value) / maxCalories.value) * 100, 3)}%`
}

async function load() {
  loading.value = true
  error.value = null
  try {
    summary.value = await nutritionApi.summary(range.value)
  } catch (e) {
    error.value = e instanceof Error ? e.message : '营养数据加载失败'
  } finally {
    loading.value = false
  }
}

watch(range, load)
onMounted(load)

defineExpose({ reload: load })
const emit = defineEmits<{ (e: 'order-dish', dishId: number): void }>()
</script>

<template>
  <section class="panel-card glass-card scroll-y">
    <header class="panel-head">
      <div>
        <h2 class="section-title">
          <span class="section-title__icon"><AppIcon name="bar-chart" :size="15" /></span>
          营养管理
        </h2>
        <p class="section-subtitle">基于已结算订单与菜品营养数据聚合 · 估算值，非医学检测</p>
      </div>
      <div class="seg-control">
        <button
          v-for="days in [7, 14, 30]"
          :key="days"
          class="seg-control__btn"
          :class="{ 'seg-control__btn--active': range === days }"
          type="button"
          @click="range = days as 7 | 14 | 30"
        >
          近 {{ days }} 天
        </button>
      </div>
    </header>

    <div v-if="loading" class="nut-skeleton">
      <div v-for="i in 4" :key="i" class="skeleton" style="height: 84px; border-radius: 16px"></div>
    </div>

    <div v-else-if="error" class="panel-empty">
      <AppIcon name="alert-triangle" :size="24" />
      <p>{{ error }}</p>
      <button class="btn btn--ghost btn--sm" type="button" @click="load">重试</button>
    </div>

    <template v-else-if="summary">
      <div class="nut-overview">
        <ProgressRing :percent="Math.min(Number(summary.calorieRate), 100)" :size="112" label="日均热量达成率" />
        <div class="nut-overview__text">
          <p class="nut-overview__title">{{ summary.period }} · {{ summary.orderCount }} 笔订单</p>
          <p class="nut-overview__desc">
            共 {{ summary.dishCount }} 份菜品，累计约
            <strong class="num">{{ Math.round(summary.totalCalories) }}</strong> kcal（日均
            <strong class="num">{{ Math.round(Number(summary.dailyCalories ?? 0)) }}</strong> kcal）
          </p>
          <div class="nut-overview__chips">
            <span class="tag">蛋白质 {{ Math.round(summary.totalProtein) }} g</span>
            <span class="tag tag--amber">碳水 {{ Math.round(summary.totalCarbohydrate) }} g</span>
            <span class="tag tag--muted">脂肪 {{ Math.round(summary.totalFat) }} g</span>
          </div>
        </div>
      </div>

      <div class="metric-grid">
        <div v-for="metric in metrics" :key="metric.key" class="metric-card">
          <div class="metric-card__head">
            <span class="metric-card__icon"><AppIcon :name="metric.icon" :size="14" /></span>
            <span class="metric-card__label">{{ metric.label }}</span>
          </div>

          <p class="metric-card__value num">
            {{ Math.round(Number(metric.value)) }}<small>{{ metric.unit }}</small>
          </p>
          <div class="metric-card__bar">
            <span
              class="metric-card__fill"
              :style="{ width: `${Math.min(Number(metric.rate), 100)}%`, background: metric.color }"
            ></span>
          </div>
          <p class="metric-card__target">参考目标 {{ metric.target }}{{ metric.unit }}</p>
        </div>
      </div>

      <!-- AI 营养助手：分析缺口并推荐菜品 -->
      <NutritionAdvice :days="range" @order-dish="(id) => emit('order-dish', id)" />

      <!-- 三大营养素构成（参考项目饼图思路，用 conic-gradient 实现，无需图表库） -->
      <section v-if="macroShare.length > 0" class="macro-card">
        <header class="macro-card__head">
          <h3 class="macro-card__title">
            <AppIcon name="bar-chart" :size="14" />三大营养素构成
          </h3>
          <span class="macro-card__hint">按供能折算（估算值）</span>
        </header>
        <div class="macro-card__body">
          <div class="macro-donut" :style="{ background: macroGradient }">
            <div class="macro-donut__hole">
              <span class="macro-donut__value num">{{ Math.round(summary.totalCalories) }}</span>
              <span class="macro-donut__unit">kcal</span>
            </div>
          </div>
          <ul class="macro-legend">
            <li v-for="m in macroShare" :key="m.key" class="macro-legend__item">
              <span class="macro-legend__dot" :style="{ background: m.color }"></span>
              <span class="macro-legend__label">{{ m.label }}</span>
              <span class="macro-legend__pct num">{{ m.pct }}%</span>
              <span class="macro-legend__kilo num">{{ m.kilo }} kcal</span>
            </li>
          </ul>
        </div>
      </section>

      <section class="trend-card">
        <header class="trend-card__head">
          <h3 class="trend-card__title">热量摄入趋势</h3>
          <span class="trend-card__hint">按日聚合（估算值）</span>
        </header>
        <div v-if="trend.length === 0" class="trend-empty">暂无数据</div>
        <template v-else>
          <div class="trend-chart">
            <div v-for="point in trend" :key="point.date" class="trend-bar">
              <span v-if="totalOf(point) > 0" class="trend-bar__value num">{{ totalOf(point) }}</span>
              <div class="trend-bar__track">
                <!-- 三色堆叠：蛋白 / 碳水 / 脂肪 折算热量 -->
                <span
                  class="trend-bar__seg trend-bar__seg--fat"
                  :style="{ height: stackHeight(point, 'fat') }"
                ></span>
                <span
                  class="trend-bar__seg trend-bar__seg--carb"
                  :style="{ height: stackHeight(point, 'carb') }"
                ></span>
                <span
                  class="trend-bar__seg trend-bar__seg--protein"
                  :style="{ height: stackHeight(point, 'protein') }"
                ></span>
              </div>
              <span class="trend-bar__label">{{ point.date }}</span>
            </div>
          </div>
          <div class="trend-legend">
            <span class="trend-legend__item"><i class="dot dot--protein"></i>蛋白质</span>
            <span class="trend-legend__item"><i class="dot dot--carb"></i>碳水</span>
            <span class="trend-legend__item"><i class="dot dot--fat"></i>脂肪</span>
          </div>
        </template>
      </section>

      <section class="advice-card">
        <h3 class="advice-card__title">
          <AppIcon name="leaf" :size="14" />饮食建议
        </h3>
        <ul class="advice-list">
          <li v-for="suggestion in summary.suggestions" :key="suggestion">
            <span class="advice-list__dot"></span>{{ suggestion }}
          </li>
        </ul>
        <p class="advice-note">{{ summary.note }}</p>
      </section>
    </template>
  </section>
</template>

<style scoped>
.panel-card {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  height: 100%;
  padding: var(--space-5);
}

.panel-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  flex-wrap: wrap;
}

.seg-control {
  display: flex;
  gap: 3px;
  padding: 3px;
  border-radius: var(--radius-pill);
  background: rgba(232, 238, 221, 0.7);
}

.seg-control__btn {
  height: 28px;
  padding: 0 11px;
  border-radius: var(--radius-pill);
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--ink-600);
  transition: background-color var(--motion-fast) var(--ease-standard),
    color var(--motion-fast) var(--ease-standard);
}

.seg-control__btn--active {
  background: #fff;
  color: var(--sage-700);
  box-shadow: var(--shadow-xs);
}

.nut-skeleton {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
}

.nut-overview {
  display: flex;
  align-items: center;
  gap: var(--space-4);
  padding: var(--space-4);
  border-radius: var(--radius-lg);
  background: rgba(232, 238, 221, 0.5);
}

.nut-overview__text {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.nut-overview__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-800);
}

.nut-overview__desc {
  font-size: var(--font-sm);
  color: var(--ink-600);
}

.nut-overview__desc strong {
  color: var(--amber-600);
}

.nut-overview__chips {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  margin-top: 2px;
}

.metric-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
}

.metric-card {
  display: flex;
  flex-direction: column;
  gap: 5px;
  padding: 11px 12px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.76);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.metric-card__head {
  display: flex;
  align-items: center;
  gap: 5px;
}

.metric-card__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  border-radius: 7px;
  background: var(--sage-100);
  color: var(--sage-600);
}

.metric-card__label {
  font-size: var(--font-xs);
  color: var(--ink-600);
}

.metric-card__value {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--ink-900);
}

.metric-card__value small {
  font-size: 10.5px;
  font-weight: 500;
  color: var(--ink-400);
  margin-left: 2px;
}

.metric-card__bar {
  height: 5px;
  border-radius: var(--radius-pill);
  background: rgba(124, 143, 90, 0.14);
  overflow: hidden;
}

.metric-card__fill {
  display: block;
  height: 100%;
  border-radius: var(--radius-pill);
  transition: width var(--motion-linger) var(--ease-enter);
}

.metric-card__target {
  font-size: 10px;
  color: var(--ink-400);
}

.trend-card {
  padding: var(--space-4);
  border-radius: var(--radius-lg);
  background: rgba(255, 255, 255, 0.7);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.trend-card__head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 10px;
}

.trend-card__title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-800);
}

.trend-card__hint {
  font-size: 10.5px;
  color: var(--ink-400);
}

.trend-chart {
  display: flex;
  align-items: flex-end;
  gap: 4px;
  height: 96px;
}

.trend-bar {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  height: 100%;
}

.trend-bar__track {
  flex: 1;
  width: 100%;
  display: flex;
  align-items: flex-end;
  border-radius: var(--radius-xs);
  background: rgba(232, 238, 221, 0.5);
  overflow: hidden;
}

.trend-bar__fill {
  width: 100%;
  border-radius: var(--radius-xs);
  background: linear-gradient(180deg, var(--sage-400), var(--sage-600));
  transition: height var(--motion-linger) var(--ease-enter);
}

.trend-bar__label {
  font-size: 9px;
  color: var(--ink-400);
  white-space: nowrap;
}

.trend-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 96px;
  color: var(--ink-400);
  font-size: var(--font-xs);
}

.advice-card {
  padding: var(--space-4);
  border-radius: var(--radius-lg);
  background: linear-gradient(135deg, rgba(243, 247, 236, 0.9), rgba(253, 248, 239, 0.85));
  border: 1px solid rgba(124, 143, 90, 0.14);
}

.advice-card__title {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--sage-700);
  margin-bottom: 7px;
}

.advice-list {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.advice-list li {
  display: flex;
  align-items: flex-start;
  gap: 7px;
  font-size: var(--font-xs);
  color: var(--ink-600);
  line-height: 1.6;
}

.advice-list__dot {
  width: 5px;
  height: 5px;
  margin-top: 6px;
  border-radius: 50%;
  background: var(--sage-400);
  flex: none;
}

.advice-note {
  margin-top: 8px;
  font-size: 10px;
  color: var(--ink-400);
  line-height: 1.5;
}

.panel-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: var(--space-10);
  color: var(--ink-500);
}

@media (max-width: 1180px) {
  .metric-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 767px) {
  .nut-overview {
    flex-direction: column;
    align-items: flex-start;
  }

  .metric-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

/* ---------- 三大营养素环形图 ---------- */
.macro-card {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  padding: var(--space-4);
  border-radius: var(--radius-lg);
  background: rgba(255, 255, 255, 0.72);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.macro-card__head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: var(--space-2);
}

.macro-card__title {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-800);
}

.macro-card__hint {
  font-size: 10px;
  color: var(--ink-400);
}

.macro-card__body {
  display: flex;
  align-items: center;
  gap: var(--space-5);
  flex-wrap: wrap;
}

.macro-donut {
  position: relative;
  width: 118px;
  height: 118px;
  flex: none;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.macro-donut__hole {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 72%;
  height: 72%;
  border-radius: 50%;
  background: var(--cream-50, #fffdf8);
  box-shadow: inset 0 0 0 1px rgba(124, 143, 90, 0.1);
}

.macro-donut__value {
  font-size: var(--font-lg);
  font-weight: 700;
  line-height: 1;
  color: var(--ink-900);
}

.macro-donut__unit {
  font-size: 9.5px;
  color: var(--ink-400);
  margin-top: 2px;
}

.macro-legend {
  flex: 1;
  min-width: 150px;
  display: flex;
  flex-direction: column;
  gap: 7px;
}

.macro-legend__item {
  display: grid;
  grid-template-columns: 10px 52px 1fr auto;
  align-items: center;
  gap: 7px;
  font-size: var(--font-xs);
  color: var(--ink-600);
}

.macro-legend__dot {
  width: 8px;
  height: 8px;
  border-radius: 3px;
}

.macro-legend__label {
  font-weight: 600;
  color: var(--ink-700);
}

.macro-legend__pct {
  font-weight: 700;
  color: var(--ink-900);
}

.macro-legend__kilo {
  font-size: 10px;
  color: var(--ink-400);
}

/* ---------- 趋势图三色堆叠 ---------- */
.trend-bar__track {
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
}

.trend-bar__seg {
  display: block;
  width: 100%;
}

.trend-bar__seg--protein {
  background: var(--sage-500);
  border-radius: 0 0 3px 3px;
}

.trend-bar__seg--carb {
  background: var(--amber-500);
}

.trend-bar__seg--fat {
  background: var(--apricot-300, #f0b45c);
  border-radius: 3px 3px 0 0;
}

.trend-bar__value {
  font-size: 9px;
  color: var(--ink-400);
  margin-bottom: 2px;
}

.trend-legend {
  display: flex;
  justify-content: center;
  gap: var(--space-4);
  margin-top: var(--space-2);
  font-size: 10px;
  color: var(--ink-500);
}

.trend-legend__item {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.trend-legend .dot {
  width: 7px;
  height: 7px;
  border-radius: 2px;
}

.trend-legend .dot--protein {
  background: var(--sage-500);
}

.trend-legend .dot--carb {
  background: var(--amber-500);
}

.trend-legend .dot--fat {
  background: var(--apricot-300, #f0b45c);
}
</style>
