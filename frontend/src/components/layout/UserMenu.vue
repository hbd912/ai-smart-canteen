<script setup lang="ts">
/**
 * 用户头像下拉菜单：个人资料 / 修改密码（演示弹窗）/ 退出登录。
 * 退出登录会清空 token 并让场景回到初始登录画面。
 */
import { onBeforeUnmount, onMounted, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'

const props = defineProps<{
  name: string
  initial: string
  account: string
}>()

const emit = defineEmits<{
  (e: 'profile'): void
  (e: 'change-password'): void
  (e: 'logout'): void
}>()

const open = ref(false)
const root = ref<HTMLDivElement | null>(null)

function toggle() {
  open.value = !open.value
}

function close() {
  open.value = false
}

function onDocumentClick(event: MouseEvent) {
  if (!open.value) {
    return
  }
  if (root.value && !root.value.contains(event.target as Node)) {
    close()
  }
}

function onKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape') {
    close()
  }
}

function pick(action: 'profile' | 'change-password' | 'logout') {
  close()
  if (action === 'profile') {
    emit('profile')
  } else if (action === 'change-password') {
    emit('change-password')
  } else {
    emit('logout')
  }
}

onMounted(() => {
  document.addEventListener('click', onDocumentClick)
  document.addEventListener('keydown', onKeydown)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', onDocumentClick)
  document.removeEventListener('keydown', onKeydown)
})
</script>

<template>
  <div ref="root" class="user-menu">
    <button
      class="user-chip"
      type="button"
      :aria-expanded="open"
      aria-haspopup="menu"
      :aria-label="`${props.name}，打开用户菜单`"
      @click.stop="toggle"
    >
      <span class="user-chip__avatar">{{ props.initial }}</span>
      <span class="user-chip__name">{{ props.name }}</span>
      <AppIcon name="chevron-down" :size="13" class="user-chip__caret" :class="{ 'user-chip__caret--open': open }" />
    </button>

    <Transition name="toast">
      <div v-if="open" class="user-dropdown" role="menu">
        <div class="user-dropdown__head">
          <span class="user-dropdown__avatar">{{ props.initial }}</span>
          <div class="user-dropdown__info">
            <span class="user-dropdown__name">{{ props.name }}</span>
            <span class="user-dropdown__account">{{ props.account }}</span>
          </div>
        </div>
        <div class="user-dropdown__divider"></div>
        <button class="user-dropdown__item" type="button" role="menuitem" @click="pick('profile')">
          <AppIcon name="user" :size="15" />
          个人资料
        </button>
        <button class="user-dropdown__item" type="button" role="menuitem" @click="pick('change-password')">
          <AppIcon name="lock" :size="15" />
          修改密码
        </button>
        <div class="user-dropdown__divider"></div>
        <button class="user-dropdown__item user-dropdown__item--danger" type="button" role="menuitem" @click="pick('logout')">
          <AppIcon name="logout" :size="15" />
          退出登录
        </button>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.user-menu {
  position: relative;
}

.user-chip {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 40px;
  padding: 0 12px 0 4px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.78);
  border: 1px solid rgba(124, 143, 90, 0.14);
  transition: background-color var(--motion-fast) var(--ease-standard),
    transform var(--motion-fast) var(--ease-standard);
}

.user-chip:hover {
  background: #fff;
  transform: translateY(-1px);
}

.user-chip__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--apricot-100), var(--sage-200));
  color: var(--sage-800);
  font-size: var(--font-sm);
  font-weight: 700;
}

.user-chip__name {
  font-size: var(--font-sm);
  font-weight: 600;
  color: var(--ink-700);
  max-width: 96px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.user-chip__caret {
  color: var(--ink-400);
  transition: transform var(--motion-normal) var(--ease-standard);
}

.user-chip__caret--open {
  transform: rotate(180deg);
}

.user-dropdown {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  z-index: 400;
  width: 214px;
  padding: 6px;
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.98);
  backdrop-filter: blur(18px) saturate(1.15);
  border: 1px solid rgba(255, 255, 255, 0.9);
  box-shadow: var(--shadow-lg);
}

.user-dropdown__head {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 8px 9px;
}

.user-dropdown__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  flex: none;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--apricot-100), var(--sage-200));
  color: var(--sage-800);
  font-size: var(--font-sm);
  font-weight: 700;
}

.user-dropdown__info {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.user-dropdown__name {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-800);
}

.user-dropdown__account {
  font-size: 10.5px;
  color: var(--ink-400);
}

.user-dropdown__divider {
  height: 1px;
  margin: 4px 6px;
  background: rgba(124, 143, 90, 0.14);
}

.user-dropdown__item {
  display: flex;
  align-items: center;
  gap: 9px;
  width: 100%;
  padding: 9px 10px;
  border-radius: var(--radius-xs);
  font-size: var(--font-sm);
  color: var(--ink-700);
  text-align: left;
  transition: background-color var(--motion-fast) var(--ease-standard),
    color var(--motion-fast) var(--ease-standard);
}

.user-dropdown__item:hover {
  background: var(--sage-50);
  color: var(--sage-800);
}

.user-dropdown__item--danger {
  color: var(--danger-600);
}

.user-dropdown__item--danger:hover {
  background: var(--danger-100);
  color: var(--danger-600);
}

@media (max-width: 1023px) {
  .user-chip__name,
  .user-chip__caret {
    display: none;
  }

  .user-chip {
    padding: 0 4px;
  }
}
</style>
