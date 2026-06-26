# @neptune-odyssey/tokens

The **determinism backbone** of [Neptune Odyssey](https://neptune.ly) — the white-label
banking design system by **Neptune.Fintech**. This package owns the color math, the
seed→palette ramp, the brandprint codec, the pinned reference palettes, and the unified
theme builder. Every other Odyssey library (Flutter, web, Svelte, Vue) resolves themes
through the same logic, so **the same brandprint produces the same theme everywhere**.

> Source-available under the **Neptune Odyssey Community License v1.0** — free for
> non-commercial use and for organizations under USD $25k/yr revenue. See `LICENSE`.

## Install

```sh
pnpm add @neptune-odyssey/tokens
```

ESM-only, `sideEffects: false`, fully tree-shakeable, SSR-safe. No runtime CSS-in-JS.

## Three ways to theme — one surface

```ts
import { buildTheme } from "@neptune-odyssey/tokens";

buildTheme("andalus", { mode: "dark", dir: "rtl" }); // 1 · reference brand id
buildTheme(myConfig);                                  // 2 · full config object
buildTheme("NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA"); // 3 · brandprint string
```

`buildTheme()` returns a platform-agnostic `NeptuneTheme`: resolved `colors` (37 M3 roles
incl. `success`), `shape` (xs…xxl), `type`, the five expression `levers`, `motion`
(per-brand easings/durations), plus the canonical `brandprint`.

## The brandprint codec

```ts
import { encode, decode } from "@neptune-odyssey/tokens";

const print = encode(config);   // "NO1-…"  · 28-byte payload, base64url, checksummed
const config = decode(print);   // throws on bad prefix / length / checksum / version
```

Registries are **append-only** — the enum indices *are* the wire format (see `docs/11`).

## Color & palette

```ts
import { oklchToHex, oklchToArgb, generatePalette, resolvePalette } from "@neptune-odyssey/tokens";

oklchToHex({ L: 0.48, C: 0.15, H: 258 });          // "#1d5ab0"
resolvePalette(primarySeed, tertiarySeed, "light"); // pinned for reference, ramp for custom
```

## The determinism contract (what the golden tests guarantee)

1. **Pinned reference palettes are exact.** `getResolvedPalette(brand, mode)` equals
   `build/tokens.resolved.json` byte-for-byte, and the Flutter package ships the identical
   ARGB data — so **Flutter == Web is exact by construction** for the four reference brands.
2. **The shared OKLCH→sRGB converter reproduces that data to ≤ 1 LSB per channel**
   (275/296 roles exact = 93%; the 21 residuals are off-by-one at gamut edges — sub-perceptual
   browser rounding). It is used for *custom* seeds, where the TS and Dart ports run identical
   math and therefore agree with each other.
3. **The brandprint codec is byte-identical** to `tools/brandprint.reference.js` for the four
   brands, idempotent (`encode(decode(x)) === x`), and rejects tampered/short/wrong-version strings.

Run them: `pnpm --filter @neptune-odyssey/tokens test`.

---
© 2026 Neptune.Fintech. "Neptune Odyssey" and "Neptune.Fintech" are marks of the Licensor.
The bundled example brands (neptune/andalus/nuran/fglb) are reference illustrations only.
