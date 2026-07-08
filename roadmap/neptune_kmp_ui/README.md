# neptune-odyssey-kmp — Compose Multiplatform target (ROADMAP)

The Kotlin Multiplatform / Compose Multiplatform implementation of the
[Neptune Odyssey](../../README.md) white-label banking design system.
**Roadmap status**: the foundation milestone is built in-repo (theme engine,
identity layer, core component set, gallery, CI gates); it stays here until it
meets the promotion bar in [`../ROADMAP.md`](../ROADMAP.md) and is **not yet
published** to Maven Central.

## Modules

| Module | Coordinates (publish-ready) | What |
|---|---|---|
| `:odyssey-tokens` | `ly.neptune.odyssey:odyssey-tokens` | Pure Kotlin determinism core: OKLCH↔sRGB math, seed→M3 palette ramp, brandprint codec (`NO1-…`), seed extractor, generated brand data. Zero dependencies. |
| `:odyssey-compose-ui` | `ly.neptune.odyssey:odyssey-compose-ui` | The Compose library: `NeptuneTheme`, the identity layer (glass/motifs/elevation-glow/gradients/eyebrow), core components, bundled OFL brand fonts. |
| `:gallery` / `:gallery-android` | not published | The reference gallery (all targets) + the `renderShots` pixel sweep. |

**Targets**: Android (minSdk 24) · JVM desktop · iOS (`iosArm64`,
`iosSimulatorArm64`) · Web (`wasmJs` **and** `js`, both Skia/canvas).
No `iosX64` — Compose Multiplatform 1.11 dropped Intel-simulator artifacts.

## Theme three ways (one composable)

```kotlin
// 1 · reference brand id
NeptuneTheme(brand = "triton", dark = true) { App() }

// 2 · portable brandprint (same string the web/Flutter accept)
NeptuneTheme(brand = "NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA") { App() }

// 3 · config object (custom white-label seeds — deterministic palette)
NeptuneTheme(
    config = BrandprintConfig(
        primary = Seed(l = 0.45, c = 0.14, h = 210),
        tertiary = Seed(l = 0.60, c = 0.11, h = 40),
        corners = Corners(xs = 8, sm = 12, md = 16, lg = 24, xl = 32, xxl = 44),
        displayWeight = 700, displayTracking = -0.02,
        fontDisplay = "Sora", fontText = "Hanken Grotesk", fontNum = "Sora",
        loginShell = "depth-emblem", dashboardHero = "balance-cards",
        contentTone = "clear-calm", glassTint = "oceanic", motion = "smooth-fluid",
    ),
) { App() }
```

Inside the theme, read tokens via the accessor object — never hard-code a
value (the CI grep will catch you):

```kotlin
NeptuneTheme.shape.rLg            // brand corner family
NeptuneTheme.colors.success       // the Odyssey success role
NeptuneTheme.identity.glassTint(MaterialTheme.colorScheme)
NeptuneTheme.moneyStyle()         // brand num face + tabular figures, RTL-aware
NeptuneTheme.formatDigits("2,484.00")  // numerals lever (Eastern Arabic opt-in)
```

Levers: `dark`, `arabic` (Arabic type set — pair with `LocalLayoutDirection`),
`density` (comfortable/compact), `numerals` (Latin/Eastern Arabic), `feedback`
(haptics weight + sound hook), `reducedMotion` (defaults to the platform
accessibility setting).

## Determinism contract

Same brandprint ⇒ identical theme on every platform. Enforced by golden tests
on **jvm, Android, iOS-native, js and wasm**: the Kotlin math must reproduce
`tokens.resolved.json` for every brand×mode×role and the four reference
brandprints exactly (`brandprints.golden.json`). Brand data is **generated**
by `node tools/codegen.mjs` from `themes.css` into
`odyssey-tokens/src/commonMain/kotlin/ly/neptune/odyssey/tokens/generated/` —
never hand-edited; `node tools/codegen.mjs --check` is the CI drift gate.

## Developing

```sh
./gradlew :odyssey-tokens:jvmTest :odyssey-compose-ui:jvmTest   # golden + theme tests
./gradlew :odyssey-tokens:iosSimulatorArm64Test                 # native goldens (macOS)
./gradlew :odyssey-tokens:jsNodeTest :odyssey-tokens:wasmJsNodeTest
./gradlew :gallery:run                                          # desktop gallery
./gradlew :gallery:wasmJsBrowserDevelopmentRun                  # browser gallery
./gradlew :gallery-android:assembleDebug                        # Android gallery APK
./gradlew :gallery:renderShots -PshotsDir=/tmp/kmp_shots        # pixel sweep (then LOOK at them)
./gradlew publishToMavenLocal                                   # publish-readiness smoke
```

iOS host app: embed `ly.neptune.odyssey.gallery.MainViewController()` from an
Xcode project (a bundled `iosApp/` is a follow-up milestone).

© 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
