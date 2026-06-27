# @neptune.fintech/react-native-ui

React Native layer for [Neptune Odyssey](https://neptune.ly) by **Neptune.Fintech** — a
`<NeptuneProvider>`, a `useNeptuneTheme` hook, and a small set of themed components built
from React Native primitives (`View` / `Text` / `Pressable` / `StyleSheet`).

React Native has no DOM, CSS variables, or custom elements, so — unlike the web layers —
this package resolves a plain `NeptuneTheme` object from `@neptune.fintech/tokens`
`buildTheme()` and provides it through React context. Components read every color, radius,
and font from that theme. Same brandprint ⇒ same theme, on every platform.

> Source-available under the **Neptune Odyssey Community License v1.0** (see `LICENSE`).

## Install

```sh
npm i @neptune.fintech/react-native-ui react react-native
```

`react` and `react-native` are **peer dependencies** — bring your own.

## Theme three ways

`input` accepts any of the three Neptune Odyssey entry points:

1. a **reference brand id** — `"neptune" | "andalus" | "nuran" | "fglb"`
2. a **config object** — a full `BrandprintConfig`
3. a **brandprint string** — `"NO1-…"`

## Use

```tsx
import {
  NeptuneProvider,
  NeptuneBalanceCard,
  NeptuneButton,
  NeptuneTransactionRow,
  NeptuneText,
} from "@neptune.fintech/react-native-ui";

export function App() {
  return (
    <NeptuneProvider input="andalus" mode="light" dir="ltr">
      <NeptuneBalanceCard label="Available balance" amount="12,480.50" currency="LYD" />
      <NeptuneButton variant="filled" label="New transfer" onPress={() => {}} />
      <NeptuneText variant="title">Recent activity</NeptuneText>
      <NeptuneTransactionRow title="Coffee" subtitle="Today" amount="-3.50" />
      <NeptuneTransactionRow title="Salary" subtitle="Jun 27" amount="+1,200.00" credit />
    </NeptuneProvider>
  );
}
```

### Read the theme yourself

```tsx
import { useNeptuneTheme, radius, colorOf } from "@neptune.fintech/react-native-ui";
import { View } from "react-native";

function Panel() {
  const theme = useNeptuneTheme();
  return (
    <View
      style={{
        backgroundColor: colorOf(theme, "surface-container"),
        borderRadius: radius(theme, "lg"),
      }}
    />
  );
}
```

`useNeptuneTheme()` throws if called outside a `<NeptuneProvider>`.

### Brandprint

```tsx
<NeptuneProvider input="NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA" mode="dark" dir="rtl">
  <App />
</NeptuneProvider>
```

`mode` is `light | dark`; `dir` is `ltr | rtl`. Logical spacing (`marginStart/End`,
`writingDirection`) means components mirror correctly under RTL.

---
© 2026 Neptune.Fintech. The bundled example brands are reference illustrations only.
