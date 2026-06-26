// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// WCAG 2.x relative-luminance + contrast-ratio math (docs/08 — accessibility).
// Pure, dependency-free, unit-tested. Operates on "#rrggbb" / "#rgb" hex strings.

export interface ContrastPair {
  /** Stable id used for keying the UI row. */
  id: string;
  /** Human label, e.g. "Primary / On-primary". */
  label: string;
  /** The role whose colour is the "background". */
  bg: string;
  /** The role whose colour is the "foreground". */
  fg: string;
  /**
   * WCAG threshold this pair must clear. 4.5 for body text,
   * 3.0 for large text / UI components.
   */
  threshold: 4.5 | 3;
}

/** Parse "#rgb" or "#rrggbb" into [r,g,b] channels in 0..1. */
export function hexToRgb01(hex: string): [number, number, number] {
  let h = hex.trim().replace(/^#/, "");
  if (h.length === 3) {
    h = h[0]! + h[0]! + h[1]! + h[1]! + h[2]! + h[2]!;
  }
  if (h.length !== 6 || /[^0-9a-fA-F]/.test(h)) {
    throw new Error(`invalid hex colour: ${hex}`);
  }
  const r = parseInt(h.slice(0, 2), 16) / 255;
  const g = parseInt(h.slice(2, 4), 16) / 255;
  const b = parseInt(h.slice(4, 6), 16) / 255;
  return [r, g, b];
}

/** Linearize a single gamma-encoded sRGB channel (0..1). */
function linearizeChannel(c: number): number {
  return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4;
}

/** WCAG relative luminance L = 0.2126·R + 0.7152·G + 0.0722·B (linearized). */
export function relativeLuminance(hex: string): number {
  const [r, g, b] = hexToRgb01(hex);
  return (
    0.2126 * linearizeChannel(r) +
    0.7152 * linearizeChannel(g) +
    0.0722 * linearizeChannel(b)
  );
}

/**
 * WCAG contrast ratio between two colours, 1..21.
 * (Llighter + 0.05) / (Ldarker + 0.05).
 */
export function contrastRatio(a: string, b: string): number {
  const la = relativeLuminance(a);
  const lb = relativeLuminance(b);
  const lighter = Math.max(la, lb);
  const darker = Math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

export interface ContrastResult extends ContrastPair {
  ratio: number;
  pass: boolean;
}

/**
 * The key role pairs validated for AA. `palette` is role -> "#rrggbb"
 * (e.g. `buildTheme(config, { mode }).colors`).
 */
export const AA_PAIRS: ContrastPair[] = [
  { id: "primary", label: "Primary / On-primary", bg: "primary", fg: "on-primary", threshold: 4.5 },
  {
    id: "secondary-container",
    label: "Secondary-container / On-",
    bg: "secondary-container",
    fg: "on-secondary-container",
    threshold: 4.5,
  },
  { id: "surface", label: "Surface / On-surface", bg: "surface", fg: "on-surface", threshold: 4.5 },
  { id: "error", label: "Error / On-error", bg: "error", fg: "on-error", threshold: 4.5 },
  { id: "success", label: "Success / On-success", bg: "success", fg: "on-success", threshold: 4.5 },
];

/** Evaluate every AA pair against a resolved palette. */
export function evaluateContrast(palette: Record<string, string>): ContrastResult[] {
  return AA_PAIRS.map((pair) => {
    const ratio = contrastRatio(palette[pair.bg]!, palette[pair.fg]!);
    return { ...pair, ratio, pass: ratio >= pair.threshold };
  });
}
