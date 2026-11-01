<script setup lang="ts">
/**
 * 用餐中状态面板：画面左侧 40%–48% 区域，右侧男主与餐食完整可见。
 * 用餐状态下不允许再次点餐，也不允许修改本餐订单。
 */
import { computed } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { DISH_PLACEHOLDER } from '@/config/media'
import type { NutritionSummary, Order } from '@/types/api'
import { formatDateTime, formatMoney } from '@/utils/format'

const props = defineProps<{
  order: Order | null
  nutrition: NutritionSummary | null
  /** 用餐冷却剩余分钟（仅前端演示标记） */
  cooldownMinutes?: number
}>()

const emit = defineEmits<{
  (e: 'view-order'): void
  (e: 'view-nutrition'): void
}>()

const items = computed(() => props.order?.items ?? [])
const totalCalories = computed(() => {
  if (props.order?.totalCalories) {
    return Math.round(Number(props.order.totalCalories))
  }
  return items.value.reduce((sum, item) => sum + Number(item.calories ?? 0), 0)
})
const totalProtein = computed(() => items.value.reduce((sum, item) => sum + Number(item.protein ?? 0), 0))
const vegetableCount = computed(
  () => items.value.filter((item) => /时蔬|西兰花|青菜|蔬菜/.test(item.dishName)).length
)
</script>

<template>
  <div class="eating-wrap scroll-y">
    <section class="eating-card glass-card">
      <header class="eating-head">
        <span class="eating-badge">
          <span class="eating-badge__dot"></span>
          正在用餐
        </span>
        <h2 class="eating-title">好好享受这一餐</h2>
        <p class="eating-subtitle">记得珍惜粮食，按需取餐。</p>
      </header>

      <div v-if="order" class="eating-order">
        <div class="eating-order__row">
          <span class="eating-order__label">订单号</span>
          <span class="eating-order__value num">{{ order.orderNo }}</span>
        </div>
        <div class="eating-order__row">
          <span class="eating-order__label">下单时间</span>
          <span class="eating-order__value">{{ formatDateTime(order.createdAt) }}</span>
        </div>
        <div class="eating-order__row">
          <span class="eating-order__label">订单金额</span>
          <span class="eating-order__value num eating-order__value--amount">¥{{ formatMoney(order.totalAmount) }}</span>
        </div>

        <ul class="eating-items">
          <li v-for="item in items" :key="item.id" class="eating-item">
            <img :src="item.imageUrl || DISH_PLACEHOLDER" :alt="item.dishName" />
            <div class="eating-item__info">
              <span class="eating-item__name">{{ item.dishName }}</span>
              <span class="eating-item__meta num">× {{ item.quantity }} · {{ Math.round(Number(item.calories ?? 0)) }} kcal</span>
            </div>
            <span class="eating-item__subtotal num">¥{{ formatMoney(item.subtotal) }}</span>
          </li>
        </ul>
      </div>

      <div v-else class="eating-order eating-order--empty">
        <p>订单信息同步中…</p>
      </div>

      <section class="eating-nutrition">
        <h3 class="eating-nutrition__title">
          <AppIcon name="flame" :size="14" />本餐营养概览
          <span class="eating-nutrition__estimate">估算值</span>
        </h3>
        <div class="eating-nutrition__grid">
          <div class="eating-nutrition__cell">
            <span class="eating-nutrition__num num">{{ totalCalories }}</span>
            <span class="eating-nutrition__unit">kcal 热量</span>
          </div>
          <div class="eating-nutrition__cell">
            <span class="eating-nutrition__num num">{{ Math.round(totalProtein) }}</span>
            <span class="eating-nutrition__unit">g 蛋白质</span>
          </div>
          <div class="eating-nutrition__cell">
            <span class="eating-nutrition__num num">{{ vegetableCount }}</span>
            <span class="eating-nutrition__unit">份 蔬菜</span>
          </div>
        </div>
        <p class="eating-nutrition__note">数值来自菜品估算数据，仅作课堂演示参考。</p>
      </section>

      <section class="eating-tip">
        <AppIcon name="leaf" :size="15" class="eating-tip__icon" />
        <div>
          <p class="eating-tip__title">按需取餐，珍惜粮食</p>
          <p class="eating-tip__text">光盘行动，从每一餐做起。用餐结束后桌面会保持当前画面。</p>
        </div>
      </section>

      <section v-if="(props.cooldownMinutes ?? 0) > 0" class="eating-cooldown">
        <AppIcon name="clock" :size="14" class="eating-cooldown__icon" />
        <div>
          <p class="eating-cooldown__title">正在用餐，暂不可再次点餐</p>
          <p class="eating-cooldown__text">
            冷却 <strong class="num">{{ props.cooldownMinutes }}</strong> 分钟后可再次点餐，请勿浪费食物。
            <span class="eating-cooldown__demo">（前端演示标记）</span>
          </p>
        </div>
      </section>

      <footer class="eating-foot">
        <button class="btn btn--ghost btn--sm" type="button" @click="emit('view-order')">
          <AppIcon name="calendar" :size="14" />查看订单详情
        </button>
        <button class="btn btn--ghost btn--sm" type="button" @click="emit('view-nutrition')">
          <AppIcon name="bar-chart" :size="14" />营养分析
        </button>
      </footer>
    </section>

    <p class="eating-hint">
      <AppIcon name="info" :size="12" />
      用餐期间如需加菜，请联系食堂工作人员（本演示版本不支持再次下单）
    </p>
  </div>
</template>

<style scoped>
.eating-wrap {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  height: 100%;
  padding-right: 4px;
}

.eating-card {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  padding: var(--space-5);
}

.eating-head {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.eating-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  align-self: flex-start;
  height: 26px;
  padding: 0 12px;
  border-radius: var(--radius-pill);
  background: rgba(232, 238, 221, 0.9);
  color: var(--sage-700);
  font-size: var(--font-xs);
  font-weight: 700;
}

.eating-badge__dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--success-500);
  animation: pulse-ring 2.4s var(--ease-standard) infinite;
}

.eating-title {
  font-size: var(--font-2xl);
  font-weight: 700;
  color: var(--ink-900);
  letter-spacing: 0.01em;
}

.eating-subtitle {
  font-size: var(--font-sm);
  color: var(--ink-500);
}

.eating-order {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.72);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.eating-order--empty {
  align-items: center;
  justify-content: center;
  color: var(--ink-400);
  font-size: var(--font-sm);
}

.eating-order__row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: var(--font-sm);
}

.eating-order__label {
  color: var(--ink-500);
}

.eating-order__value {
  color: var(--ink-800);
  font-weight: 600;
}

.eating-order__value--amount {
  color: var(--amber-600);
  font-weight: 700;
}

.eating-items {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-top: 4px;
  padding-top: 8px;
  border-top: 1px dashed rgba(124, 143, 90, 0.22);
}

.eating-item {
  display: flex;
  align-items: center;
  gap: 9px;
}

.eating-item img {
  width: 38px;
  height: 38px;
  border-radius: var(--radius-xs);
  object-fit: cover;
  flex: none;
}

.eating-item__info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.eating-item__name {
  font-size: var(--font-sm);
  font-weight: 600;
  color: var(--ink-800);
}

.eating-item__meta {
  font-size: 10.5px;
  color: var(--ink-500);
}

.eating-item__subtotal {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-700);
}

.eating-nutrition {
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: rgba(232, 238, 221, 0.5);
}

.eating-nutrition__title {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--sage-700);
  margin-bottom: 9px;
}

.eating-nutrition__estimate {
  margin-left: auto;
  font-size: 10px;
  font-weight: 500;
  color: var(--ink-400);
}

.eating-nutrition__grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 8px;
}

.eating-nutrition__cell {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1px;
  padding: 8px 6px;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.72);
}

.eating-nutrition__num {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--sage-700);
}

.eating-nutrition__unit {
  font-size: 10px;
  color: var(--ink-500);
}

.eating-nutrition__note {
  margin-top: 7px;
  font-size: 10px;
  color: var(--ink-400);
}

.eating-tip {
  display: flex;
  align-items: flex-start;
  gap: 9px;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: linear-gradient(135deg, rgba(251, 232, 214, 0.7), rgba(243, 247, 236, 0.8));
  border: 1px solid rgba(196, 122, 42, 0.16);
}

.eating-tip__icon {
  color: var(--amber-500);
  margin-top: 2px;
  flex: none;
}

.eating-tip__title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--amber-600);
}

.eating-tip__text {
  font-size: var(--font-xs);
  color: var(--ink-600);
  line-height: 1.6;
  margin-top: 1px;
}

.eating-foot {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.eating-cooldown {
  display: flex;
  align-items: flex-start;
  gap: 9px;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: rgba(253, 240, 221, 0.72);
  border: 1px solid rgba(217, 143, 56, 0.22);
}

.eating-cooldown__icon {
  color: var(--amber-600);
  margin-top: 2px;
  flex: none;
}

.eating-cooldown__title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--amber-600);
}

.eating-cooldown__text {
  font-size: var(--font-xs);
  color: var(--ink-600);
  line-height: 1.6;
  margin-top: 2px;
}

.eating-cooldown__text strong {
  color: var(--amber-600);
}

.eating-cooldown__demo {
  color: var(--ink-400);
  font-size: 10px;
}

.eating-hint {
  display: flex;
  align-items: flex-start;
  gap: 5px;
  padding: 8px 12px;
  border-radius: var(--radius-sm);
  background: rgba(255, 253, 248, 0.72);
  color: var(--ink-500);
  font-size: var(--font-xs);
  line-height: 1.5;
}

@media (max-width: 767px) {
  .eating-nutrition__grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}
</style>
