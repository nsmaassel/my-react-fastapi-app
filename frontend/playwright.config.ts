import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: false, // Disable parallel execution for more stable tests
  forbidOnly: !!process.env.CI,
  retries: 2, // Increase retries for flaky Docker environment
  workers: 1,
  reporter: 'html',
  use: {
    baseURL: process.env.PLAYWRIGHT_TEST_BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    viewport: { width: 1280, height: 720 },
    actionTimeout: 15000,
    navigationTimeout: 30000,
    // Add screenshot on failure
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    // More reliable context options for Docker
    contextOptions: {
      reducedMotion: 'reduce'
    },
    // Better Docker compatibility
    launchOptions: {
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage'
      ]
    }
  },
  projects: [
    {
      name: 'chromium',
      use: { 
        ...devices['Desktop Chrome']
      },
    },
  ],
  webServer: undefined,
  // Increase global timeout for Docker environment
  timeout: 60000,
});