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
 * <NeptuneProvider :theme="'triton'" mode="system" dir="auto"> … </NeptuneProvider>
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
// GENERATED FROM packages/neptune_web_ui/src/register.ts — keep in sync via contract:check.
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
export const NptIconButton = passthrough("npt-icon-button", "NptIconButton");
export const NptFab = passthrough("npt-fab", "NptFab");
export const NptSegmentedButton = passthrough("npt-segmented-button", "NptSegmentedButton");
export const NptSegmentedOption = passthrough("npt-segmented-option", "NptSegmentedOption");
export const NptCheckbox = passthrough("npt-checkbox", "NptCheckbox");
export const NptRadio = passthrough("npt-radio", "NptRadio");
export const NptSwitch = passthrough("npt-switch", "NptSwitch");
export const NptSlider = passthrough("npt-slider", "NptSlider");
export const NptProgress = passthrough("npt-progress", "NptProgress");
export const NptSnackbar = passthrough("npt-snackbar", "NptSnackbar");
export const NptTooltip = passthrough("npt-tooltip", "NptTooltip");
export const NptBanner = passthrough("npt-banner", "NptBanner");
export const NptDialog = passthrough("npt-dialog", "NptDialog");
export const NptBottomSheet = passthrough("npt-bottom-sheet", "NptBottomSheet");
export const NptMenu = passthrough("npt-menu", "NptMenu");
export const NptMenuItem = passthrough("npt-menu-item", "NptMenuItem");
export const NptList = passthrough("npt-list", "NptList");
export const NptListItem = passthrough("npt-list-item", "NptListItem");
export const NptDivider = passthrough("npt-divider", "NptDivider");
export const NptTabs = passthrough("npt-tabs", "NptTabs");
export const NptTab = passthrough("npt-tab", "NptTab");
export const NptAccordion = passthrough("npt-accordion", "NptAccordion");
export const NptAccordionItem = passthrough("npt-accordion-item", "NptAccordionItem");
export const NptAvatar = passthrough("npt-avatar", "NptAvatar");
export const NptNavRail = passthrough("npt-nav-rail", "NptNavRail");
export const NptTopAppBar = passthrough("npt-top-app-bar", "NptTopAppBar");
export const NptAmountInput = passthrough("npt-amount-input", "NptAmountInput");
export const NptCurrencyField = passthrough("npt-currency-field", "NptCurrencyField");
export const NptIbanField = passthrough("npt-iban-field", "NptIbanField");
export const NptOtpInput = passthrough("npt-otp-input", "NptOtpInput");
export const NptPinInput = passthrough("npt-pin-input", "NptPinInput");
export const NptAmountKeypad = passthrough("npt-amount-keypad", "NptAmountKeypad");
export const NptCardArt = passthrough("npt-card-art", "NptCardArt");
export const NptCardRow = passthrough("npt-card-row", "NptCardRow");
export const NptAddCard = passthrough("npt-add-card", "NptAddCard");
export const NptCardControls = passthrough("npt-card-controls", "NptCardControls");
export const NptStep = passthrough("npt-step", "NptStep");
export const NptStepper = passthrough("npt-stepper", "NptStepper");
export const NptTransferReview = passthrough("npt-transfer-review", "NptTransferReview");
export const NptSuccess = passthrough("npt-success", "NptSuccess");
export const NptReceipt = passthrough("npt-receipt", "NptReceipt");
export const NptBeneficiaryTile = passthrough("npt-beneficiary-tile", "NptBeneficiaryTile");
export const NptMethodRow = passthrough("npt-method-row", "NptMethodRow");
export const NptDataTable = passthrough("npt-data-table", "NptDataTable");
export const NptStatCard = passthrough("npt-stat-card", "NptStatCard");
export const NptSparkline = passthrough("npt-sparkline", "NptSparkline");
export const NptDonut = passthrough("npt-donut", "NptDonut");
export const NptLimitMeter = passthrough("npt-limit-meter", "NptLimitMeter");
export const NptTrend = passthrough("npt-trend", "NptTrend");
export const NptSkeleton = passthrough("npt-skeleton", "NptSkeleton");
export const NptEmptyState = passthrough("npt-empty-state", "NptEmptyState");
export const NptAlert = passthrough("npt-alert", "NptAlert");
export const NptStatusChip = passthrough("npt-status-chip", "NptStatusChip");
export const NptToast = passthrough("npt-toast", "NptToast");
export const NptToastHost = passthrough("npt-toast-host", "NptToastHost");
export const NptApprovalItem = passthrough("npt-approval-item", "NptApprovalItem");
export const NptBatchCard = passthrough("npt-batch-card", "NptBatchCard");
export const NptAuditRow = passthrough("npt-audit-row", "NptAuditRow");
export const NptUserRow = passthrough("npt-user-row", "NptUserRow");
export const NptPermissionToggle = passthrough("npt-permission-toggle", "NptPermissionToggle");
export const NptWorkflowStatus = passthrough("npt-workflow-status", "NptWorkflowStatus");
export const NptAppShell = passthrough("npt-app-shell", "NptAppShell");
export const NptPageHeader = passthrough("npt-page-header", "NptPageHeader");
export const NptSection = passthrough("npt-section", "NptSection");
export const NptSideNav = passthrough("npt-side-nav", "NptSideNav");
export const NptSideNavItem = passthrough("npt-side-nav-item", "NptSideNavItem");
export const NptSearchField = passthrough("npt-search-field", "NptSearchField");
export const NptToolbar = passthrough("npt-toolbar", "NptToolbar");
export const NptQuickActions = passthrough("npt-quick-actions", "NptQuickActions");
export const NptQuickAction = passthrough("npt-quick-action", "NptQuickAction");
export const NptMerchantRow = passthrough("npt-merchant-row", "NptMerchantRow");
export const NptVoucherCard = passthrough("npt-voucher-card", "NptVoucherCard");
export const NptQrPay = passthrough("npt-qr-pay", "NptQrPay");
export const NptTopupRow = passthrough("npt-topup-row", "NptTopupRow");
export const NptTierBadge = passthrough("npt-tier-badge", "NptTierBadge");
export const NptDock = passthrough("npt-dock", "NptDock");
export const NptDockItem = passthrough("npt-dock-item", "NptDockItem");
export const NptOnboarding = passthrough("npt-onboarding", "NptOnboarding");
export const NptCta = passthrough("npt-cta", "NptCta");

export { applyTheme, registerAll } from "@neptune.fintech/web-ui";
export type { ThemeInput, ModeOption, DirOption } from "@neptune.fintech/web-ui";
export { buildTheme, brandprintFor, encode, decode } from "@neptune.fintech/tokens";

export const VUE_UI_VERSION = "2.0.0";
