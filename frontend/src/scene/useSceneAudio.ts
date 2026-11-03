/**
 * SceneAudioController：动画音轨的唯一播放入口。
 *
 * 视频本身保持静音，声音统一从 Music/ 拆分出来的 mp3 播放：
 * - 普通视频：与视频同时开始，播完即停
 * - loop 视频（007 / 008）：音轨循环
 * - HOME_IDLE 的正放/倒放往返：音轨按 007-1.mp3 循环，不随倒放反向
 *
 * 音量与静音由 useAudioUnlock 统一控制（默认静音自动播放，首次手势后出声）。
 */
import { onBeforeUnmount, shallowRef, watch } from 'vue'
import { useAudioUnlock } from '@/composables/useAudioUnlock'
import { SCENE_VIDEOS, type SceneVideoId } from '@/config/media'

interface SceneAudioOptions {
  /** 当前是否处于 HOME_IDLE 的 007 往返循环 */
  isPingPong: () => boolean
  /** 状态机希望播放的视频 id（null 表示停帧/静止） */
  videoId: () => SceneVideoId | null
  /** 视频控制器是否真的在播放 */
  playing: () => boolean
}

export function useSceneAudio(options: SceneAudioOptions) {
  const element = shallowRef<HTMLAudioElement | null>(null)
  const audio = useAudioUnlock()
  let unregister: (() => void) | null = null
  let currentAudioId: SceneVideoId | null = null
  /** 是否被主动暂停过：再次进入同一片段时需要从头重播 */
  let stopped = false

  function ensureElement(): HTMLAudioElement {
    if (element.value) {
      return element.value
    }
    const el = new Audio()
    el.preload = 'auto'
    // 先静音保证自动播放一定成功；解锁/开启声音由 useAudioUnlock 统一改音量
    el.muted = true
    el.volume = 0
    // 挂到 DOM（隐藏）便于浏览器稳定播放，也方便排查当前音轨
    el.setAttribute('data-scene-audio', 'true')
    el.style.display = 'none'
    document.body.appendChild(el)
    element.value = el
    unregister = audio.register(() => element.value)
    return el
  }

  function applySource(id: SceneVideoId): HTMLAudioElement {
    const el = ensureElement()
    const meta = SCENE_VIDEOS[id]
    if (el.getAttribute('data-src') !== meta.audioSrc) {
      el.setAttribute('data-src', meta.audioSrc)
      el.src = meta.audioSrc
      el.load()
    }
    el.loop = meta.loop
    currentAudioId = id
    return el
  }

  function pausePlayback() {
    stopped = true
    const el = element.value
    if (el && !el.paused) {
      el.pause()
    }
  }

  async function playId(id: SceneVideoId, restart: boolean) {
    const el = applySource(id)
    stopped = false
    if (restart) {
      try {
        el.currentTime = 0
      } catch {
        /* ignore */
      }
    }
    try {
      await el.play()
    } catch {
      /* 已被静音，正常不会被拦截；失败时等下一次状态变化重试 */
    }
  }

  function sync() {
    // HOME_IDLE：007 音轨常驻循环
    if (options.isPingPong()) {
      const el = element.value
      if (currentAudioId === '007-1' && !stopped && el) {
        if (el.paused) {
          void el.play().catch(() => {})
        }
        return
      }
      void playId('007-1', true)
      return
    }

    const id = options.videoId()
    if (!id || !options.playing()) {
      pausePlayback()
      return
    }
    // 同一片段被暂停后恢复（如重试）时继续播放，不在中途重置
    const restart = currentAudioId !== id
    void playId(id, restart)
  }

  watch(
    () => [options.isPingPong(), options.videoId(), options.playing()] as const,
    sync,
    { immediate: true }
  )

  onBeforeUnmount(() => {
    unregister?.()
    unregister = null
    const el = element.value
    if (el) {
      el.pause()
      el.removeAttribute('src')
      el.load()
      el.remove()
    }
    element.value = null
  })

  return { element }
}
