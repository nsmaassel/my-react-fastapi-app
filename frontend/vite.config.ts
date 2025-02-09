import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: true,
    port: 3000,
    strictPort: true,
    watch: {
      usePolling: true,
      interval: 1000,
    },
    hmr: {
      host: 'frontend',
      port: 24678,
      protocol: 'ws',
      clientPort: 24678
    },
    cors: true,
    fs: {
      strict: false
    },
    allowedHosts: [
      'localhost',
      'frontend',
      '127.0.0.1'
    ],
    proxy: {
      '/api': {
        target: 'http://backend:8000',
        changeOrigin: true,
        secure: false
      }
    }
  }
})
