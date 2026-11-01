<script setup lang="ts">
/**
 * 结算确认弹窗。
 * 关键规则：只有点击「确认下单」才真正请求后端创建订单；
 * 关闭 / 取消 / 返回都不算结算成功，不会触发送餐视频。
 */
import { computed, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { DISH_PLACEHOLDER } from '@/config/media'
import { formatMoney, formatPrice } from '@/utils/format'
import type { CartItem } from '@/types/api'

const props = defineProps<{
  open: boolean
  items: CartItem[]
  totalAmount: number
  totalCalories: number
  submitting: boolean
  error: string | null
  warnings: string[]
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'confirm'): void
  (e: 'update-quantity', itemId: number, quantity: number): void
  (e: 'remove', itemId: number): void
}>()

const remark = ref('')
const agreed = ref(true)

const totalQuantity = computed(() => props.items.reduce((sum, item) => sum + item.quantity, 0))
const canConfirm = computed(() => props.items.length > 0 && !props.submitting && agreed.value)

function changeQuantity(item: CartItem, delta: number) {
  const next = item.quantity + delta
  if (next < 1) {
    emit('remove', item.id)
    return
  }
  if (next > 99) {
    return
  }
  emit('update-quantity', item.id, next)
}
</script>

<template>
  <Transition name="modal">
    <div v-if="open" class="modal" role="dialog" aria-modal="true" aria-label="确认结算" @click.self="emit('close')">
      <div class="modal__surface checkout">
        <header class="checkout__head">
          <div>
            <h2 class="checkout__title">确认结算</h2>
            <p class="checkout__subtitle">请核对菜品与金额，确认后才会通知厨房备餐</p>
          </div>
          <button class="checkout__close" type="button" aria-label="关闭结算弹窗" @click="emit('close')">
            <AppIcon name="close" :size="18" />
          </button>
        </header>

        <div class="checkout__list scroll-y">
          <div v-for="item in items" :key="item.id" class="checkout-item" :class="{ 'checkout-item--invalid': !item.available }">
            <img :src="item.imageUrl || DISH_PLACEHOLDER" :alt="item.dishName" />
            <div class="checkout-item__info">
              <span class="checkout-item__name">{{ item.dishName }}</span>
              <span class="checkout-item__unit num">¥{{ formatPrice(item.unitPrice) }} / 份</span>
              <span v-if="!item.available" class="checkout-item__warn">
                <AppIcon name="alert-triangle" :size="11" />{{ item.unavailableReason }}
              </span>
            </div>
            <div class="checkout-item__stepper">
              <button type="button" aria-label="减少数量" @click="changeQuantity(item, -1)">
                <AppIcon name="minus" :size="12" />
              </button>
              <span class="num">{{ item.quantity }}</span>
              <button type="button" aria-label="增加数量" @click="changeQuantity(item, 1)">
                <AppIcon name="plus" :size="12" />
              </button>
            </div>
            <span class="checkout-item__subtotal num">¥{{ formatMoney(item.subtotal) }}</span>
            <button class="checkout-item__remove" type="button" :aria-label="`移除 ${item.dishName}`" @click="emit('remove', item.id)">
              <AppIcon name="trash" :size="14" />
            </button>
          </div>

          <div v-if="items.length === 0" class="checkout__empty">
            <AppIcon name="cart" :size="26" />
            <p>购物车是空的，先去挑选菜品吧</p>
          </div>
        </div>

        <div v-if="warnings.length > 0" class="checkout__warnings">
          <p v-for="warn in warnings" :key="warn">
            <AppIcon name="alert-triangle" :size="12" />{{ warn }}
          </p>
        </div>

        <div class="checkout__summary">
          <div class="checkout__row">
            <span>菜品数量</span>
            <span class="num">{{ totalQuantity }} 份</span>
          </div>
          <div class="checkout__row">
            <span>预估热量</span>
            <span class="num">{{ Math.round(totalCalories) }} kcal</span>
          </div>
          <div class="checkout__row checkout__row--total">
            <span>合计金额</span>
            <span class="num checkout__amount">¥{{ formatMoney(totalAmount) }}</span>
          </div>
        </div>

        <div class="checkout__remark">
          <label class="field__label" for="checkout-remark">备注（可选）</label>
          <input id="checkout-remark" v-model="remark" class="input" type="text" maxlength="120" placeholder="例如：少放辣、不要香菜" />
        </div>

        <label class="checkout__agree">
          <input v-model="agreed" type="checkbox" />
          <span class="checkout__agree-box"><AppIcon name="check" :size="11" /></span>
          <span>我确认以上菜品与金额，同意提交订单（课堂演示：模拟支付，不产生真实扣款）</span>
        </label>

        <p v-if="error" class="checkout__error">
          <AppIcon name="x-circle" :size="13" />{{ error }}
        </p>

        <footer class="checkout__foot">
          <button class="btn btn--ghost" type="button" :disabled="submitting" @click="emit('close')">返回菜单</button>
          <button class="btn btn--primary" type="button" :disabled="!canConfirm" @click="emit('confirm')">
            <span v-if="submitting" class="spinner"></span>
            <template v-else>
              确认下单 · ¥{{ formatMoney(totalAmount) }}
            </template>
          </button>
        </footer>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.modal {
  position: fixed;
  inset: 0;
  z-index: 210;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-6);
  background: rgba(48, 44, 36, 0.44);
  backdrop-filter: blur(6px);
  -webkit-backdrop-filter: blur(6px);
}

.checkout {
  display: flex;
  flex-direction: column;
  width: min(560px, 94vw);
  max-height: 88vh;
  padding: var(--space-6);
  gap: var(--space-4);
  border-radius: var(--radius-2xl);
  background: var(--cream-50);
  box-shadow: var(--shadow-xl);
  overflow: hidden;
}

.checkout__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-3);
}

.checkout__title {
  font-size: var(--font-xl);
  font-weight: 700;
  color: var(--ink-900);
}

.checkout__subtitle {
  font-size: var(--font-sm);
  color: var(--ink-500);
  margin-top: 2px;
}

.checkout__close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.8);
  color: var(--ink-500);
}

.checkout__list {
  flex: 1;
  min-height: 120px;
  max-height: 34vh;
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-right: 4px;
}

.checkout-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 10px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.76);
  border: 1px solid rgba(124, 143, 90, 0.1);
}

.checkout-item--invalid {
  border-color: var(--danger-500);
  background: var(--danger-100);
}

.checkout-item img {
  width: 46px;
  height: 46px;
  border-radius: var(--radius-xs);
  object-fit: cover;
  flex: none;
}

.checkout-item__info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.checkout-item__name {
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--ink-800);
}

.checkout-item__unit {
  font-size: var(--font-xs);
  color: var(--ink-500);
}

.checkout-item__warn {
  display: flex;
  align-items: center;
  gap: 3px;
  font-size: 10.5px;
  color: var(--danger-600);
}

.checkout-item__stepper {
  display: flex;
  align-items: center;
  gap: 4px;
  flex: none;
}

.checkout-item__stepper button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: var(--sage-100);
  color: var(--sage-700);
}

.checkout-item__stepper span {
  min-width: 18px;
  text-align: center;
  font-size: var(--font-sm);
  font-weight: 700;
}

.checkout-item__subtotal {
  min-width: 58px;
  text-align: right;
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--amber-600);
  flex: none;
}

.checkout-item__remove {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  color: var(--ink-400);
  flex: none;
}

.checkout-item__remove:hover {
  color: var(--danger-500);
  background: var(--danger-100);
}

.checkout__empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: var(--space-8);
  color: var(--ink-400);
  font-size: var(--font-sm);
}

.checkout__warnings {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 8px 12px;
  border-radius: var(--radius-sm);
  background: var(--amber-100);
  color: var(--amber-600);
  font-size: var(--font-xs);
}

.checkout__warnings p {
  display: flex;
  align-items: flex-start;
  gap: 5px;
  line-height: 1.5;
}

.checkout__summary {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  background: rgba(232, 238, 221, 0.55);
}

.checkout__row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: var(--font-sm);
  color: var(--ink-600);
}

.checkout__row--total {
  padding-top: 6px;
  border-top: 1px dashed rgba(124, 143, 90, 0.28);
  font-weight: 700;
  color: var(--ink-800);
}

.checkout__amount {
  font-size: var(--font-xl);
  color: var(--amber-600);
}

.checkout__remark {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.checkout__agree {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  font-size: var(--font-xs);
  color: var(--ink-500);
  line-height: 1.5;
  cursor: pointer;
}

.checkout__agree input {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

.checkout__agree-box {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 16px;
  height: 16px;
  margin-top: 1px;
  flex: none;
  border-radius: 5px;
  border: 1.5px solid rgba(124, 143, 90, 0.45);
  background: #fff;
  color: transparent;
}

.checkout__agree input:checked + .checkout__agree-box {
  background: var(--sage-600);
  border-color: var(--sage-600);
  color: #fff;
}

.checkout__error {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 8px 12px;
  border-radius: var(--radius-sm);
  background: var(--danger-100);
  color: var(--danger-600);
  font-size: var(--font-xs);
}

.checkout__foot {
  display: flex;
  gap: var(--space-3);
}

.checkout__foot .btn {
  flex: 1;
}

.spinner {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.4);
  border-top-color: #fff;
  animation: spin 700ms linear infinite;
}

@media (max-width: 767px) {
  .checkout {
    max-height: 92vh;
    padding: var(--space-4);
  }

  .checkout__list {
    max-height: 30vh;
  }
}
</style>
