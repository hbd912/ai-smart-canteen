/**
 * 通用格式化工具
 */
import { onBeforeUnmount, ref, watch } from 'vue'

export function formatMoney(value: number | string | null | undefined, digits = 2): string {
  const num = Number(value ?? 0)
  if (!Number.isFinite(num)) {
    return '0.00'
  }
  return num.toFixed(digits)
}

/** 价格展示：整数省略小数，例如 15 / 15.5 */
export function formatPrice(value: number | string | null | undefined): string {
  const num = Number(value ?? 0)
  if (!Number.isFinite(num)) {
    return '0'
  }
  return Number.isInteger(num) ? String(num) : num.toFixed(2).replace(/0$/, '')
}

export function formatCalories(value: number | string | null | undefined): string {
  const num = Number(value ?? 0)
  if (!Number.isFinite(num) || num <= 0) {
    return '—'
  }
  return String(Math.round(num))
}

export function formatDateTime(value: string | null | undefined): string {
  if (!value) {
    return '—'
  }
  const normalized = value.includes('T') ? value : value.replace(' ', 'T')
  const date = new Date(normalized)
  if (Number.isNaN(date.getTime())) {
    return value
  }
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`
}

export function formatTime(value: string | null | undefined): string {
  if (!value) {
    return '—'
  }
  const normalized = value.includes('T') ? value : value.replace(' ', 'T')
  const date = new Date(normalized)
  if (Number.isNaN(date.getTime())) {
    return value
  }
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${pad(date.getHours())}:${pad(date.getMinutes())}`
}

export function formatDate(value: string | null | undefined): string {
  if (!value) {
    return '—'
  }
  const normalized = value.includes('T') ? value : value.replace(' ', 'T')
  const date = new Date(normalized)
  if (Number.isNaN(date.getTime())) {
    return value
  }
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`
}

export function relativeTime(value: string | null | undefined): string {
  if (!value) {
    return '—'
  }
  const normalized = value.includes('T') ? value : value.replace(' ', 'T')
  const date = new Date(normalized)
  if (Number.isNaN(date.getTime())) {
    return value
  }
  const diff = Date.now() - date.getTime()
  const minute = 60 * 1000
  const hour = 60 * minute
  const day = 24 * hour
  if (diff < minute) {
    return '刚刚'
  }
  if (diff < hour) {
    return `${Math.floor(diff / minute)} 分钟前`
  }
  if (diff < day) {
    return `${Math.floor(diff / hour)} 小时前`
  }
  if (diff < 7 * day) {
    return `${Math.floor(diff / day)} 天前`
  }
  return formatDate(value)
}

export function todayLabel(): string {
  const now = new Date()
  const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
  return `${now.getMonth() + 1}月${now.getDate()}日 ${weekdays[now.getDay()]}`
}

export function greeting(): string {
  const hour = new Date().getHours()
  if (hour < 6) {
    return '夜深了'
  }
  if (hour < 11) {
    return '早上好'
  }
  if (hour < 14) {
    return '中午好'
  }
  if (hour < 18) {
    return '下午好'
  }
  return '晚上好'
}

/** 订单状态 -> 展示用色调 */
export function orderStatusTone(status: string): 'sage' | 'amber' | 'danger' | 'muted' {
  switch (status) {
    case 'COMPLETED':
    case 'EATING':
      return 'sage'
    case 'PENDING':
    case 'PREPARING':
    case 'DELIVERING':
      return 'amber'
    case 'CANCELLED':
      return 'danger'
    case 'DELIVERED':
      return 'sage'
    default:
      return 'muted'
  }
}

export function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max)
}

/** 数字滚动展示（用于金额/数量变化时的轻量过渡） */
export function useCountUp(target: () => number, duration = 600) {
  const display = ref(0)
  let frame = 0
  watch(
    target,
    (next) => {
      const from = display.value
      const start = performance.now()
      cancelAnimationFrame(frame)
      const step = (now: number) => {
        const t = Math.min(1, (now - start) / duration)
        const eased = 1 - Math.pow(1 - t, 3)
        display.value = from + (next - from) * eased
        if (t < 1) {
          frame = requestAnimationFrame(step)
        } else {
          display.value = next
        }
      }
      frame = requestAnimationFrame(step)
    },
    { immediate: true }
  )
  onBeforeUnmount(() => cancelAnimationFrame(frame))
  return display
}
