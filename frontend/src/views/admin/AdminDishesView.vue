<script setup lang="ts">
/**
 * 菜品管理：列表筛选、分页、新增/编辑抽屉、上下架、复制、删除。
 * 与前台共用同一套 dish 数据：保存后前台重新请求即可见。
 */
import { computed, onMounted, reactive, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { adminApi } from '@/api/modules'
import { DISH_PLACEHOLDER } from '@/config/media'
import type { Category, Dish, PageResult } from '@/types/api'
import { formatDateTime, formatMoney, formatPrice } from '@/utils/format'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()

const loading = ref(false)
const dishes = ref<Dish[]>([])
const categories = ref<Category[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)

const filters = reactive({
  keyword: '',
  categoryId: null as number | null,
  publishStatus: '',
  supplyStatus: '',
  sort: 'created_desc'
})

const drawerOpen = ref(false)
const drawerMode = ref<'create' | 'edit'>('create')
const editingId = ref<number | null>(null)
const saving = ref(false)
const uploading = ref(false)
const formError = ref('')

const form = reactive({
  name: '',
  dishCode: '',
  categoryId: null as number | null,
  description: '',
  imageUrl: '',
  price: 0,
  calories: null as number | null,
  proteinG: null as number | null,
  fatG: null as number | null,
  carbohydrateG: null as number | null,
  fiberG: null as number | null,
  sodiumMg: null as number | null,
  nutritionSource: 'ESTIMATED',
  nutritionNote: '课堂演示估算值，非实验室检测数据',
  stock: 0,
  dailyLimit: 0,
  publishStatus: 'DRAFT',
  supplyStatus: 'AVAILABLE',
  recommendFlag: false,
  recommendRank: 0,
  sortOrder: 0,
  homeRecommendation: false,
  recommendationBadge: '今日推荐',
  ingredientsText: '',
  allergensText: '',
  tagsText: ''
})

const totalPages = computed(() => Math.max(Math.ceil(total.value / pageSize.value), 1))

const drawerTitle = computed(() => (drawerMode.value === 'create' ? '新增菜品' : `编辑菜品 · ${form.name}`))

async function loadCategories() {
  try {
    categories.value = await adminApi.categories()
  } catch {
    categories.value = []
  }
}

async function load() {
  loading.value = true
  try {
    const result: PageResult<Dish> = await adminApi.dishes({
      page: page.value,
      pageSize: pageSize.value,
      keyword: filters.keyword || undefined,
      categoryId: filters.categoryId ?? undefined,
      publishStatus: filters.publishStatus || undefined,
      supplyStatus: filters.supplyStatus || undefined,
      sort: filters.sort
    })
    dishes.value = result.records
    total.value = result.total
  } catch (e) {
    toast.error('菜品列表加载失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    loading.value = false
  }
}

function search() {
  page.value = 1
  load()
}

function resetFilters() {
  filters.keyword = ''
  filters.categoryId = null
  filters.publishStatus = ''
  filters.supplyStatus = ''
  filters.sort = 'created_desc'
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

function openCreate() {
  drawerMode.value = 'create'
  editingId.value = null
  formError.value = ''
  Object.assign(form, {
    name: '',
    dishCode: '',
    categoryId: categories.value[0]?.id ?? null,
    description: '',
    imageUrl: '',
    price: 0,
    calories: null,
    proteinG: null,
    fatG: null,
    carbohydrateG: null,
    fiberG: null,
    sodiumMg: null,
    nutritionSource: 'ESTIMATED',
    nutritionNote: '课堂演示估算值，非实验室检测数据',
    stock: 0,
    dailyLimit: 0,
    publishStatus: 'DRAFT',
    supplyStatus: 'AVAILABLE',
    recommendFlag: false,
    recommendRank: 0,
    sortOrder: 0,
    homeRecommendation: false,
    recommendationBadge: '今日推荐',
    ingredientsText: '',
    allergensText: '',
    tagsText: ''
  })
  drawerOpen.value = true
}

function openEdit(dish: Dish) {
  drawerMode.value = 'edit'
  editingId.value = dish.id
  formError.value = ''
  Object.assign(form, {
    name: dish.name,
    dishCode: dish.dishCode,
    categoryId: dish.categoryId,
    description: dish.description ?? '',
    imageUrl: dish.imageUrl ?? '',
    price: Number(dish.price),
    calories: dish.calories === null || dish.calories === undefined ? null : Number(dish.calories),
    proteinG: dish.proteinG === null || dish.proteinG === undefined ? null : Number(dish.proteinG),
    fatG: dish.fatG === null || dish.fatG === undefined ? null : Number(dish.fatG),
    carbohydrateG: dish.carbohydrateG === null || dish.carbohydrateG === undefined ? null : Number(dish.carbohydrateG),
    fiberG: dish.fiberG === null || dish.fiberG === undefined ? null : Number(dish.fiberG),
    sodiumMg: dish.sodiumMg === null || dish.sodiumMg === undefined ? null : Number(dish.sodiumMg),
    nutritionSource: dish.nutritionSource || 'ESTIMATED',
    nutritionNote: dish.nutritionNote ?? '',
    stock: dish.stock,
    dailyLimit: dish.dailyLimit ?? 0,
    publishStatus: dish.publishStatus,
    supplyStatus: dish.supplyStatus,
    recommendFlag: Boolean(dish.recommendFlag),
    recommendRank: dish.recommendRank ?? 0,
    sortOrder: dish.sortOrder ?? 0,
    homeRecommendation: Boolean(dish.recommendationBadge),
    recommendationBadge: dish.recommendationBadge ?? '今日推荐',
    ingredientsText: (dish.ingredients ?? []).join('、'),
    allergensText: (dish.allergens ?? []).join('、'),
    tagsText: (dish.tags ?? []).join('、')
  })
  drawerOpen.value = true
}

function validate(): boolean {
  formError.value = ''
  if (!form.name.trim()) {
    formError.value = '请输入菜品名称'
    return false
  }
  if (!form.categoryId) {
    formError.value = '请选择菜品分类'
    return false
  }
  if (form.price === null || Number.isNaN(Number(form.price)) || Number(form.price) < 0) {
    formError.value = '售价必须大于等于 0'
    return false
  }
  if (Number(form.price) > 9999.99) {
    formError.value = '售价超出合理范围'
    return false
  }
  if (!Number.isInteger(Number(form.stock)) || Number(form.stock) < 0) {
    formError.value = '库存必须是非负整数'
    return false
  }
  const nutritionFields: [string, number | null][] = [
    ['热量', form.calories],
    ['蛋白质', form.proteinG],
    ['脂肪', form.fatG],
    ['碳水', form.carbohydrateG],
    ['膳食纤维', form.fiberG],
    ['钠', form.sodiumMg]
  ]
  for (const [label, value] of nutritionFields) {
    if (value !== null && (Number.isNaN(Number(value)) || Number(value) < 0)) {
      formError.value = `${label}必须是非负数字`
      return false
    }
  }
  return true
}

function splitList(text: string): string[] {
  return text
    .split(/[、,，\n]/)
    .map((item) => item.trim())
    .filter(Boolean)
}

async function save() {
  if (!validate() || saving.value) {
    return
  }
  saving.value = true
  try {
    const payload = {
      name: form.name.trim(),
      dishCode: form.dishCode.trim() || undefined,
      categoryId: form.categoryId,
      description: form.description,
      imageUrl: form.imageUrl || undefined,
      price: Number(form.price),
      calories: form.calories === null ? undefined : Number(form.calories),
      proteinG: form.proteinG === null ? undefined : Number(form.proteinG),
      fatG: form.fatG === null ? undefined : Number(form.fatG),
      carbohydrateG: form.carbohydrateG === null ? undefined : Number(form.carbohydrateG),
      fiberG: form.fiberG === null ? undefined : Number(form.fiberG),
      sodiumMg: form.sodiumMg === null ? undefined : Number(form.sodiumMg),
      nutritionSource: form.nutritionSource,
      nutritionNote: form.nutritionNote,
      stock: Number(form.stock),
      dailyLimit: Number(form.dailyLimit) || 0,
      publishStatus: form.publishStatus,
      supplyStatus: form.supplyStatus,
      recommendFlag: form.recommendFlag,
      recommendRank: Number(form.recommendRank) || 0,
      sortOrder: Number(form.sortOrder) || 0,
      homeRecommendation: form.homeRecommendation,
      recommendationBadge: form.recommendationBadge,
      ingredients: splitList(form.ingredientsText),
      allergens: splitList(form.allergensText),
      tags: splitList(form.tagsText)
    }
    if (drawerMode.value === 'create') {
      await adminApi.createDish(payload)
      toast.success('菜品已创建', '若状态为已上架且供应中，前台菜单会立即出现该菜品')
    } else if (editingId.value) {
      await adminApi.updateDish(editingId.value, payload)
      toast.success('菜品已更新', '前台展示将同步更新，历史订单快照不变')
    }
    drawerOpen.value = false
    await load()
  } catch (e) {
    formError.value = e instanceof Error ? e.message : '保存失败，请稍后重试'
  } finally {
    saving.value = false
  }
}

async function togglePublish(dish: Dish) {
  const next = dish.publishStatus === 'PUBLISHED' ? 'UNPUBLISHED' : 'PUBLISHED'
  try {
    await adminApi.changeDishStatus(dish.id, next)
    toast.success(next === 'PUBLISHED' ? '已上架' : '已下架', dish.name)
    await load()
  } catch (e) {
    toast.error('状态更新失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

async function toggleSupply(dish: Dish) {
  const next = dish.supplyStatus === 'AVAILABLE' ? 'PAUSED' : 'AVAILABLE'
  try {
    await adminApi.changeSupplyStatus(dish.id, next)
    toast.success(next === 'AVAILABLE' ? '已恢复供应' : '已暂停供应', dish.name)
    await load()
  } catch (e) {
    toast.error('供应状态更新失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

async function copyDish(dish: Dish) {
  try {
    await adminApi.copyDish(dish.id)
    toast.success('已复制为草稿', '请补充库存与上架状态')
    await load()
  } catch (e) {
    toast.error('复制失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

const confirmDeleteId = ref<number | null>(null)

function askDelete(dish: Dish) {
  confirmDeleteId.value = dish.id
}

async function doDelete() {
  if (!confirmDeleteId.value) {
    return
  }
  try {
    await adminApi.deleteDish(confirmDeleteId.value)
    toast.success('菜品已删除', '历史订单中的菜品快照仍然保留')
    confirmDeleteId.value = null
    await load()
  } catch (e) {
    toast.error('删除失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

function onFilePick(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) {
    return
  }
  if (file.size > 5 * 1024 * 1024) {
    formError.value = '图片不能超过 5MB'
    return
  }
  if (!/^image\/(jpeg|png|webp)$/.test(file.type)) {
    formError.value = '仅支持 jpg / png / webp 图片'
    return
  }
  uploading.value = true
  adminApi
    .uploadDishImage(file)
    .then((result) => {
      form.imageUrl = result.url
      toast.success('图片上传成功', `尺寸 ${result.width}×${result.height}`)
    })
    .catch((e) => {
      formError.value = e instanceof Error ? e.message : '上传失败'
    })
    .finally(() => {
      uploading.value = false
      input.value = ''
    })
}

const publishLabel: Record<string, string> = { DRAFT: '草稿', PUBLISHED: '已上架', UNPUBLISHED: '已下架' }
const supplyLabel: Record<string, string> = { AVAILABLE: '供应中', SOLD_OUT: '已售罄', PAUSED: '暂停供应' }

onMounted(async () => {
  await loadCategories()
  await load()
})
</script>

<template>
  <div class="dishes-page">
    <!-- 筛选栏 -->
    <section class="filter-bar">
      <div class="filter-bar__search">
        <AppIcon name="search" :size="15" class="filter-bar__icon" />
        <input
          v-model="filters.keyword"
          class="filter-bar__input"
          type="search"
          placeholder="搜索菜品名称或菜品编码"
          @keyup.enter="search"
        />
      </div>
      <select v-model="filters.categoryId" class="select" @change="search">
        <option :value="null">全部分类</option>
        <option v-for="category in categories" :key="category.id" :value="category.id">{{ category.name }}</option>
      </select>
      <select v-model="filters.publishStatus" class="select" @change="search">
        <option value="">全部上架状态</option>
        <option value="PUBLISHED">已上架</option>
        <option value="UNPUBLISHED">已下架</option>
        <option value="DRAFT">草稿</option>
      </select>
      <select v-model="filters.supplyStatus" class="select" @change="search">
        <option value="">全部供应状态</option>
        <option value="AVAILABLE">供应中</option>
        <option value="SOLD_OUT">已售罄</option>
        <option value="PAUSED">暂停供应</option>
      </select>
      <select v-model="filters.sort" class="select" @change="search">
        <option value="created_desc">创建时间倒序</option>
        <option value="sales_desc">销量优先</option>
        <option value="price_asc">价格升序</option>
        <option value="price_desc">价格降序</option>
        <option value="stock_asc">库存升序</option>
      </select>
      <button class="btn btn--ghost btn--sm" type="button" @click="resetFilters">重置</button>
      <button class="btn btn--primary btn--sm filter-bar__add" type="button" @click="openCreate">
        <AppIcon name="plus" :size="14" />新增菜品
      </button>
    </section>

    <!-- 表格 -->
    <section class="table-card">
      <div v-if="loading" class="table-skeleton">
        <div v-for="i in 6" :key="i" class="skeleton" style="height: 46px; border-radius: 8px"></div>
      </div>

      <div v-else-if="dishes.length === 0" class="empty-state">
        <span class="empty-state__art"><AppIcon name="dish" :size="30" /></span>
        <p class="empty-state__title">没有找到菜品</p>
        <p class="empty-state__desc">调整筛选条件，或点击右上角「新增菜品」创建第一道菜。</p>
        <button class="btn btn--primary btn--sm" type="button" @click="openCreate">新增菜品</button>
      </div>

      <table v-else class="data-table">
        <thead>
          <tr>
            <th style="width: 76px">图片</th>
            <th>菜品</th>
            <th style="width: 104px">分类</th>
            <th style="width: 90px">价格</th>
            <th style="width: 92px">热量</th>
            <th style="width: 92px">库存</th>
            <th style="width: 96px">供应状态</th>
            <th style="width: 96px">上架状态</th>
            <th style="width: 150px">更新时间</th>
            <th style="width: 208px">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="dish in dishes" :key="dish.id">
            <td>
              <img class="cell-img" :src="dish.imageUrl || DISH_PLACEHOLDER" :alt="dish.name" />
            </td>
            <td>
              <div class="cell-name">
                <span class="cell-name__main">{{ dish.name }}</span>
                <span class="cell-name__sub">{{ dish.dishCode }}<template v-if="dish.recommendFlag"> · 首页推荐</template></span>
              </div>
            </td>
            <td>{{ dish.categoryName || '—' }}</td>
            <td class="num">¥{{ formatPrice(dish.price) }}</td>
            <td class="num">{{ dish.calories === null || dish.calories === undefined ? '—' : Math.round(Number(dish.calories)) }} kcal</td>
            <td>
              <span class="stock num" :class="{ 'stock--low': dish.stock <= 10, 'stock--zero': dish.stock <= 0 }">
                {{ dish.stock }}
              </span>
            </td>
            <td>
              <span class="pill" :class="dish.supplyStatus === 'AVAILABLE' ? 'pill--sage' : dish.supplyStatus === 'SOLD_OUT' ? 'pill--danger' : 'pill--muted'">
                {{ supplyLabel[dish.supplyStatus] || dish.supplyStatus }}
              </span>
            </td>
            <td>
              <span class="pill" :class="dish.publishStatus === 'PUBLISHED' ? 'pill--sage' : dish.publishStatus === 'DRAFT' ? 'pill--muted' : 'pill--amber'">
                {{ publishLabel[dish.publishStatus] || dish.publishStatus }}
              </span>
            </td>
            <td class="text-muted cell-time">{{ formatDateTime(dish.updatedAt) }}</td>
            <td>
              <div class="row-actions">
                <button class="act" type="button" @click="openEdit(dish)">编辑</button>
                <button class="act" type="button" @click="togglePublish(dish)">
                  {{ dish.publishStatus === 'PUBLISHED' ? '下架' : '上架' }}
                </button>
                <button class="act" type="button" @click="toggleSupply(dish)">
                  {{ dish.supplyStatus === 'AVAILABLE' ? '暂停' : '恢复' }}
                </button>
                <button class="act" type="button" @click="copyDish(dish)">复制</button>
                <button class="act act--danger" type="button" @click="askDelete(dish)">删除</button>
              </div>
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

    <!-- 新增/编辑抽屉 -->
    <Transition name="panel">
      <div v-if="drawerOpen" class="drawer-mask" @click.self="drawerOpen = false">
        <aside class="drawer">
          <header class="drawer__head">
            <div>
              <h2 class="drawer__title">{{ drawerTitle }}</h2>
              <p class="drawer__sub">营养与价格为课堂演示数据，请按实际情况填写</p>
            </div>
            <button class="drawer__close" type="button" aria-label="关闭" @click="drawerOpen = false">
              <AppIcon name="close" :size="17" />
            </button>
          </header>

          <div class="drawer__body">
            <div class="form-grid">
              <div class="field form-grid__full">
                <label class="field__label" for="dish-name">菜品名称 <span class="required">*</span></label>
                <input id="dish-name" v-model="form.name" class="input" type="text" maxlength="100" placeholder="例如：香煎鸡胸藜麦饭" />
              </div>

              <div class="field">
                <label class="field__label" for="dish-code">菜品编码</label>
                <input id="dish-code" v-model="form.dishCode" class="input" type="text" maxlength="40" placeholder="留空自动生成" />
              </div>

              <div class="field">
                <label class="field__label" for="dish-category">分类 <span class="required">*</span></label>
                <select id="dish-category" v-model="form.categoryId" class="select select--block">
                  <option :value="null" disabled>请选择分类</option>
                  <option v-for="category in categories" :key="category.id" :value="category.id">{{ category.name }}</option>
                </select>
              </div>

              <div class="field form-grid__full">
                <label class="field__label" for="dish-desc">菜品简介</label>
                <textarea id="dish-desc" v-model="form.description" class="input" maxlength="500" rows="2" placeholder="一句话描述这道菜"></textarea>
              </div>

              <div class="field form-grid__full">
                <label class="field__label" for="dish-image">菜品图片</label>
                <div class="image-row">
                  <div class="image-preview">
                    <img :src="form.imageUrl || DISH_PLACEHOLDER" alt="菜品预览" />
                  </div>
                  <div class="image-actions">
                    <label class="btn btn--ghost btn--sm upload-btn">
                      <AppIcon name="upload" :size="14" />
                      {{ uploading ? '上传中…' : '上传图片' }}
                      <input type="file" accept="image/jpeg,image/png,image/webp" hidden @change="onFilePick" />
                    </label>
                    <input v-model="form.imageUrl" class="input input--sm" type="text" placeholder="或填写 /assets/images/dishes/D001.webp" />
                    <p class="image-hint">支持 jpg/png/webp，≤5MB。上传文件保存在后端 uploads 目录，换机需一并拷贝。</p>
                  </div>
                </div>
              </div>

              <div class="field">
                <label class="field__label" for="dish-price">售价（元） <span class="required">*</span></label>
                <input id="dish-price" v-model.number="form.price" class="input" type="number" min="0" step="0.01" />
              </div>

              <div class="field">
                <label class="field__label" for="dish-stock">库存（份） <span class="required">*</span></label>
                <input id="dish-stock" v-model.number="form.stock" class="input" type="number" min="0" step="1" />
              </div>

              <div class="field">
                <label class="field__label" for="dish-publish">上架状态</label>
                <select id="dish-publish" v-model="form.publishStatus" class="select select--block">
                  <option value="DRAFT">草稿（前台不可见）</option>
                  <option value="PUBLISHED">已上架</option>
                  <option value="UNPUBLISHED">已下架</option>
                </select>
              </div>

              <div class="field">
                <label class="field__label" for="dish-supply">供应状态</label>
                <select id="dish-supply" v-model="form.supplyStatus" class="select select--block">
                  <option value="AVAILABLE">供应中</option>
                  <option value="SOLD_OUT">已售罄</option>
                  <option value="PAUSED">暂停供应</option>
                </select>
              </div>

              <div class="field">
                <label class="field__label" for="dish-daily">每日供应量</label>
                <input id="dish-daily" v-model.number="form.dailyLimit" class="input" type="number" min="0" step="1" placeholder="0 表示不限" />
              </div>

              <div class="field">
                <label class="field__label" for="dish-sort">排序值</label>
                <input id="dish-sort" v-model.number="form.sortOrder" class="input" type="number" min="0" step="1" />
              </div>
            </div>

            <h3 class="form-section">营养信息（估算值）</h3>
            <div class="form-grid form-grid--4">
              <div class="field">
                <label class="field__label" for="dish-cal">热量 kcal</label>
                <input id="dish-cal" v-model.number="form.calories" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="dish-protein">蛋白质 g</label>
                <input id="dish-protein" v-model.number="form.proteinG" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="dish-fat">脂肪 g</label>
                <input id="dish-fat" v-model.number="form.fatG" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="dish-carb">碳水 g</label>
                <input id="dish-carb" v-model.number="form.carbohydrateG" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="dish-fiber">膳食纤维 g</label>
                <input id="dish-fiber" v-model.number="form.fiberG" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="dish-sodium">钠 mg</label>
                <input id="dish-sodium" v-model.number="form.sodiumMg" class="input" type="number" min="0" step="0.01" />
              </div>
              <div class="field">
                <label class="field__label" for="dish-nutri-source">数据来源</label>
                <select id="dish-nutri-source" v-model="form.nutritionSource" class="select select--block">
                  <option value="ESTIMATED">估算值</option>
                  <option value="LABEL">包装标签</option>
                  <option value="TESTED">检测报告</option>
                </select>
              </div>
              <div class="field">
                <label class="field__label" for="dish-nutri-note">营养说明</label>
                <input id="dish-nutri-note" v-model="form.nutritionNote" class="input" type="text" maxlength="255" />
              </div>
            </div>

            <h3 class="form-section">食材 / 过敏原 / 标签</h3>
            <div class="form-grid">
              <div class="field">
                <label class="field__label" for="dish-ing">主要食材（用、分隔）</label>
                <input id="dish-ing" v-model="form.ingredientsText" class="input" type="text" placeholder="鸡胸肉、藜麦、西兰花" />
              </div>
              <div class="field">
                <label class="field__label" for="dish-allergen">过敏原（用、分隔）</label>
                <input id="dish-allergen" v-model="form.allergensText" class="input" type="text" placeholder="可能含大豆、小麦" />
              </div>
              <div class="field form-grid__full">
                <label class="field__label" for="dish-tags">标签（用、分隔）</label>
                <input id="dish-tags" v-model="form.tagsText" class="input" type="text" placeholder="低脂、高蛋白、今日推荐" />
              </div>
            </div>

            <h3 class="form-section">推荐位</h3>
            <div class="form-grid">
              <label class="switch-row">
                <input v-model="form.recommendFlag" type="checkbox" />
                <span class="switch-row__box"></span>
                <span>在菜单标记为推荐</span>
              </label>
              <label class="switch-row">
                <input v-model="form.homeRecommendation" type="checkbox" />
                <span class="switch-row__box"></span>
                <span>加入首页今日推荐</span>
              </label>
              <div class="field">
                <label class="field__label" for="dish-badge">推荐标签文案</label>
                <input id="dish-badge" v-model="form.recommendationBadge" class="input" type="text" maxlength="40" placeholder="今日推荐" />
              </div>
              <div class="field">
                <label class="field__label" for="dish-rank">推荐排序</label>
                <input id="dish-rank" v-model.number="form.recommendRank" class="input" type="number" min="0" step="1" />
              </div>
            </div>

            <p v-if="formError" class="form-error">
              <AppIcon name="x-circle" :size="13" />{{ formError }}
            </p>
          </div>

          <footer class="drawer__foot">
            <button class="btn btn--ghost" type="button" :disabled="saving" @click="drawerOpen = false">取消</button>
            <button class="btn btn--primary" type="button" :disabled="saving || uploading" @click="save">
              {{ saving ? '保存中…' : '保存菜品' }}
            </button>
          </footer>
        </aside>
      </div>
    </Transition>

    <!-- 删除确认 -->
    <Transition name="modal">
      <div v-if="confirmDeleteId" class="confirm-mask" @click.self="confirmDeleteId = null">
        <div class="confirm-box">
          <span class="confirm-box__icon"><AppIcon name="alert-triangle" :size="22" /></span>
          <h3 class="confirm-box__title">确认删除该菜品？</h3>
          <p class="confirm-box__desc">
            删除为逻辑删除，前台将不再展示；历史订单中的菜品名称、单价与营养快照不受影响。
          </p>
          <div class="confirm-box__actions">
            <button class="btn btn--ghost" type="button" @click="confirmDeleteId = null">取消</button>
            <button class="btn btn--primary confirm-box__danger" type="button" @click="doDelete">确认删除</button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.dishes-page {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.filter-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.filter-bar__search {
  position: relative;
  display: flex;
  align-items: center;
  width: 250px;
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

.filter-bar__input:focus {
  border-color: var(--sage-400);
  box-shadow: var(--shadow-glow);
}

.filter-bar__add {
  margin-left: auto;
}

.select {
  height: 34px;
  padding: 0 10px;
  border-radius: var(--radius-sm);
  border: 1px solid rgba(124, 143, 90, 0.2);
  background: #fff;
  color: var(--ink-700);
  font-size: var(--font-xs);
  outline: none;
}

.select:focus {
  border-color: var(--sage-400);
  box-shadow: var(--shadow-glow);
}

.select--block {
  width: 100%;
  height: 44px;
  font-size: var(--font-base);
}

.table-card {
  padding: var(--space-4);
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.table-skeleton {
  display: flex;
  flex-direction: column;
  gap: 8px;
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
  vertical-align: middle;
}

.data-table tbody tr {
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.data-table tbody tr:hover {
  background: var(--sage-50);
}

.cell-img {
  width: 52px;
  height: 40px;
  border-radius: var(--radius-xs);
  object-fit: cover;
}

.cell-name {
  display: flex;
  flex-direction: column;
  gap: 1px;
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

.cell-time {
  font-size: 10.5px;
}

.stock {
  font-weight: 700;
  color: var(--ink-700);
}

.stock--low {
  color: var(--amber-600);
}

.stock--zero {
  color: var(--danger-600);
}

.pill {
  display: inline-flex;
  align-items: center;
  padding: 2px 8px;
  border-radius: var(--radius-pill);
  font-size: 10px;
  font-weight: 600;
  white-space: nowrap;
}

.pill--sage {
  background: var(--success-100);
  color: var(--success-600);
}

.pill--amber {
  background: var(--amber-100);
  color: var(--amber-600);
}

.pill--danger {
  background: var(--danger-100);
  color: var(--danger-600);
}

.pill--muted {
  background: rgba(139, 132, 120, 0.14);
  color: var(--ink-500);
}

.row-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.act {
  padding: 3px 8px;
  border-radius: var(--radius-xs);
  background: var(--sage-50);
  color: var(--sage-700);
  font-size: 10.5px;
  font-weight: 600;
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.act:hover {
  background: var(--sage-100);
}

.act--danger {
  background: var(--danger-100);
  color: var(--danger-600);
}

.act--danger:hover {
  background: #f6d9d1;
}

.pager {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
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

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: var(--space-10);
  text-align: center;
}

.empty-state__art {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: var(--sage-50);
  color: var(--sage-400);
}

.empty-state__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-700);
}

.empty-state__desc {
  font-size: var(--font-xs);
  color: var(--ink-400);
  max-width: 320px;
  line-height: 1.6;
  margin-bottom: 4px;
}

/* 抽屉 */
.drawer-mask {
  position: fixed;
  inset: 0;
  z-index: 300;
  display: flex;
  justify-content: flex-end;
  background: rgba(48, 44, 36, 0.36);
  backdrop-filter: blur(3px);
}

.drawer {
  display: flex;
  flex-direction: column;
  width: min(660px, 96vw);
  height: 100%;
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  animation: slide-in-right var(--motion-slow) var(--ease-enter) both;
}

.drawer__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  padding: var(--space-5);
  border-bottom: 1px solid rgba(124, 143, 90, 0.12);
}

.drawer__title {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--ink-900);
}

.drawer__sub {
  font-size: 10.5px;
  color: var(--ink-400);
  margin-top: 2px;
}

.drawer__close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  color: var(--ink-500);
  background: rgba(255, 255, 255, 0.8);
}

.drawer__body {
  flex: 1;
  overflow-y: auto;
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.drawer__foot {
  display: flex;
  gap: var(--space-3);
  padding: var(--space-4) var(--space-5);
  border-top: 1px solid rgba(124, 143, 90, 0.12);
  background: rgba(255, 255, 255, 0.7);
}

.drawer__foot .btn {
  flex: 1;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-3);
}

.form-grid--4 {
  grid-template-columns: repeat(4, minmax(0, 1fr));
}

.form-grid__full {
  grid-column: 1 / -1;
}

.form-section {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--sage-700);
  padding-top: var(--space-3);
  border-top: 1px dashed rgba(124, 143, 90, 0.2);
  letter-spacing: 0.02em;
}

.image-row {
  display: flex;
  gap: var(--space-3);
  align-items: flex-start;
}

.image-preview {
  width: 118px;
  height: 88px;
  flex: none;
  border-radius: var(--radius-sm);
  overflow: hidden;
  background: var(--cream-200);
  border: 1px solid rgba(124, 143, 90, 0.16);
}

.image-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-actions {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 7px;
  min-width: 0;
}

.upload-btn {
  align-self: flex-start;
  cursor: pointer;
}

.input--sm {
  height: 36px;
  font-size: var(--font-xs);
}

.image-hint {
  font-size: 10px;
  color: var(--ink-400);
  line-height: 1.5;
}

.switch-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: var(--font-sm);
  color: var(--ink-700);
  cursor: pointer;
  padding: 6px 0;
}

.switch-row input {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

.switch-row__box {
  position: relative;
  width: 38px;
  height: 21px;
  border-radius: var(--radius-pill);
  background: rgba(139, 132, 120, 0.28);
  transition: background-color var(--motion-fast) var(--ease-standard);
  flex: none;
}

.switch-row__box::after {
  content: '';
  position: absolute;
  top: 2.5px;
  left: 2.5px;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: #fff;
  transition: transform var(--motion-normal) var(--ease-standard);
}

.switch-row input:checked + .switch-row__box {
  background: var(--sage-500);
}

.switch-row input:checked + .switch-row__box::after {
  transform: translateX(17px);
}

.form-error {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 9px 12px;
  border-radius: var(--radius-sm);
  background: var(--danger-100);
  color: var(--danger-600);
  font-size: var(--font-xs);
}

.confirm-mask {
  position: fixed;
  inset: 0;
  z-index: 400;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(48, 44, 36, 0.4);
  backdrop-filter: blur(4px);
}

.confirm-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  width: min(400px, 92vw);
  padding: var(--space-6);
  border-radius: var(--radius-xl);
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  text-align: center;
}

.confirm-box__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: var(--danger-100);
  color: var(--danger-600);
}

.confirm-box__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.confirm-box__desc {
  font-size: var(--font-xs);
  color: var(--ink-500);
  line-height: 1.6;
}

.confirm-box__actions {
  display: flex;
  gap: var(--space-3);
  width: 100%;
  margin-top: var(--space-2);
}

.confirm-box__actions .btn {
  flex: 1;
}

.confirm-box__danger {
  background: linear-gradient(135deg, var(--danger-500), var(--danger-600));
  box-shadow: 0 6px 16px rgba(180, 82, 60, 0.24);
}

@media (max-width: 1180px) {
  .form-grid--4 {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 767px) {
  .form-grid,
  .form-grid--4 {
    grid-template-columns: 1fr;
  }

  .filter-bar__search {
    width: 100%;
  }

  .filter-bar__add {
    margin-left: 0;
    width: 100%;
  }
}
</style>
