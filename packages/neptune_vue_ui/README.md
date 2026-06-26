# @neptune-odyssey/vue-ui

Vue 3 layer for [Neptune Odyssey](https://neptune.ly) by **Neptune.Fintech** — typed
component wrappers, a `<NeptuneProvider>`, and a `useNeptuneTheme` composable over the
framework-agnostic `@neptune-odyssey/web-ui` custom-element core.

> Source-available under the **Neptune Odyssey Community License v1.0** (see `LICENSE`).

## Install

```sh
pnpm add @neptune-odyssey/vue-ui vue
```

Tell Vue that `npt-*` tags are custom elements (so it doesn't try to resolve them):

```ts
// vite.config.ts
vue({ template: { compilerOptions: { isCustomElement: (t) => t.startsWith("npt-") } } });
```

## Use

```vue
<script setup lang="ts">
import "@neptune-odyssey/vue-ui/styles.css";
import { NeptuneProvider, NptBalanceCard, NptButton } from "@neptune-odyssey/vue-ui";
</script>

<template>
  <NeptuneProvider theme="andalus" mode="system" dir="auto">
    <NptBalanceCard hero label="Available balance" amount="12,480.50" currency="LYD" />
    <NptButton variant="filled">New transfer</NptButton>
  </NeptuneProvider>
</template>
```

`theme` accepts a **reference brand id**, a **config object**, or a **brandprint string** —
same surface everywhere. `mode` is `light|dark|system`; `dir` is `ltr|rtl|auto`.

---
© 2026 Neptune.Fintech. The bundled example brands are reference illustrations only.
