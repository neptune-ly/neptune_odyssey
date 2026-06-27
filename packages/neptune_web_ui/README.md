# @neptune.fintech/web-ui

Framework-agnostic **web kit** for [Neptune Odyssey](https://neptune.ly) — the white-label
banking design system by **Neptune.Fintech**. Standards-based custom elements, themed
entirely through **CSS variables** (zero runtime CSS-in-JS), with the one-call `applyTheme`
surface. Works with plain HTML, and is the layer the Svelte and Vue packages wrap.

> Source-available under the **Neptune Odyssey Community License v1.0** — free for
> non-commercial use and orgs under USD $25k/yr. See `LICENSE`.

## Install

```sh
pnpm add @neptune.fintech/web-ui @neptune.fintech/tokens
```

ESM-only, tree-shakeable, SSR-safe. Importing modules never touches the DOM; element
registration and theming run only when you call them.

## Use

```ts
import "@neptune.fintech/web-ui/styles.css"; // ships themes.css + system.css
import { applyTheme, registerAll } from "@neptune.fintech/web-ui";

registerAll();                                       // define the custom elements
applyTheme(document.documentElement, "triton", { mode: "system", dir: "auto" });
```

```html
<npt-app-bar title="Accounts"></npt-app-bar>
<npt-balance-card hero label="Available balance" amount="12,480.50" currency="LYD"
  account="•••• 4821"></npt-balance-card>
<npt-transaction-row title="Coffee" subtitle="Today · Card" amount="-4.50" currency="LYD">
</npt-transaction-row>
<npt-button variant="filled">New transfer</npt-button>
```

## Three ways to theme — one surface

```ts
applyTheme(root, "neptune");                                  // 1 · reference brand id
applyTheme(root, "NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA"); // 2 · brandprint string
applyTheme(root, { primary: {L,C,H}, tertiary: {…}, corners: {…}, … }); // 3 · config
```

For the four reference brands, re-skinning is **pure CSS** — `applyTheme` only sets
`data-theme`/`data-mode`/`dir`; the shipped `styles.css` holds every variable, so swapping
a brand is zero JavaScript. Custom configs and brandprints resolve through
`@neptune.fintech/tokens` and write the resolved variables onto the element.

## Components

A standards-based **Material 3** kit. Every element is themed only by CSS variables.

**Core & financial:** `npt-button` (filled / elevated / tonal / outlined / text) ·
`npt-card` (incl. `glass`) · `npt-balance-card` · `npt-transaction-row` · `npt-text-field` ·
`npt-badge`.

**Buttons & actions:** `npt-icon-button` (standard / filled / tonal / outlined, `[selected]`) ·
`npt-fab` (`sm`/`md`/`lg`, `[extended]`) · `npt-segmented-button` + `npt-segmented-option`.

**Selection controls:** `npt-checkbox` (`[indeterminate]`) · `npt-radio` (name/value group) ·
`npt-switch` · `npt-slider` (output bubble).

**Chips:** `npt-chip` with `variant="assist|filter|input|suggestion"` (filter check, input ✕).

**Communication & feedback:** `npt-progress` (linear / circular, `[indeterminate]`) ·
`npt-snackbar` · `npt-tooltip` · `npt-banner`.

**Containers & layout:** `npt-dialog` (scrim, ESC / backdrop close, focus-trap) ·
`npt-bottom-sheet` · `npt-list` + `npt-list-item` · `npt-divider` (`[inset]`) ·
`npt-tabs` + `npt-tab` · `npt-accordion` + `npt-accordion-item` · `npt-avatar` ·
`npt-menu` + `npt-menu-item`.

**Navigation:** `npt-app-bar` · `npt-top-app-bar` (`small`/`center`/`medium`/`large`) ·
`npt-nav-bar` · `npt-nav-rail` · `npt-nav-item`.

Every component reads **only** `var(--md-sys-color-*)` / `var(--npt-*)` — no literal color,
radius, or font anywhere (principle P2). Layout is logical (`*-inline-*`) so it mirrors in
RTL for free. Focus rings are visible; reduced-motion is honoured; targets are ≥ 48px.

---
© 2026 Neptune.Fintech. The bundled example brands are reference illustrations only.
