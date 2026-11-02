<script setup lang="ts">
/**
 * 发布作品弹窗：上传图片 + 文字描述 + 可选关联历史订单 / 菜品。
 */
import { computed, ref, watch } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { dishApi, reviewApi, workApi } from '@/api/modules'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'
import { formatDateTime, formatMoney } from '@/utils/format'

const props = defineProps<{ open: boolean }>()
const emit = defineEmits<{
  (e: 'close'): void
  (e: 'published'): void
}>()

const auth = useAuthStore()
const toast = useToastStore()

const title = ref('')
const content = ref('')
const images = ref<string[]>([])
const uploading = ref(false)
const submitting = ref(false)
const error = ref('')

const dishId = ref<number | null>(null)
/** 关联的历史订单；与 dishId 一起提交，作品详情会展示订单凭证 */
const orderId = ref<number | null>(null)
const pickerOpen = ref(false)
const loadingOptions = ref(false)

interface OrderPickItem {
  orderId: number
  dishId: number
  dishName: string
  imageUrl?: string | null
  orderNo: string
  createdAt: string
  unitPrice: number
}

const recentDishes = ref<OrderPickItem[]>([])

const selectedDish = computed(() => {
  const list = recentDishes.value
  if (!dishId.value) {
    return null
  }
  if (orderId.value) {
    const hit = list.find((d) => d.dishId === dishId.value && d.orderId === orderId.value)
    if (hit) {
      return hit
    }
  }
  // 未关联历史订单时只按菜品匹配（回退列表里的条目 orderId 为 0）
  return list.find((d) => d.dishId === dishId.value) ?? null
})

watch(
  () => props.open,
  (v) => {
    if (v) {
      reset()
      void loadRecentDishes()
    }
  }
)

function reset() {
  title.value = ''
  content.value = ''
  images.value = []
  dishId.value = null
  orderId.value = null
  error.value = ''
  pickerOpen.value = false
}

/** 加载「吃过的菜」——来自评价中心（订单明细） */
async function loadRecentDishes() {
  loadingOptions.value = true
  try {
    const rows = (await reviewApi.center()) as unknown as Array<Record<string, unknown>>
    const seen = new Set<string>()
    const list: OrderPickItem[] = []
    for (const r of rows) {
      const itemDishId = Number(r.dishId)
      const itemOrderId = Number(r.orderId)
      if (!itemDishId || !itemOrderId) {
        continue
      }
      // 保留同一道菜在不同订单中的记录，方便用户选择具体订单
      const key = `${itemOrderId}-${itemDishId}`
      if (seen.has(key)) {
        continue
      }
      seen.add(key)
      list.push({
        orderId: itemOrderId,
        dishId: itemDishId,
        dishName: String(r.dishName ?? ''),
        imageUrl: (r.imageUrl as string) ?? null,
        orderNo: String(r.orderNo ?? ''),
        createdAt: String(r.orderCreatedAt ?? ''),
        unitPrice: Number(r.unitPrice ?? 0)
      })
    }
    // 没有历史订单时退化为展示全部菜品（此时无法关联订单，只关联菜品）
    if (list.length === 0) {
      const res = await dishApi.list({ page: 1, pageSize: 30 })
      for (const d of res.records) {
        list.push({
          orderId: 0,
          dishId: d.id,
          dishName: d.name,
          imageUrl: d.imageUrl,
          orderNo: '',
          createdAt: '',
          unitPrice: Number(d.price ?? 0)
        })
      }
    }
    recentDishes.value = list
  } catch {
    recentDishes.value = []
  } finally {
    loadingOptions.value = false
  }
}

async function onFilePick(event: Event) {
  const input = event.target as HTMLInputElement
  const files = Array.from(input.files ?? [])
  if (files.length === 0) {
    return
  }
  if (images.value.length + files.length > 9) {
    error.value = '最多上传 9 张图片'
    return
  }
  uploading.value = true
  error.value = ''
  try {
    for (const file of files) {
      if (file.size > 5 * 1024 * 1024) {
        error.value = `${file.name} 超过 5MB`
        continue
      }
      if (!/^image\/(jpeg|png|webp)$/.test(file.type)) {
        error.value = `${file.name} 格式不支持（仅 jpg/png/webp）`
        continue
      }
      const r = await workApi.uploadImage(file)
      images.value = [...images.value, r.url]
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : '图片上传失败'
  } finally {
    uploading.value = false
    input.value = ''
  }
}

function removeImage(idx: number) {
  images.value = images.value.filter((_, i) => i !== idx)
}

function pickDish(d: OrderPickItem) {
  const same = dishId.value === d.dishId && orderId.value === d.orderId
  dishId.value = same ? null : d.dishId
  orderId.value = same || d.orderId === 0 ? null : d.orderId
  // 自动填充：如果没写文字，用菜名做标题
  if (!title.value && d.dishName) {
    title.value = `推荐一下${d.dishName}`
  }
  pickerOpen.value = false
}

function clearDish() {
  dishId.value = null
  orderId.value = null
}

async function submit() {
  error.value = ''
  if (!auth.isLoggedIn) {
    toast.warning('请先登录', '登录后即可发布你的用餐记录')
    emit('close')
    return
  }
  if (!content.value.trim()) {
    error.value = '请填写文字描述'
    return
  }
  if (images.value.length === 0) {
    error.value = '请至少上传一张图片'
    return
  }
  if (submitting.value) {
    return
  }
  submitting.value = true
  try {
    await workApi.publish({
      title: title.value.trim() || undefined,
      content: content.value.trim(),
      dishId: dishId.value,
      orderId: orderId.value,
      images: images.value
    })
    toast.success('发布成功', '你的作品已经出现在精选里了')
    emit('published')
  } catch (e) {
    error.value = e instanceof Error ? e.message : '发布失败，请稍后重试'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <Transition name="fade">
    <div v-if="props.open" class="pub-mask" @click.self="emit('close')">
      <div class="pub">
        <header class="pub__head">
          <div>
            <h3 class="pub__title">发布作品</h3>
            <p class="pub__sub">分享你的用餐记录，可以关联吃过的菜</p>
          </div>
          <button class="pub__close" type="button" aria-label="关闭" @click="emit('close')">
            <AppIcon name="close" :size="16" />
          </button>
        </header>

        <div class="pub__body scroll-y">
          <!-- 图片上传 -->
          <div class="pub__field">
            <label class="pub__label">作品图片（最多 9 张，第一张为封面）</label>
            <div class="pub__images">
              <div v-for="(img, idx) in images" :key="img" class="pub__img">
                <img :src="img" :alt="`图片 ${idx + 1}`" />
                <button class="pub__img-del" type="button" :aria-label="`移除图片 ${idx + 1}`" @click="removeImage(idx)">
                  <AppIcon name="close" :size="11" />
                </button>
                <span v-if="idx === 0" class="pub__img-cover">封面</span>
              </div>
              <label v-if="images.length < 9" class="pub__img-add">
                <AppIcon :name="uploading ? 'refresh' : 'plus'" :size="20" />
                <span>{{ uploading ? '上传中…' : '添加图片' }}</span>
                <input
                  type="file"
                  accept="image/jpeg,image/png,image/webp"
                  multiple
                  hidden
                  :disabled="uploading"
                  @change="onFilePick"
                />
              </label>
            </div>
          </div>

          <!-- 标题 -->
          <div class="pub__field">
            <label class="pub__label" for="pub-title">标题</label>
            <input
              id="pub-title"
              v-model="title"
              class="input"
              type="text"
              maxlength="60"
              placeholder="给作品起个标题（可选）"
            />
          </div>

          <!-- 文字 -->
          <div class="pub__field">
            <label class="pub__label" for="pub-content">文字描述 <span class="pub__req">*</span></label>
            <textarea
              id="pub-content"
              v-model="content"
              class="input"
              rows="3"
              maxlength="1000"
              placeholder="这道菜怎么样？味道、分量、价格都可以说说"
            ></textarea>
          </div>

          <!-- 关联历史订单 -->
          <div class="pub__field">
            <label class="pub__label">关联历史订单（可选，展示真实订单凭证，方便别人一键点餐）</label>
            <div v-if="selectedDish" class="pub__picked">
              <img
                class="pub__picked-img"
                :src="selectedDish.imageUrl || '/assets/images/dishes/dish-placeholder.webp'"
                :alt="selectedDish.dishName"
              />
              <div class="pub__picked-info">
                <span class="pub__picked-name">{{ selectedDish.dishName }}</span>
                <span class="pub__picked-meta num">
                  ¥{{ formatMoney(selectedDish.unitPrice) }}
                  <template v-if="selectedDish.orderNo"> · 订单 {{ selectedDish.orderNo }}</template>
                </span>
              </div>
              <button class="pub__picked-remove" type="button" aria-label="取消关联" @click="clearDish">
                <AppIcon name="close" :size="13" />
              </button>
            </div>
            <button
              v-else
              class="btn btn--ghost btn--sm"
              type="button"
              @click="pickerOpen = !pickerOpen"
            >
              <AppIcon name="clipboard-list" :size="14" />
              {{ pickerOpen ? '收起列表' : '选择历史订单' }}
            </button>

            <div v-if="pickerOpen" class="pub__picker scroll-y">
              <div v-if="loadingOptions" class="pub__picker-empty">加载中…</div>
              <div v-else-if="recentDishes.length === 0" class="pub__picker-empty">还没有可关联的历史订单</div>
              <button
                v-for="d in recentDishes"
                :key="`${d.orderId}-${d.dishId}`"
                class="pub__opt"
                type="button"
                @click="pickDish(d)"
              >
                <img
                  class="pub__opt-img"
                  :src="d.imageUrl || '/assets/images/dishes/dish-placeholder.webp'"
                  :alt="d.dishName"
                />
                <div class="pub__opt-info">
                  <span class="pub__opt-name">{{ d.dishName }}</span>
                  <span class="pub__opt-meta num">
                    ¥{{ formatMoney(d.unitPrice) }}
                    <template v-if="d.orderNo"> · 订单 {{ d.orderNo }} · {{ formatDateTime(d.createdAt) }}</template>
                    <template v-else> · 菜品（无历史订单）</template>
                  </span>
                </div>
              </button>
            </div>
          </div>

          <p v-if="error" class="pub__error">
            <AppIcon name="x-circle" :size="13" />{{ error }}
          </p>
        </div>

        <footer class="pub__foot">
          <button class="btn btn--ghost" type="button" :disabled="submitting" @click="emit('close')">取消</button>
          <button class="btn btn--primary" type="button" :disabled="submitting || uploading" @click="submit">
            {{ submitting ? '发布中…' : '发布' }}
          </button>
        </footer>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.pub-mask {
  position: fixed;
  inset: 0;
  z-index: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-5);
  background: rgba(48, 44, 36, 0.46);
  backdrop-filter: blur(6px);
}

.pub {
  display: flex;
  flex-direction: column;
  width: min(540px, 95vw);
  max-height: 88vh;
  border-radius: var(--radius-2xl);
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  overflow: hidden;
}

.pub__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  padding: var(--space-4) var(--space-5);
  border-bottom: 1px solid rgba(124, 143, 90, 0.12);
}

.pub__title {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--ink-900);
}

.pub__sub {
  font-size: 10.5px;
  color: var(--ink-400);
  margin-top: 2px;
}

.pub__close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  color: var(--ink-500);
  background: rgba(255, 255, 255, 0.8);
  flex: none;
}

.pub__body {
  flex: 1;
  overflow-y: auto;
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.pub__field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.pub__label {
  font-size: 10.5px;
  font-weight: 600;
  color: var(--ink-600);
}

.pub__req {
  color: var(--danger-500);
}

.pub__images {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 8px;
}

.pub__img {
  position: relative;
  aspect-ratio: 1 / 1;
  border-radius: var(--radius-sm);
  overflow: hidden;
  background: var(--cream-200);
}

.pub__img img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.pub__img-del {
  position: absolute;
  top: 3px;
  right: 3px;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: rgba(44, 42, 38, 0.62);
  color: #fff;
}

.pub__img-cover {
  position: absolute;
  left: 3px;
  bottom: 3px;
  padding: 1px 6px;
  border-radius: var(--radius-pill);
  background: rgba(95, 120, 80, 0.9);
  color: #fff;
  font-size: 9px;
}

.pub__img-add {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  aspect-ratio: 1 / 1;
  border-radius: var(--radius-sm);
  border: 1.5px dashed rgba(124, 143, 90, 0.34);
  color: var(--sage-600);
  font-size: 10px;
  cursor: pointer;
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.pub__img-add:hover {
  background: var(--sage-50);
}

.pub__picked {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 8px 10px;
  border-radius: var(--radius-sm);
  background: rgba(232, 238, 221, 0.62);
  border: 1px solid rgba(124, 143, 90, 0.2);
}

.pub__picked-img {
  width: 40px;
  height: 40px;
  flex: none;
  border-radius: var(--radius-xs);
  object-fit: cover;
}

.pub__picked-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.pub__picked-name {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--ink-900);
}

.pub__picked-meta {
  font-size: 10px;
  color: var(--ink-500);
}

.pub__picked-remove {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  color: var(--ink-400);
  flex: none;
}

.pub__picker {
  margin-top: 6px;
  max-height: 190px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 5px;
  padding: 6px;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.72);
  border: 1px solid rgba(124, 143, 90, 0.14);
}

.pub__picker-empty {
  padding: var(--space-4);
  text-align: center;
  color: var(--ink-400);
  font-size: 10.5px;
}

.pub__opt {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 8px;
  border-radius: var(--radius-xs);
  background: rgba(255, 253, 248, 0.92);
  text-align: left;
}

.pub__opt:hover {
  background: #fff;
}

.pub__opt-img {
  width: 34px;
  height: 34px;
  flex: none;
  border-radius: var(--radius-xs);
  object-fit: cover;
}

.pub__opt-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.pub__opt-name {
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--ink-900);
}

.pub__opt-meta {
  font-size: 9.5px;
  color: var(--ink-500);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.pub__error {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 8px 11px;
  border-radius: var(--radius-sm);
  background: var(--danger-100);
  color: var(--danger-600);
  font-size: var(--font-xs);
}

.pub__foot {
  display: flex;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-5) var(--space-4);
  border-top: 1px solid rgba(124, 143, 90, 0.12);
}

.pub__foot .btn {
  flex: 1;
}

@media (max-width: 767px) {
  .pub__images {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}
</style>
