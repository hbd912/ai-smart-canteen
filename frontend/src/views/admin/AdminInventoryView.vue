<script setup lang="ts">
/**
 * 库存管理：库存列表、调整（记录原因）、供应状态切换、库存流水。
 */
import { onMounted, reactive, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { adminApi } from '@/api/modules'
import type { InventoryItem, InventoryLog, PageResult } from '@/types/api'
import { formatDateTime } from '@/utils/format'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()

const loading = ref(false)
const items = ref<InventoryItem[]>([])
const keyword = ref('')
const lowStockOnly = ref(false)
const tab = ref<'stock' | 'logs'>('stock')

const logs = ref<InventoryLog[]>([])
const logsLoading = ref(false)
const logsTotal = ref(0)
const logsPage = ref(1)
const logsPageSize = 12

const modalOpen = ref(false)
const adjusting = ref(false)
const current = ref<InventoryItem | null>(null)
const adjustError = ref('')
const form = reactive({
  mode: 'delta' as 'delta' | 'target',
  changeAmount: 0,
  targetStock: 0,
  reason: ''
})

const confirmSupplyId = ref<number | null>(null)
const pendingSupplyStatus = ref('')

async function load() {
  loading.value = true
  try {
    items.value = await adminApi.inventory({
      keyword: keyword.value || undefined,
      lowStockOnly: lowStockOnly.value || undefined
    })
  } catch (e) {
    toast.error('库存加载失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    loading.value = false
  }
}

async function loadLogs() {
  logsLoading.value = true
  try {
    const result: PageResult<InventoryLog> = await adminApi.inventoryLogs({
      page: logsPage.value,
      pageSize: logsPageSize
    })
    logs.value = result.records
    logsTotal.value = result.total
  } catch (e) {
    toast.error('库存流水加载失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    logsLoading.value = false
  }
}

function switchTab(next: 'stock' | 'logs') {
  tab.value = next
  if (next === 'logs' && logs.value.length === 0) {
    loadLogs()
  }
}

function openAdjust(item: InventoryItem) {
  current.value = item
  adjustError.value = ''
  form.mode = 'delta'
  form.changeAmount = 0
  form.targetStock = item.stock
  form.reason = ''
  modalOpen.value = true
}

async function submitAdjust() {
  if (!current.value) {
    return
  }
  adjustError.value = ''
  if (!form.reason.trim()) {
    adjustError.value = '请填写调整原因，便于后续追溯'
    return
  }
  if (form.mode === 'delta' && (!form.changeAmount || Number(form.changeAmount) === 0)) {
    adjustError.value = '调整数量不能为 0'
    return
  }
  adjusting.value = true
  try {
    await adminApi.adjustInventory({
      dishId: current.value.dishId,
      changeAmount: form.mode === 'delta' ? Number(form.changeAmount) : undefined,
      targetStock: form.mode === 'target' ? Number(form.targetStock) : undefined,
      reason: form.reason.trim()
    })
    toast.success('库存已调整', '已写入库存流水')
    modalOpen.value = false
    await load()
    if (tab.value === 'logs') {
      await loadLogs()
    }
  } catch (e) {
    adjustError.value = e instanceof Error ? e.message : '调整失败'
  } finally {
    adjusting.value = false
  }
}

function askSupply(item: InventoryItem, status: string) {
  confirmSupplyId.value = item.dishId
  pendingSupplyStatus.value = status
}

async function doSupply() {
  if (!confirmSupplyId.value) {
    return
  }
  try {
    await adminApi.setSupplyStatus(confirmSupplyId.value, pendingSupplyStatus.value)
    toast.success('供应状态已更新', '前台菜单将同步显示')
    confirmSupplyId.value = null
    await load()
  } catch (e) {
    toast.error('更新失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

function changeLogPage(next: number) {
  const totalPages = Math.max(Math.ceil(logsTotal.value / logsPageSize), 1)
  if (next < 1 || next > totalPages) {
    return
  }
  logsPage.value = next
  loadLogs()
}

const supplyLabel: Record<string, string> = { AVAILABLE: '供应中', SOLD_OUT: '已售罄', PAUSED: '暂停供应' }

onMounted(load)
</script>

<template>
  <div class="inventory-page">
    <header class="page-head">
      <div>
        <h2 class="page-head__title">库存与供应管理</h2>
        <p class="page-head__desc">库存为 0 或暂停供应时，前台会显示售罄且禁止加入购物车；每次调整都会记录流水。</p>
      </div>
      <div class="tabs">
        <button class="tabs__btn" :class="{ 'tabs__btn--active': tab === 'stock' }" type="button" @click="switchTab('stock')">库存列表</button>
        <button class="tabs__btn" :class="{ 'tabs__btn--active': tab === 'logs' }" type="button" @click="switchTab('logs')">库存流水</button>
      </div>
    </header>

    <template v-if="tab === 'stock'">
      <section class="filter-bar">
        <div class="filter-bar__search">
          <AppIcon name="search" :size="15" class="filter-bar__icon" />
          <input v-model="keyword" class="filter-bar__input" type="search" placeholder="搜索菜品名称或编码" @keyup.enter="load" />
        </div>
        <label class="check-inline">
          <input v-model="lowStockOnly" type="checkbox" @change="load" />
          <span class="check-inline__box"><AppIcon name="check" :size="10" /></span>
          只看库存预警（≤10 份）
        </label>
        <button class="btn btn--ghost btn--sm" type="button" @click="load">刷新</button>
      </section>

      <section class="table-card">
        <div v-if="loading" class="skeleton" style="height: 220px; border-radius: 12px"></div>
        <div v-else-if="items.length === 0" class="empty-mini">没有符合条件的菜品</div>
        <table v-else class="data-table">
          <thead>
            <tr>
              <th style="width: 68px">图片</th>
              <th>菜品</th>
              <th style="width: 100px">分类</th>
              <th style="width: 90px">当前库存</th>
              <th style="width: 90px">已售</th>
              <th style="width: 100px">供应状态</th>
              <th style="width: 150px">更新时间</th>
              <th style="width: 190px">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in items" :key="item.dishId">
              <td><img class="cell-img" :src="item.imageUrl || '/assets/images/dishes/dish-placeholder.webp'" :alt="item.name" /></td>
              <td>
                <div class="cell-name">
                  <span class="cell-name__main">{{ item.name }}</span>
                  <span class="cell-name__sub">{{ item.dishCode }}</span>
                </div>
              </td>
              <td>{{ item.categoryName || '—' }}</td>
              <td>
                <span class="stock num" :class="{ 'stock--low': item.stock <= 10 && item.stock > 0, 'stock--zero': item.stock <= 0 }">
                  {{ item.stock }}
                </span>
              </td>
              <td class="num">{{ item.soldCount }}</td>
              <td>
                <span class="pill" :class="item.supplyStatus === 'AVAILABLE' ? 'pill--sage' : item.supplyStatus === 'SOLD_OUT' ? 'pill--danger' : 'pill--amber'">
                  {{ supplyLabel[item.supplyStatus] || item.supplyStatus }}
                </span>
              </td>
              <td class="text-muted cell-time">{{ formatDateTime(item.updatedAt) }}</td>
              <td>
                <div class="row-actions">
                  <button class="act" type="button" @click="openAdjust(item)">调整库存</button>
                  <button v-if="item.supplyStatus !== 'AVAILABLE'" class="act" type="button" @click="askSupply(item, 'AVAILABLE')">恢复供应</button>
                  <button v-else class="act" type="button" @click="askSupply(item, 'PAUSED')">暂停供应</button>
                  <button class="act act--danger" type="button" @click="askSupply(item, 'SOLD_OUT')">标记售罄</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </section>
    </template>

    <template v-else>
      <section class="table-card">
        <div v-if="logsLoading" class="skeleton" style="height: 220px; border-radius: 12px"></div>
        <div v-else-if="logs.length === 0" class="empty-mini">还没有库存流水记录</div>
        <table v-else class="data-table">
          <thead>
            <tr>
              <th style="width: 150px">时间</th>
              <th>菜品</th>
              <th style="width: 100px">变动</th>
              <th style="width: 130px">调整前 → 后</th>
              <th>原因</th>
              <th style="width: 120px">操作人</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="log in logs" :key="log.id">
              <td class="cell-time text-muted">{{ formatDateTime(log.createdAt) }}</td>
              <td>{{ log.dishName }}</td>
              <td>
                <span class="num delta" :class="log.changeAmount >= 0 ? 'delta--up' : 'delta--down'">
                  {{ log.changeAmount > 0 ? '+' : '' }}{{ log.changeAmount }}
                </span>
              </td>
              <td class="num">{{ log.beforeStock }} → {{ log.afterStock }}</td>
              <td class="cell-reason">{{ log.reason }}</td>
              <td>{{ log.operatorName }}</td>
            </tr>
          </tbody>
        </table>
        <footer v-if="logs.length > 0" class="pager">
          <span class="pager__info">共 {{ logsTotal }} 条流水</span>
          <div class="pager__buttons">
            <button class="btn btn--ghost btn--sm" type="button" :disabled="logsPage <= 1" @click="changeLogPage(logsPage - 1)">上一页</button>
            <button
              class="btn btn--ghost btn--sm"
              type="button"
              :disabled="logsPage >= Math.max(Math.ceil(logsTotal / logsPageSize), 1)"
              @click="changeLogPage(logsPage + 1)"
            >
              下一页
            </button>
          </div>
        </footer>
      </section>
    </template>

    <!-- 调整弹窗 -->
    <Transition name="modal">
      <div v-if="modalOpen && current" class="modal" @click.self="modalOpen = false">
        <div class="modal-box">
          <header class="modal-box__head">
            <div>
              <h3>调整库存 · {{ current.name }}</h3>
              <p class="modal-box__sub">当前库存 {{ current.stock }} 份</p>
            </div>
            <button type="button" aria-label="关闭" @click="modalOpen = false"><AppIcon name="close" :size="17" /></button>
          </header>
          <div class="modal-box__body">
            <div class="seg">
              <button class="seg__btn" :class="{ 'seg__btn--active': form.mode === 'delta' }" type="button" @click="form.mode = 'delta'">按增减量</button>
              <button class="seg__btn" :class="{ 'seg__btn--active': form.mode === 'target' }" type="button" @click="form.mode = 'target'">直接设置目标值</button>
            </div>

            <div v-if="form.mode === 'delta'" class="field">
              <label class="field__label" for="adj-delta">变动数量（正数入库 / 负数出库）</label>
              <input id="adj-delta" v-model.number="form.changeAmount" class="input" type="number" step="1" />
              <p class="field-hint">调整后库存：{{ Math.max(current.stock + Number(form.changeAmount || 0), 0) }} 份</p>
            </div>

            <div v-else class="field">
              <label class="field__label" for="adj-target">目标库存</label>
              <input id="adj-target" v-model.number="form.targetStock" class="input" type="number" min="0" step="1" />
            </div>

            <div class="field">
              <label class="field__label" for="adj-reason">调整原因 <span class="required">*</span></label>
              <input id="adj-reason" v-model="form.reason" class="input" type="text" maxlength="200" placeholder="例如：每日补货、盘点差异、损耗报废" />
            </div>

            <p v-if="adjustError" class="form-error"><AppIcon name="x-circle" :size="13" />{{ adjustError }}</p>
          </div>
          <footer class="modal-box__foot">
            <button class="btn btn--ghost" type="button" @click="modalOpen = false">取消</button>
            <button class="btn btn--primary" type="button" :disabled="adjusting" @click="submitAdjust">
              {{ adjusting ? '提交中…' : '确认调整' }}
            </button>
          </footer>
        </div>
      </div>
    </Transition>

    <Transition name="modal">
      <div v-if="confirmSupplyId" class="modal" @click.self="confirmSupplyId = null">
        <div class="modal-box modal-box--sm">
          <div class="confirm">
            <span class="confirm__icon"><AppIcon name="alert-triangle" :size="20" /></span>
            <h3 class="confirm__title">确认变更供应状态？</h3>
            <p class="confirm__desc">变更为「{{ supplyLabel[pendingSupplyStatus] }}」后，前台菜单状态会立即同步。</p>
            <div class="confirm__actions">
              <button class="btn btn--ghost" type="button" @click="confirmSupplyId = null">取消</button>
              <button class="btn btn--primary" type="button" @click="doSupply">确认</button>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.inventory-page {
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
  max-width: 720px;
  line-height: 1.55;
}

.tabs {
  display: flex;
  gap: 3px;
  padding: 3px;
  border-radius: var(--radius-pill);
  background: rgba(232, 238, 221, 0.7);
}

.tabs__btn {
  height: 28px;
  padding: 0 14px;
  border-radius: var(--radius-pill);
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--ink-600);
}

.tabs__btn--active {
  background: #fff;
  color: var(--sage-700);
  box-shadow: var(--shadow-xs);
}

.filter-bar {
  display: flex;
  align-items: center;
  gap: 10px;
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

.check-inline {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: var(--font-xs);
  color: var(--ink-600);
  cursor: pointer;
}

.check-inline input {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

.check-inline__box {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 15px;
  height: 15px;
  border-radius: 4px;
  border: 1.5px solid rgba(124, 143, 90, 0.45);
  background: #fff;
  color: transparent;
}

.check-inline input:checked + .check-inline__box {
  background: var(--sage-600);
  border-color: var(--sage-600);
  color: #fff;
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

.cell-img {
  width: 48px;
  height: 36px;
  border-radius: var(--radius-xs);
  object-fit: cover;
}

.cell-name {
  display: flex;
  flex-direction: column;
}

.cell-name__main {
  font-size: var(--font-sm);
  font-weight: 600;
  color: var(--ink-900);
}

.cell-name__sub {
  font-size: 10px;
  color: var(--ink-400);
}

.cell-time {
  font-size: 10.5px;
}

.cell-reason {
  font-size: 10.5px;
  color: var(--ink-600);
  max-width: 320px;
}

.stock {
  font-weight: 700;
  color: var(--ink-700);
}

.stock--low {
  color: var(--amber-600);
}

.stock--zero {
  color: var(--danger-600);
}

.delta {
  font-weight: 700;
}

.delta--up {
  color: var(--success-600);
}

.delta--down {
  color: var(--danger-600);
}

.pill {
  display: inline-flex;
  padding: 2px 8px;
  border-radius: var(--radius-pill);
  font-size: 10px;
  font-weight: 600;
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

.row-actions {
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
}

.act {
  padding: 3px 8px;
  border-radius: var(--radius-xs);
  background: var(--sage-50);
  color: var(--sage-700);
  font-size: 10.5px;
  font-weight: 600;
}

.act:hover {
  background: var(--sage-100);
}

.act--danger {
  background: var(--danger-100);
  color: var(--danger-600);
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

.modal {
  position: fixed;
  inset: 0;
  z-index: 400;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-5);
  background: rgba(48, 44, 36, 0.4);
  backdrop-filter: blur(4px);
}

.modal-box {
  width: min(460px, 100%);
  border-radius: var(--radius-xl);
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  overflow: hidden;
  animation: scale-in var(--motion-normal) var(--ease-enter) both;
}

.modal-box--sm {
  width: min(400px, 100%);
}

.modal-box__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  padding: var(--space-4) var(--space-5);
  border-bottom: 1px solid rgba(124, 143, 90, 0.12);
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.modal-box__sub {
  font-size: 10.5px;
  color: var(--ink-400);
  font-weight: 400;
  margin-top: 2px;
}

.modal-box__head button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  color: var(--ink-500);
}

.modal-box__body {
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.modal-box__foot {
  display: flex;
  gap: var(--space-3);
  padding: var(--space-4) var(--space-5);
  border-top: 1px solid rgba(124, 143, 90, 0.12);
}

.modal-box__foot .btn {
  flex: 1;
}

.seg {
  display: flex;
  gap: 3px;
  padding: 3px;
  border-radius: var(--radius-pill);
  background: var(--sage-50);
}

.seg__btn {
  flex: 1;
  height: 30px;
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

.field-hint {
  font-size: 10.5px;
  color: var(--ink-500);
}

.form-error {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 8px 11px;
  border-radius: var(--radius-sm);
  background: var(--danger-100);
  color: var(--danger-600);
  font-size: var(--font-xs);
}

.confirm {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: var(--space-6);
  text-align: center;
}

.confirm__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: var(--amber-100);
  color: var(--amber-600);
}

.confirm__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.confirm__desc {
  font-size: var(--font-xs);
  color: var(--ink-500);
  line-height: 1.6;
}

.confirm__actions {
  display: flex;
  gap: var(--space-3);
  width: 100%;
  margin-top: var(--space-2);
}

.confirm__actions .btn {
  flex: 1;
}
</style>
