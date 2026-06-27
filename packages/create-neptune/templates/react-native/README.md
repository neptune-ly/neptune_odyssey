# {{PROJECT_TITLE}}

A [Neptune Odyssey](https://neptune-ly.github.io/neptune_odyssey/) starter — **React Native** (Expo), themed with the **{{BRAND}}** brand.

## Run

```bash
npm install
npm run start      # then press i (iOS), a (Android), or w (web)
```

## How it's wired

`App.tsx`:

```tsx
import { NeptuneProvider } from "@neptune.fintech/react-native-ui";

<NeptuneProvider input="{{BRAND}}" mode="{{MODE}}" dir="{{DIR}}">
  <Dashboard />
</NeptuneProvider>
```

- **Provider** — `<NeptuneProvider input=…>` resolves a theme and provides it through React
  context. Read it anywhere with `useNeptuneTheme()`. Swap `input` for `neptune` / `triton`
  / `nereid` / `proteus`, or a `NO1-…` brandprint from the
  [theme builder](https://neptune-ly.github.io/neptune_odyssey/apps/configurator/).
- **Components** — `src/Dashboard.tsx` uses `NeptuneBalanceCard`, `NeptuneTransactionRow`,
  `NeptuneCard`, `NeptuneText` and `NeptuneButton` — all native, no web view.
- **Tokens** — colours come from `useNeptuneTheme().colors`; no literal palette.

> The same brandprint renders byte-identically here and on web/Flutter.

© {{YEAR}} — built on Neptune Odyssey by Neptune.Fintech.
