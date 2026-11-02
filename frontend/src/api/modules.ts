import { del, get, patch, post, put, uploadFile } from './http'
import type {
  AdminInfo,
  AiRecommendResult,
  AiStatus,
  AuthToken,
  Cart,
  Category,
  Dish,
  HomeRecommendation,
  InventoryItem,
  InventoryLog,
  NutritionSummary,
  Order,
  PageResult,
  UploadResult,
  UserInfo,
  DishRatingSummary,
  DishReview
} from '@/types/api'

/** ---------- 认证 ---------- */
export const authApi = {
  register: (payload: {
    username: string
    nickname: string
    password: string
    confirmPassword: string
    email?: string
    phone?: string
  }) => post<AuthToken>('/api/v1/auth/register', payload),
  login: (payload: { username: string; password: string }) => post<AuthToken>('/api/v1/auth/login', payload),
  logout: () => post<void>('/api/v1/auth/logout'),
  me: () => get<UserInfo>('/api/v1/users/me'),
  updateProfile: (payload: Partial<Pick<UserInfo, 'nickname' | 'email' | 'phone' | 'avatarUrl'>>) =>
    put<UserInfo>('/api/v1/users/me', payload),
  adminLogin: (payload: { username: string; password: string }) =>
    post<AuthToken>('/api/v1/admin/auth/login', payload, true),
  adminMe: () => get<AdminInfo>('/api/v1/admin/auth/me', undefined, true)
}

/** ---------- 菜品与分类 ---------- */
export const dishApi = {
  list: (params: Record<string, unknown> = {}) => get<PageResult<Dish>>('/api/v1/dishes', params),
  detail: (id: number) => get<Dish>(`/api/v1/dishes/${id}`),
  categories: () => get<Category[]>('/api/v1/categories'),
  homeRecommendations: () => get<HomeRecommendation[]>('/api/v1/recommendations/home')
}

/** ---------- 购物车 ---------- */
export const cartApi = {
  get: () => get<Cart>('/api/v1/cart'),
  add: (dishId: number, quantity = 1) => post<Cart>('/api/v1/cart/items', { dishId, quantity }),
  update: (itemId: number, quantity: number) => put<Cart>(`/api/v1/cart/items/${itemId}`, { quantity }),
  remove: (itemId: number) => del<Cart>(`/api/v1/cart/items/${itemId}`),
  clear: () => del<Cart>('/api/v1/cart')
}

/** ---------- 订单 ---------- */
export const orderApi = {
  create: (payload: { remark?: string; idempotencyKey?: string }) => post<Order>('/api/v1/orders', payload),
  list: (params: { page?: number; pageSize?: number; status?: string } = {}) =>
    get<PageResult<Order>>('/api/v1/orders', params),
  detail: (id: number) => get<Order>(`/api/v1/orders/${id}`),
  active: () => get<Order | null>('/api/v1/orders/active'),
  syncSceneStatus: (id: number, status: string) =>
    patch<Order>(`/api/v1/orders/${id}/scene-status`, { status })
}

/** ---------- 收藏 ---------- */
export const favoriteApi = {
  list: () => get<Dish[]>('/api/v1/favorites'),
  toggle: (dishId: number) => post<{ favorited: boolean }>(`/api/v1/favorites/${dishId}/toggle`)
}

/** ---------- 营养 ---------- */
export const nutritionApi = {
  summary: (days = 7) => get<NutritionSummary>('/api/v1/nutrition/summary', { days }),
  trends: (days = 7) => get<NutritionSummary['trend']>('/api/v1/nutrition/trends', { days }),
  advice: (days = 7) => get<Record<string, unknown>>('/api/v1/nutrition/advice', { days })
}

/** ---------- AI ---------- */
export const aiApi = {
  status: () => get<AiStatus>('/api/v1/ai/status'),
  recommend: (payload: { message: string; conversationId?: number | null; budgetMax?: number }) =>
    post<AiRecommendResult>('/api/v1/ai/recommend', payload)
}

/** ---------- 管理后台 ---------- */
export const adminApi = {
  dishes: (params: Record<string, unknown> = {}) => get<PageResult<Dish>>('/api/v1/admin/dishes', params, true),
  dish: (id: number) => get<Dish>(`/api/v1/admin/dishes/${id}`, undefined, true),
  createDish: (payload: Record<string, unknown>) => post<Dish>('/api/v1/admin/dishes', payload, true),
  updateDish: (id: number, payload: Record<string, unknown>) =>
    put<Dish>(`/api/v1/admin/dishes/${id}`, payload, true),
  changeDishStatus: (id: number, status: string) =>
    patch<void>(`/api/v1/admin/dishes/${id}/status`, { status }, true),
  changeSupplyStatus: (id: number, status: string) =>
    patch<void>(`/api/v1/admin/dishes/${id}/supply-status`, { status }, true),
  copyDish: (id: number) => post<Dish>(`/api/v1/admin/dishes/${id}/copy`, {}, true),
  deleteDish: (id: number) => del<void>(`/api/v1/admin/dishes/${id}`, true),

  categories: () => get<Category[]>('/api/v1/admin/categories', undefined, true),
  createCategory: (payload: Record<string, unknown>) => post<Category>('/api/v1/admin/categories', payload, true),
  updateCategory: (id: number, payload: Record<string, unknown>) =>
    put<Category>(`/api/v1/admin/categories/${id}`, payload, true),
  changeCategoryStatus: (id: number, status: string) =>
    patch<void>(`/api/v1/admin/categories/${id}/status`, { status }, true),
  sortCategories: (items: { id: number; sortOrder: number }[]) =>
    patch<void>('/api/v1/admin/categories/sort', { items }, true),
  deleteCategory: (id: number) => del<void>(`/api/v1/admin/categories/${id}`, true),

  inventory: (params: Record<string, unknown> = {}) =>
    get<InventoryItem[]>('/api/v1/admin/inventory', params, true),
  adjustInventory: (payload: { dishId: number; changeAmount?: number; targetStock?: number; reason: string }) =>
    post<InventoryItem>('/api/v1/admin/inventory/adjust', payload, true),
  inventoryLogs: (params: Record<string, unknown> = {}) =>
    get<PageResult<InventoryLog>>('/api/v1/admin/inventory/logs', params, true),
  setSupplyStatus: (dishId: number, status: string) =>
    patch<void>(`/api/v1/admin/inventory/${dishId}/supply-status`, { status }, true),

  orders: (params: Record<string, unknown> = {}) => get<PageResult<Order>>('/api/v1/admin/orders', params, true),
  order: (id: number) => get<Order>(`/api/v1/admin/orders/${id}`, undefined, true),
  updateOrderStatus: (id: number, status: string, remark?: string) =>
    patch<Order>(`/api/v1/admin/orders/${id}/status`, { status, remark }, true),

  users: (params: Record<string, unknown> = {}) => get<PageResult<UserInfo>>('/api/v1/admin/users', params, true),
  changeUserStatus: (id: number, status: string) =>
    patch<void>(`/api/v1/admin/users/${id}/status`, { status }, true),

  recommendations: () => get<HomeRecommendation[]>('/api/v1/admin/recommendations', undefined, true),
  saveRecommendations: (items: Record<string, unknown>[]) =>
    put<void>('/api/v1/admin/recommendations', { items }, true),

  nutritionDishes: (params: Record<string, unknown> = {}) =>
    get<PageResult<Dish>>('/api/v1/admin/nutrition/dish-list', params, true),
  nutritionGaps: () => get<Record<string, unknown>[]>('/api/v1/admin/nutrition/dishes', undefined, true),
  admins: () => get<AdminInfo[]>('/api/v1/admin/admins', undefined, true),

  uploadDishImage: (file: File) => uploadFile<UploadResult>('/api/v1/admin/media/dishes', file, true),

  statisticsOverview: () => get<Record<string, number | string>>('/api/v1/admin/statistics/overview', undefined, true),
  statisticsTrend: (period: 'week' | 'month') =>
    get<Record<string, unknown>>('/api/v1/admin/statistics/orders-trend', { period }, true),
  statisticsRanking: (limit = 10) =>
    get<Record<string, unknown>>('/api/v1/admin/statistics/dish-ranking', { limit }, true),
  statisticsCategorySales: () => get<Record<string, unknown>>('/api/v1/admin/statistics/category-sales', undefined, true),
  statisticsHourly: () => get<Record<string, unknown>>('/api/v1/admin/statistics/hourly-distribution', undefined, true),
  statisticsUserGrowth: () => get<Record<string, unknown>>('/api/v1/admin/statistics/user-growth', undefined, true)
}

/** ---------- 菜品评价 ---------- */
export const reviewApi = {
  /** 评分汇总（匿名可读） */
  summary: (dishId: number) => get<DishRatingSummary>(`/api/v1/reviews/dishes/${dishId}/summary`),
  /** 评价分页列表 */
  list: (dishId: number, page = 1, pageSize = 10) =>
    get<PageResult<DishReview>>(`/api/v1/reviews/dishes/${dishId}`, { page, pageSize }),
  /** 我的评价 */
  mine: () => get<DishReview[]>('/api/v1/reviews/mine'),
  /** 提交或更新评价 */
  submit: (payload: {
    dishId: number
    rating: number
    content?: string
    anonymous?: boolean
    orderId?: number | null
  }) => post<DishReview>('/api/v1/reviews', payload),
  /** 删除自己的评价 */
  remove: (reviewId: number) => del<void>(`/api/v1/reviews/${reviewId}`),
  /** 评价中心：按订单明细列出待评价/已评价 */
  center: () => get<Record<string, unknown>[]>('/api/v1/reviews/center'),
  /** 检查某道菜是否可评价 */
  canReview: (dishId: number) => get<{ canReview: boolean }>('/api/v1/reviews/can-review', { dishId }),
  /** 带订单的评价提交（评价中心使用） */
  dialogSubmit: (payload: {
    dishId: number
    orderId: number
    rating: number
    content?: string
    anonymous?: boolean
  }) => post<DishReview>('/api/v1/reviews', payload)
}

/** ---------- 精选作品 ---------- */
export const workApi = {
  /** 作品流（sort=hot 按点赞 / latest 按时间） */
  feed: (sort: 'hot' | 'latest' = 'hot', page = 1, pageSize = 40) =>
    get<Record<string, unknown>[]>('/api/v1/works', { sort, page, pageSize }),
  /** 作品详情（含评论） */
  detail: (id: number) => get<Record<string, unknown>>(`/api/v1/works/${id}`),
  /** 点赞 / 取消点赞 */
  toggleLike: (id: number) => post<{ liked: boolean }>(`/api/v1/works/${id}/like`),
  /** 评论列表 */
  comments: (id: number) => get<Record<string, unknown>[]>(`/api/v1/works/${id}/comments`),
  /** 发表评论 */
  addComment: (id: number, content: string) =>
    post<Record<string, unknown>>(`/api/v1/works/${id}/comments`, { content }),
  /** 发布作品（图片 + 文字 + 可选关联菜品） */
  publish: (payload: {
    title?: string
    content: string
    dishId?: number | null
    orderId?: number | null
    images: string[]
  }) => post<Record<string, unknown>>('/api/v1/works', payload),
  /** 上传作品图片（普通用户） */
  uploadImage: (file: File) => uploadFile<UploadResult>('/api/v1/works/images', file, false)
}
