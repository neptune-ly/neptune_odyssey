// Neptune Odyssey — @neptune.fintech/web-ui · © 2026 Neptune.Fintech (neptune.ly)
// Framework-agnostic, CSS-variable themed custom-element kit + the applyTheme API.
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// Theming is pure CSS variables. Import the stylesheet once:
//   import "@neptune.fintech/web-ui/styles.css";
// then either set data-theme/data-mode/dir yourself, or use applyTheme().
// Register components with registerAll() (or import "@neptune.fintech/web-ui/register").

export * from "./theme/applyTheme.js";

export { NptElement, define } from "./components/base.js";
export { NptButton } from "./components/button.js";
export { NptCard } from "./components/card.js";
export { NptBalanceCard, NptTransactionRow } from "./components/financial.js";
export { NptTextField, NptChip, NptBadge } from "./components/inputs.js";
export { NptAppBar, NptNavBar, NptNavItem } from "./components/nav.js";
export {
  NptIconButton,
  NptFab,
  NptSegmentedButton,
  NptSegmentedOption,
} from "./components/actions.js";
export { NptCheckbox, NptRadio, NptSwitch, NptSlider } from "./components/selection.js";
export { NptProgress, NptSnackbar, NptTooltip, NptBanner } from "./components/feedback.js";
export { NptDialog, NptBottomSheet, NptMenu, NptMenuItem } from "./components/containers.js";
export {
  NptList,
  NptListItem,
  NptDivider,
  NptTabs,
  NptTab,
  NptAccordion,
  NptAccordionItem,
  NptAvatar,
} from "./components/layout.js";
export { NptNavRail, NptTopAppBar } from "./components/nav-rail.js";
export { registerAll } from "./register.js";

// Re-export the theming types so consumers need only this package for the surface.
export type {
  Brand,
  Mode,
  Direction,
  NeptuneTheme,
  ThemeInput,
  BrandprintConfig,
} from "@neptune.fintech/tokens";
export { buildTheme, encode, decode, brandprintFor } from "@neptune.fintech/tokens";

export const WEB_UI_VERSION = "2.1.0";
