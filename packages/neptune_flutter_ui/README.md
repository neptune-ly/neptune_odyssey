# neptune_flutter_ui

The Flutter package of **Neptune Odyssey** — the vendor-neutral, white-label
banking design system by [Neptune.Fintech](https://neptune.ly). It ships the four
reference brands (`neptune`, `triton`, `nereid`, `proteus`) plus a deterministic
**brandprint** codec so any custom tenant theme rebuilds identically across
platforms.

> Neptune Odyssey by Neptune.Fintech. Source-available under the Neptune Odyssey
> Community License v1.0 (see [`LICENSE`](LICENSE)). Free for non-commercial use
> and for organizations under USD $25,000/year; a commercial license is required
> above that threshold.

## Install

```yaml
# pubspec.yaml
dependencies:
  neptune_flutter_ui: ^1.0.0
```

Or from git:

```yaml
dependencies:
  neptune_flutter_ui:
    git:
      url: https://github.com/neptune-ly/neptune_odyssey
      path: packages/neptune_flutter_ui
```

## Theming — three entry points

A bank is a pair of `ThemeData` (light + dark). Swapping banks swaps the theme;
widgets never change. Read everything from `Theme.of(context)` — no literal
colours, radii or fonts in your widgets.

```dart
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

// 1. By reference brand id.
MaterialApp(
  theme: NeptuneTheme.light('triton'),
  darkTheme: NeptuneTheme.dark('triton'),
  themeMode: ThemeMode.system,
);

// 2. From a brandprint string (the portable, copy-pasteable theme).
final theme = NeptuneTheme.fromBrandprint('NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA');

// 3. From a full config (seeds, corners, type, levers, flags).
final theme2 = NeptuneTheme.fromConfig(myConfig, brightness: Brightness.dark);
```

## Brandprint

A brandprint is a short, deterministic `NO1-…` string that encodes a tenant's
theme inputs (OKLCH seeds, corner family, type, lever enums, flags). Encode and
decode are pure and idempotent.

```dart
final config = Brandprint.decode('NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA');
final round  = Brandprint.encode(config); // == the original string

// Build a custom config and get its brandprint.
const cfg = BrandprintConfig(
  primary: Seed(l: 0.50, c: 0.12, h: 162),
  tertiary: Seed(l: 0.62, c: 0.12, h: 86),
  corners: Corners(xs: 12, sm: 18, md: 26, lg: 34, xl: 44, xxl: 56),
  displayWeight: 700,
  displayTracking: -0.01,
  fontDisplay: 'Bricolage Grotesque',
  fontText: 'Hanken Grotesk',
  fontNum: 'Hanken Grotesk',
  loginShell: 'arcade-arches',
  dashboardHero: 'warm-balance-cards',
  contentTone: 'warm-hospitable',
  glassTint: 'warm-amber',
  motion: 'calm-graceful',
);
final brandprint = Brandprint.encode(cfg);
final theme = NeptuneTheme.fromConfig(cfg);
```

## Widgets

Themed, RTL-safe building blocks that read the theme only:

- `NeptuneBalanceCard`
- `NeptuneTransactionRow`
- `NeptuneAccountTile`
- `NeptunePrimaryButton`

The brand `success` role, corner family, type set and motion are available as
`ThemeExtension`s: `NptColors`, `NptShape`, `NptType`, `NptMotion`.

```dart
final success = Theme.of(context).extension<NptColors>()!.success;
final radius  = Theme.of(context).extension<NptShape>()!.rLg;
final money   = NeptuneTheme.moneyStyle(context); // tabular figures
```

## Determinism

The same brandprint produces an identical theme on every platform. The four
reference brands resolve via pinned canonical palettes (byte-identical to
`tokens.resolved.json`); custom seeds resolve through the shared OKLCH ramp
(CSS Color 4 path), reproducing the reference data to within ≤ 1 LSB per channel.
Any change to the palette algorithm, wire layout, or a registry bumps the
brandprint version prefix (`NO2-`).

## License

Neptune Odyssey Community License v1.0. See [`LICENSE`](LICENSE). For commercial
licensing above the revenue threshold: licensing@neptune.fintech.
