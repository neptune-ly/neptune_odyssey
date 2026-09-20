// Theme builder — the three entry points must agree, and a brandprint must round-trip
// to an identical theme (the cross-platform "same string ⇒ same theme" contract).
import { describe, it, expect } from "vitest";
import { readFileSync } from "node:fs";
import { buildTheme, brandprintFor } from "../src/theme.js";
import { BRAND_CONFIG } from "../src/data/brands.generated.js";
import { getResolvedPalette } from "../src/resolve.js";
import { BRANDS, MODES, COLOR_ROLES } from "../src/types.js";

const nativeSchemes = JSON.parse(readFileSync(new URL('../assets/odyssey3.figma-colors.json', import.meta.url), 'utf8')).schemes;
const themesCss = readFileSync(new URL('../assets/themes.css', import.meta.url), 'utf8');

describe("three theming entry points agree", () => {
  for (const brand of BRANDS) {
    it(`${brand}: brand id == config == brandprint`, () => {
      const byId = buildTheme(brand, { mode: "light" });
      const byConfig = buildTheme(BRAND_CONFIG[brand]!, { mode: "light" });
      const byPrint = buildTheme(brandprintFor(brand), { mode: "light" });
      expect(byConfig.colors).toEqual(byId.colors);
      expect(byPrint.colors).toEqual(byId.colors);
      expect(byPrint.brandprint).toBe(byId.brandprint);
      expect(byPrint.shape).toEqual(byId.shape);
      expect(byPrint.type).toEqual(byId.type);
      expect(byPrint.levers).toEqual(byId.levers);
    });
  }
});

describe("reference themes use pinned palettes", () => {
  for (const brand of BRANDS) {
    for (const mode of MODES) {
      it(`${brand}/${mode} colors == resolved data`, () => {
        const t = buildTheme(brand, { mode });
        expect(t.colors).toEqual(getResolvedPalette(brand, mode));
      });
    }
  }
});

describe("mode + direction params and defaults", () => {
  it("explicit mode/dir win", () => {
    const t = buildTheme("neptune", { mode: "dark", dir: "rtl" });
    expect(t.mode).toBe("dark");
    expect(t.dir).toBe("rtl");
  });

  it("a custom seed set resolves to brand=custom via the ramp", () => {
    const cfg = structuredClone(BRAND_CONFIG.neptune!);
    cfg.primary = { L: 0.6, C: 0.2, H: 20 }; // not a reference seed
    cfg.tertiary = { L: 0.7, C: 0.15, H: 120 };
    const t = buildTheme(cfg, { mode: "light" });
    expect(t.brand).toBe("custom");
    expect(t.colors.primary).toMatch(/^#[0-9a-f]{6}$/);
    expect(t.brandprint.startsWith("NO1-")).toBe(true);
  });
});

describe("Odyssey 3 expression opt-in", () => {
  for (const product of ["wallet", "drive", "orbit"] as const) {
    for (const mode of MODES) {
      it(`${product}/${mode}: every semantic role matches the resolved native library`, () => {
        const theme = buildTheme("neptune", { edition: "odyssey3", product, mode });
        const native = nativeSchemes[product === "wallet" ? "core" : product][mode];
        expect(Object.keys(theme.colors).sort()).toEqual([...COLOR_ROLES].sort());
        expect(theme.colors).toEqual(native);
      });
    }
  }

  it("preserves each tenant banking palette when opting into O3", () => {
    for (const brand of BRANDS) for (const mode of MODES) {
      expect(buildTheme(brand, { edition: "odyssey3", product: "banking", mode }).colors)
        .toEqual(getResolvedPalette(brand, mode));
    }
  });

  it("keeps v1 tenant colors until the edition is selected", () => {
    const v1 = buildTheme("neptune", { product: "drive" });
    expect(v1.expression).toBeUndefined();
    expect(v1.colors).toEqual(getResolvedPalette("neptune", "light"));
  });

  it("maps wallet to core and applies drive's exact action with reduced motion", () => {
    const wallet = buildTheme("neptune", { edition: "odyssey3", product: "wallet" });
    const drive = buildTheme("neptune", { edition: "odyssey3", product: "drive", reducedMotion: true });
    expect(wallet.colors.primary).toBe("#07315F");
    expect(drive.colors.primary).toBe("#086B60");
    expect(drive.expression?.motionMs.reveal).toBe(0);
  });

  it("resolves the shared type, shape and motion foundation across public and banking O3", () => {
    const ltr = buildTheme("nereid", { edition: "odyssey3", product: "orbit", mode: "light" });
    const rtl = buildTheme("proteus", { edition: "odyssey3", product: "banking", dir: "rtl", reducedMotion: true });
    expect(ltr.shape).toEqual({ xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 32, full: 999 });
    expect(ltr.type).toMatchObject({ display: "Hanken Grotesk", text: "Hanken Grotesk", num: "Hanken Grotesk", displayWeight: 700 });
    expect(ltr.motion.durMs).toEqual({ fast: 120, standard: 200, slow: 320 });
    expect(rtl.type).toMatchObject({ display: "Beiruti", text: "Beiruti", num: "Hanken Grotesk", displayWeight: 700 });
    expect(rtl.motion.durMs).toEqual({ fast: 0, standard: 0, slow: 0 });
  });

  it("declares the same O3 typography and radii for CSS-only roots", () => {
    for (const declaration of [
      "--npt-font-display:var(--npt-o3-font-en)",
      "--npt-font-text:var(--npt-o3-font-en)",
      "--npt-font-num:var(--npt-o3-font-en)",
      "--npt-display-weight:700",
      "--npt-corner-xs-base:var(--npt-o3-radius-xs)",
      "--npt-corner-xl-base:var(--npt-o3-radius-xl)",
      "--npt-corner-2xl-base:var(--npt-o3-radius-xl)",
      "--npt-corner-full:var(--npt-o3-radius-full)",
      "--npt-dur-1:var(--npt-o3-feedback)",
      "--npt-dur-2:var(--npt-o3-navigate)",
      "--npt-dur-4:var(--npt-o3-reveal)",
      "--npt-text-body:16px", "--npt-leading-body:24px",
      "--npt-text-label:14px", "--npt-leading-label:20px",
      "--npt-text-caption:12px", "--npt-leading-caption:16px",
      "--npt-text-body:20px", "--npt-leading-body:28px",
      "--npt-text-label:18px", "--npt-leading-label:24px",
      "--npt-text-caption:16px", "--npt-leading-caption:22px",
      "--npt-display-tracking:0em",
    ]) expect(themesCss).toContain(declaration);
  });
});
