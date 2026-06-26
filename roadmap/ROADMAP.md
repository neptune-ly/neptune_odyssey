# Neptune Odyssey — Roadmap targets

These targets are **scaffolded but not part of v1.0.0**. They do not block the stable
release. Every one builds on the same `@neptune-odyssey/tokens` outputs (the pinned
palettes + the brandprint codec), so they inherit the palette and the determinism
contract for free — *same brandprint ⇒ same theme* extends to them with no new color math.

| Target | Package | Strategy |
|--------|---------|----------|
| **React** | `@neptune-odyssey/react-ui` | Thin wrappers over the `@neptune-odyssey/web-ui` custom elements + a `<NeptuneProvider>` calling `applyTheme`. Mirrors the Vue layer. |
| **React Native** | `@neptune-odyssey/react-native-ui` | Native components reading a JS theme object from `buildTheme()`; reuses `tokens` resolved palettes + brandprint codec. No web custom elements. |
| **Kotlin Multiplatform** | `neptune-odyssey-kmp` | Compose Multiplatform + web. Port the OKLCH→sRGB + brandprint codec to Kotlin (golden-tested against `build/tokens.resolved.json` and the JS reference, exactly as the Dart port was). |

## The bar for promoting a target to stable

1. Themes three ways — brand id, config object, **and** brandprint — with one surface.
2. Golden tests: for any platform that re-implements color math or the codec, it must
   reproduce `build/tokens.resolved.json` (≤1 LSB) and the 4 reference brandprints (exact).
3. Light + dark, LTR + RTL on every reference screen; no literal color/radius/font in
   components; WCAG AA; visible focus; reduced-motion; 48dp targets.
4. Publish-ready package metadata + LICENSE + README with the three theming entry points.

Until a target meets that bar it stays here, clearly labelled **roadmap**, never shipped
as if stable.
