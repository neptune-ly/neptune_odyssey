# Coverage — neptune-odyssey-kmp vs the 89 web components

Honest ledger, per the rulebook. The web components
(`packages/neptune_web_ui/src/components/*.ts`) are the canonical recipe
source; the Flutter package is the porting reference. Everything below is
pixel-verified by `./gradlew :gallery:renderShots` (sections × 4 brands ×
light/dark × LTR/RTL) + `tools/blank_check.py` in CI.

## Theme engine (promotion-bar items 1–2) — ✓ complete

| Capability | Status |
|---|---|
| Brand id / brandprint / config entry points (one composable) | ✓ |
| Pinned reference palettes (generated, drift-gated) | ✓ goldens on jvm/android/iOS-native/js/wasm |
| Custom-seed palette ramp (v1, deterministic) | ✓ |
| Brandprint codec `NO1-` (append-only registries) | ✓ 4 reference brandprints exact |
| 8 token groups (colors/shape/type/motion/identity/density/numerals/feedback) | ✓ |
| Brand typography + Arabic type swap + bundled OFL faces (9 families) | ✓ |
| moneyStyle (tabular figures, RTL numeral face) / formatDigits | ✓ |
| Reduced-motion detection (Android/iOS/web; desktop opt-in) | ✓ |
| Seed extractor (logo → OKLCH seeds) | ✓ (sRGB-normalisation caveat documented) |

## Identity layer (rulebook §3) — ✓ complete

| Identity lever | Compose | Web / Flutter counterpart |
|---|---|---|
| 135° hero gradient (RTL-aware) | `nptHeroGradient` | hero/card gradients · BalanceCard/CardArt |
| Glass (backdrop blur + tint + hairline) | `NeptuneGlass` (+`NptGlassScope`) | `npt-card[glass]`/dock · `NeptuneGlass` |
| Signature motifs ×4 | `NeptuneMotifLayer`/`drawNptMotif` | `--npt-motif` · `NeptuneMotifLayer` |
| Elevation e1/e2/e3/e5 + dark=glow | `Modifier.nptShadow` + `NptIdentity` | `--npt-elev-*` · `NptIdentity` |
| Primary key-light glow | `glowPrimary` | `--npt-glow-primary` |
| Eyebrow | `NeptuneEyebrow` | `.eyebrow` · `NeptuneEyebrow` |
| Ambient welcome backdrop (orbs, 57s clock) | `NeptuneAmbientBackdrop` | welcome template · `NeptuneAmbientBackdrop` |

## Components — 78 shipped (foundation + parity waves 1–3)

| Compose | Web element | Flutter widget |
|---|---|---|
| NeptuneButton (4 variants) | npt-button | NeptuneButton |
| NeptuneCta (sheen/nudge/press) | npt-cta | NeptuneCta |
| NeptuneCard (4 variants + motif) | npt-card | NeptuneCard |
| NeptuneBalanceCard | npt-balance-card | NeptuneBalanceCard |
| NeptuneTransactionRow | npt-transaction-row | NeptuneTransactionRow |
| NeptuneAccountTile | — (Flutter-first) | NeptuneAccountTile |
| NeptuneCardArt (virtual flip) | npt-card-art | NeptuneCardArt |
| NeptuneTextField | npt-text-field | NeptuneTextField |
| NeptuneAmountInput | npt-amount-input | NeptuneAmountInput |
| NeptuneOtpInput | npt-otp-input | NeptuneOtpInput |
| NeptuneListTile | npt-list-item | NeptuneListTile |
| NeptuneBadge / NeptuneTag | npt-badge / npt-chip | NeptuneBadge / NeptuneTag |
| NeptuneChip / NeptuneStatusChip | npt-chip / npt-status-chip | NeptuneChip / NeptuneStatusChip |
| NeptuneDock (+DockItem, raised-active) | npt-dock | NeptuneDock |
| NeptuneAppBar (4 variants, one title) | npt-app-bar / npt-top-app-bar | NeptuneAppBar |
| NeptuneTabs | npt-tabs | NeptuneTabs |
| NeptuneSegmented | npt-segmented-button | NeptuneSegmented |
| NeptuneAlert (4 tones) / NeptuneBanner | npt-alert / npt-banner | NeptuneAlert / NeptuneBanner |
| NeptuneSkeleton (shimmer) | npt-skeleton | NeptuneSkeleton/NeptuneShimmer |
| Loaders ×4 (+neptuneLoaderFor) | — | NeptuneHourglassLoader/Spinner/Dots/Pulse |
| NeptuneStatusMotion | npt-success (motion) | NeptuneStatusMotion |
| NeptuneWelcome / NeptuneBrandLockup | welcome template | NeptuneWelcome/NeptuneBrandLockup |
| NeptuneCheckbox / NeptuneCheckboxTile | npt-checkbox | NeptuneCheckbox/Tile |
| NeptuneRadioGroup&lt;T&gt; / NeptuneSwitch / NeptuneSlider | npt-radio / npt-switch / npt-slider | same names |
| NeptuneSelect&lt;T&gt; / NeptuneStepperInput / NeptuneDateField | (inputs.ts) | NeptuneSelect/StepperInput/DateField |
| NeptunePinInput / NeptuneAmountKeypad | npt-pin-input / npt-amount-keypad | same names |
| NeptuneDialog / NeptuneSheet / NeptuneMenu / NeptuneTooltip | npt-dialog / npt-bottom-sheet / npt-menu / npt-tooltip | NeptuneOverlays widgets |
| NeptuneToastHost (+state) | npt-toast / npt-toast-host | NeptuneToast |
| NeptuneAvatar(+Group) / NeptuneProgressBar/Ring / NeptuneRating / NeptuneTimeline | npt-avatar / npt-progress | neptune_display widgets |
| NeptunePageHeader / NeptuneSearchField / NeptuneEmptyState | npt-page-header / npt-search-field / npt-empty-state | shell feedback widgets |
| NeptuneAppShell / NeptuneSideNav / NeptuneToolbar / NeptuneNavRail | npt-app-shell / npt-side-nav / npt-toolbar / npt-nav-rail | shell nav widgets |
| NeptuneStateSwitcher / NeptuneSkeletonCard/Row | npt-skeleton | neptune_states widgets |
| NeptuneQuickActions / NeptuneQuickAction | npt-quick-actions | NeptuneQuickActions |
| NeptuneDataTable / NeptuneColumn | npt-data-table | NeptuneDataTable |
| NeptuneSparkline / NeptuneDonut / NeptuneLimitMeter / NeptuneTrend | npt-sparkline/donut/limit-meter/trend | neptune_data_viz widgets |
| NeptuneStatCard (unit/delta/chart slot) | npt-stat-card | NeptuneStatCard |
| NeptuneBarChart / NeptuneCompareBars | — (Flutter-first) | neptune_charts widgets |
| NeptuneInsightCard / NeptuneFxCard / NeptuneBudgetRing / NeptuneSpendBreakdown / NeptuneCreditScoreGauge | — (premium) | neptune_fintech widgets |
| NeptuneStepper / NeptuneTransferReview / NeptuneMethodRow / NeptuneBeneficiaryTile | npt-stepper/transfer-review/method-row/beneficiary-tile | neptune_money_movement widgets |
| NeptuneSuccess / NeptuneReceipt | npt-success / npt-receipt | neptune_receipt widgets |
| NeptuneMerchantRow / NeptuneVoucherCard / NeptuneQrPay / NeptuneTopupRow / NeptuneTierBadge | npt-merchant-row/voucher-card/qr-pay/topup-row/tier-badge | neptune_wallet_pay widgets |
| NeptuneCardControls / NeptuneAddCard | npt-card-controls / npt-add-card | neptune_card_controls widgets |
| NeptuneApprovalItem / NeptuneBatchCard / NeptuneAuditRow / NeptuneUserRow / NeptunePermissionToggle / NeptuneWorkflowStatus | npt-approval-item etc. | neptune_corporate widgets |
| NeptuneBreadcrumbs / NeptunePagination / NeptuneAccordion | npt-tabs family (layout.ts) | neptune_navigation widgets |
| NeptuneOnboarding / NeptuneSection | npt-onboarding / npt-section | neptune_onboarding widgets |
| NeptuneSplashScreen | — | NeptuneSplashScreen |

The gallery iOS host app (`iosApp/`, GalleryKit framework) builds via
xcodebuild — the gallery now runs on all five surfaces.

## Templates & demo shell — ✓ complete (wave 3)

All 7 screen templates (`ly.neptune.odyssey.ui.templates`): auth, KYC,
dashboard, cards, transfer, wallet, corporate — plus the 10-step onboarding
flow and `NeptuneDemoShellApp` (Welcome → 5-tab glass-dock shell, EN/AR
string table, outcome motion, client `logo` slot). The 94-icon set ships as
generated `NptIcons` (drift-gated by `tools/gen-icons.mjs --check`).

## Remaining before the first Maven Central release

- Credentials only: the release path is fully prepped (`centralBundle` +
  `.github/workflows/release-kmp.yml`) — verify the `ly.neptune` namespace
  on central.sonatype.com, add the four repo secrets, then tag `kmp-v*`.
