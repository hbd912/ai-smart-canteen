<script setup lang="ts">
/**
 * 菜品详情弹窗：图片、简介、主要食材、过敏原提示、营养、价格、加入购物车。
 * 数据缺失时显示"信息暂缺"，绝不编造。
 */
import { computed } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import DishReviewSection from '@/components/menu/DishReviewSection.vue'
import { DISH_PLACEHOLDER } from '@/config/media'
import { formatCalories, formatPrice } from '@/utils/format'
import type { Dish } from '@/types/api'

const props = defineProps<{
  dish: Dish | null
  quantity: number
  favorited?: boolean
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'add', dish: Dish): void
  (e: 'increase', dish: Dish): void
  (e: 'decrease', dish: Dish): void
  (e: 'toggle-favorite', dish: Dish): void
}>()

const imageSrc = computed(() => props.dish?.imageUrl || DISH_PLACEHOLDER)
const allergens = computed(() => {
  const list = props.dish?.allergens ?? []
  return list.length > 0 ? list : ['信息暂缺']
})
const ingredients = computed(() => {
  const list = props.dish?.ingredients ?? []
  return list.length > 0 ? list : ['信息暂缺']
})

const nutritionRows = computed(() => {
  const dish = props.dish
  if (!dish) {
    return []
  }
  return [
    { label: '热量', value: dish.calories, unit: 'kcal' },
    { label: '蛋白质', value: dish.proteinG, unit: 'g' },
    { label: '脂肪', value: dish.fatG, unit: 'g' },
    { label: '碳水', value: dish.carbohydrateG, unit: 'g' },
    { label: '膳食纤维', value: dish.fiberG, unit: 'g' },
    { label: '钠', value: dish.sodiumMg, unit: 'mg' }
  ]
})
</script>

<template>
  <Transition name="modal">
    <div v-if="dish" class="modal" role="dialog" aria-modal="true" :aria-label="`${dish.name} 详情`" @click.self="emit('close')">
      <div class="modal__surface detail">
        <button class="detail__close" type="button" aria-label="关闭详情" @click="emit('close')">
          <AppIcon name="close" :size="18" />
        </button>

        <div class="detail__media">
          <img :src="imageSrc" :alt="dish.name" />
          <button
            class="detail__fav"
            :class="{ 'detail__fav--on': favorited }"
            type="button"
            :aria-pressed="favorited"
            :aria-label="favorited ? '取消收藏' : '收藏菜品'"
            @click="emit('toggle-favorite', dish)"
          >
            <AppIcon name="star" :size="17" :filled="favorited" />
          </button>
        </div>

        <div class="detail__body">
          <div class="detail__title-row">
            <h2 class="detail__name">{{ dish.name }}</h2>
            <span class="detail__price num">¥{{ formatPrice(dish.price) }}</span>
          </div>
          <p class="detail__desc">{{ dish.description || '这道菜还没有添加简介。' }}</p>

          <div class="detail__tags">
            <span class="tag">{{ dish.categoryName || '未分类' }}</span>
            <span v-for="tag in dish.tags" :key="tag" class="tag tag--muted">{{ tag }}</span>
            <span v-if="dish.available === false" class="tag tag--danger">{{ dish.availabilityText }}</span>
          </div>

          <div class="detail__grid">
            <section class="detail__block">
              <h3 class="detail__block-title">
                <AppIcon name="leaf" :size="13" />主要食材
              </h3>
              <ul class="chip-list">
                <li v-for="item in ingredients" :key="item" class="chip">{{ item }}</li>
              </ul>
            </section>

            <section class="detail__block">
              <h3 class="detail__block-title">
                <AppIcon name="alert-triangle" :size="13" />过敏原提示
              </h3>
              <ul class="chip-list">
                <li v-for="item in allergens" :key="item" class="chip chip--warn">{{ item }}</li>
              </ul>
            </section>
          </div>

          <section class="detail__block">
            <h3 class="detail__block-title">
              <AppIcon name="flame" :size="13" />营养信息
              <span class="detail__estimate">估算值 · 非实验室检测</span>
            </h3>
            <div class="nutrition-grid">
              <div v-for="row in nutritionRows" :key="row.label" class="nutrition-cell">
                <span class="nutrition-cell__label">{{ row.label }}</span>
                <span class="nutrition-cell__value num">
                  {{ row.value === null || row.value === undefined ? '—' : Math.round(Number(row.value)) }}
                  <small>{{ row.unit }}</small>
                </span>
              </div>
            </div>
          </section>

          <!-- 用户评价：评分汇总 + 星级分布 + 评价列表 -->
          <DishReviewSection :dish-id="dish.id" />

          <p class="detail__note">
            <AppIcon name="info" :size="12" />
            {{ dish.nutritionNote || '营养数据为课堂演示估算值，正式使用前需由食堂核实。' }}
          </p>

          <div class="detail__footer">
            <div v-if="quantity === 0" class="detail__stock">
              库存 <strong class="num">{{ dish.stock }}</strong> 份
            </div>
            <div v-else class="detail__stepper">
              <button class="stepper-btn" type="button" aria-label="减少数量" @click="emit('decrease', dish)">
                <AppIcon name="minus" :size="15" />
              </button>
              <span class="num">{{ quantity }}</span>
              <button class="stepper-btn stepper-btn--plus" type="button" aria-label="增加数量" @click="emit('increase', dish)">
                <AppIcon name="plus" :size="15" />
              </button>
            </div>
            <button
              v-if="quantity === 0"
              class="btn btn--primary detail__add"
              type="button"
              :disabled="dish.available === false"
              @click="emit('add', dish)"
            >
              <AppIcon name="cart" :size="16" />
              加入购物车
            </button>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.modal {
  position: fixed;
  inset: 0;
  z-index: 200;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-6);
  background: rgba(48, 44, 36, 0.42);
  backdrop-filter: blur(6px);
  -webkit-backdrop-filter: blur(6px);
}

.detail {
  position: relative;
  display: grid;
  grid-template-columns: minmax(0, 0.85fr) minmax(0, 1.15fr);
  /* 宽高都设上限：内容再多也不撑破视口 */
  width: min(960px, 94vw);
  height: min(88vh, 900px);
  max-height: 90vh;
  border-radius: var(--radius-2xl);
  overflow: hidden;
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
}

.detail__close {
  position: absolute;
  top: 12px;
  right: 12px;
  z-index: 5;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.9);
  color: var(--ink-600);
  box-shadow: var(--shadow-sm);
  transition: transform var(--motion-fast) var(--ease-standard);
}

.detail__close:hover {
  transform: rotate(90deg);
}

.detail__media {
  position: relative;
  height: 100%;
  min-height: 0;
  background: var(--cream-200);
  overflow: hidden;
}

.detail__media img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}


.detail__fav {
  position: absolute;
  top: 12px;
  left: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.9);
  color: var(--ink-400);
  box-shadow: var(--shadow-sm);
}

.detail__fav--on {
  color: var(--amber-500);
}

.detail__body {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  padding: var(--space-6);
  /* 关键：独立滚动，内容超出时只滚右侧，不撑破弹窗 */
  overflow-y: auto;
  overscroll-behavior: contain;
  min-height: 0;
  height: 100%;
  padding-bottom: var(--space-8);
}

.detail__title-row {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: var(--space-3);
}

.detail__name {
  font-size: var(--font-2xl);
  font-weight: 700;
  color: var(--ink-900);
}

.detail__price {
  font-size: var(--font-xl);
  font-weight: 700;
  color: var(--amber-600);
  flex: none;
}

.detail__desc {
  font-size: var(--font-sm);
  color: var(--ink-600);
  line-height: 1.7;
}

.detail__tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.detail__grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-3);
}

.detail__block {
  display: flex;
  flex-direction: column;
  gap: 7px;
}

.detail__block-title {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--sage-700);
  letter-spacing: 0.02em;
}

.detail__estimate {
  margin-left: auto;
  font-size: 10px;
  font-weight: 500;
  color: var(--ink-400);
}

.chip-list {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
}

.chip {
  padding: 3px 10px;
  border-radius: var(--radius-pill);
  background: rgba(232, 238, 221, 0.72);
  color: var(--sage-700);
  font-size: var(--font-xs);
}

.chip--warn {
  background: var(--amber-100);
  color: var(--amber-600);
}

.nutrition-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 8px;
}

.nutrition-cell {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding: 8px 10px;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.72);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.nutrition-cell__label {
  font-size: 10.5px;
  color: var(--ink-500);
}

.nutrition-cell__value {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-800);
}

.nutrition-cell__value small {
  font-size: 10px;
  font-weight: 500;
  color: var(--ink-400);
  margin-left: 1px;
}

.detail__note {
  display: flex;
  align-items: flex-start;
  gap: 5px;
  font-size: 10.5px;
  color: var(--ink-400);
  line-height: 1.55;
}

.detail__footer {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  margin-top: auto;
  padding-top: var(--space-3);
  border-top: 1px solid rgba(124, 143, 90, 0.14);
}

.detail__stock {
  flex: 1;
  font-size: var(--font-sm);
  color: var(--ink-500);
}

.detail__stock strong {
  color: var(--sage-700);
}

.detail__stepper {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 700;
  color: var(--sage-800);
}

.stepper-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: var(--sage-100);
  color: var(--sage-700);
}

.stepper-btn--plus {
  background: linear-gradient(140deg, var(--sage-500), var(--sage-700));
  color: #fff;
}

.detail__add {
  flex: none;
  min-width: 150px;
}

@media (max-width: 767px) {
  .detail {
    grid-template-columns: 1fr;
    max-height: 90vh;
  }

  .detail__media {
    height: 200px;
  }

  .detail__grid {
    grid-template-columns: 1fr;
  }

  .nutrition-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 900px) {
  .detail {
    grid-template-columns: 1fr;
    height: min(92vh, 860px);
  }

  .detail__media {
    max-height: 220px;
  }
}
</style>
