/**
 * SceneVideoController：全部视频播放的唯一入口（组件不直接操作 video）。
 *
 * 支持三种模式：
 * - play：叙事过渡，只播一次，ended 后回调
 * - loop：原生循环（HOME_IDLE 的 007 / EATING 的 008）
 * - hold：精准 seek 到末帧并暂停（保留备用）
 *
 * 声音：所有 video 默认静音以满足自动播放策略，实际音量由 useAudioUnlock 统一控制。
 */
import { onBeforeUnmount, ref, shallowRef } from 'vue'
import { LOOP_VIDEOS, SCENE_VIDEOS, VIDEO_ORDER, type SceneVideoId } from '@/config/media'

export type SceneMode = 'play' | 'loop' | 'hold'

interface LoadOptions {
  videoId: SceneVideoId
  mode: SceneMode
  /** 强制重新加载（即使 videoId 与 mode 都相同） */
  force?: boolean
}

interface VideoLayer {
  id: SceneVideoId | null
  ready: boolean
  visible: boolean
}

export function useSceneVideoController() {
  const layerA = shallowRef<HTMLVideoElement | null>(null)
  const layerB = shallowRef<HTMLVideoElement | null>(null)
  const activeSlot = ref<'A' | 'B'>('A')

  const currentVideoId = ref<SceneVideoId | null>(null)
  const currentMode = ref<SceneMode>('hold')
  const loading = ref(false)
  const ready = ref(false)
  const playing = ref(false)
  const error = ref<string | null>(null)
  const progress = ref(0)
  const duration = ref(0)
  const slots = ref<Record<'A' | 'B', VideoLayer>>({
    A: { id: null, ready: false, visible: false },
    B: { id: null, ready: false, visible: false }
  })

  let generation = 0
  let endedGuard = 0
  const preloaded = new Set<SceneVideoId>()
  const preloaders: HTMLVideoElement[] = []

  function activeEl(): HTMLVideoElement | null {
    return activeSlot.value === 'A' ? layerA.value : layerB.value
  }

  function otherSlot(): 'A' | 'B' {
    return activeSlot.value === 'A' ? 'B' : 'A'
  }

  function slotEl(slot: 'A' | 'B'): HTMLVideoElement | null {
    return slot === 'A' ? layerA.value : layerB.value
  }

  function attach(slot: 'A' | 'B', el: HTMLVideoElement | null) {
    if (slot === 'A') {
      layerA.value = el
    } else {
      layerB.value = el
    }
    if (el) {
      el.muted = true
      el.defaultMuted = true
      el.volume = 0
      el.playsInline = true
      el.preload = 'auto'
      el.controls = false
      el.disablePictureInPicture = true
      el.setAttribute('controlsList', 'nodownload nofullscreen noremoteplayback')
      el.setAttribute('disableRemotePlayback', '')
    }
  }

  function preload(videoId: SceneVideoId | null | undefined) {
    if (!videoId || preloaded.has(videoId) || typeof document === 'undefined') {
      return
    }
    const meta = SCENE_VIDEOS[videoId]
    if (!meta) {
      return
    }
    ;[meta.poster, meta.endPoster].forEach((src) => {
      const img = new Image()
      img.src = src
    })
    try {
      const el = document.createElement('video')
      el.src = meta.src
      el.preload = 'auto'
      el.muted = true
      el.volume = 0
      el.style.display = 'none'
      el.load()
      preloaders.push(el)
      preloaded.add(videoId)
    } catch {
      /* ignore */
    }
  }

  function preloadRemaining(fromVideoId: SceneVideoId) {
    const index = VIDEO_ORDER.indexOf(fromVideoId)
    VIDEO_ORDER.slice(index + 1).forEach((id) => preload(id))
  }

  function nextVideoId(videoId: SceneVideoId): SceneVideoId | null {
    const index = VIDEO_ORDER.indexOf(videoId)
    return index >= 0 && index < VIDEO_ORDER.length - 1 ? VIDEO_ORDER[index + 1] : null
  }

  function resetSlot(slot: 'A' | 'B') {
    slots.value = {
      ...slots.value,
      [slot]: { id: null, ready: false, visible: false }
    }
  }

  /** 加载并播放 */
  async function load(options: LoadOptions): Promise<void> {
    const meta = SCENE_VIDEOS[options.videoId]
    if (!meta) {
      error.value = `视频配置缺失：${options.videoId}`
      return
    }
    // 幂等（force 时跳过，用于叙事视频播完后重新启动稳态循环）
    if (!options.force && currentVideoId.value === options.videoId && currentMode.value === options.mode) {
      const el = activeEl()
      if (options.mode !== 'hold' && el && !el.paused && !el.ended) {
        playing.value = true
        return
      }
      if (options.mode === 'hold') {
        return
      }
    }

    const myGeneration = ++generation
    endedGuard = 0

    const previousSlot = activeSlot.value
    const targetSlot = slots.value[previousSlot].id ? otherSlot() : previousSlot
    const el = slotEl(targetSlot)
    if (!el) {
      loading.value = true
      window.setTimeout(() => {
        if (myGeneration === generation) {
          void load(options)
        }
      }, 60)
      return
    }

    loading.value = true
    error.value = null
    progress.value = 0
    currentMode.value = options.mode
    currentVideoId.value = options.videoId

    activeSlot.value = targetSlot
    slots.value = {
      ...slots.value,
      [targetSlot]: { id: options.videoId, ready: false, visible: false }
    }

    el.loop = options.mode === 'loop'
    el.muted = true
    el.volume = 0
    if (el.getAttribute('data-src') !== meta.src) {
      el.setAttribute('data-src', meta.src)
      el.src = meta.src
      el.load()
    }

    const canPlay = await waitForReady(el, myGeneration)
    if (myGeneration !== generation) {
      return
    }
    if (!canPlay) {
      loading.value = false
      if (!error.value) {
        error.value = '视频加载超时，请重试'
      }
      return
    }

    duration.value = Number.isFinite(el.duration) ? el.duration : 0

    if (options.mode === 'play' || options.mode === 'loop') {
      try {
        el.currentTime = 0
      } catch {
        /* ignore */
      }
      const ok = await safePlay(el, myGeneration)
      if (myGeneration !== generation) {
        return
      }
      if (!ok) {
        loading.value = false
        return
      }
    } else {
      const target = Math.max(duration.value - 0.05, 0)
      try {
        el.currentTime = target
      } catch {
        /* ignore */
      }
      el.pause()
      playing.value = false
      progress.value = 100
    }

    ready.value = true
    loading.value = false
    slots.value = {
      ...slots.value,
      [targetSlot]: { id: options.videoId, ready: true, visible: true }
    }
    if (previousSlot !== targetSlot) {
      window.setTimeout(() => {
        if (myGeneration === generation) {
          resetSlot(previousSlot)
        }
      }, 480)
    }

    preload(nextVideoId(options.videoId))
  }

  function waitForReady(el: HTMLVideoElement, myGeneration: number): Promise<boolean> {
    if (el.readyState >= 2) {
      return Promise.resolve(true)
    }
    return new Promise<boolean>((resolve) => {
      let settled = false
      const cleanup = () => {
        el.removeEventListener('loadeddata', onReady)
        el.removeEventListener('canplay', onReady)
        el.removeEventListener('error', onError)
        window.clearTimeout(timer)
      }
      const finish = (ok: boolean) => {
        if (settled) {
          return
        }
        settled = true
        cleanup()
        resolve(ok)
      }
      const onReady = () => finish(myGeneration === generation)
      const onError = () => {
        if (myGeneration === generation) {
          error.value = '视频加载失败，请检查素材文件或点击重试'
        }
        finish(false)
      }
      el.addEventListener('loadeddata', onReady)
      el.addEventListener('canplay', onReady)
      el.addEventListener('error', onError)
      const timer = window.setTimeout(() => {
        if (myGeneration === generation && el.readyState < 2) {
          error.value = '视频加载超时，请检查网络或素材'
        }
        finish(el.readyState >= 2)
      }, 12000)
    })
  }

  async function safePlay(el: HTMLVideoElement, myGeneration: number): Promise<boolean> {
    try {
      await el.play()
      if (myGeneration === generation) {
        playing.value = true
      }
      return true
    } catch (e) {
      if (myGeneration !== generation) {
        return false
      }
      playing.value = false
      const message = e instanceof Error ? e.message : String(e)
      if (message.includes('interrupted') || message.includes('pause')) {
        return false
      }
      if (!el.muted) {
        el.muted = true
        el.volume = 0
        try {
          await el.play()
          playing.value = true
          return true
        } catch {
          /* fallthrough */
        }
      }
      error.value = '视频播放被浏览器拦截，请点击画面继续'
      return false
    }
  }

  function pause() {
    const el = activeEl()
    if (el && !el.paused) {
      el.pause()
    }
    playing.value = false
  }

  async function resume() {
    const el = activeEl()
    if (!el) {
      return
    }
    if (currentMode.value === 'hold') {
      return
    }
    await safePlay(el, generation)
  }

  async function retry() {
    const videoId = currentVideoId.value
    if (!videoId) {
      return
    }
    const mode = currentMode.value
    error.value = null
    ready.value = false
    const el = activeEl()
    if (el) {
      el.removeAttribute('data-src')
      el.src = SCENE_VIDEOS[videoId].src
      el.load()
    }
    currentVideoId.value = null
    await load({ videoId, mode })
  }

  function handleEnded() {
    const el = activeEl()
    if (!el || !currentVideoId.value) {
      return
    }
    if (currentMode.value === 'loop') {
      return
    }
    if (currentMode.value === 'hold') {
      return
    }
    playing.value = false
    const endedVideoId = currentVideoId.value
    if (endedGuard > 0) {
      return
    }
    endedGuard++
    emitEnded(endedVideoId)
  }

  const endedHandlers = new Set<(videoId: SceneVideoId) => void>()

  function onEnded(handler: (videoId: SceneVideoId) => void) {
    endedHandlers.add(handler)
    return () => endedHandlers.delete(handler)
  }

  function emitEnded(videoId: SceneVideoId) {
    endedHandlers.forEach((handler) => handler(videoId))
  }

  function handleTimeUpdate() {
    const el = activeEl()
    if (!el || !Number.isFinite(el.duration) || el.duration === 0) {
      return
    }
    progress.value = Math.min(100, Math.round((el.currentTime / el.duration) * 100))
  }

  function handleError() {
    if (currentVideoId.value) {
      error.value = '视频加载失败，请点击重试'
    }
    loading.value = false
  }

  /** 全部视频元素（供声音系统注册） */
  function allMediaElements(): HTMLMediaElement[] {
    return [layerA.value, layerB.value].filter((v): v is HTMLVideoElement => !!v)
  }

  function destroy() {
    generation++
    endedHandlers.clear()
    preloaders.forEach((el) => {
      el.removeAttribute('src')
      el.load()
    })
    preloaders.length = 0
    preloaded.clear()
  }

  onBeforeUnmount(destroy)

  return {
    layerA,
    layerB,
    activeSlot,
    slots,
    currentVideoId,
    currentMode,
    loading,
    ready,
    playing,
    error,
    progress,
    duration,
    attach,
    load,
    pause,
    resume,
    retry,
    preload,
    preloadRemaining,
    onEnded,
    handleEnded,
    handleTimeUpdate,
    handleError,
    allMediaElements,
    destroy
  }
}
