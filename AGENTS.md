# AGENTS.md — implementing Neptune Odyssey

You are turning **Neptune Odyssey** (the Neptune.Fintech white-label banking design system) into a real product (Flutter app, web app, or another surface). Read this before writing code.

## Mental model

```
seed colour (per brand)  ─┐
corner family (per brand) ├─►  THEME  ─►  applied to  ─►  shared COMPONENTS  ─►  shared SCREENS
display type (per brand)  ─┘                                  (never brand-aware)
```

- A **theme** is data: a colour scheme (M3 roles), a shape scale, a type set, motion tokens.
- A **component** reads the active theme. It contains *zero* brand knowledge.
- A **screen** composes components. Switching a bank changes only the theme object passed in.

If a bank wants to look different, that is a theme change — not a component fork.

## Source of truth

1. `tokens/themes.css` — exact values for every `--md-sys-color-*`, corner and font, per brand (neptune/triton/nereid/proteus), light + dark.
2. `tokens/tokens.json` — same data, structured for codegen.
3. `Neptune Design System.dc.html` (mobile), `Neptune Web Banking.dc.html` (web), `Neptune Wallet Web.dc.html` (wallet) — the visual contract. If your build doesn't match them, your build is wrong.
4. `configs/*.tenant.json` — the five reference tenants. A bank is one config set, never a fork.
5. `docs/07-design-principles.md`, `docs/09-governance-and-versioning.md`, `docs/10-token-naming.md` — the doctrine, the versioning gate, the token contract.

## Workflow to add or port a theme

1. Take the brand's seed hue(s) → generate the full M3 tonal palette (see `docs/03-theming-white-label.md`).
2. Pick the corner family and display typeface.
3. Emit a theme object for your platform (Flutter `ColorScheme` + `ThemeData`; CSS attribute block; etc.).
4. Verify light **and** dark, LTR **and** RTL. Check contrast (≥ 4.5:1 body, ≥ 3:1 large/UI).
5. Do not touch any component or screen code.

## Hard rules

- **No literals in components.** Colour → `colorScheme.*`. Radius → shape token. Font → text theme. Spacing → 4px scale.
- **Directional-agnostic.** Use start/end, not left/right. Test RTL.
- **Both modes.** Every screen must be designed and tested in light and dark.
- **Accessibility is not optional.** Hit targets ≥ 48dp. Respect text scaling. Meet WCAG AA.
- **Stay on Material 3.** Extend via theme + Expressive guidance; don't build a parallel kit.
- **Tokens are the public API.** Every visual change is a token change first; components inherit. A token rename is a breaking change (semver) — see `docs/09-governance-and-versioning.md`.
- **Each brand moves ≥ 6 of 12 levers.** Same skeleton, unmistakable skin.

## Platform notes

- **Flutter** (production mobile): `docs/04-flutter-implementation.md`. Use `ThemeData(useMaterial3: true)`, drive everything from `ColorScheme.fromSeed` + overrides, expose brand swap as a `ThemeData` provider.
- **Web**: load `tokens/themes.css`, set `data-theme` / `data-mode` / `dir` on `<html>`, style from the custom properties.
- **Other (DTCG / Style Dictionary)**: consume `tokens/tokens.json`.
