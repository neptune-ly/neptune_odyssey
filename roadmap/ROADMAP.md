# Neptune Odyssey — Roadmap targets

These targets are **scaffolded but not part of v1.0.0**. They do not block the stable
release. Every one builds on the same `@neptune.fintech/tokens` outputs (the pinned
palettes + the brandprint codec), so they inherit the palette and the determinism
contract for free — *same brandprint ⇒ same theme* extends to them with no new color math.

No targets are currently in flight — everything scaffolded here has been promoted.

> **Promoted to shipped packages**:
> - **React** (`@neptune.fintech/react-ui`, npm ✓) — provider + `useNeptuneTheme` hook + typed wrappers over `@neptune.fintech/web-ui`.
> - **React Native** (`@neptune.fintech/react-native-ui`, npm ✓) — provider + hook + themed native components reading the resolved theme from `@neptune.fintech/tokens` `buildTheme()` (no web custom elements). Both add no color math, inheriting the determinism contract from `tokens`.
> - **Kotlin Multiplatform** (`neptune-odyssey-kmp` → [`packages/neptune_kmp_ui`](../packages/neptune_kmp_ui), promoted 2026-07 at 0.4.0; not yet on Maven Central) — Compose Multiplatform for Android/iOS/desktop/web(js+wasm). Met the full bar: three theming entry points in one composable; goldens reproducing `tokens.resolved.json` + the 4 reference brandprints on jvm/android/iOS-native/js/wasm; 78 components + 7 templates + onboarding flow + demo shell + 94-icon set, swept 480 frames × light/dark × LTR/RTL with the no-literals gate; publish-ready metadata. First Central release needs only the `ly.neptune` portal namespace + signing secrets (`release-kmp.yml` is prepped and dormant).

## The bar for promoting a target to stable

1. Themes three ways — brand id, config object, **and** brandprint — with one surface.
2. Golden tests: for any platform that re-implements color math or the codec, it must
   reproduce `build/tokens.resolved.json` (≤1 LSB) and the 4 reference brandprints (exact).
3. Light + dark, LTR + RTL on every reference screen; no literal color/radius/font in
   components; WCAG AA; visible focus; reduced-motion; 48dp targets.
4. Publish-ready package metadata + LICENSE + README with the three theming entry points.

Until a target meets that bar it stays here, clearly labelled **roadmap**, never shipped
as if stable.
