const { test, expect } = require('@playwright/test');

test('lists the four heroes', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'My Heroes' })).toBeVisible();
  await expect(page.locator('li')).toHaveText(['Spider-Man', 'Iron Man', 'Thor', 'Hulk']);
});

test('clicking a hero shows its details and switches the page theme', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByText('Thor Details')).toHaveCount(0);
  await page.locator('li', { hasText: 'Thor' }).click();
  await expect(page.getByRole('heading', { name: 'Thor Details' })).toBeVisible();
  await expect(page.getByText('id: 3')).toBeVisible();
  await expect(page.locator('body')).toHaveClass('hero-thor');
  await page.locator('li', { hasText: 'Hulk' }).click();
  await expect(page.locator('body')).toHaveClass('hero-hulk');
});

test('unknown route falls back to the app (nginx try_files)', async ({ page }) => {
  await page.goto('/does/not/exist');
  await expect(page.getByRole('heading', { name: 'My Heroes' })).toBeVisible();
});
