# @neptune.fintech/svelte-ui

Svelte layer for [Neptune Odyssey](https://neptune.ly) by **Neptune.Fintech** — a
`use:theme` action, a `<NeptuneProvider>` component, and theming re-exports over the
framework-agnostic `@neptune.fintech/web-ui` custom-element core. Svelte renders the
`<npt-*>` elements natively, so this layer stays thin.

> Source-available under the **Neptune Odyssey Community License v1.0** (see `LICENSE`).

## Install

```sh
pnpm add @neptune.fintech/svelte-ui svelte
```

## Use

```svelte
<script lang="ts">
  import "@neptune.fintech/svelte-ui/styles.css";
  import { theme } from "@neptune.fintech/svelte-ui";
</script>

<div use:theme={{ input: "triton", mode: "system", dir: "auto" }}>
  <npt-balance-card hero label="Available balance" amount="12,480.50" currency="LYD" />
  <npt-button variant="filled">New transfer</npt-button>
</div>
```

Or with the provider component:

```svelte
<script lang="ts">
  import NeptuneProvider from "@neptune.fintech/svelte-ui/NeptuneProvider.svelte";
</script>

<NeptuneProvider input="NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA">
  <npt-app-bar title="Accounts"></npt-app-bar>
</NeptuneProvider>
```

`input` accepts a **reference brand id**, a **config object**, or a **brandprint string**.

---
© 2026 Neptune.Fintech. The bundled example brands are reference illustrations only.
