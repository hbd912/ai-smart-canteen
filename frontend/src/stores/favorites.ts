import { defineStore } from 'pinia'
import { ref } from 'vue'
import { favoriteApi } from '@/api/modules'
import type { Dish } from '@/types/api'

/** 收藏 Store：首页推荐卡、菜单卡、详情弹窗共享同一份收藏状态 */
export const useFavoriteStore = defineStore('favorites', () => {
  const ids = ref<Set<number>>(new Set())
  const dishes = ref<Dish[]>([])
  const loading = ref(false)

  function isFavorited(dishId: number) {
    return ids.value.has(dishId)
  }

  async function refresh() {
    loading.value = true
    try {
      const list = await favoriteApi.list()
      dishes.value = list
      ids.value = new Set(list.map((d) => d.id))
    } finally {
      loading.value = false
    }
  }

  async function toggle(dishId: number) {
    const result = await favoriteApi.toggle(dishId)
    const next = new Set(ids.value)
    if (result.favorited) {
      next.add(dishId)
    } else {
      next.delete(dishId)
    }
    ids.value = next
    return result.favorited
  }

  function resetLocal() {
    ids.value = new Set()
    dishes.value = []
  }

  return { ids, dishes, loading, isFavorited, refresh, toggle, resetLocal }
})
