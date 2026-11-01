import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { authApi } from '@/api/modules'
import { getAdminToken, getUserToken, setAdminToken, setUserToken } from '@/api/http'
import type { AdminInfo, UserInfo } from '@/types/api'

/** 普通用户会话 */
export const useAuthStore = defineStore('auth', () => {
  const user = ref<UserInfo | null>(null)
  const token = ref<string | null>(getUserToken())
  const loading = ref(false)
  const initialized = ref(false)

  const isLoggedIn = computed(() => Boolean(token.value && user.value))
  const displayName = computed(() => user.value?.nickname || user.value?.username || '同学')
  const initial = computed(() => (displayName.value ? displayName.value.slice(0, 1) : '食'))

  function applyToken(nextToken: string, nextUser?: UserInfo) {
    token.value = nextToken
    setUserToken(nextToken)
    if (nextUser) {
      user.value = nextUser
    }
  }

  async function login(username: string, password: string) {
    loading.value = true
    try {
      const result = await authApi.login({ username, password })
      applyToken(result.token, result.user)
      initialized.value = true
      return result
    } finally {
      loading.value = false
    }
  }

  async function register(payload: {
    username: string
    nickname: string
    password: string
    confirmPassword: string
    email?: string
    phone?: string
  }) {
    loading.value = true
    try {
      const result = await authApi.register(payload)
      applyToken(result.token, result.user)
      initialized.value = true
      return result
    } finally {
      loading.value = false
    }
  }

  /** 刷新页面后依据 sessionStorage 中的 token 恢复会话 */
  async function restoreSession() {
    if (initialized.value) {
      return isLoggedIn.value
    }
    if (!token.value) {
      initialized.value = true
      return false
    }
    try {
      user.value = await authApi.me()
      initialized.value = true
      return true
    } catch {
      logoutLocal()
      initialized.value = true
      return false
    }
  }

  async function updateProfile(payload: Partial<Pick<UserInfo, 'nickname' | 'email' | 'phone' | 'avatarUrl'>>) {
    const updated = await authApi.updateProfile(payload)
    user.value = updated
    return updated
  }

  function logoutLocal() {
    token.value = null
    user.value = null
    setUserToken(null)
  }

  async function logout() {
    try {
      if (token.value) {
        await authApi.logout()
      }
    } catch {
      /* 无状态 JWT：服务端无需失效，忽略网络错误 */
    } finally {
      logoutLocal()
    }
  }

  return {
    user,
    token,
    loading,
    initialized,
    isLoggedIn,
    displayName,
    initial,
    login,
    register,
    restoreSession,
    updateProfile,
    logout
  }
})

/** 管理员会话（与用户会话完全独立） */
export const useAdminAuthStore = defineStore('adminAuth', () => {
  const admin = ref<AdminInfo | null>(null)
  const token = ref<string | null>(getAdminToken())
  const loading = ref(false)
  const initialized = ref(false)

  const isLoggedIn = computed(() => Boolean(token.value && admin.value))
  const permissions = computed(() => admin.value?.permissions ?? [])
  const displayName = computed(() => admin.value?.displayName || admin.value?.username || '管理员')
  const roleLabel = computed(() => admin.value?.roleLabel || '')

  function has(permission: string) {
    return permissions.value.includes(permission)
  }

  async function login(username: string, password: string) {
    loading.value = true
    try {
      const result = await authApi.adminLogin({ username, password })
      token.value = result.token
      setAdminToken(result.token)
      admin.value = result.admin ?? null
      initialized.value = true
      return result
    } finally {
      loading.value = false
    }
  }

  async function restoreSession() {
    if (initialized.value) {
      return isLoggedIn.value
    }
    if (!token.value) {
      initialized.value = true
      return false
    }
    try {
      admin.value = await authApi.adminMe()
      initialized.value = true
      return true
    } catch {
      logoutLocal()
      initialized.value = true
      return false
    }
  }

  function logoutLocal() {
    token.value = null
    admin.value = null
    setAdminToken(null)
  }

  function logout() {
    logoutLocal()
  }

  return { admin, token, loading, initialized, isLoggedIn, permissions, displayName, roleLabel, has, login, restoreSession, logout }
})
