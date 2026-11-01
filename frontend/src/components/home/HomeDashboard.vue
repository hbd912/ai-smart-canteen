<script setup lang="ts">
/**
 * 首页仪表盘：AI 推荐 + 今日推荐 + 今日营养分析 + 食堂菜品分类。
 * 全部数据来自后端接口（推荐/分类/营养），不做前端写死。
 */
import { computed, onMounted, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import ProgressRing from '@/components/common/ProgressRing.vue'
import AiRecommendCard from '@/components/home/AiRecommendCard.vue'
import DishCard from '@/components/menu/DishCard.vue'
import { dishApi, nutritionApi } from '@/api/modules'
import { categoryIcon } from '@/config/media'
import type { Category, Dish, HomeRecommendation, NutritionSummary } from '@/types/api'
import { formatPrice } from '@/utils/format'

const props = defineProps<{
  quantities: Record<number, number>
  favoriteIds: number[]
}>()

const emit = defineEmits<{
  (e: 'add', dish: Dish): void
  (e: 'increase', dish: Dish): void
  (e: 'decrease', dish: Dish): void
  (e: 'open-dish', dish: Dish): void
  (e: 'toggle-favorite', dish: Dish): void
  (e: 'open-category', category: Category | null): void
  (e: 'open-nutrition'): void
  (e: 'open-orders'): void
}>()

const loading = ref(true)
const recommendations = ref<HomeRecommendation[]>([])
const categories = ref<Category[]>([])
const nutrition = ref<NutritionSummary | null>(null)
const error = ref<string | null>(null)

const featured = computed(() => recommendations.value.slice(0, 3))

const nutritionRows = computed(() => {
  const data = nutrition.value
  if (!data) {
    return []
  }
  return [
    {
      key: 'calories',
      icon: 'flame',
      label: '日均热量',
      value: Math.round(data.dailyCalories ?? 0),
      target: Math.round(data.targetCalories),
      unit: 'kcal',
      percent: data.calorieRate
    },
    {
      key: 'protein',
      icon: 'dumbbell',
      label: '日均蛋白',
      value: Math.round(data.dailyProtein ?? 0),
      target: Math.round(data.targetProtein),
      unit: 'g',
      percent: data.proteinRate
    },
    {
      key: 'water',
      icon: 'water',
      label: '饮水量',
      value: Math.round(data.waterMl),
      target: Math.round(data.targetWater),
      unit: 'ml',
      percent: data.waterRate
    }
  ]
})

const mainRingPercent = computed(() => {
  const rate = nutrition.value?.calorieRate ?? 0
  return Math.min(Math.max(Number(rate), 0), 100)
})

const tip = computed(() => nutrition.value?.suggestions?.[0] || '还没有用餐记录，先去看看今天有什么好吃的吧。')

async function load() {
  loading.value = true
  error.value = null
  try {
    const [recs, cats, nut] = await Promise.allSettled([
      dishApi.homeRecommendations(),
      dishApi.categories(),
      nutritionApi.summary(7)
    ])
    if (recs.status === 'fulfilled') {
      recommendations.value = recs.value
    }
    if (cats.status === 'fulfilled') {
      categories.value = cats.value
    }
    if (nut.status === 'fulfilled') {
      nutrition.value = nut.value
    }
    if (recs.status === 'rejected' && cats.status === 'rejected') {
      error.value = '首页数据加载失败，请稍后重试'
    }
  } finally {
    loading.value = false
  }
}

onMounted(load)

defineExpose({ reload: load })
</script>

<template>
  <div class="home-dash scroll-y">
    <div v-if="error" class="home-dash__error">
      <AppIcon name="alert-triangle" :size="16" />
      <span>{{ error }}</span>
      <button class="btn btn--ghost btn--sm" type="button" @click="load">重试</button>
    </div>

    <!-- AI 智能推荐 -->
    <AiRecommendCard
      class="anim-rise"
      @added="(id) => emit('add', { id } as Dish)"
      @open-dish="(id) => { const found = recommendations.find(r => r.dishId === id)?.dish; if (found) emit('open-dish', found) }"
    />

    <!-- 今日推荐 + 今日营养分析 -->
    <div class="home-dash__row anim-rise delay-1">
      <section class="glass-card recommend-card">
        <header class="card-head">
          <div>
            <h2 class="section-title">
              <span class="section-title__icon"><AppIcon name="flame" :size="15" /></span>
              今日推荐
            </h2>
            <p class="section-subtitle">后厨精选，卖得最好的几道</p>
          </div>
          <button class="link-more" type="button" @click="emit('open-category', null)">
            查看全部<AppIcon name="chevron-right" :size="14" />
          </button>
        </header>

        <div v-if="loading" class="recommend-grid">
          <div v-for="i in 3" :key="i" class="skeleton recommend-skeleton"></div>
        </div>
        <div v-else-if="featured.length === 0" class="empty-inline">
          <AppIcon name="info" :size="16" />
          <span>暂时没有推荐菜品，请稍后再来。</span>
        </div>
        <div v-else class="recommend-grid">
          <DishCard
            v-for="(item, index) in featured"
            :key="item.id"
            :dish="item.dish!"
            :quantity="props.quantities[item.dishId] || 0"
            :badge="item.badgeText"
            :favorited="props.favoriteIds.includes(item.dishId)"
            compact
            :class="index === 0 ? 'float-soft' : ''"
            @add="(d) => emit('add', d)"
            @increase="(d) => emit('increase', d)"
            @decrease="(d) => emit('decrease', d)"
            @open="(d) => emit('open-dish', d)"
            @favorite="(d) => emit('toggle-favorite', d)"
          />
        </div>
      </section>

      <section class="glass-card nutrition-card">
        <header class="card-head">
          <div>
            <h2 class="section-title">
              <span class="section-title__icon"><AppIcon name="bar-chart" :size="15" /></span>
              今日营养分析
            </h2>
            <p class="section-subtitle">基于已结算订单估算</p>
          </div>
          <button class="link-more" type="button" @click="emit('open-nutrition')">
            详情<AppIcon name="chevron-right" :size="14" />
          </button>
        </header>

        <div v-if="loading" class="nutrition-skeleton">
          <div class="skeleton" style="width: 104px; height: 104px; border-radius: 50%"></div>
          <div class="nutrition-skeleton__rows">
            <div v-for="i in 3" :key="i" class="skeleton" style="height: 16px"></div>
          </div>
        </div>
        <template v-else>
          <div class="nutrition-body">
            <ProgressRing :percent="mainRingPercent" :size="104" label="日均热量达成率" />
            <ul class="nutrition-list">
              <li v-for="row in nutritionRows" :key="row.key" class="nutrition-row">
                <span class="nutrition-row__icon"><AppIcon :name="row.icon" :size="14" /></span>
                <span class="nutrition-row__label">{{ row.label }}</span>
                <span class="nutrition-row__value num">
                  {{ row.value }}<small>/{{ row.target }} {{ row.unit }}</small>
                </span>
              </li>
            </ul>
          </div>
          <div class="nutrition-tip">
            <AppIcon name="leaf" :size="13" />
            <span>{{ tip }}</span>
          </div>
          <p class="nutrition-note">演示估算数据，非医学检测结果</p>
        </template>
      </section>
    </div>

    <!-- 食堂菜品分类 -->
    <section class="glass-card category-card anim-rise delay-2">
      <header class="card-head">
        <div>
          <h2 class="section-title">
            <span class="section-title__icon"><AppIcon name="grid" :size="15" /></span>
            食堂菜品分类
          </h2>
          <p class="section-subtitle">按分类快速找到想吃的</p>
        </div>
      </header>

      <div v-if="loading" class="category-grid">
        <div v-for="i in 6" :key="i" class="skeleton" style="height: 78px; border-radius: 16px"></div>
      </div>
      <div v-else class="category-grid">
        <button
          v-for="category in categories"
          :key="category.id"
          class="category-item"
          type="button"
          @click="emit('open-category', category)"
        >
          <span class="category-item__icon">
            <AppIcon :name="categoryIcon(category.code, category.icon)" :size="22" />
          </span>
          <span class="category-item__name">{{ category.name }}</span>
          <span class="category-item__count num">{{ category.dishCount }} 道</span>
        </button>
        <button v-if="categories.length === 0" class="category-item category-item--empty" type="button" disabled>
          <span class="category-item__icon"><AppIcon name="info" :size="20" /></span>
          <span class="category-item__name">暂无分类</span>
        </button>
      </div>
    </section>

    <!-- 底部迷你购物车摘要 -->
    <section v-if="Object.keys(props.quantities).length > 0" class="mini-cart glass-card anim-rise delay-3">
      <span class="mini-cart__icon"><AppIcon name="cart" :size="16" /></span>
      <div class="mini-cart__text">
        <span class="mini-cart__title">已选 {{ Object.values(props.quantities).reduce((a, b) => a + b, 0) }} 份</span>
        <span class="mini-cart__hint">结算后服务员才会送餐，桌面现在还是空的</span>
      </div>
      <button class="btn btn--primary btn--sm" type="button" @click="emit('open-category', null)">
        去点餐<AppIcon name="arrow-right" :size="14" />
      </button>
    </section>
  </div>
</template>

<style scoped>
.home-dash {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  height: 100%;
  padding-right: 6px;
}

.home-dash__error {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  border-radius: var(--radius-md);
  background: var(--danger-100);
  color: var(--danger-600);
  font-size: var(--font-sm);
}

.home-dash__row {
  display: grid;
  grid-template-columns: minmax(0, 1.55fr) minmax(0, 1fr);
  gap: var(--space-4);
  align-items: stretch;
}

.card-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  margin-bottom: var(--space-3);
}

.link-more {
  display: inline-flex;
  align-items: center;
  gap: 2px;
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--sage-600);
  padding: 3px 8px;
  border-radius: var(--radius-pill);
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.link-more:hover {
  background: var(--sage-100);
}

.recommend-card,
.nutrition-card,
.category-card {
  padding: var(--space-5);
}

.recommend-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: var(--space-3);
}

.recommend-skeleton {
  height: 208px;
  border-radius: var(--radius-lg);
}

.empty-inline {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: var(--space-5);
  color: var(--ink-500);
  font-size: var(--font-sm);
  justify-content: center;
}

.nutrition-body {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}

.nutrition-list {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 9px;
  min-width: 0;
}

.nutrition-row {
  display: flex;
  align-items: center;
  gap: 7px;
  font-size: var(--font-sm);
}

.nutrition-row__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  border-radius: 7px;
  background: var(--sage-100);
  color: var(--sage-600);
  flex: none;
}

.nutrition-row__label {
  color: var(--ink-600);
  flex: none;
}

.nutrition-row__value {
  margin-left: auto;
  font-weight: 700;
  color: var(--ink-800);
  font-size: var(--font-sm);
  white-space: nowrap;
}

.nutrition-row__value small {
  font-weight: 500;
  color: var(--ink-400);
  font-size: 10.5px;
  margin-left: 1px;
}

.nutrition-tip {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  margin-top: var(--space-3);
  padding: 9px 12px;
  border-radius: var(--radius-sm);
  background: rgba(232, 238, 221, 0.6);
  color: var(--sage-700);
  font-size: var(--font-xs);
  line-height: 1.55;
}

.nutrition-note {
  margin-top: 6px;
  font-size: 10.5px;
  color: var(--ink-400);
}

.nutrition-skeleton {
  display: flex;
  gap: var(--space-4);
  align-items: center;
}

.nutrition-skeleton__rows {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(96px, 1fr));
  gap: var(--space-3);
}

.category-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  padding: 12px 8px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.72);
  border: 1px solid rgba(124, 143, 90, 0.14);
  transition: transform var(--motion-fast) var(--ease-standard),
    background-color var(--motion-fast) var(--ease-standard),
    border-color var(--motion-fast) var(--ease-standard);
}

.category-item:hover {
  transform: translateY(-2px);
  background: #fff;
  border-color: var(--sage-300);
}

.category-item__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(150deg, var(--apricot-100), var(--sage-100));
  color: var(--sage-700);
}

.category-item__name {
  font-size: var(--font-sm);
  font-weight: 600;
  color: var(--ink-800);
}

.category-item__count {
  font-size: 10.5px;
  color: var(--ink-400);
}

.category-item--empty {
  opacity: 0.6;
  cursor: default;
}

.mini-cart {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: 12px var(--space-4);
}

.mini-cart__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: var(--sage-100);
  color: var(--sage-700);
  flex: none;
}

.mini-cart__text {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.mini-cart__title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-800);
}

.mini-cart__hint {
  font-size: var(--font-xs);
  color: var(--ink-500);
}

@media (max-width: 1439px) {
  .home-dash__row {
    grid-template-columns: minmax(0, 1.4fr) minmax(0, 1fr);
  }
}

@media (max-width: 1180px) {
  .home-dash__row {
    grid-template-columns: 1fr;
  }

  .recommend-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 767px) {
  .recommend-grid {
    grid-template-columns: 1fr;
  }

  .category-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }

  .nutrition-body {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
