/**
 * 007 首页背景的「正放 -> 倒放 -> 正放」往返播放器。
 *
 * 需求：正放进行到最后几秒时开始倒放，倒放到头后再正放，如此循环，衔接要自然。
 *
 * 实现要点：
 * 1. HTML5 <video> 不支持负 playbackRate（规范限制），因此使用 ffmpeg 预生成的
 *    反向视频 007-reversed.mp4。
 * 2. 正向 121 帧；反向 119 帧（= 正向 f119…f1，去掉首尾两个衔接帧）。
 *    帧映射 reversed[i] == forward[120 - i]，已逐帧比对验证，
 *    因此「正向停在 f119」与「反向从 r0(=f119) 开始」完全对齐，无跳帧。
 * 3. **按帧精确匹配**：切换时不是把反向视频归零，而是跳到与当前正向帧
 *    完全对应的反向帧，两路画面在切换瞬间完全一致，肉眼看不到跳帧/闪烁。
 *    映射关系：reversed[i] == forward[REVERSE_LAST_FRAME - i]
 *    - 正向在第 k 帧 → 反向应定位到第 (119 - k) 帧
 *    - 反向在第 i 帧 → 正向应定位到第 (119 - i) 帧
 * 4. 正向播放到剩余 TAIL_SECONDS 秒时开始切换，边交叉淡化边反向播放。
 * 5. 反向播放到剩余 TAIL_SECONDS 秒时，切回正向。
 */
import { onBeforeUnmount, ref, shallowRef } from 'vue'

export type PingPongPhase = 'forward' | 'reverse'

interface PingPongOptions {
  forwardSrc: string
  reverseSrc: string
  /** 提前多久开始切换（秒）。正向时长 5.042s，取 0.6s 约等于最后 14 帧 */
  tailSeconds?: number
  /** 交叉淡化时长（毫秒） */
  fadeMs?: number
}

export function usePingPongVideo(options: PingPongOptions) {
  const tailSeconds = options.tailSeconds ?? 0.8
  const fadeMs = options.fadeMs ?? 60

  /** 视频帧率（007-1 与 007-reversed 均为 24fps） */
  const FPS = 24
  /** 反向视频最后一帧的索引：reversed[i] == forward[119 - i] */
  const REVERSE_LAST_FRAME = 119

  const videoA = shallowRef<HTMLVideoElement | null>(null)
  const videoB = shallowRef<HTMLVideoElement | null>(null)
  const phase = ref<PingPongPhase>('forward')
  const playing = ref(false)
  const error = ref<string | null>(null)

  let generation = 0
  let switching = false
  let rafId = 0

  function forwardEl(): HTMLVideoElement | null {
    return videoA.value
  }

  function reverseEl(): HTMLVideoElement | null {
    return videoB.value
  }

  function attach(slot: 'A' | 'B', el: HTMLVideoElement | null) {
    if (slot === 'A') {
      videoA.value = el
    } else {
      videoB.value = el
    }
    if (el) {
      el.playsInline = true
      el.preload = 'auto'
      el.controls = false
      el.disablePictureInPicture = true
      el.loop = false
      el.setAttribute('controlsList', 'nodownload nofullscreen noremoteplayback')
      el.setAttribute('disableRemotePlayback', '')
      el.muted = true
      el.volume = 0
    }
  }

  function crossfade(show: 'forward' | 'reverse', immediate = false) {
    const f = forwardEl()
    const r = reverseEl()
    if (!f || !r) {
      return
    }
    const dur = immediate ? 0 : fadeMs
    f.style.transition = `opacity ${dur}ms cubic-bezier(0.2, 0.7, 0.2, 1)`
    r.style.transition = `opacity ${dur}ms cubic-bezier(0.2, 0.7, 0.2, 1)`
    if (show === 'forward') {
      f.style.opacity = '1'
      r.style.opacity = '0'
    } else {
      f.style.opacity = '0'
      r.style.opacity = '1'
    }
  }

  async function safePlay(el: HTMLVideoElement): Promise<boolean> {
    try {
      await el.play()
      return true
    } catch {
      el.muted = true
      el.volume = 0
      try {
        await el.play()
        return true
      } catch {
        return false
      }
    }
  }

  /** 正向当前时间 -> 反向应对齐的时间（保证画面完全一致） */
  function forwardTimeToReverseTime(forwardTime: number): number {
    const k = Math.round(forwardTime * FPS)
    const ri = REVERSE_LAST_FRAME - k
    const clamped = Math.max(0, Math.min(REVERSE_LAST_FRAME, ri))
    return clamped / FPS
  }

  /** 反向当前时间 -> 正向应对齐的时间 */
  function reverseTimeToForwardTime(reverseTime: number): number {
    const ri = Math.round(reverseTime * FPS)
    const k = REVERSE_LAST_FRAME - ri
    const clamped = Math.max(0, k)
    return clamped / FPS
  }

  async function switchTo(target: PingPongPhase) {
    if (switching) {
      return
    }
    switching = true
    const myGen = generation
    const f = forwardEl()
    const r = reverseEl()
    if (!f || !r) {
      switching = false
      return
    }

    const incoming = target === 'forward' ? f : r
    const outgoing = target === 'forward' ? r : f

    // 关键：按帧精确对齐，让 incoming 的第一帧与 outgoing 当前帧完全一致，
    // 这样切换瞬间画面不跳变，也就不会有闪烁感。
    try {
      if (target === 'reverse') {
        // 正向 -> 反向：反向定位到与正向当前帧对应的位置
        incoming.currentTime = forwardTimeToReverseTime(outgoing.currentTime)
      } else {
        // 反向 -> 正向：正向定位到与反向当前帧对应的位置
        incoming.currentTime = reverseTimeToForwardTime(outgoing.currentTime)
      }
    } catch {
      /* ignore */
    }
    const ok = await safePlay(incoming)
    if (!ok || myGen !== generation) {
      switching = false
      return
    }

    phase.value = target
    crossfade(target)

    window.setTimeout(() => {
      if (myGen === generation) {
        try {
          outgoing.pause()
        } catch {
          /* ignore */
        }
        switching = false
      }
    }, fadeMs + 30)
  }

  /** 主循环：检测是否到达切换点 */
  function tick() {
    const f = forwardEl()
    const r = reverseEl()
    if (!f || !r || !playing.value) {
      return
    }

    if (!switching) {
      if (phase.value === 'forward') {
        if (Number.isFinite(f.duration) && f.duration > 0 && !f.paused) {
          const remaining = f.duration - f.currentTime
          if (remaining <= tailSeconds && remaining > 0.02) {
            void switchTo('reverse')
          }
        }
      } else {
        if (Number.isFinite(r.duration) && r.duration > 0 && !r.paused) {
          const remaining = r.duration - r.currentTime
          if (remaining <= tailSeconds && remaining > 0.02) {
            void switchTo('forward')
          }
        }
      }
    }

    rafId = window.requestAnimationFrame(tick)
  }

  async function start() {
    generation++
    const myGen = generation
    const f = forwardEl()
    const r = reverseEl()
    if (!f || !r) {
      return
    }

    if (!f.getAttribute('src')) {
      f.src = options.forwardSrc
      f.load()
    }
    if (!r.getAttribute('src')) {
      r.src = options.reverseSrc
      r.load()
    }

    try {
      f.currentTime = 0
      r.currentTime = 0
    } catch {
      /* ignore */
    }

    const ok = await safePlay(f)
    if (!ok || myGen !== generation) {
      error.value = '首页背景视频播放失败'
      return
    }

    phase.value = 'forward'
    crossfade('forward', true)
    playing.value = true
    switching = false

    window.cancelAnimationFrame(rafId)
    rafId = window.requestAnimationFrame(tick)
  }

  function pause() {
    generation++
    playing.value = false
    window.cancelAnimationFrame(rafId)
    ;[forwardEl(), reverseEl()].forEach((el) => {
      if (el && !el.paused) {
        el.pause()
      }
    })
  }

  function setAudible(audible: boolean, volume = 1) {
    ;[forwardEl(), reverseEl()].forEach((el) => {
      if (!el) {
        return
      }
      el.muted = !audible
      el.volume = audible ? volume : 0
    })
  }

  function destroy() {
    pause()
    ;[forwardEl(), reverseEl()].forEach((el) => {
      if (el) {
        el.removeAttribute('src')
        el.load()
      }
    })
  }

  onBeforeUnmount(destroy)

  return {
    videoA,
    videoB,
    phase,
    playing,
    error,
    attach,
    start,
    pause,
    setAudible,
    destroy
  }
}
