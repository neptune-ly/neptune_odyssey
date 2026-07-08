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

## Components — 25 shipped (foundation set)

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

## Not yet ported (the parity gap — follow-up milestones)

Selection controls (checkbox/radio/switch/slider) · form fields
(select/stepper/date) · secure keypad · overlays (dialog/sheet/menu/tooltip/
toast) · display primitives (avatar/progress/rating/timeline) · data
(table/sparkline/donut/limit-meter/trend/charts) · fintech premium
(insight/fx/budget-ring/spend/credit-gauge) · money movement
(stepper/transfer-review/receipt/beneficiary/method) · wallet/pay ·
corporate · shell (app-shell/side-nav/toolbar/nav-rail/page-header/
search/empty-state/toast host) · quick actions · the 19 screen templates ·
the demo shell · the 94-icon set (3 glyphs + 6 status/finance glyphs exist).

Also pending before promotion: iOS host app for the gallery, wasm/js font
preloading guidance, Maven Central wiring (deliberately unwired — roadmap
rule).
