<script setup lang="ts">
import AppIcon from '@/components/common/AppIcon.vue'
</script>

<template>
  <div class="not-found">
    <span class="not-found__art"><AppIcon name="map-pin" :size="34" /></span>
    <h1 class="not-found__title">页面走丢了</h1>
    <p class="not-found__desc">你访问的地址不存在，回到智慧食堂继续点餐吧。</p>
    <RouterLink to="/" class="btn btn--primary">
      返回首页
      <AppIcon name="arrow-right" :size="16" />
    </RouterLink>
  </div>
</template>

<style scoped>
.not-found {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  min-height: 100vh;
  background: radial-gradient(circle at 50% 40%, #fdf8ef, #ece3d2 72%);
  text-align: center;
  padding: var(--space-6);
}

.not-found__art {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: var(--sage-100);
  color: var(--sage-500);
}

.not-found__title {
  font-size: var(--font-2xl);
  font-weight: 700;
  color: var(--ink-900);
}

.not-found__desc {
  font-size: var(--font-sm);
  color: var(--ink-500);
  margin-bottom: var(--space-3);
}
</style>
