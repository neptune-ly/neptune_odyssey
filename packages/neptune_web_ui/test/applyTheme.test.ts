// @vitest-environment jsdom
import { describe, it, expect, beforeEach } from "vitest";
import { applyTheme, setMode } from "../src/theme/applyTheme.js";
import { brandprintFor } from "@neptune.fintech/tokens";

describe("applyTheme — reference brands (zero-JS tenant reskin)", () => {
  let root: HTMLElement;
  beforeEach(() => {
    root = document.createElement("div");
    document.body.appendChild(root);
  });

  it("sets data-theme/data-mode/dir for a brand id without writing tenant vars", () => {
    const h = applyTheme(root, "triton", { mode: "dark", dir: "rtl" });
    expect(root.dataset.theme).toBe("triton");
    expect(root.dataset.mode).toBe("dark");
    expect(root.getAttribute("dir")).toBe("rtl");
    // reference brands rely on the shipped themes.css — no inline tenant color vars
    expect(root.style.getPropertyValue("--md-sys-color-primary")).toBe("");
    expect(h.theme.brand).toBe("triton");
  });

  it("setMode flips only the mode attribute", () => {
    applyTheme(root, "neptune", { mode: "light" });
    setMode(root, "dark");
    expect(root.dataset.mode).toBe("dark");
  });
});

describe("applyTheme — product worlds compose with tenant identity", () => {
  let root: HTMLElement;
  beforeEach(() => {
    root = document.createElement("div");
    document.body.appendChild(root);
  });

  it("applies Voyage world variables without writing reference-brand M3 vars", () => {
    const h = applyTheme(root, "neptune", {
      mode: "dark",
      dir: "rtl",
      world: "voyage",
    });

    expect(root.dataset.theme).toBe("neptune");
    expect(root.dataset.world).toBe("voyage");
    expect(root.dataset.motionLevel).toBe("expressive");
    expect(root.getAttribute("dir")).toBe("rtl");
    expect(root.style.getPropertyValue("--md-sys-color-primary")).toBe("");
    expect(root.style.getPropertyValue("--o2-world-accent").trim()).toBe("#7CA8FF");
    expect(root.style.getPropertyValue("--o2-world-background").trim()).toBe("#0C1424");
    expect(root.style.getPropertyValue("--o2-world-radius").trim()).toBe("20px");
    expect(root.style.getPropertyValue("--o2-world-title-font")).toContain("Sora");
    expect(root.style.getPropertyValue("--o2-motion-level-duration").trim()).toBe("420ms");
    expect(h.theme.world?.id).toBe("voyage");
    expect(h.theme.colors.primary).toMatch(/^#[0-9a-f]{6}$/);
  });

  it("reduced motion zeros travel/stagger/overshoot at the web root", () => {
    applyTheme(root, "neptune", {
      world: "pulse",
      reducedMotion: true,
    });

    expect(root.dataset.world).toBe("pulse");
    expect(root.dataset.reducedMotion).toBe("true");
    expect(root.style.getPropertyValue("--o2-motion-level-duration").trim()).toBe("80ms");
    expect(root.style.getPropertyValue("--o2-motion-level-distance").trim()).toBe("0px");
    expect(root.style.getPropertyValue("--o2-motion-level-stagger").trim()).toBe("0ms");
    expect(root.style.getPropertyValue("--o2-motion-level-overshoot").trim()).toBe("0");
  });

  it("clears stale world state when the same root is re-themed without a world", () => {
    applyTheme(root, "neptune", { world: "market" });
    expect(root.dataset.world).toBe("market");

    applyTheme(root, "neptune");
    expect(root.dataset.world).toBeUndefined();
    expect(root.dataset.motionLevel).toBeUndefined();
    expect(root.style.getPropertyValue("--o2-world-accent")).toBe("");
    expect(root.style.getPropertyValue("--o2-motion-level-duration")).toBe("");
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
    const h = applyTheme(root, brandprintFor("nereid"), { mode: "light" });
    expect(h.theme.colors.primary).toMatch(/^#[0-9a-f]{6}$/);
    expect(root.dataset.theme).toBe("custom");
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
    const h = applyTheme(root, cfg, { mode: "light", world: "grid" });
    expect(h.theme.brand).toBe("custom");
    expect(root.style.getPropertyValue("--md-sys-color-primary").trim()).toBe(h.theme.colors.primary);
    expect(root.style.getPropertyValue("--o2-world-radius").trim()).toBe("8px");
  });
});
