// Neptune Odyssey — product worlds + interaction motion · © 2026 Neptune.Fintech (neptune.ly)
//
// Product worlds are orthogonal to tenant/brand themes. A bank, wallet, travel
// app, marketplace, or SaaS product can keep its tenant palette and engineering
// contract while selecting a distinct product personality for composition and
// expressive accents.

import type { Mode } from "./types.js";

export const PRODUCT_WORLDS = [
  "voyage",
  "pulse",
  "market",
  "harbor",
  "grid",
  "canvas",
] as const;

export type ProductWorld = (typeof PRODUCT_WORLDS)[number];

export const MOTION_LEVELS = ["restrained", "standard", "expressive"] as const;
export type MotionLevel = (typeof MOTION_LEVELS)[number];

export interface WorldColors {
  accent: string;
  onAccent: string;
  tint: string;
  hero: string;
  spark: string;
  background: string;
}

export interface ProductWorldDefinition {
  id: ProductWorld;
  family: "travel" | "mobility" | "commerce" | "hospitality" | "saas" | "lifestyle";
  titleFont: string;
  radius: number;
  defaultMotionLevel: MotionLevel;
  light: WorldColors;
  dark: WorldColors;
}

export interface ResolvedProductWorld {
  id: ProductWorld;
  family: ProductWorldDefinition["family"];
  mode: Mode;
  titleFont: string;
  radius: number;
  defaultMotionLevel: MotionLevel;
  colors: WorldColors;
}

export interface MotionLevelTokens {
  level: MotionLevel;
  durationMs: number;
  distancePx: number;
  staggerMs: number;
  /** Fractional overshoot cap: 0.03 = 3%. */
  overshoot: number;
  reduced: boolean;
}

/** Shared timing primitives. These mirror the Figma `O2 · Motion` collection. */
export const ODYSSEY_MOTION = {
  instantMs: 100,
  feedbackMs: 160,
  transitionMs: 240,
  expressiveMs: 420,
  storyMs: 900,
  reducedMs: 80,
} as const;

const FULL_MOTION_LEVELS: Readonly<Record<MotionLevel, Omit<MotionLevelTokens, "level" | "reduced">>> = {
  restrained: { durationMs: ODYSSEY_MOTION.feedbackMs, distancePx: 4, staggerMs: 12, overshoot: 0 },
  standard: { durationMs: ODYSSEY_MOTION.transitionMs, distancePx: 8, staggerMs: 24, overshoot: 0.03 },
  expressive: { durationMs: ODYSSEY_MOTION.expressiveMs, distancePx: 16, staggerMs: 40, overshoot: 0.08 },
};

export const WORLD_CONFIG: Readonly<Record<ProductWorld, ProductWorldDefinition>> = {
  voyage: {
    id: "voyage",
    family: "travel",
    titleFont: "Sora",
    radius: 20,
    defaultMotionLevel: "expressive",
    light: {
      accent: "#1E63FF",
      onAccent: "#FFFFFF",
      tint: "#E7F0FF",
      hero: "#73C7FF",
      spark: "#FFB454",
      background: "#F5F9FF",
    },
    dark: {
      accent: "#7CA8FF",
      onAccent: "#0B1733",
      tint: "#16223F",
      hero: "#2A7DBD",
      spark: "#FFC46B",
      background: "#0C1424",
    },
  },
  pulse: {
    id: "pulse",
    family: "mobility",
    titleFont: "Space Grotesk",
    radius: 12,
    defaultMotionLevel: "expressive",
    light: {
      accent: "#2E5A24",
      onAccent: "#FFFFFF",
      tint: "#EFF8DF",
      hero: "#B7F34A",
      spark: "#FF6557",
      background: "#F7FAF5",
    },
    dark: {
      accent: "#C4FF56",
      onAccent: "#10200B",
      tint: "#1A2A22",
      hero: "#314B28",
      spark: "#FF7A6B",
      background: "#0D1511",
    },
  },
  market: {
    id: "market",
    family: "commerce",
    titleFont: "Plus Jakarta Sans",
    radius: 18,
    defaultMotionLevel: "expressive",
    light: {
      accent: "#D9481F",
      onAccent: "#FFFFFF",
      tint: "#FFF0E9",
      hero: "#FFB48F",
      spark: "#6F5AEF",
      background: "#FFFAF7",
    },
    dark: {
      accent: "#FF7A59",
      onAccent: "#1B0D08",
      tint: "#3A1F17",
      hero: "#7A3524",
      spark: "#A697FF",
      background: "#1A100C",
    },
  },
  harbor: {
    id: "harbor",
    family: "hospitality",
    titleFont: "Fraunces",
    radius: 28,
    defaultMotionLevel: "standard",
    light: {
      accent: "#7A3D5A",
      onAccent: "#FFFFFF",
      tint: "#F7EAF0",
      hero: "#C9A06C",
      spark: "#2F7E75",
      background: "#FBF8F6",
    },
    dark: {
      accent: "#D895B2",
      onAccent: "#25111A",
      tint: "#38232D",
      hero: "#6F5133",
      spark: "#6BBFB3",
      background: "#171216",
    },
  },
  grid: {
    id: "grid",
    family: "saas",
    titleFont: "IBM Plex Sans",
    radius: 8,
    defaultMotionLevel: "standard",
    light: {
      accent: "#3A4BC8",
      onAccent: "#FFFFFF",
      tint: "#EAECFF",
      hero: "#6E7BE8",
      spark: "#008B8B",
      background: "#F6F7FC",
    },
    dark: {
      accent: "#8793FF",
      onAccent: "#111630",
      tint: "#232849",
      hero: "#3D467D",
      spark: "#4AD1CB",
      background: "#0E1120",
    },
  },
  canvas: {
    id: "canvas",
    family: "lifestyle",
    titleFont: "DM Sans",
    radius: 24,
    defaultMotionLevel: "expressive",
    light: {
      accent: "#7445C5",
      onAccent: "#FFFFFF",
      tint: "#F1EAFF",
      hero: "#F2A3C7",
      spark: "#D88400",
      background: "#FBF8FF",
    },
    dark: {
      accent: "#B69CFF",
      onAccent: "#1B1230",
      tint: "#2B2141",
      hero: "#6B3E59",
      spark: "#FFD36A",
      background: "#15101C",
    },
  },
};

/** Resolve a product world for an appearance mode. Deterministic and side-effect free. */
export function resolveProductWorld(world: ProductWorld, mode: Mode = "light"): ResolvedProductWorld {
  const definition = WORLD_CONFIG[world];
  return {
    id: definition.id,
    family: definition.family,
    mode,
    titleFont: definition.titleFont,
    radius: definition.radius,
    defaultMotionLevel: definition.defaultMotionLevel,
    colors: { ...definition[mode] },
  };
}

/**
 * Resolve the interaction choreography for a motion level.
 * Reduced motion keeps at most a short dissolve and removes travel, stagger,
 * and overshoot. It never changes service truth or completion state.
 */
export function resolveMotionLevel(level: MotionLevel, reduced = false): MotionLevelTokens {
  if (reduced) {
    return {
      level,
      durationMs: ODYSSEY_MOTION.reducedMs,
      distancePx: 0,
      staggerMs: 0,
      overshoot: 0,
      reduced: true,
    };
  }

  return { level, ...FULL_MOTION_LEVELS[level], reduced: false };
}
