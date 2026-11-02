<script setup lang="ts">
/**
 * 通用菜品卡片：首页推荐 / 菜单网格 / 收藏面板复用。
 * 图片统一裁切比例，加入购物车按钮在数量 > 0 时变为步进器。
 */
import { computed } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { DISH_PLACEHOLDER } from '@/config/media'
import { formatCalories, formatPrice } from '@/utils/format'
import type { Dish } from '@/types/api'

const props = withDefaults(
  defineProps<{
    dish: Dish
    quantity?: number
    compact?: boolean
    showFavorite?: boolean
    favorited?: boolean
    badge?: string | null
    disabled?: boolean
  }>(),
  { quantity: 0, compact: false, showFavorite: true, favorited: false, badge: null, disabled: false }
)

const emit = defineEmits<{
  (e: 'add', dish: Dish): void
  (e: 'increase', dish: Dish): void
  (e: 'decrease', dish: Dish): void
  (e: 'open', dish: Dish): void
  (e: 'favorite', dish: Dish): void
}>()

const imageSrc = computed(() => props.dish.imageUrl || DISH_PLACEHOLDER)
const unavailable = computed(() => props.dish.available === false)

/** 评分角标：有评价时显示，如「4.1」 */
const ratingBadge = computed(() => {
  const avg = props.dish.avgRating == null ? 0 : Number(props.dish.avgRating)
  const count = props.dish.reviewCount ?? 0
  if (!count || avg <= 0) {
    return null
  }
  return avg.toFixed(1)
})
const ratingCount = computed(() => props.dish.reviewCount ?? 0)

/** 销量标签：月售 N 份，0 时不显示 */
const soldText = computed(() => {
  const n = props.dish.soldCount ?? 0
  if (!n) {
    return null
  }
  return n >= 1000 ? `月售 ${(n / 1000).toFixed(1)}k` : `月售 ${n}`
})
const displayBadge = computed(() => {
  if (props.badge) {
    return props.badge
  }
  if (props.dish.recommendationBadge) {
    return props.dish.recommendationBadge
  }
  if (props.dish.recommendFlag) {
    return '今日推荐'
  }
  return null
})

function onAdd(event: Event) {
  event.stopPropagation()
  if (unavailable.value || props.disabled) {
    return
  }
  emit('add', props.dish)
}

function onIncrease(event: Event) {
  event.stopPropagation()
  emit('increase', props.dish)
}

function onDecrease(event: Event) {
  event.stopPropagation()
  emit('decrease', props.dish)
}

function onFavorite(event: Event) {
  event.stopPropagation()
  emit('favorite', props.dish)
}
</script>

<template>
  <article
    class="dish-card"
    :class="{ 'dish-card--compact': compact, 'dish-card--unavailable': unavailable }"
    tabindex="0"
    role="button"
    :aria-label="`查看 ${dish.name} 详情`"
    @click="emit('open', dish)"
    @keydown.enter.prevent="emit('open', dish)"
    @keydown.space.prevent="emit('open', dish)"
  >
    <div class="dish-card__media">
      <img :src="imageSrc" :alt="dish.name" class="dish-card__img" loading="lazy" />
      <span v-if="displayBadge" class="dish-card__badge">{{ displayBadge }}</span>
      <!-- 评分角标：参考项目 DishCard 的设计，图片左下角 -->
      <span
        v-if="ratingBadge"
        class="dish-card__rating"
        :title="`${ratingCount} 条评价`"
      >
        <AppIcon name="star" :size="11" :filled="true" />
        <span class="num">{{ ratingBadge }}</span>
      </span>
      <button
        v-if="showFavorite"
        class="dish-card__fav"
        :class="{ 'dish-card__fav--on': favorited }"
        type="button"
        :aria-label="favorited ? `取消收藏 ${dish.name}` : `收藏 ${dish.name}`"
        :aria-pressed="favorited"
        @click="onFavorite"
      >
        <AppIcon name="star" :size="15" :filled="favorited" />
      </button>
      <div v-if="unavailable" class="dish-card__mask">
        <span>{{ dish.availabilityText || '今日售罄' }}</span>
      </div>
    </div>

    <div class="dish-card__body">
      <h3 class="dish-card__name text-ellipsis" :title="dish.name">{{ dish.name }}</h3>
      <p class="dish-card__meta">
        <span class="dish-card__price num">¥{{ formatPrice(dish.price) }}</span>
        <span class="dish-card__dot">·</span>
        <span class="dish-card__kcal num">{{ formatCalories(dish.calories) }} kcal</span>
        <span v-if="soldText" class="dish-card__sold num">{{ soldText }}</span>
      </p>
      <div class="dish-card__tags">
        <span v-for="tag in dish.tags.slice(0, 3)" :key="tag" class="tag">{{ tag }}</span>
      </div>
    </div>

    <div class="dish-card__action">
      <button
        v-if="quantity === 0"
        class="add-btn"
        type="button"
        :disabled="unavailable || disabled"
        :aria-label="`将 ${dish.name} 加入购物车`"
        @click="onAdd"
      >
        <AppIcon name="plus" :size="18" />
      </button>
      <div v-else class="stepper" role="group" :aria-label="`${dish.name} 数量`">
        <button class="stepper__btn" type="button" :aria-label="`减少 ${dish.name}`" @click="onDecrease">
          <AppIcon name="minus" :size="14" />
        </button>
        <span class="stepper__value num">{{ quantity }}</span>
        <button
          class="stepper__btn stepper__btn--plus"
          type="button"
          :aria-label="`增加 ${dish.name}`"
          @click="onIncrease"
        >
          <AppIcon name="plus" :size="14" />
        </button>
      </div>
    </div>
  </article>
</template>

<style scoped>
.dish-card {
  position: relative;
  display: flex;
  flex-direction: column;
  background: rgba(255, 253, 248, 0.92);
  border: 1px solid rgba(255, 255, 255, 0.9);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
  cursor: pointer;
  transition: transform var(--motion-normal) var(--ease-standard),
    box-shadow var(--motion-normal) var(--ease-standard),
    border-color var(--motion-normal) var(--ease-standard);
}

.dish-card:hover {
  transform: translateY(-3px);
  box-shadow: var(--shadow-lg);
  border-color: #fff;
}

.dish-card:active {
  transform: translateY(-1px) scale(0.995);
}

.dish-card--unavailable {
  opacity: 0.86;
}

.dish-card__media {
  position: relative;
  aspect-ratio: 16 / 10;
  overflow: hidden;
  background: var(--cream-200);
}

.dish-card__img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform var(--motion-slow) var(--ease-standard);
}

.dish-card:hover .dish-card__img {
  transform: scale(1.035);
}

.dish-card__badge {
  position: absolute;
  top: 10px;
  left: 10px;
  padding: 3px 10px;
  border-radius: var(--radius-pill);
  background: linear-gradient(135deg, var(--amber-400), var(--amber-500));
  color: #fff;
  font-size: 10.5px;
  font-weight: 700;
  letter-spacing: 0.02em;
  box-shadow: 0 3px 10px rgba(196, 122, 42, 0.28);
}

.dish-card__fav {
  position: absolute;
  top: 8px;
  right: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.86);
  color: var(--ink-400);
  backdrop-filter: blur(6px);
  transition: transform var(--motion-fast) var(--ease-standard),
    color var(--motion-fast) var(--ease-standard),
    background-color var(--motion-fast) var(--ease-standard);
}

.dish-card__fav:hover {
  transform: scale(1.08);
  background: #fff;
  color: var(--amber-500);
}

.dish-card__fav--on {
  color: var(--amber-500);
  animation: pop-badge 340ms var(--ease-enter);
}

/* 评分角标样式（对齐参考项目：白色胶囊 + 星星 + 数字） */
.dish-card__rating {
  position: absolute;
  left: 8px;
  bottom: 8px;
  z-index: 2;
  display: inline-flex;
  align-items: center;
  gap: 3px;
  padding: 3px 8px;
  border-radius: var(--radius-pill);
  background: rgba(255, 253, 248, 0.94);
  color: var(--amber-600);
  font-size: 10.5px;
  font-weight: 700;
  line-height: 1;
  box-shadow: 0 2px 8px rgba(44, 42, 38, 0.14);
  backdrop-filter: blur(6px);
}

.dish-card__mask {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(60, 56, 48, 0.42);
  backdrop-filter: blur(2px);
}

.dish-card__mask span {
  padding: 6px 16px;
  border-radius: var(--radius-pill);
  background: rgba(255, 253, 248, 0.94);
  color: var(--ink-700);
  font-size: var(--font-sm);
  font-weight: 600;
}

.dish-card__body {
  display: flex;
  flex-direction: column;
  gap: 5px;
  padding: 12px 14px 0;
}

.dish-card__name {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
  letter-spacing: 0.01em;
}

.dish-card__meta {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: var(--font-sm);
}

.dish-card__price {
  color: var(--amber-600);
  font-weight: 700;
  font-size: var(--font-md);
}

.dish-card__dot {
  color: var(--ink-300);
}

.dish-card__kcal {
  color: var(--ink-500);
  font-size: var(--font-sm);
}

.dish-card__tags {
  display: flex;
  gap: 5px;
  min-height: 22px;
  flex-wrap: wrap;
}

.dish-card__action {
  display: flex;
  justify-content: flex-end;
  padding: 8px 12px 12px;
  margin-top: auto;
}

.add-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--sage-500), var(--sage-700));
  color: #fff;
  box-shadow: 0 5px 14px rgba(95, 120, 80, 0.32);
  transition: transform var(--motion-fast) var(--ease-standard),
    filter var(--motion-fast) var(--ease-standard);
}

.add-btn:hover:not(:disabled) {
  transform: scale(1.08);
  filter: brightness(1.08);
}

.add-btn:active:not(:disabled) {
  transform: scale(0.94);
}

.add-btn:disabled {
  background: var(--ink-300);
  box-shadow: none;
  cursor: not-allowed;
}

.stepper {
  display: flex;
  align-items: center;
  gap: 2px;
  padding: 2px;
  border-radius: var(--radius-pill);
  background: rgba(232, 238, 221, 0.85);
  animation: scale-in var(--motion-fast) var(--ease-enter);
}

.stepper__btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  color: var(--sage-700);
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.stepper__btn:hover {
  background: #fff;
}

.stepper__btn--plus {
  background: linear-gradient(140deg, var(--sage-500), var(--sage-700));
  color: #fff;
}

.stepper__btn--plus:hover {
  background: linear-gradient(140deg, var(--sage-500), var(--sage-700));
  filter: brightness(1.08);
}

.stepper__value {
  min-width: 22px;
  text-align: center;
  font-size: var(--font-base);
  font-weight: 700;
  color: var(--sage-800);
}

.dish-card--compact .dish-card__media {
  aspect-ratio: 16 / 9;
}

.dish-card--compact .dish-card__body {
  padding: 10px 12px 0;
}

.dish-card--compact .dish-card__name {
  font-size: var(--font-base);
}

.dish-card__sold {
  margin-left: auto;
  font-size: 10px;
  color: var(--ink-400);
  white-space: nowrap;
}
</style>
