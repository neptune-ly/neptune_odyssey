# Flutter coverage vs the web component set

Neptune Odyssey ships **89 web components**. The Flutter package gives you:

1. **Theme parity — guaranteed.** `NeptuneTheme.light/dark(brand)` (or `.fromBrandprint`) returns a full Material 3 `ThemeData`, so **every Material widget** is already on-brand — resolved byte-identically from the same brandprint (golden-tested). You're never blocked.
2. **Real brand typography.** The theme loads each brand's display / text / num faces via `google_fonts` and applies them across the whole `TextTheme`; `NeptuneTheme.moneyStyle` renders amounts in the brand `num` face with tabular figures. Pass `arabic: true` (or run under RTL) and the Arabic faces (IBM Plex Sans Arabic, Reem Kufi, Tajawal, Readex Pro, Noto Kufi Arabic) take over, mirroring the web `--npt-font-*-ar` tokens; `moneyStyle` swaps to the Arabic numeral face under RTL.
3. **~88 branded widgets** — past Material parity into a complete fintech design system. All theme-only (no literals), RTL-safe (`EdgeInsetsDirectional`), ≥48dp targets, covered by `test/widgets_test.dart` (build under light/dark/RTL × 4 brands; 40 tests).
4. **The Odyssey identity layer (2.5.0).** `NptIdentity` carries the web's above-M3 levers: per-brand **glass** (tint ratios + blur → `NeptuneGlass`), the **signature motif** (`NeptuneMotifLayer`: sonar tide-rings / coastal arcs / grid-spark / shield guilloché), **elevation + glow tokens**, and the login-shell/dashboard-hero/content-tone names. The dock is real glass with the raised-active indicator, card art and hero balance cards carry the motif over the brand gradient, and `NeptuneEyebrow` gives the tracked-uppercase micro-label. This is what makes the Flutter widgets read as *Odyssey*, not generic Material — same recipes as `themes.css`, resolved per brandprint (custom seeds included).

Honest status — nothing silently dropped.

## ✅ Implemented branded widgets
| Group | Flutter widgets | Web |
|---|---|---|
| Cards / finance | `NeptuneBalanceCard`, `NeptuneStatCard`, `NeptuneTransactionRow`, `NeptuneAccountTile`, `NeptuneCardArt` (+`selected`) | `npt-balance-card`, `npt-stat-card`, `npt-transaction-row`, `npt-card-row`, `npt-card-art` |
| Actions | `NeptuneButton` (filled/tonal/outlined/text), `NeptunePrimaryButton`, `NeptuneCta`, `NeptuneQuickActions`/`NeptuneQuickAction` | `npt-button`, `npt-cta`, `npt-quick-actions` |
| Navigation / shell | `NeptuneDock`/`NeptuneDockItem`, `NeptuneAppBar`, `NeptunePageHeader`, `NeptuneSection`, `NeptuneSearchField`, `NeptuneAppShell`, `NeptuneSideNav`/`NeptuneSideNavItem`, `NeptuneToolbar`, `NeptuneNavRail`/`NeptuneNavRailItem` | `npt-dock`, `npt-app-bar`, `npt-page-header`, `npt-section`, `npt-search-field`, `npt-app-shell`, `npt-side-nav`, `npt-side-nav-item`, `npt-toolbar`, `npt-nav-rail` |
| Card management | `NeptuneCardControls`, `NeptuneAddCard` | `npt-card-controls`, `npt-add-card` |
| Data | `NeptuneDataTable`/`NeptuneColumn` | `npt-data-table` |
| Onboarding | `NeptuneOnboarding` | `npt-onboarding` |
| Money inputs | `NeptuneAmountInput`, `NeptuneCurrencyField`, `NeptuneIbanField`, `NeptuneOtpInput`, `NeptunePinInput`, `NeptuneAmountKeypad` | `npt-amount-input`, `npt-currency-field`, `npt-iban-field`, `npt-otp-input`, `npt-pin-input`, `npt-amount-keypad` |
| Money movement | `NeptuneStepper`, `NeptuneTransferReview`, `NeptuneMethodRow`, `NeptuneBeneficiaryTile`, `NeptuneSuccess`, `NeptuneReceipt` | `npt-stepper`, `npt-transfer-review`, `npt-method-row`, `npt-beneficiary-tile`, `npt-success`, `npt-receipt` |
| Data-viz | `NeptuneSparkline`, `NeptuneDonut`, `NeptuneLimitMeter`, `NeptuneTrend` | `npt-sparkline`, `npt-donut`, `npt-limit-meter`, `npt-trend` |
| Corporate | `NeptuneApprovalItem`, `NeptuneBatchCard`, `NeptuneAuditRow`, `NeptuneUserRow`, `NeptunePermissionToggle`, `NeptuneWorkflowStatus` | `npt-approval-item`, `npt-batch-card`, `npt-audit-row`, `npt-user-row`, `npt-permission-toggle`, `npt-workflow-status` |
| Wallet / pay | `NeptuneMerchantRow`, `NeptuneVoucherCard`, `NeptuneQrPay`, `NeptuneTopupRow`, `NeptuneTierBadge` | `npt-merchant-row`, `npt-voucher-card`, `npt-qr-pay`, `npt-topup-row`, `npt-tier-badge` |
| Feedback | `NeptuneChip`, `NeptuneStatusChip`, `NeptuneAlert`, `NeptuneBanner`, `NeptuneEmptyState`, `NeptuneSkeleton`, `NeptuneToast` + `showNeptuneToast` | `npt-chip`, `npt-status-chip`, `npt-alert`, `npt-banner`, `npt-empty-state`, `npt-skeleton`, `npt-snackbar`/`npt-toast` |
| Form fields | `NeptuneTextField`, `NeptuneSelect`/`NeptuneSelectOption`, `NeptuneStepperInput`, `NeptuneDateField` | `npt-text-field`, `npt-select`, `npt-stepper`, `npt-date-field` |
| Selection controls | `NeptuneCheckbox`/`NeptuneCheckboxTile`, `NeptuneRadioGroup`/`NeptuneRadioOption`, `NeptuneSwitch`, `NeptuneSegmented`/`NeptuneSegment`, `NeptuneSlider` | `npt-checkbox`, `npt-radio`, `npt-switch`, `npt-segmented-button`, `npt-slider` |
| Overlays | `showNeptuneDialog`/`NeptuneDialogAction`, `showNeptuneSheet`, `NeptuneMenu`/`NeptuneMenuItem`, `NeptuneTooltip` | `npt-dialog`, `npt-bottom-sheet`, `npt-menu`, `npt-tooltip` |
| Navigation / structure | `NeptuneTabs`, `NeptuneBreadcrumbs`/`NeptuneCrumb`, `NeptunePagination`, `NeptuneAccordion`/`NeptuneAccordionPanel` | `npt-tabs`, `npt-breadcrumbs`, `npt-pagination`, `npt-accordion` |
| Display | `NeptuneAvatar`/`NeptuneAvatarGroup`, `NeptuneBadge`, `NeptuneTag`, `NeptuneProgressBar`, `NeptuneProgressRing`, `NeptuneRating`, `NeptuneListTile`, `NeptuneTimeline`/`NeptuneTimelineEntry` | `npt-avatar`, `npt-badge`, `npt-tag`, `npt-progress`, `npt-rating`, `npt-list`, `npt-timeline` |
| Fintech (premium) | `NeptuneInsightCard`, `NeptuneFxCard`, `NeptuneBudgetRing`, `NeptuneSpendBreakdown`/`NeptuneSpendSlice`, `NeptuneCreditScoreGauge` | beyond the web set — Flutter-first |

See `example/lib/main.dart` for a live components gallery (every widget, with brand / dark / RTL toggles) plus the onboarding hero.

## ≈ Use a themed Material widget (no wrapper needed)
A few primitives are still best served straight from themed Material: `npt-divider`→`Divider`, `npt-nav-bar`→`NavigationBar` (or `NeptuneDock`), `npt-icon-button/fab`→`IconButton`/`FloatingActionButton`, `npt-card`→`Card`, `npt-snackbar`→`SnackBar` (or `showNeptuneToast`). Everything else now has a branded wrapper.

## ⬜ Remaining TODO (niche)
Live hardware-backed flows only: `npt-merchant`/QR **live camera scanning** (the static `NeptuneQrPay` presentation widget ships; live capture is app-level via a camera plugin). Everything structural is now implemented.

© 2026 Neptune.Fintech (neptune.ly).
