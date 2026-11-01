<script setup lang="ts">
/**
 * 营养信息管理：批量查看/编辑菜品营养字段，标出缺失项。
 * 前台营养分析读取同一份数据，并标注估算属性。
 */
import { computed, onMounted, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { adminApi } from '@/api/modules'
import type { Dish, PageResult } from '@/types/api'
import { formatDateTime } from '@/utils/format'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()

const loading = ref(false)
const dishes = ref<Dish[]>([])
const gaps = ref<Record<string, unknown>[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = 10
const keyword = ref('')

const editing = ref<Dish | null>(null)
const saving = ref(false)
const formError = ref('')

const form = ref({
  calories: null as number | null,
  proteinG: null as number | null,
  fatG: null as number | null,
  carbohydrateG: null as number | null,
  fiberG: null as number | null,
  sodiumMg: null as number | null,
  nutritionSource: 'ESTIMATED',
  nutritionNote: ''
})

const totalPages = computed(() => Math.max(Math.ceil(total.value / pageSize), 1))
const missingCount = computed(() => gaps.value.length)

async function load() {
  loading.value = true
  try {
    const [dishPage, gapList] = await Promise.all([
      adminApi.nutritionDishes({ page: page.value, pageSize, keyword: keyword.value || undefined }),
      adminApi.nutritionGaps()
    ])
    const result = dishPage as PageResult<Dish>
    dishes.value = result.records
    total.value = result.total
    gaps.value = gapList
  } catch (e) {
    toast.error('营养数据加载失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    loading.value = false
  }
}

function openEdit(dish: Dish) {
  editing.value = dish
  formError.value = ''
  form.value = {
    calories: dish.calories === null || dish.calories === undefined ? null : Number(dish.calories),
    proteinG: dish.proteinG === null || dish.proteinG === undefined ? null : Number(dish.proteinG),
    fatG: dish.fatG === null || dish.fatG === undefined ? null : Number(dish.fatG),
    carbohydrateG: dish.carbohydrateG === null || dish.carbohydrateG === undefined ? null : Number(dish.carbohydrateG),
    fiberG: dish.fiberG === null || dish.fiberG === undefined ? null : Number(dish.fiberG),
    sodiumMg: dish.sodiumMg === null || dish.sodiumMg === undefined ? null : Number(dish.sodiumMg),
    nutritionSource: dish.nutritionSource || 'ESTIMATED',
    nutritionNote: dish.nutritionNote ?? ''
  }
}

async function save() {
  if (!editing.value || saving.value) {
    return
  }
  const dish = editing.value
  const fields: [string, number | null][] = [
    ['热量', form.value.calories],
    ['蛋白质', form.value.proteinG],
    ['脂肪', form.value.fatG],
    ['碳水', form.value.carbohydrateG],
    ['膳食纤维', form.value.fiberG],
    ['钠', form.value.sodiumMg]
  ]
  for (const [label, value] of fields) {
    if (value !== null && (Number.isNaN(Number(value)) || Number(value) < 0)) {
      formError.value = `${label}必须是非负数字`
      return
    }
  }
  saving.value = true
  formError.value = ''
  try {
    // 复用菜品编辑接口，只提交营养相关字段 + 原有基础字段，避免覆盖其他信息
    await adminApi.updateDish(dish.id, {
      name: dish.name,
      categoryId: dish.categoryId,
      dishCode: dish.dishCode,
      description: dish.description ?? '',
      imageUrl: dish.imageUrl ?? undefined,
      price: Number(dish.price),
      calories: form.value.calories === null ? undefined : Number(form.value.calories),
      proteinG: form.value.proteinG === null ? undefined : Number(form.value.proteinG),
      fatG: form.value.fatG === null ? undefined : Number(form.value.fatG),
      carbohydrateG: form.value.carbohydrateG === null ? undefined : Number(form.value.carbohydrateG),
      fiberG: form.value.fiberG === null ? undefined : Number(form.value.fiberG),
      sodiumMg: form.value.sodiumMg === null ? undefined : Number(form.value.sodiumMg),
      nutritionSource: form.value.nutritionSource,
      nutritionNote: form.value.nutritionNote,
      stock: dish.stock,
      dailyLimit: dish.dailyLimit ?? 0,
      publishStatus: dish.publishStatus,
      supplyStatus: dish.supplyStatus,
      recommendFlag: Boolean(dish.recommendFlag),
      recommendRank: dish.recommendRank ?? 0,
      sortOrder: dish.sortOrder ?? 0,
      homeRecommendation: Boolean(dish.recommendationBadge),
      recommendationBadge: dish.recommendationBadge ?? undefined,
      ingredients: dish.ingredients ?? [],
      allergens: dish.allergens ?? [],
      tags: dish.tags ?? []
    })
    toast.success('营养信息已更新', '前台菜品详情与营养分析将同步更新')
    editing.value = null
    await load()
  } catch (e) {
    formError.value = e instanceof Error ? e.message : '保存失败'
  } finally {
    saving.value = false
  }
}

function search() {
  page.value = 1
  load()
}

function changePage(next: number) {
  if (next < 1 || next > totalPages.value) {
    return
  }
  page.value = next
  load()
}

const sourceLabel: Record<string, string> = { ESTIMATED: '估算值', LABEL: '包装标签', TESTED: '检测报告' }

onMounted(load)
</script>

<template>
  <div class="nutrition-page">
    <header class="page-head">
      <div>
        <h2 class="page-head__title">营养信息管理</h2>
        <p class="page-head__desc">
          前台营养分析基于这里的菜品营养字段聚合估算，界面会明确标注「估算值」；请勿将其当作医学检测结果。
        </p>
      </div>
      <div class="gap-pill" :class="{ 'gap-pill--warn': missingCount > 0 }">
        <AppIcon name="alert-triangle" :size="13" />
        待补全 {{ missingCount }} 道菜品
      </div>
    </header>

    <section class="filter-bar">
      <div class="filter-bar__search">
        <AppIcon name="search" :size="15" class="filter-bar__icon" />
        <input v-model="keyword" class="filter-bar__input" type="search" placeholder="搜索菜品名称" @keyup.enter="search" />
      </div>
      <button class="btn btn--ghost btn--sm" type="button" @click="search">查询</button>
    </section>

    <section class="table-card">
      <div v-if="loading" class="skeleton" style="height: 260px; border-radius: 12px"></div>
      <div v-else-if="dishes.length === 0" class="empty-mini">没有符合条件的菜品</div>
      <table v-else class="data-table">
        <thead>
          <tr>
            <th>菜品</th>
            <th style="width: 84px">热量</th>
            <th style="width: 76px">蛋白质</th>
            <th style="width: 70px">脂肪</th>
            <th style="width: 70px">碳水</th>
            <th style="width: 78px">纤维</th>
            <th style="width: 70px">钠</th>
            <th style="width: 88px">来源</th>
            <th style="width: 140px">更新时间</th>
            <th style="width: 80px">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="dish in dishes" :key="dish.id">
            <td>
              <div class="cell-name">
                <span class="cell-name__main">{{ dish.name }}</span>
                <span class="cell-name__sub">{{ dish.categoryName }} · {{ dish.dishCode }}</span>
              </div>
            </td>
            <td class="num" :class="{ 'cell-missing': dish.calories === null }">{{ dish.calories === null ? '缺失' : Math.round(Number(dish.calories)) }}</td>
            <td class="num" :class="{ 'cell-missing': dish.proteinG === null }">{{ dish.proteinG === null ? '缺失' : Number(dish.proteinG).toFixed(1) }}</td>
            <td class="num" :class="{ 'cell-missing': dish.fatG === null }">{{ dish.fatG === null ? '缺失' : Number(dish.fatG).toFixed(1) }}</td>
            <td class="num" :class="{ 'cell-missing': dish.carbohydrateG === null }">{{ dish.carbohydrateG === null ? '缺失' : Number(dish.carbohydrateG).toFixed(1) }}</td>
            <td class="num" :class="{ 'cell-missing': dish.fiberG === null }">{{ dish.fiberG === null ? '缺失' : Number(dish.fiberG).toFixed(1) }}</td>
            <td class="num" :class="{ 'cell-missing': dish.sodiumMg === null }">{{ dish.sodiumMg === null ? '缺失' : Math.round(Number(dish.sodiumMg)) }}</td>
            <td>
              <span class="pill" :class="dish.nutritionSource === 'ESTIMATED' ? 'pill--amber' : 'pill--sage'">
                {{ sourceLabel[dish.nutritionSource] || dish.nutritionSource }}
              </span>
            </td>
            <td class="cell-time text-muted">{{ formatDateTime(dish.updatedAt) }}</td>
            <td>
              <button class="act" type="button" @click="openEdit(dish)">编辑营养</button>
            </td>
          </tr>
        </tbody>
      </table>
      <footer v-if="dishes.length > 0" class="pager">
        <span class="pager__info">共 {{ total }} 道菜品 · 第 {{ page }} / {{ totalPages }} 页</span>
        <div class="pager__buttons">
          <button class="btn btn--ghost btn--sm" type="button" :disabled="page <= 1" @click="changePage(page - 1)">上一页</button>
          <button class="btn btn--ghost btn--sm" type="button" :disabled="page >= totalPages" @click="changePage(page + 1)">下一页</button>
        </div>
      </footer>
    </section>

    <Transition name="modal">
      <div v-if="editing" class="modal" @click.self="editing = null">
        <div class="modal-box">
          <header class="modal-box__head">
            <div>
              <h3>编辑营养信息 · {{ editing.name }}</h3>
              <p class="modal-box__sub">数值单位：热量 kcal、其余 g / mg（每份）</p>
            </div>
            <button type="button" aria-label="关闭" @click="editing = null"><AppIcon name="close" :size="17" /></button>
          </header>
          <div class="modal-box__body">
            <div class="form-grid">
              <div class="field">
                <label class="field__label" for="nut-cal">热量 kcal</label>
                <input id="nut-cal" v-model.number="form.calories" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="nut-protein">蛋白质 g</label>
                <input id="nut-protein" v-model.number="form.proteinG" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="nut-fat">脂肪 g</label>
                <input id="nut-fat" v-model.number="form.fatG" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="nut-carb">碳水 g</label>
                <input id="nut-carb" v-model.number="form.carbohydrateG" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="nut-fiber">膳食纤维 g</label>
                <input id="nut-fiber" v-model.number="form.fiberG" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="nut-sodium">钠 mg</label>
                <input id="nut-sodium" v-model.number="form.sodiumMg" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="nut-source">数据来源</label>
                <select id="nut-source" v-model="form.nutritionSource" class="select">
                  <option value="ESTIMATED">估算值</option>
                  <option value="LABEL">包装标签</option>
                  <option value="TESTED">检测报告</option>
                </select>
              </div>
              <div class="field">
                <label class="field__label" for="nut-note">营养说明</label>
                <input id="nut-note" v-model="form.nutritionNote" class="input" type="text" maxlength="255" />
              </div>
            </div>
            <p v-if="formError" class="form-error"><AppIcon name="x-circle" :size="13" />{{ formError }}</p>
          </div>
          <footer class="modal-box__foot">
            <button class="btn btn--ghost" type="button" @click="editing = null">取消</button>
            <button class="btn btn--primary" type="button" :disabled="saving" @click="save">
              {{ saving ? '保存中…' : '保存营养信息' }}
            </button>
          </footer>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.nutrition-page {
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
  max-width: 720px;
  line-height: 1.55;
}

.gap-pill {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  height: 28px;
  padding: 0 12px;
  border-radius: var(--radius-pill);
  background: var(--sage-100);
  color: var(--sage-700);
  font-size: var(--font-xs);
  font-weight: 600;
  flex: none;
}

.gap-pill--warn {
  background: var(--amber-100);
  color: var(--amber-600);
}

.filter-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.filter-bar__search {
  position: relative;
  display: flex;
  align-items: center;
  width: 240px;
}

.filter-bar__icon {
  position: absolute;
  left: 11px;
  color: var(--sage-500);
}

.filter-bar__input {
  width: 100%;
  height: 34px;
  padding: 0 12px 0 34px;
  border-radius: var(--radius-pill);
  border: 1px solid rgba(124, 143, 90, 0.2);
  background: #fff;
  outline: none;
  font-size: var(--font-xs);
}

.table-card {
  padding: var(--space-4);
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: var(--font-xs);
}

.data-table th {
  text-align: left;
  padding: 9px 8px;
  font-size: 10.5px;
  font-weight: 600;
  color: var(--ink-500);
  border-bottom: 1px solid rgba(124, 143, 90, 0.16);
  white-space: nowrap;
}

.data-table td {
  padding: 10px 8px;
  border-bottom: 1px solid rgba(124, 143, 90, 0.07);
  color: var(--ink-700);
}

.data-table tbody tr:hover {
  background: var(--sage-50);
}

.cell-name {
  display: flex;
  flex-direction: column;
}

.cell-name__main {
  font-size: var(--font-sm);
  font-weight: 600;
  color: var(--ink-900);
}

.cell-name__sub {
  font-size: 10px;
  color: var(--ink-400);
}

.cell-missing {
  color: var(--danger-600);
  font-weight: 700;
}

.cell-time {
  font-size: 10.5px;
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

.pill--amber {
  background: var(--amber-100);
  color: var(--amber-600);
}

.act {
  padding: 3px 9px;
  border-radius: var(--radius-xs);
  background: var(--sage-50);
  color: var(--sage-700);
  font-size: 10.5px;
  font-weight: 600;
}

.act:hover {
  background: var(--sage-100);
}

.pager {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: var(--space-3);
  margin-top: var(--space-2);
  border-top: 1px solid rgba(124, 143, 90, 0.12);
}

.pager__info {
  font-size: 10.5px;
  color: var(--ink-500);
}

.pager__buttons {
  display: flex;
  gap: 8px;
}

.empty-mini {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-8);
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
  width: min(520px, 100%);
  max-height: 88vh;
  display: flex;
  flex-direction: column;
  border-radius: var(--radius-xl);
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  overflow: hidden;
  animation: scale-in var(--motion-normal) var(--ease-enter) both;
}

.modal-box__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  padding: var(--space-4) var(--space-5);
  border-bottom: 1px solid rgba(124, 143, 90, 0.12);
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.modal-box__sub {
  font-size: 10px;
  color: var(--ink-400);
  font-weight: 400;
  margin-top: 2px;
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

.modal-box__body {
  padding: var(--space-5);
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.modal-box__foot {
  display: flex;
  gap: var(--space-3);
  padding: var(--space-4) var(--space-5);
  border-top: 1px solid rgba(124, 143, 90, 0.12);
}

.modal-box__foot .btn {
  flex: 1;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-3);
}

.select {
  height: 44px;
  width: 100%;
  padding: 0 12px;
  border-radius: var(--radius-sm);
  border: 1px solid rgba(124, 143, 90, 0.24);
  background: #fff;
  outline: none;
}

.form-error {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 8px 11px;
  border-radius: var(--radius-sm);
  background: var(--danger-100);
  color: var(--danger-600);
  font-size: var(--font-xs);
}

@media (max-width: 767px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
}
</style>
