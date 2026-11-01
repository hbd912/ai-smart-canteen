/**
 * 媒体资源配置（唯一来源）
 * 说明：所有路径均为项目内相对路径，禁止出现本机绝对路径。
 * 视频已转码为 H.264 + AAC，保证浏览器兼容；原始素材保留在 Animation/ 目录。
 */

export type SceneVideoId =
  | '001-1'
  | '002-1'
  | '003-1'
  | '004-1'
  | '004-1-reverse'
  | '005-1'
  | '006-1'
  | '007-1'
  | '008-1'

export interface SceneVideoMeta {
  id: SceneVideoId
  src: string
  poster: string
  endPoster: string
  label: string
  /** 该片段对应的业务职责，便于自测与文档对照 */
  purpose: string
  /** 是否为稳态循环动画（只有 HOME_IDLE 与 EATING 使用） */
  loop: boolean
  /** 结尾画面人物主体大致所在区域，用于 UI 避让（百分比） */
  subjectArea: { left: number; right: number; top: number; bottom: number }
}

export const SCENE_VIDEOS: Record<SceneVideoId, SceneVideoMeta> = {
  '001-1': {
    id: '001-1',
    src: '/assets/media/001-1.mp4',
    poster: '/assets/media/frames/001-1-first.webp',
    endPoster: '/assets/media/frames/001-1-last.webp',
    label: '走向食堂',
    purpose: '男主走向食堂门口，结尾停在门口；登录前播放（单次）',
    loop: false,
    subjectArea: { left: 30, right: 62, top: 24, bottom: 100 }
  },
  '002-1': {
    id: '002-1',
    src: '/assets/media/002-1.mp4',
    poster: '/assets/media/frames/002-1-first.webp',
    endPoster: '/assets/media/frames/002-1-last.webp',
    label: '推门而入',
    purpose: '登录成功后播放，男主开门进入食堂（单次）',
    loop: false,
    subjectArea: { left: 20, right: 80, top: 10, bottom: 100 }
  },
  '003-1': {
    id: '003-1',
    src: '/assets/media/003-1.mp4',
    poster: '/assets/media/frames/003-1-first.webp',
    endPoster: '/assets/media/frames/003-1-last.webp',
    label: '落座',
    purpose: '男主走到空座位并坐下；结束时人物在右侧、左侧留白（单次）',
    loop: false,
    subjectArea: { left: 46, right: 92, top: 8, bottom: 100 }
  },
  '004-1': {
    id: '004-1',
    src: '/assets/media/004-1.mp4',
    poster: '/assets/media/frames/004-1-first.webp',
    endPoster: '/assets/media/frames/004-1-last.webp',
    label: '查看菜单',
    purpose: '镜头由侧面转为俯视，男主在左侧查看菜单（单次）',
    loop: false,
    subjectArea: { left: 2, right: 52, top: 8, bottom: 100 }
  },
  '004-1-reverse': {
    id: '004-1-reverse',
    src: '/assets/media/004-1-reverse.mp4',
    poster: '/assets/media/frames/004-1-last.webp',
    endPoster: '/assets/media/frames/004-1-first.webp',
    label: '退出菜单',
    purpose: '004-1 的预生成反向视频，用于俯视 -> 侧面回退转场（单次）',
    loop: false,
    subjectArea: { left: 2, right: 52, top: 8, bottom: 100 }
  },
  '005-1': {
    id: '005-1',
    src: '/assets/media/005-1.mp4',
    poster: '/assets/media/frames/005-1-first.webp',
    endPoster: '/assets/media/frames/005-1-last.webp',
    label: '服务员送餐',
    purpose: '下单成功后播放，服务员端托盘放餐（单次）；播完停在最后一帧',
    loop: false,
    subjectArea: { left: 4, right: 78, top: 2, bottom: 100 }
  },
  '006-1': {
    id: '006-1',
    src: '/assets/media/006-1.mp4',
    poster: '/assets/media/frames/006-1-first.webp',
    endPoster: '/assets/media/frames/006-1-last.webp',
    label: '视角转换',
    purpose: '离开用餐视角时的转场：俯视 -> 侧面（单次）；播完切目标页',
    loop: false,
    subjectArea: { left: 44, right: 94, top: 6, bottom: 100 }
  },
  '007-1': {
    id: '007-1',
    src: '/assets/media/007-1.mp4',
    poster: '/assets/media/frames/007-1-first.webp',
    endPoster: '/assets/media/frames/007-1-last.webp',
    label: '落座待机',
    purpose: 'HOME_IDLE 稳态循环：男主落座待机，空桌（loop）',
    loop: true,
    subjectArea: { left: 46, right: 92, top: 8, bottom: 100 }
  },
  '008-1': {
    id: '008-1',
    src: '/assets/media/008-1.mp4',
    poster: '/assets/media/frames/008-1-first.webp',
    endPoster: '/assets/media/frames/008-1-last.webp',
    label: '用餐中',
    purpose: 'EATING 稳态循环：男主持续用餐（loop）',
    loop: true,
    subjectArea: { left: 44, right: 94, top: 6, bottom: 100 }
  }
}

/** 叙事过渡视频（只播放一次，不循环） */
export const NARRATIVE_VIDEOS: SceneVideoId[] = [
  '001-1', '002-1', '003-1', '004-1', '004-1-reverse', '005-1', '006-1'
]

/** 稳态循环视频 */
export const LOOP_VIDEOS: SceneVideoId[] = ['007-1', '008-1']

/** 全部视频（用于预加载顺序） */
export const VIDEO_ORDER: SceneVideoId[] = [
  '001-1', '002-1', '003-1', '004-1', '004-1-reverse', '005-1', '006-1', '007-1', '008-1'
]

export const DISH_PLACEHOLDER = '/assets/images/dishes/dish-placeholder.webp'

/** 分类图标（线性 SVG 名称，由 AppIcon 组件渲染） */
export const CATEGORY_ICON_MAP: Record<string, string> = {
  MAIN_MEAL: 'rice-bowl',
  MEAT: 'drumstick',
  VEGETABLE: 'salad',
  NOODLE: 'noodle',
  SOUP: 'soup',
  DRINK: 'cup-soda',
  OTHER: 'utensils'
}

export function categoryIcon(code?: string | null, fallback?: string | null): string {
  if (code && CATEGORY_ICON_MAP[code]) {
    return CATEGORY_ICON_MAP[code]
  }
  return fallback || 'utensils'
}
