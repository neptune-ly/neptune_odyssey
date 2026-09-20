# Odyssey 3.0 — adoption guide

Odyssey 3 is the new design standard: vivid colour fields, warm paper, confident ink, distinct product compositions and professional illustration. Earlier package releases numbered 2.x belong to the first standard. The new line begins at **3.0.0**.

Start with the [live system](https://neptune-ly.github.io/neptune_odyssey/), [portable kit](../site/kit/v3/README.md), [visual compass](../site/kit/v3/visual-compass.md) and [designer/agent contract](../site/kit/v3/DESIGNER-AGENT.md). These govern new visual work. Older gradient/glass/motif examples remain compatibility references, not mandatory 3.0 art direction.

## What ships

- Public design kit: six DTCG token files, CSS, JSON/TypeScript/Dart/Kotlin expression constants, three font families with licences, 94 SVG icons, eight dock SVG snapshots and four raster illustration studies with provenance.
- Figma remains the editable component source. Its manifest distinguishes native variants from SDK readiness. Access follows the file's sharing permissions; this release does not change them.
- Web, Flutter and Kotlin Multiplatform have explicit 3.0 foundation opt-ins: complete public colour profiles, Arabic metrics, Hanken numeric roles, control radius and reduced-motion durations.
- Existing widget APIs and NO1 brandprints are preserved. Full new-design widget parity, bank-private assets and runtime payment/map/booking integrations are outside this release.

## Install the released source

Use the `v3.0.0` Git tag for reproducible source integration. GitHub hosts this source release and the portable ZIP. Package metadata is coordinated at 3.0.0; npm, pub.dev and Maven Central publication require their own configured credentials. Do not infer registry availability from a GitHub tag.

For JavaScript development: clone the tag, run `pnpm install --frozen-lockfile` and `pnpm build`, then consume the workspace packages or pack the required package locally. Flutter can use a Git dependency pinned to `v3.0.0` with `path: packages/neptune_flutter_ui`. KMP can build the tagged source with `./gradlew publishToMavenLocal`.

## Web

```ts
import { applyTheme } from '@neptune.fintech/web-ui';

const theme = applyTheme(
  document.querySelector<HTMLElement>('#app')!,
  'neptune', {
  edition: 'odyssey3',
  product: 'wallet', // wallet (Core), drive, orbit, or banking
  mode: 'light',
  dir: 'ltr',
  reducedMotion: false,
});
// Dispose when this mounted surface is removed.
theme.dispose();
```

`buildTheme` accepts the same options for non-DOM use. Omitting `edition` keeps the existing `v1` behaviour. `banking` retains the caller's resolved tenant colour scheme while adopting the new foundation. Load/register Hanken Grotesk and Beiruti; Baloo 2 is a deliberate expressive heading choice. The site bundle exposes the same API as `Neptune.applyTheme`.

## Flutter

```dart
final theme = NeptuneTheme.odyssey3(
  NeptuneTheme.light('neptune'),
  product: NeptuneOdyssey3Product.wallet,
  arabic: false,
  reducedMotion: false,
);
```

Pass the result to `MaterialApp.theme`; build a matching dark theme from `NeptuneTheme.dark`. Set application locale and `Directionality` through the normal Flutter localisation path. Register fonts for offline applications. Hanken numeric roles and `displaySmall` remain distinct from Arabic text; use an isolated LTR amount/identifier widget. Existing `light`, `dark` and NO1 entry points keep their defaults.

## Kotlin Multiplatform / Compose

```kotlin
NeptuneTheme(
    brand = "neptune",
    dark = false,
    arabic = false,
    reducedMotion = false,
    odyssey3 = NeptuneOdyssey3Product.Wallet,
) {
    // Existing Odyssey components and product-owned composition.
}
```

`Banking`, `Wallet`, `Drive` and `Orbit` are available on the brand/config entry points. Omit `odyssey3` to preserve legacy resolution. Beiruti is bundled as a Compose resource alongside Hanken; third-party notices accompany it. Control shapes use the new control role; other historical widgets retain their existing structure.

## Design without drift

Use one dominant field and a purposeful accent. Choose expressive or composed from the task, vary layout and typography with the source product, and keep transaction facts visually dominant. Do not turn every bank into a recoloured card stack. Amounts and identifiers keep isolated direction; statuses always use semantic roles. Client-specific names, logos and data stay in private packages.

A dedicated image model or illustrator creates artwork. Vary category, viewpoint and silhouette; a faceless brief omits facial features without losing the shared drawing craft. PNGs are raster studies, not editable vectors, and internal inspection is not individual user approval.

## Release checks

Build and test JS packages; run token codegen/contrast and component literal gates. Analyze/test Flutter and render the 3.0 EN/light and AR/dark foundation matrix. Run KMP token and theme tests. Inspect the live page at desktop/mobile sizes, including composed/expressive, Arabic and dark mode. CI additionally exercises the existing cross-platform catalogue. Codegen success does not substitute for pixel review.
