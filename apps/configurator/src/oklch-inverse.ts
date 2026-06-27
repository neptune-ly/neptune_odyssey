// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Local sRGB("#rrggbb") → OKLCH helper. The tokens package only ships the forward
// path (OKLCH → sRGB); the configurator needs the inverse so the native colour
// pickers can two-way-sync with the L/C/H sliders. This is the exact inverse of
// tokens' CSS Color 4 path in color/oklch.ts:
//   gamma-decode sRGB → linear → XYZ(D65) → LMS → OKLab → L, C=hypot(a,b),
//   H=atan2(b,a) in degrees. A ~2-decimal approximation is fine because seeds
//   are quantised; oklchToHex(srgbToOklch(hex)) round-trips within a couple LSB.
//
// Do NOT add this to the tokens package — tokens is already published.

import type { Oklch } from "@neptune.fintech/tokens";

// Inverse matrices of the forward path in tokens/src/color/oklch.ts.
// linear sRGB → XYZ(D65)
const LIN_SRGB_TO_XYZ = [
  [0.41239079926595934, 0.357584339383878, 0.1804807884018343],
  [0.21263900587151027, 0.715168678767756, 0.07219231536073371],
  [0.01933081871559182, 0.11919477979462598, 0.9505321522496607],
] as const;

// XYZ(D65) → LMS  (inverse of tokens' LMS_TO_XYZ)
const XYZ_TO_LMS = [
  [0.8190224379967030, 0.3619062600528904, -0.1288737815209879],
  [0.0329836539323885, 0.9292868615863434, 0.0361446663506424],
  [0.0481771893596242, 0.2642395317527308, 0.6335478284694309],
] as const;

// LMS' (cube-rooted) → OKLab  (inverse of tokens' OKLAB_TO_LMS)
const LMS_TO_OKLAB = [
  [0.2104542683093140, 0.7936177747023054, -0.0040720430116193],
  [1.9779985324311684, -2.4285922420485799, 0.4505937096174110],
  [0.0259040424655478, 0.7827717124575296, -0.8086757549230774],
] as const;

type Mat3 = readonly (readonly [number, number, number])[];
function mul(m: Mat3, v: readonly [number, number, number]): [number, number, number] {
  return [
    m[0]![0] * v[0] + m[0]![1] * v[1] + m[0]![2] * v[2],
    m[1]![0] * v[0] + m[1]![1] * v[1] + m[1]![2] * v[2],
    m[2]![0] * v[0] + m[2]![1] * v[1] + m[2]![2] * v[2],
  ];
}

/** Gamma-encoded sRGB channel (0..1) → linear-light (inverse of tokens' encodeSrgb). */
function decodeSrgb(c: number): number {
  return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
}

/** Parse "#rgb" / "#rrggbb" → [r,g,b] gamma-encoded sRGB in 0..1. */
function hexToSrgb01(hex: string): [number, number, number] {
  let h = hex.trim().replace(/^#/, "");
  if (h.length === 3) h = h[0]! + h[0]! + h[1]! + h[1]! + h[2]! + h[2]!;
  if (h.length !== 6 || /[^0-9a-fA-F]/.test(h)) throw new Error(`invalid hex colour: ${hex}`);
  return [
    parseInt(h.slice(0, 2), 16) / 255,
    parseInt(h.slice(2, 4), 16) / 255,
    parseInt(h.slice(4, 6), 16) / 255,
  ];
}

/**
 * sRGB hex → OKLCH {L,C,H}. Exact inverse of tokens' oklchToHex within rounding.
 * Hue is normalised to 0..360; achromatic colours (C≈0) report H=0.
 */
export function srgbToOklch(hex: string): Oklch {
  const [r, g, b] = hexToSrgb01(hex);
  const lin: [number, number, number] = [decodeSrgb(r), decodeSrgb(g), decodeSrgb(b)];
  const xyz = mul(LIN_SRGB_TO_XYZ, lin);
  const lms = mul(XYZ_TO_LMS, xyz);
  // cube root preserving sign (forward path cubes the LMS' values)
  const lms_: [number, number, number] = [
    Math.cbrt(lms[0]),
    Math.cbrt(lms[1]),
    Math.cbrt(lms[2]),
  ];
  const [L, a, bb] = mul(LMS_TO_OKLAB, lms_);
  const C = Math.hypot(a, bb);
  let H = (Math.atan2(bb, a) * 180) / Math.PI;
  if (H < 0) H += 360;
  return { L, C: C < 1e-4 ? 0 : C, H: C < 1e-4 ? 0 : H };
}
