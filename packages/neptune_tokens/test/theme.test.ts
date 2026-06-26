// Theme builder — the three entry points must agree, and a brandprint must round-trip
// to an identical theme (the cross-platform "same string ⇒ same theme" contract).
import { describe, it, expect } from "vitest";
import { buildTheme, brandprintFor } from "../src/theme.js";
import { BRAND_CONFIG } from "../src/data/brands.generated.js";
import { getResolvedPalette } from "../src/resolve.js";
import { BRANDS, MODES } from "../src/types.js";

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
