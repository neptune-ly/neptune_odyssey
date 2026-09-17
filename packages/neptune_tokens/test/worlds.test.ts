import { describe, expect, it } from "vitest";
import { buildTheme, brandprintFor } from "../src/theme.js";
import {
  PRODUCT_WORLDS,
  WORLD_CONFIG,
  resolveMotionLevel,
  resolveProductWorld,
} from "../src/worlds.js";
import {
  allProductWorldCss,
  motionLevelToCssVars,
  productWorldToCssBlock,
} from "../src/generate/css.js";

describe("Odyssey product worlds", () => {
  it("exposes the six non-financial product worlds in a stable order", () => {
    expect(PRODUCT_WORLDS).toEqual([
      "voyage",
      "pulse",
      "market",
      "harbor",
      "grid",
      "canvas",
    ]);
  });

  for (const world of PRODUCT_WORLDS) {
    it(`${world}: resolves deterministically in light and dark`, () => {
      const lightA = resolveProductWorld(world, "light");
      const lightB = resolveProductWorld(world, "light");
      const dark = resolveProductWorld(world, "dark");

      expect(lightA).toEqual(lightB);
      expect(lightA.id).toBe(world);
      expect(lightA.mode).toBe("light");
      expect(dark.mode).toBe("dark");
      expect(lightA.colors.background).not.toBe(dark.colors.background);
      expect(lightA.radius).toBe(WORLD_CONFIG[world].radius);
      expect(lightA.titleFont).toBe(WORLD_CONFIG[world].titleFont);
      expect(lightA.colors.accent).toMatch(/^#[0-9A-F]{6}$/i);
      expect(dark.colors.accent).toMatch(/^#[0-9A-F]{6}$/i);
    });
  }

  it("composes a product world without changing the tenant palette or brandprint", () => {
    const base = buildTheme("neptune", { mode: "dark", dir: "rtl" });
    const themed = buildTheme("neptune", {
      mode: "dark",
      dir: "rtl",
      world: "voyage",
    });

    expect(themed.brand).toBe(base.brand);
    expect(themed.mode).toBe(base.mode);
    expect(themed.dir).toBe(base.dir);
    expect(themed.colors).toEqual(base.colors);
    expect(themed.shape).toEqual(base.shape);
    expect(themed.type).toEqual(base.type);
    expect(themed.brandprint).toBe(base.brandprint);
    expect(themed.brandprint).toBe(brandprintFor("neptune"));
    expect(themed.world).toEqual(resolveProductWorld("voyage", "dark"));
    expect(themed.interactionMotion).toEqual(resolveMotionLevel("expressive", false));
  });

  it("keeps the legacy buildTheme output free of product-world fields unless requested", () => {
    const legacy = buildTheme("neptune", { mode: "light" });
    expect("world" in legacy).toBe(false);
    expect("interactionMotion" in legacy).toBe(false);
  });
});

describe("Odyssey motion levels", () => {
  it("maps restrained, standard and expressive to increasing travel and stagger", () => {
    const restrained = resolveMotionLevel("restrained");
    const standard = resolveMotionLevel("standard");
    const expressive = resolveMotionLevel("expressive");

    expect(restrained.durationMs).toBe(160);
    expect(standard.durationMs).toBe(240);
    expect(expressive.durationMs).toBe(420);
    expect(restrained.distancePx).toBeLessThan(standard.distancePx);
    expect(standard.distancePx).toBeLessThan(expressive.distancePx);
    expect(restrained.staggerMs).toBeLessThan(standard.staggerMs);
    expect(standard.staggerMs).toBeLessThan(expressive.staggerMs);
    expect(expressive.overshoot).toBeLessThanOrEqual(0.08);
  });

  for (const level of ["restrained", "standard", "expressive"] as const) {
    it(`${level}: reduced motion removes travel, stagger and overshoot`, () => {
      expect(resolveMotionLevel(level, true)).toEqual({
        level,
        durationMs: 80,
        distancePx: 0,
        staggerMs: 0,
        overshoot: 0,
        reduced: true,
      });
    });
  }

  it("allows a context to override a world's default level", () => {
    const theme = buildTheme("neptune", {
      world: "canvas",
      motionLevel: "restrained",
      reducedMotion: true,
    });
    expect(theme.world?.defaultMotionLevel).toBe("expressive");
    expect(theme.interactionMotion).toEqual(resolveMotionLevel("restrained", true));
  });
});

describe("product-world CSS generation", () => {
  it("emits orthogonal data-world variables instead of replacing M3 tenant roles", () => {
    const css = productWorldToCssBlock("market", "dark");
    expect(css).toContain('[data-world="market"][data-mode="dark"]');
    expect(css).toContain("--o2-world-accent: #FF7A59;");
    expect(css).toContain("--o2-world-radius: 18px;");
    expect(css).not.toContain("--md-sys-color-primary:");
  });

  it("emits all six light + dark world selectors", () => {
    const css = allProductWorldCss();
    for (const world of PRODUCT_WORLDS) {
      expect(css).toContain(`[data-world="${world}"]`);
      expect(css).toContain(`[data-world="${world}"][data-mode="dark"]`);
    }
  });

  it("emits reduced-motion variables with no movement", () => {
    const css = motionLevelToCssVars("expressive", true);
    expect(css).toContain("--o2-motion-level-duration: 80ms;");
    expect(css).toContain("--o2-motion-level-distance: 0px;");
    expect(css).toContain("--o2-motion-level-stagger: 0ms;");
    expect(css).toContain("--o2-motion-level-overshoot: 0;");
  });
});
