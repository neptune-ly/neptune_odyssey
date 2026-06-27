// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
import { describe, it, expect } from "vitest";
import { oklchToHex } from "@neptune.fintech/tokens";
import { srgbToOklch } from "../src/oklch-inverse.js";

/** Max per-channel LSB difference between two #rrggbb hex strings. */
function lsbDelta(a: string, b: string): number {
  const ai = parseInt(a.replace("#", ""), 16);
  const bi = parseInt(b.replace("#", ""), 16);
  const dr = Math.abs(((ai >> 16) & 255) - ((bi >> 16) & 255));
  const dg = Math.abs(((ai >> 8) & 255) - ((bi >> 8) & 255));
  const db = Math.abs((ai & 255) - (bi & 255));
  return Math.max(dr, dg, db);
}

describe("srgbToOklch round-trip", () => {
  const samples = [
    "#1d5ab0", // neptune primary
    "#00774d", // triton primary
    "#6f4cc5", // nereid primary
    "#004f8f", // proteus primary
    "#eb4e4d", // configurator accent
    "#c3518d",
    "#a68018",
    "#008388",
    "#ffffff",
    "#000000",
    "#888888",
  ];

  it("oklchToHex(srgbToOklch(hex)) ≈ hex within a couple LSB", () => {
    for (const hex of samples) {
      const back = oklchToHex(srgbToOklch(hex));
      expect(lsbDelta(hex, back)).toBeLessThanOrEqual(2);
    }
  });

  it("returns L,C,H in expected ranges", () => {
    const o = srgbToOklch("#1d5ab0");
    expect(o.L).toBeGreaterThan(0);
    expect(o.L).toBeLessThanOrEqual(1);
    expect(o.C).toBeGreaterThanOrEqual(0);
    expect(o.H).toBeGreaterThanOrEqual(0);
    expect(o.H).toBeLessThan(360);
  });

  it("reports achromatic greys as zero chroma", () => {
    expect(srgbToOklch("#888888").C).toBe(0);
    expect(srgbToOklch("#ffffff").C).toBe(0);
  });

  it("parses shorthand #rgb", () => {
    const a = srgbToOklch("#fff");
    expect(oklchToHex(a)).toBe("#ffffff");
  });
});
