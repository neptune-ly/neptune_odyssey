# {{PROJECT_TITLE}}

A [Neptune Odyssey](https://neptune-ly.github.io/neptune_odyssey/) starter — **Flutter** (Material 3), themed with the **{{BRAND}}** brand.

## Run

```bash
flutter pub get
flutter create . --platforms=android,ios,web   # adds platform runners (keeps lib/)
flutter run
```

> `flutter create .` regenerates the native runner folders for an existing project
> without touching your `lib/` or `pubspec.yaml`. Skip it if you already have them.

## How it's wired

`lib/main.dart`:

```dart
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

MaterialApp(
  theme: NeptuneTheme.light('{{BRAND}}'),
  darkTheme: NeptuneTheme.dark('{{BRAND}}'),
  themeMode: ThemeMode.{{MODE}},
  home: const DashboardScreen(),
);
```

- **Theme** — `NeptuneTheme.light/dark(brand)` returns a Material `ThemeData`. Swap the
  brand for `neptune` / `triton` / `nereid` / `proteus`, or use
  `NeptuneTheme.fromBrandprint('NO1-…')` with a string from the
  [theme builder](https://neptune-ly.github.io/neptune_odyssey/apps/configurator/).
- **Widgets** — `lib/dashboard.dart` uses `NeptuneBalanceCard`, `NeptuneTransactionRow`
  and `NeptunePrimaryButton`, plus Material widgets that read the themed `ColorScheme`.
- **Parity** — the same brandprint renders byte-identically here and on web / React Native
  (enforced by golden tests).

## Dependency note

`neptune_flutter_ui` is pulled from git until it lands on pub.dev; then you can switch
`pubspec.yaml` to a hosted version constraint.

© {{YEAR}} — built on Neptune Odyssey by Neptune.Fintech.
