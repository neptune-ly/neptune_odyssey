// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Pure-logic tests only. jsdom cannot instantiate the <npt-*> custom elements
// (no constructable stylesheets), so we never mount components here — we exercise
// the brandprint decode → summary formatter against real reference brandprints.

import { describe, it, expect } from "vitest";
import { decode, buildTheme, brandprintFor } from "@neptune-odyssey/tokens";
import { summarizeBrandprint } from "../src/brandprint-summary.js";

describe("summarizeBrandprint", () => {
  it("summarizes each reference brand's canonical brandprint", () => {
    for (const brand of ["neptune", "andalus", "nuran", "fglb"] as const) {
      const bp = brandprintFor(brand);
      const decoded = decode(bp);
      const theme = buildTheme(bp);
      const lines = summarizeBrandprint(decoded, theme);

      const byKey = Object.fromEntries(lines.map((l) => [l.k, l.v]));
      // The reference brand should round-trip to a matching brand label.
      expect(byKey["Brand match"]?.toLowerCase()).toContain(brand);
      // Corners line carries all six steps + a px unit.
      expect(byKey["Corners (xs→xxl)"]).toMatch(/^\d+\/\d+\/\d+\/\d+\/\d+\/\d+px$/);
      // Defaults always names a mode and a direction.
      expect(byKey["Defaults"]).toMatch(/(light|dark) · (LTR|RTL)/);
      // Every line has a non-empty value.
      for (const l of lines) expect(l.v.length).toBeGreaterThan(0);
    }
  });

  it("labels a non-reference seed set as custom", () => {
    const decoded = decode(brandprintFor("neptune"));
    const fakeTheme = { ...buildTheme(brandprintFor("neptune")), brand: "custom" as const };
    const lines = summarizeBrandprint(decoded, fakeTheme);
    const match = lines.find((l) => l.k === "Brand match");
    expect(match?.v).toMatch(/custom/i);
  });
});
