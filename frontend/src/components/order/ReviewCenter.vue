<script setup lang="ts">
/**
 * 评价中心：按订单明细列出「待评价 / 已评价」。
 * 参考图 3 的设计：头像 + 统计 + 分栏 tab + 每条记录带商品图与「去评价」按钮。
 *
 * 业务规则：只有真正下过单的菜品才能评价（后端也会校验）。
 */
import { computed, ref, watch } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import StarRating from '@/components/menu/StarRating.vue'
import { reviewApi } from '@/api/modules'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'
import { formatDateTime, formatMoney } from '@/utils/format'

const props = defineProps<{
  active: boolean
}>()

const auth = useAuthStore()
const toast = useToastStore()

interface CenterRow {
  orderId: number
  orderNo: string
  orderStatus: string
  orderCreatedAt: string
  dishId: number
  dishName: string
  imageUrl?: string | null
  quantity: number
  unitPrice: number
  reviewed: boolean
  myRating?: number | null
  myContent?: string | null
  reviewedAt?: string | null
}

const loading = ref(false)
const rows = ref<CenterRow[]>([])
const tab = ref<'pending' | 'done'>('pending')

// 评价弹窗
const dialogOpen = ref(false)
const editing = ref<CenterRow | null>(null)
const rating = ref(0)
const content = ref('')
const anonymous = ref(false)
const submitting = ref(false)

const pendingRows = computed(() => rows.value.filter((r) => !r.reviewed))
const doneRows = computed(() => rows.value.filter((r) => r.reviewed))
const listRows = computed(() => (tab.value === 'pending' ? pendingRows.value : doneRows.value))

const totalCount = computed(() => rows.value.length)
const doneCount = computed(() => doneRows.value.length)
const avgRating = computed(() => {
  const d = doneRows.value.filter((r) => r.myRating)
  if (d.length === 0) {
    return 0
  }
  return d.reduce((s, r) => s + Number(r.myRating ?? 0), 0) / d.length
})

async function load() {
  loading.value = true
  try {
    rows.value = (await reviewApi.center()) as unknown as CenterRow[]
  } catch {
    rows.value = []
  } finally {
    loading.value = false
  }
}

function openDialog(row: CenterRow) {
  editing.value = row
  rating.value = row.myRating ?? 0
  content.value = row.myContent ?? ''
  anonymous.value = false
  dialogOpen.value = true
}

function closeDialog() {
  dialogOpen.value = false
  editing.value = null
}

async function submit() {
  if (!editing.value || rating.value <= 0) {
    return
  }
  submitting.value = true
  try {
    await reviewApi.dialogSubmit({
      dishId: editing.value.dishId,
      orderId: editing.value.orderId,
      rating: rating.value,
      content: content.value.trim() || undefined,
      anonymous: anonymous.value
    })
    toast.success('评价已提交', editing.value.dishName)
    closeDialog()
    await load()
    tab.value = 'done'
  } catch (e) {
    toast.error('提交失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    submitting.value = false
  }
}

function switchTab(next: 'pending' | 'done') {
  tab.value = next
}

watch(
  () => props.active,
  (v) => {
    if (v) {
      void load()
    }
  },
  { immediate: true }
)

defineExpose({ reload: load })
</script>

<template>
  <div class="review-center">
    <!-- 顶部：头像 + 统计 -->
    <header class="rc-head">
      <span class="rc-avatar">{{ auth.initial }}</span>
      <div class="rc-head__info">
        <p class="rc-head__name">{{ auth.displayName }}</p>
        <p class="rc-head__meta">
          评价数 <strong class="num">{{ doneCount }}</strong>
          <span class="rc-head__sep">|</span>
          购买记录 <strong class="num">{{ totalCount }}</strong>
          <template v-if="avgRating > 0">
            <span class="rc-head__sep">|</span>
            均分 <strong class="num">{{ avgRating.toFixed(1) }}</strong>
          </template>
        </p>
      </div>
    </header>

    <!-- Tab -->
    <div class="rc-tabs">
      <button
        class="rc-tab"
        :class="{ 'rc-tab--active': tab === 'pending' }"
        type="button"
        @click="switchTab('pending')"
      >
        待评价
        <span class="rc-tab__num num">{{ pendingRows.length }}</span>
      </button>
      <button
        class="rc-tab"
        :class="{ 'rc-tab--active': tab === 'done' }"
        type="button"
        @click="switchTab('done')"
      >
        已评价
        <span class="rc-tab__num num">{{ doneRows.length }}</span>
      </button>
    </div>

    <!-- 列表 -->
    <div v-if="loading" class="rc-list">
      <div v-for="i in 3" :key="i" class="skeleton" style="height: 86px; border-radius: 14px"></div>
    </div>

    <div v-else-if="listRows.length === 0" class="rc-empty">
      <span class="rc-empty__art"><AppIcon name="star" :size="24" /></span>
      <p class="rc-empty__title">
        {{ tab === 'pending' ? '没有待评价的菜品' : '还没有评价记录' }}
      </p>
      <p class="rc-empty__desc">
        {{ tab === 'pending' ? '下单并完成用餐后，就可以在这里评价啦' : '去「待评价」给吃过的菜打个分吧' }}
      </p>
    </div>

    <ul v-else class="rc-list">
      <li v-for="row in listRows" :key="`${row.orderId}-${row.dishId}`" class="rc-item">
        <img class="rc-item__img" :src="row.imageUrl || '/assets/images/dishes/dish-placeholder.webp'" :alt="row.dishName" />
        <div class="rc-item__body">
          <p class="rc-item__name">{{ row.dishName }}</p>
          <p class="rc-item__meta">
            <span class="num">¥{{ formatMoney(row.unitPrice) }}</span>
            <span class="rc-item__dot">·</span>
            <span>{{ row.quantity }} 份</span>
            <span class="rc-item__dot">·</span>
            <span class="num">{{ row.orderNo }}</span>
          </p>
          <p class="rc-item__time">{{ formatDateTime(row.orderCreatedAt) }}</p>
          <div v-if="row.reviewed" class="rc-item__mine">
            <StarRating :model-value="Number(row.myRating ?? 0)" :size="11" />
            <span v-if="row.myContent" class="rc-item__mytext">{{ row.myContent }}</span>
            <span v-else class="rc-item__mytext rc-item__mytext--empty">只打了分</span>
          </div>
        </div>
        <button
          class="btn btn--sm rc-item__btn"
          :class="row.reviewed ? 'btn--ghost' : 'btn--primary'"
          type="button"
          @click="openDialog(row)"
        >
          {{ row.reviewed ? '修改' : '去评价' }}
        </button>
      </li>
    </ul>

    <!-- 评价弹窗 -->
    <Transition name="fade">
      <div v-if="dialogOpen && editing" class="rc-mask" @click.self="closeDialog">
        <div class="rc-dialog">
          <header class="rc-dialog__head">
            <h3 class="rc-dialog__title">评价「{{ editing.dishName }}」</h3>
            <button class="rc-dialog__close" type="button" aria-label="关闭" @click="closeDialog">
              <AppIcon name="close" :size="16" />
            </button>
          </header>
          <div class="rc-dialog__body">
            <div class="rc-dialog__stars">
              <span class="rc-dialog__label">评分</span>
              <StarRating v-model="rating" :size="22" editable />
            </div>
            <textarea
              v-model="content"
              class="input rc-dialog__input"
              rows="3"
              maxlength="500"
              placeholder="这道菜怎么样？味道、分量、温度都可以说说（可选）"
            ></textarea>
            <label class="rc-dialog__anon">
              <input v-model="anonymous" type="checkbox" />
              匿名评价
            </label>
          </div>
          <footer class="rc-dialog__foot">
            <button class="btn btn--ghost btn--sm" type="button" @click="closeDialog">取消</button>
            <button
              class="btn btn--primary btn--sm"
              type="button"
              :disabled="rating <= 0 || submitting"
              @click="submit"
            >
              {{ submitting ? '提交中…' : '提交评价' }}
            </button>
          </footer>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.review-center {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.rc-head {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-md);
  background: linear-gradient(135deg, rgba(232, 238, 221, 0.7), rgba(253, 248, 239, 0.8));
  border: 1px solid rgba(124, 143, 90, 0.14);
}

.rc-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  flex: none;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--apricot-100), var(--sage-200));
  color: var(--sage-800);
  font-size: var(--font-md);
  font-weight: 700;
}

.rc-head__info {
  flex: 1;
  min-width: 0;
}

.rc-head__name {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-900);
}

.rc-head__meta {
  font-size: 10.5px;
  color: var(--ink-500);
  margin-top: 2px;
}

.rc-head__meta strong {
  color: var(--sage-700);
  font-weight: 700;
}

.rc-head__sep {
  margin: 0 5px;
  color: var(--ink-300);
}

.rc-tabs {
  display: flex;
  gap: 4px;
  padding: 3px;
  border-radius: var(--radius-pill);
  background: rgba(232, 238, 221, 0.6);
}

.rc-tab {
  flex: 1;
  height: 30px;
  border-radius: var(--radius-pill);
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--ink-600);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.rc-tab--active {
  background: #fff;
  color: var(--sage-700);
  box-shadow: var(--shadow-xs);
}

.rc-tab__num {
  font-size: 10px;
  opacity: 0.75;
}

.rc-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.rc-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 11px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.76);
  border: 1px solid rgba(124, 143, 90, 0.1);
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.rc-item:hover {
  background: #fff;
}

.rc-item__img {
  width: 54px;
  height: 54px;
  flex: none;
  border-radius: var(--radius-sm);
  object-fit: cover;
}

.rc-item__body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.rc-item__name {
  font-size: var(--font-sm);
  font-weight: 600;
  color: var(--ink-900);
}

.rc-item__meta {
  font-size: 10px;
  color: var(--ink-500);
}

.rc-item__dot {
  margin: 0 3px;
  color: var(--ink-300);
}

.rc-item__time {
  font-size: 9.5px;
  color: var(--ink-400);
}

.rc-item__mine {
  display: flex;
  align-items: center;
  gap: 5px;
  margin-top: 2px;
  flex-wrap: wrap;
}

.rc-item__mytext {
  font-size: 10px;
  color: var(--ink-600);
}

.rc-item__mytext--empty {
  color: var(--ink-300);
  font-style: italic;
}

.rc-item__btn {
  flex: none;
}

.rc-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 5px;
  padding: var(--space-8) var(--space-4);
  text-align: center;
  color: var(--ink-400);
}

.rc-empty__art {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 54px;
  height: 54px;
  border-radius: 50%;
  background: var(--sage-50);
  color: var(--sage-400);
}

.rc-empty__title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-700);
}

.rc-empty__desc {
  font-size: var(--font-xs);
  max-width: 260px;
  line-height: 1.6;
}

/* 弹窗 */
.rc-mask {
  position: fixed;
  inset: 0;
  z-index: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-5);
  background: rgba(48, 44, 36, 0.44);
  backdrop-filter: blur(6px);
}

.rc-dialog {
  width: min(420px, 94vw);
  border-radius: var(--radius-xl);
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  overflow: hidden;
}

.rc-dialog__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  padding: var(--space-4);
  border-bottom: 1px solid rgba(124, 143, 90, 0.12);
}

.rc-dialog__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.rc-dialog__close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  color: var(--ink-500);
  background: rgba(255, 255, 255, 0.8);
}

.rc-dialog__body {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  padding: var(--space-4);
}

.rc-dialog__stars {
  display: flex;
  align-items: center;
  gap: 10px;
}

.rc-dialog__label {
  font-size: var(--font-xs);
  color: var(--ink-500);
}

.rc-dialog__input {
  font-size: var(--font-xs);
  resize: vertical;
}

.rc-dialog__anon {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  font-size: 10.5px;
  color: var(--ink-500);
  cursor: pointer;
}

.rc-dialog__foot {
  display: flex;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4) var(--space-4);
}

.rc-dialog__foot .btn {
  flex: 1;
}
</style>
