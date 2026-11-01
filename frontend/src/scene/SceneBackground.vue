<script setup lang="ts">
/**
 * 场景背景层：双 video 交叉淡化 + 静止帧垫底 + 环境光。
 * 只负责呈现，不决定业务状态。
 *
 * 画质说明：
 * - 视频以原生分辨率渲染，不做额外缩放滤镜；
 * - object-fit: cover + 精确 object-position，保证人物头部/手部/餐盘不被裁切；
 * - 关闭 image-rendering 相关优化，保持浏览器默认高质量插值。
 */
import { computed } from 'vue'
import type { ComponentPublicInstance } from 'vue'
import { SCENE_VIDEOS, type SceneVideoId } from '@/config/media'

const props = defineProps<{
  activeSlot: 'A' | 'B'
  slots: Record<'A' | 'B', { id: SceneVideoId | null; ready: boolean; visible: boolean }>
  /** 静止帧（稳态末帧），用于视频结束后的垫底 */
  stillFrame: SceneVideoId | null
}>()

const emit = defineEmits<{
  (e: 'ended'): void
  (e: 'timeupdate'): void
  (e: 'error'): void
  (e: 'attach', slot: 'A' | 'B', el: HTMLVideoElement | null): void
}>()

function srcOf(slot: 'A' | 'B'): string {
  const id = props.slots[slot].id
  return id ? SCENE_VIDEOS[id].src : ''
}

function posterOf(slot: 'A' | 'B'): string | undefined {
  const id = props.slots[slot].id
  return id ? SCENE_VIDEOS[id].poster : undefined
}

function onRef(slot: 'A' | 'B', el: Element | ComponentPublicInstance | null) {
  emit('attach', slot, (el as HTMLVideoElement | null) ?? null)
}

/** 静止帧海报 */
const stillPoster = computed(() => {
  const id = props.stillFrame
  if (!id) {
    return null
  }
  return SCENE_VIDEOS[id].endPoster
})

const anySlotFilled = computed(() => !!(props.slots.A.id || props.slots.B.id))
</script>

<template>
  <div class="scene-bg" aria-hidden="true">
    <!-- 静止帧垫底：视频未就绪或已结束时的兜底，防止黑屏 -->
    <Transition name="fade">
      <img
        v-if="stillPoster && !anySlotFilled"
        class="scene-bg__still"
        :src="stillPoster"
        alt=""
      />
    </Transition>

    <video
      v-for="slot in (['A', 'B'] as const)"
      :key="slot"
      :ref="(el) => onRef(slot, el)"
      class="scene-bg__video"
      :class="{
        'scene-bg__video--visible': slots[slot].visible && slots[slot].ready,
        'scene-bg__video--hidden': !slots[slot].id
      }"
      :poster="posterOf(slot)"
      playsinline
      muted
      preload="auto"
      disablepictureinpicture
      disableRemotePlayback
      :controls="false"
      @ended="slot === activeSlot && emit('ended')"
      @timeupdate="slot === activeSlot && emit('timeupdate')"
      @error="slot === activeSlot && emit('error')"
    ></video>

    <div class="scene-bg__ambient"></div>
    <div class="scene-bg__vignette"></div>
  </div>
</template>

<style scoped>
.scene-bg {
  position: absolute;
  inset: 0;
  overflow: hidden;
  background: #d8cdb8;
  pointer-events: none;
}

.scene-bg__still {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: 50% 50%;
  pointer-events: none;
}

.scene-bg__video {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: contain;
  object-position: 50% 50%;
  image-rendering: auto;
  pointer-events: none;
  opacity: 0;
  transition: opacity var(--motion-normal) var(--ease-standard);
}

.scene-bg__video--visible {
  opacity: 1;
}

.scene-bg__video--hidden {
  opacity: 0;
  visibility: hidden;
}

.scene-bg__ambient {
  position: absolute;
  inset: 0;
  pointer-events: none;
  background:
    radial-gradient(48% 42% at 12% 8%, rgba(255, 226, 178, 0.16), transparent 72%),
    radial-gradient(42% 38% at 88% 92%, rgba(204, 226, 188, 0.14), transparent 74%);
  animation: ambient-drift 19s ease-in-out infinite;
  mix-blend-mode: soft-light;
}

.scene-bg__vignette {
  position: absolute;
  inset: 0;
  pointer-events: none;
  background:
    linear-gradient(to right, rgba(250, 245, 233, 0.2) 0%, rgba(250, 245, 233, 0) 24%),
    linear-gradient(to bottom, rgba(250, 245, 233, 0.12) 0%, rgba(250, 245, 233, 0) 20%);
}

@media (max-width: 1023px) {
  .scene-bg__video {
    object-position: 50% 50%;
  }
}
</style>
