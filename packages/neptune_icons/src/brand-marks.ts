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
  /** Render this filled shape as a currentColor OUTLINE (not a fill) in mono. */
  monoStroke?: boolean;
  /** Omit this shape entirely from the mono + outline variants (e.g. white gaps). */
  monoHide?: boolean;
}

/** A linear-gradient definition, injected into <defs> for the "color" variant. */
interface GradientDef {
  id: string;
  /** objectBoundingBox coords (0..1). Default: horizontal (0,0)→(1,0). */
  x1?: number;
  y1?: number;
  x2?: number;
  y2?: number;
  stops: { offset: number | string; color: string }[];
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
  /** Gradients available to the colour variant; a shape uses one via fill="url(#id)". */
  gradients?: GradientDef[];
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
// Arabic-capable stack — the local Libyan marks carry their native wordmark.
const AR_FONT = "'Geeza Pro', 'Noto Sans Arabic', Tahoma, 'Segoe UI', Arial, sans-serif";

// LyPay swoosh — the mark from the Neptune mobile app (24×24 path), reused
// here in Odyssey style (gradient fill / currentColor silhouette).
const LYPAY_SWOOSH =
  "M2.76255 10.6811C2.89958 10.7664 3.0384 10.8482 3.17901 10.9246C3.40503 11.0472 3.53673 11.2854 3.50648 11.5164L3.50114 11.5626C3.47978 11.7243 3.38901 11.8434 3.2413 11.902C3.09358 11.9625 2.93162 11.9465 2.77322 11.8594C2.61127 11.7688 2.45109 11.671 2.29269 11.5715C2.08802 11.44 1.9759 11.2196 2.00438 11.0028L2.00972 10.9637C2.03107 10.7984 2.12718 10.6758 2.28202 10.6189C2.43685 10.5621 2.60593 10.5834 2.76255 10.6829M5.00146 9.48332C5.14027 9.56684 5.27909 9.64505 5.42149 9.71967C5.64929 9.83876 5.78453 10.0751 5.75961 10.3062L5.75427 10.3524C5.73649 10.5141 5.64929 10.6349 5.50334 10.6989C5.35742 10.7629 5.19544 10.7505 5.03705 10.6651C4.87332 10.5763 4.71314 10.4839 4.55296 10.3844C4.34651 10.2564 4.23083 10.036 4.25397 9.81922L4.25753 9.77834C4.27532 9.61127 4.36965 9.48866 4.52093 9.42645C4.67399 9.36603 4.84306 9.38557 5.00146 9.48156V9.48332ZM4.0582 6.42304C4.19524 6.51012 4.33227 6.59365 4.47288 6.67184C4.69712 6.79802 4.82704 7.03616 4.79323 7.26719L4.78611 7.3134C4.76297 7.47334 4.67043 7.59064 4.52271 7.64929C4.37499 7.70793 4.21125 7.69016 4.05464 7.59952C3.89268 7.50711 3.73428 7.40937 3.57766 7.30629C3.37478 7.173 3.26443 6.95086 3.29647 6.73582L3.30181 6.69672C3.32494 6.53144 3.42283 6.41059 3.57766 6.3555C3.7325 6.30041 3.90158 6.32351 4.0582 6.42481V6.42304ZM7.50912 9.55974C6.86841 9.35003 6.25261 9.04437 5.67955 8.65339C5.44282 8.49166 5.32716 8.21619 5.39299 7.97274L5.40012 7.94785C5.4464 7.7808 5.56031 7.66706 5.72939 7.62085C5.89843 7.57464 6.07644 7.61019 6.23838 7.72037C6.69933 8.03671 7.19764 8.28375 7.71556 8.45258C7.88106 8.50587 8.01099 8.61072 8.10176 8.76179C8.19254 8.91287 8.21746 9.06746 8.17652 9.21854L8.16938 9.24342C8.09463 9.51886 7.80634 9.6557 7.50733 9.55798L7.50912 9.55974ZM7.13716 6.98818C7.09622 6.9704 7.05348 6.95263 7.01257 6.93486C6.71536 6.80513 6.42703 6.65584 6.1476 6.49235C5.90022 6.34662 5.76496 6.07827 5.81124 5.82591L5.81658 5.79925C5.8486 5.62686 5.95185 5.50424 6.11559 5.44381C6.27932 5.38517 6.4555 5.40649 6.62458 5.50602C6.85594 5.64286 7.09622 5.76548 7.34181 5.87389C7.38275 5.89166 7.42545 5.90943 7.46639 5.9272C7.85438 6.11203 8.26905 6.25065 8.70333 6.33418C10.0719 6.59897 10.9315 6.19911 11.8214 5.78681C12.9302 5.27321 14.0764 4.74183 16.1302 5.13814C17.4472 5.39228 18.6663 5.99296 19.6897 6.8229C20.5422 7.516 21.2576 8.36548 21.7773 9.30739C22.0104 9.73212 22.062 10.1587 21.925 10.5674L19.1433 18.8703C19.1041 18.9859 19.0009 19.0516 18.8727 19.0427C18.7428 19.0356 18.6254 18.9556 18.5631 18.8348C18.1715 18.0759 17.6821 17.3917 17.1144 16.8177C17.1001 16.8035 17.0859 16.7893 17.0717 16.7751C16.9079 16.5991 16.7335 16.4321 16.5484 16.2774C15.8721 15.7123 15.0552 15.3018 14.1653 15.1294C14.1244 15.1205 14.0817 15.1134 14.0408 15.1063H14.039C12.7576 14.8913 11.9211 15.2769 11.0579 15.675C9.94202 16.1886 8.78873 16.72 6.73848 16.3254C5.86462 16.1566 5.03349 15.8349 4.27354 15.3942C3.99056 15.2307 3.71648 15.0494 3.45486 14.8539C3.2235 14.6816 3.12205 14.4025 3.20214 14.1644L3.21104 14.1395C3.26621 13.976 3.38723 13.8694 3.55987 13.8321C3.7325 13.7947 3.9087 13.8392 4.06709 13.9565C4.28422 14.1182 4.51025 14.2692 4.74517 14.4043C5.36986 14.7669 6.05862 15.0316 6.78653 15.172C8.47373 15.4973 9.46504 15.0405 10.4243 14.5998C11.4761 14.1146 12.496 13.6455 14.2134 13.976C15.3364 14.1928 16.3704 14.7135 17.2301 15.4315C17.7213 15.842 18.1537 16.3183 18.5132 16.839L20.8411 9.89384C20.4051 9.04792 19.7822 8.28375 19.0294 7.67416C18.1876 6.99173 17.1802 6.4959 16.0857 6.28442C14.3967 5.95742 13.4125 6.41415 12.4586 6.85667C11.4085 7.34361 10.3923 7.81456 8.65883 7.48045C8.13202 7.37916 7.62303 7.20855 7.13892 6.98107L7.13716 6.98818ZM17.3066 17.9284L16.9631 18.993C16.9239 19.1138 16.8225 19.192 16.6944 19.1991C16.5662 19.2062 16.4505 19.1387 16.39 19.025C16.0091 18.2999 15.5286 17.6637 14.9715 17.1483C14.9573 17.1358 14.9431 17.1216 14.9288 17.1092C14.7687 16.9492 14.5978 16.8 14.4145 16.6649C13.7489 16.169 12.9444 15.8456 12.0652 15.7727C12.0243 15.7692 11.9834 15.7656 11.9424 15.7639H11.9407C11.7449 15.7532 11.558 15.755 11.3818 15.7692C12.083 15.4617 12.8145 15.2236 13.8539 15.3977H13.8556C13.8948 15.4049 13.934 15.412 13.9749 15.4191C14.8256 15.5844 15.6087 15.9771 16.2547 16.5174C16.4327 16.6649 16.6 16.8248 16.7549 16.9937C16.7691 17.0079 16.7833 17.0221 16.7958 17.0345C16.9364 17.1767 17.0717 17.3242 17.2016 17.4806C17.3155 17.6174 17.3546 17.7809 17.3066 17.9284ZM6.03904 13.8143C5.4108 13.6081 4.81102 13.306 4.26109 12.9186C4.03328 12.7587 3.93183 12.4832 4.01014 12.2379L4.01904 12.2131C4.07243 12.0442 4.19345 11.9305 4.36431 11.8825C4.53517 11.8345 4.71136 11.8683 4.8662 11.9803C5.31114 12.293 5.79345 12.5383 6.30245 12.7053C6.46439 12.7587 6.58898 12.8617 6.67262 13.0128C6.75627 13.1638 6.77229 13.3185 6.72425 13.4713L6.71712 13.4962C6.62813 13.7734 6.33447 13.912 6.04083 13.8161L6.03904 13.8143Z";

/**
 * name → mark definition. Each is an ORIGINAL simplified geometric placeholder
 * recognisable by the brand's colours/basic forms — never traced artwork.
 */
const MARK_DEFS: Record<BrandMarkName, MarkDef> = {
  // ── Card networks ───────────────────────────────────────────────────
  visa: {
    viewBox: "0 0 48 32",
    label: "Visa",
    colors: { a: "#1A1F71", b: "#F7B600" },
    shapes: [
      ...cardFrame(),
      // the classic gold "flag" wing, top-trailing
      { kind: "path", role: "b", attrs: { d: "M30 9 h8 l-2.2 2.7 h-8 z" }, monoHide: true },
      {
        kind: "text",
        role: "a",
        text: "VISA",
        attrs: {
          x: 24,
          y: 23.5,
          "font-family": FONT,
          "font-size": 15,
          "font-style": "italic",
          "font-weight": 800,
          "text-anchor": "middle",
          "letter-spacing": -0.4,
        },
      },
    ],
  },
  // Mastercard — two single-colour circles with a clean white separation; in
  // mono they become the classic interlocking rings.
  mastercard: {
    viewBox: "0 0 48 32",
    label: "Mastercard",
    colors: { a: "#EB001B", b: "#F79E1B" },
    shapes: [
      ...cardFrame(),
      { kind: "circle", role: "a", attrs: { cx: 21, cy: 16, r: 8 }, monoStroke: true },
      // white disc behind the amber → a crisp white ring where the circles meet
      { kind: "circle", role: "c", attrs: { cx: 29, cy: 16, r: 9.4, fill: "#FFFFFF" }, monoHide: true },
      { kind: "circle", role: "b", attrs: { cx: 29, cy: 16, r: 8 }, monoStroke: true },
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
    label: "NUMO — Moamalat national card scheme (placeholder mark)",
    placeholder: true,
    colors: { a: "#0C2A4A", b: "#D7A52B", ink: "#FFFFFF" },
    shapes: [
      { kind: "rect", role: "a", attrs: { width: 48, height: 32, rx: 4 } },
      // gold accent dot + underline frame the wordmark
      { kind: "circle", role: "b", attrs: { cx: 35, cy: 11, r: 2.3 } },
      {
        kind: "text",
        role: "ink",
        text: "NUMO",
        attrs: {
          x: 24,
          y: 19,
          "font-family": FONT,
          "font-size": 11,
          "font-weight": 800,
          "text-anchor": "middle",
          "letter-spacing": 1.2,
        },
      },
      {
        kind: "path",
        role: "b",
        attrs: { d: "M15 24 H33", fill: "none", "stroke-width": 1.6, "stroke-linecap": "round" },
      },
    ],
  },
  moamalat: {
    viewBox: "0 0 48 32",
    label: "Moamalat (placeholder mark)",
    placeholder: true,
    colors: { a: "#C8992C", ink: "#243240" },
    shapes: [
      ...cardFrame(),
      // gold flowing double-arch "M" monogram (original geometry)
      {
        kind: "path",
        role: "a",
        attrs: {
          d: "M18 22 V14.5 q0 -3.6 3 -3.6 q3 0 3 3.6 V22 M24 22 V14.5 q0 -3.6 3 -3.6 q3 0 3 3.6 V22",
          fill: "none",
          "stroke-width": 2.4,
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
        },
      },
      {
        kind: "text",
        role: "ink",
        text: "moamalat",
        attrs: {
          x: 24,
          y: 28.5,
          "font-family": FONT,
          "font-size": 6.5,
          "font-weight": 700,
          "text-anchor": "middle",
          "letter-spacing": 0.2,
        },
      },
    ],
  },
  // LyPay — the official swoosh from the Neptune mobile app, in Odyssey style:
  // a green→teal→blue gradient on a mint card, beside the LYPay wordmark.
  lypay: {
    viewBox: "0 0 48 32",
    label: "LyPay (placeholder mark)",
    placeholder: true,
    colors: { ink: "#0F3A33" },
    gradients: [
      {
        id: "npt-lypay-grad",
        x1: 0,
        y1: 1,
        x2: 1,
        y2: 0,
        stops: [
          { offset: 0, color: "#15B257" },
          { offset: 0.55, color: "#13A39C" },
          { offset: 1, color: "#2E78D6" },
        ],
      },
    ],
    shapes: [
      ...cardFrame("#F0FAF6"),
      {
        kind: "path",
        role: "a",
        attrs: { d: LYPAY_SWOOSH, fill: "url(#npt-lypay-grad)", transform: "translate(1.5 5) scale(0.9)" },
      },
      {
        kind: "text",
        role: "ink",
        text: "LYPay",
        attrs: { x: 36, y: 19, "font-family": FONT, "font-size": 8, "font-weight": 800, "text-anchor": "middle", "letter-spacing": 0.2 },
      },
    ],
  },
  // OnePay (Libya) — the clean two-tone "One Pay" wordmark with a blue accent dot.
  onepay: {
    viewBox: "0 0 48 32",
    label: "OnePay (placeholder mark)",
    placeholder: true,
    colors: { a: "#1463C6", b: "#FFFFFF", ink: "#1B2733" },
    gradients: [
      {
        id: "npt-onepay-dot",
        x1: 0,
        y1: 0,
        x2: 1,
        y2: 1,
        stops: [
          { offset: 0, color: "#46A3F0" },
          { offset: 1, color: "#1463C6" },
        ],
      },
    ],
    shapes: [
      ...cardFrame(),
      // a small blue gradient "coin" accent carrying a white 1
      { kind: "circle", role: "c", attrs: { cx: 11, cy: 16, r: 4.6, fill: "url(#npt-onepay-dot)" } },
      { kind: "text", role: "b", text: "1", attrs: { x: 11, y: 18.7, "font-family": FONT, "font-size": 7, "font-weight": 800, "text-anchor": "middle" } },
      { kind: "text", role: "a", text: "One", attrs: { x: 29.5, y: 19.5, "font-family": FONT, "font-size": 9.5, "font-weight": 800, "text-anchor": "end" } },
      { kind: "text", role: "ink", text: "Pay", attrs: { x: 30.5, y: 19.5, "font-family": FONT, "font-size": 9.5, "font-weight": 800, "text-anchor": "start" } },
    ],
  },
  // Sadad — the Libyan Sadad by Almadar (المدار الجديد): a gold/amber سداد script
  // with Almadar's green swoosh accent + Latin SADAD.
  sadad: {
    viewBox: "0 0 48 32",
    label: "Sadad — Almadar (placeholder mark)",
    placeholder: true,
    colors: { a: "#CF9B22", b: "#3E9B46", ink: "#243240" },
    shapes: [
      ...cardFrame(),
      // Almadar green swoosh accent (top-right)
      { kind: "path", role: "b", attrs: { d: "M28.5 11 c4 -2 7.5 -1 9.5 2.6", fill: "none", "stroke-width": 1.8, "stroke-linecap": "round" } },
      { kind: "text", role: "a", text: "سداد", attrs: { x: 24, y: 19.5, "font-family": AR_FONT, "font-size": 13, "font-weight": 700, "text-anchor": "middle", direction: "rtl" } },
      { kind: "text", role: "ink", text: "SADAD", attrs: { x: 24, y: 27.5, "font-family": FONT, "font-size": 5, "font-weight": 700, "text-anchor": "middle", "letter-spacing": 1.4 } },
    ],
  },
  // Tadawul (Libya) — the blue+green forward chevron mark + تداول + Tadawul.
  tadawul: {
    viewBox: "0 0 48 32",
    label: "Tadawul — Libya (placeholder mark)",
    placeholder: true,
    colors: { a: "#1668B0", b: "#36A642", ink: "#243240" },
    shapes: [
      ...cardFrame(),
      { kind: "path", role: "a", attrs: { d: "M8 10 L13.5 16 L8 22", fill: "none", "stroke-width": 2.4, "stroke-linecap": "round", "stroke-linejoin": "round" } },
      { kind: "path", role: "b", attrs: { d: "M14 10 L19.5 16 L14 22", fill: "none", "stroke-width": 2.4, "stroke-linecap": "round", "stroke-linejoin": "round" } },
      { kind: "text", role: "a", text: "تداول", attrs: { x: 34, y: 18, "font-family": AR_FONT, "font-size": 9, "font-weight": 700, "text-anchor": "middle", direction: "rtl" } },
      { kind: "text", role: "ink", text: "Tadawul", attrs: { x: 34, y: 26, "font-family": FONT, "font-size": 5, "font-weight": 700, "text-anchor": "middle", "letter-spacing": 0.4 } },
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
    colors: { a: "#8A7430", b: "#EBC56B", ink: "#FFFFFF" },
    gradients: [
      {
        id: "npt-card-grad",
        x1: 0,
        y1: 0,
        x2: 1,
        y2: 1,
        stops: [
          { offset: 0, color: "#3E4E80" },
          { offset: 0.55, color: "#2A3556" },
          { offset: 1, color: "#1C2440" },
        ],
      },
    ],
    shapes: [
      // card body — a gradient in colour, a clean rounded outline in mono
      { kind: "rect", role: "c", attrs: { x: 1, y: 1, width: 46, height: 30, rx: 5, fill: "url(#npt-card-grad)" }, monoStroke: true },
      // gold EMV chip + contacts
      { kind: "rect", role: "b", attrs: { x: 7, y: 10.5, width: 8.5, height: 6.5, rx: 1.6 } },
      { kind: "path", role: "a", attrs: { d: "M11.25 10.5 v6.5 M7 13.75 h8.5", fill: "none", "stroke-width": 0.7, "stroke-opacity": 0.65 }, monoHide: true },
      // contactless waves
      {
        kind: "g",
        role: "ink",
        attrs: { fill: "none", "stroke-width": 1.4, "stroke-linecap": "round" },
        children: [
          { kind: "path", role: "ink", attrs: { d: "M38 10.5 a6 6 0 0 1 0 11" } },
          { kind: "path", role: "ink", attrs: { d: "M34.5 12.8 a3.4 3.4 0 0 1 0 6.4" } },
        ],
      },
      // masked number
      { kind: "text", role: "ink", text: "••••  ••••  4821", attrs: { x: 7, y: 27, "font-family": FONT, "font-size": 5, "font-weight": 700, "text-anchor": "start", "letter-spacing": 0.6, "fill-opacity": 0.9 } },
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
    colors: { b: "#FFFFFF", ink: "#FFFFFF" },
    gradients: [
      {
        id: "npt-cash-grad",
        x1: 0,
        y1: 0,
        x2: 1,
        y2: 1,
        stops: [
          { offset: 0, color: "#2BAB60" },
          { offset: 1, color: "#138043" },
        ],
      },
    ],
    shapes: [
      // banknote — gradient green in colour, a clean outline in mono
      { kind: "rect", role: "c", attrs: { x: 3, y: 6, width: 42, height: 20, rx: 3, fill: "url(#npt-cash-grad)" }, monoStroke: true },
      // inner hairline frame
      { kind: "rect", role: "b", attrs: { x: 5.5, y: 8.5, width: 37, height: 15, rx: 2, fill: "none", "stroke-width": 0.8, "stroke-opacity": 0.5 }, monoHide: true },
      // centre medallion + currency glyph
      { kind: "circle", role: "b", attrs: { cx: 24, cy: 16, r: 4.4, fill: "none", "stroke-width": 1.1 } },
      { kind: "text", role: "ink", text: "$", attrs: { x: 24, y: 18.4, "font-family": FONT, "font-size": 6.5, "font-weight": 700, "text-anchor": "middle" } },
      // corner denomination dots
      { kind: "circle", role: "b", attrs: { cx: 9, cy: 10.5, r: 1 } },
      { kind: "circle", role: "b", attrs: { cx: 39, cy: 21.5, r: 1 } },
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

  // mono + outline: drop the neutral frame, full-bleed backdrops, and any shape
  // flagged monoHide (e.g. a white separation disc), so the foreground glyph
  // becomes the silhouette.
  if (isFrame || isFullBleedBackdrop(shape, def) || shape.monoHide) return null;

  if (variant === "mono") {
    // Flatten to a single currentColor silhouette. Stroke shapes (and shapes
    // flagged monoStroke, e.g. interlocking circles) stay outlines; filled fill.
    if (isStrokeShape || shape.monoStroke) {
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
  // monoStroke fills become outlines and need a weight in mono too.
  if (variant === "mono" && shape.monoStroke) return 1.8;
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

async function fetchSvg(url: string): Promise<string> {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`registerBrandMarkFromUrl: HTTP ${res.status} for ${url}`);
  return res.text();
}

/**
 * Fetch a brand's OFFICIAL, licensed SVG file and register it as the override.
 * The official artwork stays in YOUR app's assets — it is never bundled into
 * this package. Pass one URL (all variants) or per-variant URLs.
 *
 *   await registerBrandMarkFromUrl("western-union", "/assets/western_union.svg");
 *   await registerBrandMarkFromUrl("visa", { color: "/assets/visa.svg", mono: "/assets/visa-mono.svg" });
 */
export async function registerBrandMarkFromUrl(
  name: BrandMarkName | string,
  url: string | { color?: string; mono?: string; outline?: string },
): Promise<void> {
  if (typeof url === "string") {
    registerBrandMark(name, await fetchSvg(url));
    return;
  }
  const entry: OverrideEntry = {};
  if (url.color) entry.color = await fetchSvg(url.color);
  if (url.mono) entry.mono = await fetchSvg(url.mono);
  if (url.outline) entry.outline = await fetchSvg(url.outline);
  registerBrandMark(name, entry);
}

/**
 * Register many official assets at once — resolves when all are applied:
 *
 *   await registerBrandMarksFromUrls({
 *     "western-union": "/assets/western_union_logo.svg",
 *     moneygram: "/assets/moneygram.svg",
 *     lypay: "/assets/lypay_icon.svg",
 *   });
 */
export async function registerBrandMarksFromUrls(
  map: Record<string, string | { color?: string; mono?: string; outline?: string }>,
): Promise<void> {
  await Promise.all(
    Object.entries(map).map(([name, url]) => registerBrandMarkFromUrl(name, url)),
  );
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
/** Serialize a GradientDef to an SVG <linearGradient>. */
function gradSvg(g: GradientDef): string {
  const coords = `x1="${g.x1 ?? 0}" y1="${g.y1 ?? 0}" x2="${g.x2 ?? 1}" y2="${g.y2 ?? 0}"`;
  const stops = g.stops
    .map((s) => `<stop offset="${s.offset}" stop-color="${s.color}"/>`)
    .join("");
  return `<linearGradient id="${g.id}" ${coords}>${stops}</linearGradient>`;
}

function buildMarkSvg(name: BrandMarkName, variant: BrandMarkVariant, cls?: string): string {
  const def = MARK_DEFS[name];
  const [, , w, h] = def.viewBox.split(" ");
  void w;
  void h;
  const body = def.shapes.map((s) => renderShape(s, variant, def)).join("");
  const classAttr = cls ? ` class="${escapeAttr(cls)}"` : "";
  const placeholder = def.placeholder ? ' data-placeholder="true"' : "";
  // Gradients only paint in the colour variant; mono/outline ignore url() fills.
  const defs =
    variant === "color" && def.gradients?.length
      ? `<defs>${def.gradients.map(gradSvg).join("")}</defs>`
      : "";
  // mono/outline silhouettes paint with currentColor — round joins are global.
  const lineAttrs =
    variant === "outline"
      ? ' fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"'
      : "";
  return (
    `<svg xmlns="http://www.w3.org/2000/svg"${classAttr} viewBox="${def.viewBox}" ` +
    `role="img" aria-label="${escapeAttr(def.label)}" ` +
    `data-npt-brand-mark="${escapeAttr(name)}" data-variant="${variant}"${placeholder}${lineAttrs}>` +
    `${defs}${body}</svg>`
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
