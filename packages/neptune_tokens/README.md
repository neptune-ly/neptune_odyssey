# @neptune.fintech/tokens

The **determinism backbone** of [Neptune Odyssey](https://neptune.ly) — Neptune.Fintech's
cross-product digital design system. The package owns color math, the seed→palette ramp,
the Brandprint codec, pinned reference palettes, product-world tokens, interaction-motion
levels, and the unified theme builder.

Tenant identity and product personality are deliberately separate:

- **tenant/brand theme** answers *whose product is this?* — palette, shape family, type,
  Brandprint and client expression levers;
- **product world** answers *what kind of experience is this?* — travel, mobility,
  commerce, hospitality, SaaS or lifestyle composition and expressive roles.

A travel app and a bank can share Odyssey engineering primitives without looking like the
same Material screen with different logos. Likewise, choosing `world: "voyage"` never
changes the tenant Brandprint or its M3 semantic palette.

> Source-available under the **Neptune Odyssey Community License v1.0** — free for
> non-commercial use and for organizations under USD $25k/yr revenue. See `LICENSE`.

## Install

```sh
pnpm add @neptune.fintech/tokens
```

ESM-only, `sideEffects: false`, fully tree-shakeable, SSR-safe. No runtime CSS-in-JS.

## Tenant theme — three inputs, one surface

```ts
import { buildTheme } from "@neptune.fintech/tokens";

buildTheme("triton", { mode: "dark", dir: "rtl" }); // reference brand id
buildTheme(myConfig);                                  // full config object
buildTheme("NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA"); // Brandprint string
```

`buildTheme()` returns the existing platform-agnostic `NeptuneTheme`: resolved `colors`
(37 M3 roles incl. `success`), `shape` (xs…xxl), `type`, expression `levers`, brand-level
`motion`, and canonical `brandprint`.

## Product worlds — orthogonal composition language

```ts
import {
  buildTheme,
  resolveProductWorld,
  resolveMotionLevel,
} from "@neptune.fintech/tokens";

const travel = buildTheme("neptune", {
  mode: "dark",
  dir: "rtl",
  world: "voyage",
});

travel.colors;             // Neptune tenant M3 palette — unchanged
travel.brandprint;         // Neptune Brandprint — unchanged
travel.world?.colors;      // Voyage accent/tint/hero/spark/background roles
travel.world?.titleFont;   // Sora
travel.world?.radius;      // 20
travel.interactionMotion;  // Voyage default: expressive

resolveProductWorld("grid", "light");
resolveMotionLevel("restrained", true); // reduced: 80ms, 0 travel/stagger/overshoot
```

The six first-class non-financial worlds are:

| World | Product family | Display family | Radius | Default motion |
|---|---|---|---:|---|
| `voyage` | travel / booking / itinerary | Sora | 20 | expressive |
| `pulse` | mobility / ride tracking | Space Grotesk | 12 | expressive |
| `market` | commerce / marketplace | Plus Jakarta Sans | 18 | expressive |
| `harbor` | hospitality / in-stay service | Fraunces | 28 | standard |
| `grid` | SaaS / admin / productivity | IBM Plex Sans | 8 | standard |
| `canvas` | lifestyle / editorial consumer | DM Sans | 24 | expressive |

These world roles are **not substitutes for M3 semantic roles**. Shared controls continue
to use the tenant theme. World tokens are for product composition, editorial backgrounds,
hero art, category emphasis and world-specific framing.

## Motion levels

Odyssey uses three interaction levels over one shared physics system:

- `restrained`: 160ms, 4px, 12ms stagger, no overshoot — security, destructive actions,
  authorization and sensitive confirmation;
- `standard`: 240ms, 8px, 24ms stagger, ≤3% overshoot — navigation, sheets, filters,
  ordinary lists and dashboards;
- `expressive`: 420ms, 16px, 40ms stagger, ≤8% overshoot — discovery, travel, mobility,
  commerce and lifestyle editorial moments.

`reducedMotion: true` keeps at most an 80ms dissolve and forces distance, stagger and
overshoot to zero. Motion must never fabricate payment completion, service progress or
live location.

## CSS generation

```ts
import {
  allProductWorldCss,
  productWorldToCssBlock,
  motionLevelToCssVars,
} from "@neptune.fintech/tokens";

productWorldToCssBlock("market", "dark");
allProductWorldCss();
motionLevelToCssVars("expressive", true);
```

Generated product-world variables use the `--o2-world-*` namespace and `[data-world]`
selector. They do not overwrite `--md-sys-color-*`, so `data-theme`, `data-mode`, `dir`
and `data-world` can compose independently on the same root element.

## The Brandprint codec

```ts
import { encode, decode } from "@neptune.fintech/tokens";

const print = encode(config);   // "NO1-…" · base64url, checksummed
const config = decode(print);   // throws on bad prefix / length / checksum / version
```

Registries are **append-only** — enum indices are the wire format.

## Color & palette

```ts
import { oklchToHex, oklchToArgb, generatePalette, resolvePalette } from "@neptune.fintech/tokens";

oklchToHex({ L: 0.48, C: 0.15, H: 258 });
resolvePalette(primarySeed, tertiarySeed, "light");
```

## Determinism contract

Pinned tenant palettes remain exact, the shared OKLCH→sRGB converter remains the custom
seed path, and Brandprint remains byte-stable. Product worlds add no entropy: the same
`brandprint + mode + dir + world + motion level + reduced-motion flag` resolves to the
same theme data on every call.

Run package validation with:

```sh
pnpm --filter @neptune.fintech/tokens build
pnpm --filter @neptune.fintech/tokens test
```

---
© 2026 Neptune.Fintech. "Neptune Odyssey" and "Neptune.Fintech" are marks of the Licensor.
The bundled example brands (neptune/triton/nereid/proteus) are reference illustrations only.
