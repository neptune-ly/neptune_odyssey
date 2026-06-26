// @vitest-environment jsdom
import { describe, it, expect, beforeEach } from "vitest";
import { applyTheme, setMode } from "../src/theme/applyTheme.js";
import { brandprintFor } from "@neptune-odyssey/tokens";

describe("applyTheme — reference brands (zero-JS reskin)", () => {
  let root: HTMLElement;
  beforeEach(() => {
    root = document.createElement("div");
    document.body.appendChild(root);
  });

  it("sets data-theme/data-mode/dir for a brand id without writing vars", () => {
    const h = applyTheme(root, "andalus", { mode: "dark", dir: "rtl" });
    expect(root.dataset.theme).toBe("andalus");
    expect(root.dataset.mode).toBe("dark");
    expect(root.getAttribute("dir")).toBe("rtl");
    // reference brands rely on the shipped themes.css — no inline color vars
    expect(root.style.getPropertyValue("--md-sys-color-primary")).toBe("");
    expect(h.theme.brand).toBe("andalus");
  });

  it("setMode flips only the mode attribute", () => {
    applyTheme(root, "neptune", { mode: "light" });
    setMode(root, "dark");
    expect(root.dataset.mode).toBe("dark");
  });
});

describe("applyTheme — brandprint + custom config write resolved vars", () => {
  let root: HTMLElement;
  beforeEach(() => {
    root = document.createElement("div");
    document.body.appendChild(root);
  });

  it("a brandprint string resolves and applies (custom path writes vars)", () => {
    // A reference brand's brandprint round-trips to that brand's pinned palette.
    const h = applyTheme(root, brandprintFor("nuran"), { mode: "light" });
    expect(h.theme.colors.primary).toMatch(/^#[0-9a-f]{6}$/);
    expect(root.dataset.theme).toBe("custom");
    // nuran primary (light) is pinned
    expect(root.style.getPropertyValue("--md-sys-color-primary").trim()).toBe(h.theme.colors.primary);
    expect(root.style.getPropertyValue("--npt-corner-md-base").trim()).toBe(`${h.theme.shape.md}px`);
    expect(root.style.getPropertyValue("--npt-font-display").trim()).toContain("Space Grotesk");
  });

  it("a raw config object themes the root", () => {
    const cfg = {
      primary: { L: 0.6, C: 0.2, H: 20 },
      tertiary: { L: 0.7, C: 0.15, H: 120 },
      corners: { xs: 6, sm: 10, md: 14, lg: 20, xl: 28, xxl: 38 },
      displayWeight: 700,
      displayTracking: -0.02,
      fonts: { display: "Sora", text: "Hanken Grotesk", num: "Sora" },
      loginShell: "depth-emblem",
      dashboardHero: "balance-cards",
      contentTone: "clear-calm",
      glassTint: "oceanic",
      motion: "smooth-fluid",
      defaultDark: false,
      defaultRtl: false,
    } as const;
    const h = applyTheme(root, cfg, { mode: "light" });
    expect(h.theme.brand).toBe("custom");
    expect(root.style.getPropertyValue("--md-sys-color-primary").trim()).toBe(h.theme.colors.primary);
  });
});
