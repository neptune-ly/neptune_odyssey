# 01 · Foundations

All values are tokens. Authoring colour space is **OKLCH** (`oklch(L C H)`): L = lightness 0–1, C = chroma, H = hue. This gives perceptually even tonal ramps and trivial light/dark mirroring. Convert to hex/ARGB at build time.

## Colour — Material 3 roles

Neptune uses the standard M3 role set. Every role has an `on-` pair for content. Never use a raw palette tone in product code — always a role.

| Role | Use |
|------|-----|
| `primary` / `on-primary` | Main actions, key emphasis (filled buttons, FAB, active states). |
| `primary-container` / `on-…` | Standout but lower-emphasis surfaces (balance hero, selected nav). |
| `secondary` / `secondary-container` | Supporting accents, tonal buttons, chips. |
| `tertiary` / `tertiary-container` | Contrast accent — info banners, card gradients, the brand's "second colour". |
| `error` / `success` (+ containers) | Status. `success` is a Neptune addition for credits/active states. |
| `background` / `surface` | Page and component base. |
| `surface-container-lowest → highest` | The five-step elevation tonal ramp. Cards step **up** the ramp instead of relying on shadow. |
| `surface-variant` / `on-surface-variant` | Muted fills and secondary text. |
| `outline` / `outline-variant` | Borders and dividers (variant = subtler). |
| `inverse-surface` / `inverse-on-surface` / `inverse-primary` | Snackbars, device bezel, inverted moments. |
| `scrim` | Modal backdrops. |

Each brand redefines **every** role for light and `[data-mode="dark"]`. See `tokens/themes.css`.

### Contrast
Body text ≥ 4.5:1, large text / UI components / icons ≥ 3:1. The `on-*` pairings are pre-validated; if you compose a new fill, re-check.

## Typography

Two-font model per brand: a **display** face (headlines, balances, brand moments) and a **text** face (everything else). `num` selects the face used for figures (tabular).

| Brand | Display | Text | Numerals |
|-------|---------|------|----------|
| Neptune | Hanken Grotesk | Hanken Grotesk | Hanken Grotesk |
| Andalus | Bricolage Grotesque | Hanken Grotesk | Hanken Grotesk |
| Nuran | Space Grotesk | Hanken Grotesk | Space Grotesk |

### Type scale (M3)
| Role | Size / line | Weight |
|------|-------------|--------|
| Display large | 57 / 64 | display weight |
| Display medium | 45 / 52 | display weight |
| Headline medium | 28 / 36 | 700 |
| Title medium | 18 / 24 | 600 |
| Body large | 16 / 24 | 400 |
| Body medium | 14 / 20 | 400 |
| Label large | 14 / 20 | 600 |

`display weight` and display letter-spacing are themed (Neptune 700/-0.02em, Andalus 700/-0.01em, Nuran 600/-0.03em). Always use **tabular figures** for money so digits don't jiggle.

## Shape — the per-brand corner family

The single most visible white-label lever after colour. One scale, retuned per brand.

| Token | Neptune | Andalus | Nuran |
|-------|---------|---------|-------|
| xs | 8 | 12 | 4 |
| sm | 12 | 18 | 8 |
| md | 16 | 26 | 12 |
| lg | 24 | 34 | 18 |
| xl | 32 | 44 | 26 |
| 2xl | 44 | 56 | 36 |
| full | 9999 | 9999 | 9999 |

Map components to **tokens**, not pixels: chips/inputs → sm, cards → md, sheets/heros → xl, pills/FAB → lg or full. Swapping the family re-shapes the whole app.

## Elevation
M3 tonal elevation: levels 0–4 climb the `surface-container-*` ramp; add a soft shadow only for truly floating elements (FAB, menus, dialogs). Prefer tonal step over heavy shadow — it reads cleaner in dark mode.

## Spacing
4px base grid: 4 · 8 · 12 · 16 · 24 · 32 · 48. Component padding and gaps snap to it. Use `gap` on flex/grid rather than per-child margins.

## Motion (Expressive)
| Token | Duration | Easing | Use |
|-------|----------|--------|-----|
| Standard | 300ms | `cubic-bezier(.2,0,0,1)` | Most transitions. |
| Emphasized | 500ms | `cubic-bezier(.2,0,0,1)` | Entrances, large moves. |
| Spring / spatial | 450ms | `cubic-bezier(.34,1.56,.64,1)` | Toggles, selection, anything that should feel alive. |

Expressive favours a little overshoot. Respect `prefers-reduced-motion`.

## Brand expression — the signature motif

Colour, shape and type make banks *different*; the **motif** makes each one *recognisable at a glance* without changing a single layout. Each theme defines a signature texture once, applied to the highest-visibility surfaces (balance hero, payment-card art) through identical markup.

| Token | What it is |
|-------|-----------|
| `--npt-motif` | A pure-CSS `background-image` pattern (gradients only — no asset). Uses `currentColor` so it auto-adapts to whatever fill it sits on, in light or dark. |
| `--npt-motif-size` | `background-size` for the pattern (`auto`, or a tile like `40px 32px`). |
| `--npt-motif-strength` | Opacity multiplier (0–1) to dial the texture up or down per brand. |
| `--npt-hero-emblem` | A larger single-gradient "emblem" anchored in a corner of the hero — the brand's hero gesture. |

Current signatures: **Neptune** sonar tide-rings · **Andalus** heritage arcade of arches · **Nuran** crisp digital light-grid + light sweep.

**The rule:** the motif lives entirely in tokens. The hero and card markup is one shared overlay `<span>` reading these vars — no per-bank component code. A new bank gets its character by authoring four token values, nothing more.
