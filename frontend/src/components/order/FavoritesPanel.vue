<script setup lang="ts">
/**
 * 收藏面板：收藏状态与首页推荐卡、菜单卡片共享同一份数据。
 */
import { onMounted, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import DishCard from '@/components/menu/DishCard.vue'
import { favoriteApi } from '@/api/modules'
import type { Dish } from '@/types/api'

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
  (e: 'go-menu'): void
}>()

const loading = ref(true)
const dishes = ref<Dish[]>([])
const error = ref<string | null>(null)

async function load() {
  loading.value = true
  error.value = null
  try {
    dishes.value = await favoriteApi.list()
  } catch (e) {
    error.value = e instanceof Error ? e.message : '收藏加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(load)

defineExpose({ reload: load })
</script>

<template>
  <section class="panel-card glass-card scroll-y">
    <header class="panel-head">
      <div>
        <h2 class="section-title">
          <span class="section-title__icon"><AppIcon name="star" :size="15" /></span>
          我的收藏
        </h2>
        <p class="section-subtitle">喜欢的菜品都放在这里，随时可以再点一次</p>
      </div>
      <span class="count-pill num">{{ dishes.length }} 道</span>
    </header>

    <div v-if="loading" class="fav-grid">
      <div v-for="i in 4" :key="i" class="skeleton" style="height: 216px; border-radius: 20px"></div>
    </div>

    <div v-else-if="error" class="panel-empty">
      <AppIcon name="alert-triangle" :size="24" />
      <p>{{ error }}</p>
      <button class="btn btn--ghost btn--sm" type="button" @click="load">重试</button>
    </div>

    <div v-else-if="dishes.length === 0" class="panel-empty">
      <span class="panel-empty__art"><AppIcon name="star" :size="30" /></span>
      <p class="panel-empty__title">还没有收藏的菜品</p>
      <p class="panel-empty__desc">在菜单或首页点击菜品卡片右上角的星标，就能收藏到这里。</p>
      <button class="btn btn--primary btn--sm" type="button" @click="emit('go-menu')">去逛逛菜单</button>
    </div>

    <div v-else class="fav-grid">
      <DishCard
        v-for="dish in dishes"
        :key="dish.id"
        :dish="dish"
        :quantity="props.quantities[dish.id] || 0"
        :favorited="true"
        @add="(d) => emit('add', d)"
        @increase="(d) => emit('increase', d)"
        @decrease="(d) => emit('decrease', d)"
        @open="(d) => emit('open-dish', d)"
        @favorite="(d) => { emit('toggle-favorite', d); dishes = dishes.filter(x => x.id !== d.id) }"
      />
    </div>
  </section>
</template>

<style scoped>
.panel-card {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  height: 100%;
  padding: var(--space-5);
}

.panel-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
}

.count-pill {
  padding: 3px 12px;
  border-radius: var(--radius-pill);
  background: var(--sage-100);
  color: var(--sage-700);
  font-size: var(--font-xs);
  font-weight: 700;
  flex: none;
}

.fav-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: var(--space-3);
}

.panel-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: var(--space-10) var(--space-5);
  color: var(--ink-500);
  text-align: center;
}

.panel-empty__art {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: var(--amber-100);
  color: var(--amber-500);
}

.panel-empty__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-700);
}

.panel-empty__desc {
  font-size: var(--font-xs);
  color: var(--ink-400);
  max-width: 280px;
  line-height: 1.6;
  margin-bottom: 4px;
}

@media (max-width: 767px) {
  .fav-grid {
    grid-template-columns: 1fr;
  }
}
</style>
