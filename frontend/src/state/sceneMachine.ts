/**
 * 场景状态机（sceneState 是视频/场景的唯一依据）
 *
 * 设计要点：
 * 1. 组件不得直接修改 sceneState，只能通过 dispatch(action)。
 * 2. 每段视频的 ended 回调都必须校验「当前 sceneState + videoId」，防止旧事件误触发。
 * 3. 播放动作幂等：同一状态重复点击不会重复启动同一段视频。
 * 4. activePanel 只表示 UI 面板，不决定视频状态。
 *
 * 本轮流程（按需求）：
 *   点结算 → 播 005 → 播完停在服务员放盘子的画面（右侧仍是点餐 UI）
 *   → 点任意导航 → 播 006 → 播完进入 EATING，循环 008
 *   → EATING 时人物在右、左侧空 → 点餐 UI 显示在左侧
 *   → EATING 时点结算 → 拒绝下单
 */
import type { SceneVideoId } from '@/config/media'

export type SceneState =
  | 'INTRO_PLAYING'
  | 'LOGIN_REQUIRED'
  | 'ENTERING'
  | 'SEATING'
  | 'HOME_IDLE'
  | 'MENU_TRANSITION'
  | 'MENU_OPEN'
  | 'MENU_EXITING'
  | 'CHECKOUT_OPEN'
  | 'DELIVERY'
  | 'DELIVERY_HOLD'
  | 'EATING_TRANSITION'
  | 'EATING'

export type ActivePanel = 'home' | 'menu' | 'order' | 'favorites' | 'nutrition'

export type OrderStatus = 'none' | 'cart_only' | 'submitted' | 'delivered' | 'eating'

/** 用餐冷却时长（分钟），可配置常量，不散落魔法数字 */
export const DINING_COOLDOWN_MINUTES = 10

/** 场景状态 -> 视频 */
export const SCENE_VIDEO_MAP: Record<SceneState, SceneVideoId | null> = {
  INTRO_PLAYING: '001-1',
  LOGIN_REQUIRED: null,
  ENTERING: '002-1',
  SEATING: '003-1',
  HOME_IDLE: '007-1',
  MENU_TRANSITION: '004-1',
  MENU_OPEN: null,
  MENU_EXITING: '004-1-reverse',
  CHECKOUT_OPEN: null,
  DELIVERY: '005-1',
  DELIVERY_HOLD: null,
  EATING_TRANSITION: '006-1',
  EATING: '008-1'
}

/** 稳态循环视频所在状态 */
export const LOOP_STATES: SceneState[] = ['HOME_IDLE', 'EATING']

/** 叙事过渡状态（视频只播一次，播完必须切换） */
export const TRANSITION_STATES: SceneState[] = [
  'MENU_TRANSITION',
  'MENU_EXITING',
  'DELIVERY',
  'EATING_TRANSITION',
  'ENTERING',
  'SEATING'
]

/** 用餐态（人物在吃饭，点餐 UI 在左侧） */
export const DINING_STATES: SceneState[] = ['DELIVERY_HOLD', 'EATING_TRANSITION', 'EATING']

/** 稳态末帧（用海报帧垫底，避免黑屏） */
export const STILL_FRAME_MAP: Partial<Record<SceneState, SceneVideoId>> = {
  MENU_OPEN: '004-1',
  CHECKOUT_OPEN: '004-1',
  DELIVERY_HOLD: '005-1'
}

export interface SceneContext {
  sceneState: SceneState
  activePanel: ActivePanel
  orderStatus: OrderStatus
  currentOrderId: number | null
  checkoutOpen: boolean
  /** MENU_EXITING 结束后要切到的目标面板 */
  pendingPanel: ActivePanel | null
  /** EATING_TRANSITION 结束后要切到的目标面板 */
  pendingEatingPanel: ActivePanel | null
  submittedOrderNo: string | null
  videoError: string | null
  loggedIn: boolean
  /** 用餐冷却截止时间戳（毫秒），null 表示未在冷却 */
  diningCooldownUntil: number | null
}

export type SceneAction =
  | { type: 'INTRO_ENDED' }
  | { type: 'LOGIN_SUCCESS' }
  | { type: 'ENTERING_ENDED' }
  | { type: 'SEATING_ENDED' }
  | { type: 'OPEN_MENU' }
  | { type: 'MENU_ENTERED' }
  | { type: 'GO_PANEL'; panel: ActivePanel }
  | { type: 'MENU_EXITED' }
  | { type: 'OPEN_CHECKOUT' }
  | { type: 'CLOSE_CHECKOUT' }
  | { type: 'ORDER_SUBMITTED'; orderId: number; orderNo: string }
  | { type: 'DELIVERY_ENDED' }
  | { type: 'START_EATING'; panel?: ActivePanel }
  | { type: 'EATING_ENTERED' }
  | { type: 'CLEAR_COOLDOWN' }
  | { type: 'VIDEO_ERROR'; message: string }
  | { type: 'CLEAR_VIDEO_ERROR' }
  | { type: 'RESTORE'; context: Partial<SceneContext> }
  | { type: 'RESET' }
  | { type: 'LOGOUT' }

export function createInitialContext(): SceneContext {
  return {
    sceneState: 'INTRO_PLAYING',
    activePanel: 'home',
    orderStatus: 'none',
    currentOrderId: null,
    checkoutOpen: false,
    pendingPanel: null,
    pendingEatingPanel: null,
    submittedOrderNo: null,
    videoError: null,
    loggedIn: false,
    diningCooldownUntil: null
  }
}

/** 是否处于用餐态 */
export function isDining(state: SceneState): boolean {
  return DINING_STATES.includes(state)
}

/** 是否转场中（拦截重复点击） */
export function isTransitioning(state: SceneState): boolean {
  return TRANSITION_STATES.includes(state)
}

/** 是否处于点餐场景（含结算弹窗） */
export function isMenuScene(state: SceneState): boolean {
  return state === 'MENU_OPEN' || state === 'CHECKOUT_OPEN'
}

/** 冷却是否生效 */
export function isCooldownActive(ctx: SceneContext, now = Date.now()): boolean {
  return ctx.diningCooldownUntil !== null && now < ctx.diningCooldownUntil
}

/** 冷却剩余分钟（向上取整） */
export function cooldownRemainingMinutes(ctx: SceneContext, now = Date.now()): number {
  if (ctx.diningCooldownUntil === null) {
    return 0
  }
  return Math.max(0, Math.ceil((ctx.diningCooldownUntil - now) / 60000))
}

export function sceneReducer(state: SceneContext, action: SceneAction): SceneContext {
  switch (action.type) {
    case 'INTRO_ENDED':
      return state.sceneState === 'INTRO_PLAYING'
        ? { ...state, sceneState: 'LOGIN_REQUIRED' }
        : state

    case 'LOGIN_SUCCESS': {
      const settled: SceneState[] = ['ENTERING', 'SEATING', 'HOME_IDLE', 'MENU_TRANSITION', 'MENU_OPEN',
        'MENU_EXITING', 'CHECKOUT_OPEN', 'DELIVERY', 'DELIVERY_HOLD', 'EATING_TRANSITION', 'EATING']
      if (settled.includes(state.sceneState)) {
        return { ...state, loggedIn: true }
      }
      return { ...state, sceneState: 'ENTERING', loggedIn: true, videoError: null }
    }

    case 'ENTERING_ENDED':
      return state.sceneState === 'ENTERING' ? { ...state, sceneState: 'SEATING' } : state

    case 'SEATING_ENDED':
      return state.sceneState === 'SEATING'
        ? { ...state, sceneState: 'HOME_IDLE', activePanel: 'home' }
        : state

    /** 首页/任意面板点击「点餐」：进入 004-1 转场 */
    case 'OPEN_MENU':
      if (isTransitioning(state.sceneState)) {
        return state
      }
      if (state.sceneState === 'MENU_OPEN' || state.sceneState === 'CHECKOUT_OPEN') {
        return { ...state, activePanel: 'menu' }
      }
      return {
        ...state,
        sceneState: 'MENU_TRANSITION',
        activePanel: 'menu',
        checkoutOpen: false
      }

    case 'MENU_ENTERED':
      return state.sceneState === 'MENU_TRANSITION'
        ? { ...state, sceneState: 'MENU_OPEN', activePanel: 'menu' }
        : state

    /**
     * 导航统一入口。
     * - DELIVERY_HOLD：点任意导航 → 播 006（EATING_TRANSITION）
     * - MENU_OPEN/CHECKOUT_OPEN：播 004-1-reverse 回退
     * - EATING：仅切面板，背景保持 008 循环
     * - 其他：直接切面板
     */
    case 'GO_PANEL': {
      if (isTransitioning(state.sceneState)) {
        return state
      }
      // 送达停留：点任意导航都触发 006 视角转换
      if (state.sceneState === 'DELIVERY_HOLD') {
        // 同理：立即显示目标面板，006 视角转换在后台播放
        return {
          ...state,
          sceneState: 'EATING_TRANSITION',
          activePanel: action.panel,
          pendingEatingPanel: action.panel,
          checkoutOpen: false
        }
      }
      if (state.sceneState === 'MENU_OPEN' || state.sceneState === 'CHECKOUT_OPEN') {
        // 立即切到目标面板：UI 马上出现，004-1-reverse 只在后台播放视角回退，
        // 不必等转场结束（否则用户点导航后要干等 5 秒才看到页面）
        return {
          ...state,
          sceneState: 'MENU_EXITING',
          activePanel: action.panel,
          pendingPanel: action.panel,
          checkoutOpen: false
        }
      }
      // 用餐态 / 其他：切面板，背景不变
      return { ...state, activePanel: action.panel, checkoutOpen: false }
    }

    case 'MENU_EXITED': {
      if (state.sceneState !== 'MENU_EXITING') {
        return state
      }
      const target = state.pendingPanel ?? 'home'
      return {
        ...state,
        sceneState: 'HOME_IDLE',
        activePanel: target,
        pendingPanel: null
      }
    }

    case 'OPEN_CHECKOUT':
      if (state.sceneState !== 'MENU_OPEN') {
        return state
      }
      return { ...state, sceneState: 'CHECKOUT_OPEN', checkoutOpen: true }

    case 'CLOSE_CHECKOUT':
      if (state.sceneState !== 'CHECKOUT_OPEN') {
        return state
      }
      return { ...state, sceneState: 'MENU_OPEN', checkoutOpen: false }

    /** 下单成功：进入 DELIVERY 播 005，点餐面板保持可见 */
    case 'ORDER_SUBMITTED':
      return {
        ...state,
        sceneState: 'DELIVERY',
        activePanel: 'menu',
        checkoutOpen: false,
        orderStatus: 'submitted',
        currentOrderId: action.orderId,
        submittedOrderNo: action.orderNo,
        videoError: null
      }

    /** 005 播完：停在服务员放盘子的画面，右侧仍是点餐 UI，等用户点导航 */
    case 'DELIVERY_ENDED':
      if (state.sceneState !== 'DELIVERY') {
        return state
      }
      return {
        ...state,
        sceneState: 'DELIVERY_HOLD',
        activePanel: 'menu',
        orderStatus: 'delivered'
      }

    /** 兼容：外部直接触发开始用餐 */
    case 'START_EATING':
      if (state.sceneState !== 'DELIVERY_HOLD' && state.sceneState !== 'DELIVERY') {
        return state
      }
      return {
        ...state,
        sceneState: 'EATING_TRANSITION',
        pendingEatingPanel: action.panel ?? 'home'
      }

    /** 006 播完：进入 EATING，循环 008，切到目标面板 */
    case 'EATING_ENTERED':
      if (state.sceneState !== 'EATING_TRANSITION') {
        return state
      }
      return {
        ...state,
        sceneState: 'EATING',
        activePanel: state.pendingEatingPanel ?? 'home',
        pendingEatingPanel: null,
        orderStatus: 'eating',
        diningCooldownUntil: Date.now() + DINING_COOLDOWN_MINUTES * 60 * 1000
      }

    case 'CLEAR_COOLDOWN':
      return { ...state, diningCooldownUntil: null }

    case 'VIDEO_ERROR':
      return { ...state, videoError: action.message }

    case 'CLEAR_VIDEO_ERROR':
      return { ...state, videoError: null }

    case 'RESTORE':
      return { ...state, ...action.context }

    case 'RESET':
      return createInitialContext()

    case 'LOGOUT':
      return { ...createInitialContext(), sceneState: 'LOGIN_REQUIRED' }

    default:
      return state
  }
}

/** 状态中文标签（调试/自测用） */
export const SCENE_LABELS: Record<SceneState, string> = {
  INTRO_PLAYING: '001-1 走向食堂',
  LOGIN_REQUIRED: '门口 · 等待登录',
  ENTERING: '002-1 推门进入',
  SEATING: '003-1 走向座位',
  HOME_IDLE: '已落座 · 空桌',
  MENU_TRANSITION: '004-1 切换到菜单视角',
  MENU_OPEN: '俯视点餐',
  MENU_EXITING: '004-1-reverse 退出菜单',
  CHECKOUT_OPEN: '结算确认',
  DELIVERY: '005-1 送餐中',
  DELIVERY_HOLD: '餐已送达 · 等待进入用餐',
  EATING_TRANSITION: '006-1 视角转换',
  EATING: '用餐中 · 008 循环'
}

/** 是否需要显示完整业务 UI */
export function shouldShowBusinessUI(state: SceneState): boolean {
  return !['INTRO_PLAYING', 'LOGIN_REQUIRED', 'ENTERING', 'SEATING'].includes(state)
}

/**
 * 点餐面板是否可见。
 *
 * 注意：DELIVERY（005 播放中）**不显示**点餐面板 —— 下单后 UI 暂时消失，
 * 让 005 送餐动画完整呈现；005 播完进入 DELIVERY_HOLD 定格后，面板才淡入出现。
 */
/** 转场期间是否需要在后台播放视频（UI 不受影响） */
export function isBackgroundTransition(state: SceneState): boolean {
  return state === 'MENU_EXITING' || state === 'EATING_TRANSITION'
}

export function isMenuPanelVisible(state: SceneState): boolean {
  return (
    state === 'MENU_OPEN' ||
    state === 'CHECKOUT_OPEN' ||
    state === 'DELIVERY_HOLD' ||
    state === 'EATING'
  )
}

/**
 * 点餐面板是否在左侧。
 *
 * 只有真正进入用餐视角（006 播完、循环 008 吃饭）后，人物在右侧吃饭、
 * 左侧留白，此时点餐 UI 才移到左边，避免挡住人物。
 * DELIVERY_HOLD（005 刚播完、服务员放盘子）保持下单时的右侧位置不变。
 */
export function isMenuPanelLeft(state: SceneState): boolean {
  return state === 'EATING'
}
