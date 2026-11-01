<script setup lang="ts">
/**
 * 通知抽屉：点击铃铛从右侧滑出，展示 Mock 通知列表。
 * 纯前端 Mock，不对接后端接口。
 */
import { computed, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'

const props = defineProps<{ open: boolean }>()
const emit = defineEmits<{ (e: 'close'): void }>()

interface NotificationItem {
  id: number
  type: 'order' | 'notice' | 'stock'
  title: string
  content: string
  time: string
  unread: boolean
}

const items = ref<NotificationItem[]>([
  {
    id: 1,
    type: 'order',
    title: '订单已送达',
    content: '你的订单正在用餐中，记得按需取餐、珍惜粮食。',
    time: '刚刚',
    unread: true
  },
  {
    id: 2,
    type: 'notice',
    title: '食堂公告',
    content: '今日午餐新增「香煎鸡胸藜麦饭」，欢迎到点餐页查看。',
    time: '20 分钟前',
    unread: true
  },
  {
    id: 3,
    type: 'stock',
    title: '库存预警（演示数据）',
    content: '红烧排骨今日剩余不多，售完即止。',
    time: '1 小时前',
    unread: true
  },
  {
    id: 4,
    type: 'notice',
    title: '光盘行动',
    content: '按需取餐、杜绝浪费，光盘行动从每一餐做起。',
    time: '今天 09:12',
    unread: false
  },
  {
    id: 5,
    type: 'order',
    title: '营养小贴士',
    content: '本餐蛋白质摄入充足，建议搭配一份绿叶蔬菜补充膳食纤维。',
    time: '昨天',
    unread: false
  }
])

const unreadCount = computed(() => items.value.filter((i) => i.unread).length)

const iconMap: Record<NotificationItem['type'], string> = {
  order: 'clipboard-list',
  notice: 'info',
  stock: 'alert-triangle'
}

function markAllRead() {
  items.value = items.value.map((i) => ({ ...i, unread: false }))
}

function markRead(id: number) {
  items.value = items.value.map((i) => (i.id === id ? { ...i, unread: false } : i))
}
</script>

<template>
  <Transition name="fade">
    <div v-if="props.open" class="notif-mask" @click.self="emit('close')">
      <Transition name="panel" appear>
        <aside class="notif" role="dialog" aria-modal="true" aria-label="通知中心">
          <header class="notif__head">
            <div class="notif__title-row">
              <h2 class="notif__title">通知中心</h2>
              <span v-if="unreadCount > 0" class="notif__badge num">{{ unreadCount }} 条未读</span>
            </div>
            <div class="notif__head-actions">
              <button v-if="unreadCount > 0" class="notif__mark" type="button" @click="markAllRead">全部已读</button>
              <button class="notif__close" type="button" aria-label="关闭通知" @click="emit('close')">
                <AppIcon name="close" :size="17" />
              </button>
            </div>
          </header>

          <div class="notif__body scroll-y">
            <button
              v-for="item in items"
              :key="item.id"
              class="notif-item"
              :class="{ 'notif-item--unread': item.unread }"
              type="button"
              @click="markRead(item.id)"
            >
              <span class="notif-item__icon" :class="`notif-item__icon--${item.type}`">
                <AppIcon :name="iconMap[item.type]" :size="15" />
              </span>
              <span class="notif-item__body">
                <span class="notif-item__title-row">
                  <span class="notif-item__title">{{ item.title }}</span>
                  <span class="notif-item__time">{{ item.time }}</span>
                </span>
                <span class="notif-item__content">{{ item.content }}</span>
              </span>
              <span v-if="item.unread" class="notif-item__dot"></span>
            </button>
          </div>

          <footer class="notif__foot">
            <AppIcon name="info" :size="12" />
            以上为课堂演示 Mock 通知，未对接后端消息服务
          </footer>
        </aside>
      </Transition>
    </div>
  </Transition>
</template>

<style scoped>
.notif-mask {
  position: fixed;
  inset: 0;
  z-index: 500;
  background: rgba(48, 44, 36, 0.32);
  backdrop-filter: blur(3px);
  display: flex;
  justify-content: flex-end;
}

.notif {
  display: flex;
  flex-direction: column;
  width: min(400px, 92vw);
  height: 100%;
  background: rgba(255, 253, 248, 0.98);
  backdrop-filter: blur(20px) saturate(1.15);
  border-left: 1px solid rgba(255, 255, 255, 0.9);
  box-shadow: var(--shadow-xl);
}

.notif__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
  padding: var(--space-5);
  border-bottom: 1px solid rgba(124, 143, 90, 0.12);
}

.notif__title-row {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.notif__title {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--ink-900);
}

.notif__badge {
  align-self: flex-start;
  padding: 2px 9px;
  border-radius: var(--radius-pill);
  background: var(--amber-100);
  color: var(--amber-600);
  font-size: 10.5px;
  font-weight: 600;
}

.notif__head-actions {
  display: flex;
  align-items: center;
  gap: 6px;
}

.notif__mark {
  font-size: var(--font-xs);
  font-weight: 600;
  color: var(--sage-600);
  padding: 4px 8px;
  border-radius: var(--radius-pill);
}

.notif__mark:hover {
  background: var(--sage-100);
}

.notif__close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  color: var(--ink-500);
  background: rgba(255, 255, 255, 0.8);
}

.notif__close:hover {
  background: var(--sage-100);
  color: var(--sage-700);
}

.notif__body {
  flex: 1;
  overflow-y: auto;
  padding: var(--space-3);
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.notif-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 11px 12px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid transparent;
  text-align: left;
  transition: background-color var(--motion-fast) var(--ease-standard),
    border-color var(--motion-fast) var(--ease-standard);
}

.notif-item:hover {
  background: #fff;
  border-color: rgba(124, 143, 90, 0.2);
}

.notif-item--unread {
  background: rgba(243, 247, 236, 0.9);
  border-color: rgba(124, 143, 90, 0.16);
}

.notif-item__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  flex: none;
  border-radius: var(--radius-sm);
  background: var(--sage-100);
  color: var(--sage-600);
}

.notif-item__icon--notice {
  background: var(--amber-100);
  color: var(--amber-600);
}

.notif-item__icon--stock {
  background: var(--danger-100);
  color: var(--danger-600);
}

.notif-item__body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.notif-item__title-row {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 8px;
}

.notif-item__title {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-800);
}

.notif-item__time {
  font-size: 10px;
  color: var(--ink-400);
  flex: none;
}

.notif-item__content {
  font-size: var(--font-xs);
  color: var(--ink-600);
  line-height: 1.6;
}

.notif-item__dot {
  width: 7px;
  height: 7px;
  flex: none;
  margin-top: 6px;
  border-radius: 50%;
  background: var(--amber-500);
}

.notif__foot {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 10px var(--space-5);
  border-top: 1px solid rgba(124, 143, 90, 0.12);
  font-size: 10px;
  color: var(--ink-400);
}
</style>
