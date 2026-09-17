// Neptune Odyssey — palette + product-world → CSS custom properties · © 2026 Neptune.Fintech (neptune.ly)
import { COLOR_ROLES, type Mode, type Palette } from "../types.js";
import {
  PRODUCT_WORLDS,
  resolveMotionLevel,
  resolveProductWorld,
  type MotionLevel,
  type ProductWorld,
  type ResolvedProductWorld,
} from "../worlds.js";

/** Emit `--md-sys-color-*` declarations for a resolved palette. */
export function paletteToCssVars(palette: Palette, indent = "  "): string {
  return COLOR_ROLES.map((role) => `${indent}--md-sys-color-${role}: ${palette[role]};`).join("\n");
}

/** Wrap a palette in a `[data-theme][data-mode]` selector block. */
export function paletteToCssBlock(palette: Palette, theme: string, mode: Mode): string {
  const sel = mode === "light" ? `[data-theme="${theme}"]` : `[data-theme="${theme}"][data-mode="dark"]`;
  return `${sel}{\n${paletteToCssVars(palette)}\n}`;
}

/**
 * Emit the orthogonal Odyssey product-world layer. These variables intentionally
 * do not replace Material color roles: shared components continue to consume the
 * active tenant theme, while product compositions opt into `--o2-world-*` roles
 * for editorial/background/hero treatment.
 */
export function productWorldToCssVars(world: ResolvedProductWorld, indent = "  "): string {
  const c = world.colors;
  return [
    `${indent}--o2-world-accent: ${c.accent};`,
    `${indent}--o2-world-on-accent: ${c.onAccent};`,
    `${indent}--o2-world-tint: ${c.tint};`,
    `${indent}--o2-world-hero: ${c.hero};`,
    `${indent}--o2-world-spark: ${c.spark};`,
    `${indent}--o2-world-background: ${c.background};`,
    `${indent}--o2-world-radius: ${world.radius}px;`,
    `${indent}--o2-world-title-font: ${JSON.stringify(world.titleFont)};`,
  ].join("\n");
}

/** Wrap a product world in `[data-world]`, optionally scoped to dark mode. */
export function productWorldToCssBlock(world: ProductWorld, mode: Mode): string {
  const resolved = resolveProductWorld(world, mode);
  const sel =
    mode === "light"
      ? `[data-world="${world}"]`
      : `[data-world="${world}"][data-mode="dark"]`;
  return `${sel}{\n${productWorldToCssVars(resolved)}\n}`;
}

/** Emit all six world blocks for both appearance modes. */
export function allProductWorldCss(): string {
  return PRODUCT_WORLDS.flatMap((world) => [
    productWorldToCssBlock(world, "light"),
    productWorldToCssBlock(world, "dark"),
  ]).join("\n\n");
}

/** Emit interaction-motion variables for one Odyssey motion level. */
export function motionLevelToCssVars(
  level: MotionLevel,
  reduced = false,
  indent = "  ",
): string {
  const motion = resolveMotionLevel(level, reduced);
  return [
    `${indent}--o2-motion-level-duration: ${motion.durationMs}ms;`,
    `${indent}--o2-motion-level-distance: ${motion.distancePx}px;`,
    `${indent}--o2-motion-level-stagger: ${motion.staggerMs}ms;`,
    `${indent}--o2-motion-level-overshoot: ${motion.overshoot};`,
  ].join("\n");
}
