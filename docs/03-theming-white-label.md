# 03 · Theming & white-label

This is Neptune's reason to exist: **stand up a new bank's app by authoring a theme, not by editing the product.**

## What a theme controls

| Layer | Lever | Impact |
|-------|-------|--------|
| Colour | seed hue(s) → full M3 tonal palette | every role, light + dark |
| Shape | corner family (xs…full) | every card/button/sheet radius |
| Type | display + text typefaces, display weight/tracking | headlines, balances, brand moments |
| Motion | (shared Expressive tokens, rarely overridden) | feel |
| **Expression** | **signature motif + hero emblem** (`--npt-motif*`, `--npt-hero-emblem`) | **the texture that makes a bank recognisable at a glance** |

A bank is therefore a small data object. Everything else is inherited. This is why two Neptune banks can look genuinely different (compare Andalus vs Nuran in the live file) while sharing 100% of components, flows, tests and accessibility work.

## How deep does personalisation go?

The current app's problem was that only the primary colour and a logo changed — every bank felt identical. Neptune fixes that by making **colour + shape + type** all brand-controlled. The spectrum:

- **Light touch** — reuse Neptune's shape + type, swap seed colour + logo. (Fastest onboarding.)
- **Standard** — custom palette + corner family + display face. (Andalus, Nuran.)
- **Heavy** — all of the above plus bespoke balance-hero motif, illustration set, custom card art.

All three are the *same* theme mechanism at different fill levels — never a code fork.

## Authoring a new theme (e.g. "Marsa Bank")

1. **Seed.** Pick the brand's primary colour; express as OKLCH. Choose a tertiary hue for the contrast accent (card gradients, info).
2. **Generate the tonal palette.** Derive each M3 role for light and dark. Pattern used in `tokens/themes.css`:
   - Light: `primary` L≈0.5, containers L≈0.9, `on-` pairs high-contrast; surfaces L 0.90–1.0 with a faint hue tint (low chroma at the brand hue).
   - Dark: mirror — `primary` L≈0.8 on dark containers L≈0.35; surfaces L 0.09–0.28.
   - Keep chroma modest on surfaces/outlines (≈0.006–0.025) so the UI stays calm; reserve high chroma for `primary`/`tertiary`.
   - You can also feed the seed through Material Color Utilities (HCT) for the standard M3 ramp, then nudge into OKLCH.
3. **Shape.** Pick a corner family: tighter = modern/digital, generous = warm/premium. Fill all seven steps.
4. **Type.** Choose display + text faces. Keep `text` highly legible; let `display` carry personality. Set display weight + tracking.
5. **Emit** the theme for each platform (see below) and register it.
6. **Verify** light + dark, LTR + RTL, contrast AA, dynamic text sizes. Compare against the live reference.

## Emitting a theme

**CSS / web** — add a block to `themes.css`:
```css
[data-theme="marsa"]{ --md-sys-color-primary: oklch(.5 .14 24); /* …all roles… */
  --npt-font-display:'Sora'; --npt-font-text:'Hanken Grotesk';
  --npt-corner-xs:6px; /* …md/lg/xl… */ }
[data-theme="marsa"][data-mode="dark"]{ /* dark role overrides */ }
```
Switch by setting `data-theme` / `data-mode` / `dir` on a wrapper (or `<html>`).

**Flutter** — emit a `ColorScheme` + shape/text overrides; see `docs/04-flutter-implementation.md`.

**tokens.json** — add a `themes.marsa` entry for codegen pipelines.

## Runtime switching
All three brands + both modes are swappable at runtime (the live file proves it). In production, resolve the bank theme at app launch (per build flavour or per login) and provide it through the theme provider — no rebuild of components required.

## RTL & Arabic

Banks are largely MENA, so **Arabic + RTL is first-class**, not an afterthought:

- **Direction.** Setting `dir="rtl"` mirrors every layout. Author with logical properties only (`inset-inline-start/end`, `margin-inline`, `padding-inline`, `start/end`) — never `left`/`right`. The back chevron, nav order, card chips and sheet all mirror automatically.
- **Arabic type per brand.** Each brand pairs its Latin display/text faces with an Arabic counterpart, swapped in by a single rule (`[data-theme][dir="rtl"]` remaps `--npt-font-display/text/num` to the `-ar` tokens). Neptune → IBM Plex Sans Arabic; Andalus → Reem Kufi + Tajawal (heritage); Nuran → Readex Pro (digital); FGLB → Noto Kufi Arabic (institutional). A bank's Arabic personality is as deliberate as its Latin one.
- **Content, not just layout.** UI strings resolve through a dir-aware label layer, so toggling language flips real Arabic copy (greetings, nav, actions, promos, settings, flows) — numerals stay Western, which is standard for Libyan banking.

Toggling EN ↔ عربي in Settings is the customer-level switch; it sets `dir` live and the whole app re-flows and re-types.

## Two layers of personalization

Neptune separates **bank** personalization from **customer** personalization — don't conflate them:

- **Bank (build/login time):** the theme — colour, shape, type, motion, signature motif, and merchandising content (the promo/ad cards). Resolved once per bank flavour; every customer of that bank inherits it.
- **Customer (runtime, in Settings):** appearance (light/dark), language/direction (EN ↔ عربي), notification & security prefs. These layer *on top of* the bank theme and persist per user — they never change the bank's identity, only the individual's comfort.

A bank theme decides what Andalus *is*; customer prefs decide how the customer *experiences* it.

## RTL
Banks are largely MENA. Author everything with logical directions (start/end, margin-inline, etc.). Mirror layouts, keep numerals/charts reading correctly, and test every screen in `dir="rtl"`.
