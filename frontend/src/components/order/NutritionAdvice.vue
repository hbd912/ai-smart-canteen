<script setup lang="ts">
/**
 * AI 营养助手：分析最近订单的营养缺口，推荐能补齐的菜品。
 * 风格参考 AI 助手对话卡片，带机器人头像与自然语言建议。
 */
import { computed, ref, watch } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { nutritionApi } from '@/api/modules'
import { formatMoney } from '@/utils/format'

const props = defineProps<{
  days: number
}>()

const emit = defineEmits<{
  (e: 'order-dish', dishId: number): void
}>()

interface Gap {
  key: string
  label: string
  current: number
  target: number
  rate: number
  status: string
  message: string
}

interface Recommendation {
  dishId: number
  dishName: string
  imageUrl?: string | null
  price: number
  calories: number
  proteinG: number
  fiberG: number
  benefit: string
  reason: string
  score: number
  categoryName?: string | null
}

const loading = ref(true)
const headline = ref('')
const gaps = ref<Gap[]>([])
const recommendations = ref<Recommendation[]>([])
const note = ref('')
const modeLabel = ref('')

const weakGaps = computed(() => gaps.value.filter((g) => g.status === 'LOW'))

async function load() {
  loading.value = true
  try {
    const res = (await nutritionApi.advice(props.days)) as unknown as {
      headline: string
      gaps: Gap[]
      recommendations: Recommendation[]
      note: string
      modeLabel?: string
    }
    headline.value = res.headline
    gaps.value = res.gaps ?? []
    recommendations.value = res.recommendations ?? []
    note.value = res.note
    modeLabel.value = res.modeLabel ?? ''
  } catch {
    headline.value = '暂时无法获取营养建议'
    gaps.value = []
    recommendations.value = []
  } finally {
    loading.value = false
  }
}

watch(() => props.days, load, { immediate: true })

defineExpose({ reload: load })
</script>

<template>
  <section class="advice-ai">
    <!-- AI 助手头部 -->
    <header class="advice-ai__head">
      <span class="advice-ai__bot">
        <AppIcon name="robot" :size="17" />
      </span>
      <div class="advice-ai__title-wrap">
        <div class="advice-ai__title-line">
          <h3 class="advice-ai__title">AI 营养助手</h3>
          <span v-if="modeLabel" class="advice-ai__badge">{{ modeLabel }}</span>
        </div>
        <p class="advice-ai__sub">根据你最近 {{ days }} 天的用餐记录分析</p>
      </div>
    </header>

    <div v-if="loading" class="skeleton" style="height: 90px; border-radius: 12px"></div>

    <template v-else>
      <!-- AI 说 -->
      <p class="advice-ai__bubble">{{ headline }}</p>

      <!-- 缺口条 -->
      <div v-if="weakGaps.length > 0" class="advice-ai__gaps">
        <div v-for="g in weakGaps" :key="g.key" class="gap-row">
          <span class="gap-row__label">{{ g.label }}</span>
          <span class="gap-row__track">
            <span class="gap-row__fill" :style="{ width: `${Math.min(Number(g.rate), 100)}%` }"></span>
          </span>
          <span class="gap-row__value num">{{ Math.round(Number(g.rate)) }}%</span>
        </div>
      </div>

      <!-- 推荐菜品 -->
      <div v-if="recommendations.length > 0" class="advice-ai__recs">
        <p class="advice-ai__recs-title">
          <AppIcon name="sparkles" :size="12" />
          下一餐试试这些
        </p>
        <div class="rec-list">
          <article v-for="r in recommendations" :key="r.dishId" class="rec-card">
            <img
              class="rec-card__img"
              :src="r.imageUrl || '/assets/images/dishes/dish-placeholder.webp'"
              :alt="r.dishName"
              loading="lazy"
            />
            <div class="rec-card__body">
              <div class="rec-card__top">
                <span class="rec-card__name text-ellipsis">{{ r.dishName }}</span>
                <span class="rec-card__price num">¥{{ formatMoney(r.price) }}</span>
              </div>
              <p class="rec-card__benefit">{{ r.benefit }}</p>
              <p class="rec-card__reason">{{ r.reason }}</p>
            </div>
            <button class="rec-card__btn" type="button" @click="emit('order-dish', r.dishId)">
              <AppIcon name="plus" :size="13" />
              点这个
            </button>
          </article>
        </div>
      </div>

      <p class="advice-ai__note">{{ note }}</p>
    </template>
  </section>
</template>

<style scoped>
.advice-ai {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  padding: var(--space-4);
  border-radius: var(--radius-lg);
  background: linear-gradient(140deg, rgba(232, 238, 221, 0.78), rgba(253, 248, 239, 0.9));
  border: 1px solid rgba(124, 143, 90, 0.2);
}

.advice-ai__head {
  display: flex;
  align-items: center;
  gap: 9px;
}

.advice-ai__bot {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  flex: none;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--sage-400), var(--sage-600));
  color: #fff;
  box-shadow: 0 4px 12px rgba(95, 120, 80, 0.24);
}

.advice-ai__title-wrap {
  display: flex;
  flex-direction: column;
}

.advice-ai__title-line {
  display: flex;
  align-items: center;
  gap: 6px;
}

.advice-ai__title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--sage-800);
}

.advice-ai__badge {
  padding: 1px 6px;
  border-radius: var(--radius-pill);
  background: rgba(124, 143, 90, 0.16);
  color: var(--sage-700);
  font-size: 9.5px;
  font-weight: 600;
  line-height: 1.5;
  white-space: nowrap;
}

.advice-ai__sub {
  font-size: 10px;
  color: var(--ink-500);
}

.advice-ai__bubble {
  position: relative;
  padding: 10px 13px;
  border-radius: 4px 14px 14px 14px;
  background: rgba(255, 255, 255, 0.92);
  color: var(--ink-800);
  font-size: var(--font-xs);
  line-height: 1.7;
  box-shadow: 0 2px 10px rgba(44, 42, 38, 0.06);
}

.advice-ai__gaps {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.gap-row {
  display: grid;
  grid-template-columns: 60px 1fr 38px;
  align-items: center;
  gap: 7px;
  font-size: 10px;
  color: var(--ink-600);
}

.gap-row__track {
  height: 5px;
  border-radius: var(--radius-pill);
  background: rgba(124, 143, 90, 0.16);
  overflow: hidden;
}

.gap-row__fill {
  display: block;
  height: 100%;
  border-radius: var(--radius-pill);
  background: linear-gradient(90deg, var(--amber-400, #f0b45c), var(--amber-500));
  transition: width var(--motion-linger) var(--ease-enter);
}

.gap-row__value {
  text-align: right;
  font-weight: 700;
  color: var(--amber-600);
}

.advice-ai__recs {
  display: flex;
  flex-direction: column;
  gap: 7px;
}

.advice-ai__recs-title {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 10.5px;
  font-weight: 700;
  color: var(--sage-700);
}

.rec-list {
  display: flex;
  flex-direction: column;
  gap: 7px;
}

.rec-card {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 8px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(124, 143, 90, 0.12);
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.rec-card:hover {
  background: #fff;
}

.rec-card__img {
  width: 48px;
  height: 48px;
  flex: none;
  border-radius: var(--radius-sm);
  object-fit: cover;
}

.rec-card__body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.rec-card__top {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 6px;
}

.rec-card__name {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--ink-900);
}

.rec-card__price {
  font-size: 10.5px;
  font-weight: 700;
  color: var(--amber-600);
  flex: none;
}

.rec-card__benefit {
  font-size: 9.5px;
  color: var(--sage-700);
  font-weight: 600;
}

.rec-card__reason {
  font-size: 9.5px;
  color: var(--ink-500);
  line-height: 1.5;
}

.rec-card__btn {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  height: 26px;
  padding: 0 10px;
  flex: none;
  border-radius: var(--radius-pill);
  background: linear-gradient(140deg, var(--sage-500), var(--sage-700));
  color: #fff;
  font-size: 10px;
  font-weight: 700;
  transition: transform var(--motion-fast) var(--ease-standard);
}

.rec-card__btn:hover {
  transform: translateY(-1px);
}

.advice-ai__note {
  font-size: 9.5px;
  color: var(--ink-400);
  line-height: 1.5;
}
</style>
