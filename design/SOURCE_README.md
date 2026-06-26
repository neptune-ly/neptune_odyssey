# Neptune Odyssey

**A white-label banking design system by [Neptune.Fintech](https://neptune.fintech).**
One Material 3 + Material 3 Expressive foundation that any bank can wear as its own — colour, shape, type, motion and brand expression all flex to the brand, while structure, accessibility and engineering stay identical.

`v1.0.0 · Stable`

---

## The one rule that matters

> **Structure is shared; skin is per-brand.** A component built once is correct for every bank, in every mode, in both directions. If a bank wants to look different, that's a *theme* — never a fork.

## Brands

Four reference brands ship in the box, each moving **≥ 6 of 12** brand levers (the same-but-distinct rule):

| Brand | Personality | Signature |
|-------|-------------|-----------|
| **Neptune** | Platform core | Signal blue · soft 16px corners · Hanken Grotesk · sonar tide-rings |
| **Andalus Bank** | Heritage · Islamic retail | Emerald + gold · organic 26px corners · Bricolage Grotesque · arcade of arches |
| **Nuran** | Digital-first | Violet + rose · crisp 12px corners · Space Grotesk · digital light-grid |
| **FGLB** | Premium · Gulf | Navy + gold · structured 14px corners · Sora · secure guilloché |

A new bank is **one tenant config set**, never a fork. See `configs/`.

## What's here

| Path | What it is |
|------|------------|
| `Neptune Design System.dc.html` | The living mobile reference. Switch brand / mode / direction and the whole system re-skins. **Open this first.** |
| `Neptune Web Banking.dc.html` | Living web reference — retail + corporate internet banking. |
| `Neptune Wallet Web.dc.html` | Living web reference — payment-led wallet (a sibling product, not relabeled banking). |
| `tokens/themes.css` | The theme token layer — every `--md-sys-color-*`, shape and type token, per brand, light + dark. Source of truth for values. |
| `tokens/tokens.json` | Machine-readable token export for codegen / Style Dictionary. |
| `configs/*.tenant.json` | Five reference tenant configs (Neptune Retail/Corporate, Andalus Retail, Nuran Wallet, FGLB Retail) + a live theme loader (`tenants.js`). |
| `tools/brandprint.js` | The **brandprint** codec — a deterministic `NO1-…` theme string (pick levers → string → identical theme anywhere). See `docs/11`. |
| `build/` | Generated token output — `tokens.resolved.json` (OKLCH→hex/ARGB) + Flutter `ColorScheme`s / `ThemeExtension`s. |
| `HANDOFF_PROMPT.md` | The full build brief for Claude Code (libraries, frameworks, configurator, publish). |
| `LICENSE` | Neptune Odyssey Community License — free for non-commercial + orgs under USD $25k/yr. |
| `docs/` | The written system (see below). |
| `AGENTS.md` | Operating guide for AI agents implementing the system. |

## Docs

| # | Doc |
|---|-----|
| 00 | *(this README is the front door)* |
| 01 | `01-foundations.md` — colour, type, shape, elevation, spacing, motion, motif |
| 02 | `02-components.md` — component anatomy + state specs |
| 03 | `03-theming-white-label.md` — how to add a bank theme (the core playbook) |
| 04 | `04-flutter-implementation.md` — mapping tokens & components to Flutter (production stack) |
| 05 | `05-brand-identity-and-platforms.md` — brand levers + platform plan |
| 06 | `06-platform-plan.md` — **the governing plan.** Read this first for the system shape. |
| 07 | `07-design-principles.md` — the six principles |
| 08 | `08-accessibility.md` — the AA-floor checklist |
| 09 | `09-governance-and-versioning.md` — semver, component status, the tokens-first gate |
| 10 | `10-token-naming.md` — the token naming contract |
| 11 | `11-config-hash.md` — the **brandprint** (config-hash) format + determinism contract |

## Start here

1. Open `Neptune Design System.dc.html` and switch brands/modes/direction.
2. Read `docs/06-platform-plan.md` for the system shape, then `07` for the principles.
3. To build: hand `docs/04-flutter-implementation.md` + `tokens/tokens.json` to your devs (or Claude Code) to scaffold the Flutter library; generate the web kit from `tokens/themes.css`.
4. To onboard a bank: author one tenant config in `configs/` — no forks.

## Constraints

- Production mobile stack is **Flutter** (Material 3). Web app is separate but consumes the same tokens.
- Supports **light + dark** and **LTR + RTL** (banks are largely MENA — logical/directional properties only).
- Colours authored in **OKLCH**; convert to hex/ARGB at build time.
- Built on Material 3; adopt M3 Expressive shape/motion/emphasis — never a parallel component model.

---

© 2026 Neptune.Fintech — licensed to Neptune partner banks.
