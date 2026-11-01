<script setup lang="ts">
/**
 * 首页 AI 智能推荐入口。
 * 真实调用后端 /api/v1/ai/recommend；后端未配置 Key 时明确标注"规则推荐演示模式"。
 */
import { computed, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { aiApi, cartApi } from '@/api/modules'
import { useToastStore } from '@/stores/toast'
import { useCartStore } from '@/stores/cart'
import type { AiRecommendResult } from '@/types/api'
import { formatPrice } from '@/utils/format'

const emit = defineEmits<{
  (e: 'added', dishId: number): void
  (e: 'open-dish', dishId: number): void
}>()

const toast = useToastStore()
const cart = useCartStore()

const quickTags = ['减脂轻食', '增加蛋白', '清淡健康', '快速饱腹']
const question = ref('')
const loading = ref(false)
const result = ref<AiRecommendResult | null>(null)
const aiStatus = ref<{ mode: string; modeLabel: string; configured: boolean } | null>(null)
const conversationId = ref<number | null>(null)
const addingId = ref<number | null>(null)

const modeLabel = computed(() => result.value?.modeLabel || aiStatus.value?.modeLabel || '规则推荐演示模式')
const isLlm = computed(() => (result.value?.mode ?? aiStatus.value?.mode) === 'LLM')

async function loadStatus() {
  try {
    aiStatus.value = await aiApi.status()
  } catch {
    aiStatus.value = null
  }
}

async function ask(text?: string) {
  const message = (text ?? question.value).trim()
  if (!message) {
    toast.warning('先告诉我你的用餐需求吧', '例如：想吃得清淡一点、预算 20 元以内')
    return
  }
  if (loading.value) {
    return
  }
  question.value = message
  loading.value = true
  try {
    const response = await aiApi.recommend({ message, conversationId: conversationId.value })
    result.value = response
    conversationId.value = response.conversationId ?? null
  } catch (e) {
    toast.error('智能推荐失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    loading.value = false
  }
}

function useTag(tag: string) {
  ask(tag)
}

async function addToCart(dishId: number) {
  if (addingId.value) {
    return
  }
  addingId.value = dishId
  try {
    await cart.add(dishId, 1)
    emit('added', dishId)
    toast.success('已加入购物车', '结算后桌面才会送来餐食哦')
  } catch (e) {
    toast.error('加入购物车失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    addingId.value = null
  }
}

loadStatus()
</script>

<template>
  <section class="ai-card glass-card">
    <div class="ai-card__main">
      <div class="ai-card__head">
        <div>
          <h2 class="ai-card__title">今天吃什么？让我帮你搭配</h2>
          <p class="ai-card__desc">告诉我你的饮食需求，我来为你推荐合适的美味～</p>
        </div>
        <span class="ai-card__mode" :class="{ 'ai-card__mode--llm': isLlm }">
          <AppIcon :name="isLlm ? 'sparkles' : 'robot'" :size="12" />
          {{ modeLabel }}
        </span>
      </div>

      <div class="ai-card__tags">
        <button
          v-for="tag in quickTags"
          :key="tag"
          class="quick-tag"
          type="button"
          @click="useTag(tag)"
        >
          <AppIcon :name="tag === '减脂轻食' ? 'leaf' : tag === '增加蛋白' ? 'dumbbell' : tag === '清淡健康' ? 'heart' : 'flame'" :size="14" />
          {{ tag }}
        </button>
      </div>

      <form class="ai-input" @submit.prevent="ask()">
        <AppIcon name="sparkles" :size="16" class="ai-input__icon" />
        <input
          v-model="question"
          class="ai-input__field"
          type="text"
          placeholder="例如：我今天运动了，想吃得清淡一点……"
          aria-label="描述你的用餐需求"
          :disabled="loading"
        />
        <button class="ai-input__submit" type="submit" :disabled="loading" aria-label="获取智能推荐">
          <span v-if="loading" class="spinner"></span>
          <AppIcon v-else name="arrow-right" :size="17" />
        </button>
      </form>

      <Transition name="fade">
        <div v-if="result" class="ai-result">
          <p class="ai-result__reply">{{ result.reply }}</p>
          <div class="ai-result__list">
            <button
              v-for="dish in result.dishes"
              :key="dish.dishId"
              class="ai-dish"
              type="button"
              @click="emit('open-dish', dish.dishId)"
            >
              <img :src="dish.imageUrl || '/assets/images/dishes/dish-placeholder.webp'" :alt="dish.name" />
              <div class="ai-dish__info">
                <span class="ai-dish__name">{{ dish.name }}</span>
                <span class="ai-dish__reason">{{ dish.reason }}</span>
              </div>
              <div class="ai-dish__right">
                <span class="ai-dish__price num">¥{{ formatPrice(dish.price) }}</span>
                <button
                  class="ai-dish__add"
                  type="button"
                  :aria-label="`加入购物车：${dish.name}`"
                  :disabled="addingId === dish.dishId"
                  @click.stop="addToCart(dish.dishId)"
                >
                  <AppIcon name="plus" :size="14" />
                </button>
              </div>
            </button>
          </div>
          <ul class="ai-result__tips">
            <li v-for="tip in result.tips" :key="tip">
              <AppIcon name="info" :size="12" />{{ tip }}
            </li>
          </ul>
        </div>
      </Transition>
    </div>

    <div class="ai-card__art" aria-hidden="true">
      <div class="chef-bot">
        <span class="chef-bot__hat"></span>
        <span class="chef-bot__head">
          <span class="chef-bot__eye"></span>
          <span class="chef-bot__eye"></span>
        </span>
        <span class="chef-bot__body"></span>
        <span class="chef-bot__plate"></span>
      </div>
    </div>
  </section>
</template>

<style scoped>
.ai-card {
  position: relative;
  display: flex;
  gap: var(--space-4);
  padding: var(--space-5) var(--space-6);
  overflow: hidden;
  background: linear-gradient(135deg, rgba(243, 247, 236, 0.94), rgba(253, 248, 239, 0.9));
}

.ai-card__main {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.ai-card__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
}

.ai-card__title {
  font-size: var(--font-xl);
  font-weight: 700;
  color: var(--ink-900);
  letter-spacing: 0.01em;
}

.ai-card__desc {
  font-size: var(--font-sm);
  color: var(--ink-500);
  margin-top: 3px;
}

.ai-card__mode {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  flex: none;
  height: 24px;
  padding: 0 10px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(124, 143, 90, 0.22);
  color: var(--ink-500);
  font-size: var(--font-xs);
  font-weight: 600;
}

.ai-card__mode--llm {
  background: var(--sage-100);
  color: var(--sage-700);
  border-color: transparent;
}

.ai-card__tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.quick-tag {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  height: 30px;
  padding: 0 14px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(124, 143, 90, 0.2);
  color: var(--sage-700);
  font-size: var(--font-sm);
  font-weight: 600;
  transition: transform var(--motion-fast) var(--ease-standard),
    background-color var(--motion-fast) var(--ease-standard),
    border-color var(--motion-fast) var(--ease-standard);
}

.quick-tag:hover {
  transform: translateY(-1px);
  background: #fff;
  border-color: var(--sage-400);
}

.ai-input {
  position: relative;
  display: flex;
  align-items: center;
  gap: 8px;
  height: 46px;
  padding: 0 6px 0 16px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(124, 143, 90, 0.22);
  transition: border-color var(--motion-fast) var(--ease-standard),
    box-shadow var(--motion-fast) var(--ease-standard);
}

.ai-input:focus-within {
  border-color: var(--sage-400);
  box-shadow: var(--shadow-glow);
}

.ai-input__icon {
  color: var(--amber-500);
  flex: none;
}

.ai-input__field {
  flex: 1;
  min-width: 0;
  height: 100%;
  border: none;
  background: transparent;
  outline: none;
  font-size: var(--font-base);
  color: var(--ink-800);
}

.ai-input__field::placeholder {
  color: var(--ink-400);
}

.ai-input__submit {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  flex: none;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--sage-500), var(--sage-700));
  color: #fff;
  transition: transform var(--motion-fast) var(--ease-standard),
    filter var(--motion-fast) var(--ease-standard);
}

.ai-input__submit:hover:not(:disabled) {
  transform: scale(1.06);
  filter: brightness(1.08);
}

.ai-input__submit:disabled {
  opacity: 0.7;
  cursor: wait;
}

.spinner {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.4);
  border-top-color: #fff;
  animation: spin 700ms linear infinite;
}

.ai-result {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 12px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.72);
  border: 1px solid rgba(124, 143, 90, 0.14);
  max-height: 260px;
  overflow-y: auto;
  overscroll-behavior: contain;
}

.ai-result__reply {
  font-size: var(--font-sm);
  color: var(--ink-700);
  line-height: 1.65;
}

.ai-result__list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.ai-dish {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px;
  border-radius: var(--radius-sm);
  background: rgba(255, 253, 248, 0.9);
  border: 1px solid rgba(124, 143, 90, 0.1);
  text-align: left;
  transition: background-color var(--motion-fast) var(--ease-standard),
    transform var(--motion-fast) var(--ease-standard);
}

.ai-dish:hover {
  background: #fff;
  transform: translateX(2px);
}

.ai-dish img {
  width: 46px;
  height: 46px;
  border-radius: var(--radius-xs);
  object-fit: cover;
  flex: none;
}

.ai-dish__info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.ai-dish__name {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-800);
}

.ai-dish__reason {
  font-size: var(--font-xs);
  color: var(--ink-500);
  line-height: 1.45;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.ai-dish__right {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: none;
}

.ai-dish__price {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--amber-600);
}

.ai-dish__add {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 26px;
  border-radius: 50%;
  background: var(--sage-500);
  color: #fff;
  transition: transform var(--motion-fast) var(--ease-standard);
}

.ai-dish__add:hover {
  transform: scale(1.1);
}

.ai-result__tips {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.ai-result__tips li {
  display: flex;
  align-items: flex-start;
  gap: 5px;
  font-size: var(--font-xs);
  color: var(--ink-500);
  line-height: 1.5;
}

.ai-card__art {
  position: relative;
  width: 118px;
  flex: none;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 简洁厨师机器人插画（纯 CSS，避免与画风冲突的外部素材） */
.chef-bot {
  position: relative;
  width: 84px;
  height: 96px;
  animation: breathe-float 6s var(--ease-standard) infinite;
}

.chef-bot__hat {
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 44px;
  height: 24px;
  border-radius: 14px 14px 6px 6px;
  background: #fff;
  box-shadow: var(--shadow-sm);
}

.chef-bot__head {
  position: absolute;
  top: 20px;
  left: 50%;
  transform: translateX(-50%);
  width: 58px;
  height: 40px;
  border-radius: 16px;
  background: linear-gradient(160deg, #ffffff, #eef4e6);
  border: 1.5px solid rgba(124, 143, 90, 0.28);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 9px;
}

.chef-bot__eye {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--sage-600);
}

.chef-bot__body {
  position: absolute;
  top: 62px;
  left: 50%;
  transform: translateX(-50%);
  width: 52px;
  height: 30px;
  border-radius: 12px 12px 14px 14px;
  background: linear-gradient(160deg, var(--sage-300), var(--sage-500));
}

.chef-bot__plate {
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 40px;
  height: 8px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.9);
  box-shadow: var(--shadow-xs);
}

@media (max-width: 1279px) {
  .ai-card__art {
    display: none;
  }
}

@media (max-width: 1023px) {
  .ai-card {
    padding: var(--space-4);
  }

  .ai-card__title {
    font-size: var(--font-lg);
  }
}
</style>
