// @vitest-environment jsdom
import { describe, it, expect, beforeEach, vi } from "vitest";
import { applyTheme, setDirection, setMode } from "../src/theme/applyTheme.js";
import { brandprintFor } from "@neptune.fintech/tokens";

describe("applyTheme — reference brands (zero-JS reskin)", () => {
  let root: HTMLElement;
  beforeEach(() => {
    root = document.createElement("div");
    document.body.appendChild(root);
  });

  it("selects the opt-in product expression without changing the v1 path", () => {
    const h = applyTheme(root, "neptune", { edition: "odyssey3", product: "orbit", reducedMotion: true });
    expect(root.dataset.odyssey).toBe("3");
    expect(root.dataset.product).toBe("orbit");
    expect(root.dataset.reducedMotion).toBe("true");
    expect(h.theme.colors.primary).toBe("#3D49E6");
    expect(root.style.getPropertyValue("--npt-o3-paper").trim()).not.toBe("");
  });

  it("sets data-theme/data-mode/dir for a brand id without writing vars", () => {
    const h = applyTheme(root, "triton", { mode: "dark", dir: "rtl" });
    expect(root.dataset.theme).toBe("triton");
    expect(root.dataset.mode).toBe("dark");
    expect(root.getAttribute("dir")).toBe("rtl");
    // reference brands rely on the shipped themes.css — no inline color vars
    expect(root.style.getPropertyValue("--md-sys-color-primary")).toBe("");
    expect(h.theme.brand).toBe("triton");
  });

  it("setMode flips only the mode attribute", () => {
    applyTheme(root, "neptune", { mode: "light" });
    setMode(root, "dark");
    expect(root.dataset.mode).toBe("dark");
  });

  it("keeps CSS-only roots compatible with the convenience setters", () => {
    setMode(root, "dark");
    setDirection(root, "rtl");
    expect(root.dataset.mode).toBe("dark");
    expect(root.getAttribute("dir")).toBe("rtl");
  });

  it("setMode repaints inline O3 expression vars", () => {
    const h = applyTheme(root, "neptune", { edition: "odyssey3", product: "orbit", mode: "light" });
    const light = root.style.getPropertyValue("--npt-o3-paper");
    setMode(root, "dark");
    expect(root.style.getPropertyValue("--npt-o3-paper")).not.toBe(light);
    expect(h.theme.mode).toBe("dark");
  });

  it("setDirection repaints O3 fonts and the handle theme", () => {
    const h = applyTheme(root, "neptune", { edition: "odyssey3", dir: "ltr" });
    const ltr = root.style.getPropertyValue("--npt-font-display");
    setDirection(root, "rtl");
    expect(root.style.getPropertyValue("--npt-font-display")).not.toBe(ltr);
    expect(root.style.getPropertyValue("--npt-font-num")).toBe("'Hanken Grotesk'");
    expect(h.theme.dir).toBe("rtl");
  });

  it("writes the shared O3 locale type ramp for API consumers", () => {
    applyTheme(root, "neptune", { edition: "odyssey3", product: "wallet", dir: "ltr" });
    expect(root.style.getPropertyValue("--npt-text-body")).toBe("16px");
    expect(root.style.getPropertyValue("--npt-leading-body")).toBe("24px");
    expect(root.style.getPropertyValue("--npt-text-label")).toBe("14px");
    expect(root.style.getPropertyValue("--npt-leading-label")).toBe("20px");
    expect(root.style.getPropertyValue("--npt-text-caption")).toBe("12px");
    expect(root.style.getPropertyValue("--npt-leading-caption")).toBe("16px");
    expect(root.style.getPropertyValue("--npt-display-tracking")).toBe("0em");
    expect(root.style.getPropertyValue("--npt-o3-target-primary")).toBe("56px");
    expect(root.style.getPropertyValue("--npt-o3-control-radius")).toBe("16px");
    expect(root.style.getPropertyValue("--npt-o3-pocket-radius")).toBe("24px");
    expect(root.style.getPropertyValue("--npt-o3-capsule-radius")).toBe("999px");
    expect(root.style.getPropertyValue("--npt-o3-field-cyan")).toBe("#3BC1EE");
    expect(root.style.getPropertyValue("--npt-o3-content-on-coral")).toBe("#071A2D");
    expect(root.style.getPropertyValue("--npt-o3-font-expressive")).toBe("'Baloo 2'");
    setDirection(root, "rtl");
    expect(root.style.getPropertyValue("--npt-text-body")).toBe("20px");
    expect(root.style.getPropertyValue("--npt-leading-body")).toBe("28px");
    expect(root.style.getPropertyValue("--npt-text-label")).toBe("18px");
    expect(root.style.getPropertyValue("--npt-leading-label")).toBe("24px");
    expect(root.style.getPropertyValue("--npt-text-caption")).toBe("16px");
    expect(root.style.getPropertyValue("--npt-leading-caption")).toBe("22px");
    expect(root.style.getPropertyValue("--npt-display-tracking")).toBe("0em");
  });

  it("bridges legacy numeric motion aliases to O3 tiers and reduced motion", () => {
    applyTheme(root, "neptune", { edition: "odyssey3", product: "drive" });
    expect(root.style.getPropertyValue("--npt-dur-1")).toBe("120ms");
    expect(root.style.getPropertyValue("--npt-dur-2")).toBe("200ms");
    expect(root.style.getPropertyValue("--npt-dur-4")).toBe("320ms");
    applyTheme(root, "neptune", { edition: "odyssey3", product: "drive", reducedMotion: true });
    expect(root.style.getPropertyValue("--npt-dur-1")).toBe("0ms");
    expect(root.style.getPropertyValue("--npt-dur-2")).toBe("0ms");
    expect(root.style.getPropertyValue("--npt-dur-4")).toBe("0ms");
  });

  it("reapplying v1 removes adapter vars without touching consumer styles", () => {
    root.style.setProperty("--consumer-accent", "tomato");
    root.style.background = "black";
    applyTheme(root, "neptune", { edition: "odyssey3", product: "orbit" });
    applyTheme(root, "neptune");
    expect(root.style.getPropertyValue("--npt-o3-paper")).toBe("");
    expect(root.style.getPropertyValue("--md-sys-color-primary")).toBe("");
    expect(root.style.getPropertyValue("--consumer-accent")).toBe("tomato");
    expect(root.style.background).toBe("black");
  });

  it("cleans adapter vars after an O3 handle is disposed", () => {
    const h = applyTheme(root, "neptune", { edition: "odyssey3", product: "orbit" });
    h.dispose();
    applyTheme(root, "neptune");
    expect(root.style.getPropertyValue("--npt-o3-paper")).toBe("");
  });
});

describe("applyTheme — controller lifecycle", () => {
  let root: HTMLElement;
  beforeEach(() => {
    root = document.createElement("div");
    document.body.appendChild(root);
  });

  it("keeps an explicit mode after a system media change and cleans listeners", () => {
    const listeners = new Set<() => void>();
    const mq = {
      matches: false,
      addEventListener: vi.fn((_event: string, listener: () => void) => listeners.add(listener)),
      removeEventListener: vi.fn((_event: string, listener: () => void) => listeners.delete(listener)),
    };
    vi.stubGlobal("matchMedia", vi.fn(() => mq));
    const system = applyTheme(root, "neptune", { mode: "system" });
    const systemListeners = [...listeners];
    setMode(root, "dark");
    for (const listener of systemListeners) listener();
    expect(root.dataset.mode).toBe("dark");
    expect(mq.removeEventListener).toHaveBeenCalledTimes(1);
    const replacement = applyTheme(root, "neptune", { mode: "system" });
    applyTheme(root, "neptune", { mode: "light" });
    expect(mq.removeEventListener).toHaveBeenCalledTimes(2);
    system.dispose();
    const active = applyTheme(root, "neptune", { mode: "system" });
    active.dispose();
    expect(mq.removeEventListener).toHaveBeenCalledTimes(3);
    replacement.dispose();
    vi.unstubAllGlobals();
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
    // nereid primary (light) is pinned
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
