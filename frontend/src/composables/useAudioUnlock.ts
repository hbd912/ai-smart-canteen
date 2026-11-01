/**
 * 声音系统：处理浏览器自动播放策略 + 用户开关 + 持久化。
 *
 * 策略（按需求 §1.2）：
 * 1. 首次进入：静音自动播放，保证一定能播出来。
 * 2. 用户在页面第一次点击/触摸：解除静音（此时已有用户手势，允许出声）。
 * 3. 右上角常驻声音开关，状态持久化到 localStorage。
 * 4. 切换时用短时音量渐变，不爆音、不突然静音。
 */
import { computed, ref } from 'vue'

const STORAGE_KEY = 'canteen.sound.enabled'
/** 音量渐变时长（毫秒） */
const FADE_MS = 220
const TARGET_VOLUME = 0.85

/** 全局单例状态（跨组件共享） */
const soundEnabled = ref(true)
const unlocked = ref(false)
const appliedVolume = ref(0)

let fadeTimer = 0

/** 读取持久化偏好（默认开启声音） */
function readStored(): boolean {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw === null) {
      return true
    }
    return raw === 'true'
  } catch {
    return true
  }
}

soundEnabled.value = readStored()

/** 注册的音频目标（每个 video 元素一个） */
type AudioTarget = () => HTMLMediaElement | null
const targets = new Set<AudioTarget>()

function forEachMedia(fn: (el: HTMLMediaElement) => void) {
  targets.forEach((getter) => {
    const el = getter()
    if (el) {
      fn(el)
    }
  })
}

/** 平滑设置所有目标的音量 */
function applyVolume(target: number, immediate = false) {
  window.clearTimeout(fadeTimer)
  const start = appliedVolume.value
  const end = Math.max(0, Math.min(1, target))
  if (immediate) {
    appliedVolume.value = end
    forEachMedia((el) => {
      el.volume = end
      el.muted = end === 0
    })
    return
  }
  const t0 = performance.now()
  const step = (now: number) => {
    const t = Math.min(1, (now - t0) / FADE_MS)
    // 插值结果必须夹紧到 [0,1]：浮点误差会产生 -0.001 这类越界值，
    // 直接赋给 el.volume 会抛 IndexSizeError。
    const raw = start + (end - start) * t
    const v = Math.max(0, Math.min(1, raw))
    appliedVolume.value = v
    forEachMedia((el) => {
      try {
        el.volume = v
      } catch {
        el.volume = v > 0 ? 1 : 0
      }
      el.muted = v === 0
    })
    if (t < 1) {
      fadeTimer = window.requestAnimationFrame(step)
    }
  }
  fadeTimer = window.requestAnimationFrame(step)
}

/** 是否应该出声：用户开启 + 已完成手势解锁 */
const shouldBeAudible = computed(() => soundEnabled.value && unlocked.value)

function syncVolume(immediate = false) {
  applyVolume(shouldBeAudible.value ? TARGET_VOLUME : 0, immediate)
}

/** 注册一个音频目标（video 元素） */
function register(getter: AudioTarget): () => void {
  targets.add(getter)
  // 立即同步当前音量状态
  const el = getter()
  if (el) {
    const v = shouldBeAudible.value ? TARGET_VOLUME : 0
    el.volume = v
    el.muted = v === 0
  }
  return () => targets.delete(getter)
}

/** 首次用户手势：解除静音 */
function unlock() {
  if (unlocked.value) {
    return
  }
  unlocked.value = true
  syncVolume()
}

/** 用户主动切换开关 */
function toggle(): boolean {
  soundEnabled.value = !soundEnabled.value
  try {
    localStorage.setItem(STORAGE_KEY, String(soundEnabled.value))
  } catch {
    /* ignore */
  }
  // 用户点了开关本身就是一次手势，顺带解锁
  if (!unlocked.value) {
    unlocked.value = true
  }
  syncVolume()
  return soundEnabled.value
}

/** 绑定一次性手势监听（在 App 或场景根组件调用） */
function bindUnlockOnce(): () => void {
  const handler = () => {
    unlock()
  }
  // pointerdown 覆盖鼠标与触摸，keydown 覆盖键盘
  document.addEventListener('pointerdown', handler, { once: true, capture: true })
  document.addEventListener('keydown', handler, { once: true, capture: true })
  return () => {
    document.removeEventListener('pointerdown', handler, { capture: true })
    document.removeEventListener('keydown', handler, { capture: true })
  }
}

export function useAudioUnlock() {
  return {
    soundEnabled,
    unlocked,
    shouldBeAudible,
    register,
    unlock,
    toggle,
    bindUnlockOnce,
    syncVolume
  }
}
