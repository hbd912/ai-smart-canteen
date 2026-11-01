<script setup lang="ts">
/**
 * 订单管理：筛选、分页、详情抽屉、状态更新。
 * 管理员更新状态只影响业务事实，不直接改动前台视频场景。
 */
import { computed, onMounted, reactive, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { adminApi } from '@/api/modules'
import { DISH_PLACEHOLDER } from '@/config/media'
import type { Order, PageResult } from '@/types/api'
import { formatDateTime, formatMoney, orderStatusTone } from '@/utils/format'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()

const loading = ref(false)
const orders = ref<Order[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)

const filters = reactive({
  keyword: '',
  status: '',
  startDate: '',
  endDate: ''
})

const detailOpen = ref(false)
const detailLoading = ref(false)
const detail = ref<Order | null>(null)
const updating = ref(false)
const statusDraft = ref('')
const statusRemark = ref('')

const totalPages = computed(() => Math.max(Math.ceil(total.value / pageSize.value), 1))

const statusOptions = [
  { value: 'PENDING', label: '已提交' },
  { value: 'PREPARING', label: '备餐中' },
  { value: 'DELIVERING', label: '送餐中' },
  { value: 'DELIVERED', label: '已送达' },
  { value: 'EATING', label: '用餐中' },
  { value: 'COMPLETED', label: '已完成' },
  { value: 'CANCELLED', label: '已取消' }
]

async function load() {
  loading.value = true
  try {
    const result: PageResult<Order> = await adminApi.orders({
      page: page.value,
      pageSize: pageSize.value,
      keyword: filters.keyword || undefined,
      status: filters.status || undefined,
      startDate: filters.startDate || undefined,
      endDate: filters.endDate || undefined
    })
    orders.value = result.records
    total.value = result.total
  } catch (e) {
    toast.error('订单加载失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    loading.value = false
  }
}

function search() {
  page.value = 1
  load()
}

function reset() {
  filters.keyword = ''
  filters.status = ''
  filters.startDate = ''
  filters.endDate = ''
  page.value = 1
  load()
}

function changePage(next: number) {
  if (next < 1 || next > totalPages.value) {
    return
  }
  page.value = next
  load()
}

async function openDetail(order: Order) {
  detailOpen.value = true
  detailLoading.value = true
  statusDraft.value = order.orderStatus
  statusRemark.value = ''
  try {
    detail.value = await adminApi.order(order.id)
  } catch (e) {
    toast.error('订单详情加载失败', e instanceof Error ? e.message : '请稍后重试')
    detail.value = order
  } finally {
    detailLoading.value = false
  }
}

async function updateStatus() {
  if (!detail.value || updating.value) {
    return
  }
  if (statusDraft.value === detail.value.orderStatus) {
    toast.info('状态未变化')
    return
  }
  updating.value = true
  try {
    detail.value = await adminApi.updateOrderStatus(detail.value.id, statusDraft.value, statusRemark.value)
    toast.success('订单状态已更新', '用户端场景状态不会被后台强制改变')
    await load()
  } catch (e) {
    toast.error('状态更新失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    updating.value = false
  }
}

onMounted(load)
</script>

<template>
  <div class="orders-page">
    <header class="page-head">
      <div>
        <h2 class="page-head__title">订单管理</h2>
        <p class="page-head__desc">
          课堂演示订单为模拟数据，金额不代表真实支付；取消订单不计入销售额统计，并会回补库存。
        </p>
      </div>
    </header>

    <section class="filter-bar">
      <div class="filter-bar__search">
        <AppIcon name="search" :size="15" class="filter-bar__icon" />
        <input v-model="filters.keyword" class="filter-bar__input" type="search" placeholder="订单号 / 用户账号 / 昵称" @keyup.enter="search" />
      </div>
      <select v-model="filters.status" class="select" @change="search">
        <option value="">全部状态</option>
        <option v-for="option in statusOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
      </select>
      <input v-model="filters.startDate" class="select" type="date" aria-label="开始日期" @change="search" />
      <input v-model="filters.endDate" class="select" type="date" aria-label="结束日期" @change="search" />
      <button class="btn btn--ghost btn--sm" type="button" @click="reset">重置</button>
      <button class="btn btn--ghost btn--sm" type="button" @click="search">查询</button>
    </section>

    <section class="table-card">
      <div v-if="loading" class="skeleton" style="height: 260px; border-radius: 12px"></div>
      <div v-else-if="orders.length === 0" class="empty-mini">没有符合条件的订单</div>
      <table v-else class="data-table">
        <thead>
          <tr>
            <th style="width: 180px">订单号</th>
            <th style="width: 130px">用户</th>
            <th>菜品摘要</th>
            <th style="width: 70px">份数</th>
            <th style="width: 100px">金额</th>
            <th style="width: 96px">状态</th>
            <th style="width: 150px">下单时间</th>
            <th style="width: 90px">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="order in orders" :key="order.id">
            <td>
              <div class="order-no">
                <span class="num">{{ order.orderNo }}</span>
                <span v-if="order.demo" class="pill pill--muted">演示</span>
              </div>
            </td>
            <td>
              <div class="cell-user">
                <span>{{ order.userNickname || '—' }}</span>
                <span class="cell-user__acc">{{ order.userAccount }}</span>
              </div>
            </td>
            <td class="cell-summary">
              {{ (order.items || []).map((i) => i.dishName).join('、') || '—' }}
            </td>
            <td class="num">{{ order.totalQuantity ?? order.itemCount ?? 0 }}</td>
            <td class="num">¥{{ formatMoney(order.totalAmount) }}</td>
            <td>
              <span class="pill" :class="`pill--${orderStatusTone(order.orderStatus)}`">{{ order.orderStatusLabel }}</span>
            </td>
            <td class="cell-time text-muted">{{ formatDateTime(order.createdAt) }}</td>
            <td>
              <button class="act" type="button" @click="openDetail(order)">详情</button>
            </td>
          </tr>
        </tbody>
      </table>
      <footer v-if="orders.length > 0" class="pager">
        <span class="pager__info">共 {{ total }} 笔订单 · 第 {{ page }} / {{ totalPages }} 页</span>
        <div class="pager__buttons">
          <button class="btn btn--ghost btn--sm" type="button" :disabled="page <= 1" @click="changePage(page - 1)">上一页</button>
          <button class="btn btn--ghost btn--sm" type="button" :disabled="page >= totalPages" @click="changePage(page + 1)">下一页</button>
        </div>
      </footer>
    </section>

    <!-- 详情抽屉 -->
    <Transition name="panel">
      <div v-if="detailOpen" class="drawer-mask" @click.self="detailOpen = false">
        <aside class="drawer">
          <header class="drawer__head">
            <div>
              <h2 class="drawer__title">订单详情</h2>
              <p class="drawer__sub num">{{ detail?.orderNo }}</p>
            </div>
            <button class="drawer__close" type="button" aria-label="关闭" @click="detailOpen = false">
              <AppIcon name="close" :size="17" />
            </button>
          </header>

          <div class="drawer__body">
            <div v-if="detailLoading" class="skeleton" style="height: 200px; border-radius: 12px"></div>
            <template v-else-if="detail">
              <div class="info-grid">
                <div class="info-cell">
                  <span class="info-cell__label">用户</span>
                  <span class="info-cell__value">{{ detail.userNickname }}（{{ detail.userAccount }}）</span>
                </div>
                <div class="info-cell">
                  <span class="info-cell__label">下单时间</span>
                  <span class="info-cell__value">{{ formatDateTime(detail.createdAt) }}</span>
                </div>
                <div class="info-cell">
                  <span class="info-cell__label">订单金额</span>
                  <span class="info-cell__value num info-cell__value--amount">¥{{ formatMoney(detail.totalAmount) }}</span>
                </div>
                <div class="info-cell">
                  <span class="info-cell__label">支付状态</span>
                  <span class="info-cell__value">{{ detail.paymentStatusLabel }}</span>
                </div>
                <div class="info-cell">
                  <span class="info-cell__label">订单状态</span>
                  <span class="pill" :class="`pill--${orderStatusTone(detail.orderStatus)}`">{{ detail.orderStatusLabel }}</span>
                </div>
                <div class="info-cell">
                  <span class="info-cell__label">预估热量</span>
                  <span class="info-cell__value num">{{ Math.round(Number(detail.totalCalories ?? 0)) }} kcal</span>
                </div>
              </div>

              <h3 class="drawer__section">菜品快照</h3>
              <div class="item-list">
                <div v-for="item in detail.items" :key="item.id" class="item-row">
                  <img :src="item.imageUrl || DISH_PLACEHOLDER" :alt="item.dishName" />
                  <div class="item-row__info">
                    <span class="item-row__name">{{ item.dishName }}</span>
                    <span class="item-row__meta num">¥{{ formatMoney(item.unitPrice) }} × {{ item.quantity }}</span>
                  </div>
                  <span class="item-row__subtotal num">¥{{ formatMoney(item.subtotal) }}</span>
                </div>
              </div>
              <p class="drawer__note">
                <AppIcon name="info" :size="12" />
                订单明细使用下单时的名称、单价与营养快照，菜品后续修改不会影响历史订单。
              </p>

              <h3 class="drawer__section">状态变更</h3>
              <div class="timeline">
                <div v-for="log in detail.statusLogs" :key="log.id" class="timeline__item">
                  <span class="timeline__dot"></span>
                  <div class="timeline__body">
                    <span class="timeline__status">{{ log.toStatusLabel }}</span>
                    <span class="timeline__time">{{ formatDateTime(log.createdAt) }} · {{ log.operatorType }}</span>
                    <span v-if="log.remark" class="timeline__remark">{{ log.remark }}</span>
                  </div>
                </div>
                <div v-if="!detail.statusLogs || detail.statusLogs.length === 0" class="empty-mini">暂无状态记录</div>
              </div>

              <h3 class="drawer__section">管理员操作</h3>
              <div class="status-editor">
                <select v-model="statusDraft" class="select">
                  <option v-for="option in statusOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
                </select>
                <input v-model="statusRemark" class="input" type="text" maxlength="120" placeholder="操作备注（可选）" />
                <button class="btn btn--primary btn--sm" type="button" :disabled="updating" @click="updateStatus">
                  {{ updating ? '更新中…' : '更新状态' }}
                </button>
              </div>
              <p class="drawer__note">
                <AppIcon name="alert-triangle" :size="12" />
                取消订单会自动回补库存；后台状态变更不会强制改变用户端正在播放的视频场景。
              </p>
            </template>
          </div>
        </aside>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.orders-page {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
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

.filter-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.filter-bar__search {
  position: relative;
  display: flex;
  align-items: center;
  width: 240px;
}

.filter-bar__icon {
  position: absolute;
  left: 11px;
  color: var(--sage-500);
}

.filter-bar__input {
  width: 100%;
  height: 34px;
  padding: 0 12px 0 34px;
  border-radius: var(--radius-pill);
  border: 1px solid rgba(124, 143, 90, 0.2);
  background: #fff;
  outline: none;
  font-size: var(--font-xs);
}

.select {
  height: 34px;
  padding: 0 10px;
  border-radius: var(--radius-sm);
  border: 1px solid rgba(124, 143, 90, 0.2);
  background: #fff;
  color: var(--ink-700);
  font-size: var(--font-xs);
  outline: none;
}

.table-card {
  padding: var(--space-4);
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: var(--font-xs);
}

.data-table th {
  text-align: left;
  padding: 9px 8px;
  font-size: 10.5px;
  font-weight: 600;
  color: var(--ink-500);
  border-bottom: 1px solid rgba(124, 143, 90, 0.16);
  white-space: nowrap;
}

.data-table td {
  padding: 10px 8px;
  border-bottom: 1px solid rgba(124, 143, 90, 0.07);
  color: var(--ink-700);
}

.data-table tbody tr:hover {
  background: var(--sage-50);
}

.order-no {
  display: flex;
  align-items: center;
  gap: 5px;
}

.cell-user {
  display: flex;
  flex-direction: column;
}

.cell-user__acc {
  font-size: 10px;
  color: var(--ink-400);
}

.cell-summary {
  font-size: 10.5px;
  color: var(--ink-600);
  max-width: 300px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.cell-time {
  font-size: 10.5px;
}

.pill {
  display: inline-flex;
  padding: 2px 8px;
  border-radius: var(--radius-pill);
  font-size: 10px;
  font-weight: 600;
  white-space: nowrap;
}

.pill--sage {
  background: var(--success-100);
  color: var(--success-600);
}

.pill--amber {
  background: var(--amber-100);
  color: var(--amber-600);
}

.pill--danger {
  background: var(--danger-100);
  color: var(--danger-600);
}

.pill--muted {
  background: rgba(139, 132, 120, 0.14);
  color: var(--ink-500);
}

.act {
  padding: 3px 9px;
  border-radius: var(--radius-xs);
  background: var(--sage-50);
  color: var(--sage-700);
  font-size: 10.5px;
  font-weight: 600;
}

.act:hover {
  background: var(--sage-100);
}

.pager {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: var(--space-3);
  margin-top: var(--space-2);
  border-top: 1px solid rgba(124, 143, 90, 0.12);
}

.pager__info {
  font-size: 10.5px;
  color: var(--ink-500);
}

.pager__buttons {
  display: flex;
  gap: 8px;
}

.empty-mini {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-8);
  color: var(--ink-400);
  font-size: var(--font-xs);
}

.drawer-mask {
  position: fixed;
  inset: 0;
  z-index: 300;
  display: flex;
  justify-content: flex-end;
  background: rgba(48, 44, 36, 0.36);
  backdrop-filter: blur(3px);
}

.drawer {
  display: flex;
  flex-direction: column;
  width: min(560px, 96vw);
  height: 100%;
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  animation: slide-in-right var(--motion-slow) var(--ease-enter) both;
}

.drawer__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  padding: var(--space-5);
  border-bottom: 1px solid rgba(124, 143, 90, 0.12);
}

.drawer__title {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--ink-900);
}

.drawer__sub {
  font-size: 10.5px;
  color: var(--ink-400);
  margin-top: 2px;
}

.drawer__close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  color: var(--ink-500);
  background: rgba(255, 255, 255, 0.8);
}

.drawer__body {
  flex: 1;
  overflow-y: auto;
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.drawer__section {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--sage-700);
  padding-top: var(--space-2);
  border-top: 1px dashed rgba(124, 143, 90, 0.2);
}

.drawer__note {
  display: flex;
  align-items: flex-start;
  gap: 5px;
  font-size: 10px;
  color: var(--ink-400);
  line-height: 1.55;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 9px;
}

.info-cell {
  display: flex;
  flex-direction: column;
  gap: 1px;
  padding: 8px 11px;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.76);
  border: 1px solid rgba(124, 143, 90, 0.1);
}

.info-cell__label {
  font-size: 10px;
  color: var(--ink-400);
}

.info-cell__value {
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--ink-800);
}

.info-cell__value--amount {
  color: var(--amber-600);
}

.item-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.item-row {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 8px 10px;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.76);
}

.item-row img {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-xs);
  object-fit: cover;
  flex: none;
}

.item-row__info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.item-row__name {
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--ink-800);
}

.item-row__meta {
  font-size: 10px;
  color: var(--ink-500);
}

.item-row__subtotal {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--ink-700);
}

.timeline {
  display: flex;
  flex-direction: column;
  gap: 9px;
  padding-left: 3px;
}

.timeline__item {
  position: relative;
  padding-left: 14px;
  border-left: 1.5px solid rgba(124, 143, 90, 0.24);
}

.timeline__dot {
  position: absolute;
  left: -4.5px;
  top: 4px;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--sage-400);
  box-shadow: 0 0 0 2px rgba(255, 253, 248, 0.9);
}

.timeline__body {
  display: flex;
  flex-direction: column;
}

.timeline__status {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--sage-700);
}

.timeline__time,
.timeline__remark {
  font-size: 10px;
  color: var(--ink-400);
}

.status-editor {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

@media (max-width: 767px) {
  .filter-bar__search {
    width: 100%;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }
}
</style>
