import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  // Run all tests in parallel
  fullyParallel: true,
  // Fail the build on CI if you accidentally left test.only
  forbidOnly: !!process.env.CI,
  // Retry once on CI to reduce flakiness from slow startup
  retries: process.env.CI ? 1 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: process.env.CI ? 'github' : 'list',

  use: {
    // Flutter web served locally (or CI) at port 8080
    baseURL: process.env.BASE_URL ?? 'http://localhost:8080',
    // Capture screenshot on failure
    screenshot: 'only-on-failure',
    // Flutter web can be slow to hydrate — generous timeout
    actionTimeout: 15_000,
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    // Uncomment to also run on mobile viewports in CI:
    // {
    //   name: 'mobile-chrome',
    //   use: { ...devices['Pixel 7'] },
    // },
  ],

  // Global timeout per test
  timeout: 30_000,
});
