# Neptune Odyssey

**A vendor-neutral, white-label banking design system by [Neptune.Fintech](https://neptune.ly).**

One Material 3 + Material 3 Expressive core that any institution wears as its own — colour,
shape, type, motion and brand expression all flex to the brand, while structure,
accessibility and engineering stay identical. **Structure is shared; skin is per-brand.**
A component built once is correct for every bank, in every mode, in both directions. If a
bank wants to look different, that's a *theme* — never a fork.

`v1.0.0 · Stable`

**▶ Live:** [**Demo gallery**](https://neptune-ly.github.io/neptune_odyssey/) — every brand ×
light/dark × LTR/RTL across the product types · [**Theme builder**](https://neptune-ly.github.io/neptune_odyssey/configurator/)
— the hash-preset maker: pick a theme, copy its `NO1-…` brandprint, use it anywhere.

> **Source-available, not open source.** Neptune Odyssey is licensed under the
> **Neptune Odyssey Community License v1.0** ([`LICENSE`](LICENSE)): free for non-commercial
> use and for organizations under **USD $25,000/yr** revenue; a commercial license is
> required above that. Keep the attribution; don't pass it off as your own; don't use the
> Neptune.Fintech marks. This is how the project stays **public yet protected**.

The four example brands — `neptune`, `andalus`, `nuran`, `fglb` — are **reference
illustrations only**. They exist to prove the white-label engine (the same-but-distinct
rule: every brand moves ≥ 6 of 12 levers). They are not real partner products and convey
no rights. The system itself belongs to no bank — it is Neptune.Fintech's platform.

## The headline feature — the brandprint

A **brandprint** is a short, deterministic string (`NO1-…`) that encodes a theme. Pick
colours, shape, type and the five expression levers in the configurator → copy the
brandprint → paste it into any Odyssey library and get the **identical** theme.

```
NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA   →   the Andalus reference theme, everywhere
```

Same string ⇒ same theme on every platform. That guarantee is enforced by golden tests.

## Packages

| Package | What it is | Status |
|---------|-----------|--------|
| [`@neptune.fintech/tokens`](packages/neptune_tokens) | The determinism backbone — OKLCH→sRGB math, seed→palette ramp, brandprint codec, pinned palettes, `buildTheme()` | **Stable** |
| [`neptune_flutter_ui`](packages/neptune_flutter_ui) | Flutter `ThemeData` per brand/mode, ThemeExtensions, widgets | **Stable** |
| [`@neptune.fintech/web-ui`](packages/neptune_web_ui) | Framework-agnostic CSS-variable core + custom elements + `applyTheme` | **Stable** |
| [`@neptune.fintech/svelte-ui`](packages/neptune_svelte_ui) | Svelte `use:theme` action + provider | **Stable** |
| [`@neptune.fintech/vue-ui`](packages/neptune_vue_ui) | Vue 3 provider + typed wrappers | **Stable** |
| [`@neptune.fintech/react-ui`](packages/neptune_react_ui) | React provider + `useNeptuneTheme` hook + typed wrappers | **Stable** |
| [`@neptune.fintech/brand-configs`](packages/neptune_brand_configs) | 5 reference tenants + loader | **Stable** |
| [`@neptune.fintech/product-configs`](packages/neptune_product_configs) | Product flavor + feature flags | **Stable** |
| [`apps/configurator`](apps/configurator) | Client-only theme builder (brandprint encode/decode + live preview + AA check) | **Stable** |
| [`@neptune.fintech/docs`](packages/neptune_docs) | The written system + the `.dc.html` visual contracts | — |
| [`roadmap/`](roadmap) | React Native · Kotlin Multiplatform | **Roadmap** (not in v1) |

## Three ways to theme — one surface, everywhere

```ts
// web / svelte / vue
applyTheme(root, "andalus", { mode: "system", dir: "auto" }); // 1 · reference brand id
applyTheme(root, "NO1-AYB4AK…");                               // 2 · brandprint string
applyTheme(root, { primary:{L,C,H}, corners:{…}, motion:"calm-graceful", … }); // 3 · config
```
```dart
// flutter
MaterialApp(
  theme: NeptuneTheme.light('andalus'),
  darkTheme: NeptuneTheme.dark('andalus'),
  // or NeptuneTheme.fromBrandprint('NO1-…'), or NeptuneTheme.fromConfig(cfg)
);
```

Plus global `mode` (`light|dark|system`) and `dir` (`ltr|rtl|auto`). Tokens are read only
through the framework's theme context — **never a literal** in a component.

## The determinism contract (what the golden tests guarantee)

1. **Pinned reference palettes are exact.** The resolved palette (`build/tokens.resolved.json`)
   ships byte-identical in TS and Dart, so **Flutter == Web is exact by construction** for
   the reference brands.
2. **The shared OKLCH→sRGB converter** reproduces that data to **≤ 1 LSB per channel**
   (93% exact; residuals are sub-perceptual browser rounding at gamut edges) — used for
   custom seeds, where the TS and Dart ports run identical math and agree with each other.
3. **The brandprint codec is byte-identical** to the reference (`tools/brandprint.reference.js`)
   for the four brands, idempotent, and rejects tampered/short/wrong-version strings.

## Develop

```sh
corepack pnpm install        # or: npx pnpm@9.15.0 install
pnpm -r --filter "./packages/**" run build
pnpm -r --filter "./packages/**" run test     # JS/TS golden + unit tests
( cd packages/neptune_flutter_ui && flutter test )   # Dart golden tests
```

Production mobile stack is **Flutter** (Material 3). Web is a sibling, not stretched mobile.
Supports **light + dark** and **LTR + RTL** (banks are largely MENA; logical properties only).
Colours authored in **OKLCH**, resolved to hex/ARGB at build time.

## Publishing

Packages are publish-ready (`exports`, types, `sideEffects:false`, pubspec). Releases publish
from CI on a `v*` tag (`.github/workflows/release.yml`) — add `NPM_TOKEN` and `PUB_CREDENTIALS`
as repo secrets. No credentials ever touch a developer machine.

---
© 2026 Neptune.Fintech. "Neptune Odyssey" and "Neptune.Fintech" are marks of the Licensor.
See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).
