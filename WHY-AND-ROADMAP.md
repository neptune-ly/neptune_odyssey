# Why Neptune Odyssey (not just Material 3) — and the roadmap

> Neptune Odyssey **inherits** Material 3 + M3 Expressive as its foundation. It is not a
> rival to M3 — it's a fintech, white-label, MENA-first **product layer** on top of it.
> If you're building a generic app, use M3. If you're shipping **banking/payments across
> many brands, platforms and Arabic/RTL**, that's where Odyssey earns its place.

## The honest "why us" — five things M3 doesn't give you

1. **The brandprint — portable, deterministic theming.**
   One short `NO1-…` string encodes an entire theme and reproduces it **byte-identically on
   Flutter, Web, React, Vue, Svelte and React Native** — enforced by golden tests (pinned
   palettes, OKLCH→sRGB ≤ 1 LSB, a checksummed codec). M3 gives you *theming*; it does not
   give you one portable hash that guarantees Flutter == Web. This is the core moat.

2. **A fintech domain layer, out of the box.**
   The expensive, regulated, fiddly surfaces M3 deliberately omits: balance/account/card
   surfaces, transaction rows + tables, transfer review→success, IBAN/amount/currency inputs,
   beneficiaries, statements/receipts, QR/NFC pay — and corporate: maker-checker approvals,
   bulk-payment upload→validate→repair, audit trail, roles/permissions.

3. **White-label by configuration, not by fork.**
   A new bank/PSP is **one tenant config**, not a code branch. For a processor serving many
   banks (the Moamalat/NUMO model), one core skins to N institutions. The "≥ 6 of 12 levers"
   rule keeps every tenant distinct *and* coherent.

4. **Arabic / RTL as a first-class citizen.**
   Per-brand Arabic type pairing, logical-only layout, mirrored directional icons, correct
   numerals — designed, not auto-flipped. M3 supports RTL; Odyssey is *built* for it.

5. **Regional payments + compliance, localized for Libya/MENA.**
   Local card scheme + rails (NUMO via Moamalat, LyPay, OnePay) alongside Visa/Mastercard/
   Amex/WU/MoneyGram/SWIFT, plus currency (LYD), IBAN/phone/ID formats, KYC tiers, cutoffs —
   as typed config + brand marks. "Really for Libyans," then the wider region.

If none of those five matter to you, M3 alone is the right call. Odyssey is for the teams
where **all five** are real, recurring costs.

---

## Enhancement plan (what makes it *better*, not just different)

### Phase A — Domain depth (the moat)  ·  *highest priority*
- **Payments kit:** card-network row + saved cards + add-card with scheme auto-detect;
  Apple/Google-Pay-style buttons; NUMO/local-scheme support; tap-to-pay / QR pay sheet.
- **Money inputs:** amount keypad, currency field (LYD grouping + tabular figures),
  IBAN field with live validation/format, beneficiary picker, FX-rate row.
- **Transfer flow:** method select → review → success → receipt/share, all themed.
- **KYC / onboarding kit:** ID capture, selfie/liveness gate UI, OTP, tiered-limit meters
  (ties directly to the live onboarding work in nexus.mw).
- **Corporate:** approval-matrix editor, bulk upload→validate→**repair rows**, audit log,
  roles/permissions, cost-center views.

### Phase B — Localization & regional engine
- **Arabic-first polish:** per-brand Arabic faces, Eastern-Arabic numeral toggle, Hijri date
  option, a mirrored directional-icon set.
- **Compliance presets:** LY (+ other MENA markets) — currency, IBAN/phone/ID, KYC, cutoffs,
  working days — as drop-in tenant config.
- **Payment-rail registry:** typed config + brand marks + capability flags for NUMO, Moamalat,
  LyPay, OnePay, Visa, Mastercard, Amex, Discover, UnionPay, Western Union, MoneyGram, SWIFT.

### Phase C — Developer experience & trust (lower adoption friction)
- **Figma kit + token export** (Style Dictionary) so designers use the same source of truth.
- **CLI / codemods:** `npx neptune-odyssey init` scaffolds a themed starter per framework.
- **AI theming:** paste brand colours/logo → generate a brandprint (extend the configurator).
- **Visual-regression tests:** golden screenshots per brand × mode × direction in CI.
- **Governance:** semver gate on the token layer; component status board; changelog discipline.

### Phase D — Performance & quality bar
- Tree-shaking budgets, SSR, critical-CSS, 60 fps, reduced-motion — formalize and measure;
  publish bundle-size budgets per package.

### Phase E — Reach
- Promote **Kotlin Multiplatform** (Compose + web) off the roadmap to a shipped package,
  reusing the same pinned palettes + brandprint codec (golden-tested, like the Dart port).

---

## A note on the brand marks (Visa, Mastercard, NUMO, …)
Payment-network and scheme logos are **third-party trademarks of their owners**. Odyssey ships
**simplified identification marks / placeholders** (kept separate from the original icon set and
**not** covered by the Odyssey license). In production, use each brand's **official assets** per
their brand guidelines. The Libyan marks (NUMO, Moamalat, LyPay, OnePay) ship as neutral
placeholders to be replaced with official artwork.

© 2026 Neptune.Fintech.
