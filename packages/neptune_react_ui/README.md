# @neptune-odyssey/react-ui

React layer for [Neptune Odyssey](https://neptune.ly) by **Neptune.Fintech** — typed
component wrappers, a `<NeptuneProvider>`, and a `useNeptuneTheme` hook over the
framework-agnostic `@neptune-odyssey/web-ui` custom-element core.

> Source-available under the **Neptune Odyssey Community License v1.0** (see `LICENSE`).

## Install

```sh
pnpm add @neptune-odyssey/react-ui react
```

The `npt-*` tags are standards-based custom elements — React 18.3+ / 19 forwards unknown
props straight through to attributes, so no compiler or bundler config is needed.

## Use

```tsx
import "@neptune-odyssey/react-ui/styles.css";
import { NeptuneProvider, NptBalanceCard, NptButton } from "@neptune-odyssey/react-ui";

export function App() {
  return (
    <NeptuneProvider theme="andalus" mode="system" dir="auto">
      <NptBalanceCard hero label="Available balance" amount="12,480.50" currency="LYD" />
      <NptButton variant="filled">New transfer</NptButton>
    </NeptuneProvider>
  );
}
```

`theme` accepts a **reference brand id**, a **config object**, or a **brandprint string** —
the same surface as every other Neptune Odyssey framework layer. `mode` is `light|dark|system`;
`dir` is `ltr|rtl|auto`. Same brandprint ⇒ same theme, on every platform.

### Theme any subtree with the hook

```tsx
import { useNeptuneTheme } from "@neptune-odyssey/react-ui";

function Statement() {
  const ref = useNeptuneTheme("NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA", { mode: "dark" });
  return <section ref={ref}>…</section>;
}
```

---
© 2026 Neptune.Fintech. The bundled example brands are reference illustrations only.
