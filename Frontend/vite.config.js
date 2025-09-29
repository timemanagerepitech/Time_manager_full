import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:4000',
        changeOrigin: true,
        secure: false,
        // If backend expects x-forwarded headers, keep default behavior.
        // Rewrite is not needed because we keep the /api prefix as-is.
      }
    }
  }
})
