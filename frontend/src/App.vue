<script setup lang="ts">
import { onMounted } from 'vue'
import ToastHost from '@/components/common/ToastHost.vue'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()

onMounted(() => {
  // 启动时尝试恢复会话（token 存于 sessionStorage，刷新后仍可用）
  auth.restoreSession()
})
</script>

<template>
  <RouterView v-slot="{ Component }">
    <component :is="Component" />
  </RouterView>
  <ToastHost />
</template>

<style>
#app {
  height: 100%;
  width: 100%;
}
</style>
