#!/usr/bin/env node
// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Composer has no concept of pulling in an npm package's built output, so a
// Laravel app installing this via Composer needs the web-ui's compiled JS/CSS
// vendored INTO this package (checked in, not resolved at install time —
// exactly how most Laravel UI packages ship a JS frontend, e.g. Breeze).
// Run this after any @neptune.fintech/web-ui build to keep the vendored copy
// in sync: node tools/sync-assets.mjs

import { cpSync, mkdirSync, existsSync, rmSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const PKG_ROOT = join(HERE, '..');
const WEB_UI = join(PKG_ROOT, '..', 'neptune_web_ui');
const OUT = join(PKG_ROOT, 'resources', 'dist');

if (!existsSync(join(WEB_UI, 'dist'))) {
  console.error(`No build found at ${join(WEB_UI, 'dist')} — run the web-ui package's build first.`);
  process.exit(1);
}

rmSync(OUT, { recursive: true, force: true });
mkdirSync(OUT, { recursive: true });
cpSync(join(WEB_UI, 'dist'), join(OUT, 'js'), { recursive: true });
cpSync(join(WEB_UI, 'styles', 'neptune-odyssey.css'), join(OUT, 'neptune-odyssey.css'));
cpSync(join(WEB_UI, 'styles', 'themes.css'), join(OUT, 'themes.css'));

console.log(`Synced web-ui dist + styles into ${OUT}`);
console.log('Remember to bump this package\'s version to match @neptune.fintech/web-ui\'s.');
