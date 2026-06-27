# {{PROJECT_TITLE}}

A [Neptune Odyssey](https://neptune-ly.github.io/neptune_odyssey/) starter — **React** (Vite), themed with the **{{BRAND}}** brand.

## Run

```bash
npm install
npm run dev
```

## How it's wired

`src/App.tsx`:

```tsx
import { NeptuneProvider } from "@neptune.fintech/react-ui";

<NeptuneProvider theme="{{BRAND}}" mode="{{MODE}}" dir="{{DIR}}">
  <Dashboard />
</NeptuneProvider>
```

- **Provider** — `<NeptuneProvider>` registers the `npt-*` custom elements and applies the
  theme (CSS variables) to its wrapper. Swap `theme` for `neptune` / `triton` / `nereid` /
  `proteus`, or a `NO1-…` brandprint from the
  [theme builder](https://neptune-ly.github.io/neptune_odyssey/apps/configurator/).
- **Components** — `src/Dashboard.tsx` uses the typed wrappers (`NptBalanceCard`,
  `NptTransactionRow`, `NptCard`, `NptButton`, `NptNavBar`) plus a few raw `npt-*` tags
  (`npt-stat-card`, `npt-quick-actions`, `npt-icon`) enabled by `src/neptune.d.ts`.
- **Icons** — `registerIcons()` in `src/main.tsx` defines `<npt-icon>`.

Browse every component in the [gallery](https://neptune-ly.github.io/neptune_odyssey/components.html).

© {{YEAR}} — built on Neptune Odyssey by Neptune.Fintech.
