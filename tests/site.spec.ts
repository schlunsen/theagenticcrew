import { test, expect } from '@playwright/test';

test.describe('The Agentic Crew Website', () => {
  test('homepage loads with correct title', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/Agentic Crew/);
  });

  test('hero section is visible', async ({ page }) => {
    await page.goto('/');
    const hero = page.locator('#hero, .hero, section').first();
    await expect(hero).toBeVisible();
  });

  test('download section exists with language tabs', async ({ page }) => {
    await page.goto('/');
    const downloadSection = page.locator('#download');
    await expect(downloadSection).toBeVisible();

    // Check adult book language tabs
    await expect(page.locator('.lang-tab').filter({ hasText: 'English' })).toBeVisible();
    await expect(page.locator('.lang-tab').filter({ hasText: 'Español' })).toBeVisible();
    await expect(page.locator('.lang-tab').filter({ hasText: 'Català' })).toBeVisible();
    await expect(page.locator('.lang-tab').filter({ hasText: 'Dansk' })).toBeVisible();
  });

  test('adult book PDF downloads are available', async ({ page }) => {
    const pdfs = [
      '/the-agentic-crew.pdf',
      '/the-agentic-crew-es.pdf',
      '/the-agentic-crew-ca.pdf',
      '/the-agentic-crew-da.pdf',
    ];

    for (const pdf of pdfs) {
      const response = await page.request.get(pdf);
      expect(response.status(), `${pdf} should be available`).toBe(200);
    }
  });

  test('adult book EPUB downloads are available', async ({ page }) => {
    const epubs = [
      '/the-agentic-crew.epub',
      '/the-agentic-crew-es.epub',
      '/the-agentic-crew-ca.epub',
      '/the-agentic-crew-da.epub',
    ];

    for (const epub of epubs) {
      const response = await page.request.get(epub);
      expect(response.status(), `${epub} should be available`).toBe(200);
    }
  });

  test('language tab switching works for adult book', async ({ page }) => {
    await page.goto('/');

    // Click Spanish tab
    await page.locator('.lang-tab').filter({ hasText: 'Español' }).click();

    // Verify Spanish panel is now visible
    const esPanel = page.locator('.lang-panel[data-lang="es"]');
    await expect(esPanel).toBeVisible();
    await expect(esPanel.locator('.lang-title')).toHaveText('La Tripulación Agéntica');
  });

  test('buy me a coffee link is present', async ({ page }) => {
    await page.goto('/');
    const coffeeLink = page.locator('a[href*="buymeacoffee"]');
    await expect(coffeeLink).toBeVisible();
  });

  test('takes a full page screenshot', async ({ page }) => {
    await page.goto('/');
    await page.waitForTimeout(2000); // Wait for animations
    await page.screenshot({
      path: 'tests/screenshots/full-page.png',
      fullPage: true,
    });
  });
});
