<script setup lang="ts">
/**
 * 管理员登录页（与用户端登录完全独立）。
 * 视觉沿用品牌语言，但更偏清晰高效的控制台风格，不使用动漫视频背景。
 */
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppIcon from '@/components/common/AppIcon.vue'
import { useAdminAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'

const router = useRouter()
const route = useRoute()
const adminAuth = useAdminAuthStore()
const toast = useToastStore()

const form = reactive({ username: '', password: '' })
const showPassword = ref(false)
const error = ref('')
const submitting = ref(false)

const redirectTarget = computed(() => (route.query.redirect as string) || '/admin/dashboard')

async function submit() {
  if (submitting.value) {
    return
  }
  error.value = ''
  if (!form.username.trim()) {
    error.value = '请输入管理员账号'
    return
  }
  if (!form.password) {
    error.value = '请输入密码'
    return
  }
  submitting.value = true
  try {
    await adminAuth.login(form.username.trim(), form.password)
    toast.success('登录成功', `欢迎，${adminAuth.displayName}`)
    router.replace(redirectTarget.value)
  } catch (e) {
    error.value = e instanceof Error ? e.message : '登录失败，请稍后重试'
  } finally {
    submitting.value = false
  }
}

function fillDemo() {
  form.username = 'admin'
  form.password = 'Admin@123456'
  error.value = ''
}

function forgotPassword() {
  toast.info('忘记密码', '课堂演示环境未接入找回流程，请联系系统管理员重置密码。')
}
</script>

<template>
  <div class="admin-login">
    <div class="admin-login__bg" aria-hidden="true"></div>

    <div class="admin-login__card">
      <header class="admin-login__head">
        <span class="admin-login__logo"><AppIcon name="shield" :size="22" /></span>
        <div>
          <h1 class="admin-login__title">智慧食堂 · 管理后台</h1>
          <p class="admin-login__subtitle">请使用管理员账号登录，普通用户账号无法进入后台</p>
        </div>
      </header>

      <form class="admin-login__form" @submit.prevent="submit">
        <div class="field">
          <label class="field__label" for="admin-username">管理员账号 / 工号</label>
          <div class="input-wrap">
            <AppIcon name="user" :size="16" class="input-wrap__icon" />
            <input
              id="admin-username"
              v-model="form.username"
              class="input input--with-icon"
              type="text"
              autocomplete="username"
              placeholder="请输入管理员账号"
            />
          </div>
        </div>

        <div class="field">
          <label class="field__label" for="admin-password">密码</label>
          <div class="input-wrap">
            <AppIcon name="lock" :size="16" class="input-wrap__icon" />
            <input
              id="admin-password"
              v-model="form.password"
              class="input input--with-icon input--with-suffix"
              :type="showPassword ? 'text' : 'password'"
              autocomplete="current-password"
              placeholder="请输入密码"
            />
            <button
              class="input-wrap__suffix"
              type="button"
              :aria-label="showPassword ? '隐藏密码' : '显示密码'"
              @click="showPassword = !showPassword"
            >
              <AppIcon :name="showPassword ? 'eye-off' : 'eye'" :size="15" />
            </button>
          </div>
        </div>

        <p v-if="error" class="admin-login__error">
          <AppIcon name="x-circle" :size="14" />{{ error }}
        </p>

        <button class="btn btn--primary btn--lg btn--block" type="submit" :disabled="submitting">
          <span v-if="submitting" class="spinner"></span>
          <template v-else>
            登录后台
            <AppIcon name="arrow-right" :size="16" />
          </template>
        </button>
      </form>

      <div class="admin-login__foot">
        <div class="admin-login__demo">
          <AppIcon name="info" :size="12" />
          <span>演示管理员</span>
          <button type="button" class="admin-login__chip" @click="fillDemo">admin / Admin@123456</button>
        </div>
        <div class="admin-login__links">
          <button type="button" class="link-btn" @click="forgotPassword">忘记密码</button>
          <span class="admin-login__sep">·</span>
          <RouterLink to="/" class="link-btn">返回用户端</RouterLink>
        </div>
      </div>
    </div>

    <p class="admin-login__note">
      权限说明：演示版本使用单一超级管理员角色，前端隐藏菜单仅为体验优化，
      所有管理接口均由后端 Spring Security 校验 ADMIN 角色。
    </p>
  </div>
</template>

<style scoped>
.admin-login {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: var(--space-6);
  background: #f4f1ea;
  overflow: auto;
}

.admin-login__bg {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(46% 40% at 14% 8%, rgba(255, 231, 190, 0.6), transparent 70%),
    radial-gradient(42% 38% at 88% 92%, rgba(204, 226, 188, 0.5), transparent 72%);
  pointer-events: none;
}

.admin-login__card {
  position: relative;
  width: min(430px, 100%);
  padding: var(--space-7);
  border-radius: var(--radius-2xl);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(255, 255, 255, 0.9);
  box-shadow: var(--shadow-xl);
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.admin-login__head {
  display: flex;
  align-items: flex-start;
  gap: var(--space-3);
}

.admin-login__logo {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  flex: none;
  border-radius: var(--radius-md);
  background: linear-gradient(140deg, var(--sage-500), var(--sage-700));
  color: #fff;
  box-shadow: 0 6px 16px rgba(95, 120, 80, 0.26);
}

.admin-login__title {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--ink-900);
}

.admin-login__subtitle {
  font-size: var(--font-xs);
  color: var(--ink-500);
  margin-top: 3px;
  line-height: 1.5;
}

.admin-login__form {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.input-wrap {
  position: relative;
  display: flex;
  align-items: center;
}

.input-wrap__icon {
  position: absolute;
  left: 13px;
  color: var(--sage-500);
  pointer-events: none;
}

.input--with-icon {
  padding-left: 38px;
}

.input--with-suffix {
  padding-right: 40px;
}

.input-wrap__suffix {
  position: absolute;
  right: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 26px;
  border-radius: 50%;
  color: var(--ink-400);
}

.input-wrap__suffix:hover {
  color: var(--sage-600);
  background: var(--sage-100);
}

.admin-login__error {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 9px 12px;
  border-radius: var(--radius-sm);
  background: var(--danger-100);
  color: var(--danger-600);
  font-size: var(--font-sm);
}

.admin-login__foot {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-top: var(--space-4);
  border-top: 1px solid rgba(124, 143, 90, 0.14);
}

.admin-login__demo {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 6px;
  font-size: var(--font-xs);
  color: var(--ink-500);
}

.admin-login__chip {
  padding: 3px 9px;
  border-radius: var(--radius-pill);
  background: var(--sage-100);
  color: var(--sage-700);
  font-size: var(--font-xs);
  font-weight: 600;
}

.admin-login__links {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: var(--font-xs);
}

.link-btn {
  color: var(--sage-600);
  font-size: var(--font-xs);
  font-weight: 600;
}

.link-btn:hover {
  text-decoration: underline;
}

.admin-login__sep {
  color: var(--ink-300);
}

.admin-login__note {
  position: relative;
  margin-top: var(--space-5);
  max-width: 480px;
  text-align: center;
  font-size: 11px;
  color: var(--ink-400);
  line-height: 1.6;
}

.spinner {
  width: 17px;
  height: 17px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.4);
  border-top-color: #fff;
  animation: spin 700ms linear infinite;
}
</style>
