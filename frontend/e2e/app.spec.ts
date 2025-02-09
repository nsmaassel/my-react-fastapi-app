import { test, expect } from '@playwright/test';

const API_BASE_URL = process.env.API_BASE_URL || 'http://backend:8000';
const DEBUG = process.env.DEBUG === 'true';

test.describe('Frontend-Backend Integration', () => {
  test.beforeEach(async ({ page }) => {
    if (DEBUG) {
      page.on('console', msg => console.log(msg.text()));
      page.on('pageerror', err => console.error(err));
      page.on('requestfailed', request =>
        console.error(`Request failed: ${request.url()}`));
      page.on('response', response =>
        console.log(`${response.status()} ${response.url()}`));
    }

    await page.goto('/', { waitUntil: 'networkidle' });
  });

  test('displays the frontend UI and backend health status', async ({ page }) => {
    // Check page title
    await expect(page).toHaveTitle('React + FastAPI Docker Demo');
    
    // Check main heading
    const heading = page.getByRole('heading', { name: 'React + FastAPI Demo', exact: true });
    await expect(heading).toBeVisible();
    
    // Verify backend health status is displayed
    await expect(page.getByRole('heading', { name: 'Backend Status', exact: true })).toBeVisible();
    await expect(page.locator('.badge')).toHaveText('ok');
    
    // Check that feature tags are displayed
    const featureTags = page.locator('.feature-tag');
    await expect(featureTags).toHaveCount(5);
    await expect(featureTags.first()).toBeVisible();
  });

  test('loads and displays technology items from backend', async ({ page }) => {
    // Wait for items to load
    await page.waitForSelector('.item-card');
    
    // Check that all items are displayed
    const items = page.locator('.item-card');
    await expect(items).toHaveCount(5);
    
    // Verify Docker item details
    const dockerItem = items.filter({ hasText: 'Docker' });
    await expect(dockerItem).toBeVisible();
    await expect(dockerItem).toHaveAttribute('href', 'https://www.docker.com/');
    
    // Verify FastAPI item details
    const fastapiItem = items.filter({ hasText: 'FastAPI' });
    await expect(fastapiItem).toBeVisible();
    await expect(fastapiItem).toHaveAttribute('href', 'https://fastapi.tiangolo.com/');
  });

  test('handles backend connection errors gracefully', async ({ page }) => {
    // Simulate backend failure by requesting non-existent endpoint
    const response = await page.request.get(`${API_BASE_URL}/api/nonexistent`, {
      failOnStatusCode: false
    });
    expect(response.status()).toBe(404);
    
    // Navigate to frontend and verify error handling
    await page.route('/api/**', route => route.abort());
    await page.reload();
    
    await expect(page.locator('.error')).toBeVisible();
    await expect(page.getByText('Connection Error', { exact: true })).toBeVisible();
  });

  test('verifies API documentation link', async ({ page }) => {
    const docsLink = page.locator('footer').getByRole('link', { name: 'API Documentation', exact: true });
    await expect(docsLink).toBeVisible();
    await expect(docsLink).toHaveAttribute('href', '/api/docs');
  });
});