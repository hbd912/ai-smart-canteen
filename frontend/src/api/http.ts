import axios, { type AxiosError, type AxiosInstance, type AxiosRequestConfig } from 'axios'
import type { ApiResponse } from '@/types/api'

/** 统一的业务错误对象，供 UI 展示可读 message */
export class ApiError extends Error {
  code: number
  status?: number

  constructor(message: string, code: number, status?: number) {
    super(message)
    this.name = 'ApiError'
    this.code = code
    this.status = status
  }
}

const USER_TOKEN_KEY = 'canteen.user.token'
const ADMIN_TOKEN_KEY = 'canteen.admin.token'

export function getUserToken(): string | null {
  try {
    return sessionStorage.getItem(USER_TOKEN_KEY)
  } catch {
    return null
  }
}

export function setUserToken(token: string | null) {
  try {
    if (token) {
      sessionStorage.setItem(USER_TOKEN_KEY, token)
    } else {
      sessionStorage.removeItem(USER_TOKEN_KEY)
    }
  } catch {
    /* sessionStorage 不可用时降级为内存态，不影响主流程 */
  }
}

export function getAdminToken(): string | null {
  try {
    return sessionStorage.getItem(ADMIN_TOKEN_KEY)
  } catch {
    return null
  }
}

export function setAdminToken(token: string | null) {
  try {
    if (token) {
      sessionStorage.setItem(ADMIN_TOKEN_KEY, token)
    } else {
      sessionStorage.removeItem(ADMIN_TOKEN_KEY)
    }
  } catch {
    /* ignore */
  }
}

const baseURL = import.meta.env.VITE_API_BASE_URL || ''

function createClient(getToken: () => string | null): AxiosInstance {
  const instance = axios.create({
    baseURL,
    timeout: 20000,
    headers: { 'Content-Type': 'application/json;charset=utf-8' }
  })

  instance.interceptors.request.use((config) => {
    const token = getToken()
    if (token) {
      config.headers = config.headers || {}
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  })

  instance.interceptors.response.use(
    (response) => response,
    (error: AxiosError<ApiResponse<unknown>>) => {
      const status = error.response?.status
      const payload = error.response?.data
      const message =
        (payload && typeof payload === 'object' && 'message' in payload && payload.message) ||
        (status === 401
          ? '登录状态已失效，请重新登录'
          : status === 403
            ? '没有权限执行该操作'
            : error.code === 'ECONNABORTED'
              ? '请求超时，请稍后重试'
              : '网络异常，请检查后端服务是否已启动')
      const code = (payload && typeof payload === 'object' && 'code' in payload && payload.code) || status || -1
      return Promise.reject(new ApiError(String(message), Number(code), status))
    }
  )
  return instance
}

/** 用户端请求实例 */
export const userHttp = createClient(getUserToken)
/** 管理员端请求实例 */
export const adminHttp = createClient(getAdminToken)

async function unwrap<T>(promise: Promise<{ data: ApiResponse<T> }>): Promise<T> {
  const response = await promise
  const body = response.data
  if (body && typeof body === 'object' && 'code' in body) {
    if (body.code !== 0) {
      throw new ApiError(body.message || '请求失败', body.code)
    }
    return body.data
  }
  return body as unknown as T
}

export function get<T>(
  url: string,
  params?: Record<string, unknown>,
  admin = false,
  config?: AxiosRequestConfig
): Promise<T> {
  const client = admin ? adminHttp : userHttp
  return unwrap<T>(client.get(url, { ...config, params }))
}

export function post<T>(url: string, data?: unknown, admin = false, config?: AxiosRequestConfig): Promise<T> {
  const client = admin ? adminHttp : userHttp
  return unwrap<T>(client.post(url, data, config))
}

export function put<T>(url: string, data?: unknown, admin = false): Promise<T> {
  const client = admin ? adminHttp : userHttp
  return unwrap<T>(client.put(url, data))
}

export function patch<T>(url: string, data?: unknown, admin = false): Promise<T> {
  const client = admin ? adminHttp : userHttp
  return unwrap<T>(client.patch(url, data))
}

export function del<T>(url: string, admin = false): Promise<T> {
  const client = admin ? adminHttp : userHttp
  return unwrap<T>(client.delete(url))
}

export function uploadFile<T>(url: string, file: File, admin = true): Promise<T> {
  const client = admin ? adminHttp : userHttp
  const form = new FormData()
  form.append('file', file)
  return unwrap<T>(
    client.post(url, form, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 60000
    })
  )
}
