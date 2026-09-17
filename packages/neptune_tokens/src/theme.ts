// Neptune Odyssey — the unified theming surface · © 2026 Neptune.Fintech (neptune.ly)
//
// One API, three ways to resolve the tenant/brand layer:
//   1. brand id      — "neptune" | "triton" | "nereid" | "proteus"
//   2. config object — a full BrandprintConfig (seeds, corners, type, levers, flags)
//   3. brandprint    — "NO1-…"  (decode → config → theme)
//
// Product personality is orthogonal to tenant identity. Pass `world` in
// ThemeOptions when the product needs a Voyage/Pulse/Market/Harbor/Grid/Canvas
// composition language. Existing calls without `world` remain byte-for-byte
// equivalent in their tenant palette, type, shape, motion, direction and
// canonical brandprint.

import { decode, encode, type BrandprintConfig } from "./brandprint/codec.js";
import { BRAND_CONFIG, BRAND_BRANDPRINT } from "./data/brands.generated.js";
import { MOTION_PRESETS } from "./data/levers.generated.js";
import { resolvePalette, matchReferenceBrand } from "./resolve.js";
import { BRANDS, type Brand, type Direction, type Mode, type Palette } from "./types.js";
import {
  resolveMotionLevel,
  resolveProductWorld,
  type MotionLevel,
  type MotionLevelTokens,
  type ProductWorld,
  type ResolvedProductWorld,
} from "./worlds.js";

export interface ThemeShape {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
  xxl: number;
  full: number;
}

export interface ThemeType {
  display: string;
  text: string;
  num: string;
  displayWeight: number;
  /** em */
  displayTracking: number;
}

export interface ThemeLevers {
  loginShell: string;
  dashboardHero: string;
  contentTone: string;
  glassTint: string;
  motion: string;
}

export interface ThemeMotion {
  ease: { standard: string; emphasized: string; spring: string };
  durMs: { fast: number; standard: number; slow: number };
  glassBlurPx: number;
}

export interface NeptuneTheme {
  /** reference brand id, or "custom" for a non-reference seed set */
  brand: Brand | "custom";
  mode: Mode;
  dir: Direction;
  colors: Palette;
  shape: ThemeShape;
  type: ThemeType;
  levers: ThemeLevers;
  motion: ThemeMotion;
  /**
   * Optional product-personality layer. This does not replace the tenant
   * palette or Brandprint contract; it supplies product-specific expressive
   * roles, geometry and display-family guidance.
   */
  world?: ResolvedProductWorld;
  /** Interaction choreography for the active product context. */
  interactionMotion?: MotionLevelTokens;
  /** canonical brandprint for this theme (idempotent round-trip) */
  brandprint: string;
}

export interface ThemeOptions {
  mode?: Mode;
  dir?: Direction;
  /** Optional product personality, independent from tenant/brand identity. */
  world?: ProductWorld;
  /** Override the world's default interaction intensity for this context. */
  motionLevel?: MotionLevel;
  /** Removes travel, stagger and overshoot while retaining a short dissolve. */
  reducedMotion?: boolean;
}

export type ThemeInput = Brand | BrandprintConfig | string;

const isBrand = (v: unknown): v is Brand =>
  typeof v === "string" && (BRANDS as readonly string[]).includes(v);

const isBrandprint = (v: unknown): v is string =>
  typeof v === "string" && v.startsWith("NO1-");

const FALLBACK_MOTION: ThemeMotion = {
  ease: {
    standard: "cubic-bezier(.2,0,0,1)",
    emphasized: "cubic-bezier(.2,0,0,1)",
    spring: "cubic-bezier(.34,1.56,.64,1)",
  },
  durMs: { fast: 240, standard: 300, slow: 500 },
  glassBlurPx: 18,
};

function shapeFromCorners(c: BrandprintConfig["corners"]): ThemeShape {
  return { xs: c.xs, sm: c.sm, md: c.md, lg: c.lg, xl: c.xl, xxl: c.xxl, full: 9999 };
}

function motionFor(motionLever: string): ThemeMotion {
  const preset = (MOTION_PRESETS as Record<string, ThemeMotion>)[motionLever];
  return preset ?? FALLBACK_MOTION;
}

/** Resolve any of the three theme inputs to a normalized BrandprintConfig. */
export function toConfig(input: ThemeInput): BrandprintConfig {
  if (isBrand(input)) return BRAND_CONFIG[input]!;
  if (isBrandprint(input)) return decode(input);
  return input;
}

/** Build a complete, platform-agnostic theme from any of the three inputs. */
export function buildTheme(input: ThemeInput, opts: ThemeOptions = {}): NeptuneTheme {
  const cfg = toConfig(input);
  const refBrand = matchReferenceBrand(cfg.primary, cfg.tertiary);
  const brand: Brand | "custom" = isBrand(input) ? input : (refBrand ?? "custom");

  const mode: Mode = opts.mode ?? (cfg.defaultDark ? "dark" : "light");
  const dir: Direction = opts.dir ?? (cfg.defaultRtl ? "rtl" : "ltr");

  const brandprint =
    isBrand(input) ? BRAND_BRANDPRINT[input]! : isBrandprint(input) ? input : encode(cfg);

  const world = opts.world ? resolveProductWorld(opts.world, mode) : undefined;
  const interactionLevel = opts.motionLevel ?? world?.defaultMotionLevel;
  const interactionMotion = interactionLevel
    ? resolveMotionLevel(interactionLevel, opts.reducedMotion ?? false)
    : undefined;

  return {
    brand,
    mode,
    dir,
    colors: resolvePalette(cfg.primary, cfg.tertiary, mode),
    shape: shapeFromCorners(cfg.corners),
    type: {
      display: cfg.fonts.display,
      text: cfg.fonts.text,
      num: cfg.fonts.num,
      displayWeight: cfg.displayWeight,
      displayTracking: cfg.displayTracking,
    },
    levers: {
      loginShell: cfg.loginShell,
      dashboardHero: cfg.dashboardHero,
      contentTone: cfg.contentTone,
      glassTint: cfg.glassTint,
      motion: cfg.motion,
    },
    motion: motionFor(cfg.motion),
    ...(world ? { world } : {}),
    ...(interactionMotion ? { interactionMotion } : {}),
    brandprint,
  };
}

/** The canonical brandprint for a reference brand. */
export function brandprintFor(brand: Brand): string {
  return BRAND_BRANDPRINT[brand]!;
}
