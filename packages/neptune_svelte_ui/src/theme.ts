// Neptune Odyssey — Svelte theming action · © 2026 Neptune.Fintech (neptune.ly)
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
import {
  applyTheme,
  registerAll,
  type ThemeHandle,
  type ThemeInput,
  type ModeOption,
  type DirOption,
} from "@neptune.fintech/web-ui";

export interface ThemeActionParams {
  input: ThemeInput;
  mode?: ModeOption;
  dir?: DirOption;
}

interface SvelteActionReturn {
  update(params: ThemeActionParams): void;
  destroy(): void;
}

/**
 * Svelte action: `<div use:theme={{ input: "triton", mode: "system", dir: "auto" }}>`.
 * Applies (and reactively updates) a Neptune Odyssey theme on the node, and registers
 * the custom elements so `<npt-*>` tags work anywhere inside.
 */
export function theme(node: HTMLElement, params: ThemeActionParams): SvelteActionReturn {
  registerAll();
  let handle: ThemeHandle = applyTheme(node, params.input, { mode: params.mode, dir: params.dir });
  return {
    update(next: ThemeActionParams) {
      handle.dispose();
      handle = applyTheme(node, next.input, { mode: next.mode, dir: next.dir });
    },
    destroy() {
      handle.dispose();
    },
  };
}
