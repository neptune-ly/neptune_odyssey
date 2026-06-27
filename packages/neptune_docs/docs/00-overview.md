# Neptune Odyssey

**A white-label financial design system by Neptune.Fintech.**
One Material 3 Expressive foundation that ships mobile banking, wallets, and retail & corporate internet banking for many banks — each wearing its own brand, all sharing one structure, one accessibility contract, and one engineering model.

> **M3 Expressive foundation · Neptune signature · institution-specific identity · one system, many products.**

A customer must never feel *"this is the same app with a different logo."* They must feel *"this is **my** bank — and it's excellent."* Odyssey engineers that feeling instead of hoping for it.

---

## What Odyssey is

- **A token system**, not a skin. Six layers — primitive → semantic → component → brand → product → platform — with `themes.css` (per-brand color/shape/type/motif) and `system.css` (motion, elevation, spacing, type scale, state, focus, z-index) as the source of truth.
- **A component contract.** Anatomy, states, a11y, RTL and responsive behavior are defined once and shared by every tenant. Components carry **zero** brand knowledge.
- **A product model.** Banking ≠ Wallet. Retail ≠ Corporate. Web is a sibling of mobile, not a stretch of it. Each is a distinct, intentional information architecture.
- **A white-label machine.** A new bank is one tenant config set (`configs/*.tenant.json`) — no forks. The same-but-distinct rule (≥6 of 12 brand levers) guarantees each bank looks genuinely its own.

## Principles

1. **Clarity is the brand.** One primary action per view. No redundant affordances, no data echoed twice, no decoration that doesn't carry meaning.
2. **Everything is a token.** No literal color, radius, spacing, type size, shadow, or motion in a component. If you typed a hex or a `px` shadow inside a widget, it belongs in a theme.
3. **Same structure, distinct skin.** Shared: anatomy, a11y, interaction, security, layout logic, RTL. Per-brand: palette, shape, type feel, motif, card art, login world, motion personality, dashboard hero, content tone.
4. **Expressive, but controlled.** M3 Expressive shows up as confident color, strong hierarchy, larger hero moments, shape contrast and motion that *confirms* — never as a default Material template, never as motion that slows a banking task.
5. **Arabic and dark are first-class.** Designed, not auto-flipped. Logical properties only. Per-brand Arabic typefaces. Every screen ships light + dark, LTR + RTL.
6. **Accessibility is a gate, not a polish.** WCAG AA contrast, visible keyboard focus, ≥48dp targets, reduced-motion paths, screen-reader labels. A screen that fails these is unfinished.
7. **Glass is a material, not the language.** Functional translucency on nav, command bars, hero cards and high-priority sheets only — never on tables, forms, reports, or anywhere clarity suffers.

## The four reference brands

| Brand | Personality | Color | Shape | Display type | Motif |
|---|---|---|---|---|---|
| **Neptune** | oceanic, premium, calm | signal blue + aqua | soft 16px | Hanken Grotesk | sonar tide-rings |
| **Triton** | warm, fresh, coastal | emerald + gold | organic 26px | Bricolage Grotesque | soft arc rings |
| **Nereid** | digital, youthful, luminous | violet + rose | crisp 12px | Space Grotesk | light-grid spark |
| **Proteus** | institutional, secure, stable | navy + gold | structured 14px | Sora | shield guilloché |

Each moves **≥6 of the 12 brand levers** (color · shape · type · logo · motif · card art · illustration · motion · login world · dashboard hero · nav accent · content tone). Color-only customization cannot ship.

## What's in the box

```
tokens/
  themes.css          per-brand color · shape · type · motif (light + dark, LTR/RTL)
  system.css          motion · elevation · spacing · type scale · state · focus · z
  tokens.json         machine-readable export for Style Dictionary / codegen
configs/
  *.tenant.json       5 reference tenants (the white-label config model, 8 layers)
  tenants.js          runtime registry + live theme loader
docs/
  00 overview         this file
  01 foundations · 02 components · 03 theming · 04 flutter · 05 brand & platforms
  06 platform plan    the governing document (vision, config model, corporate, QA)
  07 design review    honest, Apple/Google-bar critique + remediation
living references (interactive, re-skin live):
  Neptune Design System.dc.html    mobile — banking + wallet
  Neptune Web Banking.dc.html      web — retail + corporate internet banking
  Neptune Wallet Web.dc.html       web — payment-led wallet
```

## Platforms

- **Flutter** (production mobile) — `ThemeData(useMaterial3:true)` + per-brand `ColorScheme` + `ThemeExtension`s for shape, motif, success and glass. See `docs/04`.
- **Web** — load `themes.css` + `system.css`, set `data-theme` / `data-mode` / `dir`, style from custom properties. The `.dc.html` references are the visual contract.
- **Tokens** — consume `tokens.json` (DTCG-ish) for Style Dictionary, Figma variables, or your own pipeline.

## Versioning & release

Semantic versioning. **`themes.css` + `system.css` + `tokens.json` are the contract** — a change to a token's *meaning* is a major bump; a new tenant or additive token is a minor; value tuning within a role is a patch. Tenants pin a major. This file tracks **1.0** — production-grade, four reference brands, web + mobile, five reference tenants.

## Licensing

Proprietary to **Neptune.Fintech**. Licensed per institution as part of a Neptune platform deployment. Brand assets (logos, wordmarks, card art) are owned by their respective institutions; the system, tokens and components are Neptune's.

---

*Odyssey references Apple for premium translucency and Google's Material 3 for system architecture — and copies neither. The maturity markers we hold ourselves to are theirs: obsessive spacing rhythm, real empty/loading/error states, motion that confirms rather than decorates, and a config model that scales to many banks without looking sold many times.*
