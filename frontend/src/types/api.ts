/** 统一 API 类型定义（与后端 VO 对应） */

export interface ApiResponse<T> {
  code: number
  message: string
  data: T
  timestamp: number
}

export interface PageResult<T> {
  records: T[]
  total: number
  page: number
  pageSize: number
}

export interface UserInfo {
  id: number
  username: string
  nickname: string
  email?: string | null
  phone?: string | null
  avatarUrl?: string | null
  status: string
  createdAt?: string
  orderCount?: number
}

export interface AdminInfo {
  id: number
  username: string
  displayName: string
  roleCode: string
  roleLabel: string
  status: string
  permissions: string[]
  lastLoginAt?: string | null
}

export interface AuthToken {
  token: string
  tokenType: string
  expiresIn: number
  user?: UserInfo
  admin?: AdminInfo
}

export interface Category {
  id: number
  name: string
  code: string
  icon?: string | null
  coverImage?: string | null
  sortOrder: number
  status: string
  createdAt?: string
  dishCount: number
}

export interface Dish {
  id: number
  categoryId: number
  categoryName?: string | null
  categoryCode?: string | null
  dishCode: string
  name: string
  description?: string | null
  ingredients: string[]
  allergens: string[]
  imageUrl?: string | null
  price: number
  calories?: number | null
  proteinG?: number | null
  fatG?: number | null
  carbohydrateG?: number | null
  fiberG?: number | null
  sodiumMg?: number | null
  nutritionSource: string
  nutritionNote?: string | null
  stock: number
  dailyLimit?: number | null
  soldCount: number
  supplyStatus: string
  publishStatus: string
  recommendFlag: boolean
  recommendRank: number
  tags: string[]
  sortOrder: number
  createdAt?: string
  updatedAt?: string
  available?: boolean
  favorited?: boolean
  availabilityText?: string
  recommendationBadge?: string | null
  recommendationSort?: number | null
}

export interface CartItem {
  id: number
  dishId: number
  dishName: string
  imageUrl?: string | null
  quantity: number
  unitPrice: number
  subtotal: number
  calories?: number | null
  subtotalCalories?: number | null
  available: boolean
  unavailableReason?: string | null
  stock: number
  supplyStatus: string
  publishStatus: string
}

export interface Cart {
  cartId: number
  items: CartItem[]
  totalQuantity: number
  dishCount: number
  totalAmount: number
  totalCalories: number
  warnings: string[]
  hasUnavailable: boolean
}

export interface OrderItem {
  id: number
  dishId?: number | null
  dishName: string
  imageUrl?: string | null
  unitPrice: number
  quantity: number
  subtotal: number
  calories?: number | null
  protein?: number | null
  fat?: number | null
  carbohydrate?: number | null
}

export interface OrderStatusLog {
  id: number
  fromStatus?: string | null
  toStatus: string
  toStatusLabel: string
  operatorType: string
  remark?: string | null
  createdAt: string
}

export interface Order {
  id: number
  orderNo: string
  userId: number
  userNickname?: string | null
  userAccount?: string | null
  totalAmount: number
  totalCalories?: number | null
  orderStatus: string
  orderStatusLabel: string
  paymentStatus: string
  paymentStatusLabel: string
  remark?: string | null
  itemCount?: number
  totalQuantity?: number
  items?: OrderItem[]
  statusLogs?: OrderStatusLog[]
  createdAt: string
  updatedAt?: string
  completedAt?: string | null
  demo?: boolean
}

export interface NutritionTrendPoint {
  date: string
  calories: number
  protein: number
  fat: number
  carbohydrate: number
  orderCount: number
}

export interface NutritionSummary {
  period: string
  totalCalories: number
  totalProtein: number
  totalFat: number
  totalCarbohydrate: number
  totalFiber: number
  totalSodium: number
  vegetableGrams: number
  orderCount: number
  dishCount: number
  targetCalories: number
  targetProtein: number
  targetWater: number
  dailyCalories: number
  dailyProtein: number
  calorieRate: number
  proteinRate: number
  waterRate: number
  waterMl: number
  suggestions: string[]
  note: string
  trend: NutritionTrendPoint[]
}

export interface HomeRecommendation {
  id: number
  dishId: number
  title?: string | null
  badgeText?: string | null
  sortOrder: number
  enabled: boolean
  dish?: Dish
}

export interface HomeContent {
  recommendations: HomeRecommendation[]
  categories: Category[]
  quickTags: string[]
  aiMode?: string
  aiConfigured?: boolean
}

export interface AiDishSuggestion {
  dishId: number
  name: string
  imageUrl?: string | null
  price?: number | null
  calories?: number | null
  categoryName?: string | null
  reason: string
  tags: string[]
}

export interface AiRecommendResult {
  mode: string
  modeLabel: string
  reply: string
  dishes: AiDishSuggestion[]
  tips: string[]
  conversationId?: number | null
  elapsedMs: number
}

export interface AiStatus {
  configured: boolean
  available: boolean
  mode: string
  modeLabel: string
  model: string
  message: string
  lastError?: string | null
}

export interface StatisticsOverview {
  todayOrders: number
  todaySales: number
  todayDishesSold: number
  weekOrders: number
  weekSales: number
  monthOrders: number
  monthSales: number
  avgOrderAmount: number
  dishCount: number
  publishedDishCount: number
  lowStockCount: number
  soldOutCount: number
  pendingOrderCount: number
  userCount: number
  activeUserCount: number
  totalOrders: number
  totalSales: number
  note: string
}

export interface Trend {
  period: string
  labels: string[]
  orderCounts: number[]
  salesAmounts: number[]
  note: string
}

export interface Ranking {
  items: {
    dishId: number
    name: string
    imageUrl?: string | null
    categoryName?: string | null
    quantity: number
    amount: number
    share: number
  }[]
}

export interface CategorySales {
  totalQuantity: number
  totalAmount: number
  items: {
    categoryId?: number | null
    categoryName: string
    quantity: number
    amount: number
    share: number
  }[]
}

export interface HourlyDistribution {
  labels: string[]
  counts: number[]
  note: string
}

export interface UserGrowth {
  labels: string[]
  newUsers: number[]
  cumulativeUsers: number[]
  note: string
}

export interface InventoryItem {
  dishId: number
  dishCode: string
  name: string
  imageUrl?: string | null
  categoryName?: string | null
  stock: number
  dailyLimit?: number | null
  soldCount: number
  remaining: number
  supplyStatus: string
  publishStatus: string
  lowStock: boolean
  soldOut: boolean
  updatedAt?: string
}

export interface InventoryLog {
  id: number
  dishId: number
  dishName: string
  changeAmount: number
  beforeStock: number
  afterStock: number
  reason: string
  operatorAdminId?: number | null
  operatorName: string
  relatedOrderId?: number | null
  createdAt: string
}

export interface UploadResult {
  url: string
  fileName: string
  size: number
  contentType: string
  width?: number
  height?: number
  note?: string
}
