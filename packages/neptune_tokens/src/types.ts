// Neptune Odyssey — shared token types · © 2026 Neptune.Fintech (neptune.ly)

export const BRANDS = ["neptune", "andalus", "nuran", "fglb"] as const;
export type Brand = (typeof BRANDS)[number];

export const MODES = ["light", "dark"] as const;
export type Mode = (typeof MODES)[number];

export type Direction = "ltr" | "rtl";

export const COLOR_ROLES = [
  "primary",
  "on-primary",
  "primary-container",
  "on-primary-container",
  "secondary",
  "on-secondary",
  "secondary-container",
  "on-secondary-container",
  "tertiary",
  "on-tertiary",
  "tertiary-container",
  "on-tertiary-container",
  "error",
  "on-error",
  "error-container",
  "on-error-container",
  "success",
  "on-success",
  "success-container",
  "on-success-container",
  "background",
  "on-background",
  "surface",
  "on-surface",
  "surface-variant",
  "on-surface-variant",
  "outline",
  "outline-variant",
  "surface-container-lowest",
  "surface-container-low",
  "surface-container",
  "surface-container-high",
  "surface-container-highest",
  "inverse-surface",
  "inverse-on-surface",
  "inverse-primary",
  "scrim",
] as const;

export type ColorRole = (typeof COLOR_ROLES)[number];

/** role -> "#rrggbb" */
export type Palette = Record<ColorRole, string>;

export interface ResolvedColor {
  hex: string;
  argb: string;
}
