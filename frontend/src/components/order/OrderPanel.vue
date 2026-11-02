<script setup lang="ts">
/**
 * 订单面板：当前订单 + 历史订单。不改变背景视频。
 */
import { computed, onMounted, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import ReviewCenter from '@/components/order/ReviewCenter.vue'
import { DISH_PLACEHOLDER } from '@/config/media'
import { orderApi } from '@/api/modules'
import type { Order } from '@/types/api'
import { formatDateTime, formatMoney, orderStatusTone } from '@/utils/format'

/** 视图模式：orders = 订单列表，review = 评价中心 */
const viewMode = ref<'orders' | 'review'>('orders')

const emit = defineEmits<{
  (e: 'refresh-scene'): void
}>()

const loading = ref(true)
const error = ref<string | null>(null)
const orders = ref<Order[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = 6
const expandedId = ref<number | null>(null)
const filter = ref<'ALL' | 'active' | 'completed'>('ALL')

const filtered = computed(() => {
  if (filter.value === 'active') {
    return orders.value.filter((o) => ['PENDING', 'PREPARING', 'DELIVERING', 'DELIVERED', 'EATING'].includes(o.orderStatus))
  }
  if (filter.value === 'completed') {
    return orders.value.filter((o) => o.orderStatus === 'COMPLETED')
  }
  return orders.value
})

const hasMore = computed(() => orders.value.length < total.value)

async function load(reset = false) {
  if (reset) {
    page.value = 1
  }
  loading.value = true
  error.value = null
  try {
    const result = await orderApi.list({ page: page.value, pageSize })
    orders.value = reset ? result.records : [...orders.value, ...result.records]
    total.value = result.total
  } catch (e) {
    error.value = e instanceof Error ? e.message : '订单加载失败'
  } finally {
    loading.value = false
  }
}

async function loadMore() {
  page.value += 1
  await load()
}

function toggle(id: number) {
  expandedId.value = expandedId.value === id ? null : id
}

onMounted(() => load(true))

defineExpose({ reload: () => load(true) })
</script>

<template>
  <section class="panel-card glass-card scroll-y">
    <header class="panel-head">
      <div>
        <h2 class="section-title">
          <span class="section-title__icon"><AppIcon name="calendar" :size="15" /></span>
          我的订单
        </h2>
        <p class="section-subtitle">
          {{ viewMode === 'orders' ? '课堂演示订单：模拟支付，不产生真实扣款' : '只展示你下过单的菜品，未购买不可评价' }}
        </p>
      </div>
      <div class="order-head__right">
        <button
          class="btn btn--sm order-mode-btn"
          :class="viewMode === 'review' ? 'btn--primary' : 'btn--ghost'"
          type="button"
          @click="viewMode = viewMode === 'orders' ? 'review' : 'orders'"
        >
          <AppIcon name="star" :size="13" />
          {{ viewMode === 'review' ? '返回订单' : '评价中心' }}
        </button>
        <div v-if="viewMode === 'orders'" class="seg-control">
          <button
            v-for="item in [
              { key: 'ALL', label: '全部' },
              { key: 'active', label: '进行中' },
              { key: 'completed', label: '已完成' }
            ]"
            :key="item.key"
            class="seg-control__btn"
            :class="{ 'seg-control__btn--active': filter === item.key }"
            type="button"
            @click="filter = item.key as typeof filter"
          >
            {{ item.label }}
          </button>
        </div>
      </div>
    </header>

    <!-- 评价中心 -->
    <ReviewCenter v-if="viewMode === 'review'" :active="viewMode === 'review'" />

    <!-- 订单列表 -->
    <template v-else>

    <div v-if="loading && orders.length === 0" class="order-list">
      <div v-for="i in 3" :key="i" class="skeleton" style="height: 96px; border-radius: 16px"></div>
    </div>

    <div v-else-if="error" class="panel-empty">
      <AppIcon name="alert-triangle" :size="24" />
      <p>{{ error }}</p>
      <button class="btn btn--ghost btn--sm" type="button" @click="load(true)">重试</button>
    </div>

    <div v-else-if="filtered.length === 0" class="panel-empty">
      <span class="panel-empty__art"><AppIcon name="clipboard-list" :size="30" /></span>
      <p class="panel-empty__title">还没有订单</p>
      <p class="panel-empty__desc">去挑选今天的美味吧，结算后桌面才会送来餐食。</p>
    </div>

    <div v-else class="order-list">
      <article v-for="order in filtered" :key="order.id" class="order-card">
        <button class="order-card__head" type="button" :aria-expanded="expandedId === order.id" @click="toggle(order.id)">
          <div class="order-card__main">
            <div class="order-card__top">
              <span class="order-card__no num">{{ order.orderNo }}</span>
              <span class="tag" :class="`tag--${orderStatusTone(order.orderStatus) === 'amber' ? 'amber' : orderStatusTone(order.orderStatus) === 'danger' ? 'danger' : 'sage'}`">
                {{ order.orderStatusLabel }}
              </span>
              <span v-if="order.demo" class="tag tag--muted">演示订单</span>
            </div>
            <p class="order-card__meta">
              <span>{{ formatDateTime(order.createdAt) }}</span>
              <span class="order-card__dot">·</span>
              <span>{{ order.totalQuantity ?? order.itemCount ?? 0 }} 份</span>
              <span class="order-card__dot">·</span>
              <span class="order-card__amount num">¥{{ formatMoney(order.totalAmount) }}</span>
            </p>
          </div>
          <AppIcon :name="expandedId === order.id ? 'chevron-up' : 'chevron-down'" :size="16" class="order-card__chevron" />
        </button>

        <Transition name="fade">
          <div v-if="expandedId === order.id" class="order-card__detail">
            <ul class="order-items">
              <li v-for="item in order.items" :key="item.id" class="order-item">
                <img :src="item.imageUrl || DISH_PLACEHOLDER" :alt="item.dishName" />
                <div class="order-item__info">
                  <span class="order-item__name">{{ item.dishName }}</span>
                  <span class="order-item__unit num">¥{{ formatMoney(item.unitPrice) }} × {{ item.quantity }}</span>
                </div>
                <span class="order-item__subtotal num">¥{{ formatMoney(item.subtotal) }}</span>
              </li>
            </ul>

            <div class="order-card__summary">
              <div class="order-card__row">
                <span>订单金额</span>
                <span class="num">¥{{ formatMoney(order.totalAmount) }}</span>
              </div>
              <div class="order-card__row">
                <span>预估热量</span>
                <span class="num">{{ Math.round(Number(order.totalCalories ?? 0)) }} kcal</span>
              </div>
              <div class="order-card__row">
                <span>支付状态</span>
                <span>{{ order.paymentStatusLabel }}</span>
              </div>
            </div>

            <div v-if="order.statusLogs && order.statusLogs.length" class="order-timeline">
              <div v-for="log in order.statusLogs" :key="log.id" class="timeline-item">
                <span class="timeline-item__dot"></span>
                <div class="timeline-item__body">
                  <span class="timeline-item__status">{{ log.toStatusLabel }}</span>
                  <span class="timeline-item__time">{{ formatDateTime(log.createdAt) }}</span>
                  <span v-if="log.remark" class="timeline-item__remark">{{ log.remark }}</span>
                </div>
              </div>
            </div>
          </div>
        </Transition>
      </article>

      <button v-if="hasMore" class="btn btn--ghost btn--block" type="button" :disabled="loading" @click="loadMore">
        {{ loading ? '加载中…' : '加载更多订单' }}
      </button>
    </div>
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
  padding: 0 12px;
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

.order-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.order-card {
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.76);
  border: 1px solid rgba(124, 143, 90, 0.12);
  overflow: hidden;
  transition: border-color var(--motion-fast) var(--ease-standard),
    box-shadow var(--motion-fast) var(--ease-standard);
}

.order-card:hover {
  border-color: rgba(124, 143, 90, 0.28);
  box-shadow: var(--shadow-sm);
}

.order-card__head {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  width: 100%;
  padding: 12px 14px;
  text-align: left;
}

.order-card__main {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.order-card__top {
  display: flex;
  align-items: center;
  gap: 7px;
  flex-wrap: wrap;
}

.order-card__no {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-800);
  letter-spacing: 0.02em;
}

.order-card__meta {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: var(--font-xs);
  color: var(--ink-500);
  flex-wrap: wrap;
}

.order-card__dot {
  color: var(--ink-300);
}

.order-card__amount {
  color: var(--amber-600);
  font-weight: 700;
}

.order-card__chevron {
  color: var(--ink-400);
  flex: none;
}

.order-card__detail {
  padding: 0 14px 14px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.order-items {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.order-item {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 7px 9px;
  border-radius: var(--radius-sm);
  background: rgba(247, 239, 223, 0.5);
}

.order-item img {
  width: 38px;
  height: 38px;
  border-radius: var(--radius-xs);
  object-fit: cover;
  flex: none;
}

.order-item__info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.order-item__name {
  font-size: var(--font-sm);
  font-weight: 600;
  color: var(--ink-800);
}

.order-item__unit {
  font-size: 10.5px;
  color: var(--ink-500);
}

.order-item__subtotal {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-700);
}

.order-card__summary {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 9px 11px;
  border-radius: var(--radius-sm);
  background: rgba(232, 238, 221, 0.5);
}

.order-card__row {
  display: flex;
  justify-content: space-between;
  font-size: var(--font-xs);
  color: var(--ink-600);
}

.order-timeline {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-left: 4px;
}

.timeline-item {
  position: relative;
  display: flex;
  gap: 10px;
  padding-left: 12px;
  border-left: 1.5px solid rgba(124, 143, 90, 0.24);
}

.timeline-item__dot {
  position: absolute;
  left: -4.5px;
  top: 4px;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--sage-400);
  box-shadow: 0 0 0 2px rgba(255, 253, 248, 0.9);
}

.timeline-item__body {
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.timeline-item__status {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--sage-700);
}

.timeline-item__time {
  font-size: 10.5px;
  color: var(--ink-400);
}

.timeline-item__remark {
  font-size: 10.5px;
  color: var(--ink-500);
}

.panel-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: var(--space-10) var(--space-5);
  color: var(--ink-500);
  text-align: center;
}

.panel-empty__art {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: var(--sage-50);
  color: var(--sage-400);
}

.panel-empty__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-700);
}

.panel-empty__desc {
  font-size: var(--font-xs);
  color: var(--ink-400);
  max-width: 260px;
  line-height: 1.6;
}

.order-head__right {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.order-mode-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  white-space: nowrap;
}
</style>
