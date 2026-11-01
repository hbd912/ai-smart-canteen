<script setup lang="ts">
/**
 * 点餐面板（画面右侧，占视口 55%–60%）。
 * 分类、排序、热量筛选、搜索均真实改变后端返回的列表。
 */
import { computed, onMounted, ref, watch } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import DishCard from '@/components/menu/DishCard.vue'
import { dishApi } from '@/api/modules'
import { categoryIcon } from '@/config/media'
import type { Category, Dish } from '@/types/api'
import { formatMoney } from '@/utils/format'

const props = defineProps<{
  quantities: Record<number, number>
  favoriteIds: number[]
  searchKeyword: string
  initialCategoryId?: number | null
  cartCount: number
  cartTotal: number
  cartCalories: number
  hasUnavailable: boolean
  /** 是否用餐态：结算按钮变为冷却提示 */
  eating?: boolean
  /** 用餐冷却是否生效 */
  cooldownActive?: boolean
  /** 冷却剩余分钟 */
  cooldownMinutes?: number
}>()

const emit = defineEmits<{
  (e: 'add', dish: Dish): void
  (e: 'increase', dish: Dish): void
  (e: 'decrease', dish: Dish): void
  (e: 'open-dish', dish: Dish): void
  (e: 'toggle-favorite', dish: Dish): void
  (e: 'checkout'): void
  (e: 'view-cart'): void
}>()

type SortKey = 'sales_desc' | 'price_asc' | 'price_desc' | 'calories_asc' | 'calories_desc'
type CalorieFilter = 'all' | 'low' | 'mid' | 'high'

const categories = ref<Category[]>([])
const dishes = ref<Dish[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

const activeCategory = ref<number | null>(props.initialCategoryId ?? null)
const sortKey = ref<SortKey>('sales_desc')
const calorieFilter = ref<CalorieFilter>('all')
const keyword = ref(props.searchKeyword)
const sortOpen = ref(false)
const calorieOpen = ref(false)

const sortOptions: { key: SortKey; label: string }[] = [
  { key: 'sales_desc', label: '销量优先' },
  { key: 'price_asc', label: '价格从低到高' },
  { key: 'price_desc', label: '价格从高到低' },
  { key: 'calories_asc', label: '热量从低到高' },
  { key: 'calories_desc', label: '热量从高到低' }
]

const calorieOptions: { key: CalorieFilter; label: string }[] = [
  { key: 'all', label: '不限热量' },
  { key: 'low', label: '低热量（<300 kcal）' },
  { key: 'mid', label: '适中（300-500 kcal）' },
  { key: 'high', label: '高热量（>500 kcal）' }
]

const currentSortLabel = computed(() => sortOptions.find((o) => o.key === sortKey.value)?.label ?? '销量优先')
const currentCalorieLabel = computed(() => calorieOptions.find((o) => o.key === calorieFilter.value)?.label ?? '不限热量')

const calorieRange = computed(() => {
  switch (calorieFilter.value) {
    case 'low':
      return { maxCalories: 299.99 }
    case 'mid':
      return { minCalories: 300, maxCalories: 500 }
    case 'high':
      return { minCalories: 500.01 }
    default:
      return {}
  }
})

const hasFilters = computed(
  () => Boolean(keyword.value) || activeCategory.value !== null || calorieFilter.value !== 'all' || sortKey.value !== 'sales_desc'
)

const totalQuantity = computed(() => Object.values(props.quantities).reduce((a, b) => a + b, 0))

async function loadCategories() {
  try {
    categories.value = await dishApi.categories()
  } catch {
    categories.value = []
  }
}

async function loadDishes() {
  loading.value = true
  error.value = null
  try {
    const result = await dishApi.list({
      page: 1,
      pageSize: 60,
      categoryId: activeCategory.value ?? undefined,
      keyword: keyword.value || undefined,
      sort: sortKey.value,
      ...calorieRange.value
    })
    dishes.value = result.records
  } catch (e) {
    error.value = e instanceof Error ? e.message : '菜单加载失败'
    dishes.value = []
  } finally {
    loading.value = false
  }
}

function selectCategory(id: number | null) {
  activeCategory.value = id
}

function selectSort(key: SortKey) {
  sortKey.value = key
  sortOpen.value = false
}

function selectCalorie(key: CalorieFilter) {
  calorieFilter.value = key
  calorieOpen.value = false
}

function resetFilters() {
  keyword.value = ''
  activeCategory.value = null
  calorieFilter.value = 'all'
  sortKey.value = 'sales_desc'
}

watch([activeCategory, sortKey, calorieFilter], () => loadDishes())
watch(
  () => props.searchKeyword,
  (next) => {
    keyword.value = next
  }
)
watch(keyword, () => loadDishes())

watch(
  () => props.initialCategoryId,
  (next) => {
    if (next !== undefined) {
      activeCategory.value = next
    }
  }
)

onMounted(async () => {
  await loadCategories()
  await loadDishes()
})
</script>

<template>
  <div class="menu-panel">
    <section class="menu-panel__card glass-panel">
      <header class="menu-head">
        <div class="menu-head__titles">
          <h2 class="menu-head__title">今日菜单</h2>
          <p class="menu-head__subtitle">新鲜美味，为你准备好了</p>
        </div>

        <div class="menu-head__filters">
          <div class="dropdown">
            <button class="filter-btn" type="button" :aria-expanded="sortOpen" @click="sortOpen = !sortOpen; calorieOpen = false">
              <AppIcon name="sort" :size="14" />
              {{ currentSortLabel }}
              <AppIcon name="chevron-down" :size="13" />
            </button>
            <Transition name="fade">
              <ul v-if="sortOpen" class="dropdown__list">
                <li v-for="option in sortOptions" :key="option.key">
                  <button
                    class="dropdown__item"
                    :class="{ 'dropdown__item--active': sortKey === option.key }"
                    type="button"
                    @click="selectSort(option.key)"
                  >
                    {{ option.label }}
                    <AppIcon v-if="sortKey === option.key" name="check" :size="13" />
                  </button>
                </li>
              </ul>
            </Transition>
          </div>

          <div class="dropdown">
            <button class="filter-btn" type="button" :aria-expanded="calorieOpen" @click="calorieOpen = !calorieOpen; sortOpen = false">
              <AppIcon name="flame" :size="14" />
              {{ currentCalorieLabel }}
              <AppIcon name="chevron-down" :size="13" />
            </button>
            <Transition name="fade">
              <ul v-if="calorieOpen" class="dropdown__list">
                <li v-for="option in calorieOptions" :key="option.key">
                  <button
                    class="dropdown__item"
                    :class="{ 'dropdown__item--active': calorieFilter === option.key }"
                    type="button"
                    @click="selectCalorie(option.key)"
                  >
                    {{ option.label }}
                    <AppIcon v-if="calorieFilter === option.key" name="check" :size="13" />
                  </button>
                </li>
              </ul>
            </Transition>
          </div>
        </div>
      </header>

      <div class="menu-cats" role="tablist" aria-label="菜品分类">
        <button
          class="menu-cat"
          :class="{ 'menu-cat--active': activeCategory === null }"
          type="button"
          role="tab"
          :aria-selected="activeCategory === null"
          @click="selectCategory(null)"
        >
          <AppIcon name="grid" :size="14" />
          全部菜品
        </button>
        <button
          v-for="category in categories"
          :key="category.id"
          class="menu-cat"
          :class="{ 'menu-cat--active': activeCategory === category.id }"
          type="button"
          role="tab"
          :aria-selected="activeCategory === category.id"
          @click="selectCategory(category.id)"
        >
          <AppIcon :name="categoryIcon(category.code, category.icon)" :size="14" />
          {{ category.name }}
        </button>
      </div>

      <div class="menu-body scroll-y">
        <div v-if="loading" class="dish-grid">
          <div v-for="i in 6" :key="i" class="skeleton dish-skeleton"></div>
        </div>

        <div v-else-if="error" class="menu-empty">
          <AppIcon name="alert-triangle" :size="26" />
          <p>{{ error }}</p>
          <button class="btn btn--ghost btn--sm" type="button" @click="loadDishes">重试</button>
        </div>

        <div v-else-if="dishes.length === 0" class="menu-empty">
          <AppIcon name="search" :size="26" />
          <p>没有找到符合条件的菜品</p>
          <button v-if="hasFilters" class="btn btn--ghost btn--sm" type="button" @click="resetFilters">
            清除筛选条件
          </button>
        </div>

        <div v-else class="dish-grid">
          <DishCard
            v-for="dish in dishes"
            :key="dish.id"
            :dish="dish"
            :quantity="quantities[dish.id] || 0"
            :favorited="favoriteIds.includes(dish.id)"
            @add="(d) => emit('add', d)"
            @increase="(d) => emit('increase', d)"
            @decrease="(d) => emit('decrease', d)"
            @open="(d) => emit('open-dish', d)"
            @favorite="(d) => emit('toggle-favorite', d)"
          />
        </div>
      </div>

      <footer class="menu-foot">
        <button class="cart-brief" type="button" @click="emit('view-cart')">
          <span class="cart-brief__icon">
            <AppIcon name="cart" :size="18" />
            <span v-if="cartCount > 0" class="cart-brief__badge num">{{ cartCount > 99 ? '99+' : cartCount }}</span>
          </span>
          <span class="cart-brief__text">
            <span class="cart-brief__title">已选 {{ totalQuantity }} 份菜品</span>
            <span class="cart-brief__sub num">{{ Math.round(cartCalories) }} kcal</span>
          </span>
        </button>

        <div class="menu-foot__total">
          <span class="menu-foot__label">合计</span>
          <span class="menu-foot__amount num">¥{{ formatMoney(cartTotal) }}</span>
        </div>

        <!-- 用餐态：结算按钮变为冷却提示，不可下单 -->
        <button
          v-if="props.eating"
          class="btn menu-foot__checkout menu-foot__checkout--cooling"
          type="button"
          :title="props.cooldownActive ? `冷却 ${props.cooldownMinutes} 分钟后可再次点餐` : '正在用餐'"
          @click="emit('checkout')"
        >
          <AppIcon name="clock" :size="15" />
          {{ props.cooldownActive ? `冷却 ${props.cooldownMinutes} 分钟` : '正在用餐' }}
        </button>
        <button
          v-else
          class="btn btn--primary menu-foot__checkout"
          type="button"
          :disabled="cartCount === 0"
          @click="emit('checkout')"
        >
          去结算
          <AppIcon name="arrow-right" :size="16" />
        </button>
      </footer>

      <p v-if="props.eating && props.cooldownActive" class="menu-warn menu-warn--cooling">
        <AppIcon name="info" :size="13" />
        正在用餐，请珍惜粮食，冷却 {{ props.cooldownMinutes }} 分钟后可再次点餐，请勿浪费食物
      </p>
      <p v-else-if="hasUnavailable" class="menu-warn">
        <AppIcon name="alert-triangle" :size="13" />
        购物车中有菜品状态已变化，请打开购物车确认后再结算
      </p>
    </section>
  </div>
</template>

<style scoped>
.menu-panel {
  height: 100%;
  display: flex;
  justify-content: flex-end;
}

.menu-panel__card {
  position: relative;
  display: flex;
  flex-direction: column;
  width: 100%;
  max-width: 100%;
  height: 100%;
  padding: var(--space-5) var(--space-6) 0;
  overflow: hidden;
}

.menu-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.menu-head__title {
  font-size: var(--font-2xl);
  font-weight: 700;
  color: var(--ink-900);
  letter-spacing: 0.02em;
}

.menu-head__subtitle {
  font-size: var(--font-sm);
  color: var(--ink-500);
  margin-top: 2px;
}

.menu-head__filters {
  display: flex;
  gap: 8px;
}

.dropdown {
  position: relative;
}

.filter-btn {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  height: 32px;
  padding: 0 12px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.86);
  border: 1px solid rgba(124, 143, 90, 0.2);
  color: var(--ink-700);
  font-size: var(--font-xs);
  font-weight: 600;
  transition: border-color var(--motion-fast) var(--ease-standard),
    background-color var(--motion-fast) var(--ease-standard);
}

.filter-btn:hover {
  background: #fff;
  border-color: var(--sage-400);
}

.dropdown__list {
  position: absolute;
  top: calc(100% + 6px);
  right: 0;
  z-index: 20;
  min-width: 178px;
  padding: 6px;
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.98);
  backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.9);
  box-shadow: var(--shadow-lg);
}

.dropdown__item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  width: 100%;
  padding: 8px 10px;
  border-radius: var(--radius-xs);
  font-size: var(--font-sm);
  color: var(--ink-700);
  text-align: left;
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.dropdown__item:hover {
  background: var(--sage-50);
}

.dropdown__item--active {
  color: var(--sage-700);
  font-weight: 700;
  background: var(--sage-100);
}

.menu-cats {
  display: flex;
  gap: 8px;
  margin-top: var(--space-4);
  padding-bottom: var(--space-3);
  overflow-x: auto;
  flex: none;
}

.menu-cat {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  height: 32px;
  padding: 0 14px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(124, 143, 90, 0.16);
  color: var(--ink-600);
  font-size: var(--font-sm);
  font-weight: 600;
  white-space: nowrap;
  transition: background-color var(--motion-normal) var(--ease-standard),
    color var(--motion-normal) var(--ease-standard),
    border-color var(--motion-normal) var(--ease-standard);
}

.menu-cat:hover {
  background: #fff;
  border-color: var(--sage-300);
}

.menu-cat--active {
  background: linear-gradient(135deg, var(--sage-500), var(--sage-700));
  border-color: transparent;
  color: #fff;
  box-shadow: 0 5px 14px rgba(95, 120, 80, 0.26);
}

.menu-body {
  flex: 1;
  min-height: 0;
  padding-bottom: 12px;
  padding-right: 4px;
}

.dish-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: var(--space-3);
  padding-bottom: var(--space-3);
}

.dish-skeleton {
  height: 236px;
  border-radius: var(--radius-lg);
}

.menu-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  height: 100%;
  min-height: 200px;
  color: var(--ink-500);
  font-size: var(--font-sm);
}

.menu-foot {
  flex: none;
  display: flex;
  align-items: center;
  gap: var(--space-4);
  padding: 12px var(--space-5);
  margin: 0 calc(var(--space-6) * -1);
  border-top: 1px solid rgba(124, 143, 90, 0.14);
  background: rgba(255, 253, 248, 0.96);
  backdrop-filter: blur(14px);
}

.cart-brief {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
  min-width: 0;
  text-align: left;
  padding: 4px 8px;
  border-radius: var(--radius-md);
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.cart-brief:hover {
  background: var(--sage-50);
}

.cart-brief__icon {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  border-radius: 50%;
  background: var(--sage-100);
  color: var(--sage-700);
  flex: none;
}

.cart-brief__badge {
  position: absolute;
  top: -4px;
  right: -6px;
  min-width: 17px;
  height: 17px;
  padding: 0 4px;
  border-radius: var(--radius-pill);
  background: var(--amber-500);
  color: #fff;
  font-size: 10px;
  font-weight: 700;
  line-height: 17px;
  text-align: center;
  box-shadow: 0 0 0 2px rgba(255, 253, 248, 0.95);
}

.cart-brief__text {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.cart-brief__title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-800);
}

.cart-brief__sub {
  font-size: var(--font-xs);
  color: var(--ink-500);
}

.menu-foot__total {
  display: flex;
  align-items: baseline;
  gap: 6px;
  flex: none;
}

.menu-foot__label {
  font-size: var(--font-xs);
  color: var(--ink-500);
}

.menu-foot__amount {
  font-size: var(--font-xl);
  font-weight: 700;
  color: var(--amber-600);
}

.menu-foot__checkout {
  flex: none;
  min-width: 126px;
}

.menu-foot__checkout--cooling {
  background: rgba(253, 240, 221, 0.95);
  color: var(--amber-600);
  border: 1px solid rgba(217, 143, 56, 0.32);
  cursor: pointer;
}

.menu-warn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 7px var(--space-5);
  margin: 0 calc(var(--space-6) * -1);
  background: var(--amber-100);
  color: var(--amber-600);
  font-size: var(--font-xs);
}

.menu-warn--cooling {
  background: var(--amber-100);
  color: var(--amber-600);
  font-weight: 600;
}

@media (max-width: 1439px) {
  .dish-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 1023px) {
  .menu-panel__card {
    padding: var(--space-4) var(--space-4) 0;
  }

  .dish-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .menu-foot {
    margin: 0 calc(var(--space-4) * -1);
    padding: 10px var(--space-4);
  }

  .menu-head__filters {
    width: 100%;
  }
}

@media (max-width: 767px) {
  .dish-grid {
    grid-template-columns: 1fr;
  }

  .menu-foot {
    flex-wrap: wrap;
    gap: 8px;
  }

  .menu-foot__checkout {
    width: 100%;
  }
}
</style>
