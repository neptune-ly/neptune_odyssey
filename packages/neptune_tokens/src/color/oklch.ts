// Neptune Odyssey — OKLCH → sRGB converter · © 2026 Neptune.Fintech (neptune.ly)
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// Shared, pinned color math. The SAME algorithm ships in the Dart port
// (neptune_flutter_ui) so custom seeds resolve identically on every platform.
//
// Determinism note: for the four REFERENCE brands the resolved palette is shipped
// as canonical data (tokens.resolved.json) — byte-identical across platforms — so
// Flutter == Web is exact by construction. This converter reproduces that data to
// within <= 1 LSB per channel (the residual is sub-perceptual browser rounding at
// gamut edges) and is used for CUSTOM seeds from the configurator.

export interface Oklch {
  /** Perceptual lightness, 0..1 */
  L: number;
  /** Chroma, ~0..0.4 */
  C: number;
  /** Hue in degrees, 0..360 */
  H: number;
}

export interface Rgb {
  r: number;
  g: number;
  b: number;
}

// CSS Color 4 reference path: OKLab -> LMS -> XYZ(D65) -> linear sRGB.
const OKLAB_TO_LMS = [
  [1, 0.3963377773761749, 0.2158037573099136],
  [1, -0.1055613458156586, -0.0638541728258133],
  [1, -0.0894841775298119, -1.2914855480194092],
] as const;

const LMS_TO_XYZ = [
  [1.2268798733741557, -0.5578149965554813, 0.2813910501772159],
  [-0.0405757452148008, 1.1122868293970594, -0.0717110580655164],
  [-0.0763729366746601, -0.4214933324022432, 1.5869240198367816],
] as const;

const XYZ_TO_LIN_SRGB = [
  [3.2409699419045226, -1.537383177570094, -0.4986107602930034],
  [-0.9692436362808796, 1.8759675015077202, 0.04155505740717559],
  [0.05563007969699366, -0.20397695888897652, 1.0569715142428786],
] as const;

type Mat3 = readonly (readonly [number, number, number])[];
function mul(m: Mat3, v: readonly [number, number, number]): [number, number, number] {
  return [
    m[0]![0] * v[0] + m[0]![1] * v[1] + m[0]![2] * v[2],
    m[1]![0] * v[0] + m[1]![1] * v[1] + m[1]![2] * v[2],
    m[2]![0] * v[0] + m[2]![1] * v[1] + m[2]![2] * v[2],
  ];
}

const clamp01 = (x: number): number => (x < 0 ? 0 : x > 1 ? 1 : x);

/** Linear-light sRGB channel -> gamma-encoded sRGB (0..1). */
function encodeSrgb(x: number): number {
  const c = clamp01(x);
  return c <= 0.0031308 ? 12.92 * c : 1.055 * Math.pow(c, 1 / 2.4) - 0.055;
}

/** OKLCH -> linear-light sRGB (unclamped). Exposed for gamut inspection. */
export function oklchToLinearSrgb({ L, C, H }: Oklch): [number, number, number] {
  const hr = (H * Math.PI) / 180;
  const lab: [number, number, number] = [L, C * Math.cos(hr), C * Math.sin(hr)];
  const lms_ = mul(OKLAB_TO_LMS, lab);
  const lms: [number, number, number] = [lms_[0] ** 3, lms_[1] ** 3, lms_[2] ** 3];
  const xyz = mul(LMS_TO_XYZ, lms);
  return mul(XYZ_TO_LIN_SRGB, xyz);
}

/** True if the OKLCH color is inside the sRGB gamut (no channel clamped). */
export function inSrgbGamut(c: Oklch): boolean {
  const [r, g, b] = oklchToLinearSrgb(c);
  const lo = -1e-4;
  const hi = 1 + 1e-4;
  return r >= lo && r <= hi && g >= lo && g <= hi && b >= lo && b <= hi;
}

/** OKLCH -> sRGB 0..255 integer channels (per-channel clamp). */
export function oklchToRgb255(c: Oklch): Rgb {
  const [lr, lg, lb] = oklchToLinearSrgb(c);
  return {
    r: Math.round(encodeSrgb(lr) * 255),
    g: Math.round(encodeSrgb(lg) * 255),
    b: Math.round(encodeSrgb(lb) * 255),
  };
}

const hex2 = (n: number): string => n.toString(16).padStart(2, "0");

/** OKLCH -> "#rrggbb" lowercase. */
export function oklchToHex(c: Oklch): string {
  const { r, g, b } = oklchToRgb255(c);
  return `#${hex2(r)}${hex2(g)}${hex2(b)}`;
}

/** OKLCH -> "0xAARRGGBB" Flutter ARGB literal (alpha = FF). */
export function oklchToArgb(c: Oklch): string {
  const { r, g, b } = oklchToRgb255(c);
  return `0xFF${hex2(r)}${hex2(g)}${hex2(b)}`.toUpperCase();
}

/** Parse a CSS `oklch(L C H)` function string into an {L,C,H}. Returns null if not OKLCH. */
export function parseOklch(value: string): Oklch | null {
  const m = /oklch\(\s*([0-9.]+)\s+([0-9.]+)\s+([0-9.]+)/.exec(value);
  if (!m) return null;
  return { L: Number(m[1]), C: Number(m[2]), H: Number(m[3]) };
}
