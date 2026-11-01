<script setup lang="ts">
/**
 * 环形进度（今日营养达成率）。数据驱动：百分比由真实营养接口计算。
 */
import { computed, onMounted, ref, watch } from 'vue'

const props = withDefaults(
  defineProps<{
    percent: number
    size?: number
    stroke?: number
    color?: string
    trackColor?: string
    label?: string
  }>(),
  { size: 104, stroke: 9, color: 'var(--sage-500)', trackColor: 'rgba(124,143,90,0.18)' }
)

const animated = ref(0)
const radius = computed(() => (props.size - props.stroke) / 2)
const circumference = computed(() => 2 * Math.PI * radius.value)
const offset = computed(() => circumference.value * (1 - Math.min(Math.max(animated.value, 0), 100) / 100))

function animateTo(target: number) {
  const start = animated.value
  const duration = 950
  const t0 = performance.now()
  const step = (now: number) => {
    const t = Math.min(1, (now - t0) / duration)
    const eased = 1 - Math.pow(1 - t, 3)
    animated.value = start + (target - start) * eased
    if (t < 1) {
      requestAnimationFrame(step)
    }
  }
  requestAnimationFrame(step)
}

onMounted(() => animateTo(props.percent))
watch(() => props.percent, (next) => animateTo(next))
</script>

<template>
  <div class="ring" :style="{ width: `${size}px`, height: `${size}px` }">
    <svg :width="size" :height="size" :viewBox="`0 0 ${size} ${size}`">
      <circle
        :cx="size / 2"
        :cy="size / 2"
        :r="radius"
        fill="none"
        :stroke="trackColor"
        :stroke-width="stroke"
      />
      <circle
        :cx="size / 2"
        :cy="size / 2"
        :r="radius"
        fill="none"
        :stroke="color"
        :stroke-width="stroke"
        stroke-linecap="round"
        :stroke-dasharray="circumference"
        :stroke-dashoffset="offset"
        :transform="`rotate(-90 ${size / 2} ${size / 2})`"
      />
    </svg>
    <div class="ring__content">
      <span class="ring__value num">{{ Math.round(animated) }}<small>%</small></span>
      <span v-if="label" class="ring__label">{{ label }}</span>
    </div>
  </div>
</template>

<style scoped>
.ring {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  flex: none;
}

.ring svg {
  position: absolute;
  inset: 0;
}

.ring__content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1px;
  line-height: 1.15;
}

.ring__value {
  font-size: 23px;
  font-weight: 700;
  color: var(--sage-700);
}

.ring__value small {
  font-size: 11px;
  margin-left: 1px;
  color: var(--ink-500);
}

.ring__label {
  font-size: 10.5px;
  color: var(--ink-500);
}
</style>
