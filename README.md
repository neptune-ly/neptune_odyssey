# Neptune Odyssey

**Neptune.Fintech's cross-product design system and product-experience framework.**

**Distinct worlds. Shared trust.** Odyssey provides one deterministic engineering foundation
for financial and non-financial products while allowing products and customers to feel
materially different through composition, typography, shape language, density, illustration,
navigation, motion and content rhythm.

Odyssey can power retail and corporate banking, wallets, merchant/POS experiences, payment
apps, onboarding/KYC and gateways — but also travel, mobility, commerce, hospitality, SaaS,
lifestyle and other digital products. It is **not** a banking-only UI kit and it is **not** a
“same Material screen + new logo/color/radius” white-label engine.

Material 3 / Material 3 Expressive provide architectural guidance for semantics,
accessibility and platform behavior. Odyssey owns the visual language above those primitives:
flat-first color, expressive silhouettes, deliberate typography, editorial composition,
product-specific illustration and truthful motion.

`v2.0 · Odyssey product worlds in active development`

**▶ Live:** [**Demo gallery**](https://neptune-ly.github.io/neptune_odyssey/) ·
[**Theme builder**](https://neptune-ly.github.io/neptune_odyssey/configurator/)

> **Source-available, not open source.** Neptune Odyssey is licensed under the
> **Neptune Odyssey Community License v1.0** ([`LICENSE`](LICENSE)): free for non-commercial
> use and for organizations under **USD $25,000/yr** revenue; a commercial license is
> required above that. Keep the attribution; don't pass it off as your own; don't use the
> Neptune.Fintech marks.

The four example tenants — `neptune`, `triton`, `nereid`, `proteus` — are **reference
illustrations only**. They prove tenant/Brandprint determinism and convey no partner rights.
Product worlds are a separate axis and are never encoded as tenant brand IDs.

## The Odyssey 2.0 model

Odyssey deliberately separates two questions:

- **Tenant / brand theme — “whose product is this?”** Semantic M3 palette, tenant type and
  shape, Brandprint and client identity levers.
- **Product world — “what kind of experience is this?”** Composition, density, expressive
  roles, display family, illustration language and interaction-motion intensity.

Those layers compose over shared accessibility, security, state semantics, responsive rules,
RTL, Light/Dark behavior and component APIs.

The first six non-financial worlds implemented in `@neptune.fintech/tokens` are:

| World | Product family | Display family | Default motion |
|---|---|---|---|
| `voyage` | travel / booking / itinerary | Sora | expressive |
| `pulse` | mobility / live trip | Space Grotesk | expressive |
| `market` | commerce / marketplace | Plus Jakarta Sans | expressive |
| `harbor` | hospitality / in-stay service | Fraunces | standard |
| `grid` | SaaS / admin / productivity | IBM Plex Sans | standard |
| `canvas` | lifestyle / editorial consumer | DM Sans | expressive |

See [`docs/12-product-worlds.md`](docs/12-product-worlds.md) for the complete contract.

## The brandprint

A **brandprint** is a short, deterministic string (`NO1-…`) that encodes the tenant identity
layer. Pick tenant colours, shape, type and expression levers in the configurator → copy the
brandprint → paste it into any Odyssey library and get the identical tenant theme.

```text
NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA   →   Triton reference tenant, everywhere
```

Same string ⇒ same tenant identity on every platform. Product worlds compose on top and do not
mutate the Brandprint.

## Packages

All JS/TS packages are published under [`@neptune.fintech`](https://www.npmjs.com/org/neptune.fintech);
`neptune_flutter_ui` and `neptune_sound_kit` target pub.dev.

| Package | What it is | Status |
|---------|-----------|--------|
| [`@neptune.fintech/tokens`](packages/neptune_tokens) | Determinism backbone — palette math, Brandprint, tenant themes, product worlds and interaction motion | **npm ✓** · v2.0.0 |
| [`neptune_flutter_ui`](packages/neptune_flutter_ui) | Flutter theme + component library | **pub.dev ✓** · v2.13.0 |
| [`neptune_sound_kit`](packages/neptune_sound_kit) | Optional Flutter sound cues | **Stable** · not yet published |
| [`@neptune.fintech/web-ui`](packages/neptune_web_ui) | Framework-agnostic CSS-variable core + custom elements + `applyTheme` | **npm ✓** · v2.5.1 |
| [`@neptune.fintech/svelte-ui`](packages/neptune_svelte_ui) | Svelte integration | **npm ✓** · v2.0.1 |
| [`@neptune.fintech/vue-ui`](packages/neptune_vue_ui) | Vue 3 integration | **npm ✓** · v2.0.1 |
| [`@neptune.fintech/react-ui`](packages/neptune_react_ui) | React provider + hook + typed wrappers | **npm ✓** · v2.0.1 |
| [`neptune_laravel_ui`](packages/neptune_laravel_ui) | Blade components over the web kit | **Stable** |
| [`@neptune.fintech/react-native-ui`](packages/neptune_react_native_ui) | React Native provider + themed native components | **npm ✓** · maintenance mode |
| [`@neptune.fintech/icons`](packages/neptune_icons) | Original icon library + `<npt-icon>` | **npm ✓** |
| [`@neptune.fintech/brand-configs`](packages/neptune_brand_configs) | Reference tenant configs + loader | **npm ✓** |
| [`@neptune.fintech/product-configs`](packages/neptune_product_configs) | Product configuration + feature flags | **npm ✓** |
| [`create-neptune`](packages/create-neptune) | Starter-app scaffolder CLI | **npm ✓** |
| [`apps/configurator`](apps/configurator) | Tenant theme/Brandprint configurator | **Stable** |
| [`apps/neptune_studio`](apps/neptune_studio) | Desktop client-demo factory | **Stable** |
| [`apps/neptune_desktop`](apps/neptune_desktop) | Cross-platform demo shell | **Stable** |
| [`@neptune.fintech/docs`](packages/neptune_docs) | Written system + visual contracts | — |
| [`neptune-odyssey-kmp`](packages/neptune_kmp_ui) | Kotlin/Compose Multiplatform system | **Stable** |

## Compose tenant + product world

```ts
import { buildTheme } from "@neptune.fintech/tokens";
import { applyTheme } from "@neptune.fintech/web-ui";

const theme = buildTheme("neptune", {
  mode: "dark",
  dir: "rtl",
  world: "voyage",
});

// Tenant semantic identity stays stable.
theme.colors;
theme.brandprint;

// Product personality is additive.
theme.world?.colors;
theme.world?.titleFont;
theme.interactionMotion;

applyTheme(document.documentElement, "neptune", {
  mode: "dark",
  dir: "rtl",
  world: "voyage",
});
// data-theme="neptune" data-world="voyage" data-mode="dark" dir="rtl"
```

Existing calls without `world` remain valid and retain the prior tenant-theme output contract.

## Motion

Odyssey uses one motion grammar rather than per-product animation inventions:

- **restrained** — 160ms / 4px / no overshoot: security, authorization, destructive and
  sensitive confirmation;
- **standard** — 240ms / 8px / ≤3% overshoot: navigation, sheets, filters, lists, dashboards;
- **expressive** — 420ms / 16px / ≤8% overshoot: travel, mobility, commerce and lifestyle
  discovery/editorial moments.

Reduced motion keeps at most an 80ms dissolve and removes travel, stagger and overshoot.
Motion never fabricates backend completion, booking progress, payment success or live location.

## Shared trust contract

Regardless of world or tenant, Odyssey keeps the same engineering guarantees: semantic states,
WCAG accessibility, ≥48dp touch targets, keyboard/focus behavior, responsive rules, logical
layout properties, Light/Dark, LTR/RTL, form/security patterns, deterministic tokens and stable
component APIs.

### Determinism

1. Pinned tenant palettes remain exact across supported platforms.
2. Shared OKLCH→sRGB math remains deterministic for custom tenant seeds.
3. Brandprint remains byte-stable and idempotent.
4. Product-world resolution is deterministic for `world + mode` and composes without changing
   tenant palette or Brandprint.

## Develop

```sh
corepack pnpm install
pnpm -r --filter "./packages/**" run build
pnpm -r --filter "./packages/**" run test
( cd packages/neptune_flutter_ui && flutter test )
```

The CI suite additionally runs token/codegen/contrast gates, KMP builds, LTR/RTL visual sweeps
and blank-region checks.

## Publishing

Packages are publish-ready (`exports`, types, `sideEffects:false`, pubspec). Releases publish
from CI on a `v*` tag. Credentials belong in CI secrets and never in repository code.

---
© 2026 Neptune.Fintech. "Neptune Odyssey" and "Neptune.Fintech" are marks of the Licensor.
See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).
