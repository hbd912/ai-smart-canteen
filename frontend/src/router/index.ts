import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAdminAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'customer-home',
    component: () => import('@/views/customer/CustomerSceneView.vue'),
    meta: { title: '智慧食堂' }
  },
  {
    path: '/customer',
    redirect: '/'
  },
  {
    path: '/customer/orders',
    name: 'customer-orders',
    component: () => import('@/views/customer/CustomerSceneView.vue'),
    meta: { title: '我的订单', panel: 'order' }
  },
  {
    path: '/customer/favorites',
    name: 'customer-favorites',
    component: () => import('@/views/customer/CustomerSceneView.vue'),
    meta: { title: '我的收藏', panel: 'favorites' }
  },
  {
    path: '/customer/nutrition',
    name: 'customer-nutrition',
    component: () => import('@/views/customer/CustomerSceneView.vue'),
    meta: { title: '营养管理', panel: 'nutrition' }
  },
  {
    path: '/admin/login',
    name: 'admin-login',
    component: () => import('@/views/admin/AdminLoginView.vue'),
    meta: { title: '管理员登录', public: true }
  },
  {
    path: '/admin',
    component: () => import('@/layouts/AdminLayout.vue'),
    meta: { requiresAdmin: true },
    children: [
      { path: '', redirect: '/admin/dashboard' },
      {
        path: 'dashboard',
        name: 'admin-dashboard',
        component: () => import('@/views/admin/AdminDashboardView.vue'),
        meta: { title: '工作台', icon: 'dashboard' }
      },
      {
        path: 'dishes',
        name: 'admin-dishes',
        component: () => import('@/views/admin/AdminDishesView.vue'),
        meta: { title: '菜品管理', icon: 'dish' }
      },
      {
        path: 'categories',
        name: 'admin-categories',
        component: () => import('@/views/admin/AdminCategoriesView.vue'),
        meta: { title: '菜品分类', icon: 'tag' }
      },
      {
        path: 'inventory',
        name: 'admin-inventory',
        component: () => import('@/views/admin/AdminInventoryView.vue'),
        meta: { title: '库存管理', icon: 'box' }
      },
      {
        path: 'orders',
        name: 'admin-orders',
        component: () => import('@/views/admin/AdminOrdersView.vue'),
        meta: { title: '订单管理', icon: 'clipboard-list' }
      },
      {
        path: 'users',
        name: 'admin-users',
        component: () => import('@/views/admin/AdminUsersView.vue'),
        meta: { title: '用户管理', icon: 'users' }
      },

      {
        path: 'recommendations',
        name: 'admin-recommendations',
        component: () => import('@/views/admin/AdminRecommendationsView.vue'),
        meta: { title: '首页推荐', icon: 'sparkles' }
      },
      {
        path: 'nutrition',
        name: 'admin-nutrition',
        component: () => import('@/views/admin/AdminNutritionView.vue'),
        meta: { title: '营养信息', icon: 'flame' }
      },
      {
        path: 'statistics',
        name: 'admin-statistics',
        component: () => import('@/views/admin/AdminStatisticsView.vue'),
        meta: { title: '数据统计', icon: 'bar-chart' }
      },
      {
        path: 'admins',
        name: 'admin-admins',
        component: () => import('@/views/admin/AdminAdminsView.vue'),
        meta: { title: '管理员与权限', icon: 'shield' }
      },
      {
        path: 'ai-config',
        name: 'admin-ai-config',
        component: () => import('@/views/admin/AdminAiConfigView.vue'),
        meta: { title: 'AI 服务配置', icon: 'robot' }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/views/common/NotFoundView.vue'),
    meta: { title: '页面不存在', public: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})

router.beforeEach(async (to) => {
  if (to.meta.requiresAdmin) {
    const adminAuth = useAdminAuthStore()
    const ok = await adminAuth.restoreSession()
    if (!ok) {
      return { name: 'admin-login', query: { redirect: to.fullPath } }
    }
  }
  if (to.name === 'admin-login') {
    const adminAuth = useAdminAuthStore()
    const ok = await adminAuth.restoreSession()
    if (ok) {
      return { path: '/admin/dashboard' }
    }
  }
  return true
})

router.afterEach((to) => {
  const title = (to.meta.title as string) || '智慧食堂'
  document.title = `${title} · 智慧食堂`
})

export default router
