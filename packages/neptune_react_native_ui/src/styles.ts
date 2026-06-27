// Neptune Odyssey — @neptune.fintech/react-native-ui · © 2026 Neptune.Fintech (neptune.ly)
// Pure mappers from a resolved `NeptuneTheme` to React Native style primitives — radii
// (numbers), colors (hex strings), and a flat bag of reusable style fragments. No
// `react-native` import, so these stay unit-testable in node. Every value here is read
// from the theme; there are no literal colors, radii, or font families.
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).

import type { NeptuneTheme, ColorRole } from "@neptune.fintech/tokens";

export type ShapeKey = "xs" | "sm" | "md" | "lg" | "xl" | "xxl" | "full";

/** Corner radius (a plain number, as RN expects) for a shape role. */
export function radius(theme: NeptuneTheme, key: ShapeKey): number {
  return theme.shape[key];
}

/** Hex string for a color role. */
export function colorOf(theme: NeptuneTheme, role: ColorRole): string {
  return theme.colors[role];
}

/** Spacing scale (dp). Logical so RTL flips for free via marginStart/paddingStart. */
export const SPACE = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 32,
} as const;

export type SpaceKey = keyof typeof SPACE;

/** Themed style fragments shared across components. Plain objects (RN-style-shaped). */
export interface ThemedStyles {
  screen: { flex: number; backgroundColor: string };
  surface: { backgroundColor: string; borderRadius: number };
  surfaceContainer: { backgroundColor: string; borderRadius: number };
  outline: { borderColor: string; borderWidth: number };
  textBody: { color: string; fontFamily: string };
  textDisplay: { color: string; fontFamily: string; fontWeight: string; letterSpacing: number };
  textMuted: { color: string; fontFamily: string };
  textNum: { color: string; fontFamily: string; fontVariant: string[] };
  primaryFill: { backgroundColor: string };
  onPrimary: { color: string };
}

/**
 * Build a flat bag of common, theme-derived style fragments. Returned values are plain
 * objects shaped like RN styles — callers can spread them into `StyleSheet.create`.
 */
export function makeThemedStyles(theme: NeptuneTheme): ThemedStyles {
  const c = theme.colors;
  const t = theme.type;
  return {
    screen: { flex: 1, backgroundColor: c.background },
    surface: { backgroundColor: c.surface, borderRadius: theme.shape.lg },
    surfaceContainer: { backgroundColor: c["surface-container"], borderRadius: theme.shape.lg },
    outline: { borderColor: c.outline, borderWidth: 1 },
    textBody: { color: c["on-surface"], fontFamily: t.text },
    textDisplay: {
      color: c["on-surface"],
      fontFamily: t.display,
      // RN fontWeight is a string union; the theme weight is numeric.
      fontWeight: String(t.displayWeight),
      // theme tracking is em; RN letterSpacing is dp — keep it conservative.
      letterSpacing: t.displayTracking * 16,
    },
    textMuted: { color: c["on-surface-variant"], fontFamily: t.text },
    textNum: { color: c["on-surface"], fontFamily: t.num, fontVariant: ["tabular-nums"] },
    primaryFill: { backgroundColor: c.primary },
    onPrimary: { color: c["on-primary"] },
  };
}
