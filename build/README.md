# build/ — generated token output

These files are **generated** from `tokens/themes.css` + `tokens/tokens.json` by the
OKLCH→sRGB build step. Do not edit by hand — change the tokens and re-run.

| File | What |
|------|------|
| `tokens.resolved.json` | Every `--md-sys-color-*` resolved to hex + ARGB, per brand × light/dark. The codegen source. |
| `neptune_color_schemes.dart` | One M3 `ColorScheme` per brand × mode + a `neptuneSchemes` map. Drop into `neptune_tokens`. |
| `neptune_theme_extensions.dart` | `NeptuneColors` (the `success` role M3 lacks), `NeptuneShapes` (corner family), `NeptuneType` (font set), per brand. |

## How it was produced
OKLCH values are resolved through the browser's colour engine (real sRGB gamut mapping),
matching what the web reference renders. In the production Flutter build, reproduce this with
a Dart/Node step using a colour library (e.g. `culori`) so CI has no browser dependency —
values must match `tokens.resolved.json`.

Brands: neptune, andalus, nuran, fglb · 4 × light+dark.
