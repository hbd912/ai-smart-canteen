<script setup lang="ts">
/**
 * 用户管理：列表、搜索、启用/禁用。不展示密码，敏感信息最小化。
 */
import { computed, onMounted, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { adminApi } from '@/api/modules'
import type { PageResult, UserInfo } from '@/types/api'
import { formatDateTime } from '@/utils/format'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()

const loading = ref(false)
const users = ref<UserInfo[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = 10
const keyword = ref('')
const statusFilter = ref('')

const totalPages = computed(() => Math.max(Math.ceil(total.value / pageSize), 1))
const confirmUserId = ref<number | null>(null)
const pendingStatus = ref('')

async function load() {
  loading.value = true
  try {
    const result: PageResult<UserInfo> = await adminApi.users({
      page: page.value,
      pageSize,
      keyword: keyword.value || undefined,
      status: statusFilter.value || undefined
    })
    users.value = result.records
    total.value = result.total
  } catch (e) {
    toast.error('用户加载失败', e instanceof Error ? e.message : '请稍后重试')
  } finally {
    loading.value = false
  }
}

function search() {
  page.value = 1
  load()
}

function changePage(next: number) {
  if (next < 1 || next > totalPages.value) {
    return
  }
  page.value = next
  load()
}

function askToggle(user: UserInfo) {
  confirmUserId.value = user.id
  pendingStatus.value = user.status === 'ACTIVE' ? 'DISABLED' : 'ACTIVE'
}

async function doToggle() {
  if (!confirmUserId.value) {
    return
  }
  try {
    await adminApi.changeUserStatus(confirmUserId.value, pendingStatus.value)
    toast.success(pendingStatus.value === 'ACTIVE' ? '用户已启用' : '用户已禁用', '禁用后该账号将无法登录')
    confirmUserId.value = null
    await load()
  } catch (e) {
    toast.error('操作失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

onMounted(load)
</script>

<template>
  <div class="users-page">
    <header class="page-head">
      <div>
        <h2 class="page-head__title">用户管理</h2>
        <p class="page-head__desc">
          仅展示业务所需信息，后台无法查看任何用户密码（数据库仅保存 BCrypt 哈希）。
        </p>
      </div>
    </header>

    <section class="filter-bar">
      <div class="filter-bar__search">
        <AppIcon name="search" :size="15" class="filter-bar__icon" />
        <input v-model="keyword" class="filter-bar__input" type="search" placeholder="账号 / 昵称 / 手机号" @keyup.enter="search" />
      </div>
      <select v-model="statusFilter" class="select" @change="search">
        <option value="">全部状态</option>
        <option value="ACTIVE">正常</option>
        <option value="DISABLED">已禁用</option>
      </select>
      <button class="btn btn--ghost btn--sm" type="button" @click="search">查询</button>
    </section>

    <section class="table-card">
      <div v-if="loading" class="skeleton" style="height: 240px; border-radius: 12px"></div>
      <div v-else-if="users.length === 0" class="empty-mini">没有符合条件的用户</div>
      <table v-else class="data-table">
        <thead>
          <tr>
            <th style="width: 60px">ID</th>
            <th>昵称</th>
            <th style="width: 160px">账号</th>
            <th style="width: 160px">联系方式</th>
            <th style="width: 80px">订单数</th>
            <th style="width: 150px">注册时间</th>
            <th style="width: 90px">状态</th>
            <th style="width: 90px">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in users" :key="user.id">
            <td class="num text-muted">{{ user.id }}</td>
            <td>
              <div class="user-cell">
                <span class="user-cell__avatar">{{ (user.nickname || user.username).slice(0, 1) }}</span>
                <span>{{ user.nickname }}</span>
              </div>
            </td>
            <td class="num">{{ user.username }}</td>
            <td class="text-muted">{{ user.phone || user.email || '—' }}</td>
            <td class="num">{{ user.orderCount ?? 0 }}</td>
            <td class="cell-time text-muted">{{ formatDateTime(user.createdAt) }}</td>
            <td>
              <span class="pill" :class="user.status === 'ACTIVE' ? 'pill--sage' : 'pill--danger'">
                {{ user.status === 'ACTIVE' ? '正常' : '已禁用' }}
              </span>
            </td>
            <td>
              <button class="act" :class="{ 'act--danger': user.status === 'ACTIVE' }" type="button" @click="askToggle(user)">
                {{ user.status === 'ACTIVE' ? '禁用' : '启用' }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
      <footer v-if="users.length > 0" class="pager">
        <span class="pager__info">共 {{ total }} 位用户 · 第 {{ page }} / {{ totalPages }} 页</span>
        <div class="pager__buttons">
          <button class="btn btn--ghost btn--sm" type="button" :disabled="page <= 1" @click="changePage(page - 1)">上一页</button>
          <button class="btn btn--ghost btn--sm" type="button" :disabled="page >= totalPages" @click="changePage(page + 1)">下一页</button>
        </div>
      </footer>
    </section>

    <Transition name="modal">
      <div v-if="confirmUserId" class="modal" @click.self="confirmUserId = null">
        <div class="modal-box">
          <div class="confirm">
            <span class="confirm__icon"><AppIcon name="user-cog" :size="20" /></span>
            <h3 class="confirm__title">{{ pendingStatus === 'ACTIVE' ? '确认启用该用户？' : '确认禁用该用户？' }}</h3>
            <p class="confirm__desc">
              {{ pendingStatus === 'ACTIVE' ? '启用后用户可以重新登录点餐。' : '禁用后该账号将无法登录，历史订单仍保留。' }}
            </p>
            <div class="confirm__actions">
              <button class="btn btn--ghost" type="button" @click="confirmUserId = null">取消</button>
              <button class="btn btn--primary" type="button" @click="doToggle">确认</button>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.users-page {
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
}

.filter-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.filter-bar__search {
  position: relative;
  display: flex;
  align-items: center;
  width: 240px;
}

.filter-bar__icon {
  position: absolute;
  left: 11px;
  color: var(--sage-500);
}

.filter-bar__input {
  width: 100%;
  height: 34px;
  padding: 0 12px 0 34px;
  border-radius: var(--radius-pill);
  border: 1px solid rgba(124, 143, 90, 0.2);
  background: #fff;
  outline: none;
  font-size: var(--font-xs);
}

.select {
  height: 34px;
  padding: 0 10px;
  border-radius: var(--radius-sm);
  border: 1px solid rgba(124, 143, 90, 0.2);
  background: #fff;
  color: var(--ink-700);
  font-size: var(--font-xs);
  outline: none;
}

.table-card {
  padding: var(--space-4);
  border-radius: var(--radius-md);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: var(--font-xs);
}

.data-table th {
  text-align: left;
  padding: 9px 8px;
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

.user-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.user-cell__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--apricot-100), var(--sage-200));
  color: var(--sage-800);
  font-size: 11px;
  font-weight: 700;
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

.pill--danger {
  background: var(--danger-100);
  color: var(--danger-600);
}

.act {
  padding: 3px 9px;
  border-radius: var(--radius-xs);
  background: var(--sage-50);
  color: var(--sage-700);
  font-size: 10.5px;
  font-weight: 600;
}

.act--danger {
  background: var(--danger-100);
  color: var(--danger-600);
}

.pager {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: var(--space-3);
  margin-top: var(--space-2);
  border-top: 1px solid rgba(124, 143, 90, 0.12);
}

.pager__info {
  font-size: 10.5px;
  color: var(--ink-500);
}

.pager__buttons {
  display: flex;
  gap: 8px;
}

.empty-mini {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-8);
  color: var(--ink-400);
  font-size: var(--font-xs);
}

.modal {
  position: fixed;
  inset: 0;
  z-index: 400;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-5);
  background: rgba(48, 44, 36, 0.4);
  backdrop-filter: blur(4px);
}

.modal-box {
  width: min(400px, 100%);
  border-radius: var(--radius-xl);
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  animation: scale-in var(--motion-normal) var(--ease-enter) both;
}

.confirm {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: var(--space-6);
  text-align: center;
}

.confirm__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: var(--amber-100);
  color: var(--amber-600);
}

.confirm__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.confirm__desc {
  font-size: var(--font-xs);
  color: var(--ink-500);
  line-height: 1.6;
}

.confirm__actions {
  display: flex;
  gap: var(--space-3);
  width: 100%;
  margin-top: var(--space-2);
}

.confirm__actions .btn {
  flex: 1;
}
</style>
