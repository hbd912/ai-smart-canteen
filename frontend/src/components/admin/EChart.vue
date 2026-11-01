<script setup lang="ts">
/**
 * ECharts 轻封装：统一主题、自适应、空状态。
 * 只负责渲染，数据全部由父组件从统计接口传入。
 */
import { onBeforeUnmount, onMounted, ref, shallowRef, watch } from 'vue'
import * as echarts from 'echarts'

const props = withDefaults(
  defineProps<{
    option: Record<string, unknown> | null
    height?: string
    loading?: boolean
    empty?: boolean
    emptyText?: string
  }>(),
  { height: '260px', loading: false, empty: false, emptyText: '暂无数据' }
)

const container = ref<HTMLDivElement | null>(null)
const chart = shallowRef<echarts.ECharts | null>(null)
let resizeObserver: ResizeObserver | null = null

const THEME = {
  color: ['#7C8F5A', '#D98F38', '#97A97A', '#E8A95A', '#5A7F96', '#B6C4A0', '#C47A2A'],
  textStyle: { fontFamily: 'Microsoft YaHei, PingFang SC, sans-serif', color: '#514C44' }
}

function render() {
  if (!container.value || !props.option || props.empty) {
    return
  }
  if (!chart.value) {
    chart.value = echarts.init(container.value, undefined, { renderer: 'canvas' })
  }
  chart.value.setOption({ ...THEME, ...props.option } as echarts.EChartsOption, true)
  chart.value.resize()
}

function dispose() {
  chart.value?.dispose()
  chart.value = null
}

watch(
  () => [props.option, props.empty],
  () => {
    if (props.empty) {
      dispose()
      return
    }
    render()
  },
  { deep: false }
)

onMounted(() => {
  render()
  if (container.value) {
    resizeObserver = new ResizeObserver(() => chart.value?.resize())
    resizeObserver.observe(container.value)
  }
})

onBeforeUnmount(() => {
  resizeObserver?.disconnect()
  dispose()
})
</script>

<template>
  <div class="chart-wrap" :style="{ height }">
    <div v-if="loading" class="chart-state">
      <span class="chart-state__spinner"></span>
      <span>图表加载中…</span>
    </div>
    <div v-else-if="empty" class="chart-state">
      <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.4">
        <path d="M4 20h16M7.5 20v-6M12 20V8M16.5 20v-9" stroke-linecap="round" />
      </svg>
      <span>{{ emptyText }}</span>
    </div>
    <div v-show="!loading && !empty" ref="container" class="chart-canvas"></div>
  </div>
</template>

<style scoped>
.chart-wrap {
  position: relative;
  width: 100%;
}

.chart-canvas {
  width: 100%;
  height: 100%;
}

.chart-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  height: 100%;
  color: var(--ink-400);
  font-size: var(--font-xs);
}

.chart-state__spinner {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  border: 2px solid rgba(124, 143, 90, 0.24);
  border-top-color: var(--sage-600);
  animation: spin 700ms linear infinite;
}
</style>
