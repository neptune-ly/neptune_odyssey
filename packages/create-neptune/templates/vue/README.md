# {{PROJECT_TITLE}}

A [Neptune Odyssey](https://neptune-ly.github.io/neptune_odyssey/) starter — **Vue 3** (Vite), themed with the **{{BRAND}}** brand.

## Run

```bash
npm install
npm run dev
```

## How it's wired

`src/App.vue`:

```vue
<script setup lang="ts">
import { NeptuneProvider } from "@neptune.fintech/vue-ui";
</script>

<template>
  <NeptuneProvider theme="{{BRAND}}" mode="{{MODE}}" dir="{{DIR}}">
    <Dashboard />
  </NeptuneProvider>
</template>
```

- **Provider** — `<NeptuneProvider>` registers the `npt-*` custom elements and applies the
  theme to its wrapper. `vite.config.ts` already tells Vue that `npt-*` are custom elements.
- **Theme** — swap `theme` for `neptune` / `triton` / `nereid` / `proteus`, or a `NO1-…`
  brandprint from the
  [theme builder](https://neptune-ly.github.io/neptune_odyssey/apps/configurator/).
- **Components** — `src/Dashboard.vue` uses `<npt-balance-card>`, `<npt-stat-card>`,
  `<npt-transaction-row>`, `<npt-quick-actions>`, `<npt-nav-bar>` and `<npt-icon>`.

Browse every component in the [gallery](https://neptune-ly.github.io/neptune_odyssey/components.html).

© {{YEAR}} — built on Neptune Odyssey by Neptune.Fintech.
