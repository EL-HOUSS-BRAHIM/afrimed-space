// Run with Node and Playwright. A temporary localhost server is closed after QA.
const assert = require('node:assert/strict');
const http = require('node:http');
const fs = require('node:fs/promises');
const path = require('node:path');
const { chromium } = require('playwright');
const root = path.resolve(__dirname, '../lyvora-site');
const types = { '.html': 'text/html', '.css': 'text/css', '.png': 'image/png', '.xml': 'application/xml', '.txt': 'text/plain' };

(async () => {
  const server = http.createServer(async (req, res) => {
    try {
      const url = new URL(req.url, 'http://localhost');
      const file = path.resolve(root, '.' + decodeURIComponent(url.pathname === '/' ? '/index.html' : url.pathname));
      if (!file.startsWith(root + path.sep)) { res.writeHead(403).end(); return; }
      const body = await fs.readFile(file);
      res.writeHead(200, { 'Content-Type': types[path.extname(file)] || 'application/octet-stream' }).end(body);
    } catch { res.writeHead(404).end(); }
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  let browser;
  try {
    browser = await chromium.launch({ channel: process.env.BROWSER_CHANNEL || undefined });
    const base = `http://127.0.0.1:${server.address().port}`;
    const errors = [];
    let cases = 0;
    for (const width of [320, 390, 768, 1024, 1440]) {
      const page = await browser.newPage({ viewport: { width, height: 900 } });
      page.on('pageerror', error => errors.push(error.message));
      for (const route of ['/', '/download.html', '/404.html']) {
        const response = await page.goto(base + route);
        assert.equal(response.status(), 200);
        await page.locator('body').scrollIntoViewIfNeeded();
        await page.evaluate(async () => { await Promise.all([...document.images].map(img => img.decode())); });
        assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, `Overflow at ${width} on ${route}`);
        assert.equal(await page.locator('h1').count(), 1);
        for (const src of await page.locator('link[rel="stylesheet"], img').evaluateAll(nodes => nodes.map(n => n.href || n.src))) {
          assert.equal((await page.request.get(src)).status(), 200, src);
        }
        if (route === '/') {
          await page.keyboard.press('Tab');
          assert.equal(await page.locator(':focus').textContent(), 'Skip to content');
          await page.keyboard.press('Enter');
          assert.equal(new URL(page.url()).hash, '#main');
          await page.getByRole('link', { name: 'Questions', exact: true }).click();
          const summary = page.locator('summary').first();
          await summary.focus();
          await page.keyboard.press('Enter');
          assert.equal(await page.locator('details').first().getAttribute('open'), '');
          await page.getByRole('link', { name: 'Get Lyvora' }).click();
          assert.equal(new URL(page.url()).pathname, '/download.html');
        }
        if (route === '/download.html') {
          assert.equal(await page.getByRole('link', { name: 'Download APK' }).getAttribute('href'), '/downloads/current/lyvora-preview.apk');
          assert.equal(await page.locator('link[rel="canonical"]').getAttribute('href'), 'https://lyvora-finance.tech/download.html');
        }
        await page.emulateMedia({ reducedMotion: 'reduce' });
        assert.equal(await page.evaluate(() => getComputedStyle(document.documentElement).scrollBehavior), 'auto');
        await page.emulateMedia({ reducedMotion: 'no-preference' });
        cases++;
      }
      // Large text should reflow without hiding or horizontally clipping content.
      await page.goto(base);
      await page.addStyleTag({ content: 'body { font-size: 200%; }' });
      assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true);
      await page.close();
    }
    assert.deepEqual(errors, []);
    console.log(`Passed ${cases} localhost page/viewport cases, keyboard FAQ and navigation, download links, assets and reduced motion.`);
  } finally {
    if (browser) await browser.close();
    await new Promise(resolve => server.close(resolve));
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
