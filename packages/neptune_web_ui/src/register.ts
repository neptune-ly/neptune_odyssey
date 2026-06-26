// Neptune Odyssey — element registration · © 2026 Neptune.Fintech (neptune.ly)
// Side-effectful by design: importing this file registers every custom element.
// (Tree-shakers: this module is listed in package.json "sideEffects".)
import { define } from "./components/base.js";
import { NptButton } from "./components/button.js";
import { NptCard } from "./components/card.js";
import { NptBalanceCard, NptTransactionRow } from "./components/financial.js";
import { NptTextField, NptChip, NptBadge } from "./components/inputs.js";
import { NptAppBar, NptNavBar, NptNavItem } from "./components/nav.js";

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
}

registerAll();
