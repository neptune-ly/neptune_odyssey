# Changelog

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
