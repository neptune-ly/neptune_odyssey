// Neptune Odyssey — element registration · © 2026 Neptune.Fintech (neptune.ly)
// Side-effectful by design: importing this file registers every custom element.
// (Tree-shakers: this module is listed in package.json "sideEffects".)
import { define } from "./components/base.js";
import { NptButton } from "./components/button.js";
import { NptCard } from "./components/card.js";
import { NptBalanceCard, NptTransactionRow } from "./components/financial.js";
import { NptTextField, NptChip, NptBadge } from "./components/inputs.js";
import { NptAppBar, NptNavBar, NptNavItem } from "./components/nav.js";
import { NptIconButton, NptFab, NptSegmentedButton, NptSegmentedOption } from "./components/actions.js";
import { NptCheckbox, NptRadio, NptSwitch, NptSlider } from "./components/selection.js";
import { NptProgress, NptSnackbar, NptTooltip, NptBanner } from "./components/feedback.js";
import { NptDialog, NptBottomSheet, NptMenu, NptMenuItem } from "./components/containers.js";
import {
  NptList,
  NptListItem,
  NptDivider,
  NptTabs,
  NptTab,
  NptAccordion,
  NptAccordionItem,
  NptAvatar,
} from "./components/layout.js";
import { NptNavRail, NptTopAppBar } from "./components/nav-rail.js";

/** Register every Neptune Odyssey custom element (idempotent, browser-only). */
export function registerAll(): void {
  define("npt-button", NptButton);
  define("npt-card", NptCard);
  define("npt-balance-card", NptBalanceCard);
  define("npt-transaction-row", NptTransactionRow);
  define("npt-text-field", NptTextField);
  define("npt-chip", NptChip);
  define("npt-badge", NptBadge);
  define("npt-app-bar", NptAppBar);
  define("npt-nav-bar", NptNavBar);
  define("npt-nav-item", NptNavItem);
  // Buttons & actions
  define("npt-icon-button", NptIconButton);
  define("npt-fab", NptFab);
  define("npt-segmented-button", NptSegmentedButton);
  define("npt-segmented-option", NptSegmentedOption);
  // Selection controls
  define("npt-checkbox", NptCheckbox);
  define("npt-radio", NptRadio);
  define("npt-switch", NptSwitch);
  define("npt-slider", NptSlider);
  // Communication & feedback
  define("npt-progress", NptProgress);
  define("npt-snackbar", NptSnackbar);
  define("npt-tooltip", NptTooltip);
  define("npt-banner", NptBanner);
  // Containers (overlays)
  define("npt-dialog", NptDialog);
  define("npt-bottom-sheet", NptBottomSheet);
  define("npt-menu", NptMenu);
  define("npt-menu-item", NptMenuItem);
  // Containers & layout
  define("npt-list", NptList);
  define("npt-list-item", NptListItem);
  define("npt-divider", NptDivider);
  define("npt-tabs", NptTabs);
  define("npt-tab", NptTab);
  define("npt-accordion", NptAccordion);
  define("npt-accordion-item", NptAccordionItem);
  define("npt-avatar", NptAvatar);
  // Navigation
  define("npt-nav-rail", NptNavRail);
  define("npt-top-app-bar", NptTopAppBar);
}

registerAll();
