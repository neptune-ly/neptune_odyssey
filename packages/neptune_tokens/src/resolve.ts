// Neptune Odyssey — palette resolution (pinned reference + generated custom) ·
// © 2026 Neptune.Fintech (neptune.ly)

import { RESOLVED } from "./data/resolved.generated.js";
import { BRAND_SEEDS } from "./data/seeds.generated.js";
import { generatePalette } from "./color/palette.js";
import type { Oklch } from "./color/oklch.js";
import { COLOR_ROLES, type Brand, type ColorRole, type Mode, type Palette } from "./types.js";

const PREFIX = "md-sys-color-";

/** The pinned canonical palette for a reference brand+mode (== tokens.resolved.json). */
export function getResolvedPalette(brand: Brand, mode: Mode): Palette {
  const src = RESOLVED[brand][mode] as Record<string, { hex: string; argb: string }>;
  const out = {} as Palette;
  for (const role of COLOR_ROLES) out[role] = src[`${PREFIX}${role}`]!.hex;
  return out;
}

/** ARGB form of a reference palette (for Flutter codegen / parity checks). */
export function getResolvedArgb(brand: Brand, mode: Mode): Record<ColorRole, string> {
  const src = RESOLVED[brand][mode] as Record<string, { hex: string; argb: string }>;
  const out = {} as Record<ColorRole, string>;
  for (const role of COLOR_ROLES) out[role] = src[`${PREFIX}${role}`]!.argb;
  return out;
}

const seedClose = (a: Oklch, b: Oklch): boolean =>
  Math.abs(a.L - b.L) <= 1 / 255 + 1e-9 &&
  Math.abs(a.C - b.C) <= 1e-3 + 1e-9 &&
  Math.abs(a.H - b.H) <= 0.5;

/**
 * If the given seeds match a reference brand (within brandprint quantisation
 * tolerance), return that brand id — so reference brandprints resolve to the
 * pinned palette and stay equal to tokens.resolved.json.
 */
export function matchReferenceBrand(primary: Oklch, tertiary: Oklch): Brand | null {
  for (const brand of Object.keys(BRAND_SEEDS) as Brand[]) {
    const s = BRAND_SEEDS[brand];
    if (seedClose(primary, s.primary) && seedClose(tertiary, s.tertiary)) return brand;
  }
  return null;
}

/**
 * Resolve a palette from seeds: pinned canonical data for reference brands,
 * otherwise the deterministic v1 ramp. Same logic on every platform.
 */
export function resolvePalette(primary: Oklch, tertiary: Oklch, mode: Mode): Palette {
  const ref = matchReferenceBrand(primary, tertiary);
  if (ref) return getResolvedPalette(ref, mode);
  return generatePalette(primary, tertiary, mode);
}
