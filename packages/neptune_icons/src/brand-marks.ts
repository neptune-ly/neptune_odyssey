// Neptune Odyssey — payment-network & fintech BRAND MARKS · © 2026 Neptune.Fintech (neptune.ly)
//
// ⚠️  TRADEMARK NOTICE — READ BEFORE USE
// ----------------------------------------------------------------------------
// The marks in this module (Visa, Mastercard, American Express, Discover,
// UnionPay, Western Union, MoneyGram, Apple Pay, Google Pay, PayPal, SWIFT,
// NUMO, Moamalat, LyPay, OnePay, Sadad, Tadawul, etc.) are THIRD-PARTY
// TRADEMARKS owned by their respective owners. They are provided here ONLY as
// SIMPLIFIED, SCHEMATIC IDENTIFICATION MARKS / PLACEHOLDERS so a UI can label a
// payment method — they are deliberately NOT pixel-exact reproductions of any
// official logo, and they are NOT traced from any official artwork. They are
// ORIGINAL, clean geometric placeholders authored for Neptune Odyssey.
//
// These marks are NOT licensed under the Neptune Odyssey Community License and
// are kept SEPARATE from the monochrome ICONS set on purpose. In production,
// replace each with the brand's OFFICIAL asset via registerBrandMark() (see
// below) and follow that brand's brand/usage guidelines.
//
// The Libyan / local marks (NUMO, Moamalat, LyPay, OnePay, Sadad, Tadawul) are
// NEUTRAL PLACEHOLDERS (a simple badge + initials/motif) — we do not ship their
// real assets. Replace them with official artwork before shipping.
//
// ── THREE-VARIANT SYSTEM ────────────────────────────────────────────────────
// Every mark is authored as a small array of shape PRIMITIVES tagged by ROLE,
// plus a per-mark brand-colour map. It then renders in three variants:
//   • "color"   — multicolour, brand colours by role. The default.
//   • "mono"    — a single flat silhouette in `currentColor` (fills only).
//   • "outline" — line style: stroke="currentColor", fill="none", round joins.
// Licensed users can drop in a brand's official SVG with registerBrandMark();
// after that, brandMarkSvg() returns the override.

/** Every payment / fintech brand mark shipped (identification placeholders). */
export type BrandMarkName =
  // Card networks
  | "visa"
  | "mastercard"
  | "amex"
  | "discover"
  | "unionpay"
  // Money transfer
  | "western-union"
  | "moneygram"
  // Libyan / local — PLACEHOLDERS, replace with official assets
  | "numo"
  | "moamalat"
  | "lypay"
  | "onepay"
  | "sadad"
  | "tadawul"
  // Wallets / generic
  | "apple-pay"
  | "google-pay"
  | "paypal"
  | "swift"
  | "mada"
  | "generic-card"
  | "contactless-pay"
  | "cash"
  | "bank-building";

/** The three render variants every brand mark supports. */
export type BrandMarkVariant = "color" | "mono" | "outline";

/**
 * A shape's semantic role. Brand colours are assigned per role, so the same
 * primitive array renders correctly in colour, mono and outline:
 *  - 'a' | 'b' | 'c' — distinct brand-colour slots (primary, secondary, …).
 *  - 'ink'           — foreground detail (text / glyph / line) over a tint.
 *  - 'bg'            — a neutral card/badge body (frame), not a brand colour.
 *  - 'hairline'      — a thin neutral border around a neutral 'bg'.
 */
type Role = "a" | "b" | "c" | "ink" | "bg" | "hairline";

type ShapeKind = "rect" | "circle" | "ellipse" | "path" | "text" | "line" | "g";

/** A single drawable primitive. `text` carries its label in `text`. */
interface Shape {
  kind: ShapeKind;
  role: Role;
  attrs: Record<string, string | number>;
  /** For kind:'text' — the string to render. */
  text?: string;
  /** For kind:'g' — nested children (used for grouped strokes). */
  children?: Shape[];
}

/** Per-mark definition: an intrinsic viewBox, a colour map, and the shapes. */
interface MarkDef {
  /** Intrinsic viewBox, e.g. "0 0 48 32". Aspect ratio is preserved on resize. */
  viewBox: string;
  /** Human label for aria. */
  label: string;
  /** Brand colour by role for the "color" variant. */
  colors: Partial<Record<Role, string>>;
  shapes: Shape[];
  /** True for neutral local placeholders (adds data-placeholder="true"). */
  placeholder?: boolean;
}

// Neutral framing colours shared by the "card body" marks (not brand colours).
const CARD_BG = "#F4F5F7";
const CARD_HAIRLINE = "#E1E3E8";

// A neutral card body + hairline frame, as two shapes. Reused by many marks.
function cardFrame(bg: string = CARD_BG): Shape[] {
  return [
    { kind: "rect", role: "bg", attrs: { width: 48, height: 32, rx: 4, fill: bg } },
    {
      kind: "rect",
      role: "hairline",
      attrs: { x: 0.5, y: 0.5, width: 47, height: 31, rx: 3.5 },
    },
  ];
}

const FONT = "Arial, Helvetica, sans-serif";

/**
 * name → mark definition. Each is an ORIGINAL simplified geometric placeholder
 * recognisable by the brand's colours/basic forms — never traced artwork.
 */
const MARK_DEFS: Record<BrandMarkName, MarkDef> = {
  // ── Card networks ───────────────────────────────────────────────────
  visa: {
    viewBox: "0 0 48 32",
    label: "Visa",
    colors: { a: "#1A1F71", ink: "#1A1F71" },
    shapes: [
      ...cardFrame(),
      {
        kind: "text",
        role: "a",
        text: "VISA",
        attrs: {
          x: 24,
          y: 21.5,
          "font-family": FONT,
          "font-size": 13,
          "font-style": "italic",
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 0.5,
        },
      },
    ],
  },
  mastercard: {
    viewBox: "0 0 48 32",
    label: "Mastercard",
    colors: { a: "#EB001B", b: "#F79E1B", c: "#FF5F00" },
    shapes: [
      ...cardFrame(),
      { kind: "circle", role: "a", attrs: { cx: 20, cy: 16, r: 8 } },
      { kind: "circle", role: "b", attrs: { cx: 28, cy: 16, r: 8 } },
      {
        kind: "path",
        role: "c",
        attrs: { d: "M24 9.7a8 8 0 0 0 0 12.6 8 8 0 0 0 0-12.6Z" },
      },
    ],
  },
  amex: {
    viewBox: "0 0 48 32",
    label: "American Express",
    colors: { a: "#2E77BC", ink: "#FFFFFF" },
    shapes: [
      { kind: "rect", role: "a", attrs: { width: 48, height: 32, rx: 4 } },
      {
        kind: "rect",
        role: "ink",
        attrs: { x: 6, y: 9, width: 36, height: 14, rx: 2, "fill-opacity": 0.12 },
      },
      {
        kind: "text",
        role: "ink",
        text: "AMEX",
        attrs: {
          x: 24,
          y: 20.5,
          "font-family": FONT,
          "font-size": 11,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 1,
        },
      },
    ],
  },
  discover: {
    viewBox: "0 0 48 32",
    label: "Discover",
    colors: { ink: "#231F20", a: "#F58220" },
    shapes: [
      ...cardFrame(),
      {
        kind: "text",
        role: "ink",
        text: "DISC",
        attrs: {
          x: 21,
          y: 20.5,
          "font-family": FONT,
          "font-size": 9,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 0.3,
        },
      },
      { kind: "circle", role: "a", attrs: { cx: 36, cy: 17, r: 6 } },
    ],
  },
  unionpay: {
    viewBox: "0 0 48 32",
    label: "UnionPay",
    colors: { a: "#E21836", b: "#00447C", c: "#007B84", ink: "#FFFFFF" },
    shapes: [
      ...cardFrame(),
      { kind: "rect", role: "a", attrs: { x: 10, y: 7, width: 9, height: 18, rx: 2 } },
      { kind: "rect", role: "b", attrs: { x: 19, y: 7, width: 9, height: 18, rx: 2 } },
      { kind: "rect", role: "c", attrs: { x: 28, y: 7, width: 9, height: 18, rx: 2 } },
      {
        kind: "text",
        role: "ink",
        text: "UPAY",
        attrs: {
          x: 24,
          y: 19.5,
          "font-family": FONT,
          "font-size": 6,
          "font-weight": 700,
          "text-anchor": "middle",
        },
      },
    ],
  },

  // ── Money transfer ──────────────────────────────────────────────────
  "western-union": {
    viewBox: "0 0 48 32",
    label: "Western Union",
    colors: { a: "#FFDD00", ink: "#000000" },
    shapes: [
      { kind: "rect", role: "a", attrs: { width: 48, height: 32, rx: 4 } },
      {
        kind: "text",
        role: "ink",
        text: "WESTERN",
        attrs: {
          x: 24,
          y: 14.5,
          "font-family": FONT,
          "font-size": 7,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 0.5,
        },
      },
      {
        kind: "text",
        role: "ink",
        text: "UNION",
        attrs: {
          x: 24,
          y: 23.5,
          "font-family": FONT,
          "font-size": 7,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 0.5,
        },
      },
    ],
  },
  moneygram: {
    viewBox: "0 0 48 32",
    label: "MoneyGram",
    colors: { a: "#E51937", ink: "#E51937" },
    shapes: [
      ...cardFrame(),
      { kind: "circle", role: "a", attrs: { cx: 13, cy: 16, r: 5 } },
      {
        kind: "text",
        role: "ink",
        text: "MGRAM",
        attrs: {
          x: 29,
          y: 19.5,
          "font-family": FONT,
          "font-size": 7,
          "font-weight": 700,
          "text-anchor": "middle",
        },
      },
    ],
  },

  // ── Libyan / local — PLACEHOLDERS (replace with official assets) ─────
  numo: {
    viewBox: "0 0 48 32",
    label: "NUMO (placeholder mark)",
    placeholder: true,
    colors: { a: "#0E2A47", b: "#5AA9E6", ink: "#FFFFFF" },
    shapes: [
      { kind: "rect", role: "a", attrs: { width: 48, height: 32, rx: 4 } },
      {
        kind: "rect",
        role: "b",
        attrs: { x: 6, y: 8, width: 36, height: 16, rx: 3, fill: "none", "stroke-width": 1.4 },
      },
      {
        kind: "text",
        role: "ink",
        text: "NUMO",
        attrs: {
          x: 24,
          y: 21,
          "font-family": FONT,
          "font-size": 9,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 1.5,
        },
      },
    ],
  },
  moamalat: {
    viewBox: "0 0 48 32",
    label: "Moamalat (placeholder mark)",
    placeholder: true,
    colors: { a: "#1C7A4D", b: "#FFFFFF", ink: "#FFFFFF" },
    shapes: [
      { kind: "rect", role: "a", attrs: { width: 48, height: 32, rx: 4 } },
      {
        kind: "circle",
        role: "b",
        attrs: { cx: 13, cy: 16, r: 6, fill: "none", "stroke-width": 1.4 },
      },
      {
        kind: "text",
        role: "ink",
        text: "M",
        attrs: {
          x: 13,
          y: 19,
          "font-family": FONT,
          "font-size": 8,
          "font-weight": 700,
          "text-anchor": "middle",
        },
      },
      {
        kind: "text",
        role: "ink",
        text: "MOAM",
        attrs: {
          x: 31,
          y: 19.5,
          "font-family": FONT,
          "font-size": 7,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 0.5,
        },
      },
    ],
  },
  // LyPay — a green→blue swoosh/flag beside a "LyPay" wordmark block.
  // Original geometry: two short strokes (green, blue) form a flag, wordmark right.
  lypay: {
    viewBox: "0 0 48 32",
    label: "LyPay (placeholder mark)",
    placeholder: true,
    colors: { a: "#3FBF7F", b: "#2AA0D8", ink: "#0E3A2E" },
    shapes: [
      ...cardFrame("#EAF7F0"),
      // green swoosh stroke
      {
        kind: "path",
        role: "a",
        attrs: {
          d: "M7 21c3-6 6-9 11-9",
          fill: "none",
          "stroke-width": 2.6,
          "stroke-linecap": "round",
        },
      },
      // blue swoosh stroke (above the green), a flag
      {
        kind: "path",
        role: "b",
        attrs: {
          d: "M7 16c3-5 6-7.5 11-7.5",
          fill: "none",
          "stroke-width": 2.6,
          "stroke-linecap": "round",
        },
      },
      {
        kind: "text",
        role: "ink",
        text: "LyPay",
        attrs: {
          x: 33,
          y: 20,
          "font-family": FONT,
          "font-size": 9,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 0.3,
        },
      },
    ],
  },
  // OnePay — a deep-blue rounded tile with a stylised folded "1" ribbon motif.
  // Original geometry: rounded tile (deep blue), a folded "1" from two strokes
  // in a lighter blue, plus a small "PAY" wordmark.
  onepay: {
    viewBox: "0 0 48 32",
    label: "OnePay (placeholder mark)",
    placeholder: true,
    colors: { a: "#1F6FB2", b: "#2AA0D8", ink: "#FFFFFF" },
    shapes: [
      { kind: "rect", role: "a", attrs: { width: 48, height: 32, rx: 6 } },
      // folded "1": a flag-foot stroke + the upright, in the lighter blue tone.
      {
        kind: "path",
        role: "b",
        attrs: {
          d: "M10 11.5l4-2.5v14",
          fill: "none",
          "stroke-width": 2.6,
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
        },
      },
      {
        kind: "path",
        role: "b",
        attrs: {
          d: "M11 23h6",
          fill: "none",
          "stroke-width": 2.6,
          "stroke-linecap": "round",
        },
      },
      {
        kind: "text",
        role: "ink",
        text: "PAY",
        attrs: {
          x: 32,
          y: 19.5,
          "font-family": FONT,
          "font-size": 8,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 0.5,
        },
      },
    ],
  },
  sadad: {
    viewBox: "0 0 48 32",
    label: "Sadad (placeholder mark)",
    placeholder: true,
    colors: { a: "#5B2E91", b: "#FFFFFF", ink: "#FFFFFF" },
    shapes: [
      { kind: "rect", role: "a", attrs: { width: 48, height: 32, rx: 4 } },
      {
        kind: "rect",
        role: "b",
        attrs: { x: 7, y: 9, width: 34, height: 14, rx: 3, fill: "none", "stroke-width": 1.4 },
      },
      {
        kind: "text",
        role: "ink",
        text: "SADAD",
        attrs: {
          x: 24,
          y: 20.5,
          "font-family": FONT,
          "font-size": 9,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 1,
        },
      },
    ],
  },
  tadawul: {
    viewBox: "0 0 48 32",
    label: "Tadawul (placeholder mark)",
    placeholder: true,
    colors: { a: "#1A4D4D", b: "#3FC1C9", ink: "#FFFFFF" },
    shapes: [
      { kind: "rect", role: "a", attrs: { width: 48, height: 32, rx: 4 } },
      {
        kind: "path",
        role: "b",
        attrs: {
          d: "M9 20l5-5 4 3 6-7",
          fill: "none",
          "stroke-width": 1.6,
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
        },
      },
      {
        kind: "text",
        role: "ink",
        text: "TDWL",
        attrs: {
          x: 33,
          y: 19.5,
          "font-family": FONT,
          "font-size": 6,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 0.5,
        },
      },
    ],
  },

  // ── Wallets / generic ───────────────────────────────────────────────
  "apple-pay": {
    viewBox: "0 0 48 32",
    label: "Apple Pay",
    colors: { ink: "#000000" },
    shapes: [
      ...cardFrame("#FFFFFF"),
      {
        kind: "path",
        role: "ink",
        attrs: {
          d: "M14.4 12.1c.5-.6.8-1.4.7-2.2-.7 0-1.5.5-2 1.1-.4.5-.8 1.3-.7 2.1.8.1 1.5-.4 2-1Zm.7 1.1c-1.1-.1-2 .6-2.5.6-.5 0-1.3-.6-2.1-.6-1.1 0-2.1.6-2.7 1.6-1.1 2-.3 4.9.8 6.5.5.8 1.2 1.7 2 1.6.8 0 1.1-.5 2.1-.5s1.3.5 2.1.5c.9 0 1.4-.8 2-1.5.6-.9.8-1.7.9-1.8 0 0-1.7-.7-1.7-2.6 0-1.6 1.3-2.4 1.4-2.4-.8-1.1-2-1.4-2.3-1.5Z",
        },
      },
      {
        kind: "text",
        role: "ink",
        text: "Pay",
        attrs: {
          x: 33,
          y: 19.5,
          "font-family": FONT,
          "font-size": 9,
          "font-weight": 600,
          "text-anchor": "middle",
        },
      },
    ],
  },
  "google-pay": {
    viewBox: "0 0 48 32",
    label: "Google Pay",
    colors: { a: "#4285F4", b: "#34A853", ink: "#5F6368" },
    shapes: [
      ...cardFrame("#FFFFFF"),
      {
        kind: "path",
        role: "a",
        attrs: {
          d: "M16 16.2v2.1h3a2.6 2.6 0 0 1-1.1 1.7 3.2 3.2 0 1 1-1-4.6l1.5-1.5a5.3 5.3 0 1 0 1.6 4.5h-5Z",
        },
      },
      {
        kind: "path",
        role: "b",
        attrs: { d: "M19 16.2h-3v2.1h3a3 3 0 0 0 .1-.8 4 4 0 0 0-.1-1.3Z" },
      },
      {
        kind: "text",
        role: "ink",
        text: "Pay",
        attrs: {
          x: 33,
          y: 19.5,
          "font-family": FONT,
          "font-size": 9,
          "font-weight": 600,
          "text-anchor": "middle",
        },
      },
    ],
  },
  paypal: {
    viewBox: "0 0 48 32",
    label: "PayPal",
    colors: { a: "#003087", b: "#009CDE", ink: "#003087" },
    shapes: [
      ...cardFrame(),
      {
        kind: "path",
        role: "a",
        attrs: { d: "M15 9h5.2c2.4 0 4 1.4 3.6 3.9-.4 2.6-2.4 3.9-4.9 3.9h-1.7l-.7 4.3h-2.9L15 9Z" },
      },
      {
        kind: "path",
        role: "b",
        attrs: { d: "M18 11h4.3c2.4 0 4 1.4 3.6 3.9-.4 2.6-2.4 3.9-4.9 3.9h-1.7l-.7 4.3h-2.9L18 11Z" },
      },
      {
        kind: "text",
        role: "ink",
        text: "Pal",
        attrs: {
          x: 34,
          y: 20,
          "font-family": FONT,
          "font-size": 7,
          "font-weight": 700,
          "text-anchor": "middle",
        },
      },
    ],
  },
  swift: {
    viewBox: "0 0 48 32",
    label: "SWIFT",
    colors: { a: "#0033A0", ink: "#FFFFFF" },
    shapes: [
      { kind: "rect", role: "a", attrs: { width: 48, height: 32, rx: 4 } },
      {
        kind: "text",
        role: "ink",
        text: "SWIFT",
        attrs: {
          x: 24,
          y: 20.5,
          "font-family": FONT,
          "font-size": 10,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 1.5,
        },
      },
    ],
  },
  mada: {
    viewBox: "0 0 48 32",
    label: "mada-style domestic scheme (generic)",
    placeholder: true,
    colors: { a: "#84BD00", b: "#1F3661" },
    shapes: [
      ...cardFrame(),
      { kind: "rect", role: "a", attrs: { x: 9, y: 13, width: 14, height: 6, rx: 3 } },
      { kind: "rect", role: "b", attrs: { x: 25, y: 13, width: 14, height: 6, rx: 3 } },
    ],
  },
  "generic-card": {
    viewBox: "0 0 48 32",
    label: "Card",
    colors: { a: "#3C4858", b: "#E8C56B", ink: "#FFFFFF" },
    shapes: [
      { kind: "rect", role: "a", attrs: { width: 48, height: 32, rx: 4 } },
      { kind: "rect", role: "b", attrs: { x: 6, y: 11, width: 8, height: 6, rx: 1.2 } },
      {
        kind: "path",
        role: "ink",
        attrs: {
          d: "M6 22h20",
          fill: "none",
          "stroke-width": 1.4,
          "stroke-linecap": "round",
          "stroke-opacity": 0.7,
        },
      },
      {
        kind: "path",
        role: "ink",
        attrs: {
          d: "M30 22h12",
          fill: "none",
          "stroke-width": 1.4,
          "stroke-linecap": "round",
          "stroke-opacity": 0.4,
        },
      },
    ],
  },
  "contactless-pay": {
    viewBox: "0 0 48 32",
    label: "Contactless payment",
    colors: { a: "#1F6FEB" },
    shapes: [
      ...cardFrame(),
      {
        kind: "g",
        role: "a",
        attrs: { fill: "none", "stroke-width": 1.8, "stroke-linecap": "round" },
        children: [
          { kind: "path", role: "a", attrs: { d: "M18 12a8 8 0 0 1 0 8" } },
          { kind: "path", role: "a", attrs: { d: "M22 9.5a12 12 0 0 1 0 13" } },
          { kind: "path", role: "a", attrs: { d: "M26 7.5a16 16 0 0 1 0 17" } },
        ],
      },
    ],
  },
  cash: {
    viewBox: "0 0 48 32",
    label: "Cash",
    colors: { a: "#2E7D32", b: "#A5D6A7", ink: "#A5D6A7" },
    shapes: [
      ...cardFrame("#E8F5E9"),
      { kind: "rect", role: "a", attrs: { x: 9, y: 9, width: 30, height: 14, rx: 2 } },
      {
        kind: "circle",
        role: "b",
        attrs: { cx: 24, cy: 16, r: 4, fill: "none", "stroke-width": 1.4 },
      },
      {
        kind: "text",
        role: "ink",
        text: "$",
        attrs: {
          x: 24,
          y: 18.5,
          "font-family": FONT,
          "font-size": 6,
          "font-weight": 700,
          "text-anchor": "middle",
        },
      },
    ],
  },
  "bank-building": {
    viewBox: "0 0 48 32",
    label: "Bank",
    colors: { a: "#2A3A5A" },
    shapes: [
      ...cardFrame("#EEF1F6"),
      {
        kind: "g",
        role: "a",
        attrs: {
          fill: "none",
          "stroke-width": 1.6,
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
        },
        children: [
          { kind: "path", role: "a", attrs: { d: "M14 14l10-5 10 5" } },
          { kind: "path", role: "a", attrs: { d: "M16 14v7" } },
          { kind: "path", role: "a", attrs: { d: "M21 14v7" } },
          { kind: "path", role: "a", attrs: { d: "M27 14v7" } },
          { kind: "path", role: "a", attrs: { d: "M32 14v7" } },
          { kind: "path", role: "a", attrs: { d: "M13 23h22" } },
        ],
      },
    ],
  },
};

/** All brand-mark names, in catalogue order. */
export const BRAND_MARK_NAMES: BrandMarkName[] = [
  "visa",
  "mastercard",
  "amex",
  "discover",
  "unionpay",
  "western-union",
  "moneygram",
  "numo",
  "moamalat",
  "lypay",
  "onepay",
  "sadad",
  "tadawul",
  "apple-pay",
  "google-pay",
  "paypal",
  "swift",
  "mada",
  "generic-card",
  "contactless-pay",
  "cash",
  "bank-building",
];

/** True when `name` is a known brand mark. Acts as a type guard. */
export function isBrandMarkName(name: string): name is BrandMarkName {
  return Object.prototype.hasOwnProperty.call(MARK_DEFS, name);
}

// ── Rendering ───────────────────────────────────────────────────────────────

const escapeAttr = (v: string): string =>
  v.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

const escapeText = (v: string): string =>
  v.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

/** The single SVG tag for a shape kind ('g' has children, 'text' has a body). */
const SELF_CLOSING: Record<ShapeKind, boolean> = {
  rect: true,
  circle: true,
  ellipse: true,
  path: true,
  line: true,
  text: false,
  g: false,
};

/** A rect that fills the whole canvas — a coloured card body / backdrop. */
function isFullBleedBackdrop(shape: Shape, def: MarkDef): boolean {
  if (shape.kind !== "rect") return false;
  const [, , vbW, vbH] = def.viewBox.split(" ").map(Number);
  const w = Number(shape.attrs.width);
  const h = Number(shape.attrs.height);
  // Anchored at the origin (no x/y, or 0) and spanning the full viewBox.
  const x = Number(shape.attrs.x ?? 0);
  const y = Number(shape.attrs.y ?? 0);
  return x === 0 && y === 0 && w === vbW && h === vbH;
}

/**
 * Resolve the paint attributes a shape gets in a given variant.
 *  - color   → brand colour by role; strokes (fill:none in attrs) keep stroke=colour.
 *  - mono    → everything is a flat `currentColor` silhouette (fill); neutral
 *              frames AND full-bleed coloured backdrops are dropped so the inked
 *              glyph reads as the silhouette (e.g. AMEX/SWIFT lettering).
 *  - outline → stroke="currentColor", fill="none", round joins; frames/backdrops
 *              dropped.
 * Returns null when the shape should be omitted in this variant.
 */
function paintFor(
  shape: Shape,
  variant: BrandMarkVariant,
  def: MarkDef,
): Record<string, string | number> | null {
  const isStrokeShape = shape.attrs.fill === "none" || shape.attrs["stroke-width"] !== undefined;
  const isFrame = shape.role === "bg" || shape.role === "hairline";

  if (variant === "color") {
    const out: Record<string, string | number> = {};
    if (isFrame) {
      // Neutral frame keeps its literal colours (bg fill / hairline stroke).
      if (shape.role === "bg") {
        out.fill = shape.attrs.fill ?? CARD_BG;
      } else {
        out.fill = "none";
        out.stroke = CARD_HAIRLINE;
      }
      return out;
    }
    const brand = def.colors[shape.role] ?? shape.attrs.fill ?? "#000000";
    if (isStrokeShape) {
      out.fill = "none";
      out.stroke = brand;
    } else {
      out.fill = brand;
    }
    return out;
  }

  // mono + outline: drop the neutral frame and any full-bleed coloured backdrop,
  // so the foreground glyph (text/paths) becomes the silhouette.
  if (isFrame || isFullBleedBackdrop(shape, def)) return null;

  if (variant === "mono") {
    // Flatten to a single currentColor silhouette. Stroke shapes stay strokes
    // (so line-art marks like contactless/bank still read), filled shapes fill.
    if (isStrokeShape) {
      return { fill: "none", stroke: "currentColor" };
    }
    return { fill: "currentColor" };
  }

  // outline
  return { fill: "none", stroke: "currentColor" };
}

/** Stroke-width to use for a shape in mono/outline (keeps line marks tidy). */
function strokeWidthFor(shape: Shape, variant: BrandMarkVariant): number | undefined {
  if (variant === "color") {
    return shape.attrs["stroke-width"] as number | undefined;
  }
  // For native stroke shapes, keep their authored weight; otherwise use 1.8.
  const authored = shape.attrs["stroke-width"];
  if (typeof authored === "number") return authored;
  return variant === "outline" ? 1.8 : authored === undefined ? undefined : Number(authored);
}

// Attrs that are PAINT (resolved per variant) rather than geometry/typography.
const PAINT_KEYS = new Set([
  "fill",
  "stroke",
  "fill-opacity",
  "stroke-opacity",
  "stroke-width",
  "stroke-linecap",
  "stroke-linejoin",
]);

/**
 * Render one shape to an SVG element string for the given variant.
 *
 * `inGroup` marks a child of a <g>: the group already carries the resolved
 * paint, so children emit ONLY geometry and INHERIT fill/stroke. This keeps
 * grouped line-art (contactless, bank) as strokes in every variant instead of
 * accidentally giving each child a brand fill.
 */
function renderShape(
  shape: Shape,
  variant: BrandMarkVariant,
  def: MarkDef,
  inGroup = false,
): string {
  const paint = inGroup ? {} : paintFor(shape, variant, def);
  if (paint === null) return "";

  const merged: Record<string, string | number> = {};
  for (const [k, v] of Object.entries(shape.attrs)) {
    if (PAINT_KEYS.has(k)) continue;
    merged[k] = v;
  }
  // Apply resolved paint (skipped for group children — they inherit).
  for (const [k, v] of Object.entries(paint)) merged[k] = v;

  if (!inGroup) {
    // Stroke niceties for line shapes / mono / outline.
    const sw = strokeWidthFor(shape, variant);
    if (sw !== undefined && (merged.stroke !== undefined || merged.fill === "none")) {
      merged["stroke-width"] = sw;
    }
    if (
      (variant === "outline" || (variant === "mono" && merged.stroke === "currentColor")) &&
      merged.stroke !== undefined
    ) {
      merged["stroke-linecap"] = shape.attrs["stroke-linecap"] ?? "round";
      merged["stroke-linejoin"] = shape.attrs["stroke-linejoin"] ?? "round";
    }
    // Carry through opacities that aren't a brand colour.
    if (shape.attrs["fill-opacity"] !== undefined && merged.fill !== "none") {
      merged["fill-opacity"] = shape.attrs["fill-opacity"];
    }
    if (shape.attrs["stroke-opacity"] !== undefined && merged.stroke !== undefined) {
      merged["stroke-opacity"] = shape.attrs["stroke-opacity"];
    }
  }

  const attrStr = Object.entries(merged)
    .map(([k, v]) => `${k}="${typeof v === "string" ? escapeAttr(v) : v}"`)
    .join(" ");

  if (shape.kind === "g") {
    const inner = (shape.children ?? []).map((c) => renderShape(c, variant, def, true)).join("");
    return `<g ${attrStr}>${inner}</g>`;
  }
  if (shape.kind === "text") {
    return `<text ${attrStr}>${escapeText(shape.text ?? "")}</text>`;
  }
  if (SELF_CLOSING[shape.kind]) {
    return `<${shape.kind} ${attrStr}/>`;
  }
  return `<${shape.kind} ${attrStr}></${shape.kind}>`;
}

// ── Official-asset override registry ────────────────────────────────────────

/** Per-variant override entry. A bare string fills all three variants. */
interface OverrideEntry {
  color?: string;
  mono?: string;
  outline?: string;
}

const OVERRIDES = new Map<string, OverrideEntry>();

/**
 * Register a brand's OFFICIAL, licensed SVG, overriding the bundled placeholder.
 *
 * Licensed users SHOULD call this to render approved official artwork:
 *   registerBrandMark("visa", officialVisaSvg);              // all variants
 *   registerBrandMark("visa", { color, mono, outline });     // per-variant
 *
 * After registration, brandMarkSvg(name, { variant }) returns the override,
 * falling back across variants when only some are provided
 * (color → mono → outline, whichever exists). <npt-brand-mark> uses it too.
 *
 * `name` is typed as BrandMarkName | string so you may also register your own
 * additional brands (then render them via brandMarkSvg(yourName)).
 */
export function registerBrandMark(
  name: BrandMarkName | string,
  svg: string | OverrideEntry,
): void {
  const entry: OverrideEntry = typeof svg === "string" ? { color: svg, mono: svg, outline: svg } : { ...svg };
  OVERRIDES.set(name, entry);
}

/** Remove a previously registered override (mainly for tests/tooling). */
export function unregisterBrandMark(name: BrandMarkName | string): void {
  OVERRIDES.delete(name);
}

/** True when an official-asset override has been registered for `name`. */
export function hasBrandMarkOverride(name: string): boolean {
  return OVERRIDES.has(name);
}

/** Pick the best override string for a variant, falling back across variants. */
function resolveOverride(entry: OverrideEntry, variant: BrandMarkVariant): string | undefined {
  const order: BrandMarkVariant[] =
    variant === "color"
      ? ["color", "mono", "outline"]
      : variant === "mono"
        ? ["mono", "color", "outline"]
        : ["outline", "color", "mono"];
  for (const v of order) {
    const s = entry[v];
    if (s) return s;
  }
  return undefined;
}

export interface BrandMarkOptions {
  /** Render variant. Default "color". */
  variant?: BrandMarkVariant;
  /** Rendered height in px; width scales to preserve the mark's aspect ratio. */
  height?: number;
  /** Optional class attribute placed on the root <svg>. */
  class?: string;
}

/** Inject/replace width & height on an <svg> head, sized to `height` by aspect. */
function sizeSvg(svg: string, height: number): string {
  const vb = svg.match(/viewBox="0 0 (\d+(?:\.\d+)?) (\d+(?:\.\d+)?)"/);
  const vbW = vb ? Number(vb[1]) : 48;
  const vbH = vb ? Number(vb[2]) : 32;
  const width = Math.round(((height * vbW) / vbH) * 100) / 100;
  const gt = svg.indexOf(">");
  let head = svg.slice(0, gt);
  head = head.replace(/\s(?:width|height)="[^"]*"/g, "");
  head += ` width="${width}" height="${height}"`;
  return head + svg.slice(gt);
}

/**
 * Build the complete <svg> for a placeholder mark in a given variant.
 */
function buildMarkSvg(name: BrandMarkName, variant: BrandMarkVariant, cls?: string): string {
  const def = MARK_DEFS[name];
  const [, , w, h] = def.viewBox.split(" ");
  void w;
  void h;
  const body = def.shapes.map((s) => renderShape(s, variant, def)).join("");
  const classAttr = cls ? ` class="${escapeAttr(cls)}"` : "";
  const placeholder = def.placeholder ? ' data-placeholder="true"' : "";
  // mono/outline silhouettes paint with currentColor — round joins are global.
  const lineAttrs =
    variant === "outline"
      ? ' fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"'
      : "";
  return (
    `<svg xmlns="http://www.w3.org/2000/svg"${classAttr} viewBox="${def.viewBox}" ` +
    `role="img" aria-label="${escapeAttr(def.label)}" ` +
    `data-npt-brand-mark="${escapeAttr(name)}" data-variant="${variant}"${placeholder}${lineAttrs}>` +
    `${body}</svg>`
  );
}

/**
 * Return the complete <svg> for `name`, in the requested variant, sized to a
 * height. Aspect ratio is preserved from the mark's intrinsic viewBox.
 *
 * If an official asset was registered via registerBrandMark(), that override is
 * returned (with width/height sized to `height`), falling back across variants.
 *
 * @throws RangeError when `name` is not a known BrandMarkName and has no override.
 */
export function brandMarkSvg(name: BrandMarkName, opts: BrandMarkOptions = {}): string {
  const variant: BrandMarkVariant = opts.variant ?? "color";

  // 1) Official override wins.
  const override = OVERRIDES.get(name as string);
  if (override) {
    const raw = resolveOverride(override, variant);
    if (raw) return opts.height === undefined ? raw : sizeSvg(raw, opts.height);
  }

  // 2) Bundled placeholder.
  if (!isBrandMarkName(name)) {
    throw new RangeError(`Unknown Neptune brand mark: "${String(name)}"`);
  }
  const svg = buildMarkSvg(name, variant, opts.class);
  return opts.height === undefined ? svg : sizeSvg(svg, opts.height);
}

/**
 * BRAND_MARKS — name → complete multicolour ("color" variant) <svg> string.
 * Kept as a convenience map (back-compat). For mono/outline or overrides, use
 * brandMarkSvg(name, { variant }).
 */
export const BRAND_MARKS: Record<BrandMarkName, string> = BRAND_MARK_NAMES.reduce(
  (acc, name) => {
    acc[name] = buildMarkSvg(name, "color");
    return acc;
  },
  {} as Record<BrandMarkName, string>,
);
