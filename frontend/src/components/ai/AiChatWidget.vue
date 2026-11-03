<script setup lang="ts">
/**
 * 悬浮「食堂小助手」：右下角饭团小图标，点击弹出可拖动 / 可缩放的聊天窗口。
 * 支持 SSE 流式输出、多轮追问、菜品卡加购；菜品数据全部来自后端数据库。
 */
import { computed, nextTick, onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { aiApi } from '@/api/modules'
import { askAiStream } from '@/api/aiStream'
import { useCartStore } from '@/stores/cart'
import { useToastStore } from '@/stores/toast'
import { formatPrice } from '@/utils/format'
import type { AiDishSuggestion, AiRecommendResult } from '@/types/api'

interface ChatTurn {
  id: number
  role: 'user' | 'assistant'
  text: string
  dishes?: AiDishSuggestion[]
  tips?: string[]
  streaming?: boolean
}

const FAB_KEY = 'canteen.aiChat.fab'
/** 面板尺寸与悬浮球尺寸，完全按参考项目 ChatWidget 的锚定方式 */
const PANEL_W = 540
const PANEL_MIN_W = 360
const PANEL_H_MIN = 420
const FAB_SIZE = 58
/** 圆球与面板之间的缝隙 */
const FAB_GAP = 12
const EDGE = 12

const quickAsks = ['今天吃什么？', '我想补点蛋白质', '预算 15 元', '想吃清淡低油的']

const toast = useToastStore()
const cart = useCartStore()

const open = ref(false)
const question = ref('')
const loading = ref(false)
const turns = ref<ChatTurn[]>([])
const conversationId = ref<number | null>(null)
const modeLabel = ref('AI 助手')
const addingId = ref<number | null>(null)
const listRef = ref<HTMLElement | null>(null)
const inputRef = ref<HTMLInputElement | null>(null)
const stickBottom = ref(true)
const dragging = ref(false)

const viewport = ref({ w: viewportWidth(), h: viewportHeight() })
/** 圆球的唯一锚点：窗口位置全部由它推导，不再单独保存窗口坐标 */
const pos = ref({ x: viewportWidth() - FAB_SIZE - 28, y: viewportHeight() - FAB_SIZE - 32 })

let seq = 0
let streamController: AbortController | null = null
let scrollRaf = 0
let dragState: { sx: number; sy: number; ox: number; oy: number; moved: boolean } | null = null

const showQuick = computed(() => turns.value.length === 0)
const panelSize = computed(() => {
  const availW = viewport.value.w - EDGE * 2
  const width = Math.max(Math.min(PANEL_MIN_W, availW), Math.min(PANEL_W, availW))
  const maxH = viewport.value.h - EDGE * 2
  const above = pos.value.y - EDGE
  const below = viewport.value.h - pos.value.y - FAB_SIZE - EDGE
  // 上方空间够就优先向上展开（与参考项目一致），否则翻到圆球下方
  const preferAbove = above >= Math.min(PANEL_H_MIN, maxH) + FAB_GAP
  const avail = Math.max(0, (preferAbove ? above : below) - FAB_GAP)
  const height = Math.max(Math.min(PANEL_H_MIN, maxH), Math.min(maxH, avail))
  return { width, height, above: preferAbove }
})

/**
 * 面板跟随圆球浮动：以圆球为锚点，在左/右、上/下四个方向中选择空间足够的一侧展开，
 * 圆球本身留在原地，窗口紧贴圆球，而不是固定在屏幕角落。
 */
const panelStyle = computed((): Record<string, string> => {
  const { width, height, above } = panelSize.value
  let top = above ? pos.value.y - height - FAB_GAP : pos.value.y + FAB_SIZE + FAB_GAP
  top = clamp(top, EDGE, viewport.value.h - height - EDGE)

  const spaceLeft = pos.value.x - FAB_GAP - EDGE
  const spaceRight = viewport.value.w - (pos.value.x + FAB_SIZE) - FAB_GAP - EDGE
  let left: number
  if (spaceLeft >= width) {
    left = pos.value.x - width - FAB_GAP
  } else if (spaceRight >= width) {
    left = pos.value.x + FAB_SIZE + FAB_GAP
  } else {
    left = pos.value.x - width - FAB_GAP
  }
  left = clamp(left, EDGE, viewport.value.w - width - EDGE)
  return { left: `${left}px`, top: `${top}px`, width: `${width}px`, height: `${height}px` }
})

/** 圆球始终停在用户拖到的位置，窗口围绕它展开 */
const fabStyle = computed((): Record<string, string> => {
  return { left: `${pos.value.x}px`, top: `${pos.value.y}px`, right: 'auto', bottom: 'auto' }
})

function viewportWidth() {
  return typeof window === 'undefined' ? 1280 : window.innerWidth
}

function viewportHeight() {
  return typeof window === 'undefined' ? 800 : window.innerHeight
}

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), Math.max(min, max))
}

function clampPos() {
  pos.value.x = clamp(pos.value.x, EDGE, viewport.value.w - FAB_SIZE - EDGE)
  pos.value.y = clamp(pos.value.y, EDGE, viewport.value.h - FAB_SIZE - EDGE)
}

function persistFabPos() {
  try {
    localStorage.setItem(FAB_KEY, JSON.stringify(pos.value))
  } catch {
    /* ignore */
  }
}

function restoreFabPos() {
  try {
    const raw = localStorage.getItem(FAB_KEY)
    if (!raw) {
      return
    }
    const saved = JSON.parse(raw) as { x?: number; y?: number }
    if (typeof saved.x === 'number' && typeof saved.y === 'number') {
      pos.value = { x: saved.x, y: saved.y }
      clampPos()
    }
  } catch {
    /* ignore */
  }
}

function onWindowResize() {
  viewport.value = { w: viewportWidth(), h: viewportHeight() }
  clampPos()
}

// ---------------------------------------------------------------
// 圆球拖动 / 开合（严格按参考项目：拖动只移动，不触发开合）
// ---------------------------------------------------------------
function onFabDown(event: PointerEvent) {
  if (event.button !== 0) {
    return
  }
  event.preventDefault()
  dragState = { sx: event.clientX, sy: event.clientY, ox: pos.value.x, oy: pos.value.y, moved: false }
  window.addEventListener('pointermove', onFabMove)
  window.addEventListener('pointerup', onFabUp)
}

function onFabMove(event: PointerEvent) {
  if (!dragState) {
    return
  }
  const dx = event.clientX - dragState.sx
  const dy = event.clientY - dragState.sy
  if (!dragState.moved && Math.hypot(dx, dy) > 5) {
    dragState.moved = true
    dragging.value = true
  }
  if (dragState.moved) {
    pos.value = { x: dragState.ox + dx, y: dragState.oy + dy }
    clampPos()
  }
}

function toggleOpen() {
  open.value = !open.value
  if (!open.value) {
    return
  }
  scrollToBottom()
  void nextTick(() => inputRef.value?.focus())
}

/** 仅响应键盘触发的 click（detail===0），鼠标点击走 pointerup，避免拖动后误开窗 */
function onFabClick(event: MouseEvent) {
  if (event.detail === 0) {
    toggleOpen()
  }
}

function onFabUp() {
  window.removeEventListener('pointermove', onFabMove)
  window.removeEventListener('pointerup', onFabUp)
  const state = dragState
  dragState = null
  if (!state) {
    dragging.value = false
    return
  }
  dragging.value = false

  if (state.moved) {
    // 拖动了就只保存位置，绝不开窗；展开状态下窗口会跟着圆球一起移动
    persistFabPos()
    return
  }

  toggleOpen()
}

// ---------------------------------------------------------------
// 消息与流式输出
// ---------------------------------------------------------------
function scrollToBottom() {
  if (scrollRaf) {
    return
  }
  scrollRaf = requestAnimationFrame(() => {
    scrollRaf = 0
    const el = listRef.value
    if (el && stickBottom.value) {
      el.scrollTop = el.scrollHeight
    }
  })
}

function onListScroll() {
  const el = listRef.value
  if (!el) {
    return
  }
  stickBottom.value = el.scrollHeight - el.scrollTop - el.clientHeight < 48
}

async function loadStatus() {
  try {
    const status = await aiApi.status()
    modeLabel.value = status.modeLabel || 'AI 助手'
  } catch {
    /* ignore */
  }
}

async function send(text?: string) {
  const message = (text ?? question.value).trim()
  if (!message) {
    toast.warning('先告诉我你的用餐需求吧', '例如：想吃得清淡一点、预算 20 元以内')
    return
  }
  if (loading.value) {
    return
  }
  turns.value.push({ id: ++seq, role: 'user', text: message })
  // reactive：流式回调在 Vue 之外修改字段，必须通过响应式代理才能触发重渲染
  const turn = reactive<ChatTurn>({ id: ++seq, role: 'assistant', text: '', streaming: true })
  turns.value.push(turn)
  question.value = ''
  loading.value = true
  stickBottom.value = true
  scrollToBottom()

  streamController = new AbortController()
  try {
    await askAiStream(
      { message, conversationId: conversationId.value },
      {
        onMeta: (meta) => {
          if (meta.conversationId) {
            conversationId.value = meta.conversationId
          }
          if (meta.modeLabel) {
            modeLabel.value = meta.modeLabel
          }
        },
        onDelta: (delta) => {
          turn.text += delta
          scrollToBottom()
        },
        onDone: (answer: AiRecommendResult) => {
          turn.text = answer.reply || turn.text
          turn.dishes = answer.dishes
          turn.tips = answer.tips
          turn.streaming = false
          conversationId.value = answer.conversationId ?? conversationId.value
          modeLabel.value = answer.modeLabel || modeLabel.value
          scrollToBottom()
        },
        onError: (msg) => {
          turn.text = `抱歉，我刚才走神了（${msg}），可以再问一次吗？`
          turn.streaming = false
        }
      },
      streamController.signal
    )
  } catch (e) {
    const aborted = e instanceof DOMException && e.name === 'AbortError'
    if (!aborted) {
      const reason = e instanceof Error ? e.message : '请稍后重试'
      turn.text = `抱歉，我刚才走神了（${reason}），可以再问一次吗？`
    } else if (!turn.text) {
      turn.text = '已停止生成。'
    }
    turn.streaming = false
  } finally {
    loading.value = false
    streamController = null
    scrollToBottom()
  }
}

function stopStreaming() {
  streamController?.abort()
}

async function addToCart(dish: AiDishSuggestion) {
  if (addingId.value) {
    return
  }
  addingId.value = dish.dishId
  try {
    await cart.add(dish.dishId, 1)
    toast.success('已加入购物车', `${dish.name} 已放入购物车，结算后送到桌面`)
  } catch (e) {
    toast.error('加入购物车失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    addingId.value = null
  }
}

function onKeydown(event: KeyboardEvent) {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault()
    void send()
  }
}

function onEscape(event: KeyboardEvent) {
  if (event.key === 'Escape' && open.value) {
    if (loading.value) {
      stopStreaming()
    }
    open.value = false
  }
}

onMounted(() => {
  viewport.value = { w: viewportWidth(), h: viewportHeight() }
  restoreFabPos()
  clampPos()
  void loadStatus()
  window.addEventListener('resize', onWindowResize)
  window.addEventListener('keydown', onEscape)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', onWindowResize)
  window.removeEventListener('keydown', onEscape)
  window.removeEventListener('pointermove', onFabMove)
  window.removeEventListener('pointerup', onFabUp)
  streamController?.abort()
})
</script>

<template>
  <!-- 悬浮入口：项目自绘「饭团小助手」，可拖动，点击展开；展开后它是关闭按钮 -->
  <button
    class="ai-fab"
    :class="{ 'ai-fab--dragging': dragging, 'ai-fab--open': open }"
    :style="fabStyle"
    type="button"
    :aria-label="open ? '关闭食堂小助手' : '打开食堂小助手'"
    :title="open ? '点击关闭' : '按住可拖动，点击打开'"
    @pointerdown="onFabDown"
    @click="onFabClick"
  >
    <template v-if="!open">
      <span class="ai-fab__halo" aria-hidden="true"></span>
      <svg class="ai-fab__mascot" viewBox="0 0 64 64" aria-hidden="true">
        <defs>
          <linearGradient id="aiMascotBg" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stop-color="#a9bd8a" />
            <stop offset="1" stop-color="#6f8a55" />
          </linearGradient>
        </defs>
        <circle cx="32" cy="32" r="30" fill="url(#aiMascotBg)" />
        <path d="M25 13c-3-3 3-5 0-8" stroke="#ffffff" stroke-opacity="0.75" stroke-width="2" fill="none" stroke-linecap="round" />
        <path d="M36 14c3-3-3-5 0-8" stroke="#ffffff" stroke-opacity="0.75" stroke-width="2" fill="none" stroke-linecap="round" />
        <path d="M18 35c0-8 6-13 14-13s14 5 14 13z" fill="#ffffff" />
        <circle cx="27" cy="28" r="1.8" fill="#5b4a3a" />
        <circle cx="37" cy="28" r="1.8" fill="#5b4a3a" />
        <path d="M28.5 32c2 2.2 5 2.2 7 0" stroke="#5b4a3a" stroke-width="1.6" fill="none" stroke-linecap="round" />
        <path d="M14 34h36c0 9-8 15-18 15s-18-6-18-15z" fill="#fffdf7" />
        <path d="M14 34h36" stroke="#e8ddca" stroke-width="1.4" />
      </svg>
      <span class="ai-fab__dot" aria-hidden="true"></span>
    </template>
    <svg v-else class="ai-fab__close" viewBox="0 0 24 24" aria-hidden="true">
      <path d="M6 6l12 12M18 6l-12 12" stroke="#ffffff" stroke-width="2.4" fill="none" stroke-linecap="round" />
    </svg>
  </button>

  <!-- 聊天窗口：位置完全跟随圆球（在球左上方展开），不再单独拖动窗口 -->
  <Transition name="ai-chat">
    <section
      v-if="open"
      class="ai-chat"
      :style="panelStyle"
      role="dialog"
      aria-label="食堂小助手聊天窗口"
    >
      <header class="ai-chat__head">
        <span class="ai-chat__avatar" aria-hidden="true">
          <svg viewBox="0 0 64 64">
            <path d="M18 35c0-8 6-13 14-13s14 5 14 13z" fill="#ffffff" />
            <circle cx="27" cy="28" r="1.8" fill="#5b4a3a" />
            <circle cx="37" cy="28" r="1.8" fill="#5b4a3a" />
            <path d="M28.5 32c2 2.2 5 2.2 7 0" stroke="#5b4a3a" stroke-width="1.6" fill="none" stroke-linecap="round" />
            <path d="M14 34h36c0 9-8 15-18 15s-18-6-18-15z" fill="#fffdf7" />
          </svg>
        </span>
        <div class="ai-chat__titles">
          <div class="ai-chat__title-line">
            <h2 class="ai-chat__title">食堂小助手</h2>
            <span class="ai-chat__mode">{{ modeLabel }}</span>
          </div>
          <p class="ai-chat__sub">按真实菜单与用餐记录回答 · 拖动圆球换位置</p>
        </div>
        <button class="ai-chat__close" type="button" aria-label="关闭聊天窗口" @pointerdown.stop @click="open = false">
          <AppIcon name="close" :size="15" />
        </button>
      </header>

      <div ref="listRef" class="ai-chat__list" @scroll="onListScroll">
        <!-- 欢迎面板 -->
        <div v-if="showQuick" class="ai-welcome">
          <div class="ai-welcome__icon" aria-hidden="true">
            <svg viewBox="0 0 64 64">
              <path d="M18 35c0-8 6-13 14-13s14 5 14 13z" fill="#fff" />
              <circle cx="27" cy="28" r="1.8" fill="#5b4a3a" />
              <circle cx="37" cy="28" r="1.8" fill="#5b4a3a" />
              <path d="M28.5 32c2 2.2 5 2.2 7 0" stroke="#5b4a3a" stroke-width="1.6" fill="none" stroke-linecap="round" />
              <path d="M14 34h36c0 9-8 15-18 15s-18-6-18-15z" fill="#fffdf7" />
            </svg>
          </div>
          <p class="ai-welcome__title">你好，我是食堂小助手</p>
          <p class="ai-welcome__sub">问我吃什么、想补什么营养、预算多少，我会按真实菜单和你的用餐记录来推荐。</p>
          <div class="ai-welcome__chips">
            <button v-for="item in quickAsks" :key="item" type="button" class="ai-quick" @click="send(item)">
              {{ item }}
            </button>
          </div>
        </div>

        <div
          v-for="turn in turns"
          :key="turn.id"
          class="ai-msg"
          :class="turn.role === 'user' ? 'ai-msg--user' : 'ai-msg--assistant'"
        >
          <span v-if="turn.role === 'assistant'" class="ai-msg__avatar" aria-hidden="true">
            <svg viewBox="0 0 64 64">
              <path d="M18 35c0-8 6-13 14-13s14 5 14 13z" fill="#fff" />
              <circle cx="27" cy="28" r="1.8" fill="#5b4a3a" />
              <circle cx="37" cy="28" r="1.8" fill="#5b4a3a" />
              <path d="M28.5 32c2 2.2 5 2.2 7 0" stroke="#5b4a3a" stroke-width="1.6" fill="none" stroke-linecap="round" />
              <path d="M14 34h36c0 9-8 15-18 15s-18-6-18-15z" fill="#fffdf7" />
            </svg>
          </span>
          <div class="ai-msg__content">
            <div class="ai-bubble" :class="{ 'ai-bubble--streaming': turn.streaming }">
              <template v-if="turn.role === 'assistant' && turn.streaming">
                <span v-if="!turn.text" class="ai-thinking">
                  <i></i><i></i><i></i>
                  <em class="ai-thinking__hint">正在翻菜单、结合你的用餐记录…</em>
                </span>
                <template v-else>{{ turn.text }}<span class="ai-caret"></span></template>
              </template>
              <template v-else>{{ turn.text }}</template>
            </div>

            <div v-if="turn.dishes && turn.dishes.length > 0" class="ai-dishes">
              <div v-for="dish in turn.dishes" :key="dish.dishId" class="ai-dish">
                <img
                  class="ai-dish__img"
                  :src="dish.imageUrl || '/assets/images/dishes/dish-placeholder.webp'"
                  :alt="dish.name"
                  loading="lazy"
                />
                <div class="ai-dish__info">
                  <span class="ai-dish__name">{{ dish.name }}</span>
                  <span class="ai-dish__reason">{{ dish.reason }}</span>
                </div>
                <div class="ai-dish__right">
                  <span v-if="dish.price != null" class="ai-dish__price num">¥{{ formatPrice(dish.price) }}</span>
                  <button
                    class="ai-dish__add"
                    type="button"
                    :aria-label="`加入购物车：${dish.name}`"
                    :disabled="addingId === dish.dishId"
                    @click="addToCart(dish)"
                  >
                    <AppIcon name="plus" :size="13" />
                  </button>
                </div>
              </div>
            </div>

            <ul v-if="turn.tips && turn.tips.length > 0" class="ai-tips">
              <li v-for="tip in turn.tips" :key="tip">
                <AppIcon name="info" :size="11" />{{ tip }}
              </li>
            </ul>
          </div>
        </div>
      </div>

      <form class="ai-chat__input" @submit.prevent="send()">
        <input
          ref="inputRef"
          v-model="question"
          type="text"
          class="ai-chat__field"
          placeholder="想吃什么？告诉我你的需求…"
          aria-label="向食堂小助手提问"
          :disabled="loading"
          @keydown="onKeydown"
        />
        <button
          v-if="loading"
          class="ai-chat__stop"
          type="button"
          aria-label="停止生成"
          @click="stopStreaming"
        >
          <span class="ai-chat__stop-square"></span>
        </button>
        <button v-else class="ai-chat__send" type="submit" :disabled="!question.trim()" aria-label="发送">
          <AppIcon name="arrow-right" :size="16" />
        </button>
      </form>
    </section>
  </Transition>
</template>

<style scoped>
.ai-fab {
  position: fixed;
  z-index: 1202;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 58px;
  height: 58px;
  padding: 0;
  border: 0;
  border-radius: 50%;
  background: transparent;
  cursor: grab;
  touch-action: none;
  filter: drop-shadow(0 8px 18px rgba(74, 92, 58, 0.35));
  transition: transform var(--motion-fast) var(--ease-standard),
    left 0.28s cubic-bezier(0.34, 1.4, 0.64, 1),
    top 0.28s cubic-bezier(0.34, 1.4, 0.64, 1);
}

.ai-fab:hover {
  transform: translateY(-2px) scale(1.04);
}

.ai-fab--dragging,
.ai-fab--dragging:hover {
  cursor: grabbing;
  transform: none;
  transition: none;
}

.ai-fab__mascot {
  width: 58px;
  height: 58px;
  border-radius: 50%;
  pointer-events: none;
}

.ai-fab__close {
  width: 22px;
  height: 22px;
  pointer-events: none;
}

.ai-fab__halo {
  position: absolute;
  inset: -6px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(169, 189, 138, 0.45), transparent 68%);
  animation: ai-halo 2.6s ease-in-out infinite;
  pointer-events: none;
}

.ai-fab__dot {
  position: absolute;
  top: 6px;
  right: 7px;
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: var(--amber-500);
  box-shadow: 0 0 0 2px rgba(255, 255, 255, 0.85);
  pointer-events: none;
}

@keyframes ai-halo {
  0%,
  100% {
    transform: scale(0.94);
    opacity: 0.7;
  }
  50% {
    transform: scale(1.06);
    opacity: 1;
  }
}

.ai-chat {
  position: fixed;
  z-index: 1201;
  display: flex;
  flex-direction: column;
  border-radius: 18px;
  background: linear-gradient(165deg, rgba(253, 250, 242, 0.99), rgba(243, 247, 236, 0.99));
  border: 1px solid rgba(124, 143, 90, 0.24);
  box-shadow: 0 22px 60px rgba(44, 42, 38, 0.28), 0 2px 8px rgba(44, 42, 38, 0.08);
  overflow: hidden;
}

.ai-chat__head {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 14px;
  background: linear-gradient(135deg, rgba(232, 238, 221, 0.98), rgba(253, 248, 239, 0.98));
  border-bottom: 1px solid rgba(124, 143, 90, 0.16);
}

.ai-chat__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  flex: none;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--sage-400), var(--sage-600));
  box-shadow: 0 4px 10px rgba(95, 120, 80, 0.24);
}

.ai-chat__avatar svg {
  width: 40px;
  height: 40px;
  transform: translateY(6px);
}

.ai-chat__titles {
  flex: 1;
  min-width: 0;
}

.ai-chat__title-line {
  display: flex;
  align-items: center;
  gap: 6px;
}

.ai-chat__title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--sage-800);
}

.ai-chat__mode {
  padding: 1px 7px;
  border-radius: var(--radius-pill);
  background: rgba(124, 143, 90, 0.16);
  color: var(--sage-700);
  font-size: 9.5px;
  font-weight: 600;
  white-space: nowrap;
}

.ai-chat__sub {
  margin-top: 1px;
  font-size: 10px;
  color: var(--ink-500);
}

.ai-chat__close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  flex: none;
  border-radius: 50%;
  color: var(--ink-500);
  background: rgba(255, 255, 255, 0.7);
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.ai-chat__close:hover {
  background: rgba(255, 255, 255, 0.95);
  color: var(--ink-800);
}

.ai-chat__list {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 14px 14px 10px;
  overflow-y: auto;
}

.ai-welcome {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 20px 12px 8px;
  text-align: center;
}

.ai-welcome__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--sage-400), var(--sage-600));
  box-shadow: 0 8px 20px rgba(95, 120, 80, 0.26);
}

.ai-welcome__icon svg {
  width: 62px;
  height: 62px;
  transform: translateY(9px);
}

.ai-welcome__title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-900);
}

.ai-welcome__sub {
  max-width: 280px;
  font-size: var(--font-xs);
  line-height: 1.65;
  color: var(--ink-500);
}

.ai-welcome__chips {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 6px;
  margin-top: 4px;
}

.ai-quick {
  height: 28px;
  padding: 0 11px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(124, 143, 90, 0.22);
  color: var(--sage-700);
  font-size: 11px;
  font-weight: 600;
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.ai-quick:hover {
  background: var(--sage-100);
}

.ai-msg {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  max-width: 94%;
}

.ai-msg--assistant {
  align-self: flex-start;
}

.ai-msg--user {
  align-self: flex-end;
  justify-content: flex-end;
  max-width: 86%;
}

.ai-msg__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  flex: none;
  margin-top: 2px;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--sage-400), var(--sage-600));
  overflow: hidden;
}

.ai-msg__avatar svg {
  width: 26px;
  height: 26px;
  transform: translateY(4px);
}

.ai-msg__content {
  display: flex;
  flex-direction: column;
  gap: 6px;
  min-width: 0;
}

.ai-bubble {
  padding: 8px 11px;
  border-radius: 4px 12px 12px 12px;
  background: rgba(255, 255, 255, 0.95);
  color: var(--ink-800);
  font-size: var(--font-xs);
  line-height: 1.7;
  box-shadow: 0 2px 8px rgba(44, 42, 38, 0.06);
  white-space: pre-wrap;
  word-break: break-word;
}

.ai-msg--user .ai-bubble {
  border-radius: 12px 4px 12px 12px;
  background: linear-gradient(135deg, var(--sage-500), var(--sage-600));
  color: #fff;
  box-shadow: 0 3px 10px rgba(95, 120, 80, 0.24);
}

.ai-bubble--streaming {
  border: 1px solid rgba(124, 143, 90, 0.16);
}

.ai-caret {
  display: inline-block;
  width: 2px;
  height: 1em;
  margin-left: 2px;
  vertical-align: -2px;
  background: var(--sage-600);
  animation: ai-caret 0.9s steps(2, start) infinite;
}

@keyframes ai-caret {
  0%,
  49% {
    opacity: 1;
  }
  50%,
  100% {
    opacity: 0;
  }
}

.ai-thinking {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 2px 0;
}

.ai-thinking__hint {
  margin-left: 4px;
  font-size: 10px;
  font-style: normal;
  color: var(--ink-500);
}

.ai-thinking i {
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: var(--sage-500);
  animation: ai-typing 1.2s ease-in-out infinite;
}

.ai-thinking i:nth-child(2) {
  animation-delay: 0.2s;
}

.ai-thinking i:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes ai-typing {
  0%,
  60%,
  100% {
    transform: translateY(0);
    opacity: 0.45;
  }
  30% {
    transform: translateY(-3px);
    opacity: 1;
  }
}

.ai-dishes {
  display: flex;
  flex-direction: column;
  gap: 6px;
  width: 100%;
}

.ai-dish {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(124, 143, 90, 0.16);
}

.ai-dish__img {
  width: 44px;
  height: 44px;
  flex: none;
  border-radius: 8px;
  object-fit: cover;
  background: var(--cream-200);
}

.ai-dish__info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.ai-dish__name {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--ink-900);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.ai-dish__reason {
  font-size: 10px;
  line-height: 1.45;
  color: var(--ink-500);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.ai-dish__right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 3px;
  flex: none;
}

.ai-dish__price {
  font-size: 11px;
  font-weight: 700;
  color: var(--amber-600);
}

.ai-dish__add {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  color: #fff;
  background: var(--sage-600);
  transition: transform var(--motion-fast) var(--ease-standard);
}

.ai-dish__add:hover {
  transform: scale(1.08);
}

.ai-dish__add:disabled {
  opacity: 0.55;
  cursor: default;
}

.ai-tips {
  display: flex;
  flex-direction: column;
  gap: 3px;
  padding: 0 2px;
  font-size: 10px;
  line-height: 1.5;
  color: var(--ink-500);
}

.ai-tips li {
  display: flex;
  gap: 4px;
  align-items: flex-start;
}

.ai-chat__input {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 9px 10px;
  border-top: 1px solid rgba(124, 143, 90, 0.16);
  background: rgba(255, 255, 255, 0.9);
}

.ai-chat__field {
  flex: 1;
  min-width: 0;
  height: 36px;
  padding: 0 12px;
  border-radius: var(--radius-pill);
  border: 1px solid rgba(124, 143, 90, 0.22);
  background: #fff;
  font-size: var(--font-xs);
  color: var(--ink-800);
}

.ai-chat__field:focus {
  outline: none;
  border-color: var(--sage-500);
  box-shadow: 0 0 0 3px rgba(124, 143, 90, 0.14);
}

.ai-chat__send,
.ai-chat__stop {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  flex: none;
  border-radius: 50%;
  color: #fff;
  background: linear-gradient(135deg, var(--sage-500), var(--sage-700));
  box-shadow: 0 3px 10px rgba(95, 120, 80, 0.26);
  transition: opacity var(--motion-fast) var(--ease-standard);
}

.ai-chat__stop {
  background: linear-gradient(135deg, #b98a6a, #8f5f47);
}

.ai-chat__stop-square {
  width: 11px;
  height: 11px;
  border-radius: 2px;
  background: #fff;
}

.ai-chat__send:disabled {
  opacity: 0.5;
  cursor: default;
}

.ai-chat-enter-active,
.ai-chat-leave-active {
  transition: opacity var(--motion-normal) var(--ease-standard),
    transform var(--motion-normal) var(--ease-enter);
}

.ai-chat-enter-from,
.ai-chat-leave-to {
  opacity: 0;
  transform: translateY(12px) scale(0.98);
}

@media (max-width: 600px) {
  .ai-fab {
    width: 52px;
    height: 52px;
  }

  .ai-fab__mascot {
    width: 52px;
    height: 52px;
  }
}
</style>
