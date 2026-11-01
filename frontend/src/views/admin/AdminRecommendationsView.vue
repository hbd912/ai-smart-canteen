<script setup lang="ts">
/**
 * 首页推荐管理：选择推荐菜品、排序、推荐标签。
 * 保存后前台首页推荐区立即同步（同一份 home_recommendation 数据）。
 */
import { computed, onMounted, reactive, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { adminApi } from '@/api/modules'
import type { Dish, HomeRecommendation } from '@/types/api'
import { formatPrice } from '@/utils/format'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()

const loading = ref(false)
const saving = ref(false)
const recommendations = ref<HomeRecommendation[]>([])
const dishes = ref<Dish[]>([])
const pickerOpen = ref(false)
const pickerKeyword = ref('')
const selectedIds = ref<number[]>([])

const editable = reactive<{ dishId: number; title: string; badgeText: string; sortOrder: number; enabled: boolean }[]>([])

const quickTags = ref(['减脂轻食', '增加蛋白', '清淡健康', '快速饱腹'])

const availableDishes = computed(() =>
  dishes.value.filter(
    (dish) =>
      !selectedIds.value.includes(dish.id) &&
      (!pickerKeyword.value || dish.name.includes(pickerKeyword.value))
  )
)

async function load() {
  loading.value = true
  try {
    const [recs, dishPage] = await Promise.all([
      adminApi.recommendations(),
      adminApi.dishes({ page: 1, pageSize: 100, sort: 'created_desc' })
    ])
    recommendations.value = recs
    dishes.value = dishPage.records
    editable.splice(
      0,
      editable.length,
      ...recs.map((rec, index) => ({
        dishId: rec.dishId,
        title: rec.title ?? rec.dish?.name ?? '',
        badgeText: rec.badgeText ?? '',
        sortOrder: rec.sortOrder ?? index + 1,
        enabled: rec.enabled
      }))
    )
    selectedIds.value = recs.map((rec) => rec.dishId)
  } catch (e) {
    toast.error('推荐配置加载失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    loading.value = false
  }
}

function dishOf(dishId: number): Dish | undefined {
  return dishes.value.find((dish) => dish.id === dishId)
}

function addDish(dish: Dish) {
  if (selectedIds.value.includes(dish.id)) {
    return
  }
  editable.push({
    dishId: dish.id,
    title: dish.name,
    badgeText: '今日推荐',
    sortOrder: editable.length + 1,
    enabled: true
  })
  selectedIds.value = [...selectedIds.value, dish.id]
}

function removeAt(index: number) {
  const [removed] = editable.splice(index, 1)
  selectedIds.value = selectedIds.value.filter((id) => id !== removed.dishId)
  reindex()
}

function move(index: number, direction: -1 | 1) {
  const target = index + direction
  if (target < 0 || target >= editable.length) {
    return
  }
  const items = [...editable]
  const temp = items[index]
  items[index] = items[target]
  items[target] = temp
  editable.splice(0, editable.length, ...items)
  reindex()
}

function reindex() {
  editable.forEach((item, index) => {
    item.sortOrder = index + 1
  })
}

async function save() {
  if (saving.value) {
    return
  }
  saving.value = true
  try {
    await adminApi.saveRecommendations(
      editable.map((item, index) => ({
        dishId: item.dishId,
        title: item.title,
        badgeText: item.badgeText,
        sortOrder: index + 1,
        enabled: item.enabled
      }))
    )
    toast.success('推荐配置已保存', '前台首页「今日推荐」将同步更新')
    await load()
  } catch (e) {
    toast.error('保存失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    saving.value = false
  }
}

onMounted(load)
</script>

<template>
  <div class="rec-page">
    <header class="page-head">
      <div>
        <h2 class="page-head__title">首页推荐管理</h2>
        <p class="page-head__desc">
          前台首页「今日推荐」直接读取这里的配置。调整顺序或增删菜品后，用户端刷新即可看到变化。
        </p>
      </div>
      <div class="page-head__actions">
        <button class="btn btn--ghost btn--sm" type="button" @click="pickerOpen = true">
          <AppIcon name="plus" :size="14" />添加推荐菜品
        </button>
        <button class="btn btn--primary btn--sm" type="button" :disabled="saving" @click="save">
          {{ saving ? '保存中…' : '保存配置' }}
        </button>
      </div>
    </header>

    <div v-if="loading" class="skeleton" style="height: 300px; border-radius: 12px"></div>

    <div v-else-if="editable.length === 0" class="empty-state">
      <AppIcon name="sparkles" :size="28" />
      <p>还没有配置推荐菜品</p>
      <p class="empty-state__desc">没有配置时前台首页不会展示「今日推荐」区块。</p>
      <button class="btn btn--primary btn--sm" type="button" @click="pickerOpen = true">添加推荐菜品</button>
    </div>

    <div v-else class="rec-list">
      <article v-for="(item, index) in editable" :key="item.dishId" class="rec-card" :class="{ 'rec-card--off': !item.enabled }">
        <span class="rec-card__order num">{{ index + 1 }}</span>
        <img
          class="rec-card__img"
          :src="dishOf(item.dishId)?.imageUrl || '/assets/images/dishes/dish-placeholder.webp'"
          :alt="dishOf(item.dishId)?.name || ''"
        />
        <div class="rec-card__info">
          <div class="rec-card__title-row">
            <span class="rec-card__name">{{ dishOf(item.dishId)?.name || '菜品已删除' }}</span>
            <span class="num rec-card__price">¥{{ formatPrice(dishOf(item.dishId)?.price) }}</span>
            <span class="pill" :class="dishOf(item.dishId)?.publishStatus === 'PUBLISHED' ? 'pill--sage' : 'pill--muted'">
              {{ dishOf(item.dishId)?.publishStatus === 'PUBLISHED' ? '已上架' : '未上架' }}
            </span>
          </div>
          <div class="rec-card__fields">
            <div class="field field--inline">
              <label class="field__label">推荐标题</label>
              <input v-model="item.title" class="input input--sm" type="text" maxlength="80" placeholder="展示在卡片上的短标题" />
            </div>
            <div class="field field--inline">
              <label class="field__label">角标文案</label>
              <input v-model="item.badgeText" class="input input--sm" type="text" maxlength="40" placeholder="例如：人气TOP1" />
            </div>
          </div>
        </div>
        <div class="rec-card__actions">
          <button class="act" type="button" :disabled="index === 0" aria-label="上移" @click="move(index, -1)">↑</button>
          <button class="act" type="button" :disabled="index === editable.length - 1" aria-label="下移" @click="move(index, 1)">↓</button>
          <label class="switch-row">
            <input v-model="item.enabled" type="checkbox" />
            <span class="switch-row__box"></span>
            <span class="switch-row__text">{{ item.enabled ? '展示' : '隐藏' }}</span>
          </label>
          <button class="act act--danger" type="button" @click="removeAt(index)">移除</button>
        </div>
      </article>
    </div>

    <section class="tip-card">
      <h3 class="tip-card__title"><AppIcon name="info" :size="14" />AI 快捷标签（演示配置）</h3>
      <p class="tip-card__desc">
        前台 AI 助手当前使用后端规则推荐服务，快捷标签由前端常量定义；
        如需支持后台动态配置，可在后续版本新增配置表与接口。
      </p>
      <div class="tip-card__tags">
        <span v-for="tag in quickTags" :key="tag" class="tag">{{ tag }}</span>
      </div>
    </section>

    <!-- 菜品选择器 -->
    <Transition name="modal">
      <div v-if="pickerOpen" class="modal" @click.self="pickerOpen = false">
        <div class="modal-box">
          <header class="modal-box__head">
            <h3>选择推荐菜品</h3>
            <button type="button" aria-label="关闭" @click="pickerOpen = false"><AppIcon name="close" :size="17" /></button>
          </header>
          <div class="modal-box__search">
            <AppIcon name="search" :size="15" />
            <input v-model="pickerKeyword" type="search" placeholder="搜索菜品名称" />
          </div>
          <div class="modal-box__body scroll-y">
            <div v-if="availableDishes.length === 0" class="empty-mini">没有可添加的菜品</div>
            <button
              v-for="dish in availableDishes"
              :key="dish.id"
              class="pick-row"
              type="button"
              @click="addDish(dish)"
            >
              <img :src="dish.imageUrl || '/assets/images/dishes/dish-placeholder.webp'" :alt="dish.name" />
              <div class="pick-row__info">
                <span class="pick-row__name">{{ dish.name }}</span>
                <span class="pick-row__meta">{{ dish.categoryName }} · ¥{{ formatPrice(dish.price) }} · 库存 {{ dish.stock }}</span>
              </div>
              <AppIcon name="plus" :size="16" />
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.rec-page {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.page-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.page-head__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.page-head__desc {
  font-size: 10.5px;
  color: var(--ink-400);
  margin-top: 2px;
  max-width: 700px;
  line-height: 1.55;
}

.page-head__actions {
  display: flex;
  gap: 8px;
}

.rec-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.rec-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
  transition: opacity var(--motion-fast) var(--ease-standard);
}

.rec-card--off {
  opacity: 0.66;
}

.rec-card__order {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 26px;
  flex: none;
  border-radius: 50%;
  background: var(--sage-100);
  color: var(--sage-700);
  font-size: var(--font-xs);
  font-weight: 700;
}

.rec-card__img {
  width: 74px;
  height: 56px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  flex: none;
}

.rec-card__info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 7px;
}

.rec-card__title-row {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.rec-card__name {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-900);
}

.rec-card__price {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--amber-600);
}

.pill {
  display: inline-flex;
  padding: 2px 8px;
  border-radius: var(--radius-pill);
  font-size: 10px;
  font-weight: 600;
}

.pill--sage {
  background: var(--success-100);
  color: var(--success-600);
}

.pill--muted {
  background: rgba(139, 132, 120, 0.14);
  color: var(--ink-500);
}

.rec-card__fields {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.field--inline {
  flex-direction: row;
  align-items: center;
  gap: 7px;
}

.field--inline .field__label {
  flex: none;
  font-size: 10px;
  color: var(--ink-500);
  white-space: nowrap;
}

.input--sm {
  height: 32px;
  font-size: var(--font-xs);
}

.rec-card__actions {
  display: flex;
  align-items: center;
  gap: 5px;
  flex: none;
  flex-wrap: wrap;
  justify-content: flex-end;
  max-width: 190px;
}

.act {
  padding: 3px 8px;
  border-radius: var(--radius-xs);
  background: var(--sage-50);
  color: var(--sage-700);
  font-size: 10.5px;
  font-weight: 600;
}

.act:hover:not(:disabled) {
  background: var(--sage-100);
}

.act:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.act--danger {
  background: var(--danger-100);
  color: var(--danger-600);
}

.switch-row {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  cursor: pointer;
  font-size: 10px;
  color: var(--ink-500);
}

.switch-row input {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

.switch-row__box {
  position: relative;
  width: 32px;
  height: 18px;
  border-radius: var(--radius-pill);
  background: rgba(139, 132, 120, 0.28);
  transition: background-color var(--motion-fast) var(--ease-standard);
  flex: none;
}

.switch-row__box::after {
  content: '';
  position: absolute;
  top: 2px;
  left: 2px;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: #fff;
  transition: transform var(--motion-normal) var(--ease-standard);
}

.switch-row input:checked + .switch-row__box {
  background: var(--sage-500);
}

.switch-row input:checked + .switch-row__box::after {
  transform: translateX(14px);
}

.tip-card {
  padding: var(--space-4);
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.8);
  border: 1px dashed rgba(124, 143, 90, 0.28);
}

.tip-card__title {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--sage-700);
}

.tip-card__desc {
  font-size: 10.5px;
  color: var(--ink-500);
  margin-top: 4px;
  line-height: 1.6;
}

.tip-card__tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 8px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: var(--space-10);
  color: var(--ink-400);
  font-size: var(--font-sm);
  text-align: center;
}

.empty-state__desc {
  font-size: var(--font-xs);
  color: var(--ink-400);
}

.empty-mini {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-6);
  color: var(--ink-400);
  font-size: var(--font-xs);
}

.modal {
  position: fixed;
  inset: 0;
  z-index: 400;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-5);
  background: rgba(48, 44, 36, 0.4);
  backdrop-filter: blur(4px);
}

.modal-box {
  display: flex;
  flex-direction: column;
  width: min(500px, 100%);
  max-height: 82vh;
  border-radius: var(--radius-xl);
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  overflow: hidden;
  animation: scale-in var(--motion-normal) var(--ease-enter) both;
}

.modal-box__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-4) var(--space-5);
  border-bottom: 1px solid rgba(124, 143, 90, 0.12);
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.modal-box__head button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  color: var(--ink-500);
}

.modal-box__search {
  position: relative;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px var(--space-5);
  color: var(--sage-500);
  border-bottom: 1px solid rgba(124, 143, 90, 0.1);
}

.modal-box__search input {
  flex: 1;
  height: 32px;
  border: none;
  outline: none;
  background: transparent;
  font-size: var(--font-xs);
}

.modal-box__body {
  flex: 1;
  min-height: 120px;
  overflow-y: auto;
  padding: var(--space-3) var(--space-4);
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.pick-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 10px;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.76);
  color: var(--sage-600);
  text-align: left;
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.pick-row:hover {
  background: #fff;
}

.pick-row img {
  width: 42px;
  height: 42px;
  border-radius: var(--radius-xs);
  object-fit: cover;
  flex: none;
}

.pick-row__info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.pick-row__name {
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--ink-800);
}

.pick-row__meta {
  font-size: 10px;
  color: var(--ink-400);
}

@media (max-width: 1023px) {
  .rec-card {
    flex-wrap: wrap;
  }

  .rec-card__fields {
    grid-template-columns: 1fr;
  }

  .rec-card__actions {
    max-width: none;
    width: 100%;
    justify-content: flex-start;
  }
}
</style>
