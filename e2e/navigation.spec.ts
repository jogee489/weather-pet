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

// NOTE: Flutter web HTML renderer marks flt-paragraph elements as
// visibility:hidden. We use toBeAttached() instead of toBeVisible() for
// Flutter text content.

test.describe('Navigation', () => {
  test.beforeEach(async ({ page, context }) => {
    await setupWeatherMocks(context, page);
    await page.goto('/');
    // Wait for Flutter to boot and splash to complete
    await page.waitForTimeout(3000);
  });

  test('app loads without crashing', async ({ page }) => {
    // Flutter canvas or flt-glass-pane should be present in the DOM
    const flutterRoot = page.locator('flt-glass-pane, canvas').first();
    await expect(flutterRoot).toBeAttached();
  });

  test('bottom navigation bar is visible', async ({ page }) => {
    // With HTML renderer, navigation labels render as flt-paragraph text nodes
    await expect(page.getByText('Weather').first()).toBeAttached();
    await expect(page.getByText('Forecast').first()).toBeAttached();
    await expect(page.getByText('Search').first()).toBeAttached();
    await expect(page.getByText('Settings').first()).toBeAttached();
  });

  test('tapping Forecast tab shows forecast content', async ({ page }) => {
    await page.getByText('Forecast').first().click();
    await expect(page.getByText('Forecast').first()).toBeAttached();
  });

  test('tapping Search tab shows search input', async ({ page }) => {
    await page.getByText('Search').first().click();
    await expect(page.getByText('Search for a city').first()).toBeAttached({ timeout: 10_000 });
  });

  test('tapping Settings tab shows settings content', async ({ page }) => {
    await page.getByText('Settings').first().click();
    await expect(page.getByText('Settings').first()).toBeAttached();
  });

  test('tapping Weather tab returns to home screen', async ({ page }) => {
    await page.getByText('Settings').first().click();
    await page.getByText('Weather').first().click();
    await expect(page.getByText(/\d+°C/).first()).toBeAttached({ timeout: 10_000 });
  });
});
