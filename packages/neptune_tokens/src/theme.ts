// Neptune Odyssey — the unified theming surface · © 2026 Neptune.Fintech (neptune.ly)
//
// One API, three ways to theme (docs · HANDOFF_PROMPT "The theming API"):
//   1. brand id      — "neptune" | "triton" | "nereid" | "proteus"
//   2. config object — a full BrandprintConfig (seeds, corners, type, levers, flags)
//   3. brandprint    — "NO1-…"  (decode → config → theme)
// Same brandprint ⇒ identical theme on every platform.

import { decode, encode, type BrandprintConfig } from "./brandprint/codec.js";
import { BRAND_CONFIG, BRAND_BRANDPRINT } from "./data/brands.generated.js";
import { MOTION_PRESETS } from "./data/levers.generated.js";
import { odyssey3Expressions, odyssey3Foundation, odyssey3Schemes } from "./generated/tokens.g.js";
import { resolvePalette, matchReferenceBrand } from "./resolve.js";
import { BRANDS, type Brand, type Direction, type Mode, type Palette } from "./types.js";

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

export type OdysseyEdition = "v1" | "odyssey3";
export type OdysseyProduct = "banking" | "wallet" | "drive" | "orbit";
export interface OdysseyExpression {
  product: OdysseyProduct;
  colors: Record<"paper" | "ink" | "action" | "on-action" | "signature" | "tint" | "muted" | "line" | "pending" | "pending-container" | "info" | "info-container" | "focus" | "disabled" | "on-disabled", string>;
  fonts: { en: string; ar: string };
  motionMs: { feedback: number; navigate: number; reveal: number; celebrate: number };
  reducedMotion: boolean;
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
  /** Present only when the caller explicitly selects the Odyssey 3 expression profile. */
  expression?: OdysseyExpression;
  /** canonical brandprint for this theme (idempotent round-trip) */
  brandprint: string;
}

export interface ThemeOptions {
  mode?: Mode;
  dir?: Direction;
  edition?: OdysseyEdition;
  product?: OdysseyProduct;
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

// The Odyssey 3 foundation ends at XL. NeptuneTheme retains its legacy 2XL
// slot, so it resolves to the largest canonical Odyssey radius.
const ODYSSEY3_SHAPE: ThemeShape = {
  xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 32, full: 999,
};

function shapeFromCorners(c: BrandprintConfig["corners"]): ThemeShape {
  return { xs: c.xs, sm: c.sm, md: c.md, lg: c.lg, xl: c.xl, xxl: c.xxl, full: 9999 };
}

function motionFor(motionLever: string): ThemeMotion {
  const preset = (MOTION_PRESETS as Record<string, ThemeMotion>)[motionLever];
  return preset ?? FALLBACK_MOTION;
}

function odyssey3Type(dir: Direction): ThemeType {
  const font = dir === "rtl" ? odyssey3Foundation.fonts.ar : odyssey3Foundation.fonts.en;
  return {
    display: font,
    text: font,
    num: odyssey3Foundation.fonts.numeric,
    displayWeight: 700,
    displayTracking: 0,
  };
}

function odyssey3Motion(motionLever: string, reducedMotion: boolean): ThemeMotion {
  const base = motionFor(motionLever);
  const durations = reducedMotion ? odyssey3Foundation.motionMs.reduced : odyssey3Foundation.motionMs.full;
  return {
    ...base,
    durMs: { fast: durations.feedback, standard: durations.navigate, slow: durations.reveal },
  };
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

  const edition = opts.edition ?? "v1";
  const baseColors = resolvePalette(cfg.primary, cfg.tertiary, mode);
  const product = opts.product ?? "banking";
  const productKey = product === "drive" || product === "orbit" ? product : "core";
  const profile = edition === "odyssey3" && product !== "banking"
    ? odyssey3Expressions[productKey][mode]
    : null;
  const expressionColors = profile ? profile : {
    paper: baseColors.background, ink: baseColors["on-background"], action: baseColors.primary,
    "on-action": baseColors["on-primary"], signature: baseColors.tertiary, tint: baseColors["secondary-container"],
    muted: baseColors["on-surface-variant"], line: baseColors["outline-variant"], focus: baseColors.primary,
    ...odyssey3Foundation.extras[mode],
  };
  const colors = profile ? odyssey3Schemes[productKey][mode] : baseColors;
  const isOdyssey3 = edition === "odyssey3";
  return {
    brand,
    mode,
    dir,
    colors,
    shape: isOdyssey3 ? { ...ODYSSEY3_SHAPE } : shapeFromCorners(cfg.corners),
    type: isOdyssey3 ? odyssey3Type(dir) : {
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
    motion: isOdyssey3 ? odyssey3Motion(cfg.motion, opts.reducedMotion ?? false) : motionFor(cfg.motion),
    expression: edition === "odyssey3" ? {
      product, colors: expressionColors, fonts: odyssey3Foundation.fonts,
      motionMs: opts.reducedMotion ? odyssey3Foundation.motionMs.reduced : odyssey3Foundation.motionMs.full,
      reducedMotion: opts.reducedMotion ?? false,
    } : undefined,
    brandprint,
  };
}

/** The canonical brandprint for a reference brand. */
export function brandprintFor(brand: Brand): string {
  return BRAND_BRANDPRINT[brand]!;
}
