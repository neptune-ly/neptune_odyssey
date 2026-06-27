// Neptune Odyssey — @neptune.fintech/react-native-ui · © 2026 Neptune.Fintech (neptune.ly)
// Public surface: the theme provider + hook, pure style helpers, themed react-native
// components, and a re-export of the framework-agnostic token API so consumers don't
// need a second import. Licensed under the Neptune Odyssey Community License v1.0.

export { NeptuneProvider, useNeptuneTheme } from "./context.js";
export type { NeptuneProviderProps } from "./context.js";

export {
  radius,
  colorOf,
  makeThemedStyles,
  SPACE,
} from "./styles.js";
export type { ShapeKey, SpaceKey, ThemedStyles } from "./styles.js";

export { NeptuneText } from "./components/NeptuneText.js";
export type { NeptuneTextProps, NeptuneTextVariant } from "./components/NeptuneText.js";
export { NeptuneButton } from "./components/NeptuneButton.js";
export type { NeptuneButtonProps, NeptuneButtonVariant } from "./components/NeptuneButton.js";
export { NeptuneCard } from "./components/NeptuneCard.js";
export type { NeptuneCardProps } from "./components/NeptuneCard.js";
export { NeptuneBalanceCard } from "./components/NeptuneBalanceCard.js";
export type { NeptuneBalanceCardProps } from "./components/NeptuneBalanceCard.js";
export { NeptuneTransactionRow } from "./components/NeptuneTransactionRow.js";
export type { NeptuneTransactionRowProps } from "./components/NeptuneTransactionRow.js";

export { buildTheme, encode, decode, brandprintFor } from "@neptune.fintech/tokens";
export type {
  NeptuneTheme,
  ThemeInput,
  BrandprintConfig,
  Brand,
  Mode,
  Direction,
  ColorRole,
  Palette,
} from "@neptune.fintech/tokens";

export const REACT_NATIVE_UI_VERSION = "1.0.0";
