// Neptune Odyssey — @neptune.fintech/icons · © 2026 Neptune.Fintech (neptune.ly)
// An original, hand-authored 24px stroke icon family for banking & fintech.
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// Two ways to consume:
//   1. Plain web — iconSvg("card") returns a complete, themeable <svg> string.
//   2. Custom element — <npt-icon name="card" size="24">, after registerIcons().
//
// Every glyph paints with `currentColor`, so it themes with --md-sys-color-*
// (or any inherited `color`) with zero per-icon configuration.

export { ICONS } from "./icons.js";
export { ICON_NAMES } from "./types.js";
export type { IconName } from "./types.js";
export { iconSvg, isIconName } from "./svg.js";
export type { IconSvgOptions } from "./svg.js";
export { NptIcon, registerIcons } from "./element.js";

// ── Brand marks (third-party trademarks — identification placeholders) ──
// Original simplified geometric placeholders (NOT traced from official art) and
// NOT under the Neptune Odyssey Community License. Each renders in three
// variants — color | mono | outline. Licensed users SHOULD swap in official
// artwork with registerBrandMark(). See brand-marks.ts and NOTICE-brand-marks.md.
export {
  BRAND_MARKS,
  BRAND_MARK_NAMES,
  brandMarkSvg,
  isBrandMarkName,
  registerBrandMark,
  unregisterBrandMark,
  hasBrandMarkOverride,
} from "./brand-marks.js";
export type { BrandMarkName, BrandMarkOptions, BrandMarkVariant } from "./brand-marks.js";
export { NptBrandMark, registerBrandMarks, register } from "./element.js";

/** Semantic version of the icon family (kept in lockstep with package.json). */
export const ICONS_VERSION = "2.4.0";
