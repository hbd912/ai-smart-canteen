<script setup lang="ts">
import { useToastStore } from '@/stores/toast'
import AppIcon from './AppIcon.vue'

const toast = useToastStore()

const iconMap = {
  success: 'check-circle',
  error: 'x-circle',
  warning: 'alert-triangle',
  info: 'info'
} as const
</script>

<template>
  <div class="toast-host" aria-live="polite" aria-atomic="true">
    <TransitionGroup name="toast">
      <div
        v-for="item in toast.items"
        :key="item.id"
        class="toast"
        :class="`toast--${item.type}`"
        role="status"
        @click="toast.remove(item.id)"
      >
        <span class="toast__icon">
          <AppIcon :name="iconMap[item.type]" :size="18" />
        </span>
        <div class="toast__body">
          <p class="toast__message">{{ item.message }}</p>
          <p v-if="item.detail" class="toast__detail">{{ item.detail }}</p>
        </div>
      </div>
    </TransitionGroup>
  </div>
</template>

<style scoped>
.toast-host {
  position: fixed;
  top: 20px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 10px;
  align-items: center;
  pointer-events: none;
}

.toast {
  pointer-events: auto;
  display: flex;
  align-items: flex-start;
  gap: 10px;
  min-width: 240px;
  max-width: min(460px, 88vw);
  padding: 12px 18px;
  border-radius: var(--radius-pill);
  background: rgba(255, 253, 248, 0.96);
  backdrop-filter: blur(16px) saturate(1.2);
  -webkit-backdrop-filter: blur(16px) saturate(1.2);
  border: 1px solid rgba(255, 255, 255, 0.9);
  box-shadow: var(--shadow-lg);
  cursor: pointer;
}

.toast__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 26px;
  border-radius: 50%;
  flex: none;
  margin-top: 1px;
}

.toast--success .toast__icon {
  background: var(--success-100);
  color: var(--success-600);
}

.toast--error .toast__icon {
  background: var(--danger-100);
  color: var(--danger-600);
}

.toast--warning .toast__icon {
  background: var(--amber-100);
  color: var(--amber-600);
}

.toast--info .toast__icon {
  background: var(--sage-100);
  color: var(--sage-600);
}

.toast__body {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.toast__message {
  font-size: var(--font-base);
  font-weight: 600;
  color: var(--ink-800);
  line-height: 1.5;
}

.toast__detail {
  font-size: var(--font-xs);
  color: var(--ink-500);
  line-height: 1.5;
}
</style>
