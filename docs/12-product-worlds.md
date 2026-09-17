# Odyssey 2.0 — Product worlds

> **Philosophy:** **Distinct worlds. Shared trust.**

Odyssey is Neptune.Fintech's general digital-product design language. It can power banking,
wallets and payments, but it is not defined by finance. The same engineering system must also
support travel, mobility, commerce, hospitality, SaaS, lifestyle and other product categories
without making every customer feel like the same app with a different logo and primary color.

## Two orthogonal layers

Odyssey has two independent identity axes:

1. **Tenant / brand theme — “whose product is this?”**
   - M3 semantic palette
   - tenant shape family
   - tenant type choices
   - Brandprint
   - client identity/expression levers

2. **Product world — “what kind of experience is this?”**
   - composition and density
   - product-specific expressive roles
   - display-family guidance
   - framing and shape emphasis
   - illustration subject and silhouette
   - navigation/content rhythm
   - default interaction-motion level

A product world **must not replace** the tenant semantic palette. Shared controls, forms,
security, transaction state, accessibility and engineering behavior continue to use the active
tenant theme. World roles are for composition and editorial/product expression.

In TypeScript:

```ts
const theme = buildTheme("neptune", {
  mode: "dark",
  dir: "rtl",
  world: "voyage",
});

// Tenant identity remains stable.
theme.colors;
theme.brandprint;

// Product personality is additive.
theme.world?.colors;
theme.world?.titleFont;
theme.world?.radius;
theme.interactionMotion;
```

On web the same contract is represented by independent root attributes:

```html
<html
  data-theme="neptune"
  data-world="voyage"
  data-mode="dark"
  dir="rtl"
>
```

## First-class worlds

| World | Family | Display family | Radius | Default motion | Product emphasis |
|---|---|---|---:|---|---|
| `voyage` | travel | Sora | 20 | expressive | destination, itinerary, booking, discovery |
| `pulse` | mobility | Space Grotesk | 12 | expressive | live map, route, ETA, trip state |
| `market` | commerce | Plus Jakarta Sans | 18 | expressive | merchandising, discovery, product, cart |
| `harbor` | hospitality | Fraunces | 28 | standard | property, reservation, stay, service |
| `grid` | SaaS | IBM Plex Sans | 8 | standard | navigation shell, workflow, tables, dashboards |
| `canvas` | lifestyle | DM Sans | 24 | expressive | editorial feed, collections, events, consumer discovery |

These are not “themes” in the cheap white-label sense. A world should materially affect at
least composition, typography, framing/shape, density, imagery/illustration and interaction
rhythm. Palette alone is not sufficient.

## Visual rules

Default to flat fills, strong solid colors, intentional contrast, clear silhouettes,
well-composed type, purposeful asymmetry and editorial rhythm. Gradients, blur and glass are
exceptions, not identity requirements. Avoid generic “fintech” mesh gradients, glowing blobs,
crypto gloss and one-radius-everywhere layouts.

Material 3 and Material 3 Expressive are architectural references for accessibility,
behavior and platform conventions. Odyssey owns the visual language on top of those
primitives; it is not a Material clone.

## Illustration contract

Odyssey illustrations are reusable product primitives, not random stock art. The current
families in Figma include Voyage, Pulse, Market, Harbor, Grid and Canvas alongside the original
six Odyssey art-direction families.

Illustrations must be editable vector-first where practical and should define:

- silhouette and proportion before decorative detail;
- restrained facial detail for people;
- world-variable color roles for dark-mode adaptation;
- clear line/no-line and shadow behavior;
- an explicit RTL rule;
- an animation rule if the asset is animated.

### RTL direction

Mirror an illustration only when direction carries semantic meaning: routes, vehicles,
aircraft, journey arrows and directional navigation. Do **not** blindly mirror map pins,
buildings, product images, status symbols or decorative objects. Numeric values keep their
appropriate LTR treatment inside an RTL composition.

## Motion contract

Odyssey uses one motion grammar with three levels:

| Level | Duration | Distance | Stagger | Overshoot | Typical use |
|---|---:|---:|---:|---:|---|
| restrained | 160ms | 4px | 12ms | 0 | security, authorization, destructive/sensitive confirmation |
| standard | 240ms | 8px | 24ms | ≤3% | navigation, sheets, filters, lists, dashboards |
| expressive | 420ms | 16px | 40ms | ≤8% | travel, mobility, commerce, lifestyle discovery/editorial moments |

Reduced motion uses at most an 80ms dissolve and sets distance, stagger and overshoot to zero.
Motion must never invent backend success, payment completion, booking state, route progress or
live location.

## What remains shared

Worlds may feel genuinely different, but they share Odyssey trust primitives:

- WCAG accessibility and 48dp touch targets;
- semantic state and error behavior;
- form and input behavior;
- security and authorization patterns;
- deterministic theme/token architecture;
- responsive rules and logical layout properties;
- Light/Dark support;
- LTR/RTL support;
- component APIs and engineering primitives;
- truthful loading, progress, transaction and service state.

## Figma reference

The live Odyssey 2.0 Figma file is the visual reference for the current product-world work.
The continuation pages contain:

- `24 · Product worlds / Twelve personalities`
- `25 · Travel + Mobility / Product studies`
- `26 · Commerce + Hospitality / Product studies`
- `27 · SaaS + Lifestyle / Product studies`
- additions to `05 · Illustration / Art direction`
- additions to the existing Motion page
- additions to the existing Adaptive / Arabic page

The original six abstract Odyssey worlds remain valid art-direction research and should not be
deleted or rewritten merely because the product-world layer was added.
