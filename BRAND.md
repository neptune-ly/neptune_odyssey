# Neptune.Fintech — Brand

Neptune Odyssey is the design system **by Neptune.Fintech** (Financial Technology & Solutions,
[neptune.ly](https://neptune.ly)). This file records the official Neptune corporate identity used
for the project's own chrome (the site, the configurator, attribution) — distinct from the four
**reference tenant themes** (neptune/andalus/nuran/fglb) that the design system ships to demonstrate
white-labelling. Those reference brands are illustrations only.

> Source of truth: the Neptune Brand Identity Guidelines (2026). This is a summary for engineering;
> the full guideline (logo construction, clear space, incorrect usage, applications) lives with the
> brand team.

## Logo

The wordmark **“Neptune”** in navy, followed by the signature **coral dot** — `Neptune•`. Tagline:
*Financial Technology And Solutions*. An Arabic lockup exists (**نبتون•**, *لتكنولوجيا والحلول المالية*).

- Primary lockup: navy wordmark + coral dot on light backgrounds.
- Reversed: white wordmark + coral dot on navy/dark backgrounds.
- The coral dot is the minimal mark (see `site/assets/favicon.svg`).
- Don't recolour the wordmark outside navy/white, distort proportions, add effects, or drop the dot.

## Colours

**Primary**

| Name | HEX |
|------|-----|
| Coral | `#EB4E4D` |
| Teal  | `#00A8AE` |
| Navy Blue | `#07315F` |
| Sand  | `#F0CE9D` |
| Sky Blue | `#3BC1EE` |

**Secondary / neutral**

| Name | HEX |
|------|-----|
| Grey | `#898989` |
| Slate | `#3A4F54` |
| Mist | `#D3D3D3` |

Navy is the anchor; coral is the accent (CTAs, the dot, highlights); teal/sky/sand support.

## Typography

- **English:** SF Compact Rounded (Apple system rounded). Web fallback: `ui-rounded` → **Baloo 2**
  (Google Fonts) → Hanken Grotesk. Used for the logo and display headings.
- **Arabic:** **Beiruti** (Google Fonts).
- Body/UI on the project site uses **Hanken Grotesk** (also the Neptune reference theme's text face).

## Usage in this repo

- The landing (`site/index.html`) and the configurator chrome use the official navy/coral palette and
  the `Neptune•` logo. The favicon (`site/assets/favicon.svg`) is the navy mark with the coral dot.
- The live references (`system.html` / `banking.html` / `wallet.html`) show the **design-system**
  themes (the four reference brands), not the corporate brand — that's the point of a white-label
  system: the company brand and the product skins are separate layers.

---
© 2026 Neptune.Fintech. “Neptune”, “Neptune.Fintech” and the Neptune logo are marks of Neptune.Fintech.
