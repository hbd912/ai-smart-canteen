<script setup lang="ts">
/**
 * 顶部品牌栏：Logo、提示语、搜索、天气/日期（演示数据）、通知、头像下拉。
 * 通知与头像均为真实交互组件（通知为 Mock 数据，头像菜单含退出登录）。
 */
import { computed, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import UserMenu from '@/components/layout/UserMenu.vue'
import { useAuthStore } from '@/stores/auth'
import { greeting, todayLabel } from '@/utils/format'

const props = withDefaults(
  defineProps<{
    searchable?: boolean
    compact?: boolean
    modelValue?: string
    unreadCount?: number
  }>(),
  { searchable: true, compact: false, modelValue: '', unreadCount: 0 }
)

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
  (e: 'search', value: string): void
  (e: 'open-notifications'): void
  (e: 'profile'): void
  (e: 'change-password'): void
  (e: 'logout'): void
}>()

const auth = useAuthStore()
const localSearch = ref(props.modelValue)

const weather = { temp: 24, text: '晴', note: '演示数据' }

const dateText = computed(() => todayLabel())
const greetingText = computed(() => `${greeting()}，${auth.displayName}`)

function onInput(event: Event) {
  const value = (event.target as HTMLInputElement).value
  localSearch.value = value
  emit('update:modelValue', value)
}

function submit() {
  emit('search', localSearch.value.trim())
}
</script>

<template>
  <header class="topbar" :class="{ 'topbar--compact': compact }">
    <div class="topbar__left">
      <RouterLink to="/" class="brand" aria-label="返回智慧食堂首页">
        <span class="brand__logo">
          <AppIcon name="leaf" :size="20" />
        </span>
        <span class="brand__text">
          <span class="brand__name">智慧食堂</span>
          <span class="brand__tagline">今天想吃点什么？</span>
        </span>
      </RouterLink>
    </div>

    <div v-if="searchable" class="topbar__search">
      <label class="search" for="global-search">
        <AppIcon name="search" :size="18" class="search__icon" />
        <input
          id="global-search"
          class="search__input"
          type="search"
          :value="localSearch"
          placeholder="搜索菜品、口味或营养需求…"
          @input="onInput"
          @keyup.enter="submit"
        />
        <button
          v-if="localSearch"
          class="search__clear"
          type="button"
          aria-label="清除搜索"
          @click="localSearch = ''; emit('update:modelValue', ''); emit('search', '')"
        >
          <AppIcon name="close" :size="14" />
        </button>
      </label>
    </div>

    <div class="topbar__right">
      <div class="weather" :title="`天气为课堂演示数据（${weather.note}）`">
        <AppIcon name="sun" :size="17" class="weather__icon" />
        <span class="weather__temp num">{{ weather.temp }}°C</span>
        <span class="weather__divider"></span>
        <span class="weather__date">{{ dateText }}</span>
        <span class="weather__badge">演示</span>
      </div>

      <button class="icon-btn" type="button" :aria-label="`通知${props.unreadCount > 0 ? `（${props.unreadCount} 条未读）` : ''}`" @click="emit('open-notifications')">
        <AppIcon name="bell" :size="19" />
        <span v-if="props.unreadCount > 0" class="icon-btn__dot"></span>
      </button>

      <UserMenu
        :name="auth.displayName"
        :initial="auth.initial"
        :account="auth.user?.username || ''"
        @profile="emit('profile')"
        @change-password="emit('change-password')"
        @logout="emit('logout')"
      />
    </div>
  </header>
</template>

<style scoped>
.topbar {
  position: relative;
  z-index: 30;
  display: flex;
  align-items: center;
  gap: var(--space-5);
  height: var(--topbar-height);
  padding: 0 var(--space-7);
  margin: 0 var(--space-6);
  margin-top: var(--space-4);
  border-radius: var(--radius-pill);
  background: rgba(255, 253, 248, 0.78);
  backdrop-filter: blur(18px) saturate(1.2);
  -webkit-backdrop-filter: blur(18px) saturate(1.2);
  border: 1px solid rgba(255, 255, 255, 0.85);
  box-shadow: var(--shadow-md);
  transition: background-color var(--motion-normal) var(--ease-standard),
    box-shadow var(--motion-normal) var(--ease-standard),
    height var(--motion-normal) var(--ease-standard);
}

.topbar--compact {
  height: 64px;
  background: rgba(255, 253, 248, 0.92);
  box-shadow: var(--shadow-sm);
}

.topbar__left {
  flex: none;
}

.brand {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: 6px 10px 6px 4px;
  border-radius: var(--radius-pill);
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.brand:hover {
  background: rgba(232, 238, 221, 0.5);
}

.brand__logo {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--sage-400), var(--sage-600));
  color: #fff;
  box-shadow: 0 4px 12px rgba(95, 120, 80, 0.28);
}

.brand__text {
  display: flex;
  flex-direction: column;
  line-height: 1.2;
}

.brand__name {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--sage-800);
  letter-spacing: 0.02em;
}

.brand__tagline {
  font-size: var(--font-xs);
  color: var(--ink-500);
}

.topbar__search {
  flex: 1;
  display: flex;
  justify-content: center;
  min-width: 0;
}

.search {
  position: relative;
  display: flex;
  align-items: center;
  width: min(460px, 100%);
  height: 42px;
  padding: 0 var(--space-4);
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.86);
  border: 1px solid rgba(124, 143, 90, 0.18);
  transition: border-color var(--motion-fast) var(--ease-standard),
    box-shadow var(--motion-fast) var(--ease-standard);
}

.search:focus-within {
  border-color: var(--sage-400);
  box-shadow: var(--shadow-glow);
}

.search__icon {
  color: var(--sage-500);
  flex: none;
}

.search__input {
  flex: 1;
  min-width: 0;
  height: 100%;
  padding: 0 var(--space-2);
  border: none;
  background: transparent;
  outline: none;
  font-size: var(--font-base);
  color: var(--ink-800);
}

.search__input::placeholder {
  color: var(--ink-400);
}

.search__clear {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  color: var(--ink-400);
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.search__clear:hover {
  background: var(--sage-100);
  color: var(--sage-700);
}

.topbar__right {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  flex: none;
  /* 搜索框隐藏时（如首页），用 margin-left:auto 把右侧控件推到最右，
     否则会紧跟品牌名贴到左边 */
  margin-left: auto;
}

.weather {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 38px;
  padding: 0 var(--space-4);
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.7);
  border: 1px solid rgba(124, 143, 90, 0.14);
  font-size: var(--font-sm);
  color: var(--ink-600);
}

.weather__icon {
  color: var(--amber-500);
}

.weather__temp {
  font-weight: 700;
  color: var(--ink-800);
}

.weather__divider {
  width: 1px;
  height: 14px;
  background: rgba(124, 143, 90, 0.24);
}

.weather__badge {
  font-size: 10px;
  padding: 1px 6px;
  border-radius: var(--radius-pill);
  background: var(--amber-100);
  color: var(--amber-600);
}

.icon-btn {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  color: var(--sage-700);
  background: rgba(255, 255, 255, 0.7);
  border: 1px solid rgba(124, 143, 90, 0.14);
  transition: background-color var(--motion-fast) var(--ease-standard),
    transform var(--motion-fast) var(--ease-standard);
}

.icon-btn:hover {
  background: #fff;
  transform: translateY(-1px);
}

.icon-btn__dot {
  position: absolute;
  top: 9px;
  right: 10px;
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--danger-500);
  box-shadow: 0 0 0 2px rgba(255, 253, 248, 0.95);
  animation: pop-badge 420ms var(--ease-enter);
}

@media (max-width: 1279px) {
  .weather__date,
  .weather__divider {
    display: none;
  }
}

@media (max-width: 1023px) {
  .topbar {
    margin: 0 12px;
    margin-top: 10px;
    padding: 0 14px;
    gap: 10px;
    height: 64px;
  }

  .brand__tagline,
  .weather {
    display: none;
  }
}

@media (max-width: 767px) {
  .topbar__search {
    display: none;
  }

  .brand__name {
    font-size: var(--font-base);
  }
}
</style>
