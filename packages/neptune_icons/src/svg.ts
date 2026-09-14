// Neptune Odyssey — SVG string builder · © 2026 Neptune.Fintech (neptune.ly)
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// iconSvg() composes a complete, themeable <svg> string from the inner path data
// in ICONS. Colour is `currentColor`, so the icon inherits whatever colour the
// surrounding text/CSS resolves (e.g. --md-sys-color-on-surface). The root <svg>
// carries ONLY viewBox (plus width/height and the shared stroke attributes) —
// never a literal colour.

import { ICONS } from "./icons.js";
import { iconProfile } from "./profiles.js";
import type { IconProfileName } from "./profiles.js";
import type { IconName } from "./types.js";

export interface IconSvgOptions {
  /** Rendered width & height in px (the viewBox is always 24×24). Default 24. */
  size?: number;
  /** Stroke width in viewBox units. Default 1.8 — the family's native weight. */
  stroke?: number;
  /** Optional class attribute to place on the root <svg>. */
  class?: string;
  /**
   * Draw the glyph in one bank's own weight — see `profiles.ts`.
   *
   * Omit it for the family's native cut. Passing a profile overrides `stroke`
   * and the terminal treatment, and scales the glyph to that bank's optical
   * size; a bank with no profile throws rather than borrowing another's.
   */
  profile?: IconProfileName;
}

/** True when `name` is a known icon. Acts as a type guard for IconName. */
export function isIconName(name: string): name is IconName {
  return Object.prototype.hasOwnProperty.call(ICONS, name);
}

const escapeAttr = (v: string): string =>
  v.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

/**
 * Build a complete <svg> string for `name`.
 * @throws RangeError when `name` is not a known IconName.
 */
export function iconSvg(name: IconName, opts: IconSvgOptions = {}): string {
  if (!isIconName(name)) {
    throw new RangeError(`Unknown Neptune icon: "${String(name)}"`);
  }
  const size = opts.size ?? 24;
  const p = opts.profile ? iconProfile(opts.profile) : null;
  // The group scales the geometry, so the declared weight is divided by that
  // scale to come out at the intended visual thickness.
  const stroke = p ? p.strokeWidth / p.scale : (opts.stroke ?? 1.8);
  const cap = p ? p.linecap : "round";
  const join = p ? p.linejoin : "round";
  const miter = p ? ` stroke-miterlimit="${p.miterlimit}"` : "";
  const bank = p ? ` data-npt-profile="${escapeAttr(opts.profile!)}"` : "";
  const raw = ICONS[name];
  const inner =
    p && p.scale !== 1
      ? `<g transform="translate(12 12) scale(${p.scale}) translate(-12 -12)">${raw}</g>`
      : raw;
  const cls = opts.class ? ` class="${escapeAttr(opts.class)}"` : "";
  return (
    `<svg${cls} viewBox="0 0 24 24" width="${size}" height="${size}" fill="none" ` +
    `stroke="currentColor" stroke-width="${stroke}" stroke-linecap="${cap}" ` +
    `stroke-linejoin="${join}"${miter} role="img" aria-label="${escapeAttr(name)}" ` +
    `data-npt-icon="${escapeAttr(name)}"${bank}>${inner}</svg>`
  );
}
