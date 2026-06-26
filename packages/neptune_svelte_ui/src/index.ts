// Neptune Odyssey — @neptune-odyssey/svelte-ui · © 2026 Neptune.Fintech (neptune.ly)
// A thin Svelte layer over @neptune-odyssey/web-ui. Svelte renders the `<npt-*>`
// custom elements natively; this package adds the `use:theme` action, a
// <NeptuneProvider> component (shipped as source), and the theming re-exports.
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).

export { theme } from "./theme.js";
export type { ThemeActionParams } from "./theme.js";

export { applyTheme, registerAll } from "@neptune-odyssey/web-ui";
export type { ThemeInput, ModeOption, DirOption, NeptuneTheme } from "@neptune-odyssey/web-ui";
export { buildTheme, brandprintFor, encode, decode } from "@neptune-odyssey/tokens";

export const SVELTE_UI_VERSION = "1.0.0";
