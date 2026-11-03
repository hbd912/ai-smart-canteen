import { getUserToken } from './http'
import type { AiRecommendResult } from '@/types/api'

const BASE_URL = import.meta.env.VITE_API_BASE_URL || ''

export interface AiStreamMeta {
  conversationId?: number | null
  modeLabel?: string
}

export interface AiStreamHandlers {
  onMeta?: (meta: AiStreamMeta) => void
  /** 增量文字，用于逐字渲染 */
  onDelta?: (text: string) => void
  /** 结束：完整结果（含菜品卡与多轮会话 id） */
  onDone?: (answer: AiRecommendResult) => void
  onError?: (message: string) => void
}

/**
 * 流式提问（SSE）。
 * 不使用 EventSource：它不支持 POST，也无法携带 Authorization。
 * 这里用 fetch + ReadableStream 手工解析 event-stream。
 */
export async function askAiStream(
  payload: { message: string; conversationId?: number | null; budgetMax?: number },
  handlers: AiStreamHandlers,
  signal?: AbortSignal
): Promise<void> {
  const token = getUserToken()
  const response = await fetch(`${BASE_URL}/api/v1/ai/stream`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      Accept: 'text/event-stream',
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    },
    body: JSON.stringify(payload),
    signal
  })

  if (!response.ok) {
    let message = `请求失败（HTTP ${response.status}）`
    try {
      const text = await response.text()
      if (text) {
        message = text
      }
    } catch {
      /* ignore */
    }
    throw new Error(message)
  }
  if (!response.body) {
    throw new Error('当前浏览器不支持流式响应')
  }

  const reader = response.body.getReader()
  const decoder = new TextDecoder('utf-8')
  let buffer = ''
  let finished = false

  try {
    while (true) {
      const { done, value } = await reader.read()
      if (done) {
        break
      }
      buffer += decoder.decode(value, { stream: true })
      let sep = buffer.search(/\r?\n\r?\n/)
      while (sep !== -1) {
        const rawEvent = buffer.slice(0, sep)
        buffer = buffer.slice(sep).replace(/^\r?\n\r?\n/, '')
        const parsed = parseEvent(rawEvent)
        if (parsed) {
          finished = handleEvent(parsed, handlers)
        }
        if (finished) {
          // 后端 done 之后连接可能仍被代理保持，主动取消，避免 loading 一直挂住
          try {
            await reader.cancel()
          } catch {
            /* ignore */
          }
          return
        }
        sep = buffer.search(/\r?\n\r?\n/)
      }
    }
  } finally {
    try {
      reader.releaseLock()
    } catch {
      /* ignore */
    }
  }
}

/** 处理单条事件；返回 true 表示流已结束，可以停止读取 */
function handleEvent(parsed: { event: string; data: string }, handlers: AiStreamHandlers): boolean {
  try {
    if (parsed.event === 'meta') {
      handlers.onMeta?.(JSON.parse(parsed.data) as AiStreamMeta)
    } else if (parsed.event === 'delta') {
      const obj = JSON.parse(parsed.data) as { text?: string }
      if (obj.text) {
        handlers.onDelta?.(obj.text)
      }
    } else if (parsed.event === 'done') {
      const obj = JSON.parse(parsed.data) as { answer?: AiRecommendResult }
      if (obj.answer) {
        handlers.onDone?.(obj.answer)
      }
      return true
    } else if (parsed.event === 'error') {
      const obj = JSON.parse(parsed.data) as { message?: string }
      handlers.onError?.(obj.message || '流式请求失败')
      return true
    }
  } catch {
    /* 单条事件解析失败不影响后续 */
  }
  return false
}

function parseEvent(raw: string): { event: string; data: string } | null {
  let event = 'message'
  const dataLines: string[] = []
  for (const line of raw.split(/\r?\n/)) {
    if (!line || line.startsWith(':')) {
      continue
    }
    if (line.startsWith('event:')) {
      event = line.slice(6).trim()
    } else if (line.startsWith('data:')) {
      dataLines.push(line.slice(5).trim())
    }
  }
  if (!dataLines.length) {
    return null
  }
  return { event, data: dataLines.join('\n') }
}
