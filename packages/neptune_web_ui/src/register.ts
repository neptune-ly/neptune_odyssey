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
import {
  NptAmountInput,
  NptCurrencyField,
  NptIbanField,
  NptOtpInput,
  NptPinInput,
  NptAmountKeypad,
} from "./components/money-inputs.js";
import { NptCardArt, NptCardRow, NptAddCard, NptCardControls } from "./components/cards.js";
import {
  NptStep,
  NptStepper,
  NptTransferReview,
  NptSuccess,
  NptReceipt,
  NptBeneficiaryTile,
  NptMethodRow,
} from "./components/money-movement.js";
import {
  NptDataTable,
  NptStatCard,
  NptSparkline,
  NptDonut,
  NptLimitMeter,
  NptTrend,
} from "./components/data-viz.js";
import {
  NptSkeleton,
  NptEmptyState,
  NptAlert,
  NptStatusChip,
  NptToast,
  NptToastHost,
} from "./components/feedback-status.js";
import {
  NptApprovalItem,
  NptBatchCard,
  NptAuditRow,
  NptUserRow,
  NptPermissionToggle,
  NptWorkflowStatus,
} from "./components/corporate.js";
import {
  NptAppShell,
  NptPageHeader,
  NptSection,
  NptSideNav,
  NptSideNavItem,
  NptSearchField,
  NptToolbar,
} from "./components/shell-layout.js";
import {
  NptQuickActions,
  NptQuickAction,
  NptMerchantRow,
  NptVoucherCard,
  NptQrPay,
  NptTopupRow,
  NptTierBadge,
} from "./components/wallet-pay.js";
import { NptDock, NptDockItem, NptOnboarding } from "./components/premium.js";

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
  // Money & secure-entry inputs
  define("npt-amount-input", NptAmountInput);
  define("npt-currency-field", NptCurrencyField);
  define("npt-iban-field", NptIbanField);
  define("npt-otp-input", NptOtpInput);
  define("npt-pin-input", NptPinInput);
  define("npt-amount-keypad", NptAmountKeypad);
  // Payment cards
  define("npt-card-art", NptCardArt);
  define("npt-card-row", NptCardRow);
  define("npt-add-card", NptAddCard);
  define("npt-card-controls", NptCardControls);
  // Money-movement flow
  define("npt-step", NptStep);
  define("npt-stepper", NptStepper);
  define("npt-transfer-review", NptTransferReview);
  define("npt-success", NptSuccess);
  define("npt-receipt", NptReceipt);
  define("npt-beneficiary-tile", NptBeneficiaryTile);
  define("npt-method-row", NptMethodRow);
  // Data visualisation
  define("npt-data-table", NptDataTable);
  define("npt-stat-card", NptStatCard);
  define("npt-sparkline", NptSparkline);
  define("npt-donut", NptDonut);
  define("npt-limit-meter", NptLimitMeter);
  define("npt-trend", NptTrend);
  // Feedback & status
  define("npt-skeleton", NptSkeleton);
  define("npt-empty-state", NptEmptyState);
  define("npt-alert", NptAlert);
  define("npt-status-chip", NptStatusChip);
  define("npt-toast", NptToast);
  define("npt-toast-host", NptToastHost);
  // Corporate & back-office
  define("npt-approval-item", NptApprovalItem);
  define("npt-batch-card", NptBatchCard);
  define("npt-audit-row", NptAuditRow);
  define("npt-user-row", NptUserRow);
  define("npt-permission-toggle", NptPermissionToggle);
  define("npt-workflow-status", NptWorkflowStatus);
  // Application shell & layout
  define("npt-app-shell", NptAppShell);
  define("npt-page-header", NptPageHeader);
  define("npt-section", NptSection);
  define("npt-side-nav", NptSideNav);
  define("npt-side-nav-item", NptSideNavItem);
  define("npt-search-field", NptSearchField);
  define("npt-toolbar", NptToolbar);
  // Wallet & pay surfaces
  define("npt-quick-actions", NptQuickActions);
  define("npt-quick-action", NptQuickAction);
  define("npt-merchant-row", NptMerchantRow);
  define("npt-voucher-card", NptVoucherCard);
  define("npt-qr-pay", NptQrPay);
  define("npt-topup-row", NptTopupRow);
  define("npt-tier-badge", NptTierBadge);
  // Premium app-shell (Dribbble-grade)
  define("npt-dock", NptDock);
  define("npt-dock-item", NptDockItem);
  define("npt-onboarding", NptOnboarding);
}

registerAll();
