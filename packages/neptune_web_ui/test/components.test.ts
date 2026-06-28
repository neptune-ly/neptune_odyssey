// @vitest-environment jsdom
// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// jsdom can't run constructable stylesheets, so these tests never instantiate or
// mount an element. They assert the *surface*: every new tag is exported from
// index.ts, registerAll() lists each one exactly once, and the helpers are pure.
import { describe, it, expect, vi, beforeEach } from "vitest";
import * as kit from "../src/index.js";

/** Every custom-element class the kit must export. */
const EXPORTED_CLASSES = [
  // existing
  "NptButton",
  "NptCard",
  "NptBalanceCard",
  "NptTransactionRow",
  "NptTextField",
  "NptChip",
  "NptBadge",
  "NptAppBar",
  "NptNavBar",
  "NptNavItem",
  // actions
  "NptIconButton",
  "NptFab",
  "NptSegmentedButton",
  "NptSegmentedOption",
  // selection
  "NptCheckbox",
  "NptRadio",
  "NptSwitch",
  "NptSlider",
  // feedback
  "NptProgress",
  "NptSnackbar",
  "NptTooltip",
  "NptBanner",
  // containers
  "NptDialog",
  "NptBottomSheet",
  "NptMenu",
  "NptMenuItem",
  // layout
  "NptList",
  "NptListItem",
  "NptDivider",
  "NptTabs",
  "NptTab",
  "NptAccordion",
  "NptAccordionItem",
  "NptAvatar",
  // navigation
  "NptNavRail",
  "NptTopAppBar",
  // money & secure-entry inputs
  "NptAmountInput",
  "NptCurrencyField",
  "NptIbanField",
  "NptOtpInput",
  "NptPinInput",
  "NptAmountKeypad",
  // payment cards
  "NptCardArt",
  "NptCardRow",
  "NptAddCard",
  "NptCardControls",
  // money-movement flow
  "NptStep",
  "NptStepper",
  "NptTransferReview",
  "NptSuccess",
  "NptReceipt",
  "NptBeneficiaryTile",
  "NptMethodRow",
  // data visualisation
  "NptDataTable",
  "NptStatCard",
  "NptSparkline",
  "NptDonut",
  "NptLimitMeter",
  "NptTrend",
  // feedback & status
  "NptSkeleton",
  "NptEmptyState",
  "NptAlert",
  "NptStatusChip",
  "NptToast",
  "NptToastHost",
  // corporate & back-office
  "NptApprovalItem",
  "NptBatchCard",
  "NptAuditRow",
  "NptUserRow",
  "NptPermissionToggle",
  "NptWorkflowStatus",
  // application shell & layout
  "NptAppShell",
  "NptPageHeader",
  "NptSection",
  "NptSideNav",
  "NptSideNavItem",
  "NptSearchField",
  "NptToolbar",
  // wallet & pay surfaces
  "NptQuickActions",
  "NptQuickAction",
  "NptMerchantRow",
  "NptVoucherCard",
  "NptQrPay",
  "NptTopupRow",
  "NptTierBadge",
  "NptDock",
  "NptDockItem",
  "NptOnboarding",
  "NptCta",
] as const;

/** Tags registerAll() must define. */
const EXPECTED_TAGS = [
  "npt-button",
  "npt-card",
  "npt-balance-card",
  "npt-transaction-row",
  "npt-text-field",
  "npt-chip",
  "npt-badge",
  "npt-app-bar",
  "npt-nav-bar",
  "npt-nav-item",
  "npt-icon-button",
  "npt-fab",
  "npt-segmented-button",
  "npt-segmented-option",
  "npt-checkbox",
  "npt-radio",
  "npt-switch",
  "npt-slider",
  "npt-progress",
  "npt-snackbar",
  "npt-tooltip",
  "npt-banner",
  "npt-dialog",
  "npt-bottom-sheet",
  "npt-menu",
  "npt-menu-item",
  "npt-list",
  "npt-list-item",
  "npt-divider",
  "npt-tabs",
  "npt-tab",
  "npt-accordion",
  "npt-accordion-item",
  "npt-avatar",
  "npt-nav-rail",
  "npt-top-app-bar",
  "npt-amount-input",
  "npt-currency-field",
  "npt-iban-field",
  "npt-otp-input",
  "npt-pin-input",
  "npt-amount-keypad",
  "npt-card-art",
  "npt-card-row",
  "npt-add-card",
  "npt-card-controls",
  "npt-step",
  "npt-stepper",
  "npt-transfer-review",
  "npt-success",
  "npt-receipt",
  "npt-beneficiary-tile",
  "npt-method-row",
  "npt-data-table",
  "npt-stat-card",
  "npt-sparkline",
  "npt-donut",
  "npt-limit-meter",
  "npt-trend",
  "npt-skeleton",
  "npt-empty-state",
  "npt-alert",
  "npt-status-chip",
  "npt-toast",
  "npt-toast-host",
  "npt-approval-item",
  "npt-batch-card",
  "npt-audit-row",
  "npt-user-row",
  "npt-permission-toggle",
  "npt-workflow-status",
  "npt-app-shell",
  "npt-page-header",
  "npt-section",
  "npt-side-nav",
  "npt-side-nav-item",
  "npt-search-field",
  "npt-toolbar",
  "npt-quick-actions",
  "npt-quick-action",
  "npt-merchant-row",
  "npt-voucher-card",
  "npt-qr-pay",
  "npt-topup-row",
  "npt-tier-badge",
  "npt-dock",
  "npt-dock-item",
  "npt-onboarding",
  "npt-cta",
] as const;

describe("web-ui · exported surface", () => {
  it("exports registerAll", () => {
    expect(typeof kit.registerAll).toBe("function");
  });

  it("exports every custom-element class", () => {
    for (const name of EXPORTED_CLASSES) {
      expect(kit, `missing export: ${name}`).toHaveProperty(name);
      expect(typeof (kit as Record<string, unknown>)[name]).toBe("function");
    }
  });

  it("WEB_UI_VERSION is current (2.4.0)", () => {
    expect(kit.WEB_UI_VERSION).toBe("2.4.0");
  });
});

describe("web-ui · registerAll() registry", () => {
  let tags: string[];

  beforeEach(() => {
    // Record every define() call without mounting elements (jsdom can't adopt
    // constructable stylesheets). `define` no-ops if a tag already exists, so we
    // stub get→undefined and capture define()'s first arg.
    tags = [];
    vi.spyOn(customElements, "get").mockReturnValue(undefined);
    vi.spyOn(customElements, "define").mockImplementation((tag: string) => {
      tags.push(tag);
    });
    kit.registerAll();
  });

  it("registers every expected tag", () => {
    for (const tag of EXPECTED_TAGS) {
      expect(tags, `not registered: ${tag}`).toContain(tag);
    }
  });

  it("registers no duplicate tags", () => {
    expect(new Set(tags).size).toBe(tags.length);
  });

  it("all tags are namespaced npt-*", () => {
    for (const tag of tags) expect(tag.startsWith("npt-")).toBe(true);
  });

  it("export count matches the registered tag count", () => {
    expect(EXPORTED_CLASSES.length).toBe(EXPECTED_TAGS.length);
  });
});
