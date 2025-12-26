import { expect, test } from "@playwright/test";

const BASE_URL = process.env.PMPL_WEB_URL || "https://staging.example.com";

// Minimal E2E: login, add product, checkout (happy path)
test("order to payment flow", async ({ page }) => {
  await page.goto(`${BASE_URL}/login`);
  await page.fill("input[name=email]", "qa+valid@example.com");
  await page.fill("input[name=password]", "Password123!");
  await page.click("button[type=submit]");
  await expect(page).toHaveURL(/dashboard/);

  await page.click("text=Tambah Produk");
  await page.fill("input[name=productName]", "Kemeja Flanel QA");
  await page.fill("input[name=price]", "150000");
  await page.setInputFiles("input[type=file]", "./fixtures/sample-shirt.jpg");
  await page.click("text=Simpan");

  await page.click("text=Kemeja Flanel QA");
  await page.click("text=Tambah ke Keranjang");
  await page.click("text=Checkout");
  await page.click("text=Bayar");

  await expect(page.locator("text=Terima kasih"))
    .toBeVisible({ timeout: 10000 });
});
