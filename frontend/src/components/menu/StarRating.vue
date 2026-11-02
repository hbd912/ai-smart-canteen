<script setup lang="ts">
/**
 * 星级评分组件：支持只读展示与交互打分两种模式。
 * 参考项目 StarRating 的交互方式，按本项目视觉体系重新实现。
 */
import { computed } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'

const props = withDefaults(
  defineProps<{
    /** 当前评分 1~5，可为小数（只读展示时四舍五入到半星以内） */
    modelValue: number
    /** 是否可交互 */
    editable?: boolean
    /** 尺寸 */
    size?: number
    /** 是否显示数值文字 */
    showValue?: boolean
  }>(),
  { editable: false, size: 16, showValue: false }
)

const emit = defineEmits<{
  (e: 'update:modelValue', value: number): void
}>()

const stars = [1, 2, 3, 4, 5]

/** 每颗星填充程度：0 = 空，1 = 满 */
const fillRatios = computed(() =>
  stars.map((i) => {
    const v = props.modelValue ?? 0
    if (v >= i) {
      return 1
    }
    if (v > i - 1) {
      return v - (i - 1)
    }
    return 0
  })
)

function pick(value: number) {
  if (!props.editable) {
    return
  }
  emit('update:modelValue', value)
}
</script>

<template>
  <div class="star-rating" :class="{ 'star-rating--editable': editable }" role="img" :aria-label="`评分 ${modelValue} 星`">
    <button
      v-for="(ratio, idx) in fillRatios"
      :key="idx"
      class="star-rating__star"
      :class="{ 'star-rating__star--filled': ratio >= 0.5 }"
      type="button"
      :disabled="!editable"
      :tabindex="editable ? 0 : -1"
      :aria-label="`${idx + 1} 星`"
      @click="pick(idx + 1)"
    >
      <AppIcon name="star" :size="size" :filled="ratio >= 0.5" />
    </button>
    <span v-if="showValue" class="star-rating__value num">{{ Number(modelValue).toFixed(1) }}</span>
  </div>
</template>

<style scoped>
.star-rating {
  display: inline-flex;
  align-items: center;
  gap: 1px;
}

.star-rating__star {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  color: var(--ink-300);
  cursor: default;
  transition: color var(--motion-fast) var(--ease-standard),
    transform var(--motion-fast) var(--ease-standard);
}

.star-rating--editable .star-rating__star {
  cursor: pointer;
  padding: 2px;
}

.star-rating--editable .star-rating__star:hover {
  transform: scale(1.15);
}

.star-rating__star--filled {
  color: var(--amber-500);
}

.star-rating__value {
  margin-left: 5px;
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--amber-600);
}
</style>
