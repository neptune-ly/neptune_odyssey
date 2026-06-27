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
// official logo.
//
// These marks are NOT original Neptune Odyssey artwork and are NOT licensed
// under the Neptune Odyssey Community License. They are kept SEPARATE from the
// monochrome ICONS set on purpose. In production, replace each with the brand's
// OFFICIAL asset and follow that brand's brand/usage guidelines.
//
// The Libyan / local marks (NUMO, Moamalat, LyPay, OnePay, Sadad, Tadawul) are
// NEUTRAL PLACEHOLDERS (a simple badge + initials) — we do not ship their real
// assets. Replace them with official artwork before shipping.
//
// Unlike the stroke ICONS, brand marks are multicolour: each value is a
// COMPLETE <svg> string (with its own viewBox), not just inner markup.

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

/**
 * name → complete multicolour <svg> string.
 *
 * Card-ratio canvas (viewBox 0 0 48 32) for wide marks; 32×32 for square
 * badges. A neutral card body (#F4F5F7 fill, #E1E3E8 hairline) frames most
 * marks so they sit well on any surface.
 */
export const BRAND_MARKS: Record<BrandMarkName, string> = {
  // ── Card networks ───────────────────────────────────────────────────
  visa:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Visa" data-npt-brand-mark="visa">' +
    '<rect width="48" height="32" rx="4" fill="#F4F5F7"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#E1E3E8"/>' +
    '<text x="24" y="21.5" font-family="Arial, Helvetica, sans-serif" font-size="13" font-style="italic" font-weight="700" fill="#1A1F71" text-anchor="middle" letter-spacing="0.5">VISA</text>' +
    '</svg>',
  mastercard:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Mastercard" data-npt-brand-mark="mastercard">' +
    '<rect width="48" height="32" rx="4" fill="#F4F5F7"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#E1E3E8"/>' +
    '<circle cx="20" cy="16" r="8" fill="#EB001B"/><circle cx="28" cy="16" r="8" fill="#F79E1B"/>' +
    '<path d="M24 9.7a8 8 0 0 0 0 12.6 8 8 0 0 0 0-12.6Z" fill="#FF5F00"/>' +
    '</svg>',
  amex:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="American Express" data-npt-brand-mark="amex">' +
    '<rect width="48" height="32" rx="4" fill="#2E77BC"/>' +
    '<rect x="6" y="9" width="36" height="14" rx="2" fill="#FFFFFF" fill-opacity="0.12"/>' +
    '<text x="24" y="20.5" font-family="Arial, Helvetica, sans-serif" font-size="11" font-weight="700" fill="#FFFFFF" text-anchor="middle" letter-spacing="1">AMEX</text>' +
    '</svg>',
  discover:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Discover" data-npt-brand-mark="discover">' +
    '<rect width="48" height="32" rx="4" fill="#F4F5F7"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#E1E3E8"/>' +
    '<text x="21" y="20.5" font-family="Arial, Helvetica, sans-serif" font-size="9" font-weight="700" fill="#231F20" text-anchor="middle" letter-spacing="0.3">DISC</text>' +
    '<circle cx="36" cy="17" r="6" fill="#F58220"/>' +
    '</svg>',
  unionpay:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="UnionPay" data-npt-brand-mark="unionpay">' +
    '<rect width="48" height="32" rx="4" fill="#F4F5F7"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#E1E3E8"/>' +
    '<rect x="10" y="7" width="9" height="18" rx="2" fill="#E21836"/>' +
    '<rect x="19" y="7" width="9" height="18" rx="2" fill="#00447C"/>' +
    '<rect x="28" y="7" width="9" height="18" rx="2" fill="#007B84"/>' +
    '<text x="24" y="19.5" font-family="Arial, Helvetica, sans-serif" font-size="6" font-weight="700" fill="#FFFFFF" text-anchor="middle">UPAY</text>' +
    '</svg>',

  // ── Money transfer ──────────────────────────────────────────────────
  "western-union":
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Western Union" data-npt-brand-mark="western-union">' +
    '<rect width="48" height="32" rx="4" fill="#FFDD00"/>' +
    '<text x="24" y="14.5" font-family="Arial, Helvetica, sans-serif" font-size="7" font-weight="700" fill="#000000" text-anchor="middle" letter-spacing="0.5">WESTERN</text>' +
    '<text x="24" y="23.5" font-family="Arial, Helvetica, sans-serif" font-size="7" font-weight="700" fill="#000000" text-anchor="middle" letter-spacing="0.5">UNION</text>' +
    '</svg>',
  moneygram:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="MoneyGram" data-npt-brand-mark="moneygram">' +
    '<rect width="48" height="32" rx="4" fill="#F4F5F7"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#E1E3E8"/>' +
    '<circle cx="13" cy="16" r="5" fill="#E51937"/>' +
    '<text x="29" y="19.5" font-family="Arial, Helvetica, sans-serif" font-size="7" font-weight="700" fill="#E51937" text-anchor="middle">MGRAM</text>' +
    '</svg>',

  // ── Libyan / local — PLACEHOLDERS (replace with official assets) ─────
  numo:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="NUMO (placeholder mark)" data-npt-brand-mark="numo" data-placeholder="true">' +
    '<rect width="48" height="32" rx="4" fill="#0E2A47"/>' +
    '<rect x="6" y="8" width="36" height="16" rx="3" fill="none" stroke="#5AA9E6" stroke-width="1.4"/>' +
    '<text x="24" y="21" font-family="Arial, Helvetica, sans-serif" font-size="9" font-weight="700" fill="#FFFFFF" text-anchor="middle" letter-spacing="1.5">NUMO</text>' +
    '</svg>',
  moamalat:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Moamalat (placeholder mark)" data-npt-brand-mark="moamalat" data-placeholder="true">' +
    '<rect width="48" height="32" rx="4" fill="#1C7A4D"/>' +
    '<circle cx="13" cy="16" r="6" fill="none" stroke="#FFFFFF" stroke-width="1.4"/>' +
    '<text x="13" y="19" font-family="Arial, Helvetica, sans-serif" font-size="8" font-weight="700" fill="#FFFFFF" text-anchor="middle">M</text>' +
    '<text x="30" y="19.5" font-family="Arial, Helvetica, sans-serif" font-size="7" font-weight="700" fill="#FFFFFF" text-anchor="middle">MOAM</text>' +
    '</svg>',
  lypay:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="LyPay (placeholder mark)" data-npt-brand-mark="lypay" data-placeholder="true">' +
    '<rect width="48" height="32" rx="4" fill="#0B6E4F"/>' +
    '<rect x="7" y="9" width="34" height="14" rx="7" fill="#FFFFFF" fill-opacity="0.1"/>' +
    '<text x="24" y="21" font-family="Arial, Helvetica, sans-serif" font-size="9" font-weight="700" fill="#FFFFFF" text-anchor="middle" letter-spacing="0.5">LyPay</text>' +
    '</svg>',
  onepay:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="OnePay (placeholder mark)" data-npt-brand-mark="onepay" data-placeholder="true">' +
    '<rect width="48" height="32" rx="4" fill="#243B6B"/>' +
    '<circle cx="13" cy="16" r="6.5" fill="none" stroke="#F5A623" stroke-width="1.6"/>' +
    '<text x="13" y="19.5" font-family="Arial, Helvetica, sans-serif" font-size="9" font-weight="700" fill="#F5A623" text-anchor="middle">1</text>' +
    '<text x="30" y="19.5" font-family="Arial, Helvetica, sans-serif" font-size="7" font-weight="700" fill="#FFFFFF" text-anchor="middle">PAY</text>' +
    '</svg>',
  sadad:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Sadad (placeholder mark)" data-npt-brand-mark="sadad" data-placeholder="true">' +
    '<rect width="48" height="32" rx="4" fill="#5B2E91"/>' +
    '<rect x="7" y="9" width="34" height="14" rx="3" fill="#FFFFFF" fill-opacity="0.1"/>' +
    '<text x="24" y="21" font-family="Arial, Helvetica, sans-serif" font-size="9" font-weight="700" fill="#FFFFFF" text-anchor="middle" letter-spacing="1">SADAD</text>' +
    '</svg>',
  tadawul:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Tadawul (placeholder mark)" data-npt-brand-mark="tadawul" data-placeholder="true">' +
    '<rect width="48" height="32" rx="4" fill="#1A4D4D"/>' +
    '<path d="M9 20l5-5 4 3 6-7" fill="none" stroke="#3FC1C9" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<text x="32" y="20" font-family="Arial, Helvetica, sans-serif" font-size="6" font-weight="700" fill="#FFFFFF" text-anchor="middle">TDWL</text>' +
    '</svg>',

  // ── Wallets / generic ───────────────────────────────────────────────
  "apple-pay":
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Apple Pay" data-npt-brand-mark="apple-pay">' +
    '<rect width="48" height="32" rx="4" fill="#FFFFFF"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#E1E3E8"/>' +
    '<path d="M14.4 12.1c.5-.6.8-1.4.7-2.2-.7 0-1.5.5-2 1.1-.4.5-.8 1.3-.7 2.1.8.1 1.5-.4 2-1Zm.7 1.1c-1.1-.1-2 .6-2.5.6-.5 0-1.3-.6-2.1-.6-1.1 0-2.1.6-2.7 1.6-1.1 2-.3 4.9.8 6.5.5.8 1.2 1.7 2 1.6.8 0 1.1-.5 2.1-.5s1.3.5 2.1.5c.9 0 1.4-.8 2-1.5.6-.9.8-1.7.9-1.8 0 0-1.7-.7-1.7-2.6 0-1.6 1.3-2.4 1.4-2.4-.8-1.1-2-1.4-2.3-1.5Z" fill="#000000"/>' +
    '<text x="33" y="19.5" font-family="Arial, Helvetica, sans-serif" font-size="9" font-weight="600" fill="#000000" text-anchor="middle">Pay</text>' +
    '</svg>',
  "google-pay":
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Google Pay" data-npt-brand-mark="google-pay">' +
    '<rect width="48" height="32" rx="4" fill="#FFFFFF"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#E1E3E8"/>' +
    '<path d="M16 16.2v2.1h3a2.6 2.6 0 0 1-1.1 1.7 3.2 3.2 0 1 1-1-4.6l1.5-1.5a5.3 5.3 0 1 0 1.6 4.5h-5Z" fill="#4285F4"/>' +
    '<path d="M19 16.2h-3v2.1h3a3 3 0 0 0 .1-.8 4 4 0 0 0-.1-1.3Z" fill="#34A853"/>' +
    '<text x="33" y="19.5" font-family="Arial, Helvetica, sans-serif" font-size="9" font-weight="600" fill="#5F6368" text-anchor="middle">Pay</text>' +
    '</svg>',
  paypal:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="PayPal" data-npt-brand-mark="paypal">' +
    '<rect width="48" height="32" rx="4" fill="#F4F5F7"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#E1E3E8"/>' +
    '<path d="M15 9h5.2c2.4 0 4 1.4 3.6 3.9-.4 2.6-2.4 3.9-4.9 3.9h-1.7l-.7 4.3h-2.9L15 9Z" fill="#003087"/>' +
    '<path d="M18 11h4.3c2.4 0 4 1.4 3.6 3.9-.4 2.6-2.4 3.9-4.9 3.9h-1.7l-.7 4.3h-2.9L18 11Z" fill="#009CDE"/>' +
    '<text x="34" y="20" font-family="Arial, Helvetica, sans-serif" font-size="7" font-weight="700" fill="#003087" text-anchor="middle">Pal</text>' +
    '</svg>',
  swift:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="SWIFT" data-npt-brand-mark="swift">' +
    '<rect width="48" height="32" rx="4" fill="#0033A0"/>' +
    '<text x="24" y="20.5" font-family="Arial, Helvetica, sans-serif" font-size="10" font-weight="700" fill="#FFFFFF" text-anchor="middle" letter-spacing="1.5">SWIFT</text>' +
    '</svg>',
  mada:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="mada-style domestic scheme (generic)" data-npt-brand-mark="mada" data-placeholder="true">' +
    '<rect width="48" height="32" rx="4" fill="#F4F5F7"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#E1E3E8"/>' +
    '<rect x="9" y="13" width="14" height="6" rx="3" fill="#84BD00"/>' +
    '<rect x="25" y="13" width="14" height="6" rx="3" fill="#1F3661"/>' +
    '</svg>',
  "generic-card":
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Card" data-npt-brand-mark="generic-card">' +
    '<rect width="48" height="32" rx="4" fill="#3C4858"/>' +
    '<rect x="6" y="11" width="8" height="6" rx="1.2" fill="#E8C56B"/>' +
    '<path d="M6 22h20" stroke="#FFFFFF" stroke-width="1.4" stroke-linecap="round" stroke-opacity="0.7"/>' +
    '<path d="M30 22h12" stroke="#FFFFFF" stroke-width="1.4" stroke-linecap="round" stroke-opacity="0.4"/>' +
    '</svg>',
  "contactless-pay":
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Contactless payment" data-npt-brand-mark="contactless-pay">' +
    '<rect width="48" height="32" rx="4" fill="#F4F5F7"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#E1E3E8"/>' +
    '<g fill="none" stroke="#1F6FEB" stroke-width="1.8" stroke-linecap="round">' +
    '<path d="M18 12a8 8 0 0 1 0 8"/><path d="M22 9.5a12 12 0 0 1 0 13"/><path d="M26 7.5a16 16 0 0 1 0 17"/></g>' +
    '</svg>',
  cash:
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Cash" data-npt-brand-mark="cash">' +
    '<rect width="48" height="32" rx="4" fill="#E8F5E9"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#C8E6C9"/>' +
    '<rect x="9" y="9" width="30" height="14" rx="2" fill="#2E7D32"/>' +
    '<circle cx="24" cy="16" r="4" fill="none" stroke="#A5D6A7" stroke-width="1.4"/>' +
    '<text x="24" y="18.5" font-family="Arial, Helvetica, sans-serif" font-size="6" font-weight="700" fill="#A5D6A7" text-anchor="middle">$</text>' +
    '</svg>',
  "bank-building":
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 32" role="img" aria-label="Bank" data-npt-brand-mark="bank-building">' +
    '<rect width="48" height="32" rx="4" fill="#EEF1F6"/><rect x="0.5" y="0.5" width="47" height="31" rx="3.5" fill="none" stroke="#E1E3E8"/>' +
    '<g fill="none" stroke="#2A3A5A" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">' +
    '<path d="M14 14l10-5 10 5"/><path d="M16 14v7"/><path d="M21 14v7"/><path d="M27 14v7"/><path d="M32 14v7"/><path d="M13 23h22"/></g>' +
    '</svg>',
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
  return Object.prototype.hasOwnProperty.call(BRAND_MARKS, name);
}

export interface BrandMarkOptions {
  /** Rendered height in px; width scales to preserve the mark's aspect ratio. */
  height?: number;
}

/**
 * Return the complete multicolour <svg> for `name`, sized to a given height.
 * Aspect ratio is preserved from the mark's intrinsic viewBox.
 * @throws RangeError when `name` is not a known BrandMarkName.
 */
export function brandMarkSvg(name: BrandMarkName, opts: BrandMarkOptions = {}): string {
  if (!isBrandMarkName(name)) {
    throw new RangeError(`Unknown Neptune brand mark: "${String(name)}"`);
  }
  const svg = BRAND_MARKS[name];
  if (opts.height === undefined) return svg;

  const vb = svg.match(/viewBox="0 0 (\d+(?:\.\d+)?) (\d+(?:\.\d+)?)"/);
  const vbW = vb ? Number(vb[1]) : 48;
  const vbH = vb ? Number(vb[2]) : 32;
  const height = opts.height;
  const width = Math.round((height * vbW) / vbH * 100) / 100;

  // Inject width/height after the opening "<svg" — replace any existing ones.
  let head = svg.slice(0, svg.indexOf(">"));
  head = head.replace(/\s(?:width|height)="[^"]*"/g, "");
  head += ` width="${width}" height="${height}"`;
  return head + svg.slice(svg.indexOf(">"));
}
