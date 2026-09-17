# AGENTS.md — implementing Neptune Odyssey

You are turning **Neptune Odyssey** — Neptune.Fintech's cross-product digital design system and
product-experience framework — into a real product. Odyssey powers banking and fintech, but it
is **not a banking-only UI kit**. Read this before writing code.

> Also read [`ODYSSEY_RULEBOOK.md`](./ODYSSEY_RULEBOOK.md) for implementation mistakes,
> verification harnesses and shipping discipline, and [`docs/12-product-worlds.md`](./docs/12-product-worlds.md)
> for the Odyssey 2.0 product-world contract. Where older visual doctrine conflicts with the
> current product-world contract, preserve its engineering/accessibility rules but follow the
> newer flat-first, product-specific direction.

## Mental model

Odyssey has two orthogonal expression layers over one shared engineering system:

```text
TENANT / BRAND                         PRODUCT WORLD
whose product?                         what kind of experience?

seed palette ─┐                        voyage / pulse / market
shape family ─┼─► tenant theme    +    harbor / grid / canvas
brand type  ──┘                              │
       │                                      │
       └──────────────┬───────────────────────┘
                      ▼
        shared trust + engineering primitives
                      ▼
      components / responsive behavior / screens
```

- A **tenant theme** is deterministic data: M3 semantic color roles, tenant shape/type,
  Brandprint and client expression levers.
- A **product world** is product-personality data: composition guidance, expressive color
  roles, display family, geometry emphasis and default interaction-motion intensity.
- A **component** contains zero hardcoded bank/tenant/product knowledge. It consumes semantic
  tokens and behavior contracts.
- A **screen** may compose the same primitives very differently by product world. A taxi app,
  travel app, wallet and corporate portal are not required to share one skeleton.

A customer wanting a distinct identity is **not** permission to fork core behavior. A product
category needing a different composition is **not** permission to disguise the same screen by
changing only color/radius.

## Source of truth

1. `tokens/themes.css` + `tokens/tokens.json` — tenant semantic palette, shape and type data.
2. `packages/neptune_tokens/src/worlds.ts` — Odyssey 2.0 product-world and interaction-motion
   definitions; these are orthogonal to tenant themes.
3. The live Odyssey 2.0 Figma file — current visual contract for worlds, illustration, motion,
   adaptive behavior and product studies. Continuation pages 24–27 prove non-financial use.
4. `docs/12-product-worlds.md` — product-world architecture, RTL and motion contract.
5. `configs/*.tenant.json` — reference tenants. A tenant is one config set, never a fork.
6. `docs/07-design-principles.md`, `docs/09-governance-and-versioning.md`,
   `docs/10-token-naming.md` — design, versioning and token governance.

Older `.dc.html` finance contracts remain useful reference material for the financial product
family; they no longer define the full boundary of Odyssey.

## Workflow: tenant / brand work

1. Take the tenant seed hue(s) and generate the full M3 tonal palette.
2. Pick the tenant corner family and type identity.
3. Resolve one theme object for the target platform.
4. Verify light/dark, LTR/RTL and WCAG contrast.
5. Do not introduce brand-specific component forks.

## Workflow: product-world work

1. Choose the nearest existing world before inventing another.
2. Keep tenant semantic roles intact; use `--o2-world-*` / `theme.world` for product expression.
3. Change composition, density, hierarchy, typography, framing, illustration and interaction
   rhythm when the product genuinely requires it — not just palette.
4. Reuse shared security, forms, state semantics, accessibility and component APIs.
5. Verify Light/Dark and LTR/RTL. Mirror only semantically directional graphics.
6. Select the lowest motion level that communicates the state; sensitive financial/security
   confirmation stays restrained.

## Hard rules

- **No literals in components.** Color → semantic/world token. Radius → shape token. Font →
  theme/world type guidance. Spacing → shared scale.
- **No cheap white-labeling.** Logo + primary color + radius is not a distinct product.
- **Directional-agnostic engineering.** Use start/end and logical properties; test RTL.
- **Directional art is deliberate.** Mirror routes, vehicles, aircraft and navigation when
  direction carries meaning; do not blindly mirror buildings, product images or status icons.
- **Both modes.** Every meaningful surface must work in light and dark.
- **Accessibility is non-negotiable.** Touch targets ≥48dp, text scaling, keyboard/focus and
  WCAG AA remain shared trust primitives.
- **Material 3 is architectural, not the visual identity.** Reuse semantics, accessibility and
  platform behavior; Odyssey owns its visual language. Do not build a second behavior system.
- **Flat-first visual language.** Gradients, blur and glass are exceptions. Do not use glowing
  blobs, mesh gradients or glossy crypto styling as generic identity filler.
- **Tokens are public API.** Rename/removal is a breaking change; follow semver governance.
- **Product worlds and tenant brands stay orthogonal.** Never add `voyage`, `grid`, etc. to the
  tenant Brandprint brand registry.
- **Motion is truthful.** Never animate fake payment completion, booking progress or location.
  Reduced motion removes travel/stagger/overshoot.

## Platform notes

- **Tokens / TypeScript:** `buildTheme(input, { mode, dir, world, motionLevel, reducedMotion })`.
  Existing calls without world options retain the old tenant-theme output contract.
- **Web:** `applyTheme(root, input, { world: "voyage", ... })` composes `data-theme`,
  `data-world`, `data-mode` and `dir`; product expression lives in `--o2-world-*` variables.
- **Flutter / KMP:** continue consuming tenant semantic themes. Product-world ports should expose
  the same roles and motion levels without duplicating component behavior.
- **Other / DTCG:** keep tenant semantic tokens and product-world roles as composable layers.
