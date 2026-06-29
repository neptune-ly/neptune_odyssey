# Flutter coverage vs the web component set

Neptune Odyssey ships **89 web components**. The Flutter package gives you:

1. **Theme parity — guaranteed.** `NeptuneTheme.light/dark(brand)` (or `.fromBrandprint`) returns a full Material 3 `ThemeData`, so **every Material widget** is already on-brand — resolved byte-identically from the same brandprint (golden-tested). You're never blocked.
2. **~46 branded widgets** matching specific web components, all theme-only (no literals), RTL-safe (`EdgeInsetsDirectional`), ≥48dp targets, covered by `test/widgets_test.dart` (build under light/dark/RTL × 4 brands; 36 tests).

Honest status — nothing silently dropped.

## ✅ Implemented branded widgets
| Group | Flutter widgets | Web |
|---|---|---|
| Cards / finance | `NeptuneBalanceCard`, `NeptuneStatCard`, `NeptuneTransactionRow`, `NeptuneAccountTile`, `NeptuneCardArt` (+`selected`) | `npt-balance-card`, `npt-stat-card`, `npt-transaction-row`, `npt-card-row`, `npt-card-art` |
| Actions | `NeptuneButton` (filled/tonal/outlined/text), `NeptunePrimaryButton`, `NeptuneCta`, `NeptuneQuickActions`/`NeptuneQuickAction` | `npt-button`, `npt-cta`, `npt-quick-actions` |
| Navigation / shell | `NeptuneDock`/`NeptuneDockItem`, `NeptuneAppBar`, `NeptunePageHeader`, `NeptuneSection`, `NeptuneSearchField` | `npt-dock`, `npt-app-bar`, `npt-page-header`, `npt-section`, `npt-search-field` |
| Onboarding | `NeptuneOnboarding` | `npt-onboarding` |
| Money inputs | `NeptuneAmountInput`, `NeptuneCurrencyField`, `NeptuneIbanField`, `NeptuneOtpInput`, `NeptunePinInput`, `NeptuneAmountKeypad` | `npt-amount-input`, `npt-currency-field`, `npt-iban-field`, `npt-otp-input`, `npt-pin-input`, `npt-amount-keypad` |
| Money movement | `NeptuneStepper`, `NeptuneTransferReview`, `NeptuneMethodRow`, `NeptuneBeneficiaryTile`, `NeptuneSuccess`, `NeptuneReceipt` | `npt-stepper`, `npt-transfer-review`, `npt-method-row`, `npt-beneficiary-tile`, `npt-success`, `npt-receipt` |
| Data-viz | `NeptuneSparkline`, `NeptuneDonut`, `NeptuneLimitMeter`, `NeptuneTrend` | `npt-sparkline`, `npt-donut`, `npt-limit-meter`, `npt-trend` |
| Corporate | `NeptuneApprovalItem`, `NeptuneBatchCard`, `NeptuneAuditRow`, `NeptuneUserRow`, `NeptunePermissionToggle`, `NeptuneWorkflowStatus` | `npt-approval-item`, `npt-batch-card`, `npt-audit-row`, `npt-user-row`, `npt-permission-toggle`, `npt-workflow-status` |
| Wallet / pay | `NeptuneMerchantRow`, `NeptuneVoucherCard`, `NeptuneQrPay`, `NeptuneTopupRow`, `NeptuneTierBadge` | `npt-merchant-row`, `npt-voucher-card`, `npt-qr-pay`, `npt-topup-row`, `npt-tier-badge` |
| Feedback | `NeptuneChip`, `NeptuneStatusChip`, `NeptuneAlert`, `NeptuneBanner`, `NeptuneEmptyState`, `NeptuneSkeleton` | `npt-chip`, `npt-status-chip`, `npt-alert`, `npt-banner`, `npt-empty-state`, `npt-skeleton` |

See `example/lib/main.dart` for a real dashboard + onboarding built from these.

## ≈ Use a themed Material widget (no wrapper needed)
`npt-text-field`→`TextField`, `npt-checkbox/radio/switch/slider`→Material, `npt-dialog`→`showDialog`, `npt-bottom-sheet`→`showModalBottomSheet`, `npt-menu`→`MenuAnchor`, `npt-tabs`→`TabBar`, `npt-divider`→`Divider`, `npt-avatar`→`CircleAvatar`, `npt-nav-bar`→`NavigationBar`, `npt-progress`→`Progress*Indicator`, `npt-icon-button/fab`→`IconButton`/`FloatingActionButton`, `npt-card`→`Card`, `npt-snackbar`→`SnackBar`, `npt-tooltip`→`Tooltip`, `npt-segmented-button`→`SegmentedButton`.

## ⬜ Remaining TODO (structural / niche)
`npt-data-table` (use Material `DataTable`, themed, for now), `npt-app-shell` / `npt-side-nav` / `npt-toolbar` / `npt-nav-rail` (web responsive shell — build a Flutter equivalent with `NavigationRail`/`Drawer`), `npt-card-controls`, `npt-add-card`, `npt-toast`/`npt-toast-host`, `npt-merchant`/QR live scanning. Tracked here, added over subsequent releases — and themed via Material in the meantime.

© 2026 Neptune.Fintech (neptune.ly).
