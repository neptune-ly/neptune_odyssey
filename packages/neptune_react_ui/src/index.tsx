// Neptune Odyssey — @neptune.fintech/react-ui · © 2026 Neptune.Fintech (neptune.ly)
// A thin React layer over @neptune.fintech/web-ui: the custom elements do the
// rendering (themed by CSS variables); React adds typed wrappers, a provider, and a
// hook. Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// The npt-* tags are standard custom elements — React (18.3+/19) forwards unknown
// props straight through to attributes, so no compiler config is needed.

import { createElement, forwardRef, useEffect, useRef } from "react";
import type { HTMLAttributes, ReactNode, RefObject } from "react";
import {
  applyTheme,
  registerAll,
  type ThemeInput,
  type ModeOption,
  type DirOption,
} from "@neptune.fintech/web-ui";

export interface NeptuneThemeOptions {
  mode?: ModeOption;
  dir?: DirOption;
}

/** A theme is identified for effect-deps by its brand id, or by a stable hash of the config/brandprint. */
function themeKey(input: ThemeInput): string {
  return typeof input === "string" ? input : JSON.stringify(input);
}

/**
 * Apply a theme to an element ref (or the document root) reactively.
 *
 * @example
 * const ref = useNeptuneTheme("andalus", { mode: "system", dir: "auto" });
 * return <main ref={ref}>…</main>;
 */
export function useNeptuneTheme<T extends HTMLElement = HTMLElement>(
  input: ThemeInput,
  options: NeptuneThemeOptions = {},
): RefObject<T | null> {
  const ref = useRef<T | null>(null);
  const { mode, dir } = options;
  useEffect(() => {
    registerAll();
    const el = ref.current ?? (typeof document !== "undefined" ? document.documentElement : null);
    if (!el) return;
    const handle = applyTheme(el, input, { mode, dir });
    return () => handle.dispose();
    // input is tracked by its stable key; mode/dir are primitives.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [themeKey(input), mode, dir]);
  return ref;
}

export interface NeptuneProviderProps {
  /** Reference brand id, a full config object, or a `NO1-…` brandprint string. */
  theme: ThemeInput;
  mode?: ModeOption;
  dir?: DirOption;
  className?: string;
  children?: ReactNode;
}

/**
 * <NeptuneProvider theme="andalus" mode="system" dir="auto"> … </NeptuneProvider>
 * Wraps its children in a themed <div> and registers the custom elements on mount.
 */
export const NeptuneProvider = forwardRef<HTMLDivElement, NeptuneProviderProps>(
  function NeptuneProvider({ theme, mode, dir, className, children }, forwardedRef) {
    const innerRef = useRef<HTMLDivElement | null>(null);
    useEffect(() => {
      registerAll();
      const el = innerRef.current;
      if (!el) return;
      const handle = applyTheme(el, theme, { mode, dir });
      return () => handle.dispose();
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [themeKey(theme), mode, dir]);

    const setRefs = (el: HTMLDivElement | null) => {
      innerRef.current = el;
      if (typeof forwardedRef === "function") forwardedRef(el);
      else if (forwardedRef) forwardedRef.current = el;
    };

    return createElement(
      "div",
      { className: ["neptune-provider", className].filter(Boolean).join(" "), ref: setRefs },
      children,
    );
  },
);
NeptuneProvider.displayName = "NeptuneProvider";

/** Props for a wrapper: any DOM attribute passes straight through to the custom element. */
export type NptElementProps = HTMLAttributes<HTMLElement> & Record<string, unknown>;

/** Typed thin wrappers — attributes pass straight through to the custom element. */
function passthrough(tag: string, displayName: string) {
  const Component = forwardRef<HTMLElement, NptElementProps>(function NptWrapper(props, ref) {
    return createElement(tag, { ...props, ref });
  });
  Component.displayName = displayName;
  return Component;
}

export const NptButton = passthrough("npt-button", "NptButton");
export const NptCard = passthrough("npt-card", "NptCard");
export const NptBalanceCard = passthrough("npt-balance-card", "NptBalanceCard");
export const NptTransactionRow = passthrough("npt-transaction-row", "NptTransactionRow");
export const NptTextField = passthrough("npt-text-field", "NptTextField");
export const NptChip = passthrough("npt-chip", "NptChip");
export const NptBadge = passthrough("npt-badge", "NptBadge");
export const NptAppBar = passthrough("npt-app-bar", "NptAppBar");
export const NptNavBar = passthrough("npt-nav-bar", "NptNavBar");
export const NptNavItem = passthrough("npt-nav-item", "NptNavItem");

export { applyTheme, registerAll } from "@neptune.fintech/web-ui";
export type { ThemeInput, ModeOption, DirOption } from "@neptune.fintech/web-ui";
export { buildTheme, brandprintFor, encode, decode } from "@neptune.fintech/tokens";

export const REACT_UI_VERSION = "1.0.0";
