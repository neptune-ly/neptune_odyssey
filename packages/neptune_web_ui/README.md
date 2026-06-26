# @neptune-odyssey/web-ui

Framework-agnostic **web kit** for [Neptune Odyssey](https://neptune.ly) — the white-label
banking design system by **Neptune.Fintech**. Standards-based custom elements, themed
entirely through **CSS variables** (zero runtime CSS-in-JS), with the one-call `applyTheme`
surface. Works with plain HTML, and is the layer the Svelte and Vue packages wrap.

> Source-available under the **Neptune Odyssey Community License v1.0** — free for
> non-commercial use and orgs under USD $25k/yr. See `LICENSE`.

## Install

```sh
pnpm add @neptune-odyssey/web-ui @neptune-odyssey/tokens
```

ESM-only, tree-shakeable, SSR-safe. Importing modules never touches the DOM; element
registration and theming run only when you call them.

## Use

```ts
import "@neptune-odyssey/web-ui/styles.css"; // ships themes.css + system.css
import { applyTheme, registerAll } from "@neptune-odyssey/web-ui";

registerAll();                                       // define the custom elements
applyTheme(document.documentElement, "andalus", { mode: "system", dir: "auto" });
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
`@neptune-odyssey/tokens` and write the resolved variables onto the element.

## Components

`npt-button` · `npt-card` (incl. `glass`) · `npt-balance-card` · `npt-transaction-row` ·
`npt-text-field` · `npt-chip` · `npt-badge` · `npt-app-bar` · `npt-nav-bar` / `npt-nav-item`.

Every component reads **only** `var(--md-sys-color-*)` / `var(--npt-*)` — no literal color,
radius, or font anywhere (principle P2). Layout is logical (`*-inline-*`) so it mirrors in
RTL for free. Focus rings are visible; reduced-motion is honoured; targets are ≥ 48px.

---
© 2026 Neptune.Fintech. The bundled example brands are reference illustrations only.
