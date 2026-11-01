<script setup lang="ts">
/**
 * 登录 / 注册浮层（右侧玻璃卡片）。
 * 位置：画面右侧中部偏上，右边距 5%–7%，不遮挡男主与门把手。
 * 演示模式：账号体系由后端真实校验（BCrypt + JWT），不是纯前端假登录。
 */
import { computed, reactive, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'

const emit = defineEmits<{
  (e: 'success'): void
  (e: 'admin-entry'): void
}>()

const auth = useAuthStore()
const toast = useToastStore()

type Mode = 'login' | 'register'
const mode = ref<Mode>('login')
const showPassword = ref(false)
const submitting = ref(false)
const serverError = ref('')
const rememberMe = ref(true)

const loginForm = reactive({
  username: '',
  password: ''
})

const registerForm = reactive({
  nickname: '',
  username: '',
  password: '',
  confirmPassword: '',
  agreement: false
})

const errors = reactive<Record<string, string>>({
  username: '',
  password: '',
  nickname: '',
  confirmPassword: '',
  agreement: ''
})

const isLogin = computed(() => mode.value === 'login')

const demoAccounts = [
  { label: '演示用户', account: 'student', password: '123456' }
]

function clearErrors() {
  Object.keys(errors).forEach((key) => {
    errors[key] = ''
  })
  serverError.value = ''
}

function switchMode(next: Mode) {
  mode.value = next
  clearErrors()
}

function validateLogin(): boolean {
  clearErrors()
  let ok = true
  if (!loginForm.username.trim()) {
    errors.username = '请输入账号'
    ok = false
  }
  if (!loginForm.password) {
    errors.password = '请输入密码'
    ok = false
  } else if (loginForm.password.length < 6) {
    errors.password = '密码长度至少 6 位'
    ok = false
  }
  return ok
}

function validateRegister(): boolean {
  clearErrors()
  let ok = true
  if (!registerForm.nickname.trim()) {
    errors.nickname = '请输入昵称'
    ok = false
  } else if (registerForm.nickname.trim().length > 20) {
    errors.nickname = '昵称不能超过 20 个字符'
    ok = false
  }
  if (!registerForm.username.trim()) {
    errors.username = '请输入账号'
    ok = false
  } else if (!/^[A-Za-z0-9_@.\-]{3,20}$/.test(registerForm.username.trim())) {
    errors.username = '账号需 3-20 位，仅支持字母、数字、_ @ . -'
    ok = false
  }
  if (!registerForm.password) {
    errors.password = '请输入密码'
    ok = false
  } else if (registerForm.password.length < 6 || registerForm.password.length > 32) {
    errors.password = '密码长度需在 6-32 位之间'
    ok = false
  }
  if (!registerForm.confirmPassword) {
    errors.confirmPassword = '请再次输入密码'
    ok = false
  } else if (registerForm.confirmPassword !== registerForm.password) {
    errors.confirmPassword = '两次输入的密码不一致'
    ok = false
  }
  if (!registerForm.agreement) {
    errors.agreement = '请阅读并同意用户协议'
    ok = false
  }
  return ok
}

async function submit() {
  if (submitting.value) {
    return
  }
  const valid = isLogin.value ? validateLogin() : validateRegister()
  if (!valid) {
    return
  }
  submitting.value = true
  serverError.value = ''
  try {
    if (isLogin.value) {
      await auth.login(loginForm.username.trim(), loginForm.password)
      toast.success('登录成功', '欢迎回到智慧食堂')
    } else {
      await auth.register({
        username: registerForm.username.trim(),
        nickname: registerForm.nickname.trim(),
        password: registerForm.password,
        confirmPassword: registerForm.confirmPassword
      })
      toast.success('注册成功', '已为你开启智慧用餐体验')
    }
    emit('success')  } catch (e) {
    const message = e instanceof Error ? e.message : '登录失败，请稍后重试'
    serverError.value = message
  } finally {
    submitting.value = false
  }
}

function fillDemo(account: string, password: string) {
  mode.value = 'login'
  clearErrors()
  loginForm.username = account
  loginForm.password = password
}
</script>

<template>
  <div class="auth-layer">
    <div class="auth-card glass-panel anim-slide-right">
      <div class="auth-card__header">
        <span class="auth-card__logo">
          <AppIcon name="leaf" :size="22" />
        </span>
        <div>
          <h1 class="auth-card__title">欢迎来到智慧食堂</h1>
          <p class="auth-card__subtitle">登录后开启你的智能用餐体验</p>
        </div>
      </div>

      <div class="auth-tabs" role="tablist" aria-label="登录或注册">
        <button
          class="auth-tabs__btn"
          :class="{ 'auth-tabs__btn--active': isLogin }"
          type="button"
          role="tab"
          :aria-selected="isLogin"
          @click="switchMode('login')"
        >
          登录
        </button>
        <button
          class="auth-tabs__btn"
          :class="{ 'auth-tabs__btn--active': !isLogin }"
          type="button"
          role="tab"
          :aria-selected="!isLogin"
          @click="switchMode('register')"
        >
          注册
        </button>
      </div>

      <form class="auth-form" novalidate @submit.prevent="submit">
        <template v-if="isLogin">
          <div class="field">
            <label class="field__label" for="login-username">账号 / 手机号</label>
            <div class="input-wrap">
              <AppIcon name="user" :size="17" class="input-wrap__icon" />
              <input
                id="login-username"
                v-model="loginForm.username"
                class="input input--with-icon"
                :class="{ 'input--error': errors.username }"
                type="text"
                autocomplete="username"
                placeholder="请输入账号"
              />
            </div>
            <p v-if="errors.username" class="field__error">
              <AppIcon name="alert-triangle" :size="12" />{{ errors.username }}
            </p>
          </div>

          <div class="field">
            <label class="field__label" for="login-password">密码</label>
            <div class="input-wrap">
              <AppIcon name="lock" :size="17" class="input-wrap__icon" />
              <input
                id="login-password"
                v-model="loginForm.password"
                class="input input--with-icon input--with-suffix"
                :class="{ 'input--error': errors.password }"
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
                <AppIcon :name="showPassword ? 'eye-off' : 'eye'" :size="16" />
              </button>
            </div>
            <p v-if="errors.password" class="field__error">
              <AppIcon name="alert-triangle" :size="12" />{{ errors.password }}
            </p>
          </div>

          <div class="auth-row">
            <label class="checkbox">
              <input v-model="rememberMe" type="checkbox" />
              <span class="checkbox__box"><AppIcon name="check" :size="11" /></span>
              <span class="checkbox__text">记住我</span>
            </label>
            <button
              class="link-btn"
              type="button"
              @click="toast.info('忘记密码', '课堂演示环境暂未接入短信/邮件找回，请联系管理员重置。')"
            >
              忘记密码？
            </button>
          </div>
        </template>

        <template v-else>
          <div class="field">
            <label class="field__label" for="reg-nickname">昵称</label>
            <input
              id="reg-nickname"
              v-model="registerForm.nickname"
              class="input"
              :class="{ 'input--error': errors.nickname }"
              type="text"
              autocomplete="nickname"
              placeholder="想让我们怎么称呼你？"
            />
            <p v-if="errors.nickname" class="field__error">
              <AppIcon name="alert-triangle" :size="12" />{{ errors.nickname }}
            </p>
          </div>

          <div class="field">
            <label class="field__label" for="reg-username">账号 / 手机号</label>
            <input
              id="reg-username"
              v-model="registerForm.username"
              class="input"
              :class="{ 'input--error': errors.username }"
              type="text"
              autocomplete="username"
              placeholder="3-20 位字母、数字或 _ @ . -"
            />
            <p v-if="errors.username" class="field__error">
              <AppIcon name="alert-triangle" :size="12" />{{ errors.username }}
            </p>
          </div>

          <div class="field-row">
            <div class="field">
              <label class="field__label" for="reg-password">密码</label>
              <input
                id="reg-password"
                v-model="registerForm.password"
                class="input"
                :class="{ 'input--error': errors.password }"
                :type="showPassword ? 'text' : 'password'"
                autocomplete="new-password"
                placeholder="6-32 位"
              />
              <p v-if="errors.password" class="field__error">
                <AppIcon name="alert-triangle" :size="12" />{{ errors.password }}
              </p>
            </div>
            <div class="field">
              <label class="field__label" for="reg-confirm">确认密码</label>
              <input
                id="reg-confirm"
                v-model="registerForm.confirmPassword"
                class="input"
                :class="{ 'input--error': errors.confirmPassword }"
                :type="showPassword ? 'text' : 'password'"
                autocomplete="new-password"
                placeholder="再次输入"
              />
              <p v-if="errors.confirmPassword" class="field__error">
                <AppIcon name="alert-triangle" :size="12" />{{ errors.confirmPassword }}
              </p>
            </div>
          </div>

          <label class="checkbox checkbox--agreement">
            <input v-model="registerForm.agreement" type="checkbox" />
            <span class="checkbox__box"><AppIcon name="check" :size="11" /></span>
            <span class="checkbox__text">我已阅读并同意《用户协议》与《隐私说明》（演示版本地确认）</span>
          </label>
          <p v-if="errors.agreement" class="field__error">
            <AppIcon name="alert-triangle" :size="12" />{{ errors.agreement }}
          </p>
        </template>

        <p v-if="serverError" class="auth-error">
          <AppIcon name="x-circle" :size="14" />{{ serverError }}
        </p>

        <button class="btn btn--primary btn--lg btn--block auth-submit" type="submit" :disabled="submitting">
          <span v-if="submitting" class="spinner"></span>
          <template v-else>
            <span>{{ isLogin ? '登录' : '注册并进入' }}</span>
            <AppIcon name="arrow-right" :size="17" />
          </template>
        </button>

        <p class="auth-switch">
          <template v-if="isLogin">
            没有账号？
            <button class="link-btn" type="button" @click="switchMode('register')">立即注册</button>
          </template>
          <template v-else>
            已有账号？
            <button class="link-btn" type="button" @click="switchMode('login')">立即登录</button>
          </template>
        </p>
      </form>

      <div class="auth-card__footer">
        <div class="demo-hint">
          <AppIcon name="info" :size="13" />
          <span>演示账号</span>
          <button
            v-for="account in demoAccounts"
            :key="account.account"
            class="demo-hint__chip"
            type="button"
            @click="fillDemo(account.account, account.password)"
          >
            {{ account.account }}
          </button>
        </div>
        <button class="admin-entry" type="button" @click="emit('admin-entry')">
          <AppIcon name="shield" :size="12" />
          管理员入口
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.auth-layer {
  position: absolute;
  inset: 0;
  z-index: 40;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  /* 卡片整体左移，不再紧贴屏幕右侧；垂直居中略偏上 */
  padding-right: 9%;
  padding-top: 0;
  padding-bottom: 4vh;
  pointer-events: none;
}

.auth-card {
  pointer-events: auto;
  width: min(452px, 94vw);
  max-height: 84vh;
  overflow-y: auto;
  padding: var(--space-8) var(--space-7);
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.auth-card__header {
  display: flex;
  align-items: flex-start;
  gap: var(--space-3);
}

.auth-card__logo {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  flex: none;
  border-radius: var(--radius-md);
  background: linear-gradient(140deg, var(--sage-400), var(--sage-600));
  color: #fff;
  box-shadow: 0 6px 16px rgba(95, 120, 80, 0.26);
}

.auth-card__title {
  font-size: var(--font-xl);
  font-weight: 700;
  color: var(--ink-900);
  letter-spacing: 0.01em;
  line-height: 1.35;
}

.auth-card__subtitle {
  font-size: var(--font-sm);
  color: var(--ink-500);
  margin-top: 2px;
}

.auth-tabs {
  display: flex;
  gap: 4px;
  padding: 4px;
  border-radius: var(--radius-pill);
  background: rgba(232, 238, 221, 0.6);
}

.auth-tabs__btn {
  flex: 1;
  height: 34px;
  border-radius: var(--radius-pill);
  font-size: var(--font-base);
  font-weight: 600;
  color: var(--ink-600);
  transition: background-color var(--motion-normal) var(--ease-standard),
    color var(--motion-normal) var(--ease-standard),
    box-shadow var(--motion-normal) var(--ease-standard);
}

.auth-tabs__btn--active {
  background: #fff;
  color: var(--sage-700);
  box-shadow: var(--shadow-sm);
}

.auth-form {
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
  transition: color var(--motion-fast) var(--ease-standard),
    background-color var(--motion-fast) var(--ease-standard);
}

.input-wrap__suffix:hover {
  color: var(--sage-600);
  background: var(--sage-100);
}

.field-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-3);
}

.auth-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
}

.checkbox {
  display: inline-flex;
  align-items: flex-start;
  gap: 8px;
  cursor: pointer;
  user-select: none;
}

.checkbox input {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

.checkbox__box {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 17px;
  height: 17px;
  margin-top: 1px;
  flex: none;
  border-radius: 5px;
  border: 1.5px solid rgba(124, 143, 90, 0.45);
  background: #fff;
  color: transparent;
  transition: background-color var(--motion-fast) var(--ease-standard),
    border-color var(--motion-fast) var(--ease-standard),
    color var(--motion-fast) var(--ease-standard);
}

.checkbox input:checked + .checkbox__box {
  background: var(--sage-600);
  border-color: var(--sage-600);
  color: #fff;
}

.checkbox input:focus-visible + .checkbox__box {
  box-shadow: var(--shadow-glow);
}

.checkbox__text {
  font-size: var(--font-sm);
  color: var(--ink-600);
  line-height: 1.5;
}

.checkbox--agreement .checkbox__text {
  font-size: var(--font-xs);
}

.link-btn {
  font-size: var(--font-sm);
  color: var(--sage-600);
  font-weight: 600;
  padding: 0;
  transition: color var(--motion-fast) var(--ease-standard);
}

.link-btn:hover {
  color: var(--sage-800);
  text-decoration: underline;
}

.auth-error {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 9px 12px;
  border-radius: var(--radius-sm);
  background: var(--danger-100);
  color: var(--danger-600);
  font-size: var(--font-sm);
}

.auth-submit {
  margin-top: 2px;
}

.auth-switch {
  text-align: center;
  font-size: var(--font-sm);
  color: var(--ink-500);
}

.spinner {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.4);
  border-top-color: #fff;
  animation: spin 700ms linear infinite;
}

.auth-card__footer {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-top: var(--space-3);
  border-top: 1px solid rgba(124, 143, 90, 0.14);
}

.demo-hint {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 6px;
  font-size: var(--font-xs);
  color: var(--ink-500);
}

.demo-hint__chip {
  padding: 3px 9px;
  border-radius: var(--radius-pill);
  background: rgba(232, 238, 221, 0.8);
  color: var(--sage-700);
  font-size: var(--font-xs);
  font-weight: 600;
  transition: background-color var(--motion-fast) var(--ease-standard);
}

.demo-hint__chip:hover {
  background: var(--sage-200);
}

.admin-entry {
  align-self: flex-start;
  display: inline-flex;
  align-items: center;
  gap: 5px;
  font-size: var(--font-xs);
  color: var(--ink-400);
  transition: color var(--motion-fast) var(--ease-standard);
}

.admin-entry:hover {
  color: var(--sage-600);
}

@media (max-width: 1023px) {
  .auth-layer {
    justify-content: center;
    align-items: flex-end;
    padding: 0 16px 84px;
  }

  .auth-card {
    width: 100%;
    max-width: 480px;
    max-height: 66vh;
    padding: var(--space-6) var(--space-5);
  }
}
</style>
