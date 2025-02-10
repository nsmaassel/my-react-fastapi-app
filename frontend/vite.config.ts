import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

// Load environment variables
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const isDev = mode === 'development'
  const apiUrl = env.VITE_API_URL || 'http://backend:8000'
  
  return {
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
      // Only use proxy in development
      proxy: isDev ? {
        '/api': {
          target: apiUrl,
          changeOrigin: true,
          secure: false,
          rewrite: (path) => path
        }
      } : undefined
    }
  }
})
