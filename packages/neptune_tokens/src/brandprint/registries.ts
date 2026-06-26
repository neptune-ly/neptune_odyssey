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

export const LOGIN = [
  "depth-emblem",
  "arcade-arches",
  "light-grid-spark",
  "shield-guilloche",
] as const;

export const HERO = [
  "balance-cards",
  "warm-balance-cards",
  "wallet-hero",
  "restrained-balance",
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

export type Font = (typeof FONTS)[number];
export type LoginShell = (typeof LOGIN)[number];
export type DashboardHero = (typeof HERO)[number];
export type ContentTone = (typeof TONE)[number];
export type GlassTint = (typeof GLASS)[number];
export type Motion = (typeof MOTION)[number];

export const REGISTRIES = { FONTS, LOGIN, HERO, TONE, GLASS, MOTION } as const;
