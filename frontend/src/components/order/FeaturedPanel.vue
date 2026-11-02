<script setup lang="ts">
/**
 * 精选作品流：用户发布菜品实拍 + 评价。
 *
 * 布局参考抖音的信息结构（双列卡片 + 悬浮信息），配色沿用本项目视觉体系。
 * 点开作品可看：作者评价、关联菜品（点击跳转点餐下单）、评论列表。
 */
import { computed, ref, watch } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import ReviewCenter from '@/components/order/ReviewCenter.vue'
import { workApi } from '@/api/modules'
import { useToastStore } from '@/stores/toast'
import { formatDateTime, formatMoney } from '@/utils/format'

const props = defineProps<{ active: boolean }>()
const emit = defineEmits<{ (e: 'order-dish', dishId: number): void }>()

const toast = useToastStore()

interface WorkComment {
  id: number
  authorNickname: string
  authorInitial: string
  content: string
  createdAt: string
}

interface Work {
  id: number
  userId: number
  authorNickname: string
  authorInitial: string
  dishId: number
  dishName: string
  dishPrice: number
  title: string
  content: string
  images: string[]
  likeCount: number
  commentCount: number
  liked: boolean
  createdAt: string
  comments?: WorkComment[]
}

/** 视图模式：featured = 精选作品流，review = 评价中心 */
const viewMode = ref<'featured' | 'review'>('featured')
const loading = ref(false)
const works = ref<Work[]>([])
const sort = ref<'hot' | 'latest'>('hot')
const detailOpen = ref(false)
const activeWork = ref<Work | null>(null)
const commentText = ref('')
const submitting = ref(false)

const leftColumn = computed(() => works.value.filter((_, i) => i % 2 === 0))
const rightColumn = computed(() => works.value.filter((_, i) => i % 2 === 1))

async function load() {
  loading.value = true
  try {
    works.value = (await workApi.feed(sort.value)) as unknown as Work[]
  } catch {
    works.value = []
  } finally {
    loading.value = false
  }
}

function switchSort(next: 'hot' | 'latest') {
  if (sort.value === next) {
    return
  }
  sort.value = next
  void load()
}

async function openDetail(work: Work) {
  activeWork.value = work
  detailOpen.value = true
  try {
    const full = (await workApi.detail(work.id)) as unknown as Work
    activeWork.value = full
  } catch {
    /* 保底使用列表数据 */
  }
}

function closeDetail() {
  detailOpen.value = false
  activeWork.value = null
  commentText.value = ''
}

async function toggleLike(work: Work, event?: Event) {
  event?.stopPropagation()
  try {
    const r = await workApi.toggleLike(work.id)
    work.liked = r.liked
    work.likeCount = r.liked ? work.likeCount + 1 : Math.max(0, work.likeCount - 1)
    if (activeWork.value?.id === work.id) {
      activeWork.value = { ...activeWork.value, liked: work.liked, likeCount: work.likeCount }
    }
  } catch (e) {
    toast.error('操作失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

async function submitComment() {
  const text = commentText.value.trim()
  if (!text || !activeWork.value || submitting.value) {
    return
  }
  submitting.value = true
  try {
    const c = (await workApi.addComment(activeWork.value.id, text)) as unknown as WorkComment
    activeWork.value = {
      ...activeWork.value,
      comments: [...(activeWork.value.comments ?? []), c],
      commentCount: activeWork.value.commentCount + 1
    }
    const target = works.value.find((w) => w.id === activeWork.value?.id)
    if (target) {
      target.commentCount += 1
    }
    commentText.value = ''
    toast.success('评论已发表')
  } catch (e) {
    toast.error('评论失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    submitting.value = false
  }
}

/** 跳转点餐页并定位到该菜品 */
function goDish(work: Work) {
  closeDetail()
  emit('order-dish', work.dishId)
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
  <div class="featured">
    <header class="featured__head">
      <div>
        <h2 class="section-title">
          <span class="section-title__icon"><AppIcon name="star" :size="15" /></span>
          精选
        </h2>
        <p class="section-subtitle">同学们分享的真实用餐记录，点开可以看评价和下单</p>
      </div>
      <div class="featured__head-right">
        <button
          class="btn btn--sm featured__review-btn"
          :class="viewMode === 'review' ? 'btn--primary' : 'btn--ghost'"
          type="button"
          @click="viewMode = viewMode === 'featured' ? 'review' : 'featured'"
        >
          <AppIcon name="star" :size="13" />
          {{ viewMode === 'review' ? '返回精选' : '评价中心' }}
        </button>
        <div v-if="viewMode === 'featured'" class="seg-control">
          <button
            class="seg-control__btn"
            :class="{ 'seg-control__btn--active': sort === 'hot' }"
            type="button"
            @click="switchSort('hot')"
          >
            最热
          </button>
          <button
            class="seg-control__btn"
            :class="{ 'seg-control__btn--active': sort === 'latest' }"
            type="button"
            @click="switchSort('latest')"
          >
            最新
          </button>
        </div>
      </div>
    </header>

    <!-- 评价中心 -->
    <ReviewCenter v-if="viewMode === 'review'" :active="viewMode === 'review'" />

    <!-- 精选作品流 -->
    <template v-else>

    <div v-if="loading" class="featured__cols">
      <div class="featured__col">
        <div v-for="i in 2" :key="'l' + i" class="skeleton" style="height: 220px; border-radius: 16px"></div>
      </div>
      <div class="featured__col">
        <div v-for="i in 2" :key="'r' + i" class="skeleton" style="height: 260px; border-radius: 16px"></div>
      </div>
    </div>

    <div v-else-if="works.length === 0" class="panel-empty">
      <span class="panel-empty__art"><AppIcon name="star" :size="30" /></span>
      <p class="panel-empty__title">还没有精选作品</p>
      <p class="panel-empty__desc">同学们发布用餐记录后会展示在这里</p>
    </div>

    <div v-else class="featured__cols scroll-y">
      <div class="featured__col">
        <article
          v-for="w in leftColumn"
          :key="w.id"
          class="work-card"
          tabindex="0"
          @click="openDetail(w)"
          @keydown.enter="openDetail(w)"
        >
          <div class="work-card__media">
            <img :src="w.images[0] || '/assets/images/dishes/dish-placeholder.webp'" :alt="w.title" loading="lazy" />
            <div class="work-card__overlay">
              <span class="work-card__dish">{{ w.dishName }}</span>
              <span class="work-card__likes">
                <button
                  class="work-card__like-btn"
                  :class="{ 'work-card__like-btn--on': w.liked }"
                  type="button"
                  :aria-label="w.liked ? '取消点赞' : '点赞'"
                  @click="toggleLike(w, $event)"
                >
                  <AppIcon name="heart" :size="13" :filled="w.liked" />
                </button>
                <span class="num">{{ w.likeCount }}</span>
              </span>
            </div>
          </div>
          <div class="work-card__body">
            <h3 class="work-card__title clamp-2">{{ w.title }}</h3>
            <p class="work-card__text clamp-2">{{ w.content }}</p>
            <div class="work-card__foot">
              <span class="work-card__author">
                <span class="work-card__avatar">{{ w.authorInitial }}</span>
                <span class="work-card__name text-ellipsis">{{ w.authorNickname }}</span>
              </span>
              <span class="work-card__meta">
                <AppIcon name="info" :size="11" />
                <span class="num">{{ w.commentCount }}</span>
              </span>
            </div>
          </div>
        </article>
      </div>
      <div class="featured__col">
        <article
          v-for="w in rightColumn"
          :key="w.id"
          class="work-card"
          tabindex="0"
          @click="openDetail(w)"
          @keydown.enter="openDetail(w)"
        >
          <div class="work-card__media">
            <img :src="w.images[0] || '/assets/images/dishes/dish-placeholder.webp'" :alt="w.title" loading="lazy" />
            <div class="work-card__overlay">
              <span class="work-card__dish">{{ w.dishName }}</span>
              <span class="work-card__likes">
                <button
                  class="work-card__like-btn"
                  :class="{ 'work-card__like-btn--on': w.liked }"
                  type="button"
                  :aria-label="w.liked ? '取消点赞' : '点赞'"
                  @click="toggleLike(w, $event)"
                >
                  <AppIcon name="heart" :size="13" :filled="w.liked" />
                </button>
                <span class="num">{{ w.likeCount }}</span>
              </span>
            </div>
          </div>
          <div class="work-card__body">
            <h3 class="work-card__title clamp-2">{{ w.title }}</h3>
            <p class="work-card__text clamp-2">{{ w.content }}</p>
            <div class="work-card__foot">
              <span class="work-card__author">
                <span class="work-card__avatar">{{ w.authorInitial }}</span>
                <span class="work-card__name text-ellipsis">{{ w.authorNickname }}</span>
              </span>
              <span class="work-card__meta">
                <AppIcon name="info" :size="11" />
                <span class="num">{{ w.commentCount }}</span>
              </span>
            </div>
          </div>
        </article>
      </div>
    </div>

    </template>

    <!-- 作品详情 -->
    <Transition name="fade">
      <div v-if="detailOpen && activeWork" class="wd-mask" @click.self="closeDetail">
        <div class="wd">
          <div class="wd__media">
            <img :src="activeWork.images[0] || '/assets/images/dishes/dish-placeholder.webp'" :alt="activeWork.title" />
          </div>
          <div class="wd__side scroll-y">
            <header class="wd__head">
              <span class="wd__avatar">{{ activeWork.authorInitial }}</span>
              <div class="wd__author">
                <span class="wd__name">{{ activeWork.authorNickname }}</span>
                <span class="wd__time">{{ formatDateTime(activeWork.createdAt) }}</span>
              </div>
              <button class="wd__close" type="button" aria-label="关闭" @click="closeDetail">
                <AppIcon name="close" :size="16" />
              </button>
            </header>

            <h3 class="wd__title">{{ activeWork.title }}</h3>
            <p class="wd__content">{{ activeWork.content }}</p>

            <!-- 关联菜品：点击跳转点餐下单 -->
            <button class="wd__dish" type="button" @click="goDish(activeWork)">
              <div class="wd__dish-info">
                <span class="wd__dish-label">提到的菜品</span>
                <span class="wd__dish-name">{{ activeWork.dishName }}</span>
                <span class="wd__dish-price num">¥{{ formatMoney(activeWork.dishPrice) }}</span>
              </div>
              <span class="wd__dish-go">去点餐<AppIcon name="chevron-right" :size="13" /></span>
            </button>

            <div class="wd__actions">
              <button
                class="wd__act"
                :class="{ 'wd__act--on': activeWork.liked }"
                type="button"
                @click="toggleLike(activeWork)"
              >
                <AppIcon name="heart" :size="15" :filled="activeWork.liked" />
                {{ activeWork.likeCount }}
              </button>
              <span class="wd__act wd__act--static">
                <AppIcon name="info" :size="15" />
                {{ activeWork.commentCount }}
              </span>
            </div>

            <!-- 评论区 -->
            <section class="wd__comments">
              <h4 class="wd__comments-title">评论 {{ activeWork.comments?.length ?? 0 }}</h4>
              <div class="wd__comment-list scroll-y">
                <div v-if="(activeWork.comments?.length ?? 0) === 0" class="wd__comment-empty">
                  还没有评论，来说两句吧
                </div>
                <div v-for="c in activeWork.comments" :key="c.id" class="wd__comment">
                  <span class="wd__c-avatar">{{ c.authorInitial }}</span>
                  <div class="wd__c-body">
                    <span class="wd__c-name">{{ c.authorNickname }}</span>
                    <p class="wd__c-text">{{ c.content }}</p>
                    <span class="wd__c-time">{{ formatDateTime(c.createdAt) }}</span>
                  </div>
                </div>
              </div>
              <form class="wd__c-form" @submit.prevent="submitComment">
                <input
                  v-model="commentText"
                  class="input wd__c-input"
                  type="text"
                  maxlength="200"
                  placeholder="说点什么…"
                  :disabled="submitting"
                />
                <button class="btn btn--primary btn--sm" type="submit" :disabled="!commentText.trim() || submitting">
                  {{ submitting ? '发表中' : '发表' }}
                </button>
              </form>
            </section>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.featured {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  height: 100%;
}

.featured__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  flex-wrap: wrap;
}

.featured__cols {
  flex: 1;
  min-height: 0;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  overflow-y: auto;
  align-content: start;
  padding-right: 4px;
}

.featured__col {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-width: 0;
}

.work-card {
  display: flex;
  flex-direction: column;
  border-radius: var(--radius-lg);
  background: rgba(255, 253, 248, 0.94);
  border: 1px solid rgba(255, 255, 255, 0.9);
  box-shadow: var(--shadow-xs);
  overflow: hidden;
  cursor: pointer;
  transition: transform var(--motion-normal) var(--ease-standard),
    box-shadow var(--motion-normal) var(--ease-standard);
}

.work-card:hover {
  transform: translateY(-3px);
  box-shadow: var(--shadow-md);
}

.work-card__media {
  position: relative;
  height: 168px;
  overflow: hidden;
  background: var(--cream-200);
}

.work-card__media img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform var(--motion-slow) var(--ease-standard);
}

.work-card:hover .work-card__media img {
  transform: scale(1.04);
}

.work-card__overlay {
  position: absolute;
  inset: auto 0 0 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
  padding: 6px 8px;
  background: linear-gradient(to top, rgba(44, 42, 38, 0.6), transparent);
}

.work-card__dish {
  font-size: 10px;
  color: #fff;
  background: rgba(95, 120, 80, 0.82);
  padding: 2px 7px;
  border-radius: var(--radius-pill);
}

.work-card__likes {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  color: #fff;
  font-size: 10.5px;
}

.work-card__like-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  color: #fff;
  background: rgba(255, 255, 255, 0.18);
  transition: transform var(--motion-fast) var(--ease-standard);
}

.work-card__like-btn:hover {
  transform: scale(1.15);
}

.work-card__like-btn--on {
  color: #ff6b6b;
}

.work-card__body {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 9px 11px 11px;
}

.work-card__title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-900);
  line-height: 1.45;
}

.work-card__text {
  font-size: 10.5px;
  color: var(--ink-500);
  line-height: 1.55;
}

.work-card__foot {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-top: 2px;
}

.work-card__author {
  display: flex;
  align-items: center;
  gap: 5px;
  min-width: 0;
}

.work-card__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  flex: none;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--apricot-100), var(--sage-200));
  color: var(--sage-800);
  font-size: 9.5px;
  font-weight: 700;
}

.work-card__name {
  font-size: 10.5px;
  color: var(--ink-500);
}

.work-card__meta {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  font-size: 10px;
  color: var(--ink-400);
  flex: none;
}

/* 详情 */
.wd-mask {
  position: fixed;
  inset: 0;
  z-index: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-5);
  background: rgba(48, 44, 36, 0.46);
  backdrop-filter: blur(6px);
}

.wd {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 420px);
  width: min(900px, 94vw);
  height: min(82vh, 720px);
  border-radius: var(--radius-2xl);
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  overflow: hidden;
}

.wd__media {
  background: var(--cream-200);
  overflow: hidden;
}

.wd__media img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.wd__side {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  padding: var(--space-4);
  overflow-y: auto;
  min-height: 0;
}

.wd__head {
  display: flex;
  align-items: center;
  gap: 8px;
}

.wd__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  flex: none;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--apricot-100), var(--sage-200));
  color: var(--sage-800);
  font-size: var(--font-sm);
  font-weight: 700;
}

.wd__author {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.wd__name {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-900);
}

.wd__time {
  font-size: 9.5px;
  color: var(--ink-400);
}

.wd__close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  color: var(--ink-500);
  background: rgba(255, 255, 255, 0.8);
  flex: none;
}

.wd__title {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--ink-900);
  line-height: 1.4;
}

.wd__content {
  font-size: var(--font-sm);
  color: var(--ink-600);
  line-height: 1.75;
  white-space: pre-wrap;
}

/* 关联菜品卡片 */
.wd__dish {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 10px 12px;
  border-radius: var(--radius-md);
  background: rgba(232, 238, 221, 0.62);
  border: 1px solid rgba(124, 143, 90, 0.2);
  text-align: left;
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.wd__dish:hover {
  background: rgba(232, 238, 221, 0.9);
}

.wd__dish-info {
  display: flex;
  flex-direction: column;
  gap: 1px;
  min-width: 0;
}

.wd__dish-label {
  font-size: 9.5px;
  color: var(--ink-500);
}

.wd__dish-name {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-900);
}

.wd__dish-price {
  font-size: var(--font-xs);
  color: var(--amber-600);
  font-weight: 700;
}

.wd__dish-go {
  display: inline-flex;
  align-items: center;
  gap: 2px;
  font-size: 10.5px;
  font-weight: 700;
  color: var(--sage-700);
  flex: none;
}

.wd__actions {
  display: flex;
  gap: 8px;
}

.wd__act {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  height: 30px;
  padding: 0 14px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(124, 143, 90, 0.16);
  color: var(--ink-600);
  font-size: var(--font-xs);
  font-weight: 600;
}

.wd__act--on {
  color: #e35d5d;
  border-color: rgba(227, 93, 93, 0.3);
}

.wd__act--static {
  cursor: default;
}

.wd__comments {
  display: flex;
  flex-direction: column;
  gap: 8px;
  border-top: 1px solid rgba(124, 143, 90, 0.14);
  padding-top: var(--space-3);
}

.wd__comments-title {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--ink-700);
}

.wd__comment-list {
  display: flex;
  flex-direction: column;
  gap: 9px;
  max-height: 200px;
  overflow-y: auto;
  padding-right: 4px;
}

.wd__comment-empty {
  padding: var(--space-4);
  text-align: center;
  color: var(--ink-400);
  font-size: 10.5px;
}

.wd__comment {
  display: flex;
  gap: 8px;
}

.wd__c-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  flex: none;
  border-radius: 50%;
  background: var(--sage-100);
  color: var(--sage-700);
  font-size: 10px;
  font-weight: 700;
}

.wd__c-body {
  display: flex;
  flex-direction: column;
  gap: 1px;
  min-width: 0;
}

.wd__c-name {
  font-size: 10.5px;
  font-weight: 600;
  color: var(--ink-700);
}

.wd__c-text {
  font-size: var(--font-xs);
  color: var(--ink-600);
  line-height: 1.55;
  word-break: break-word;
}

.wd__c-time {
  font-size: 9.5px;
  color: var(--ink-300);
}

.wd__c-form {
  display: flex;
  gap: 8px;
}

.wd__c-input {
  flex: 1;
  height: 34px;
  font-size: var(--font-xs);
}

@media (max-width: 900px) {
  .wd {
    grid-template-columns: 1fr;
    height: min(88vh, 760px);
  }

  .wd__media {
    max-height: 200px;
  }
}

.featured__head-right {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.featured__review-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  white-space: nowrap;
}
</style>
