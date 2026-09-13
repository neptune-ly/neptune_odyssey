// Neptune Odyssey — brandprint registries · © 2026 Neptune.Fintech (neptune.ly)
// APPEND-ONLY. The enum indices ARE the wire format (see docs/11-config-hash.md).
// Never reorder or remove an entry — only append. A removed/reordered registry is a
// breaking change and requires a new version prefix (NO2-).

export const FONTS = [
  "Hanken Grotesk",
  "Bricolage Grotesque",
  "Space Grotesk",
  "Sora",
  "IBM Plex Sans Arabic",
  "Reem Kufi",
  "Tajawal",
  "Readex Pro",
  "Noto Kufi Arabic",
] as const;

// 2.24.0 appended paper-lockup / lockup-rule (login) and statement-ledger /
// chevron-summary (hero): the lockup-on-a-plain-ground shells and the
// carousel-free dashboard heroes.
export const LOGIN = [
  "depth-emblem",
  "arcade-arches",
  "light-grid-spark",
  "shield-guilloche",
  "paper-lockup",
  "lockup-rule",
] as const;

export const HERO = [
  "balance-cards",
  "warm-balance-cards",
  "wallet-hero",
  "restrained-balance",
  "statement-ledger",
  "chevron-summary",
] as const;

export const TONE = [
  "clear-calm",
  "warm-hospitable",
  "light-instant",
  "formal-authoritative",
] as const;

export const GLASS = ["oceanic", "warm-amber", "violet-luminous", "navy-steel"] as const;

export const MOTION = [
  "smooth-fluid",
  "calm-graceful",
  "light-quick-crisp",
  "stable-minimal-authoritative",
] as const;

// Byte 26 of the payload, reserved (always 0) until 2.24.0. Index 0 = "auto":
// derive the motif from glassTint exactly as before the byte was claimed, so
// every brandprint already in the wild decodes to the identical theme.
export const MOTIF = ["auto", "sonar-rings", "coastal-arcs", "grid-spark", "guilloche", "none"] as const;

/**
 * The signed-in bar (flags bits 4-5, 2.28.0). `raised-dock` is index 0, so every
 * brandprint issued before 2.28.0 keeps the floating dock it has today.
 * FOUR ENTRIES MAX - this registry is two bits, not a byte.
 */
export const NAV_SHELL = ["raised-dock", "register-bar", "rule-bar"] as const;

/**
 * The home quick-action treatment (flags bits 6-7, 2.28.0). `filled-circles` is
 * index 0. FOUR ENTRIES MAX, same reason.
 */
export const ACTION_ROW = ["filled-circles", "register-rows", "rule-grid"] as const;

export type Font = (typeof FONTS)[number];
export type LoginShell = (typeof LOGIN)[number];
export type DashboardHero = (typeof HERO)[number];
export type ContentTone = (typeof TONE)[number];
export type GlassTint = (typeof GLASS)[number];
export type Motion = (typeof MOTION)[number];
export type Motif = (typeof MOTIF)[number];
export type NavShell = (typeof NAV_SHELL)[number];
export type ActionRow = (typeof ACTION_ROW)[number];

export const REGISTRIES = { FONTS, LOGIN, HERO, TONE, GLASS, MOTION, MOTIF, NAV_SHELL, ACTION_ROW } as const;
