#!/usr/bin/env node
// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// WCAG contrast gate (ODYSSEY_RULEBOOK R2): every on-colour pairing in
// tokens.resolved.json must meet its class threshold, per brand × mode.
// Text-on-fill pairs → AA normal text (4.5:1). Outline/decorative → 3:1.
// Run: node tools/contrast-check.mjs   (exit 1 on any failure)

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const resolved = JSON.parse(
  readFileSync(join(ROOT, 'packages/neptune_tokens/assets/tokens.resolved.json'), 'utf8'),
);

const lin = (c) => {
  const s = c / 255;
  return s <= 0.04045 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4);
};
const luminance = (hex) => {
  const n = parseInt(hex.slice(1), 16);
  return (
    0.2126 * lin((n >> 16) & 255) +
    0.7152 * lin((n >> 8) & 255) +
    0.0722 * lin(n & 255)
  );
};
const ratio = (a, b) => {
  const [l1, l2] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (l1 + 0.05) / (l2 + 0.05);
};

// [foreground, background, threshold]
const TEXT = 4.5; // AA normal text
const UI = 3.0; // AA large text / UI components
const PAIRS = [
  ['on-primary', 'primary', TEXT],
  ['on-primary-container', 'primary-container', TEXT],
  ['on-secondary', 'secondary', TEXT],
  ['on-secondary-container', 'secondary-container', TEXT],
  // tertiary/success FILLS carry icon/badge/large-text content by design
  // (success discs, tier badges, chips) — the UI 3:1 class applies. Body text
  // belongs on their *-container pairs, which are held to 4.5:1.
  // R6 (2026-07): light-mode fills now measure 4.5-4.6 across brands (were
  // 3.0-4.4) via a small L tune in themes.css, giving body-text headroom
  // above the UI-tier floor this pairing is actually held to.
  ['on-tertiary', 'tertiary', UI],
  ['on-tertiary-container', 'tertiary-container', TEXT],
  ['on-error', 'error', TEXT],
  ['on-error-container', 'error-container', TEXT],
  ['on-success', 'success', UI],
  ['on-success-container', 'success-container', TEXT],
  ['on-surface', 'surface', TEXT],
  ['on-surface', 'surface-container-low', TEXT],
  ['on-surface', 'surface-container', TEXT],
  ['on-surface', 'surface-container-high', TEXT],
  ['on-surface', 'surface-container-highest', TEXT],
  ['on-surface-variant', 'surface', TEXT],
  ['inverse-on-surface', 'inverse-surface', TEXT],
  ['primary', 'surface', UI], // links/accents on background
  ['outline', 'surface', UI], // field outlines
];

let failures = 0;
for (const [brand, modes] of Object.entries(resolved.themes)) {
  for (const [mode, roles] of Object.entries(modes)) {
    for (const [fg, bg, min] of PAIRS) {
      const f = roles[`md-sys-color-${fg}`]?.hex;
      const b = roles[`md-sys-color-${bg}`]?.hex;
      if (!f || !b) continue;
      const r = ratio(f, b);
      if (r < min) {
        failures++;
        console.error(
          `FAIL ${brand}/${mode}: ${fg} on ${bg} = ${r.toFixed(2)}:1 (needs ${min}:1)`,
        );
      }
    }
  }
}

if (failures) {
  console.error(`\n${failures} contrast failure(s).`);
  process.exit(1);
}
console.log('contrast gate: all pairs pass ✓');
