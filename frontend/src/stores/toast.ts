import { defineStore } from 'pinia'
import { ref } from 'vue'

export interface ToastItem {
  id: number
  type: 'success' | 'error' | 'info' | 'warning'
  message: string
  detail?: string
  duration: number
}

let seed = 0

/** 轻提示。所有交互反馈都走这里，避免使用原生 alert 破坏沉浸感 */
export const useToastStore = defineStore('toast', () => {
  const items = ref<ToastItem[]>([])

  function push(type: ToastItem['type'], message: string, detail?: string, duration = 2600) {
    const id = ++seed
    items.value = [...items.value, { id, type, message, detail, duration }]
    window.setTimeout(() => remove(id), duration)
    return id
  }

  function remove(id: number) {
    items.value = items.value.filter((item) => item.id !== id)
  }

  return {
    items,
    push,
    remove,
    success: (message: string, detail?: string) => push('success', message, detail),
    error: (message: string, detail?: string) => push('error', message, detail, 3400),
    info: (message: string, detail?: string) => push('info', message, detail),
    warning: (message: string, detail?: string) => push('warning', message, detail, 3000)
  }
})
