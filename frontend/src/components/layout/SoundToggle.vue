<script setup lang="ts">
/**
 * 声音开关：右上角常驻，状态持久化到 localStorage。
 */
import AppIcon from '@/components/common/AppIcon.vue'
import { useAudioUnlock } from '@/composables/useAudioUnlock'

const { soundEnabled, unlocked, toggle } = useAudioUnlock()

function onClick() {
  toggle()
}
</script>

<template>
  <button
    class="sound-toggle"
    type="button"
    :class="{ 'sound-toggle--on': soundEnabled }"
    :aria-label="soundEnabled ? '关闭声音' : '开启声音'"
    :aria-pressed="soundEnabled"
    :title="soundEnabled ? '声音已开启，点击静音' : '声音已静音，点击开启'"
    @click.stop="onClick"
  >
    <AppIcon :name="soundEnabled ? 'volume' : 'volume-off'" :size="18" />
    <span v-if="soundEnabled && !unlocked" class="sound-toggle__hint">点击任意处开启声音</span>
  </button>
</template>

<style scoped>
.sound-toggle {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  height: 40px;
  min-width: 40px;
  padding: 0 10px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.7);
  border: 1px solid rgba(124, 143, 90, 0.14);
  color: var(--ink-500);
  transition: background-color var(--motion-fast) var(--ease-standard),
    color var(--motion-fast) var(--ease-standard),
    transform var(--motion-fast) var(--ease-standard);
}

.sound-toggle:hover {
  background: #fff;
  transform: translateY(-1px);
}

.sound-toggle--on {
  color: var(--sage-700);
}

.sound-toggle__hint {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  white-space: nowrap;
  padding: 5px 10px;
  border-radius: var(--radius-pill);
  background: rgba(44, 42, 38, 0.86);
  color: #fff;
  font-size: 10.5px;
  pointer-events: none;
  animation: fade-in var(--motion-slow) var(--ease-standard) both;
}

@media (max-width: 1023px) {
  .sound-toggle__hint {
    display: none;
  }
}
</style>
