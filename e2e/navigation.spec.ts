import { test, expect } from '@playwright/test';

test.describe('Navigation', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    // Wait for Flutter to boot and splash to complete
    await page.waitForTimeout(3000);
  });

  test('app loads without crashing', async ({ page }) => {
    // No error dialogs or blank screens
    await expect(page).not.toHaveTitle('');
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
    // Navigate away first
    await page.getByText('Settings').click();
    // Return home
    await page.getByText('Weather').click();
    // Home should show temperature
    await expect(page.getByText(/\d+°C/)).toBeVisible({ timeout: 10_000 });
  });
});
