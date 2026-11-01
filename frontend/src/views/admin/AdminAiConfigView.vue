<script setup lang="ts">
/**
 * AI 服务配置状态页：展示后端 AI 服务是否已配置、当前模式、模型名称与降级说明。
 * 安全约束：页面不展示、也不允许输入 API Key；Key 只能通过后端环境变量注入。
 */
import { onMounted, ref } from 'vue'
import AppIcon from '@/components/common/AppIcon.vue'
import { aiApi } from '@/api/modules'
import type { AiStatus } from '@/types/api'

const loading = ref(true)
const status = ref<AiStatus | null>(null)
const error = ref<string | null>(null)

async function load() {
  loading.value = true
  error.value = null
  try {
    status.value = await aiApi.status()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'AI 状态加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>

<template>
  <div class="ai-page">
    <header class="page-head">
      <div>
        <h2 class="page-head__title">AI 服务配置</h2>
        <p class="page-head__desc">
          大模型 API Key 只能通过后端环境变量注入（AI_API_KEY），严禁写入前端代码或数据库；
          本页面仅展示服务状态与调用模式，不提供任何密钥输入。
        </p>
      </div>
      <button class="btn btn--ghost btn--sm" type="button" @click="load">
        <AppIcon name="refresh" :size="14" />刷新状态
      </button>
    </header>

    <div v-if="error" class="alert-bar">
      <AppIcon name="alert-triangle" :size="15" />
      <span>{{ error }}</span>
    </div>

    <div v-if="loading" class="skeleton" style="height: 180px; border-radius: 16px"></div>

    <template v-else-if="status">
      <section class="status-card" :class="status.configured ? 'status-card--llm' : 'status-card--rule'">
        <div class="status-card__icon">
          <AppIcon :name="status.configured ? 'sparkles' : 'robot'" :size="26" />
        </div>
        <div class="status-card__body">
          <div class="status-card__title-row">
            <h3 class="status-card__title">{{ status.modeLabel }}</h3>
            <span class="pill" :class="status.configured ? 'pill--sage' : 'pill--amber'">
              {{ status.configured ? '已配置大模型' : '降级模式' }}
            </span>
          </div>
          <p class="status-card__desc">{{ status.message }}</p>
          <div class="status-card__meta">
            <span><strong>模型：</strong>{{ status.model || '未配置' }}</span>
            <span><strong>调用模式：</strong>{{ status.mode }}</span>
            <span><strong>可用状态：</strong>{{ status.available ? '可用' : '不可用' }}</span>
          </div>
          <p v-if="status.lastError" class="status-card__error">
            <AppIcon name="alert-triangle" :size="12" />最近一次调用失败：{{ status.lastError }}
          </p>
        </div>
      </section>

      <section class="admin-card">
        <h3 class="admin-card__title">两种运行模式</h3>
        <div class="mode-grid">
          <div class="mode-card" :class="{ 'mode-card--active': status.configured }">
            <h4 class="mode-card__title"><AppIcon name="sparkles" :size="15" />大模型模式</h4>
            <p class="mode-card__desc">
              后端把数据库中的在售菜品（名称、价格、热量、营养、标签）作为候选集写入 Prompt，
              调用配置的大模型 API，要求其返回结构化 JSON。后端会二次校验模型返回的菜品 ID
              是否真实存在、已上架且有库存，编造结果一律丢弃。
            </p>
            <ul class="mode-card__list">
              <li>Key 仅存于后端环境变量</li>
              <li>Prompt 只含真实候选菜品</li>
              <li>输出经后端校验后才返回前端</li>
            </ul>
          </div>
          <div class="mode-card" :class="{ 'mode-card--active': !status.configured }">
            <h4 class="mode-card__title"><AppIcon name="robot" :size="15" />规则推荐降级模式</h4>
            <p class="mode-card__desc">
              未配置 Key 或调用失败时自动降级：根据预算、热量、分类、关键词等规则，
              在数据库中真实在售的菜品里筛选并打分排序，返回推荐理由。
              界面会明确标注「规则推荐演示模式」，不会把规则推荐谎称为大模型生成。
            </p>
            <ul class="mode-card__list">
              <li>基于数据库真实菜品</li>
              <li>预算 / 热量 / 口味规则筛选</li>
              <li>结果明确标注模式</li>
            </ul>
          </div>
        </div>
      </section>

      <section class="admin-card">
        <h3 class="admin-card__title">配置方式（后端环境变量）</h3>
        <pre class="code-block"># application.yml 已预留以下环境变量，无需改动代码
AI_ENABLED=true
AI_BASE_URL=https://api.deepseek.com/v1
AI_API_KEY=&lt;你的密钥，仅在后端环境变量中设置&gt;
AI_MODEL=deepseek-chat
AI_TIMEOUT_SECONDS=20
AI_TEMPERATURE=0.3</pre>
        <p class="config-note">
          <AppIcon name="info" :size="12" />
          设置 AI_API_KEY 后重启后端即进入大模型模式；删除该变量即自动回到规则推荐降级模式。
        </p>
      </section>

      <section class="admin-card">
        <h3 class="admin-card__title">接口说明</h3>
        <table class="api-table">
          <thead>
            <tr>
              <th style="width: 90px">方法</th>
              <th style="width: 240px">路径</th>
              <th>说明</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><span class="method">GET</span></td>
              <td><code>/api/v1/ai/status</code></td>
              <td>返回 AI 服务是否已配置、当前模式、模型名（不含任何密钥）</td>
            </tr>
            <tr>
              <td><span class="method">POST</span></td>
              <td><code>/api/v1/ai/recommend</code></td>
              <td>接收自然语言需求，返回推荐菜品、推荐理由、搭配建议与模式标识</td>
            </tr>
          </tbody>
        </table>
      </section>
    </template>
  </div>
</template>

<style scoped>
.ai-page {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.page-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.page-head__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
}

.page-head__desc {
  font-size: 10.5px;
  color: var(--ink-400);
  margin-top: 2px;
  max-width: 780px;
  line-height: 1.6;
}

.alert-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  border-radius: var(--radius-md);
  background: var(--danger-100);
  color: var(--danger-600);
  font-size: var(--font-sm);
}

.status-card {
  display: flex;
  align-items: flex-start;
  gap: var(--space-4);
  padding: var(--space-5);
  border-radius: var(--radius-lg);
  border: 1px solid rgba(124, 143, 90, 0.16);
  background: linear-gradient(135deg, rgba(243, 247, 236, 0.95), rgba(253, 248, 239, 0.9));
}

.status-card--rule {
  background: linear-gradient(135deg, rgba(253, 240, 221, 0.9), rgba(253, 248, 239, 0.9));
  border-color: rgba(217, 143, 56, 0.24);
}

.status-card__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 54px;
  height: 54px;
  flex: none;
  border-radius: var(--radius-md);
  background: #fff;
  color: var(--sage-600);
  box-shadow: var(--shadow-sm);
}

.status-card--rule .status-card__icon {
  color: var(--amber-500);
}

.status-card__body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.status-card__title-row {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.status-card__title {
  font-size: var(--font-lg);
  font-weight: 700;
  color: var(--ink-900);
}

.status-card__desc {
  font-size: var(--font-xs);
  color: var(--ink-600);
  line-height: 1.65;
}

.status-card__meta {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
  font-size: 10.5px;
  color: var(--ink-500);
  margin-top: 2px;
}

.status-card__error {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 10px;
  color: var(--danger-600);
}

.pill {
  display: inline-flex;
  padding: 2px 9px;
  border-radius: var(--radius-pill);
  font-size: 10px;
  font-weight: 600;
}

.pill--sage {
  background: var(--success-100);
  color: var(--success-600);
}

.pill--amber {
  background: var(--amber-100);
  color: var(--amber-600);
}

.admin-card {
  padding: var(--space-5);
  border-radius: var(--radius-lg);
  background: rgba(255, 253, 248, 0.96);
  border: 1px solid rgba(124, 143, 90, 0.12);
}

.admin-card__title {
  font-size: var(--font-md);
  font-weight: 700;
  color: var(--ink-900);
  margin-bottom: var(--space-3);
}

.mode-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
}

.mode-card {
  padding: var(--space-4);
  border-radius: var(--radius-md);
  border: 1px solid rgba(124, 143, 90, 0.16);
  background: rgba(255, 255, 255, 0.6);
  opacity: 0.72;
  transition: opacity var(--motion-normal) var(--ease-standard),
    border-color var(--motion-normal) var(--ease-standard);
}

.mode-card--active {
  opacity: 1;
  border-color: var(--sage-400);
  box-shadow: var(--shadow-sm);
}

.mode-card__title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: var(--font-sm);
  font-weight: 700;
  color: var(--sage-700);
}

.mode-card__desc {
  font-size: 10.5px;
  color: var(--ink-600);
  line-height: 1.7;
  margin-top: 6px;
}

.mode-card__list {
  display: flex;
  flex-direction: column;
  gap: 3px;
  margin-top: 8px;
}

.mode-card__list li {
  position: relative;
  padding-left: 12px;
  font-size: 10px;
  color: var(--ink-500);
}

.mode-card__list li::before {
  content: '';
  position: absolute;
  left: 2px;
  top: 6px;
  width: 4px;
  height: 4px;
  border-radius: 50%;
  background: var(--sage-400);
}

.code-block {
  padding: var(--space-4);
  border-radius: var(--radius-sm);
  background: #2f3d26;
  color: #d7e3c9;
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 11px;
  line-height: 1.8;
  overflow-x: auto;
  white-space: pre;
}

.config-note {
  display: flex;
  align-items: center;
  gap: 5px;
  margin-top: 8px;
  font-size: 10.5px;
  color: var(--ink-500);
}

.api-table {
  width: 100%;
  border-collapse: collapse;
  font-size: var(--font-xs);
}

.api-table th {
  text-align: left;
  padding: 8px;
  font-size: 10.5px;
  font-weight: 600;
  color: var(--ink-500);
  border-bottom: 1px solid rgba(124, 143, 90, 0.16);
}

.api-table td {
  padding: 9px 8px;
  border-bottom: 1px solid rgba(124, 143, 90, 0.07);
  color: var(--ink-600);
  font-size: 10.5px;
}

.api-table code {
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 10.5px;
  color: var(--sage-700);
}

.method {
  display: inline-flex;
  padding: 1px 7px;
  border-radius: 4px;
  background: var(--sage-100);
  color: var(--sage-700);
  font-size: 10px;
  font-weight: 700;
}

@media (max-width: 1023px) {
  .mode-grid {
    grid-template-columns: 1fr;
  }
}
</style>
