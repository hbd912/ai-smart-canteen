import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import {
  SCENE_VIDEO_MAP,
  SCENE_LABELS,
  STILL_FRAME_MAP,
  LOOP_STATES,
  cooldownRemainingMinutes,
  createInitialContext,
  isCooldownActive,
  isDining,
  isMenuPanelLeft,
  isMenuPanelVisible,
  isMenuScene,
  isTransitioning,
  sceneReducer,
  shouldShowBusinessUI,
  type ActivePanel,
  type SceneAction,
  type SceneContext,
  type SceneState
} from '@/state/sceneMachine'
import type { SceneVideoId } from '@/config/media'

const STORAGE_KEY = 'canteen.scene.v2'

interface PersistedScene {
  sceneState: SceneState
  activePanel: ActivePanel
  orderStatus: SceneContext['orderStatus']
  currentOrderId: number | null
  submittedOrderNo: string | null
  diningCooldownUntil: number | null
}

/**
 * 场景状态 Store。
 * - sceneState 只能通过 dispatch 修改（reducer 内部保证幂等与合法性）
 * - 持久化仅保存"展示阶段"，订单事实仍以后端为准
 */
export const useSceneStore = defineStore('scene', () => {
  const context = ref<SceneContext>(createInitialContext())
  const nowTick = ref(Date.now())
  let tickTimer = 0
  /** 用餐冷却结束时通知外部（订单需推进为 COMPLETED），携带到期前的订单号 */
  const diningFinishedHandlers = new Set<(orderId: number) => void>()

  function onDiningFinished(handler: (orderId: number) => void) {
    diningFinishedHandlers.add(handler)
    return () => diningFinishedHandlers.delete(handler)
  }

  function startTick() {
    if (tickTimer) {
      return
    }
    tickTimer = window.setInterval(() => {
      nowTick.value = Date.now()
      if (context.value.diningCooldownUntil !== null && nowTick.value >= context.value.diningCooldownUntil) {
        // CLEAR_COOLDOWN 会清空 currentOrderId，先取出来再切换回 HOME_IDLE
        const orderId = context.value.currentOrderId
        dispatch({ type: 'CLEAR_COOLDOWN' })
        if (orderId !== null) {
          diningFinishedHandlers.forEach((handler) => handler(orderId))
        }
      }
    }, 1000)
  }

  function stopTick() {
    if (tickTimer) {
      window.clearInterval(tickTimer)
      tickTimer = 0
    }
  }

  const currentVideoId = computed<SceneVideoId | null>(() => SCENE_VIDEO_MAP[context.value.sceneState])
  const stillFrameId = computed<SceneVideoId | null>(() => STILL_FRAME_MAP[context.value.sceneState] ?? null)
  const sceneState = computed(() => context.value.sceneState)
  const activePanel = computed(() => context.value.activePanel)
  const orderStatus = computed(() => context.value.orderStatus)
  const checkoutOpen = computed(() => context.value.checkoutOpen)
  const videoError = computed(() => context.value.videoError)
  const currentOrderId = computed(() => context.value.currentOrderId)
  const submittedOrderNo = computed(() => context.value.submittedOrderNo)
  const sceneLabel = computed(() => SCENE_LABELS[context.value.sceneState])

  const shouldLoop = computed(() => LOOP_STATES.includes(context.value.sceneState))
  const transitioning = computed(() => isTransitioning(context.value.sceneState))
  const dining = computed(() => isDining(context.value.sceneState))
  const menuScene = computed(() => isMenuScene(context.value.sceneState))
  /** 点餐面板是否可见（MENU_TRANSITION / MENU_OPEN / CHECKOUT_OPEN / DELIVERY_HOLD / EATING） */
  const menuPanelVisible = computed(() => isMenuPanelVisible(context.value.sceneState))
  /** 点餐面板是否在左侧（用餐态） */
  const menuPanelLeft = computed(() => isMenuPanelLeft(context.value.sceneState))
  const isDeliveryHold = computed(() => context.value.sceneState === 'DELIVERY_HOLD')
  const showBusinessUI = computed(() => shouldShowBusinessUI(context.value.sceneState))

  const cooldownActive = computed(() => isCooldownActive(context.value, nowTick.value))
  const cooldownMinutes = computed(() => cooldownRemainingMinutes(context.value, nowTick.value))

  function dispatch(action: SceneAction) {
    context.value = sceneReducer(context.value, action)
    persist()
  }

  function persist() {
    try {
      const payload: PersistedScene = {
        sceneState: context.value.sceneState,
        activePanel: context.value.activePanel,
        orderStatus: context.value.orderStatus,
        currentOrderId: context.value.currentOrderId,
        submittedOrderNo: context.value.submittedOrderNo,
        diningCooldownUntil: context.value.diningCooldownUntil
      }
      sessionStorage.setItem(STORAGE_KEY, JSON.stringify(payload))
    } catch {
      /* ignore */
    }
  }

  function readPersisted(): PersistedScene | null {
    try {
      const raw = sessionStorage.getItem(STORAGE_KEY)
      if (!raw) {
        return null
      }
      return JSON.parse(raw) as PersistedScene
    } catch {
      return null
    }
  }

  function clearPersisted() {
    try {
      sessionStorage.removeItem(STORAGE_KEY)
      sessionStorage.removeItem('canteen.scene.v1')
      sessionStorage.removeItem('canteen.scene.v3')
    } catch {
      /* ignore */
    }
  }

  function restore(patch: Partial<SceneContext>) {
    const persisted = readPersisted()
    const base: Partial<SceneContext> = {}
    if (persisted) {
      base.sceneState = persisted.sceneState
      base.activePanel = persisted.activePanel
      base.orderStatus = persisted.orderStatus
      base.currentOrderId = persisted.currentOrderId
      base.submittedOrderNo = persisted.submittedOrderNo
      base.diningCooldownUntil = persisted.diningCooldownUntil ?? null
    }
    dispatch({ type: 'RESTORE', context: { ...base, ...patch } })
  }

  function reset() {
    clearPersisted()
    dispatch({ type: 'RESET' })
  }

  return {
    context,
    nowTick,
    sceneState,
    activePanel,
    orderStatus,
    checkoutOpen,
    videoError,
    currentOrderId,
    submittedOrderNo,
    sceneLabel,
    currentVideoId,
    stillFrameId,
    shouldLoop,
    transitioning,
    dining,
    menuScene,
    menuPanelVisible,
    menuPanelLeft,
    isDeliveryHold,
    showBusinessUI,
    cooldownActive,
    cooldownMinutes,
    dispatch,
    onDiningFinished,
    startTick,
    stopTick,
    restore,
    reset,
    readPersisted
  }
})
