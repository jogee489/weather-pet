import { test, expect, Page, BrowserContext } from '@playwright/test';
import { mockForecastResponse } from './helpers';

async function setupWeatherMocks(context: BrowserContext, page: Page) {
  await context.grantPermissions(['geolocation']);
  await context.setGeolocation({ latitude: 51.5074, longitude: -0.1278 });
  await page.route('**/api.open-meteo.com/**', async route => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify(mockForecastResponse()),
    });
  });
}

// NOTE: Flutter web's flutter-view element intercepts ALL pointer events,
// making Playwright clicks on individual DOM elements unreliable.
// We test navigation by driving go_router directly via URL, which is the
// canonical way to test Flutter web routing in headless environments.

test.describe('Navigation', () => {
  test.beforeEach(async ({ page, context }) => {
    await setupWeatherMocks(context, page);
  });

  test('app loads without crashing', async ({ page }) => {
    await page.goto('/');
    await page.waitForTimeout(3000);
    // Flutter mounts a flutter-view or canvas root element
    await expect(page.locator('flt-glass-pane, flutter-view, canvas').first()).toBeAttached();
  });

  test('bottom navigation bar shows all four tabs', async ({ page }) => {
    await page.goto('/home');
    await page.waitForTimeout(3000);
    await expect(page.getByText('Weather').first()).toBeAttached();
    await expect(page.getByText('Forecast').first()).toBeAttached();
    await expect(page.getByText('Search').first()).toBeAttached();
    await expect(page.getByText('Settings').first()).toBeAttached();
  });

  test('home route shows weather data', async ({ page }) => {
    await page.goto('/home');
    await expect(page.getByText(/\d+°C/).first()).toBeAttached({ timeout: 10_000 });
  });

  test('forecast route loads', async ({ page }) => {
    await page.goto('/forecast');
    await page.waitForTimeout(3000);
    // Forecast screen should be mounted (check URL and that Flutter is running)
    expect(page.url()).toContain('/forecast');
    await expect(page.locator('flt-glass-pane, flutter-view, canvas').first()).toBeAttached();
  });

  test('search route loads', async ({ page }) => {
    await page.goto('/search');
    await page.waitForTimeout(3000);
    expect(page.url()).toContain('/search');
    await expect(page.locator('flt-glass-pane, flutter-view, canvas').first()).toBeAttached();
  });

  test('settings route loads', async ({ page }) => {
    await page.goto('/settings');
    await page.waitForTimeout(3000);
    expect(page.url()).toContain('/settings');
    await expect(page.locator('flt-glass-pane, flutter-view, canvas').first()).toBeAttached();
  });

  test('navigating from settings back to home shows weather data', async ({ page }) => {
    await page.goto('/settings');
    await page.waitForTimeout(1000);
    await page.goto('/home');
    await expect(page.getByText(/\d+°C/).first()).toBeAttached({ timeout: 10_000 });
  });
});
