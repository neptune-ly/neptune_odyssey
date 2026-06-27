// Neptune Odyssey — icon path data · © 2026 Neptune.Fintech (neptune.ly)
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// The Neptune icon family. Each value is the INNER markup of a 24×24 icon
// (the <path>/<circle>/… elements only — NOT the outer <svg>). Authored on a
// 24px grid with ~2px visual padding, outlined stroke style: stroke-width 1.8,
// round caps & joins, fill none. Colour is inherited from `currentColor` at the
// <svg> level (see svg.ts), so every glyph themes with --md-sys-color-*.
//
// Do not add width/height/style attributes here, and do not wrap in <svg>.

import type { IconName } from "./types.js";

/** name → inner SVG markup. Typed against IconName so the set stays in sync. */
export const ICONS: Record<IconName, string> = {
  // ── Navigation & core ───────────────────────────────────────────────
  home:
    '<path d="M4 11 12 4l8 7"/><path d="M6 10v9a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1v-9"/><path d="M10 20v-5h4v5"/>',
  accounts:
    '<rect x="3" y="6" width="18" height="13" rx="2.5"/><path d="M3 10h18"/><path d="M7 15h4"/>',
  card:
    '<rect x="3" y="5" width="18" height="14" rx="2.5"/><path d="M3 9.5h18"/><path d="M6.5 14.5h4"/>',
  "card-add":
    '<path d="M21 11V7.5A2.5 2.5 0 0 0 18.5 5h-13A2.5 2.5 0 0 0 3 7.5V16a2.5 2.5 0 0 0 2.5 2.5H12"/><path d="M3 9.5h18"/><path d="M18 15v6"/><path d="M15 18h6"/>',
  wallet:
    '<path d="M4 7.5A2.5 2.5 0 0 1 6.5 5H17a1 1 0 0 1 1 1v1.5"/><rect x="4" y="7.5" width="16" height="12" rx="2.5"/><path d="M16 13h2"/><path d="M20 11.5h-3a1.5 1.5 0 0 0 0 3h3"/>',
  transfer:
    '<path d="M5 9h12l-3-3"/><path d="M19 15H7l3 3"/>',
  send:
    '<path d="M20 4 9.5 14.5"/><path d="M20 4 13.5 20l-4-7-7-4Z"/>',
  receive:
    '<path d="M12 4v11"/><path d="M7.5 10.5 12 15l4.5-4.5"/><path d="M5 19h14"/>',
  request:
    '<path d="M12 20V9"/><path d="M16.5 13.5 12 9 7.5 13.5"/><path d="M5 5h14"/>',
  "swap-exchange":
    '<path d="M6 8h11l-3.5-3.5"/><path d="M6 8V6"/><path d="M18 16H7l3.5 3.5"/><path d="M18 16v2"/>',
  "qr-code":
    '<rect x="4" y="4" width="6" height="6" rx="1.2"/><rect x="14" y="4" width="6" height="6" rx="1.2"/><rect x="4" y="14" width="6" height="6" rx="1.2"/><path d="M14 14h2v2"/><path d="M20 14v2"/><path d="M14 20h6"/><path d="M20 18v2"/>',
  contactless:
    '<path d="M7 8a8 8 0 0 1 0 8"/><path d="M11 6a12 12 0 0 1 0 12"/><path d="M15 4.5a16 16 0 0 1 0 15"/>',

  // ── Documents & money flow ──────────────────────────────────────────
  bill:
    '<path d="M6 3.5h9l3 3V20a.8.8 0 0 1-1.2.7L15 19.5l-1.5 1.2a1 1 0 0 1-1.2 0L10.8 19.5 9.3 20.7a1 1 0 0 1-1.2 0L6.6 19.5 5.2 20.7A.8.8 0 0 1 4 20V5.5A2 2 0 0 1 6 3.5Z"/><path d="M8.5 9h7"/><path d="M8.5 12.5h5"/>',
  receipt:
    '<path d="M6 3.5h12V20a.8.8 0 0 1-1.2.7L15 19.5l-1.5 1.2a1 1 0 0 1-1.2 0L10.8 19.5 9.3 20.7a1 1 0 0 1-1.2 0L6.6 19.5 5.2 20.7A.8.8 0 0 1 6 20Z"/><path d="M9 8h6"/><path d="M9 11.5h6"/><path d="M9 15h3"/>',
  statement:
    '<rect x="5" y="3.5" width="14" height="17" rx="2"/><path d="M8.5 8h7"/><path d="M8.5 11.5h7"/><path d="M8.5 15h4"/>',
  pdf:
    '<path d="M7 3.5h7l4 4V19a1.5 1.5 0 0 1-1.5 1.5h-9A1.5 1.5 0 0 1 6 19V5A1.5 1.5 0 0 1 7.5 3.5Z"/><path d="M14 3.5V8h4"/><path d="M9 16.5v-4h1.2a1.2 1.2 0 0 1 0 2.4H9"/><path d="M14 12.5v4"/><path d="M14 12.5h1.6"/><path d="M14 14.5h1.2"/>',
  download:
    '<path d="M12 4v10"/><path d="M7.5 9.5 12 14l4.5-4.5"/><path d="M5 18.5h14"/>',
  upload:
    '<path d="M12 14V4"/><path d="M7.5 8.5 12 4l4.5 4.5"/><path d="M5 18.5h14"/>',

  // ── Tools ───────────────────────────────────────────────────────────
  search:
    '<circle cx="11" cy="11" r="6.5"/><path d="M16 16l3.5 3.5"/>',
  filter:
    '<path d="M4 6h16"/><path d="M7 11h10"/><path d="M10 16h4"/>',
  settings:
    '<circle cx="12" cy="12" r="3"/><path d="M12 3v2.2"/><path d="M12 18.8V21"/><path d="M3 12h2.2"/><path d="M18.8 12H21"/><path d="m5.6 5.6 1.6 1.6"/><path d="m16.8 16.8 1.6 1.6"/><path d="m18.4 5.6-1.6 1.6"/><path d="m7.2 16.8-1.6 1.6"/>',

  // ── People & identity ───────────────────────────────────────────────
  user:
    '<circle cx="12" cy="8" r="3.5"/><path d="M5.5 19.5a6.5 6.5 0 0 1 13 0"/>',
  users:
    '<circle cx="9" cy="8" r="3"/><path d="M3.5 19a5.5 5.5 0 0 1 11 0"/><path d="M16 5.2a3 3 0 0 1 0 5.6"/><path d="M17 14.2a5.5 5.5 0 0 1 3.5 4.8"/>',
  "security-shield":
    '<path d="M12 3.5 19 6v5.5c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6Z"/><path d="m9 12 2 2 4-4"/>',
  lock:
    '<rect x="5" y="10.5" width="14" height="9" rx="2"/><path d="M8 10.5V8a4 4 0 0 1 8 0v2.5"/><circle cx="12" cy="15" r="1.1" fill="currentColor" stroke="none"/>',
  unlock:
    '<rect x="5" y="10.5" width="14" height="9" rx="2"/><path d="M8 10.5V8a4 4 0 0 1 7.5-1.9"/><circle cx="12" cy="15" r="1.1" fill="currentColor" stroke="none"/>',
  key:
    '<circle cx="8" cy="8" r="4"/><path d="m11 11 8 8"/><path d="m16.5 16.5 1.8-1.8"/><path d="m18.5 18.5 1.8-1.8"/>',
  fingerprint:
    '<path d="M7 11a5 5 0 0 1 10 0v1"/><path d="M9.5 11a2.5 2.5 0 0 1 5 0v1.5a6 6 0 0 0 .8 3"/><path d="M12 11v3a8 8 0 0 0 1.2 4.2"/><path d="M9.5 14a8 8 0 0 0 1 4.5"/><path d="M5 13a9 9 0 0 1 1.2-7"/><path d="M18.8 6.5A9 9 0 0 1 19 13"/>',
  "face-id":
    '<path d="M4 8V6.5A2.5 2.5 0 0 1 6.5 4H8"/><path d="M16 4h1.5A2.5 2.5 0 0 1 20 6.5V8"/><path d="M20 16v1.5a2.5 2.5 0 0 1-2.5 2.5H16"/><path d="M8 20H6.5A2.5 2.5 0 0 1 4 17.5V16"/><path d="M9.5 9.5v1"/><path d="M14.5 9.5v1"/><path d="M12 9.5v3l-1 .8"/><path d="M9.5 15a3.5 3.5 0 0 0 5 0"/>',

  // ── Status & alerts ─────────────────────────────────────────────────
  bell:
    '<path d="M6 16.5V11a6 6 0 0 1 12 0v5.5l1.5 2H4.5Z"/><path d="M10 18.5a2 2 0 0 0 4 0"/>',
  eye:
    '<path d="M3 12c2.2-4 5.5-6 9-6s6.8 2 9 6c-2.2 4-5.5 6-9 6s-6.8-2-9-6Z"/><circle cx="12" cy="12" r="2.6"/>',
  "eye-off":
    '<path d="M4 4 20 20"/><path d="M9.6 9.7A2.6 2.6 0 0 0 12 14.6"/><path d="M7 7.3C5.3 8.4 3.9 10 3 12c2.2 4 5.5 6 9 6 1.5 0 2.9-.3 4.2-1"/><path d="M14.7 9.5A2.6 2.6 0 0 0 12 9.4"/><path d="M17.4 7.6c1.3 1 2.5 2.5 3.6 4.4-1 1.7-2.1 3-3.5 4"/>',
  info:
    '<circle cx="12" cy="12" r="8.5"/><path d="M12 11v5"/><circle cx="12" cy="8" r="1.1" fill="currentColor" stroke="none"/>',
  "success-check":
    '<circle cx="12" cy="12" r="8.5"/><path d="m8.5 12 2.3 2.3 4.7-4.6"/>',
  warning:
    '<path d="M12 4.5 21 19.5H3Z"/><path d="M12 10v4"/><circle cx="12" cy="17" r="1" fill="currentColor" stroke="none"/>',
  error:
    '<circle cx="12" cy="12" r="8.5"/><path d="M12 8v5"/><circle cx="12" cy="16" r="1" fill="currentColor" stroke="none"/>',
  close:
    '<path d="M6 6 18 18"/><path d="M18 6 6 18"/>',
  plus:
    '<path d="M12 5v14"/><path d="M5 12h14"/>',
  minus:
    '<path d="M5 12h14"/>',

  // ── Charts & insights ───────────────────────────────────────────────
  "chart-line":
    '<path d="M4 4v15a1 1 0 0 0 1 1h15"/><path d="M7 15l3.5-4 3 2.5L20 7"/>',
  "chart-pie":
    '<path d="M12 4a8 8 0 1 0 8 8h-8Z"/><path d="M14 3.2A8 8 0 0 1 20.8 10H14Z"/>',
  "trending-up":
    '<path d="M4 16l5-5 3 3 7-7"/><path d="M15 7h4v4"/>',
  "trending-down":
    '<path d="M4 8l5 5 3-3 7 7"/><path d="M15 17h4v-4"/>',
  savings:
    '<circle cx="12" cy="12" r="8.5"/><path d="M12 6.5v11"/><path d="M14.5 8.5h-3.2a2 2 0 0 0 0 4h2.4a2 2 0 0 1 0 4H10"/>',

  // ── Time & place ────────────────────────────────────────────────────
  calendar:
    '<rect x="4" y="5.5" width="16" height="14.5" rx="2.5"/><path d="M4 10h16"/><path d="M8 3.5v3.5"/><path d="M16 3.5v3.5"/>',
  clock:
    '<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/>',
  location:
    '<path d="M12 21c-3.5-3.4-6-6.4-6-9.5a6 6 0 0 1 12 0c0 3.1-2.5 6.1-6 9.5Z"/><circle cx="12" cy="11" r="2.4"/>',
  phone:
    '<path d="M6 4h3l1.5 4-2 1.5a11 11 0 0 0 5 5l1.5-2 4 1.5V19a2 2 0 0 1-2.2 2A15.5 15.5 0 0 1 5 8.2 2 2 0 0 1 6 4Z"/>',
  mail:
    '<rect x="3.5" y="6" width="17" height="12" rx="2.5"/><path d="m4.5 8 7.5 5.5L19.5 8"/>',

  // ── Support ─────────────────────────────────────────────────────────
  support:
    '<circle cx="12" cy="12" r="8.5"/><path d="M9.5 10a2.5 2.5 0 0 1 4.6 1.3c0 1.7-2.1 1.9-2.1 3.2"/><circle cx="12" cy="17" r="1" fill="currentColor" stroke="none"/>',

  // ── Carets & arrows ─────────────────────────────────────────────────
  "chevron-right":
    '<path d="M9.5 5.5 16 12l-6.5 6.5"/>',
  "chevron-down":
    '<path d="M5.5 9.5 12 16l6.5-6.5"/>',
  "arrow-right":
    '<path d="M4 12h15"/><path d="m13 6 6 6-6 6"/>',
  "arrow-left":
    '<path d="M20 12H5"/><path d="m11 6-6 6 6 6"/>',

  // ── Overflow & misc ─────────────────────────────────────────────────
  menu:
    '<path d="M4 7h16"/><path d="M4 12h16"/><path d="M4 17h16"/>',
  "more-horizontal":
    '<circle cx="5.5" cy="12" r="1.3" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="1.3" fill="currentColor" stroke="none"/><circle cx="18.5" cy="12" r="1.3" fill="currentColor" stroke="none"/>',
  "more-vertical":
    '<circle cx="12" cy="5.5" r="1.3" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="1.3" fill="currentColor" stroke="none"/><circle cx="12" cy="18.5" r="1.3" fill="currentColor" stroke="none"/>',
  copy:
    '<rect x="8" y="8" width="12" height="12" rx="2.5"/><path d="M16 8V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h2"/>',
  share:
    '<circle cx="7" cy="12" r="2.5"/><circle cx="17" cy="6" r="2.5"/><circle cx="17" cy="18" r="2.5"/><path d="m9.2 10.8 5.6-3.4"/><path d="m9.2 13.2 5.6 3.4"/>',
  logout:
    '<path d="M14 4.5H6.5A1.5 1.5 0 0 0 5 6v12a1.5 1.5 0 0 0 1.5 1.5H14"/><path d="M11 12h9"/><path d="m16.5 8 3.5 4-3.5 4"/>',
  language:
    '<circle cx="12" cy="12" r="8.5"/><path d="M3.5 12h17"/><path d="M12 3.5c2.4 2.3 3.7 5.3 3.7 8.5S14.4 18.2 12 20.5c-2.4-2.3-3.7-5.3-3.7-8.5S9.6 5.8 12 3.5Z"/>',
  moon:
    '<path d="M20 13.5A8 8 0 0 1 10.5 4 8 8 0 1 0 20 13.5Z"/>',
  sun:
    '<circle cx="12" cy="12" r="4"/><path d="M12 3v2.2"/><path d="M12 18.8V21"/><path d="M3 12h2.2"/><path d="M18.8 12H21"/><path d="m5.4 5.4 1.6 1.6"/><path d="m17 17 1.6 1.6"/><path d="m18.6 5.4-1.6 1.6"/><path d="m7 17-1.6 1.6"/>',

  // ── Fintech & payments ──────────────────────────────────────────────
  atm:
    '<rect x="4" y="4.5" width="16" height="15" rx="2"/><path d="M4 9h16"/><path d="M7.5 13h3"/><path d="M7.5 16h6"/><path d="M16 13.5v3"/>',
  "pos-terminal":
    '<rect x="6" y="3.5" width="12" height="17" rx="2"/><path d="M6 8h12"/><path d="M9 5.5h6"/><path d="M9 12h2"/><path d="M13 12h2"/><path d="M9 15.5h2"/><path d="M13 15.5h2"/>',
  coins:
    '<ellipse cx="9" cy="7" rx="5" ry="2.5"/><path d="M4 7v4c0 1.4 2.2 2.5 5 2.5s5-1.1 5-2.5V7"/><ellipse cx="15" cy="15" rx="5" ry="2.5"/><path d="M10 15v4c0 1.4 2.2 2.5 5 2.5s5-1.1 5-2.5v-4"/>',
  "cash-stack":
    '<rect x="3" y="7" width="18" height="11" rx="2"/><circle cx="12" cy="12.5" r="2.4"/><path d="M3 11h2"/><path d="M19 11h2"/><path d="M5 5h14"/>',
  invoice:
    '<path d="M6 3.5h9l3 3V20a.8.8 0 0 1-1.2.7L15 19.5l-1.5 1.2a1 1 0 0 1-1.2 0L10.8 19.5 9.3 20.7a1 1 0 0 1-1.2 0L6.6 19.5 5.2 20.7A.8.8 0 0 1 4 20V5.5A2 2 0 0 1 6 3.5Z"/><path d="M12 8.5v6"/><path d="M13.8 10h-2.6a1.4 1.4 0 0 0 0 2.8h1.6a1.4 1.4 0 0 1 0 2.8H10"/>',
  "pie-budget":
    '<circle cx="12" cy="12" r="8.5"/><path d="M12 12V3.5"/><path d="M12 12l6 6"/>',
  "exchange-rate":
    '<path d="M4 8h10l-3-3"/><path d="M4 8V6"/><path d="M20 16H10l3 3"/><path d="M20 16v2"/><path d="M6.2 13h1.6"/><path d="M7 12.2v1.6"/><path d="M16.2 11h1.6"/>',
  crypto:
    '<circle cx="12" cy="12" r="8.5"/><path d="M9.5 8h4a2.2 2.2 0 0 1 0 4.4h-4"/><path d="M9.5 12.4h4.3a2.2 2.2 0 0 1 0 4.4H9.5"/><path d="M9.5 8v8.8"/><path d="M11 6.5v1.5"/><path d="M11 16.8v1.5"/><path d="M13 6.5v1.5"/><path d="M13 16.8v1.5"/>',
  loan:
    '<circle cx="12" cy="12" r="8.5"/><path d="M12 6.5v11"/><path d="M14.5 8.5h-3.2a2 2 0 0 0 0 4h2.4a2 2 0 0 1 0 4H10"/><path d="m17 5 3 3-3 3"/><path d="M20 8h-6"/>',
  insurance:
    '<path d="M12 3.5 19 6v5.5c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6Z"/><path d="M12 8.5v7"/><path d="M8.5 12h7"/>',
  "split-bill":
    '<circle cx="8" cy="8" r="3"/><circle cx="16" cy="8" r="3"/><path d="M3.5 19a4.5 4.5 0 0 1 9 0"/><path d="M11.5 19a4.5 4.5 0 0 1 9 0"/>',
  "tap-to-pay":
    '<rect x="3" y="6" width="13" height="12" rx="2.5"/><path d="M3 10h13"/><path d="M6.5 14.5h3"/><path d="M19 8.5a6 6 0 0 1 0 7"/><path d="M21.5 6.5a9 9 0 0 1 0 11"/>',
};
