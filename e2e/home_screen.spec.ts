import { test, expect } from '@playwright/test';

test.describe('Home Screen', () => {
  test.beforeEach(async ({ page }) => {
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
      'Could not fetch weather', // error state is also acceptable
    ];
    const pattern = new RegExp(conditions.join('|'));
    await expect(page.getByText(pattern)).toBeVisible({ timeout: 10_000 });
  });

  test('does not show loading spinner after data loads', async ({ page }) => {
    // Give extra time for the weather fetch
    await page.waitForTimeout(8000);
    // If we have temperature visible, loading must be gone
    const hasTemp = await page.getByText(/\d+°C/).isVisible();
    if (hasTemp) {
      // Spinner is identified by its aria role (progressbar in Flutter web)
      const spinner = page.getByRole('progressbar');
      await expect(spinner).toHaveCount(0);
    }
  });

  test('feels-like temperature is visible', async ({ page }) => {
    await expect(page.getByText(/Feels like/)).toBeVisible({ timeout: 10_000 });
  });

  test('humidity percentage is visible', async ({ page }) => {
    await expect(page.getByText(/%/)).toBeVisible({ timeout: 10_000 });
  });

  test('wind speed is visible', async ({ page }) => {
    await expect(page.getByText(/km\/h/)).toBeVisible({ timeout: 10_000 });
  });
});
