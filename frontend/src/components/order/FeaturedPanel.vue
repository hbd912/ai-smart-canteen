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
import PublishWorkDialog from '@/components/order/PublishWorkDialog.vue'
import { orderApi, workApi } from '@/api/modules'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'
import { formatDateTime, formatMoney } from '@/utils/format'
import type { Order } from '@/types/api'

const props = defineProps<{ active: boolean }>()
const emit = defineEmits<{ (e: 'order-dish', dishId: number): void }>()

const auth = useAuthStore()
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
  dishId?: number | null
  dishName?: string | null
  dishPrice?: number | null
  orderId?: number | null
  orderNo?: string | null
  orderCreatedAt?: string | null
  orderTotalAmount?: number | null
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
/** 发布作品弹窗 */
const publishOpen = ref(false)
const loading = ref(false)
const works = ref<Work[]>([])
const sort = ref<'hot' | 'latest'>('hot')
const detailOpen = ref(false)
const activeWork = ref<Work | null>(null)
const commentText = ref('')
const submitting = ref(false)

/** 作品图片轮播 */
const imageIndex = ref(0)
const activeImages = computed(() => {
  const images = activeWork.value?.images ?? []
  return images.length > 0 ? images : ['/assets/images/dishes/dish-placeholder.webp']
})
const currentImage = computed(() => activeImages.value[imageIndex.value] ?? activeImages.value[0])
const isAuthor = computed(() => activeWork.value?.userId === auth.user?.id)

/** 关联订单详情 */
const orderOpen = ref(false)
const orderLoading = ref(false)
const orderDetail = ref<Order | null>(null)

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

async function onPublished() {
  publishOpen.value = false
  sort.value = 'latest'
  await load()
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
  imageIndex.value = 0
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
  imageIndex.value = 0
  closeOrder()
}

function prevImage() {
  const total = activeImages.value.length
  imageIndex.value = (imageIndex.value - 1 + total) % total
}

function nextImage() {
  const total = activeImages.value.length
  imageIndex.value = (imageIndex.value + 1) % total
}

function selectImage(index: number) {
  imageIndex.value = index
}

/** 打开关联订单：作者本人可看完整明细，其他访客只看订单凭证快照 */
async function openOrder(work: Work) {
  if (!work.orderId) {
    return
  }
  orderOpen.value = true
  orderDetail.value = null
  if (work.userId !== auth.user?.id) {
    return
  }
  orderLoading.value = true
  try {
    orderDetail.value = await orderApi.detail(work.orderId)
  } catch (e) {
    toast.error('订单加载失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    orderLoading.value = false
  }
}

function closeOrder() {
  orderOpen.value = false
  orderDetail.value = null
  orderLoading.value = false
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
  if (!work.dishId) {
    return
  }
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
          v-if="viewMode === 'featured'"
          class="btn btn--primary btn--sm featured__review-btn"
          type="button"
          @click="publishOpen = true"
        >
          <AppIcon name="plus" :size="13" />
          发布作品
        </button>
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
      <p class="panel-empty__desc">来做第一个分享用餐记录的人吧</p>
      <button class="btn btn--primary btn--sm" type="button" @click="publishOpen = true">
        发布作品
      </button>
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
              <span class="work-card__dish">{{ w.dishName || '图文分享' }}</span>
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
              <span class="work-card__dish">{{ w.dishName || '图文分享' }}</span>
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
            <img :src="currentImage" :alt="activeWork.title" />
            <template v-if="activeImages.length > 1">
              <button class="wd__img-nav wd__img-nav--prev" type="button" aria-label="上一张" @click.stop="prevImage">
                <AppIcon name="chevron-left" :size="18" />
              </button>
              <button class="wd__img-nav wd__img-nav--next" type="button" aria-label="下一张" @click.stop="nextImage">
                <AppIcon name="chevron-right" :size="18" />
              </button>
              <span class="wd__img-count num">{{ imageIndex + 1 }} / {{ activeImages.length }}</span>
              <div class="wd__thumbs">
                <button
                  v-for="(img, idx) in activeImages"
                  :key="`${img}-${idx}`"
                  class="wd__thumb"
                  :class="{ 'wd__thumb--active': idx === imageIndex }"
                  type="button"
                  :aria-label="`查看第 ${idx + 1} 张图片`"
                  @click.stop="selectImage(idx)"
                >
                  <img :src="img" :alt="`图片 ${idx + 1}`" />
                </button>
              </div>
            </template>
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

            <!-- 关联历史订单：展示订单凭证；作者本人可查看完整订单 -->
            <button v-if="activeWork.orderId" class="wd__order" type="button" @click="openOrder(activeWork)">
              <span class="wd__order-icon"><AppIcon name="clipboard-list" :size="16" /></span>
              <span class="wd__order-info">
                <span class="wd__order-label">来自历史订单</span>
                <span class="wd__order-no num">{{ activeWork.orderNo || `#${activeWork.orderId}` }}</span>
                <span class="wd__order-meta">
                  {{ formatDateTime(activeWork.orderCreatedAt ?? '') }}
                  <template v-if="activeWork.orderTotalAmount != null">
                    · ¥{{ formatMoney(activeWork.orderTotalAmount) }}
                  </template>
                </span>
              </span>
              <span class="wd__order-go">
                {{ isAuthor ? '查看订单' : '凭证' }}
                <AppIcon name="chevron-right" :size="13" />
              </span>
            </button>

            <!-- 关联菜品：点击跳转点餐下单 -->
            <button v-if="activeWork.dishId" class="wd__dish" type="button" @click="goDish(activeWork)">
              <div class="wd__dish-info">
                <span class="wd__dish-label">提到的菜品</span>
                <span class="wd__dish-name">{{ activeWork.dishName || '关联菜品' }}</span>
                <span v-if="activeWork.dishPrice != null" class="wd__dish-price num">
                  ¥{{ formatMoney(activeWork.dishPrice) }}
                </span>
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

    <!-- 关联订单详情 -->
    <Transition name="fade">
      <div v-if="orderOpen && activeWork" class="od-mask" @click.self="closeOrder">
        <div class="od">
          <header class="od__head">
            <div>
              <h3 class="od__title">订单详情</h3>
              <p class="od__sub num">{{ activeWork.orderNo || `#${activeWork.orderId}` }}</p>
            </div>
            <button class="od__close" type="button" aria-label="关闭" @click="closeOrder">
              <AppIcon name="close" :size="16" />
            </button>
          </header>

          <div class="od__body scroll-y">
            <div v-if="orderLoading" class="od__loading">
              <span class="skeleton" style="height: 42px; border-radius: 10px"></span>
              <span class="skeleton" style="height: 120px; border-radius: 10px"></span>
            </div>

            <template v-else-if="orderDetail">
              <div class="od__summary">
                <span class="od__pill">{{ orderDetail.orderStatusLabel || orderDetail.orderStatus }}</span>
                <span class="od__time">{{ formatDateTime(orderDetail.createdAt) }}</span>
              </div>
              <ul class="od__items">
                <li v-for="item in orderDetail.items ?? []" :key="item.id" class="od__item">
                  <img
                    class="od__item-img"
                    :src="item.imageUrl || '/assets/images/dishes/dish-placeholder.webp'"
                    :alt="item.dishName"
                  />
                  <div class="od__item-body">
                    <span class="od__item-name">{{ item.dishName }}</span>
                    <span class="od__item-meta num">
                      ¥{{ formatMoney(item.unitPrice) }} × {{ item.quantity }}
                    </span>
                  </div>
                  <span class="od__item-sub num">¥{{ formatMoney(item.subtotal) }}</span>
                </li>
              </ul>
              <div class="od__total">
                <span>合计</span>
                <strong class="num">¥{{ formatMoney(orderDetail.totalAmount) }}</strong>
              </div>
            </template>

            <template v-else>
              <div class="od__snapshot">
                <p class="od__snapshot-title">作者的历史订单</p>
                <p class="od__snapshot-line">
                  <span>订单号</span><span class="num">{{ activeWork.orderNo || `#${activeWork.orderId}` }}</span>
                </p>
                <p class="od__snapshot-line">
                  <span>下单时间</span><span>{{ formatDateTime(activeWork.orderCreatedAt ?? '') }}</span>
                </p>
                <p v-if="activeWork.orderTotalAmount != null" class="od__snapshot-line">
                  <span>订单金额</span><span class="num">¥{{ formatMoney(activeWork.orderTotalAmount) }}</span>
                </p>
                <p class="od__snapshot-note">完整订单明细仅作者本人可查看。</p>
              </div>
            </template>
          </div>
        </div>
      </div>
    </Transition>

    <!-- 发布作品弹窗 -->
    <PublishWorkDialog
      :open="publishOpen"
      @close="publishOpen = false"
      @published="onPublished"
    />
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
  position: relative;
  background: var(--cream-200);
  overflow: hidden;
}

.wd__media > img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  display: block;
}

.wd__img-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: rgba(44, 42, 38, 0.52);
  color: #fff;
  backdrop-filter: blur(4px);
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.wd__img-nav:hover {
  background: rgba(44, 42, 38, 0.75);
}

.wd__img-nav--prev {
  left: 10px;
}

.wd__img-nav--next {
  right: 10px;
}

.wd__img-count {
  position: absolute;
  top: 10px;
  right: 10px;
  padding: 2px 8px;
  border-radius: var(--radius-pill);
  background: rgba(44, 42, 38, 0.58);
  color: #fff;
  font-size: 10px;
}

.wd__thumbs {
  position: absolute;
  left: 10px;
  right: 10px;
  bottom: 10px;
  display: flex;
  gap: 6px;
  padding: 5px;
  border-radius: var(--radius-sm);
  background: rgba(44, 42, 38, 0.38);
  backdrop-filter: blur(4px);
  overflow-x: auto;
}

.wd__thumb {
  width: 44px;
  height: 44px;
  flex: none;
  border-radius: var(--radius-xs);
  overflow: hidden;
  border: 2px solid transparent;
  opacity: 0.7;
  transition: opacity var(--motion-fast) var(--ease-standard),
    border-color var(--motion-fast) var(--ease-standard);
}

.wd__thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.wd__thumb:hover,
.wd__thumb--active {
  opacity: 1;
  border-color: #fff;
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

/* 关联订单卡片 */
.wd__order {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-radius: var(--radius-md);
  background: rgba(255, 250, 238, 0.9);
  border: 1px dashed rgba(196, 154, 82, 0.5);
  text-align: left;
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.wd__order:hover {
  background: rgba(255, 246, 224, 1);
}

.wd__order-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  flex: none;
  border-radius: 50%;
  background: rgba(196, 154, 82, 0.16);
  color: var(--amber-700);
}

.wd__order-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.wd__order-label {
  font-size: 9.5px;
  color: var(--ink-500);
}

.wd__order-no {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-900);
}

.wd__order-meta {
  font-size: 9.5px;
  color: var(--ink-400);
}

.wd__order-go {
  display: inline-flex;
  align-items: center;
  gap: 2px;
  font-size: 10.5px;
  font-weight: 700;
  color: var(--amber-700);
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

/* 关联订单详情弹窗 */
.od-mask {
  position: fixed;
  inset: 0;
  z-index: 640;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-5);
  background: rgba(48, 44, 36, 0.5);
  backdrop-filter: blur(6px);
}

.od {
  display: flex;
  flex-direction: column;
  width: min(460px, 94vw);
  max-height: 82vh;
  border-radius: var(--radius-2xl);
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  overflow: hidden;
}

.od__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 10px;
  padding: var(--space-4) var(--space-5);
  border-bottom: 1px solid rgba(124, 143, 90, 0.12);
}

.od__title {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--ink-900);
}

.od__sub {
  margin-top: 2px;
  font-size: 10.5px;
  color: var(--ink-400);
}

.od__close {
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

.od__body {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.od__loading {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.od__summary {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.od__pill {
  padding: 2px 9px;
  border-radius: var(--radius-pill);
  background: var(--sage-100);
  color: var(--sage-700);
  font-size: 10px;
  font-weight: 700;
}

.od__time {
  font-size: 10px;
  color: var(--ink-400);
}

.od__items {
  display: flex;
  flex-direction: column;
  gap: 7px;
}

.od__item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 7px 8px;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.72);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.od__item-img {
  width: 40px;
  height: 40px;
  flex: none;
  border-radius: var(--radius-xs);
  object-fit: cover;
}

.od__item-body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.od__item-name {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--ink-900);
}

.od__item-meta {
  font-size: 10px;
  color: var(--ink-500);
}

.od__item-sub {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--amber-600);
  flex: none;
}

.od__total {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: var(--space-3);
  border-top: 1px dashed rgba(124, 143, 90, 0.26);
  font-size: var(--font-sm);
  color: var(--ink-600);
}

.od__total strong {
  font-size: var(--font-lg);
  color: var(--amber-600);
}

.od__snapshot {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: var(--space-4);
  border-radius: var(--radius-md);
  background: rgba(255, 250, 238, 0.9);
  border: 1px dashed rgba(196, 154, 82, 0.4);
}

.od__snapshot-title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-900);
}

.od__snapshot-line {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  font-size: var(--font-xs);
  color: var(--ink-500);
}

.od__snapshot-line span:last-child {
  color: var(--ink-800);
  font-weight: 600;
}

.od__snapshot-note {
  font-size: 10px;
  color: var(--ink-400);
  line-height: 1.6;
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
