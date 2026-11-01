<script setup lang="ts">
/**
 * 菜品分类管理：新增、编辑、排序、启用/停用、删除（有菜品时禁止）。
 * 前台分类标签使用同一数据源。
 */
import { onMounted, reactive, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { adminApi } from '@/api/modules'
import { categoryIcon } from '@/config/media'
import type { Category } from '@/types/api'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()

const loading = ref(false)
const categories = ref<Category[]>([])
const modalOpen = ref(false)
const modalMode = ref<'create' | 'edit'>('create')
const editingId = ref<number | null>(null)
const saving = ref(false)
const formError = ref('')

const form = reactive({
  name: '',
  code: '',
  icon: 'utensils',
  sortOrder: 0,
  status: 'ACTIVE'
})

const iconOptions = ['rice-bowl', 'drumstick', 'salad', 'noodle', 'soup', 'cup-soda', 'utensils', 'leaf', 'flame']

const confirmDeleteId = ref<number | null>(null)

async function load() {
  loading.value = true
  try {
    categories.value = await adminApi.categories()
  } catch (e) {
    toast.error('分类加载失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    loading.value = false
  }
}

function openCreate() {
  modalMode.value = 'create'
  editingId.value = null
  formError.value = ''
  Object.assign(form, { name: '', code: '', icon: 'utensils', sortOrder: categories.value.length + 1, status: 'ACTIVE' })
  modalOpen.value = true
}

function openEdit(category: Category) {
  modalMode.value = 'edit'
  editingId.value = category.id
  formError.value = ''
  Object.assign(form, {
    name: category.name,
    code: category.code,
    icon: category.icon || 'utensils',
    sortOrder: category.sortOrder,
    status: category.status
  })
  modalOpen.value = true
}

async function save() {
  formError.value = ''
  if (!form.name.trim()) {
    formError.value = '请输入分类名称'
    return
  }
  saving.value = true
  try {
    const payload = {
      name: form.name.trim(),
      code: modalMode.value === 'create' ? form.code.trim() || undefined : form.code,
      icon: form.icon,
      sortOrder: Number(form.sortOrder) || 0,
      status: form.status
    }
    if (modalMode.value === 'create') {
      await adminApi.createCategory(payload)
      toast.success('分类已创建', '前台分类标签将同步更新')
    } else if (editingId.value) {
      await adminApi.updateCategory(editingId.value, payload)
      toast.success('分类已更新')
    }
    modalOpen.value = false
    await load()
  } catch (e) {
    formError.value = e instanceof Error ? e.message : '保存失败'
  } finally {
    saving.value = false
  }
}

async function toggleStatus(category: Category) {
  const next = category.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'
  try {
    await adminApi.changeCategoryStatus(category.id, next)
    toast.success(next === 'ACTIVE' ? '已启用' : '已停用', category.name)
    await load()
  } catch (e) {
    toast.error('状态更新失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

async function move(category: Category, direction: -1 | 1) {
  const sorted = [...categories.value].sort((a, b) => a.sortOrder - b.sortOrder)
  const index = sorted.findIndex((item) => item.id === category.id)
  const target = index + direction
  if (target < 0 || target >= sorted.length) {
    return
  }
  const items = sorted.map((item, idx) => ({ id: item.id, sortOrder: idx + 1 }))
  // 交换顺序值
  const a = items[index]
  const b = items[target]
  const temp = a.sortOrder
  a.sortOrder = b.sortOrder
  b.sortOrder = temp
  try {
    await adminApi.sortCategories(items)
    await load()
    toast.success('排序已保存')
  } catch (e) {
    toast.error('排序保存失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

async function doDelete() {
  if (!confirmDeleteId.value) {
    return
  }
  try {
    await adminApi.deleteCategory(confirmDeleteId.value)
    toast.success('分类已删除')
    confirmDeleteId.value = null
    await load()
  } catch (e) {
    toast.error('删除失败', e instanceof Error ? e.message : '该分类下可能仍有菜品')
    confirmDeleteId.value = null
  }
}

onMounted(load)
</script>

<template>
  <div class="cats-page">
    <header class="page-head">
      <div>
        <h2 class="page-head__title">菜品分类</h2>
        <p class="page-head__desc">分类顺序即前台标签顺序；停用后前台不再展示该分类，历史订单不受影响。</p>
      </div>
      <button class="btn btn--primary btn--sm" type="button" @click="openCreate">
        <AppIcon name="plus" :size="14" />新增分类
      </button>
    </header>

    <div v-if="loading" class="cat-grid">
      <div v-for="i in 6" :key="i" class="skeleton" style="height: 104px; border-radius: 16px"></div>
    </div>

    <div v-else-if="categories.length === 0" class="empty-state">
      <AppIcon name="tag" :size="28" />
      <p>还没有分类，先创建一个吧</p>
      <button class="btn btn--primary btn--sm" type="button" @click="openCreate">新增分类</button>
    </div>

    <div v-else class="cat-grid">
      <article v-for="(category, index) in categories" :key="category.id" class="cat-card" :class="{ 'cat-card--off': category.status !== 'ACTIVE' }">
        <div class="cat-card__top">
          <span class="cat-card__icon"><AppIcon :name="categoryIcon(category.code, category.icon)" :size="20" /></span>
          <span class="pill" :class="category.status === 'ACTIVE' ? 'pill--sage' : 'pill--muted'">
            {{ category.status === 'ACTIVE' ? '启用中' : '已停用' }}
          </span>
        </div>
        <h3 class="cat-card__name">{{ category.name }}</h3>
        <p class="cat-card__meta">
          <span class="num">{{ category.code }}</span>
          <span class="cat-card__dot">·</span>
          <span class="num">{{ category.dishCount }} 道菜</span>
          <span class="cat-card__dot">·</span>
          <span class="num">排序 {{ category.sortOrder }}</span>
        </p>
        <div class="cat-card__actions">
          <button class="act" type="button" :disabled="index === 0" @click="move(category, -1)" aria-label="上移">↑</button>
          <button class="act" type="button" :disabled="index === categories.length - 1" @click="move(category, 1)" aria-label="下移">↓</button>
          <button class="act" type="button" @click="openEdit(category)">编辑</button>
          <button class="act" type="button" @click="toggleStatus(category)">
            {{ category.status === 'ACTIVE' ? '停用' : '启用' }}
          </button>
          <button class="act act--danger" type="button" @click="confirmDeleteId = category.id">删除</button>
        </div>
      </article>
    </div>

    <!-- 弹窗 -->
    <Transition name="modal">
      <div v-if="modalOpen" class="modal" @click.self="modalOpen = false">
        <div class="modal-box">
          <header class="modal-box__head">
            <h3>{{ modalMode === 'create' ? '新增分类' : '编辑分类' }}</h3>
            <button type="button" aria-label="关闭" @click="modalOpen = false"><AppIcon name="close" :size="17" /></button>
          </header>
          <div class="modal-box__body">
            <div class="field">
              <label class="field__label" for="cat-name">分类名称 <span class="required">*</span></label>
              <input id="cat-name" v-model="form.name" class="input" type="text" maxlength="50" placeholder="例如：主食套餐" />
            </div>
            <div class="field">
              <label class="field__label" for="cat-code">分类编码</label>
              <input
                id="cat-code"
                v-model="form.code"
                class="input"
                type="text"
                maxlength="30"
                :disabled="modalMode === 'edit'"
                placeholder="留空自动生成，创建后不可修改"
              />
            </div>
            <div class="field">
              <label class="field__label" for="cat-icon">图标</label>
              <div class="icon-picker">
                <button
                  v-for="icon in iconOptions"
                  :key="icon"
                  class="icon-option"
                  :class="{ 'icon-option--active': form.icon === icon }"
                  type="button"
                  :aria-label="`选择图标 ${icon}`"
                  @click="form.icon = icon"
                >
                  <AppIcon :name="icon" :size="18" />
                </button>
              </div>
            </div>
            <div class="field-row">
              <div class="field">
                <label class="field__label" for="cat-sort">排序值</label>
                <input id="cat-sort" v-model.number="form.sortOrder" class="input" type="number" min="0" step="1" />
              </div>
              <div class="field">
                <label class="field__label" for="cat-status">状态</label>
                <select id="cat-status" v-model="form.status" class="select">
                  <option value="ACTIVE">启用</option>
                  <option value="INACTIVE">停用</option>
                </select>
              </div>
            </div>
            <p v-if="formError" class="form-error"><AppIcon name="x-circle" :size="13" />{{ formError }}</p>
          </div>
          <footer class="modal-box__foot">
            <button class="btn btn--ghost" type="button" @click="modalOpen = false">取消</button>
            <button class="btn btn--primary" type="button" :disabled="saving" @click="save">
              {{ saving ? '保存中…' : '保存' }}
            </button>
          </footer>
        </div>
      </div>
    </Transition>

    <Transition name="modal">
      <div v-if="confirmDeleteId" class="modal" @click.self="confirmDeleteId = null">
        <div class="modal-box modal-box--sm">
          <div class="confirm">
            <span class="confirm__icon"><AppIcon name="alert-triangle" :size="20" /></span>
            <h3 class="confirm__title">确认删除该分类？</h3>
            <p class="confirm__desc">若该分类下仍有菜品，删除会被拒绝，请先迁移菜品。</p>
            <div class="confirm__actions">
              <button class="btn btn--ghost" type="button" @click="confirmDeleteId = null">取消</button>
              <button class="btn btn--primary confirm__danger" type="button" @click="doDelete">确认删除</button>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.cats-page {
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
  line-height: 1.5;
}

.cat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(258px, 1fr));
  gap: var(--space-3);
}

.cat-card {
  display: flex;
  flex-direction: column;
  gap: 7px;
  padding: 14px 16px;
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
  transition: transform var(--motion-normal) var(--ease-standard),
    box-shadow var(--motion-normal) var(--ease-standard);
}

.cat-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-sm);
}

.cat-card--off {
  opacity: 0.72;
}

.cat-card__top {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.cat-card__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  border-radius: var(--radius-sm);
  background: linear-gradient(150deg, var(--apricot-100), var(--sage-100));
  color: var(--sage-700);
}

.cat-card__name {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.cat-card__meta {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 10.5px;
  color: var(--ink-500);
  flex-wrap: wrap;
}

.cat-card__dot {
  color: var(--ink-300);
}

.cat-card__actions {
  display: flex;
  gap: 4px;
  margin-top: 2px;
  flex-wrap: wrap;
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

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: var(--space-10);
  color: var(--ink-400);
  font-size: var(--font-sm);
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
  width: min(460px, 100%);
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  border-radius: var(--radius-xl);
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  overflow: hidden;
  animation: scale-in var(--motion-normal) var(--ease-enter) both;
}

.modal-box--sm {
  width: min(400px, 100%);
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

.modal-box__body {
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  overflow-y: auto;
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

.field-row {
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

.icon-picker {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.icon-option {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(124, 143, 90, 0.16);
  color: var(--sage-600);
  transition: all var(--motion-fast) var(--ease-standard);
}

.icon-option:hover {
  border-color: var(--sage-400);
}

.icon-option--active {
  background: var(--sage-100);
  border-color: var(--sage-500);
  color: var(--sage-800);
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

.confirm {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: var(--space-6);
  text-align: center;
}

.confirm__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: var(--danger-100);
  color: var(--danger-600);
}

.confirm__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.confirm__desc {
  font-size: var(--font-xs);
  color: var(--ink-500);
  line-height: 1.6;
}

.confirm__actions {
  display: flex;
  gap: var(--space-3);
  width: 100%;
  margin-top: var(--space-2);
}

.confirm__actions .btn {
  flex: 1;
}

.confirm__danger {
  background: linear-gradient(135deg, var(--danger-500), var(--danger-600));
}
</style>
