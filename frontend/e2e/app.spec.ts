import { test, expect } from '@playwright/test';

const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:8000';
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

    await page.goto('/', { waitUntil: 'networkidle', timeout: 30000 });
  });

  test('displays the frontend UI and backend health status', async ({ page }) => {
    // Check page title
    await expect(page).toHaveTitle('React + FastAPI Docker Demo', { timeout: 10000 });
    
    // Check main heading
    const heading = page.getByRole('heading', { name: 'React + FastAPI Demo', exact: true });
    await expect(heading).toBeVisible({ timeout: 10000 });
    
    // Verify backend health status is displayed
    await expect(page.getByRole('heading', { name: 'Backend Status', exact: true })).toBeVisible({ timeout: 10000 });
    await expect(page.locator('.badge')).toHaveText('ok', { timeout: 10000 });
    
    // Check that feature tags are displayed
    const featureTags = page.locator('.feature-tag');
    await expect(featureTags).toHaveCount(7, { timeout: 10000 });
    await expect(featureTags.first()).toBeVisible({ timeout: 10000 });
  });

  test('loads and displays technology items from backend', async ({ page }) => {
    // Wait for items to load
    await page.waitForSelector('.item-card', { timeout: 30000 });
    
    // Check that all items are displayed
    const items = page.locator('.item-card');
    await expect(items).toHaveCount(7, { timeout: 10000 });
    
    // Verify Docker item details
    const dockerItem = items.filter({ hasText: 'Docker' });
    await expect(dockerItem).toBeVisible({ timeout: 10000 });
    await expect(dockerItem).toHaveAttribute('href', 'https://www.docker.com/', { timeout: 10000 });
    
    // Verify FastAPI item details
    const fastapiItem = items.filter({ hasText: 'FastAPI' });
    await expect(fastapiItem).toBeVisible({ timeout: 10000 });
    await expect(fastapiItem).toHaveAttribute('href', 'https://fastapi.tiangolo.com/', { timeout: 10000 });

    // Verify Azure Container Apps item details
    const azureItem = items.filter({ hasText: 'Azure Container Apps' });
    await expect(azureItem).toBeVisible({ timeout: 10000 });
    await expect(azureItem).toHaveAttribute('href', 'https://azure.microsoft.com/en-us/services/container-apps/', { timeout: 10000 });

    // Verify GitHub Actions item details
    const githubActionsItem = items.filter({ hasText: 'GitHub Actions' });
    await expect(githubActionsItem).toBeVisible({ timeout: 10000 });
    await expect(githubActionsItem).toHaveAttribute('href', 'https://github.com/features/actions', { timeout: 10000 });
  });

  test('handles backend connection errors gracefully', async ({ page }) => {
    // Simulate backend failure by requesting non-existent endpoint
    const response = await page.request.get(`${API_BASE_URL}/api/nonexistent`, {
      failOnStatusCode: false,
      timeout: 10000
    });
    expect(response.status()).toBe(404);
    
    // Navigate to frontend and verify error handling
    await page.route('/api/**', route => route.abort());
    await page.reload({ waitUntil: 'networkidle', timeout: 30000 });
    
    await expect(page.locator('.error')).toBeVisible({ timeout: 10000 });
    await expect(page.getByText('Connection Error', { exact: true })).toBeVisible({ timeout: 10000 });
  });

  test('verifies API documentation link', async ({ page }) => {
    const docsLink = page.locator('footer').getByRole('link', { name: 'API Documentation', exact: true });
    await expect(docsLink).toBeVisible({ timeout: 10000 });
    await expect(docsLink).toHaveAttribute('href', '/api/docs', { timeout: 10000 });
  });
});