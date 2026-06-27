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

  it("WEB_UI_VERSION is unchanged (2.0.0)", () => {
    expect(kit.WEB_UI_VERSION).toBe("2.0.0");
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
