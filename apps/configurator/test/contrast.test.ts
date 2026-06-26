// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
import { describe, it, expect } from "vitest";
import {
  contrastRatio,
  relativeLuminance,
  hexToRgb01,
  evaluateContrast,
  AA_PAIRS,
} from "../src/contrast.js";

describe("hexToRgb01", () => {
  it("parses #rrggbb", () => {
    expect(hexToRgb01("#ffffff")).toEqual([1, 1, 1]);
    expect(hexToRgb01("#000000")).toEqual([0, 0, 0]);
  });

  it("parses shorthand #rgb", () => {
    expect(hexToRgb01("#fff")).toEqual([1, 1, 1]);
  });

  it("throws on bad input", () => {
    expect(() => hexToRgb01("#xyz123")).toThrow();
    expect(() => hexToRgb01("not-a-color")).toThrow();
  });
});

describe("relativeLuminance", () => {
  it("white is 1, black is 0", () => {
    expect(relativeLuminance("#ffffff")).toBeCloseTo(1, 5);
    expect(relativeLuminance("#000000")).toBeCloseTo(0, 5);
  });
});

describe("contrastRatio", () => {
  it("black on white is 21", () => {
    expect(contrastRatio("#000000", "#ffffff")).toBeCloseTo(21, 5);
    expect(contrastRatio("#ffffff", "#000000")).toBeCloseTo(21, 5);
  });

  it("equal colours are 1", () => {
    expect(contrastRatio("#336699", "#336699")).toBeCloseTo(1, 10);
    expect(contrastRatio("#ffffff", "#ffffff")).toBeCloseTo(1, 10);
  });

  it("is symmetric", () => {
    const a = contrastRatio("#1a73e8", "#ffffff");
    const b = contrastRatio("#ffffff", "#1a73e8");
    expect(a).toBeCloseTo(b, 10);
  });

  it("known pair: #767676 on white ≈ 4.54 (AA boundary)", () => {
    expect(contrastRatio("#767676", "#ffffff")).toBeGreaterThanOrEqual(4.5);
    expect(contrastRatio("#777777", "#ffffff")).toBeLessThan(4.6);
  });
});

describe("evaluateContrast", () => {
  it("passes a high-contrast palette and flags a low-contrast one", () => {
    const palette: Record<string, string> = {};
    for (const p of AA_PAIRS) {
      palette[p.bg] = "#ffffff";
      palette[p.fg] = "#000000";
    }
    const results = evaluateContrast(palette);
    expect(results).toHaveLength(AA_PAIRS.length);
    expect(results.every((r) => r.pass)).toBe(true);
    expect(results[0]!.ratio).toBeCloseTo(21, 5);

    const bad: Record<string, string> = {};
    for (const p of AA_PAIRS) {
      bad[p.bg] = "#ffffff";
      bad[p.fg] = "#fefefe";
    }
    const badResults = evaluateContrast(bad);
    expect(badResults.every((r) => !r.pass)).toBe(true);
  });
});
