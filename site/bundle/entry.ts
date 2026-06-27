// Neptune Odyssey — browser bundle entry for the docs site · © 2026 Neptune.Fintech (neptune.ly)
// esbuild bundles this (IIFE, globalName "Neptune") into site/assets/neptune.js so the
// static docs pages can render real <npt-*> components + icons live. Auto-registers on load.
import { registerAll, applyTheme, buildTheme, encode, decode } from "@neptune.fintech/web-ui";
import { register, iconSvg, ICON_NAMES, brandMarkSvg, BRAND_MARK_NAMES } from "@neptune.fintech/icons";

if (typeof customElements !== "undefined") {
  registerAll();
  register(); // icons + brand marks (<npt-icon>, <npt-brand-mark>)
}

export {
  registerAll,
  register,
  applyTheme,
  buildTheme,
  encode,
  decode,
  iconSvg,
  ICON_NAMES,
  brandMarkSvg,
  BRAND_MARK_NAMES,
};
