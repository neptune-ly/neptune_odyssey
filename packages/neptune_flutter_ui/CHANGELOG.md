# Changelog

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
