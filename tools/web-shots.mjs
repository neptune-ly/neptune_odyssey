#!/usr/bin/env node
// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Web visual sweep (ODYSSEY_RULEBOOK R2): render the published site's template
// pages per brand × mode with Playwright and save full-page screenshots for
// the blank-check + CI artifacts.
//
// Usage: node tools/web-shots.mjs <out-dir>   (requires `playwright` dev dep
// and `npx playwright install chromium`)

import { createServer } from 'node:http';
import { readFileSync, mkdirSync, existsSync } from 'node:fs';
import { extname, join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const OUT = process.argv[2] ?? '/tmp/npt-web-shots';
mkdirSync(OUT, { recursive: true });

const MIME = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'text/javascript',
  '.mjs': 'text/javascript',
  '.json': 'application/json',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.woff2': 'font/woff2',
};

// Static server over the repo (site/ references ../packages assets).
const server = createServer((req, res) => {
  const path = join(ROOT, decodeURIComponent(new URL(req.url, 'http://x').pathname));
  if (!existsSync(path) || !path.startsWith(ROOT)) {
    res.writeHead(404).end();
    return;
  }
  res.writeHead(200, { 'content-type': MIME[extname(path)] ?? 'application/octet-stream' });
  res.end(readFileSync(path));
});
await new Promise((r) => server.listen(0, r));
const port = server.address().port;

const BRANDS = ['neptune', 'triton', 'nereid', 'proteus'];
const PAGES = ['site/templates.html', 'site/system.html'];

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });

for (const path of PAGES) {
  const slug = path.split('/').pop().replace('.html', '');
  for (const brand of BRANDS) {
    for (const mode of ['light', 'dark']) {
      await page.goto(`http://127.0.0.1:${port}/${path}`, { waitUntil: 'networkidle' });
      await page.evaluate(
        ([b, m]) => {
          // The site pages theme a single wrapper (e.g. #frames) — flip that;
          // fall back to body for plain pages.
          const el = document.querySelector('[data-theme]') ?? document.body;
          el.setAttribute('data-theme', b);
          el.setAttribute('data-mode', m);
        },
        [brand, mode],
      );
      await page.waitForTimeout(400); // fonts/motifs settle
      await page.screenshot({
        path: join(OUT, `${slug}_${brand}_${mode}.png`),
        fullPage: false, // viewport-sized: keeps shots comparable + fast
      });
      console.log(`shot ${slug}_${brand}_${mode}.png`);
    }
  }
}

await browser.close();
server.close();
console.log(`web shots → ${OUT}`);
