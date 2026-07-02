# Changelog

## 2.5.0

**The identity release — Odyssey stops looking like generic Material.** Ports
the web token levers that sit above the M3 colour scheme, so every brand
carries its signature look (verified pixel-by-pixel against the shipped web
templates via engine-rendered screenshots across 4 brands × light/dark × RTL):

- `NptIdentity` theme extension: per-brand glass recipes (`--npt-glass-tint`
  mix ratios + blur), the signature motif lever, elevation tokens
  (`--npt-elevation-1/2/3/5`), the primary key-light glow, and the
  login-shell / dashboard-hero / content-tone levers. Resolves for custom
  brandprint seeds too (keyed off the `glassTint` lever).
- `NeptuneMotifLayer`: the four brand motifs as CustomPainters — Neptune sonar
  tide-rings, Triton coastal arcs, Nereid grid-spark, Proteus shield
  guilloché — ported from the `--npt-motif` CSS gradients.
- `NeptuneGlass`: real backdrop-blur glass with the brand tint and hairline
  seal (card glass + dock pane recipes). `NeptuneCard` with the web's four
  variants (standard / elevated / tonal / glass, `motif:` overlay opt-in).
- `NeptuneEyebrow`: the uppercase, letter-spaced display-face micro-label.
- Widgets now wear the identity: the dock is glass with the raised-active
  circle popping above the bar (sprung on the brand motion curve), card art
  carries the motif + elevation + selection glow, the balance-card hero etches
  the motif over its gradient with the web's display-md amount, onboarding
  heroes get the login-shell motif backdrop, stat cards use the eyebrow.
- Example gallery: fixed phone-frame window on macOS, content scrolls under
  the glass dock, and a `--dart-define=SHOTS=true` harness renders pixel-exact
  gallery screenshots per brand/mode/scroll for visual regression.

## 2.4.0

The "fully fledged" release — ~33 new branded widgets take the package past
Material parity into a complete fintech design system (now ~88 widgets). All
theme-only (no literal colours/radii/fonts), RTL-safe, ≥48dp; 40 widget tests
pass under light/dark/RTL × brands; `flutter analyze` clean.

- Form fields: `NeptuneTextField`, `NeptuneSelect`, `NeptuneStepperInput`,
  `NeptuneDateField`.
- Selection controls: `NeptuneCheckbox`/`NeptuneCheckboxTile`,
  `NeptuneRadioGroup`, `NeptuneSwitch`, `NeptuneSegmented`, `NeptuneSlider`.
- Overlays: `showNeptuneDialog`, `showNeptuneSheet`, `NeptuneMenu`,
  `NeptuneTooltip`.
- Navigation / structure: `NeptuneTabs`, `NeptuneBreadcrumbs`,
  `NeptunePagination`, `NeptuneAccordion`.
- Display: `NeptuneAvatar`/`NeptuneAvatarGroup`, `NeptuneBadge`, `NeptuneTag`,
  `NeptuneProgressBar`, `NeptuneProgressRing`, `NeptuneRating`,
  `NeptuneListTile`, `NeptuneTimeline`.
- Fintech: `NeptuneInsightCard`, `NeptuneFxCard`, `NeptuneBudgetRing`,
  `NeptuneSpendBreakdown`, `NeptuneCreditScoreGauge`.

Mobile-readiness fixes (found by narrow-width testing): `NeptuneAccountTile`
and `NeptuneLimitMeter` trailing values now flex/ellipsize; `NeptuneApprovalItem`
stacks its actions on narrow widths; `NeptuneTabs` no longer requires a bounded
height. The example app gained gallery sections for every new widget.

## 2.3.0

The full solution — real brand typography + the remaining structural widgets.

- **Fonts now render for real.** `NeptuneTheme` integrates `google_fonts`: each
  brand's display / text / num families (Hanken Grotesk, Bricolage Grotesque,
  Space Grotesk, Sora) are loaded and applied to the whole `TextTheme`, and
  `moneyStyle` resolves the brand `num` face with tabular figures.
- **Arabic / RTL faces.** `NptType` now carries the Arabic faces per brand
  (`displayAr` / `textAr` / `numAr` — IBM Plex Sans Arabic, Reem Kufi, Tajawal,
  Readex Pro, Noto Kufi Arabic, matching the web `--npt-font-*-ar` tokens). Pass
  `arabic: true` to `NeptuneTheme.light/dark/fromConfig/fromBrandprint` for an
  RTL build; `moneyStyle` is direction-aware and swaps to the Arabic numeral
  face under RTL, mirroring the web's `[dir="rtl"]` font swap.
- **New widgets:** `NeptuneDataTable` (themed Material `DataTable`, zebra rows,
  numeric/money columns), the responsive shell — `NeptuneAppShell`,
  `NeptuneSideNav` / `NeptuneSideNavItem`, `NeptuneToolbar`, `NeptuneNavRail`
  (Material `NavigationRail`) — plus `NeptuneCardControls`, `NeptuneAddCard`
  (dashed tile), and `NeptuneToast` + `showNeptuneToast` (overlay, no Scaffold
  needed).
- **Example:** a full components-gallery screen showcasing every widget.
- Colour goldens unchanged (byte-identical); `flutter analyze` clean; all
  widget tests pass under light / dark / RTL × 4 brands. COVERAGE.md updated.

## 2.2.0

Widget parity, round 2 — the package now ships ~46 branded widgets (up from 16),
covering the full dashboard / transfer / corporate / wallet surfaces:

- Money inputs: NeptuneAmountInput, NeptuneCurrencyField, NeptuneIbanField,
  NeptuneOtpInput, NeptunePinInput, NeptuneAmountKeypad.
- Money movement: NeptuneStepper, NeptuneTransferReview, NeptuneMethodRow,
  NeptuneBeneficiaryTile, NeptuneSuccess, NeptuneReceipt.
- Data-viz (CustomPainter): NeptuneSparkline, NeptuneDonut, NeptuneLimitMeter,
  NeptuneTrend.
- Corporate: NeptuneApprovalItem, NeptuneBatchCard, NeptuneAuditRow,
  NeptuneUserRow, NeptunePermissionToggle, NeptuneWorkflowStatus.
- Wallet/pay: NeptuneMerchantRow, NeptuneVoucherCard, NeptuneQrPay,
  NeptuneTopupRow, NeptuneTierBadge.
- Feedback/shell: NeptuneAlert, NeptuneBanner, NeptuneEmptyState,
  NeptuneSkeleton, NeptunePageHeader, NeptuneSearchField.

All theme-only (no literals), RTL-safe, ≥48dp; 36 widget tests pass under
light/dark/RTL × 4 brands; flutter analyze clean. COVERAGE.md updated.

## 2.1.0

Widget parity pass — the package now ships **16 branded widgets** (up from 4),
matching the web components shown in the docs templates. New:

- `NeptuneButton` (filled / tonal / outlined / text) + `NeptuneCta` (animated
  pill CTA), `NeptuneStatCard`, `NeptuneCardArt` (gradient card + `selected`
  ring), `NeptuneQuickActions` / `NeptuneQuickAction`, `NeptuneDock` /
  `NeptuneDockItem` (floating nav, raised active indicator), `NeptuneAppBar`,
  `NeptuneOnboarding`, `NeptuneSection`, `NeptuneChip`, `NeptuneStatusChip`.
- A real **example app** (`example/`) — a themed dashboard + onboarding screen
  built only from the widget set.
- Honest **COVERAGE.md** mapping every web component → implemented / Material
  fallback / TODO (nothing silently dropped).
- All widgets theme-only (no literals), RTL-safe, ≥48dp targets;
  `test/widgets_test.dart` builds them under light/dark/RTL × 4 brands.
  `flutter analyze` clean.

## 2.0.0

Aligns the Flutter package with the Neptune Odyssey 2.x line (vendor-neutral, white-label).

- Reference brands are the four neutral demo skins — `neptune` / `triton` / `nereid` /
  `proteus` (no real-institution identity).
- Brandprint strings remain byte-identical to the JS/TS reference and stable across
  versions: a saved `NO1-…` resolves to the same theme on Flutter, Web, React, Vue,
  Svelte and React Native (golden-tested).
- `NeptuneTheme.light` / `.dark` / `.fromBrandprint` / `.fromConfig`; `ThemeExtension`s
  `NptColors` / `NptShape` / `NptType` / `NptMotion`; theme-only widgets (balance card,
  transaction row, account tile, primary button). RTL-safe, ≥48dp targets, no literals.
- 31 golden tests; `flutter analyze` clean.

## 1.0.0

First stable release of the Neptune Odyssey Flutter package by Neptune.Fintech.

- Const M3 `ColorScheme`s for the four reference brands × light/dark, byte-identical
  to the cross-platform pinned palettes (`build/tokens.resolved.json`).
- `ThemeExtension`s: `NptColors` (incl. success roles), `NptShape`, `NptType`, `NptMotion`.
- `NeptuneTheme.light` / `.dark` / `.fromBrandprint` / `.fromConfig` → full
  `ThemeData(useMaterial3: true)`; money uses `FontFeature.tabularFigures()`.
- Brandprint codec (byte-identical to the JS reference, idempotent, checksum-validated)
  and the shared OKLCH→sRGB converter for custom seeds.
- Theme-only widgets (balance card, transaction row, account tile, primary button);
  `EdgeInsetsDirectional` + ≥48dp targets; no literal colours/radii/fonts.
- 31 golden tests; `flutter analyze` clean.
