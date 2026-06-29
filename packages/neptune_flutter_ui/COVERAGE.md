# Flutter coverage vs the web component set

Neptune Odyssey ships **89 web components**. The Flutter package gives you two things:

1. **Theme parity — guaranteed.** `NeptuneTheme.light/dark(brand)` (or `.fromBrandprint`) returns a full Material 3 `ThemeData`, so **every Material widget** (`FilledButton`, `TextField`, `Card`, `Chip`, `Dialog`, `NavigationBar`, `Switch`, …) is already on-brand — same colours, corners, type and motion as the web, resolved byte-identically from the same brandprint (golden-tested). You are never blocked: anything not wrapped below still themes correctly with a stock Material widget.
2. **Branded widgets** that match specific web components 1:1.

Honest status — nothing is silently dropped:

## ✅ Implemented widgets (match the web component)
| Flutter widget | Web component |
|---|---|
| `NeptuneBalanceCard` | `npt-balance-card` |
| `NeptuneStatCard` | `npt-stat-card` |
| `NeptuneTransactionRow` | `npt-transaction-row` |
| `NeptuneAccountTile` | `npt-card-row` / account list item |
| `NeptuneCardArt` (+ `selected`) | `npt-card-art` |
| `NeptuneQuickActions` / `NeptuneQuickAction` | `npt-quick-actions` / `npt-quick-action` |
| `NeptuneDock` / `NeptuneDockItem` | `npt-dock` / `npt-dock-item` (floating nav, raised active) |
| `NeptuneAppBar` | `npt-app-bar` |
| `NeptuneOnboarding` | `npt-onboarding` |
| `NeptuneSection` | `npt-section` |
| `NeptuneButton` (filled/tonal/outlined/text) + `NeptunePrimaryButton` | `npt-button` |
| `NeptuneCta` | `npt-cta` |
| `NeptuneChip` | `npt-chip` |
| `NeptuneStatusChip` | `npt-status-chip` |

See `example/lib/main.dart` for a real dashboard + onboarding screen built from these. All are theme-only (no literals), RTL-safe (`EdgeInsetsDirectional`), ≥48dp targets; covered by `test/widgets_test.dart` (build under light/dark/RTL × 4 brands).

## ≈ Use a Material widget (themed, exact-enough)
These web components map cleanly onto a stock Material widget that the theme already styles — no wrapper needed yet:
`npt-text-field`→`TextField`, `npt-checkbox/radio/switch/slider`→Material equivalents, `npt-dialog`→`showDialog`/`AlertDialog`, `npt-bottom-sheet`→`showModalBottomSheet`, `npt-menu`→`MenuAnchor`, `npt-tabs`→`TabBar`, `npt-divider`→`Divider`, `npt-avatar`→`CircleAvatar`, `npt-nav-bar`→`NavigationBar`, `npt-progress`→`Progress*Indicator`, `npt-icon-button/fab`→`IconButton`/`FloatingActionButton`, `npt-card`→`Card`.

## ⬜ TODO — branded wrappers not built yet (fall back to Material/custom for now)
Money inputs (`npt-amount-keypad`, `npt-currency-field`, `npt-iban-field`, `npt-otp-input`, `npt-pin-input`), money-movement (`npt-stepper`, `npt-transfer-review`, `npt-success`, `npt-receipt`, `npt-beneficiary-tile`, `npt-method-row`), data-viz (`npt-data-table`, `npt-sparkline`, `npt-donut`, `npt-limit-meter`, `npt-trend`), corporate (`npt-approval-item`, `npt-batch-card`, `npt-audit-row`, `npt-user-row`, `npt-permission-toggle`, `npt-workflow-status`), wallet-pay (`npt-merchant-row`, `npt-voucher-card`, `npt-qr-pay`, `npt-topup-row`, `npt-tier-badge`), shell-layout (`npt-app-shell`, `npt-page-header`, `npt-side-nav`, `npt-toolbar`), `npt-nav-rail`, `npt-card-controls`, `npt-add-card`, feedback (`npt-skeleton`, `npt-empty-state`, `npt-alert`, `npt-toast`, `npt-banner`, `npt-snackbar`, `npt-tooltip`).

These are tracked here, not pretended-complete. They'll be added as branded widgets over subsequent releases; until then they theme correctly via Material.

© 2026 Neptune.Fintech (neptune.ly).
