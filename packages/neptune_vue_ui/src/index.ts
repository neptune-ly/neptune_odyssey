// Neptune Odyssey — @neptune.fintech/vue-ui · © 2026 Neptune.Fintech (neptune.ly)
// A thin Vue 3 layer over @neptune.fintech/web-ui: the custom elements do the
// rendering (themed by CSS variables); Vue adds typed wrappers, a provider, and a
// composable. Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// Tell Vue that npt-* are custom elements in your build:
//   vue({ template: { compilerOptions: { isCustomElement: (t) => t.startsWith("npt-") } } })

import { defineComponent, h, onMounted, watchEffect, type PropType } from "vue";
import {
  applyTheme,
  registerAll,
  type ThemeInput,
  type ModeOption,
  type DirOption,
} from "@neptune.fintech/web-ui";

/** Apply a theme to an element ref (or the document root) reactively. */
export function useNeptuneTheme(
  getEl: () => HTMLElement | null | undefined,
  getInput: () => ThemeInput,
  getOpts: () => { mode?: ModeOption; dir?: DirOption } = () => ({}),
): void {
  onMounted(() => {
    registerAll();
    watchEffect(() => {
      const el = getEl() ?? (typeof document !== "undefined" ? document.documentElement : null);
      if (el) applyTheme(el, getInput(), getOpts());
    });
  });
}

/**
 * <NeptuneProvider :theme="'andalus'" mode="system" dir="auto"> … </NeptuneProvider>
 * Wraps its slot in a themed <div> and registers the custom elements on mount.
 */
export const NeptuneProvider = defineComponent({
  name: "NeptuneProvider",
  props: {
    theme: { type: [String, Object] as PropType<ThemeInput>, required: true },
    mode: { type: String as PropType<ModeOption>, default: undefined },
    dir: { type: String as PropType<DirOption>, default: undefined },
  },
  setup(props, { slots }) {
    let root: HTMLElement | null = null;
    onMounted(() => {
      registerAll();
      watchEffect(() => {
        if (root) applyTheme(root, props.theme, { mode: props.mode, dir: props.dir });
      });
    });
    return () =>
      h("div", { class: "neptune-provider", ref: (el) => (root = el as HTMLElement) }, slots.default?.());
  },
});

type AnyRecord = Record<string, unknown>;
const passthrough = (tag: string, name: string) =>
  defineComponent({
    name,
    inheritAttrs: false,
    setup(_props, { attrs, slots }) {
      return () =>
        h(tag, attrs as AnyRecord, slots.default ? { default: () => slots.default!() } : undefined);
    },
  });

/** Typed thin wrappers — attributes pass straight through to the custom element. */
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

export const VUE_UI_VERSION = "1.0.0";
