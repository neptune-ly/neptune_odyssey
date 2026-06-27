// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Pure logic: turn a decoded brandprint + its resolved theme into the labelled
// key/value lines the loader panel renders. Kept dependency-light and DOM-free
// so it is unit-testable (jsdom cannot instantiate the <npt-*> elements, but it
// can exercise pure functions like this one).

import type { DecodedBrandprint, NeptuneTheme } from "@neptune-odyssey/tokens";

export interface SummaryLine {
  k: string;
  v: string;
}

/** How many of the 12 named brand levers a config moves off the Neptune default
 *  is not encoded in the wire format, so we summarise the levers we *can* read. */
export function summarizeBrandprint(
  decoded: DecodedBrandprint,
  theme: NeptuneTheme,
): SummaryLine[] {
  const corners = decoded.corners;
  const cornerSummary = `${corners.xs}/${corners.sm}/${corners.md}/${corners.lg}/${corners.xl}/${corners.xxl}px`;
  const brandMatch =
    theme.brand === "custom" ? "Custom (no reference match)" : titleCase(theme.brand);

  return [
    { k: "Brand match", v: brandMatch },
    { k: "Fonts", v: uniqueFonts(decoded) },
    { k: "Display weight", v: String(decoded.displayWeight) },
    { k: "Tracking", v: `${decoded.displayTracking}em` },
    { k: "Corners (xs→xxl)", v: cornerSummary },
    { k: "Login shell", v: humanize(decoded.loginShell) },
    { k: "Dashboard hero", v: humanize(decoded.dashboardHero) },
    { k: "Content tone", v: humanize(decoded.contentTone) },
    { k: "Glass tint", v: humanize(decoded.glassTint) },
    { k: "Motion", v: humanize(decoded.motion) },
    { k: "Defaults", v: defaultsLabel(decoded) },
  ];
}

function uniqueFonts(d: DecodedBrandprint): string {
  const seen: string[] = [];
  for (const f of [d.fonts.display, d.fonts.text, d.fonts.num]) {
    if (!seen.includes(f)) seen.push(f);
  }
  return seen.join(", ");
}

function defaultsLabel(d: DecodedBrandprint): string {
  const parts = [d.defaultDark ? "dark" : "light", d.defaultRtl ? "RTL" : "LTR"];
  return parts.join(" · ");
}

function humanize(token: string): string {
  return token
    .split("-")
    .map((w) => (w.length ? w[0]!.toUpperCase() + w.slice(1) : w))
    .join(" ");
}

function titleCase(s: string): string {
  return s.length ? s[0]!.toUpperCase() + s.slice(1) : s;
}
