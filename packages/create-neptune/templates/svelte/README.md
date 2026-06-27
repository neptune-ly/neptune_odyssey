# {{PROJECT_TITLE}}

A [Neptune Odyssey](https://neptune-ly.github.io/neptune_odyssey/) starter — **Svelte 5** (Vite), themed with the **{{BRAND}}** brand.

## Run

```bash
npm install
npm run dev
```

## How it's wired

`src/App.svelte`:

```svelte
<script lang="ts">
  import { theme } from "@neptune.fintech/svelte-ui";
</script>

<div use:theme={{ input: "{{BRAND}}", mode: "{{MODE}}", dir: "{{DIR}}" }}>
  <Dashboard />
</div>
```

- **Theme action** — `use:theme` registers the `npt-*` custom elements and applies the
  theme to the node. Swap `input` for `neptune` / `triton` / `nereid` / `proteus`, or a
  `NO1-…` brandprint from the
  [theme builder](https://neptune-ly.github.io/neptune_odyssey/apps/configurator/).
- **Components** — `src/Dashboard.svelte` uses `<npt-balance-card>`, `<npt-stat-card>`,
  `<npt-transaction-row>`, `<npt-quick-actions>`, `<npt-nav-bar>` and `<npt-icon>`.
- **Type-check** — `npm run check` runs `svelte-check`.

Browse every component in the [gallery](https://neptune-ly.github.io/neptune_odyssey/components.html).

© {{YEAR}} — built on Neptune Odyssey by Neptune.Fintech.
