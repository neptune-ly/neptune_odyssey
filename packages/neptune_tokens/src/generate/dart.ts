// Neptune Odyssey — palette → Flutter ColorScheme · © 2026 Neptune.Fintech (neptune.ly)
import { oklchToArgb, type Oklch } from "../color/oklch.js";
import type { ColorRole, Mode } from "../types.js";

// M3 ColorScheme role -> Odyssey role name. success* live in a ThemeExtension (not here).
const SCHEME_MAP: ReadonlyArray<[string, ColorRole]> = [
  ["primary", "primary"],
  ["onPrimary", "on-primary"],
  ["primaryContainer", "primary-container"],
  ["onPrimaryContainer", "on-primary-container"],
  ["secondary", "secondary"],
  ["onSecondary", "on-secondary"],
  ["secondaryContainer", "secondary-container"],
  ["onSecondaryContainer", "on-secondary-container"],
  ["tertiary", "tertiary"],
  ["onTertiary", "on-tertiary"],
  ["tertiaryContainer", "tertiary-container"],
  ["onTertiaryContainer", "on-tertiary-container"],
  ["error", "error"],
  ["onError", "on-error"],
  ["errorContainer", "error-container"],
  ["onErrorContainer", "on-error-container"],
  ["surface", "surface"],
  ["onSurface", "on-surface"],
  ["surfaceContainerLowest", "surface-container-lowest"],
  ["surfaceContainerLow", "surface-container-low"],
  ["surfaceContainer", "surface-container"],
  ["surfaceContainerHigh", "surface-container-high"],
  ["surfaceContainerHighest", "surface-container-highest"],
  ["onSurfaceVariant", "on-surface-variant"],
  ["outline", "outline"],
  ["outlineVariant", "outline-variant"],
  ["inverseSurface", "inverse-surface"],
  ["onInverseSurface", "inverse-on-surface"],
  ["inversePrimary", "inverse-primary"],
  ["scrim", "scrim"],
];

/** Emit a `const ColorScheme(...)` from an ARGB-valued palette. */
export function argbPaletteToColorScheme(
  argb: Record<ColorRole, string>,
  name: string,
  mode: Mode,
): string {
  const brightness = mode === "light" ? "Brightness.light" : "Brightness.dark";
  const lines = SCHEME_MAP.map(([dartKey, role]) => `  ${dartKey}: Color(${argb[role]}),`);
  // surfaceTint follows primary; shadow is opaque black.
  lines.push(`  surfaceTint: Color(${argb.primary}),`);
  lines.push(`  shadow: const Color(0xFF000000),`);
  return [
    `const ColorScheme ${name} = ColorScheme(`,
    `  brightness: ${brightness},`,
    ...lines,
    `);`,
  ].join("\n");
}

/** Convenience: OKLCH role map → ARGB role map (for custom seeds). */
export function oklchPaletteToArgb(
  palette: Record<ColorRole, Oklch>,
): Record<ColorRole, string> {
  const out = {} as Record<ColorRole, string>;
  for (const role of Object.keys(palette) as ColorRole[]) out[role] = oklchToArgb(palette[role]);
  return out;
}
