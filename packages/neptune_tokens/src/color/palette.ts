// Neptune Odyssey — seed → palette (the v1 OKLCH ramp) · © 2026 Neptune.Fintech (neptune.ly)
//
// ONE palette-generation algorithm from a seed, shared by every platform (docs/11
// "Determinism"). This is the documented Odyssey OKLCH ramp used for CUSTOM seeds
// (the configurator). The four REFERENCE brands resolve via the pinned canonical
// palette (data/resolved.generated.ts) so they equal tokens.resolved.json exactly;
// resolvePalette() routes reference seeds to that pinned data and custom seeds here.
//
// The ramp keeps each role's hue from its source channel and places it at a fixed
// perceptual lightness with a chroma derived from the seed, tuned to the Neptune
// baseline. Pinned for v1; any change bumps the brandprint version (NO2-).

import { oklchToHex, type Oklch } from "./oklch.js";
import type { ColorRole, Palette } from "../types.js";

type HueSource = "primary" | "tertiary" | "neutral" | number;

interface RoleRecipe {
  L: number;
  /** chroma as an absolute value (number) or a multiplier of the source seed chroma (mult) */
  C: number | { mult: number };
  hue: HueSource;
}

// Fixed semantic hues (error/success are brand-invariant for trust + legibility).
const ERROR_H = 27;
const SUCCESS_H = 152;

// Light-mode ramp (role -> recipe). Mirrors the Neptune baseline tuning.
const LIGHT: Record<ColorRole, RoleRecipe> = {
  primary: { L: 0.48, C: { mult: 1 }, hue: "primary" },
  "on-primary": { L: 0.99, C: 0.02, hue: "primary" },
  "primary-container": { L: 0.91, C: { mult: 0.47 }, hue: "primary" },
  "on-primary-container": { L: 0.22, C: { mult: 0.87 }, hue: "primary" },
  secondary: { L: 0.5, C: 0.06, hue: "primary" },
  "on-secondary": { L: 0.99, C: 0.02, hue: "primary" },
  "secondary-container": { L: 0.92, C: 0.035, hue: "primary" },
  "on-secondary-container": { L: 0.25, C: 0.05, hue: "primary" },
  tertiary: { L: 0.55, C: { mult: 1 }, hue: "tertiary" },
  "on-tertiary": { L: 0.99, C: 0.02, hue: "tertiary" },
  "tertiary-container": { L: 0.9, C: { mult: 0.6 }, hue: "tertiary" },
  "on-tertiary-container": { L: 0.26, C: { mult: 0.8 }, hue: "tertiary" },
  error: { L: 0.52, C: 0.2, hue: ERROR_H },
  "on-error": { L: 0.99, C: 0.02, hue: ERROR_H },
  "error-container": { L: 0.92, C: 0.07, hue: ERROR_H },
  "on-error-container": { L: 0.28, C: 0.16, hue: ERROR_H },
  success: { L: 0.58, C: 0.13, hue: SUCCESS_H },
  "on-success": { L: 0.99, C: 0.02, hue: SUCCESS_H },
  "success-container": { L: 0.9, C: 0.07, hue: SUCCESS_H },
  "on-success-container": { L: 0.26, C: 0.1, hue: SUCCESS_H },
  background: { L: 0.985, C: 0.006, hue: "neutral" },
  "on-background": { L: 0.16, C: 0.02, hue: "neutral" },
  surface: { L: 0.985, C: 0.006, hue: "neutral" },
  "on-surface": { L: 0.16, C: 0.02, hue: "neutral" },
  "surface-variant": { L: 0.9, C: 0.018, hue: "neutral" },
  "on-surface-variant": { L: 0.4, C: 0.025, hue: "neutral" },
  outline: { L: 0.62, C: 0.02, hue: "neutral" },
  "outline-variant": { L: 0.86, C: 0.015, hue: "neutral" },
  "surface-container-lowest": { L: 1, C: 0, hue: "neutral" },
  "surface-container-low": { L: 0.965, C: 0.006, hue: "neutral" },
  "surface-container": { L: 0.945, C: 0.008, hue: "neutral" },
  "surface-container-high": { L: 0.925, C: 0.01, hue: "neutral" },
  "surface-container-highest": { L: 0.905, C: 0.012, hue: "neutral" },
  "inverse-surface": { L: 0.24, C: 0.02, hue: "neutral" },
  "inverse-on-surface": { L: 0.96, C: 0.006, hue: "neutral" },
  "inverse-primary": { L: 0.82, C: { mult: 0.8 }, hue: "primary" },
  scrim: { L: 0.08, C: 0.02, hue: "neutral" },
};

// Dark-mode ramp.
const DARK: Record<ColorRole, RoleRecipe> = {
  primary: { L: 0.8, C: { mult: 0.8 }, hue: "primary" },
  "on-primary": { L: 0.2, C: { mult: 0.67 }, hue: "primary" },
  "primary-container": { L: 0.36, C: { mult: 0.8 }, hue: "primary" },
  "on-primary-container": { L: 0.9, C: { mult: 0.47 }, hue: "primary" },
  secondary: { L: 0.82, C: 0.04, hue: "primary" },
  "on-secondary": { L: 0.22, C: 0.04, hue: "primary" },
  "secondary-container": { L: 0.34, C: 0.04, hue: "primary" },
  "on-secondary-container": { L: 0.9, C: 0.035, hue: "primary" },
  tertiary: { L: 0.82, C: { mult: 0.8 }, hue: "tertiary" },
  "on-tertiary": { L: 0.22, C: { mult: 0.6 }, hue: "tertiary" },
  "tertiary-container": { L: 0.34, C: { mult: 0.7 }, hue: "tertiary" },
  "on-tertiary-container": { L: 0.9, C: { mult: 0.6 }, hue: "tertiary" },
  error: { L: 0.78, C: 0.13, hue: ERROR_H },
  "on-error": { L: 0.24, C: 0.1, hue: ERROR_H },
  "error-container": { L: 0.36, C: 0.14, hue: ERROR_H },
  "on-error-container": { L: 0.92, C: 0.06, hue: ERROR_H },
  success: { L: 0.78, C: 0.12, hue: SUCCESS_H },
  "on-success": { L: 0.22, C: 0.08, hue: SUCCESS_H },
  "success-container": { L: 0.34, C: 0.1, hue: SUCCESS_H },
  "on-success-container": { L: 0.9, C: 0.07, hue: SUCCESS_H },
  background: { L: 0.13, C: 0.012, hue: "neutral" },
  "on-background": { L: 0.92, C: 0.01, hue: "neutral" },
  surface: { L: 0.13, C: 0.012, hue: "neutral" },
  "on-surface": { L: 0.92, C: 0.01, hue: "neutral" },
  "surface-variant": { L: 0.34, C: 0.02, hue: "neutral" },
  "on-surface-variant": { L: 0.78, C: 0.02, hue: "neutral" },
  outline: { L: 0.58, C: 0.02, hue: "neutral" },
  "outline-variant": { L: 0.32, C: 0.02, hue: "neutral" },
  "surface-container-lowest": { L: 0.09, C: 0.012, hue: "neutral" },
  "surface-container-low": { L: 0.16, C: 0.014, hue: "neutral" },
  "surface-container": { L: 0.18, C: 0.016, hue: "neutral" },
  "surface-container-high": { L: 0.22, C: 0.018, hue: "neutral" },
  "surface-container-highest": { L: 0.27, C: 0.02, hue: "neutral" },
  "inverse-surface": { L: 0.92, C: 0.01, hue: "neutral" },
  "inverse-on-surface": { L: 0.2, C: 0.02, hue: "neutral" },
  "inverse-primary": { L: 0.48, C: { mult: 1 }, hue: "primary" },
  scrim: { L: 0, C: 0, hue: "neutral" },
};

function resolveHue(src: HueSource, primaryH: number, tertiaryH: number): number {
  if (typeof src === "number") return src;
  if (src === "tertiary") return tertiaryH;
  return primaryH; // primary + neutral both ride the primary hue
}

function resolveChroma(c: number | { mult: number }, seedC: number): number {
  return typeof c === "number" ? c : seedC * c.mult;
}

/**
 * Generate a full 37-role palette from primary + tertiary seeds via the v1 ramp.
 * Used for custom (non-reference) seeds. Deterministic and platform-shared.
 */
export function generatePalette(primary: Oklch, tertiary: Oklch, mode: "light" | "dark"): Palette {
  const ramp = mode === "light" ? LIGHT : DARK;
  const out = {} as Palette;
  for (const role of Object.keys(ramp) as ColorRole[]) {
    const recipe = ramp[role];
    const hue = resolveHue(recipe.hue, primary.H, tertiary.H);
    const seedC = recipe.hue === "tertiary" ? tertiary.C : primary.C;
    const C = resolveChroma(recipe.C, seedC);
    out[role] = oklchToHex({ L: recipe.L, C, H: hue });
  }
  return out;
}
