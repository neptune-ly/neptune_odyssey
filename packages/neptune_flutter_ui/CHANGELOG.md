# Changelog

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
