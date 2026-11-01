<script setup lang="ts">
/**
 * 005 送餐完成后的停留状态面板。
 * 此时视频停在最后一帧（餐盘已放上桌），等待用户主动点击任意导航才进入用餐循环。
 */
import { computed } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import type { Order } from '@/types/api'
import { formatMoney } from '@/utils/format'

const props = defineProps<{
  order: Order | null
}>()

const itemSummary = computed(() => {
  const items = props.order?.items ?? []
  if (items.length === 0) {
    return '订单信息同步中…'
  }
  return items.map((i) => `${i.dishName} ×${i.quantity}`).join('、')
})
</script>

<template>
  <section class="hold-card glass-card">
    <div class="hold-card__badge">
      <span class="hold-card__dot"></span>
      餐已送达
    </div>

    <h2 class="hold-card__title">你的餐已经准备好了</h2>
    <p class="hold-card__subtitle">点击任意导航按钮，开始享用这一餐。</p>

    <div v-if="order" class="hold-card__order">
      <div class="hold-card__row">
        <span class="hold-card__label">订单号</span>
        <span class="hold-card__value num">{{ order.orderNo }}</span>
      </div>
      <div class="hold-card__row">
        <span class="hold-card__label">订单金额</span>
        <span class="hold-card__value num hold-card__value--amount">¥{{ formatMoney(order.totalAmount) }}</span>
      </div>
      <div class="hold-card__row hold-card__row--wrap">
        <span class="hold-card__label">菜品</span>
        <span class="hold-card__value hold-card__value--items">{{ itemSummary }}</span>
      </div>
    </div>

    <div class="hold-card__actions">
      <button class="btn btn--primary" type="button" @click="$emit('start-eating')">
        <AppIcon name="play" :size="15" />
        开始用餐
      </button>
    </div>

    <p class="hold-card__hint">
      <AppIcon name="info" :size="12" />
      也可以点击左侧导航（首页 / 订单 / 收藏 / 营养管理）进入用餐画面
    </p>
  </section>
</template>

<style scoped>
.hold-card {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  padding: var(--space-5);
}

.hold-card__badge {
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

.hold-card__dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--success-500);
  animation: pulse-ring 2.4s var(--ease-standard) infinite;
}

.hold-card__title {
  font-size: var(--font-xl);
  font-weight: 700;
  color: var(--ink-900);
}

.hold-card__subtitle {
  font-size: var(--font-sm);
  color: var(--ink-500);
  margin-top: -6px;
}

.hold-card__order {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.72);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.hold-card__row {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
  font-size: var(--font-sm);
}

.hold-card__row--wrap {
  align-items: flex-start;
}

.hold-card__label {
  color: var(--ink-500);
  flex: none;
}

.hold-card__value {
  color: var(--ink-800);
  font-weight: 600;
  text-align: right;
}

.hold-card__value--amount {
  color: var(--amber-600);
  font-weight: 700;
}

.hold-card__value--items {
  font-size: var(--font-xs);
  font-weight: 500;
  line-height: 1.6;
}

.hold-card__actions {
  display: flex;
  gap: 8px;
}

.hold-card__hint {
  display: flex;
  align-items: flex-start;
  gap: 5px;
  font-size: 10.5px;
  color: var(--ink-400);
  line-height: 1.55;
}
</style>
