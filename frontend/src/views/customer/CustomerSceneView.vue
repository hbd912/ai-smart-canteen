<script setup lang="ts">
/**
 * 用户端主场景：视频叙事 + UI 叠加层。
 *
 * 职责：
 * 1. 驱动 SceneVideoController（全部视频的唯一播放者，组件不直接操作 video）
 * 2. 把视频 ended 事件转换为状态机 action（真实 ended 驱动，不用 setTimeout 猜测）
 * 3. 统一处理导航点击（严格遵循状态机规则）
 * 4. 与后端同步业务事实（订单、购物车、收藏、营养）
 *
 * 视频编排：
 * - 001/002/003/004/005/006 为叙事过渡，只播一次
 * - 004-1-reverse 为预生成反向视频，用于俯视 -> 侧面回退
 * - 007-1 在 HOME_IDLE 循环，008-1 在 EATING 循环
 */
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import SceneBackground from '@/scene/SceneBackground.vue'
import { useSceneVideoController } from '@/scene/useSceneVideoController'
import TopBar from '@/components/layout/TopBar.vue'
import SideNavigation from '@/components/layout/SideNavigation.vue'
import NotificationDrawer from '@/components/layout/NotificationDrawer.vue'
import SoundToggle from '@/components/layout/SoundToggle.vue'
import AuthPanel from '@/components/auth/AuthPanel.vue'
import HomeDashboard from '@/components/home/HomeDashboard.vue'
import MenuPanel from '@/components/menu/MenuPanel.vue'
import DishDetailModal from '@/components/menu/DishDetailModal.vue'
import CheckoutModal from '@/components/menu/CheckoutModal.vue'
import ReviewCenter from '@/components/order/ReviewCenter.vue'
import OrderPanel from '@/components/order/OrderPanel.vue'
import FavoritesPanel from '@/components/order/FeaturedPanel.vue'
import NutritionPanel from '@/components/order/NutritionPanel.vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { useSceneStore } from '@/stores/scene'
import { useAuthStore } from '@/stores/auth'
import { useCartStore } from '@/stores/cart'
import { useFavoriteStore } from '@/stores/favorites'
import { useToastStore } from '@/stores/toast'
import { useAudioUnlock } from '@/composables/useAudioUnlock'
import { usePingPongVideo } from '@/composables/usePingPongVideo'
import { orderApi } from '@/api/modules'
import { PING_PONG_PAIR, SCENE_VIDEOS, type SceneVideoId } from '@/config/media'
import { shouldShowBusinessUI, type ActivePanel } from '@/state/sceneMachine'
import type { Category, Dish, Order } from '@/types/api'

const router = useRouter()
const scene = useSceneStore()
const auth = useAuthStore()
const cart = useCartStore()
const favorites = useFavoriteStore()
const toast = useToastStore()
const audio = useAudioUnlock()

const controller = useSceneVideoController()
/** HOME_IDLE 时用 007 正放 <-> 倒放往返循环 */
const pingPong = usePingPongVideo({
  forwardSrc: PING_PONG_PAIR.forward,
  reverseSrc: PING_PONG_PAIR.reverse,
  tailSeconds: 0.6,
  fadeMs: 250
})

// ---------------------------------------------------------------
// 数据状态
// ---------------------------------------------------------------
const currentOrder = ref<Order | null>(null)
const detailDish = ref<Dish | null>(null)
const menuCategoryId = ref<number | null>(null)
const submitting = ref(false)
const checkoutError = ref<string | null>(null)
const booting = ref(true)
const introReady = ref(false)
const navHint = ref<string | null>(null)
const notificationsOpen = ref(false)
const menuRef = ref<InstanceType<typeof MenuPanel> | null>(null)
// 订单页已改为评价中心，不再需要 OrderPanel 实例
const nutritionRef = ref<InstanceType<typeof NutritionPanel> | null>(null)

let navHintTimer = 0

/** 收藏 id 数组（favorites store 内部用 Set） */
const favoriteIds = computed<number[]>(() => Array.from(favorites.ids))

const quantities = computed<Record<number, number>>(() => {
  const map: Record<number, number> = {}
  cart.items.forEach((item) => {
    map[item.dishId] = item.quantity
  })
  return map
})

const showAuth = computed(() => scene.sceneState === 'LOGIN_REQUIRED' && !auth.isLoggedIn)
const showBusinessUI = computed(() => shouldShowBusinessUI(scene.sceneState))
const isEatingScene = computed(() => scene.sceneState === 'EATING')
/** 点餐面板可见：状态允许 且 当前导航停在「点餐」
 *  —— 缺了 activePanel 判断会导致用餐态点其他导航时仍显示点餐页
 */
const isMenuPanelVisible = computed(() => scene.menuPanelVisible && scene.activePanel === 'menu')
/** 用餐态点餐面板在左侧（人物在右） */
const menuPanelLeft = computed(() => scene.menuPanelLeft)
/** 005 播完、停在服务员放盘子画面，等待用户点导航 */
const isDeliveryHold = computed(() => scene.isDeliveryHold)
/** HOME_IDLE 使用 ping-pong 往返；其余状态用普通控制器 */
const isPingPong = computed(() => scene.sceneState === 'HOME_IDLE')

// ---------------------------------------------------------------
// 声音：注册 video 元素
// ---------------------------------------------------------------
const audioCleanups: Array<() => void> = []
let unbindAudioGesture: (() => void) | null = null

// ---------------------------------------------------------------
// 视频编排
// ---------------------------------------------------------------
/** 按当前状态启动播放（DOM 就绪与状态变化都会调用） */
function startPlaybackForCurrentState() {
  // ============ HOME_IDLE：007 正放 <-> 倒放往返 ============
  if (isPingPong.value) {
    if (pingPong.videoA.value && pingPong.videoB.value && !pingPong.playing.value) {
      void pingPong.start()
    }
    return
  }

  // 离开 HOME_IDLE：停掉 ping-pong
  if (pingPong.playing.value) {
    pingPong.pause()
  }

  if (!(controller.layerA.value || controller.layerB.value)) {
    return
  }
  const videoId = scene.currentVideoId
  if (!videoId) {
    // 稳态末帧（DELIVERY_HOLD / MENU_OPEN / CHECKOUT_OPEN）：暂停并保持画面
    controller.pause()
    return
  }
  const mode = scene.shouldLoop ? 'loop' : 'play'
  // 不能只比较 currentVideoId，因为叙事视频播完后 controller 仍记着它，而画面已停在末帧。
  const sameVideo = controller.currentVideoId.value === videoId
  const actuallyPlaying = controller.playing.value
  if (!sameVideo) {
    void controller.load({ videoId, mode })
  } else if (!actuallyPlaying) {
    void controller.load({ videoId, mode, force: true })
  }
}

watch(
  () => [controller.layerA.value, controller.layerB.value, pingPong.videoA.value, pingPong.videoB.value] as const,
  () => {
    startPlaybackForCurrentState()
  }
)

watch(
  () => scene.sceneState,
  () => {
    startPlaybackForCurrentState()
  }
)

/** 普通控制器的 ended -> 状态机 */
controller.onEnded((videoId: SceneVideoId) => {
  if (scene.currentVideoId !== videoId) {
    return
  }
  switch (videoId) {
    case '001-1':
      scene.dispatch({ type: 'INTRO_ENDED' })
      break
    case '002-1':
      scene.dispatch({ type: 'ENTERING_ENDED' })
      break
    case '003-1':
      scene.dispatch({ type: 'SEATING_ENDED' })
      void onSeatingComplete()
      break
    case '004-1':
      scene.dispatch({ type: 'MENU_ENTERED' })
      break
    case '004-1-reverse':
      scene.dispatch({ type: 'MENU_EXITED' })
      break
    case '005-1':
      scene.dispatch({ type: 'DELIVERY_ENDED' })
      void syncOrderStatus('DELIVERED')
      break
    case '006-1':
      scene.dispatch({ type: 'EATING_ENTERED' })
      void syncOrderStatus('EATING')
      break
    default:
      break
  }
})

// ---------------------------------------------------------------
// 生命周期
// ---------------------------------------------------------------
onMounted(async () => {
  audioCleanups.push(audio.register(() => controller.layerA.value))
  audioCleanups.push(audio.register(() => controller.layerB.value))
  audioCleanups.push(audio.register(() => pingPong.videoA.value))
  audioCleanups.push(audio.register(() => pingPong.videoB.value))
  unbindAudioGesture = audio.bindUnlockOnce()

  controller.preload('001-1')
  controller.preload('002-1')
  controller.preload('003-1')
  controller.preload('007-1')
  controller.preload('008-1')

  await boot()
})

onBeforeUnmount(() => {
  window.clearTimeout(navHintTimer)
  unbindAudioGesture?.()
  audioCleanups.forEach((fn) => fn())
  controller.destroy()
  pingPong.destroy()
  scene.stopTick()
})

/** 启动流程 */
async function boot() {
  booting.value = true
  try {
    const loggedIn = await auth.restoreSession()
    if (loggedIn) {
      await Promise.allSettled([cart.refresh(), favorites.refresh()])
      await restoreSceneFromBackend()
    } else {
      scene.dispatch({ type: 'RESTORE', context: { sceneState: 'INTRO_PLAYING', loggedIn: false } })
    }
  } finally {
    booting.value = false
    introReady.value = true
    scene.startTick()
  }
}

/** 刷新恢复：以后端订单事实为准 */
async function restoreSceneFromBackend() {
  let activeOrder: Order | null = null
  try {
    activeOrder = await orderApi.active()
  } catch {
    activeOrder = null
  }
  if (activeOrder) {
    currentOrder.value = activeOrder
    const status = activeOrder.orderStatus
    if (status === 'DELIVERING') {
      scene.dispatch({
        type: 'RESTORE',
        context: {
          sceneState: 'DELIVERY',
          activePanel: 'menu',
          orderStatus: 'submitted',
          currentOrderId: activeOrder.id,
          submittedOrderNo: activeOrder.orderNo,
          loggedIn: true
        }
      })
      return
    }
    // DELIVERED / EATING：用餐态
    scene.dispatch({
      type: 'RESTORE',
      context: {
        sceneState: 'EATING',
        activePanel: 'home',
        orderStatus: 'eating',
        currentOrderId: activeOrder.id,
        submittedOrderNo: activeOrder.orderNo,
        loggedIn: true,
        diningCooldownUntil: scene.context.diningCooldownUntil ?? Date.now() + 10 * 60 * 1000
      }
    })
    return
  }

  scene.dispatch({
    type: 'RESTORE',
    context: {
      sceneState: 'HOME_IDLE',
      activePanel: 'home',
      orderStatus: cart.totalQuantity > 0 ? 'cart_only' : 'none',
      loggedIn: true
    }
  })
}

async function onSeatingComplete() {
  await Promise.allSettled([cart.refresh(), favorites.refresh()])
}

// ---------------------------------------------------------------
// 登录
// ---------------------------------------------------------------
watch(
  () => auth.isLoggedIn,
  (loggedIn) => {
    if (!loggedIn) {
      return
    }
    if (scene.sceneState === 'LOGIN_REQUIRED' || scene.sceneState === 'INTRO_PLAYING') {
      onLoginSuccess()
    }
  }
)

function onLoginSuccess() {
  if (scene.sceneState !== 'LOGIN_REQUIRED' && scene.sceneState !== 'INTRO_PLAYING') {
    return
  }
  scene.dispatch({ type: 'LOGIN_SUCCESS' })
  controller.preload('002-1')
  controller.preload('003-1')
  Promise.allSettled([cart.refresh(), favorites.refresh()])
}

function goAdminEntry() {
  router.push('/admin/login')
}

// ---------------------------------------------------------------
// 导航
// ---------------------------------------------------------------
function onNavigate(panel: ActivePanel) {
  // 转场中拦截
  if (scene.transitioning) {
    showNavHint('镜头切换中，请稍候…')
    return
  }

  // ============ 送达停留（005 播完，画面停在服务员放盘子） ============
  // 按需求：此时点任意导航（含「点餐」本身）都要触发 006 视角转换，
  // 所以必须放在「点当前页无操作」之前判断。
  if (isDeliveryHold.value) {
    scene.dispatch({ type: 'GO_PANEL', panel })
    return
  }

  // ============ 用餐态（008 循环） ============
  if (isEatingScene.value) {
    if (panel === 'menu') {
      // 用餐态点餐面板显示在左侧：先切面板，再提示冷却（不能下单）
      scene.dispatch({ type: 'GO_PANEL', panel: 'menu' })
      showEatingBlockHint()
      return
    }
    // 其他导航：直接切面板，背景保持 008 循环
    scene.dispatch({ type: 'GO_PANEL', panel })
    if (panel === 'order') {
      void 0
    }
    return
  }

  // ============ 点餐场景（俯视） ============
  if (scene.menuScene) {
    if (panel === 'menu') {
      return
    }
    // 播 004-1-reverse 回退
    scene.dispatch({ type: 'GO_PANEL', panel })
    return
  }

  // ============ 其他面板之间切换 ============
  // 点当前页：无操作
  if (scene.activePanel === panel) {
    return
  }

  // 点「点餐」：播 004-1 进入俯视视角
  if (panel === 'menu') {
    scene.dispatch({ type: 'OPEN_MENU' })
    return
  }

  // 直接切面板
  scene.dispatch({ type: 'GO_PANEL', panel })
  if (panel === 'order') {
    void 0
  }
}

function showEatingBlockHint() {
  if (scene.cooldownActive) {
    showNavHint(`正在用餐，请珍惜粮食，冷却 ${scene.cooldownMinutes} 分钟后可再次点餐，请勿浪费食物`)
  } else {
    showNavHint('正在用餐，请珍惜粮食，请勿浪费食物')
  }
}

function showNavHint(message: string) {
  navHint.value = message
  window.clearTimeout(navHintTimer)
  navHintTimer = window.setTimeout(() => {
    navHint.value = null
  }, 3200)
}

function openCategory(category: Category | null) {
  menuCategoryId.value = category ? category.id : null
  if (!scene.menuScene) {
    scene.dispatch({ type: 'OPEN_MENU' })
  }
}

// ---------------------------------------------------------------
// 购物车与收藏
// ---------------------------------------------------------------
async function addToCart(dish: Dish) {
  try {
    await cart.add(dish.id, 1)
    toast.success(`已加入 ${dish.name}`, isEatingScene.value ? '用餐中仍可继续加购' : '结算后才会送餐')
  } catch (e) {
    toast.error('加入购物车失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

async function increaseDish(dish: Dish) {
  const itemId = cart.itemIdOf(dish.id)
  if (!itemId) {
    await addToCart(dish)
    return
  }
  const current = cart.quantityOf(dish.id)
  if (current >= 99) {
    toast.warning('单道菜最多 99 份')
    return
  }
  try {
    await cart.updateQuantity(itemId, current + 1)
  } catch (e) {
    toast.error('数量更新失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

async function decreaseDish(dish: Dish) {
  const itemId = cart.itemIdOf(dish.id)
  if (!itemId) {
    return
  }
  try {
    await cart.updateQuantity(itemId, Math.max(cart.quantityOf(dish.id) - 1, 0))
  } catch (e) {
    toast.error('数量更新失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

async function removeCartItem(itemId: number) {
  try {
    await cart.remove(itemId)
  } catch (e) {
    toast.error('移除失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

async function updateCartQuantity(itemId: number, quantity: number) {
  try {
    await cart.updateQuantity(itemId, quantity)
  } catch (e) {
    toast.error('数量更新失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

async function toggleFavorite(dish: Dish) {
  try {
    const added = await favorites.toggle(dish.id)
    toast.success(added ? `已收藏 ${dish.name}` : `已取消收藏 ${dish.name}`)
  } catch (e) {
    toast.error('收藏失败', e instanceof Error ? e.message : '请稍后重试')
  }
}

function onOrderDishFromWork(dishId: number) {
  // 从精选作品 / AI 营养建议跳转到点餐页
  if (!scene.menuScene && !scene.dining) {
    scene.dispatch({ type: 'OPEN_MENU' })
  } else if (scene.activePanel !== 'menu') {
    scene.dispatch({ type: 'GO_PANEL', panel: 'menu' })
  }
  showNavHint('已切换到点餐，找到这道菜就可以直接加购啦')
  void dishId
}

function openDishDetail(dish: Dish) {
  detailDish.value = dish
}

// ---------------------------------------------------------------
// 结算
// ---------------------------------------------------------------
function openCheckout() {
  // 用餐态（含 005 送达停留、008 用餐循环）：一律拒绝下单
  if (isEatingScene.value || isDeliveryHold.value) {
    showEatingBlockHint()
    return
  }
  if (cart.totalQuantity === 0) {
    toast.warning('还没有选择菜品', '先挑几道喜欢的菜吧')
    return
  }
  checkoutError.value = null
  scene.dispatch({ type: 'OPEN_CHECKOUT' })
}

function closeCheckout() {
  checkoutError.value = null
  scene.dispatch({ type: 'CLOSE_CHECKOUT' })
}

async function confirmOrder() {
  if (submitting.value) {
    return
  }
  submitting.value = true
  checkoutError.value = null
  const idempotencyKey = `c-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`
  try {
    const order = await orderApi.create({ idempotencyKey })
    currentOrder.value = order
    scene.dispatch({ type: 'ORDER_SUBMITTED', orderId: order.id, orderNo: order.orderNo })
    toast.success('下单成功', `订单号 ${order.orderNo}（课堂演示订单，未发生真实支付）`)
    controller.preload('005-1')
    controller.preload('006-1')
    controller.preload('008-1')
    await cart.refresh()
    void syncOrderStatus('DELIVERING')
  } catch (e) {
    const message = e instanceof Error ? e.message : '下单失败，请稍后重试'
    checkoutError.value = message
    toast.error('下单失败', message)
  } finally {
    submitting.value = false
  }
}

async function syncOrderStatus(status: string) {
  const orderId = currentOrder.value?.id
  if (!orderId) {
    return
  }
  try {
    currentOrder.value = await orderApi.syncSceneStatus(orderId, status)
  } catch {
    /* ignore */
  }
}

// ---------------------------------------------------------------
// 视频层
// ---------------------------------------------------------------
function onVideoAttach(slot: 'A' | 'B', el: HTMLVideoElement | null) {
  if (isPingPong.value) {
    pingPong.attach(slot, el)
  } else {
    controller.attach(slot, el)
  }
}

function retryVideo() {
  scene.dispatch({ type: 'CLEAR_VIDEO_ERROR' })
  controller.retry()
}

const videoError = computed(() => controller.error.value || pingPong.error.value || scene.videoError)

// ---------------------------------------------------------------
// 顶部栏
// ---------------------------------------------------------------
const unreadCount = ref(3)

function openNotifications() {
  notificationsOpen.value = true
}

function onProfile() {
  scene.dispatch({ type: 'GO_PANEL', panel: 'nutrition' })
}

function onChangePassword() {
  toast.info('修改密码（演示）', '课堂演示环境未接入真实改密接口，请联系管理员重置。')
}

async function onLogout() {
  await auth.logout()
  cart.resetLocal()
  favorites.resetLocal()
  currentOrder.value = null
  notificationsOpen.value = false
  scene.reset()
  scene.dispatch({ type: 'RESTORE', context: { sceneState: 'LOGIN_REQUIRED', loggedIn: false } })
  toast.info('已退出登录', '已返回门口，可重新登录体验')
}

const currentVideoLabel = computed(() => {
  const id = controller.currentVideoId.value
  return id ? SCENE_VIDEOS[id].label : ''
})
const canSkipIntro = computed(() =>
  ['INTRO_PLAYING', 'ENTERING', 'SEATING', 'DELIVERY', 'MENU_TRANSITION', 'MENU_EXITING', 'EATING_TRANSITION']
    .includes(scene.sceneState)
)

function skipVideo() {
  const el = controller.activeSlot.value === 'A' ? controller.layerA.value : controller.layerB.value
  if (!el) {
    return
  }
  try {
    el.currentTime = Math.max(el.duration - 0.08, 0)
  } catch {
    /* ignore */
  }
}
</script>

<template>
  <div
    class="scene-view"
    :data-scene="scene.sceneState"
    :data-panel="scene.activePanel"
    :data-pp-phase="isPingPong ? pingPong.phase.value : undefined"
  >
    <!-- 视频背景层 -->
    <SceneBackground
      :ping-pong="isPingPong"
      :active-slot="controller.activeSlot.value"
      :slots="controller.slots.value"
      :still-frame="scene.stillFrameId"
      @attach="onVideoAttach"
      @ended="controller.handleEnded()"
      @timeupdate="controller.handleTimeUpdate"
      @error="controller.handleError"
    />

    <!-- 启动加载 -->
    <Transition name="fade">
      <div v-if="booting || !introReady" class="boot-layer">
        <div class="boot-layer__logo">
          <AppIcon name="leaf" :size="26" />
        </div>
        <p class="boot-layer__text">正在进入智慧食堂…</p>
        <span class="boot-layer__bar"><span class="boot-layer__fill"></span></span>
      </div>
    </Transition>

    <!-- 视频错误 -->
    <Transition name="fade">
      <div v-if="videoError" class="video-error">
        <AppIcon name="alert-triangle" :size="22" />
        <div class="video-error__text">
          <p class="video-error__title">视频播放遇到问题</p>
          <p class="video-error__desc">{{ videoError }}</p>
        </div>
        <button class="btn btn--primary btn--sm" type="button" @click="retryVideo">重试</button>
      </div>
    </Transition>

    <!-- 播放中的品牌标识 -->
    <Transition name="fade">
      <div v-if="scene.sceneState === 'INTRO_PLAYING' && controller.ready.value" class="intro-brand">
        <span class="intro-brand__logo"><AppIcon name="leaf" :size="18" /></span>
        <span class="intro-brand__text">智慧食堂</span>
      </div>
    </Transition>

    <div v-if="showBusinessUI || scene.sceneState === 'INTRO_PLAYING'" class="scene-tools">
      <button v-if="canSkipIntro" class="scene-tool" type="button" aria-label="跳过当前视频" @click="skipVideo">
        <AppIcon name="chevron-right" :size="16" />
        跳过
      </button>
    </div>

    <!-- 业务 UI -->
    <template v-if="showBusinessUI">
      <TopBar
        :unread-count="unreadCount"
        @open-notifications="openNotifications"
        @profile="onProfile"
        @change-password="onChangePassword"
        @logout="onLogout"
      />

      <div class="scene-body">
        <SideNavigation
          :active="scene.activePanel"
          :eating="isEatingScene"
          :cart-count="cart.totalQuantity"
          @select="onNavigate"
        />

        <main class="scene-content">
          <!-- ============ 点餐面板 ============
               MENU_OPEN / CHECKOUT_OPEN / DELIVERY / DELIVERY_HOLD：右侧（保持下单位置）
               EATING：左侧（人物在右吃饭，左侧留白）
               005 播完进入 DELIVERY_HOLD 时，面板做一次淡入出现
          -->
          <Transition name="menu-appear" appear>
            <div
              v-if="isMenuPanelVisible"
              :key="menuPanelLeft ? 'left' : 'right'"
              class="scene-pane"
              :class="menuPanelLeft ? 'scene-pane--menu-left' : 'scene-pane--menu-right'"
            >
              <MenuPanel
                ref="menuRef"
                :quantities="quantities"
                :favorite-ids="favoriteIds"
                  :initial-category-id="menuCategoryId"
                :cart-count="cart.totalQuantity"
                :cart-total="cart.totalAmount"
                :cart-calories="cart.totalCalories"
                :has-unavailable="cart.hasUnavailable"
                :eating="isEatingScene"
                :cooldown-active="scene.cooldownActive"
                :cooldown-minutes="scene.cooldownMinutes"
                @add="addToCart"
                @increase="increaseDish"
                @decrease="decreaseDish"
                @open-dish="openDishDetail"
                @checkout="openCheckout"
                @view-cart="openCheckout"
              />
            </div>
          </Transition>

          <!-- ============ 其他面板 ============ -->
          <div v-if="!isMenuPanelVisible" class="scene-pane scene-pane--left">
            <Transition name="fade" mode="out-in">
              <HomeDashboard
                v-if="scene.activePanel === 'home'"
                key="home"
                :quantities="quantities"
                :favorite-ids="favoriteIds"
                @add="addToCart"
                @increase="increaseDish"
                @decrease="decreaseDish"
                @open-dish="openDishDetail"
                @toggle-favorite="toggleFavorite"
                @open-category="openCategory"
                @open-nutrition="onNavigate('nutrition')"
                @open-orders="onNavigate('order')"
              />
              <section v-else-if="scene.activePanel === 'order'" class="panel-card glass-card scroll-y">
                <header class="panel-head">
                  <div>
                    <h2 class="section-title">
                      <span class="section-title__icon"><AppIcon name="calendar" :size="15" /></span>
                      我的订单
                    </h2>
                    <p class="section-subtitle">按订单明细列出待评价 / 已评价，可直接评价</p>
                  </div>
                </header>
                <ReviewCenter :active="scene.activePanel === 'order'" />
              </section>
              <FavoritesPanel
                v-else-if="scene.activePanel === 'favorites'"
                key="favorites"
                :active="scene.activePanel === 'favorites'"
                @order-dish="onOrderDishFromWork"
              />
              <NutritionPanel
                v-else-if="scene.activePanel === 'nutrition'"
                ref="nutritionRef"
                key="nutrition"
                @order-dish="onOrderDishFromWork"
              />
            </Transition>
          </div>
        </main>
      </div>
    </template>

    <!-- 声音开关：常驻右上角 -->
    <SoundToggle v-if="showBusinessUI" class="sound-anchor" />

    <!-- 登录浮层 -->
    <Transition name="fade">
      <AuthPanel v-if="showAuth" @success="onLoginSuccess" @admin-entry="goAdminEntry" />
    </Transition>

    <!-- 菜品详情 -->
    <DishDetailModal
      :dish="detailDish"
      :quantity="detailDish ? quantities[detailDish.id] || 0 : 0"
      :favorited="detailDish ? favoriteIds.includes(detailDish.id) : false"
      @close="detailDish = null"
      @add="addToCart"
      @increase="increaseDish"
      @decrease="decreaseDish"
      @toggle-favorite="toggleFavorite"
    />

    <!-- 结算 -->
    <CheckoutModal
      :open="scene.checkoutOpen"
      :items="cart.items"
      :total-amount="cart.totalAmount"
      :total-calories="cart.totalCalories"
      :submitting="submitting"
      :error="checkoutError"
      :warnings="cart.warnings"
      @close="closeCheckout"
      @confirm="confirmOrder"
      @update-quantity="updateCartQuantity"
      @remove="removeCartItem"
    />

    <!-- 通知抽屉 -->
    <NotificationDrawer :open="notificationsOpen" @close="notificationsOpen = false" />

    <!-- 导航提示 -->
    <Transition name="toast">
      <div v-if="navHint" class="nav-hint" role="status">
        <AppIcon name="info" :size="15" />
        {{ navHint }}
      </div>
    </Transition>

    <!-- 播放标签 -->
    <div v-if="controller.playing.value && !showBusinessUI" class="video-caption">
      {{ currentVideoLabel }}
    </div>
  </div>
</template>

<style scoped>
.scene-view {
  position: relative;
  width: 100%;
  height: 100vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.sound-anchor {
  position: absolute;
  top: calc(var(--topbar-height) + var(--space-4) + 14px);
  right: var(--space-6);
  z-index: 35;
}

.scene-body {
  position: relative;
  z-index: 20;
  display: flex;
  gap: var(--ui-gap);
  /* 由 flex 自动填充 topbar 之后的剩余高度，避免手算 vh 出错 */
  flex: 1;
  min-height: 0;
  padding: calc(20px * var(--ui-scale)) calc(var(--space-6) * var(--ui-scale)) calc(var(--space-5) * var(--ui-scale));
  align-items: flex-start;
  overflow: hidden;
}

.scene-content {
  flex: 1;
  min-width: 0;
  height: 100%;
  display: flex;
}

.scene-pane {
  height: 100%;
  min-width: 0;
  /* 不在这里裁切：内部各面板（.home-dash / .scroll-y）自己管理滚动 */
  overflow: visible;
}

/* 点餐面板出现/位置切换的淡入淡出（005 播完后面板渐变出现） */
.menu-appear-enter-active {
  transition: opacity var(--motion-slow) var(--ease-standard),
    transform var(--motion-slow) var(--ease-enter);
}

.menu-appear-leave-active {
  transition: opacity var(--motion-normal) var(--ease-standard);
}

.menu-appear-enter-from {
  opacity: 0;
  transform: translateY(10px) scale(0.985);
}

.menu-appear-leave-to {
  opacity: 0;
}

/*
 * 面板宽度策略：以「视频人物安全边界」为准，而不是按视口百分比猜。
 *
 * 视频为 1280x720，object-fit:cover 铺满视口：
 *  - 宽屏（视口比 > 16:9）：宽度铺满，水平不裁切，人物起始于画面 46%
 *  - 窄屏（视口比 < 16:9）：高度铺满，水平裁切，人物会被推到更靠左
 *
 * 因此用 --safe-left 表示「人物开始出现的位置」，面板宽度绝不能超过它，
 * 否则就会盖住人物。这个变量由下面的 calc 按不同视口比例计算。
 */
.scene-view {
  /* 人物起始位置：宽屏 46%，窄屏裁切后约 44%，取保守值 */
  --person-left: 44%;
  /* 面板与人物之间至少留出的空隙 */
  --pane-gap: 24px;

  /*
   * UI 自适应缩放系数：纯数值，供 calc(var(--space-x) * var(--ui-scale)) 使用。
   * 用媒体查询逐档赋值（见下方 @media），避免 clamp/calc 嵌套导致整条声明被丢弃。
   */
  --ui-scale: 1;
  --ui-gap: calc(var(--space-4) * var(--ui-scale));
}

/* 非点餐面板：靠左，宽度不超过人物起点 */
.scene-pane--left {
  width: min(calc(var(--person-left) - var(--pane-gap)), 1080px);
  margin-right: auto;
}

/* 点餐面板（俯视视角）：靠右 */
.scene-pane--menu-right {
  width: min(58vw, 1180px);
  margin-left: auto;
}

/* 点餐面板（用餐态）：靠左，避开右侧人物 */
.scene-pane--menu-left {
  width: min(calc(var(--person-left) - var(--pane-gap)), 980px);
  margin-right: auto;
}

.boot-layer {
  position: absolute;
  inset: 0;
  z-index: 120;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 14px;
  background: radial-gradient(circle at 50% 42%, #fdf8ef, #e9dfcc 72%);
}

.boot-layer__logo {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 62px;
  height: 62px;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--sage-400), var(--sage-600));
  color: #fff;
  box-shadow: 0 10px 26px rgba(95, 120, 80, 0.28);
  animation: scale-in var(--motion-linger) var(--ease-enter) both;
}

.boot-layer__text {
  font-size: var(--font-sm);
  color: var(--ink-500);
  letter-spacing: 0.06em;
}

.boot-layer__bar {
  width: 132px;
  height: 3px;
  border-radius: var(--radius-pill);
  background: rgba(124, 143, 90, 0.2);
  overflow: hidden;
}

.boot-layer__fill {
  display: block;
  width: 42%;
  height: 100%;
  border-radius: var(--radius-pill);
  background: var(--sage-500);
  animation: boot-slide 1.5s var(--ease-standard) infinite;
}

@keyframes boot-slide {
  0% {
    transform: translateX(-100%);
  }

  100% {
    transform: translateX(320%);
  }
}

.video-error {
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  z-index: 130;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  border-radius: var(--radius-lg);
  background: rgba(255, 253, 248, 0.97);
  border: 1px solid var(--danger-500);
  box-shadow: var(--shadow-xl);
  color: var(--danger-600);
  max-width: min(460px, 90vw);
}

.video-error__title {
  font-size: var(--font-sm);
  font-weight: 700;
}

.video-error__desc {
  font-size: var(--font-xs);
  color: var(--ink-500);
  margin-top: 2px;
}

.intro-brand {
  position: absolute;
  top: 28px;
  left: 32px;
  z-index: 60;
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 8px 16px 8px 8px;
  border-radius: var(--radius-pill);
  background: rgba(255, 253, 248, 0.82);
  backdrop-filter: blur(12px);
  box-shadow: var(--shadow-md);
}

.intro-brand__logo {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: linear-gradient(140deg, var(--sage-400), var(--sage-600));
  color: #fff;
}

.intro-brand__text {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--sage-800);
  letter-spacing: 0.04em;
}

.scene-tools {
  position: absolute;
  right: 28px;
  bottom: 22px;
  z-index: 60;
  display: flex;
  gap: 8px;
}

.scene-tool {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  height: 30px;
  padding: 0 12px;
  border-radius: var(--radius-pill);
  background: rgba(255, 253, 248, 0.82);
  backdrop-filter: blur(10px);
  color: var(--ink-600);
  font-size: var(--font-xs);
  box-shadow: var(--shadow-sm);
  transition: background-color var(--motion-fast) var(--ease-standard),
    transform var(--motion-fast) var(--ease-standard);
}

.scene-tool:hover {
  background: #fff;
  transform: translateY(-1px);
}

.nav-hint {
  position: fixed;
  left: 50%;
  bottom: 92px;
  transform: translateX(-50%);
  z-index: 300;
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 10px 20px;
  border-radius: var(--radius-pill);
  background: rgba(44, 42, 38, 0.9);
  color: #fff;
  font-size: var(--font-sm);
  box-shadow: var(--shadow-lg);
  max-width: min(680px, 92vw);
  text-align: center;
}

.video-caption {
  position: absolute;
  left: 50%;
  bottom: 24px;
  transform: translateX(-50%);
  z-index: 50;
  padding: 6px 16px;
  border-radius: var(--radius-pill);
  background: rgba(255, 253, 248, 0.7);
  backdrop-filter: blur(8px);
  color: var(--ink-600);
  font-size: var(--font-xs);
  letter-spacing: 0.08em;
}

/* 中屏：收紧间距，让同样的内容占用更少空间 */
@media (max-width: 1439px) {
  .scene-view {
    --ui-scale: 0.96;
  }

  .scene-body {
    padding: 16px var(--space-5) var(--space-4);
    gap: var(--space-4);
  }

  .scene-pane--left {
    width: min(calc(var(--person-left) - 18px), 900px);
  }

  .scene-pane--menu-right {
    width: min(56vw, 980px);
  }

  .scene-pane--menu-left {
    width: min(calc(var(--person-left) - 18px), 820px);
  }
}

@media (max-width: 1180px) {
  .scene-pane--left {
    width: clamp(280px, 62vw, 760px);
  }

  .scene-pane--menu-right {
    width: clamp(300px, 64vw, 820px);
  }

  .scene-pane--menu-left {
    width: clamp(280px, 56vw, 700px);
  }
}

@media (max-width: 1180px) {
  .scene-view {
    --ui-scale: 0.92;
  }

  .scene-body {
    padding: 16px var(--space-4) var(--space-4);
    gap: var(--space-3);
  }

  .scene-pane--left {
    width: clamp(280px, 62vw, 760px);
  }

  .scene-pane--menu-right {
    width: clamp(300px, 64vw, 820px);
  }

  .scene-pane--menu-left {
    width: clamp(280px, 56vw, 700px);
  }
}

@media (max-width: 1023px) {
  .scene-view {
    --ui-scale: 0.9;
  }

  .sound-anchor {
    top: auto;
    bottom: 112px;
    right: 12px;
  }

  .scene-body {
    padding: 12px 12px 76px;
    gap: 0;
  }

  .scene-pane--left,
  .scene-pane--menu-right,
  .scene-pane--menu-left {
    width: 100%;
    margin: 0;
  }

  .scene-tools {
    right: 12px;
    bottom: 112px;
  }
}

@media (max-width: 767px) {
  .nav-hint {
    bottom: 150px;
    font-size: var(--font-xs);
    padding: 8px 16px;
  }
}
</style>
