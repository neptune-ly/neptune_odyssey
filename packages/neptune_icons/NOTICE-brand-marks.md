# NOTICE — Brand marks (third-party trademarks)

The payment-network and fintech **brand marks** shipped in this package
(`src/brand-marks.ts` → `BRAND_MARKS`, `brandMarkSvg`, `<npt-brand-mark>`) —
including but not limited to **Visa, Mastercard, American Express, Discover,
UnionPay, Western Union, MoneyGram, Apple Pay, Google Pay, PayPal, SWIFT,
mada, NUMO, Moamalat, LyPay, OnePay, Sadad, and Tadawul** — are
**third-party trademarks of their respective owners**.

They are provided here ONLY as **simplified, schematic identification marks /
placeholders** so that a user interface can label a payment method. They are:

- **original, clean geometric placeholders** authored for Neptune Odyssey —
  **NOT traced or copied** from any official logo artwork;
- **NOT** pixel-exact reproductions of any official logo;
- **NOT** licensed under the Neptune Odyssey Community License v1.0 (which covers
  only the original monochrome icon set in `src/icons.ts`);
- kept **separate** from the `ICONS` / `IconName` set on purpose.

Each mark renders in three variants — `color`, `mono`, and `outline` — but all
three remain placeholders.

The Libyan / local marks (**NUMO, Moamalat, LyPay, OnePay, Sadad, Tadawul**) and
the generic **mada**-style mark are **neutral placeholders** (a simple badge plus
initials) — this package does not ship those brands' real assets.

## In production

Replace each brand mark with that brand's **official asset** — the supported path
is `registerBrandMark(name, svg)` (or a per-variant `{ color, mono, outline }`),
after which `brandMarkSvg()` and `<npt-brand-mark>` return your approved artwork.
Use it strictly in accordance with the relevant brand / trademark owner's brand
and usage guidelines. Use of a brand mark does not imply any endorsement,
sponsorship, or affiliation. Neptune.Fintech claims no rights in these
third-party trademarks.
