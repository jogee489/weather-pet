import { test, expect, Page, BrowserContext } from '@playwright/test';
import { mockForecastResponse } from './helpers';

// ─── Mock helpers ────────────────────────────────────────────────────────────

/** Sets up geolocation permission + Open-Meteo API mock for the given context/page. */
async function setupWeatherMocks(context: BrowserContext, page: Page) {
  // Grant geolocation and set a fixed location (London) so geolocator resolves
  await context.grantPermissions(['geolocation']);
  await context.setGeolocation({ latitude: 51.5074, longitude: -0.1278 });

  // Intercept Open-Meteo API calls and return deterministic mock data
  await page.route('**/api.open-meteo.com/**', async route => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify(mockForecastResponse()),
    });
  });
}

// ─── Tests ───────────────────────────────────────────────────────────────────

test.describe('Home Screen', () => {
  test.beforeEach(async ({ page, context }) => {
    await setupWeatherMocks(context, page);
    await page.goto('/');
    // Wait for splash to complete and weather to load
    await page.waitForTimeout(5000);
  });

  test('displays temperature in degrees Celsius', async ({ page }) => {
    await expect(page.getByText(/\d+°C/)).toBeVisible({ timeout: 10_000 });
  });

  test('displays a weather condition description', async ({ page }) => {
    const conditions = [
      'Clear sky', 'Mainly clear', 'Partly cloudy', 'Overcast',
      'Foggy', 'Drizzle', 'Rain', 'Snow', 'Thunderstorm', 'Cloudy',
    ];
    const pattern = new RegExp(conditions.join('|'));
    await expect(page.getByText(pattern)).toBeVisible({ timeout: 10_000 });
  });

  test('does not show loading spinner after data loads', async ({ page }) => {
    await expect(page.getByText(/\d+°C/)).toBeVisible({ timeout: 10_000 });
    // Once temperature is visible, the spinner must be gone
    const spinner = page.getByRole('progressbar');
    await expect(spinner).toHaveCount(0);
  });

  test('feels-like temperature is visible', async ({ page }) => {
    await expect(page.getByText(/Feels like/)).toBeVisible({ timeout: 10_000 });
  });

  test('humidity percentage is visible', async ({ page }) => {
    const el = page.getByText(/%/).first();
    await el.scrollIntoViewIfNeeded();
    await expect(el).toBeVisible({ timeout: 10_000 });
  });

  test('wind speed is visible', async ({ page }) => {
    const el = page.getByText(/km\/h/).first();
    await el.scrollIntoViewIfNeeded();
    await expect(el).toBeVisible({ timeout: 10_000 });
  });
});
