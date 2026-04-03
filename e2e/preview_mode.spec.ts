import { test, expect } from '@playwright/test';

/**
 * Preview Mode E2E tests.
 *
 * These tests are SKIPPED until Phase 6 (Settings screen) is complete.
 * Remove the test.skip() calls once the Preview Mode UI is implemented.
 */
test.describe('Preview Mode', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForTimeout(3000);
    // Navigate to Settings
    await page.getByText('Settings').click();
    await page.waitForTimeout(500);
  });

  test.skip('Preview Mode toggle is visible in Settings', async ({ page }) => {
    await expect(page.getByText('Preview Mode')).toBeVisible();
  });

  test.skip('enabling Preview Mode shows state selector', async ({ page }) => {
    await page.getByText('Preview Mode').click();
    await expect(page.getByText('Sunny')).toBeVisible();
    await expect(page.getByText('Stormy')).toBeVisible();
    await expect(page.getByText('Snowy')).toBeVisible();
  });

  test.skip('selecting Stormy applies dark background', async ({ page }) => {
    await page.getByText('Preview Mode').click();
    await page.getByText('Stormy').click();

    // Navigate to Weather tab to see the effect
    await page.getByText('Weather').click();
    await page.waitForTimeout(1000);

    // Dark background: background color should be dark
    const bgColor = await page.evaluate(() => {
      const body = document.querySelector('body');
      return body ? window.getComputedStyle(body).backgroundColor : '';
    });
    // Stormy theme is very dark — check that it's not white
    expect(bgColor).not.toBe('rgb(255, 255, 255)');
  });

  test.skip('selecting Sunny applies warm background', async ({ page }) => {
    await page.getByText('Preview Mode').click();
    await page.getByText('Sunny').click();
    await page.getByText('Weather').click();
    await page.waitForTimeout(1000);

    // Sunny theme condition description should be visible
    await expect(page.getByText('Clear sky')).toBeVisible();
  });

  test.skip('disabling Preview Mode restores live weather', async ({ page }) => {
    // Enable, select a state, then disable
    await page.getByText('Preview Mode').click();
    await page.getByText('Stormy').click();
    // Toggle off
    await page.getByText('Preview Mode').click();
    // Live weather description should return
    await page.getByText('Weather').click();
    await expect(page.getByText(/\d+°C/)).toBeVisible({ timeout: 10_000 });
  });
});
