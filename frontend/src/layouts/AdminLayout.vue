<script setup lang="ts">
/**
 * 管理后台布局：左侧深色侧边栏 + 顶部白色工具栏 + 内容区。
 * 侧边栏可折叠，路由切换有轻量过渡。
 */
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppIcon from '@/components/common/AppIcon.vue'
import { useAdminAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'

const route = useRoute()
const router = useRouter()
const adminAuth = useAdminAuthStore()
const toast = useToastStore()

const collapsed = ref(false)

interface NavItem {
  path: string
  label: string
  icon: string
  permission?: string
}

const navItems: NavItem[] = [
  { path: '/admin/dashboard', label: '工作台', icon: 'dashboard', permission: 'dashboard.read' },
  { path: '/admin/dishes', label: '菜品管理', icon: 'dish', permission: 'dishes.read' },
  { path: '/admin/categories', label: '菜品分类', icon: 'tag', permission: 'categories.manage' },
  { path: '/admin/inventory', label: '库存管理', icon: 'box', permission: 'inventory.manage' },
  { path: '/admin/orders', label: '订单管理', icon: 'clipboard-list', permission: 'orders.read' },
  { path: '/admin/users', label: '用户管理', icon: 'users', permission: 'users.read' },
  { path: '/admin/recommendations', label: '首页推荐', icon: 'sparkles', permission: 'banners.manage' },
  { path: '/admin/nutrition', label: '营养信息', icon: 'flame', permission: 'nutrition.manage' },
  { path: '/admin/statistics', label: '数据统计', icon: 'bar-chart', permission: 'dashboard.read' },
  { path: '/admin/admins', label: '管理员与权限', icon: 'shield', permission: 'admins.manage' },
  { path: '/admin/ai-config', label: 'AI 服务配置', icon: 'robot', permission: 'settings.manage' }
]

const visibleNav = computed(() => navItems.filter((item) => !item.permission || adminAuth.has(item.permission)))

const currentTitle = computed(() => (route.meta.title as string) || '管理后台')

function go(path: string) {
  router.push(path)
}

function logout() {
  adminAuth.logout()
  toast.info('已退出后台', '管理会话已清除')
  router.replace('/admin/login')
}

function toCustomer() {
  router.push('/')
}
</script>

<template>
  <div class="admin-layout" :class="{ 'admin-layout--collapsed': collapsed }">
    <aside class="admin-side">
      <div class="admin-side__brand">
        <span class="admin-side__logo"><AppIcon name="leaf" :size="18" /></span>
        <span v-if="!collapsed" class="admin-side__brand-text">
          <span class="admin-side__name">智慧食堂</span>
          <span class="admin-side__tag">运营管理后台</span>
        </span>
      </div>

      <nav class="admin-side__nav" aria-label="后台导航">
        <button
          v-for="item in visibleNav"
          :key="item.path"
          class="admin-nav-item"
          :class="{ 'admin-nav-item--active': route.path === item.path }"
          type="button"
          :aria-current="route.path === item.path ? 'page' : undefined"
          :title="collapsed ? item.label : undefined"
          @click="go(item.path)"
        >
          <AppIcon :name="item.icon" :size="17" />
          <span v-if="!collapsed" class="admin-nav-item__label">{{ item.label }}</span>
        </button>
      </nav>

      <div class="admin-side__foot">
        <button class="admin-side__toggle" type="button" :aria-label="collapsed ? '展开侧栏' : '收起侧栏'" @click="collapsed = !collapsed">
          <AppIcon :name="collapsed ? 'chevron-right' : 'chevron-left'" :size="15" />
          <span v-if="!collapsed">收起侧栏</span>
        </button>
      </div>
    </aside>

    <div class="admin-main">
      <header class="admin-top">
        <div class="admin-top__left">
          <h1 class="admin-top__title">{{ currentTitle }}</h1>
          <span class="admin-top__crumb">管理后台 / {{ currentTitle }}</span>
        </div>
        <div class="admin-top__right">
          <button class="admin-top__action" type="button" @click="toCustomer">
            <AppIcon name="log-in" :size="15" />
            用户端
          </button>
          <div class="admin-top__user">
            <span class="admin-top__avatar">{{ adminAuth.displayName.slice(0, 1) }}</span>
            <div class="admin-top__user-info">
              <span class="admin-top__user-name">{{ adminAuth.displayName }}</span>
              <span class="admin-top__user-role">{{ adminAuth.roleLabel }}</span>
            </div>
          </div>
          <button class="admin-top__logout" type="button" aria-label="退出登录" @click="logout">
            <AppIcon name="logout" :size="16" />
          </button>
        </div>
      </header>

      <main class="admin-content">
        <RouterView v-slot="{ Component }">
          <Transition name="fade" mode="out-in">
            <component :is="Component" />
          </Transition>
        </RouterView>
      </main>
    </div>
  </div>
</template>

<style scoped>
.admin-layout {
  display: flex;
  height: 100vh;
  overflow: hidden;
  background: #f5f2ea;
}

.admin-side {
  display: flex;
  flex-direction: column;
  width: 216px;
  flex: none;
  background: linear-gradient(180deg, var(--sage-800), var(--sage-900));
  color: rgba(255, 255, 255, 0.86);
  transition: width var(--motion-normal) var(--ease-standard);
}

.admin-layout--collapsed .admin-side {
  width: 68px;
}

.admin-side__brand {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 18px 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.admin-side__logo {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  flex: none;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.14);
  color: #fff;
}

.admin-side__brand-text {
  display: flex;
  flex-direction: column;
  line-height: 1.25;
  overflow: hidden;
}

.admin-side__name {
  font-size: var(--font-base);
  font-weight: 700;
  color: #fff;
  letter-spacing: 0.02em;
  white-space: nowrap;
}

.admin-side__tag {
  font-size: 10px;
  color: rgba(255, 255, 255, 0.55);
  white-space: nowrap;
}

.admin-side__nav {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 3px;
  padding: 12px 10px;
  overflow-y: auto;
}

.admin-nav-item {
  display: flex;
  align-items: center;
  gap: 10px;
  height: 40px;
  padding: 0 12px;
  border-radius: var(--radius-sm);
  color: rgba(255, 255, 255, 0.76);
  font-size: var(--font-sm);
  font-weight: 500;
  text-align: left;
  transition: background-color var(--motion-fast) var(--ease-standard),
    color var(--motion-fast) var(--ease-standard);
}

.admin-nav-item:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.admin-nav-item--active {
  background: rgba(255, 255, 255, 0.18);
  color: #fff;
  font-weight: 600;
}

.admin-nav-item__label {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.admin-layout--collapsed .admin-nav-item {
  justify-content: center;
  padding: 0;
}

.admin-side__foot {
  padding: 10px;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
}

.admin-side__toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  width: 100%;
  height: 32px;
  border-radius: var(--radius-sm);
  color: rgba(255, 255, 255, 0.6);
  font-size: var(--font-xs);
}

.admin-side__toggle:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.admin-main {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.admin-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
  height: 66px;
  flex: none;
  padding: 0 var(--space-6);
  background: rgba(255, 253, 248, 0.94);
  border-bottom: 1px solid rgba(124, 143, 90, 0.12);
}

.admin-top__left {
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.admin-top__title {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--ink-900);
}

.admin-top__crumb {
  font-size: 10.5px;
  color: var(--ink-400);
}

.admin-top__right {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.admin-top__action {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  height: 32px;
  padding: 0 12px;
  border-radius: var(--radius-pill);
  background: var(--sage-50);
  color: var(--sage-700);
  font-size: var(--font-xs);
  font-weight: 600;
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.admin-top__action:hover {
  background: var(--sage-100);
}

.admin-top__user {
  display: flex;
  align-items: center;
  gap: 8px;
}

.admin-top__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--sage-400), var(--sage-600));
  color: #fff;
  font-size: var(--font-sm);
  font-weight: 700;
}

.admin-top__user-info {
  display: flex;
  flex-direction: column;
  line-height: 1.25;
}

.admin-top__user-name {
  font-size: var(--font-sm);
  font-weight: 600;
  color: var(--ink-800);
}

.admin-top__user-role {
  font-size: 10px;
  color: var(--ink-400);
}

.admin-top__logout {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  color: var(--ink-500);
  transition: background-color var(--motion-fast) var(--ease-standard),
    color var(--motion-fast) var(--ease-standard);
}

.admin-top__logout:hover {
  background: var(--danger-100);
  color: var(--danger-600);
}

.admin-content {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  padding: var(--space-5) var(--space-6) var(--space-7);
}

@media (max-width: 1023px) {
  .admin-side {
    width: 68px;
  }

  .admin-side__brand-text,
  .admin-nav-item__label,
  .admin-side__toggle span {
    display: none;
  }

  .admin-nav-item {
    justify-content: center;
    padding: 0;
  }

  .admin-top {
    padding: 0 var(--space-4);
  }

  .admin-top__user-info {
    display: none;
  }

  .admin-content {
    padding: var(--space-4);
  }
}
</style>
