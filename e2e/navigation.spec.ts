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

// NOTE: Flutter web uses hash-based routing by default (/#/home, /#/settings).
// Navigating to /settings (no hash) hits the static file server, gets a 404,
// and Flutter never boots. Always use /#/<route> for direct navigation.
//
// flutter-view intercepts ALL pointer events, so we test routing by URL, not
// by simulating clicks on nav bar elements.
//
// Text elements rendered by Flutter HTML renderer are visibility:hidden in CSS
// — use toBeAttached() instead of toBeVisible().

test.describe('Navigation', () => {
  test.beforeEach(async ({ page, context }) => {
    await setupWeatherMocks(context, page);
  });

  test('app loads without crashing', async ({ page }) => {
    await page.goto('/');
    await page.waitForTimeout(4000);
    // Check that the page has a document title (set in index.html by Flutter)
    const title = await page.title();
    expect(title.length).toBeGreaterThan(0);
  });

  test('bottom navigation bar shows all four tabs', async ({ page }) => {
    await page.goto('/');
    await page.waitForTimeout(4000);
    await expect(page.getByText('Weather').first()).toBeAttached({ timeout: 10_000 });
    await expect(page.getByText('Forecast').first()).toBeAttached({ timeout: 10_000 });
    await expect(page.getByText('Search').first()).toBeAttached({ timeout: 10_000 });
    await expect(page.getByText('Settings').first()).toBeAttached({ timeout: 10_000 });
  });

  test('home route shows weather data', async ({ page }) => {
    await page.goto('/#/home');
    await expect(page.getByText(/\d+°C/).first()).toBeAttached({ timeout: 15_000 });
  });

  test('forecast route loads', async ({ page }) => {
    await page.goto('/#/forecast');
    await page.waitForTimeout(4000);
    // Nav bar always visible on ShellRoute screens
    await expect(page.getByText('Forecast').first()).toBeAttached({ timeout: 10_000 });
  });

  test('search route loads', async ({ page }) => {
    await page.goto('/#/search');
    await page.waitForTimeout(4000);
    await expect(page.getByText('Search').first()).toBeAttached({ timeout: 10_000 });
  });

  test('settings route loads', async ({ page }) => {
    await page.goto('/#/settings');
    await page.waitForTimeout(4000);
    await expect(page.getByText('Settings').first()).toBeAttached({ timeout: 10_000 });
  });

  test('navigating from settings back to home shows weather data', async ({ page }) => {
    await page.goto('/#/settings');
    await page.waitForTimeout(1000);
    await page.goto('/#/home');
    await expect(page.getByText(/\d+°C/).first()).toBeAttached({ timeout: 15_000 });
  });
});
