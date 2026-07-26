# neptune-odyssey-kmp — Compose Multiplatform

The Kotlin Multiplatform / Compose Multiplatform implementation of the
[Neptune Odyssey](../../README.md) white-label banking design system.
**Status (0.4.0)**: full parity — theme engine, identity layer, 78
components, the 7 screen templates + 10-step onboarding flow, the
white-label demo shell, the generated 94-icon set, and the gallery on all
five surfaces, gated by the golden tests, the no-literals grep and the
480-frame render sweep. Promoted out of `roadmap/` after meeting the bar in
[`../../roadmap/ROADMAP.md`](../../roadmap/ROADMAP.md); **not yet published**
to Maven Central (see § Releasing — only credentials are missing).

## Modules

| Module | Coordinates (publish-ready) | What |
|---|---|---|
| `:odyssey-tokens` | `ly.neptune.odyssey:odyssey-tokens` | Pure Kotlin determinism core: OKLCH↔sRGB math, seed→M3 palette ramp, brandprint codec (`NO1-…`), seed extractor, generated brand data. Zero dependencies. |
| `:odyssey-compose-ui` | `ly.neptune.odyssey:odyssey-compose-ui` | The Compose library: `NeptuneTheme`, the identity layer (glass/motifs/elevation-glow/gradients/eyebrow), the full component set + screen templates + demo shell + `NptIcons`, bundled OFL brand fonts. |
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

## Web (wasm/js): preload the brand fonts

The 9 reference faces ship inside the library as Compose resources. On the
browser targets resources load **asynchronously**, so the first text frame
would paint in the platform default face and re-render when the brand face
arrives (a flash-of-default-font). Warm the faces your brandprint uses before
composing the app — the resource accessors are public
(`ly.neptune.odyssey.ui.resources.Res`):

```kotlin
import ly.neptune.odyssey.ui.resources.Res
import ly.neptune.odyssey.ui.resources.hanken_grotesk_400
import ly.neptune.odyssey.ui.resources.hanken_grotesk_700
import org.jetbrains.compose.resources.ExperimentalResourceApi
import org.jetbrains.compose.resources.preloadFont

@OptIn(ExperimentalComposeUiApi::class, ExperimentalResourceApi::class)
fun main() {
    ComposeViewport(viewportContainerId = "app") {
        val text by preloadFont(Res.font.hanken_grotesk_400)
        val display by preloadFont(Res.font.hanken_grotesk_700)
        if (text != null && display != null) {
            NeptuneTheme(brand = "neptune") { App() }
        } // else: keep the host page's loader visible — no fallback-font flash
    }
}
```

Preload the weights your first screen actually renders (400 + 700 covers the
default type scale; add 500/600/800 if your screens use them). Faces per
reference brand: **neptune** = Hanken Grotesk · **triton** = Bricolage
Grotesque (display) + Hanken Grotesk · **nereid** = Space Grotesk (display,
num) + Hanken Grotesk · **proteus** = Sora (display, num) + Hanken Grotesk.
Booting in Arabic (`arabic = true`)? Preload the brand's Arabic set instead
(the pairing lives in the generated brand data, `NptTypeSet`). Custom faces
registered via `NeptuneFontRegistry` are yours to load — register them
before composing `NeptuneTheme`. The other targets (Android/iOS/desktop)
load bundled resources synchronously and need none of this. Both gallery
web entry points (`gallery/src/jsMain`, `gallery/src/wasmJsMain`)
demonstrate the pattern.

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

iOS host app: `iosApp/iosApp.xcodeproj` embeds the GalleryKit framework
(`xcodebuild -project iosApp/iosApp.xcodeproj -target iosApp -sdk
iphonesimulator build CODE_SIGNING_ALLOWED=NO`, or open in Xcode and run).

## Releasing (prepped — waiting on credentials)

`.github/workflows/release-kmp.yml` publishes both modules to Maven Central
(Central Portal) on a `kmp-v*` tag or manual dispatch. Locally,
`./gradlew centralBundle` stages every publication into
`build/staging-deploy` (signed when the `signingInMemoryKey` /
`signingInMemoryKeyPassword` Gradle properties are present; unsigned
otherwise) and zips `build/central/central-bundle.zip` for the Portal
upload API. The workflow needs four repo secrets — `CENTRAL_USERNAME` /
`CENTRAL_PASSWORD` (a central.sonatype.com user token; the `ly.neptune`
namespace must be DNS-verified first) and `SIGNING_KEY` /
`SIGNING_PASSWORD` (armored PGP key + passphrase) — and uploads as
**USER_MANAGED**, so nothing goes live until "Publish" is pressed in the
portal. Once the secrets are in place, tag `kmp-v0.4.0` (or bump first) to
cut the first release.

© 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
