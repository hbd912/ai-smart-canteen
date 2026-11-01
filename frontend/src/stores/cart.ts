import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { cartApi } from '@/api/modules'
import type { Cart } from '@/types/api'

/**
 * 购物车 Store（数据以后端为准）。
 * 注意：购物车有商品 ≠ 订单已提交。桌面是否有菜只由 orderStatus 决定。
 */
export const useCartStore = defineStore('cart', () => {
  const cart = ref<Cart>({
    cartId: 0,
    items: [],
    totalQuantity: 0,
    dishCount: 0,
    totalAmount: 0,
    totalCalories: 0,
    warnings: [],
    hasUnavailable: false
  })
  const loading = ref(false)
  const error = ref<string | null>(null)
  /** 最近一次数量变化，用于角标弹动动画 */
  const lastChangedDishId = ref<number | null>(null)

  const items = computed(() => cart.value.items ?? [])
  const totalQuantity = computed(() => cart.value.totalQuantity ?? 0)
  const dishCount = computed(() => cart.value.dishCount ?? 0)
  const totalAmount = computed(() => Number(cart.value.totalAmount ?? 0))
  const totalCalories = computed(() => Number(cart.value.totalCalories ?? 0))
  const warnings = computed(() => cart.value.warnings ?? [])
  const isEmpty = computed(() => totalQuantity.value === 0)
  const hasUnavailable = computed(() => Boolean(cart.value.hasUnavailable))

  function quantityOf(dishId: number): number {
    const found = items.value.find((item) => item.dishId === dishId)
    return found ? found.quantity : 0
  }

  function itemIdOf(dishId: number): number | null {
    const found = items.value.find((item) => item.dishId === dishId)
    return found ? found.id : null
  }

  async function refresh() {
    loading.value = true
    error.value = null
    try {
      cart.value = await cartApi.get()
    } catch (e) {
      error.value = e instanceof Error ? e.message : '购物车加载失败'
    } finally {
      loading.value = false
    }
  }

  async function add(dishId: number, quantity = 1) {
    cart.value = await cartApi.add(dishId, quantity)
    lastChangedDishId.value = dishId
    return cart.value
  }

  async function updateQuantity(itemId: number, quantity: number) {
    cart.value = await cartApi.update(itemId, quantity)
    return cart.value
  }

  async function remove(itemId: number) {
    cart.value = await cartApi.remove(itemId)
    return cart.value
  }

  async function clear() {
    cart.value = await cartApi.clear()
    return cart.value
  }

  function resetLocal() {
    cart.value = {
      cartId: 0,
      items: [],
      totalQuantity: 0,
      dishCount: 0,
      totalAmount: 0,
      totalCalories: 0,
      warnings: [],
      hasUnavailable: false
    }
  }

  return {
    cart,
    loading,
    error,
    lastChangedDishId,
    items,
    totalQuantity,
    dishCount,
    totalAmount,
    totalCalories,
    warnings,
    isEmpty,
    hasUnavailable,
    quantityOf,
    itemIdOf,
    refresh,
    add,
    updateQuantity,
    remove,
    clear,
    resetLocal
  }
})
