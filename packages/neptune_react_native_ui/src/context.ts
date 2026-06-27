// Neptune Odyssey — @neptune.fintech/react-native-ui · © 2026 Neptune.Fintech (neptune.ly)
// The theme provider + hook. React Native has no DOM, no CSS variables, and no custom
// elements, so — unlike the web layer — there is nothing to "apply" to a root element.
// Instead we resolve a plain `NeptuneTheme` object via `buildTheme()` and hand it down
// through React context; themed components read it with `useNeptuneTheme()`.
//
// This file imports React ONLY (never `react-native`), so it stays unit-testable in a
// plain node environment. Licensed under the Neptune Odyssey Community License v1.0.

import { createContext, createElement, useContext, useMemo } from "react";
import type { ReactNode } from "react";
import {
  buildTheme,
  type NeptuneTheme,
  type ThemeInput,
  type Mode,
  type Direction,
} from "@neptune.fintech/tokens";

const NeptuneThemeContext = createContext<NeptuneTheme | null>(null);
NeptuneThemeContext.displayName = "NeptuneThemeContext";

export interface NeptuneProviderProps {
  /** Reference brand id, a full config object, or a `NO1-…` brandprint string. */
  input: ThemeInput;
  mode?: Mode;
  dir?: Direction;
  children?: ReactNode;
}

/** Stable identity for a theme input, used to memoize `buildTheme`. */
function themeKey(input: ThemeInput): string {
  return typeof input === "string" ? input : JSON.stringify(input);
}

/**
 * Resolve a theme from any of the three inputs and provide it to descendants.
 *
 * @example
 * <NeptuneProvider input="andalus" mode="light" dir="ltr">
 *   <App />
 * </NeptuneProvider>
 */
export function NeptuneProvider({
  input,
  mode,
  dir,
  children,
}: NeptuneProviderProps): ReactNode {
  const theme = useMemo(
    () => buildTheme(input, { mode, dir }),
    // input is tracked by its stable key; mode/dir are primitives.
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [themeKey(input), mode, dir],
  );
  return createElement(NeptuneThemeContext.Provider, { value: theme }, children);
}

/**
 * Read the resolved `NeptuneTheme` from the nearest `<NeptuneProvider>`.
 * Throws if used outside a provider so misuse fails loudly in development.
 */
export function useNeptuneTheme(): NeptuneTheme {
  const theme = useContext(NeptuneThemeContext);
  if (theme === null) {
    throw new Error(
      "useNeptuneTheme() must be used within a <NeptuneProvider>. " +
        "Wrap your app (or the themed subtree) in <NeptuneProvider input=… />.",
    );
  }
  return theme;
}
