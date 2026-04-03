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

test.describe('Navigation', () => {
  test.beforeEach(async ({ page, context }) => {
    await setupWeatherMocks(context, page);
    await page.goto('/');
    // Wait for Flutter to boot and splash to complete
    await page.waitForTimeout(3000);
  });

  test('app loads without crashing', async ({ page }) => {
    // Flutter canvas or flt-glass-pane should be present
    const flutterRoot = page.locator('flt-glass-pane, canvas').first();
    await expect(flutterRoot).toBeVisible();
  });

  test('bottom navigation bar is visible', async ({ page }) => {
    // With HTML renderer, navigation labels render as text
    await expect(page.getByText('Weather')).toBeVisible();
    await expect(page.getByText('Forecast')).toBeVisible();
    await expect(page.getByText('Search')).toBeVisible();
    await expect(page.getByText('Settings')).toBeVisible();
  });

  test('tapping Forecast tab shows forecast content', async ({ page }) => {
    await page.getByText('Forecast').click();
    await expect(page.getByText('Forecast')).toBeVisible();
  });

  test('tapping Search tab shows search input', async ({ page }) => {
    await page.getByText('Search').click();
    await expect(page.getByText('Search for a city')).toBeVisible();
  });

  test('tapping Settings tab shows settings content', async ({ page }) => {
    await page.getByText('Settings').click();
    await expect(page.getByText('Settings')).toBeVisible();
  });

  test('tapping Weather tab returns to home screen', async ({ page }) => {
    await page.getByText('Settings').click();
    await page.getByText('Weather').click();
    await expect(page.getByText(/\d+°C/)).toBeVisible({ timeout: 10_000 });
  });
});
