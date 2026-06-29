# Neptune Odyssey — Desktop

The white-label **desktop banking app**, one Flutter codebase targeting **macOS
(Apple Silicon)** and **Windows**. Every pixel is themed from
[`neptune_flutter_ui`](../../packages/neptune_flutter_ui) brandprints — switch the
brand at runtime and the entire app reskins, byte-identically to the web and
mobile surfaces.

## What's inside

A real, navigable multi-screen app (not a demo gallery):

| Screen | Highlights |
|---|---|
| **Overview** | Total balance, money in/out, quick actions, recent-activity table, spend donut + limit meter + sparkline, accounts |
| **Accounts** | Master-detail: account list ↔ balance, IBAN, recent activity, statement/transfer actions |
| **Cards** | Card art, freeze/limits/PIN controls, spend limit meter, add-card |
| **Transfer** | 3-step wizard (amount → review → done) with stepper, beneficiaries, review, success + receipt |
| **Pay** | QR pay, top-ups, recent merchants, vouchers, tier badges |
| **Activity** | Filterable transaction table (all / income / spending) + summary |
| **Payees** | Saved beneficiaries master-detail |
| **Corporate** | Approvals, batches, workflow status, team permissions, audit trail |
| **Settings** | **Live brand switch** (neptune / triton / nereid / proteus), dark mode, RTL + Arabic faces, typography preview |

The top bar carries the white-label controls (cycle brand, light/dark,
LTR/RTL) so you can see the brandprint engine working live.

## Architecture

```
lib/
  main.dart                  app entry
  app/                       AppState (ChangeNotifier) + AppScope (InheritedNotifier),
                             NeptuneApp (MaterialApp ← brandprint), nav model
  data/                      models, seeded mock data, money formatter (no intl dep)
  shell/                     desktop_shell (side nav + content), top_bar
  widgets/                   ContentScaffold + Block (shared page frame)
  screens/                   one file per destination
```

- **State:** a single `AppState` `ChangeNotifier` exposed through an
  `InheritedNotifier` (`AppScope.of(context)`). No external state package.
- **Theming:** `NeptuneTheme.light/dark(brand, arabic: rtl)` from the design
  system — the only source of colour, shape, motion and typography. Screens never
  hard-code colours, radii or font names.
- **Data:** in-memory repositories seeded from `data/mock_data.dart`. Swap for a
  real API/backend behind the same `AppState` surface.

## Run it

Requires Flutter ≥ 3.22 (developed on 3.35.4).

```bash
cd apps/neptune_desktop
flutter pub get

# macOS (Apple Silicon)
flutter run -d macos

# Windows
flutter run -d windows
```

## Build release artifacts

```bash
# macOS → build/macos/Build/Products/Release/neptune_desktop.app
flutter build macos --release

# Windows → build/windows/x64/runner/Release/
flutter build windows --release
```

CI builds both on every push (`.github/workflows/desktop.yml`) and uploads the
`.app` (macOS arm64) and `.zip` (Windows x64) as artifacts. Cross-compiling is
not supported — each platform builds on its own runner.

## Signing & distribution (production)

The artifacts above are **unsigned**. To ship:

- **macOS:** sign with a Developer ID Application certificate and notarize:
  set the signing identity in Xcode (`macos/Runner.xcworkspace`), then
  `flutter build macos --release` and `xcrun notarytool submit`. Distribute the
  notarized `.app` (or a `.dmg`).
- **Windows:** sign the `.exe` with `signtool` using an EV/OV code-signing
  certificate. For Store distribution, package as MSIX (e.g. the `msix` package)
  and submit to the Microsoft Store.

These steps need certificates that live outside the repo (Apple Developer ID /
Windows code-signing cert), so they're intentionally not wired into CI here.

© 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
