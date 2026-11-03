<script setup lang="ts">
/**
 * 左侧五项垂直导航。顺序固定：首页、点餐、订单、收藏、营养管理。
 * 点击行为由父组件统一按状态机处理（本组件只发出 intent）。
 */
import { computed } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import type { ActivePanel } from '@/state/sceneMachine'

const props = defineProps<{
  active: ActivePanel
  /** 用餐状态下点餐入口需要提示而不是切换 */
  eating: boolean
  cartCount: number
}>()

const emit = defineEmits<{
  (e: 'select', panel: ActivePanel): void
}>()

interface NavItem {
  key: ActivePanel
  label: string
  icon: string
}

const items: NavItem[] = [
  { key: 'home', label: '首页', icon: 'home' },
  { key: 'menu', label: '点餐', icon: 'utensils' },
  { key: 'order', label: '订单', icon: 'calendar' },
  { key: 'favorites', label: '精选', icon: 'star' },
  { key: 'nutrition', label: '营养管理', icon: 'bar-chart' }
]

const activeIndex = computed(() => items.findIndex((item) => item.key === props.active))

function onClick(item: NavItem) {
  emit('select', item.key)
}
</script>

<template>
  <nav class="sidenav" aria-label="主导航">
    <ul class="sidenav__list">
      <li v-for="(item, index) in items" :key="item.key" class="sidenav__item">
        <button
          class="sidenav__btn"
          :class="{ 'sidenav__btn--active': active === item.key }"
          type="button"
          :aria-current="active === item.key ? 'page' : undefined"
          :aria-label="item.label"
          @click="onClick(item)"
        >
          <span class="sidenav__icon">
            <AppIcon :name="item.icon" :size="21" />
            <span v-if="item.key === 'menu' && cartCount > 0" class="sidenav__badge num">
              {{ cartCount > 99 ? '99+' : cartCount }}
            </span>
          </span>
          <span class="sidenav__label">{{ item.label }}</span>
          <span class="sidenav__tooltip" role="tooltip">{{ item.label }}</span>
        </button>
        <span
          v-if="index === activeIndex && activeIndex >= 0"
          class="sidenav__marker"
          aria-hidden="true"
        ></span>
      </li>
    </ul>
  </nav>
</template>

<style scoped>
.sidenav {
  position: relative;
  z-index: 25;
  flex: none;
}

.sidenav__list {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 12px 8px;
  border-radius: var(--radius-pill);
  background: rgba(255, 253, 248, 0.82);
  backdrop-filter: blur(12px) saturate(1.2);
  -webkit-backdrop-filter: blur(12px) saturate(1.2);
  border: 1px solid rgba(255, 255, 255, 0.85);
  box-shadow: var(--shadow-md);
}

.sidenav__item {
  position: relative;
}

.sidenav__btn {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 3px;
  width: 64px;
  height: 62px;
  border-radius: var(--radius-lg);
  color: var(--sage-700);
  transition: background-color var(--motion-normal) var(--ease-standard),
    color var(--motion-normal) var(--ease-standard),
    transform var(--motion-fast) var(--ease-standard);
}

.sidenav__btn:hover {
  background: rgba(232, 238, 221, 0.72);
  transform: translateY(-1px);
}

.sidenav__btn:active {
  transform: scale(0.94);
}

.sidenav__btn--active {
  background: linear-gradient(150deg, var(--sage-500), var(--sage-700));
  color: #fff;
  box-shadow: 0 8px 20px rgba(77, 99, 64, 0.32);
}

.sidenav__btn--active:hover {
  background: linear-gradient(150deg, var(--sage-500), var(--sage-700));
}

.sidenav__icon {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--motion-normal) var(--ease-enter);
}

.sidenav__btn--active .sidenav__icon {
  transform: scale(1.06);
}

.sidenav__label {
  font-size: 10.5px;
  font-weight: 600;
  letter-spacing: 0.02em;
  line-height: 1;
}

.sidenav__badge {
  position: absolute;
  top: -7px;
  right: -10px;
  min-width: 16px;
  height: 16px;
  padding: 0 4px;
  border-radius: var(--radius-pill);
  background: var(--amber-500);
  color: #fff;
  font-size: 10px;
  font-weight: 700;
  line-height: 16px;
  text-align: center;
  box-shadow: 0 0 0 2px rgba(255, 253, 248, 0.9);
  animation: pop-badge 380ms var(--ease-enter);
}

.sidenav__marker {
  position: absolute;
  right: -8px;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 18px;
  border-radius: var(--radius-pill);
  background: var(--sage-500);
}

.sidenav__tooltip {
  position: absolute;
  left: calc(100% + 12px);
  top: 50%;
  transform: translateY(-50%) translateX(-4px);
  padding: 6px 12px;
  border-radius: var(--radius-pill);
  background: rgba(44, 42, 38, 0.88);
  color: #fff;
  font-size: var(--font-xs);
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transition: opacity var(--motion-normal) var(--ease-standard) 380ms,
    transform var(--motion-normal) var(--ease-standard) 380ms;
}

.sidenav__btn:hover .sidenav__tooltip,
.sidenav__btn:focus-visible .sidenav__tooltip {
  opacity: 1;
  transform: translateY(-50%) translateX(0);
}

@media (max-width: 1023px) {
  .sidenav {
    position: absolute;
    left: 50%;
    bottom: 14px;
    transform: translateX(-50%);
    width: auto;
  }

  .sidenav__list {
    flex-direction: row;
    padding: 8px;
    gap: 4px;
  }

  .sidenav__btn {
    width: 58px;
    height: 52px;
  }

  .sidenav__marker,
  .sidenav__tooltip {
    display: none;
  }
}

@media (max-width: 767px) {
  .sidenav__btn {
    width: 52px;
    height: 48px;
  }

  .sidenav__label {
    font-size: 9.5px;
  }
}
</style>
