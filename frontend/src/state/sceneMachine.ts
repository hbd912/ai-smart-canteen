/**
 * 场景状态机（sceneState 是视频/场景的唯一依据）
 *
 * 设计要点：
 * 1. 组件不得直接修改 sceneState，只能通过 dispatch(action)。
 * 2. 每段视频的 ended 回调都必须校验「当前 sceneState + videoId」，防止旧事件误触发。
 * 3. 播放动作幂等：同一状态重复点击不会重复启动同一段视频。
 * 4. activePanel 只表示 UI 面板，不决定视频状态。
 * 5. 稳态（HOME_IDLE / EATING）循环播放 007-1 / 008-1，叙事视频只播一次。
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

/** 用餐态（可播放 006 离开） */
export const DINING_STATES: SceneState[] = ['DELIVERY', 'DELIVERY_HOLD', 'EATING_TRANSITION', 'EATING']

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
     * 点餐场景下点击其他导航：播 004-1-reverse 回退，结束后渲染目标面板。
     * 未结算 = 空桌，购物车保留。
     */
    case 'GO_PANEL': {
      if (isTransitioning(state.sceneState)) {
        return state
      }
      if (state.sceneState === 'MENU_OPEN' || state.sceneState === 'CHECKOUT_OPEN') {
        return {
          ...state,
          sceneState: 'MENU_EXITING',
          pendingPanel: action.panel,
          checkoutOpen: false
        }
      }
      // 用餐态：切面板但背景保持
      if (isDining(state.sceneState)) {
        return { ...state, activePanel: action.panel, checkoutOpen: false }
      }
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

    /** 下单成功：进入 DELIVERY 播 005 */
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

    /** 005 播完：停在最后一帧，等用户主动点导航 */
    case 'DELIVERY_ENDED':
      if (state.sceneState !== 'DELIVERY') {
        return state
      }
      return {
        ...state,
        sceneState: 'DELIVERY_HOLD',
        orderStatus: 'delivered'
      }

    /** 用户点击导航：播 006 进入用餐 */
    case 'START_EATING':
      if (state.sceneState !== 'DELIVERY_HOLD' && state.sceneState !== 'DELIVERY') {
        return state
      }
      return {
        ...state,
        sceneState: 'EATING_TRANSITION',
        activePanel: action.panel ?? 'home',
        pendingPanel: action.panel ?? 'home'
      }

    case 'EATING_ENTERED':
      if (state.sceneState !== 'EATING_TRANSITION') {
        return state
      }
      return {
        ...state,
        sceneState: 'EATING',
        activePanel: state.pendingPanel ?? 'home',
        pendingPanel: null,
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
  DELIVERY_HOLD: '餐已送达',
  EATING_TRANSITION: '006-1 视角转换',
  EATING: '用餐中'
}

/** 是否需要显示完整业务 UI */
export function shouldShowBusinessUI(state: SceneState): boolean {
  return !['INTRO_PLAYING', 'LOGIN_REQUIRED', 'ENTERING', 'SEATING'].includes(state)
}

/** 是否可以用餐中点餐提示拦截 */
export function canOpenMenu(state: SceneState): boolean {
  return state === 'MENU_OPEN' || state === 'CHECKOUT_OPEN'
}
