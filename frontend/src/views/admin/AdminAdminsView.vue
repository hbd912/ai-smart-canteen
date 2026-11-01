<script setup lang="ts">
/**
 * 管理员与权限：展示管理员账号、角色与权限点（演示版只读）。
 * 真实部署应由后端提供增删改与权限配置接口。
 */
import { computed, onMounted, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { adminApi } from '@/api/modules'
import { useAdminAuthStore } from '@/stores/auth'
import type { AdminInfo } from '@/types/api'
import { formatDateTime } from '@/utils/format'

const adminAuth = useAdminAuthStore()
const loading = ref(true)
const admins = ref<AdminInfo[]>([])
const error = ref<string | null>(null)

const permissionGroups = computed(() => {
  const permissions = adminAuth.permissions
  const groups = [
    { title: '数据看板', items: ['dashboard.read'] },
    { title: '菜品', items: ['dishes.read', 'dishes.create', 'dishes.update', 'dishes.delete'] },
    { title: '分类与库存', items: ['categories.manage', 'inventory.manage'] },
    { title: '订单与用户', items: ['orders.read', 'orders.update', 'users.read', 'users.disable'] },
    { title: '推荐与营养', items: ['banners.manage', 'nutrition.manage'] },
    { title: '系统管理', items: ['admins.manage', 'settings.manage'] }
  ]
  return groups.map((group) => ({
    ...group,
    granted: group.items.map((item) => ({ code: item, granted: permissions.includes(item) }))
  }))
})

async function load() {
  loading.value = true
  error.value = null
  try {
    admins.value = await adminApi.admins()
  } catch (e) {
    error.value = e instanceof Error ? e.message : '管理员列表加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>

<template>
  <div class="admins-page">
    <header class="page-head">
      <div>
        <h2 class="page-head__title">管理员与权限</h2>
        <p class="page-head__desc">
          演示版本仅提供单一超级管理员角色，权限点已在后端集中定义（Permissions 常量）。
          真实部署应由后端提供管理员增删改与细粒度权限配置接口。
        </p>
      </div>
    </header>

    <div v-if="error" class="alert-bar">
      <AppIcon name="alert-triangle" :size="15" />
      <span>{{ error }}</span>
      <button class="btn btn--ghost btn--sm" type="button" @click="load">重试</button>
    </div>

    <section class="admin-card">
      <header class="admin-card__head">
        <h3 class="admin-card__title">管理员账号</h3>
        <span class="tag tag--muted">共 {{ admins.length }} 个</span>
      </header>

      <div v-if="loading" class="skeleton" style="height: 120px; border-radius: 12px"></div>
      <table v-else class="data-table">
        <thead>
          <tr>
            <th>账号</th>
            <th>显示名称</th>
            <th style="width: 150px">角色</th>
            <th style="width: 90px">状态</th>
            <th style="width: 170px">最近登录</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="admin in admins" :key="admin.id">
            <td class="num">{{ admin.username }}</td>
            <td>{{ admin.displayName }}</td>
            <td>
              <span class="tag">{{ admin.roleLabel }}</span>
            </td>
            <td>
              <span class="pill" :class="admin.status === 'ACTIVE' ? 'pill--sage' : 'pill--muted'">
                {{ admin.status === 'ACTIVE' ? '正常' : '停用' }}
              </span>
            </td>
            <td class="text-muted cell-time">{{ admin.lastLoginAt ? formatDateTime(admin.lastLoginAt) : '尚未登录' }}</td>
          </tr>
        </tbody>
      </table>
    </section>

    <section class="admin-card">
      <header class="admin-card__head">
        <div>
          <h3 class="admin-card__title">当前账号权限点</h3>
          <p class="admin-card__sub">
            角色：{{ adminAuth.roleLabel }}（{{ adminAuth.admin?.roleCode }}）
          </p>
        </div>
        <span class="tag">{{ adminAuth.permissions.length }} 项权限</span>
      </header>

      <div class="perm-groups">
        <div v-for="group in permissionGroups" :key="group.title" class="perm-group">
          <h4 class="perm-group__title">{{ group.title }}</h4>
          <ul class="perm-list">
            <li v-for="item in group.granted" :key="item.code" class="perm-item" :class="{ 'perm-item--off': !item.granted }">
              <AppIcon :name="item.granted ? 'check-circle' : 'x-circle'" :size="13" />
              <code>{{ item.code }}</code>
            </li>
          </ul>
        </div>
      </div>
    </section>

    <section class="notice-card">
      <AppIcon name="shield" :size="16" />
      <div>
        <p class="notice-card__title">权限校验说明</p>
        <p class="notice-card__text">
          前端隐藏菜单只用于体验优化，<strong>真正的权限控制在后端</strong>：
          <code>/api/v1/admin/**</code> 全部由 Spring Security 的 <code>hasRole('ADMIN')</code> 保护，
          普通用户 token 无法访问；管理员 token 由独立登录接口签发，与用户会话互不影响。
        </p>
      </div>
    </section>
  </div>
</template>

<style scoped>
.admins-page {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.page-head__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.page-head__desc {
  font-size: 10.5px;
  color: var(--ink-400);
  margin-top: 2px;
  max-width: 780px;
  line-height: 1.6;
}

.alert-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  border-radius: var(--radius-md);
  background: var(--danger-100);
  color: var(--danger-600);
  font-size: var(--font-sm);
}

.admin-card {
  padding: var(--space-5);
  border-radius: var(--radius-lg);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.admin-card__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  margin-bottom: var(--space-3);
}

.admin-card__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.admin-card__sub {
  font-size: 10.5px;
  color: var(--ink-400);
  margin-top: 1px;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: var(--font-xs);
}

.data-table th {
  text-align: left;
  padding: 8px;
  font-size: 10.5px;
  font-weight: 600;
  color: var(--ink-500);
  border-bottom: 1px solid rgba(124, 143, 90, 0.16);
}

.data-table td {
  padding: 10px 8px;
  border-bottom: 1px solid rgba(124, 143, 90, 0.07);
  color: var(--ink-700);
}

.data-table tbody tr:hover {
  background: var(--sage-50);
}

.cell-time {
  font-size: 10.5px;
}

.pill {
  display: inline-flex;
  padding: 2px 8px;
  border-radius: var(--radius-pill);
  font-size: 10px;
  font-weight: 600;
}

.pill--sage {
  background: var(--success-100);
  color: var(--success-600);
}

.pill--muted {
  background: rgba(139, 132, 120, 0.14);
  color: var(--ink-500);
}

.perm-groups {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: var(--space-4);
}

.perm-group__title {
  font-size: var(--font-xs);
  font-weight: 700;
  color: var(--sage-700);
  margin-bottom: 6px;
}

.perm-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.perm-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 10.5px;
  color: var(--success-600);
}

.perm-item--off {
  color: var(--ink-300);
}

.perm-item code {
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 10px;
  color: var(--ink-600);
}

.notice-card {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: var(--space-4);
  border-radius: var(--radius-md);
  background: linear-gradient(135deg, rgba(243, 247, 236, 0.9), rgba(253, 248, 239, 0.85));
  border: 1px solid rgba(124, 143, 90, 0.18);
  color: var(--sage-700);
}

.notice-card__title {
  font-size: var(--font-xs);
  font-weight: 700;
}

.notice-card__text {
  font-size: 10.5px;
  color: var(--ink-600);
  line-height: 1.7;
  margin-top: 3px;
}

.notice-card code {
  font-family: 'Consolas', 'Monaco', monospace;
  padding: 1px 4px;
  border-radius: 4px;
  background: rgba(124, 143, 90, 0.12);
  font-size: 10px;
}
</style>
