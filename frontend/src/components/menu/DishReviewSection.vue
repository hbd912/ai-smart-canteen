<script setup lang="ts">
/**
 * 菜品评价区：评分汇总 + 星级分布 + 评价列表 + 提交评价。
 * 参考项目 DishDetail 的评价模块，按本项目视觉体系实现。
 */
import { computed, ref, watch } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import StarRating from '@/components/menu/StarRating.vue'
import { reviewApi } from '@/api/modules'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'
import { formatDateTime } from '@/utils/format'
import type { DishRatingSummary, DishReview } from '@/types/api'

const props = defineProps<{
  dishId: number | null
}>()

const auth = useAuthStore()
const toast = useToastStore()

const loading = ref(false)
const submitting = ref(false)
const summary = ref<DishRatingSummary | null>(null)
const reviews = ref<DishReview[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = 6

const myRating = ref(0)
const myContent = ref('')
const anonymous = ref(false)

const distribution = computed(() => {
  const s = summary.value
  if (!s) {
    return []
  }
  const rows = [
    { star: 5, count: s.star5 },
    { star: 4, count: s.star4 },
    { star: 3, count: s.star3 },
    { star: 2, count: s.star2 },
    { star: 1, count: s.star1 }
  ]
  const max = Math.max(...rows.map((r) => r.count), 1)
  return rows.map((r) => ({ ...r, pct: Math.round((r.count / s.reviewCount) * 100), bar: (r.count / max) * 100 }))
})

const canSubmit = computed(() => myRating.value > 0 && !submitting.value)
const totalPages = computed(() => Math.max(Math.ceil(total.value / pageSize), 1))

async function loadSummary() {
  if (!props.dishId) {
    return
  }
  try {
    summary.value = await reviewApi.summary(props.dishId)
    // 已评价过则回填自己的评分
    const mine = summary.value.recentReviews?.find(
      (r) => r.userId != null && r.userId === auth.user?.id
    )
    if (mine) {
      myRating.value = mine.rating
      myContent.value = mine.content ?? ''
      anonymous.value = mine.anonymous
    }
  } catch {
    summary.value = null
  }
}

async function loadList() {
  if (!props.dishId) {
    return
  }
  loading.value = true
  try {
    const res = await reviewApi.list(props.dishId, page.value, pageSize)
    reviews.value = res.records
    total.value = res.total
  } catch {
    reviews.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

async function reload() {
  await Promise.all([loadSummary(), loadList()])
}

function changePage(next: number) {
  if (next < 1 || next > totalPages.value) {
    return
  }
  page.value = next
  loadList()
}

async function submit() {
  if (!props.dishId || !canSubmit.value) {
    return
  }
  if (!auth.isLoggedIn) {
    toast.warning('请先登录', '登录后即可评价')
    return
  }
  submitting.value = true
  try {
    await reviewApi.submit({
      dishId: props.dishId,
      rating: myRating.value,
      content: myContent.value.trim() || undefined,
      anonymous: anonymous.value
    })
    toast.success('评价已提交', '感谢你的反馈')
    myContent.value = ''
    page.value = 1
    await reload()
  } catch (e) {
    toast.error('提交失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    submitting.value = false
  }
}

watch(
  () => props.dishId,
  (id) => {
    myRating.value = 0
    myContent.value = ''
    anonymous.value = false
    page.value = 1
    if (id) {
      void reload()
    } else {
      summary.value = null
      reviews.value = []
      total.value = 0
    }
  },
  { immediate: true }
)

defineExpose({ reload })
</script>

<template>
  <section v-if="dishId" class="review-section">
    <h3 class="review-section__title">
      <AppIcon name="star" :size="14" />
      用户评价
      <span v-if="summary && summary.reviewCount > 0" class="review-section__count num">
        {{ summary.reviewCount }} 条
      </span>
    </h3>

    <!-- 评分汇总 -->
    <div v-if="summary && summary.reviewCount > 0" class="rating-board">
      <div class="rating-board__score">
        <span class="rating-board__value num">{{ Number(summary.avgRating).toFixed(1) }}</span>
        <StarRating :model-value="summary.avgRating" :size="13" />
        <span class="rating-board__good">好评率 {{ summary.goodRate }}%</span>
      </div>
      <div class="rating-board__bars">
        <div v-for="row in distribution" :key="row.star" class="rating-bar">
          <span class="rating-bar__star">{{ row.star }}星</span>
          <span class="rating-bar__track">
            <span class="rating-bar__fill" :style="{ width: `${row.bar}%` }"></span>
          </span>
          <span class="rating-bar__pct num">{{ row.pct }}%</span>
        </div>
      </div>
    </div>

    <div v-else class="review-empty">
      <AppIcon name="star" :size="20" />
      <p>还没有评价，来做第一个评价的人吧</p>
    </div>

    <!-- 发表评价 -->
    <div class="review-form">
      <div class="review-form__row">
        <span class="review-form__label">我的评分</span>
        <StarRating v-model="myRating" :size="18" editable />
      </div>
      <textarea
        v-model="myContent"
        class="input review-form__input"
        rows="2"
        maxlength="500"
        placeholder="这一餐怎么样？味道、分量、温度都可以说说（可选）"
      ></textarea>
      <div class="review-form__foot">
        <label class="review-form__anon">
          <input v-model="anonymous" type="checkbox" />
          匿名评价
        </label>
        <button class="btn btn--primary btn--sm" type="button" :disabled="!canSubmit" @click="submit">
          {{ submitting ? '提交中…' : '发表评价' }}
        </button>
      </div>
    </div>

    <!-- 评价列表 -->
    <div v-if="loading" class="skeleton" style="height: 80px; border-radius: 12px"></div>
    <ul v-else-if="reviews.length > 0" class="review-list">
      <li v-for="r in reviews" :key="r.id" class="review-item">
        <span class="review-item__avatar">{{ r.authorInitial }}</span>
        <div class="review-item__body">
          <div class="review-item__head">
            <span class="review-item__name">{{ r.authorNickname }}</span>
            <StarRating :model-value="r.rating" :size="11" />
            <span class="review-item__time">{{ formatDateTime(r.createdAt) }}</span>
          </div>
          <p v-if="r.content" class="review-item__content">{{ r.content }}</p>
          <p v-else class="review-item__content review-item__content--empty">该用户只打了分</p>
        </div>
      </li>
    </ul>

    <div v-if="totalPages > 1" class="review-pager">
      <button class="btn btn--ghost btn--sm" type="button" :disabled="page <= 1" @click="changePage(page - 1)">
        上一页
      </button>
      <span class="review-pager__info num">{{ page }} / {{ totalPages }}</span>
      <button class="btn btn--ghost btn--sm" type="button" :disabled="page >= totalPages" @click="changePage(page + 1)">
        下一页
      </button>
    </div>
  </section>
</template>

<style scoped>
.review-section {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  padding-top: var(--space-3);
  border-top: 1px solid rgba(124, 143, 90, 0.14);
}

.review-section__title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-800);
}

.review-section__count {
  font-size: 10.5px;
  font-weight: 500;
  color: var(--ink-400);
}

/* 评分汇总面板 */
.rating-board {
  display: flex;
  align-items: center;
  gap: var(--space-4);
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-md);
  background: rgba(253, 248, 239, 0.72);
  border: 1px solid rgba(217, 143, 56, 0.16);
  flex-wrap: wrap;
}

.rating-board__score {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  min-width: 78px;
}

.rating-board__value {
  font-size: var(--font-2xl);
  font-weight: 700;
  line-height: 1;
  color: var(--amber-600);
}

.rating-board__good {
  font-size: 10px;
  color: var(--ink-500);
}

.rating-board__bars {
  flex: 1;
  min-width: 160px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.rating-bar {
  display: grid;
  grid-template-columns: 26px 1fr 32px;
  align-items: center;
  gap: 6px;
  font-size: 10px;
  color: var(--ink-500);
}

.rating-bar__track {
  height: 5px;
  border-radius: var(--radius-pill);
  background: rgba(217, 143, 56, 0.14);
  overflow: hidden;
}

.rating-bar__fill {
  display: block;
  height: 100%;
  border-radius: var(--radius-pill);
  background: linear-gradient(90deg, var(--amber-400, #f0b45c), var(--amber-500));
  transition: width var(--motion-linger) var(--ease-enter);
}

.rating-bar__pct {
  text-align: right;
}

/* 发表评价 */
.review-form {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  padding: var(--space-3);
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(124, 143, 90, 0.14);
}

.review-form__row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.review-form__label {
  font-size: 10.5px;
  color: var(--ink-500);
}

.review-form__input {
  font-size: var(--font-xs);
  resize: vertical;
  min-height: 52px;
}

.review-form__foot {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.review-form__anon {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 10.5px;
  color: var(--ink-500);
  cursor: pointer;
}

/* 评价列表 */
.review-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.review-item {
  display: flex;
  gap: 8px;
}

.review-item__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 26px;
  flex: none;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--apricot-100), var(--sage-200));
  color: var(--sage-800);
  font-size: 10.5px;
  font-weight: 700;
}

.review-item__body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.review-item__head {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}

.review-item__name {
  font-size: 10.5px;
  font-weight: 600;
  color: var(--ink-700);
}

.review-item__time {
  font-size: 9.5px;
  color: var(--ink-300);
}

.review-item__content {
  font-size: var(--font-xs);
  color: var(--ink-600);
  line-height: 1.55;
  word-break: break-word;
}

.review-item__content--empty {
  color: var(--ink-300);
  font-style: italic;
}

.review-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  padding: var(--space-4);
  color: var(--ink-400);
  font-size: var(--font-xs);
  text-align: center;
}

.review-pager {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.review-pager__info {
  font-size: 10.5px;
  color: var(--ink-500);
}
</style>
