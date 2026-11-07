import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const backend = env.VITE_PROXY_TARGET || 'http://localhost:8080'

  return {
    plugins: [vue()],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url))
      }
    },
    server: {
      port: 5173,
      strictPort: false,
      // 允许通过临时隧道（如 cloudflared）用外部域名访问本地开发/预览服务
      allowedHosts: true,
      proxy: {
        // 通过隧道访问时浏览器会带外部域名 Origin，后端 CORS 只放行本地源；
        // 这里由本地代理统一改写 Origin，避免公网预览时被 403 (Invalid CORS request)
        '/api': {
          target: backend,
          changeOrigin: true,
          headers: { Origin: 'http://localhost:5173' }
        },
        '/uploads': { target: backend, changeOrigin: true }
      }
    },
    preview: {
      port: 4173,
      allowedHosts: true,
      proxy: {
        '/api': {
          target: backend,
          changeOrigin: true,
          headers: { Origin: 'http://localhost:5173' }
        },
        '/uploads': { target: backend, changeOrigin: true }
      }
    },
    build: {
      outDir: 'dist',
      chunkSizeWarningLimit: 1600,
      rollupOptions: {
        output: {
          manualChunks: {
            echarts: ['echarts'],
            element: ['element-plus'],
            vendor: ['vue', 'vue-router', 'pinia', 'axios']
          }
        }
      }
    }
  }
})
