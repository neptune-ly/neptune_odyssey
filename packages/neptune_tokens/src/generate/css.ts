// Neptune Odyssey — palette → CSS custom properties · © 2026 Neptune.Fintech (neptune.ly)
import { COLOR_ROLES, type Palette } from "../types.js";

/** Emit `--md-sys-color-*` declarations for a resolved palette. */
export function paletteToCssVars(palette: Palette, indent = "  "): string {
  return COLOR_ROLES.map((role) => `${indent}--md-sys-color-${role}: ${palette[role]};`).join("\n");
}

/** Wrap a palette in a `[data-theme][data-mode]` selector block. */
export function paletteToCssBlock(palette: Palette, theme: string, mode: "light" | "dark"): string {
  const sel = mode === "light" ? `[data-theme="${theme}"]` : `[data-theme="${theme}"][data-mode="dark"]`;
  return `${sel}{\n${paletteToCssVars(palette)}\n}`;
}
