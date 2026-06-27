// Neptune Odyssey — brand-mark contract tests · © 2026 Neptune.Fintech (neptune.ly)
import { describe, it, expect } from "vitest";
import {
  BRAND_MARKS,
  BRAND_MARK_NAMES,
  brandMarkSvg,
  isBrandMarkName,
} from "../src/brand-marks.js";
import type { BrandMarkName } from "../src/brand-marks.js";
import { ICONS } from "../src/icons.js";

describe("BRAND_MARKS map ↔ BRAND_MARK_NAMES roster", () => {
  it("every BrandMarkName has an entry in BRAND_MARKS", () => {
    for (const name of BRAND_MARK_NAMES) {
      expect(BRAND_MARKS[name], `missing svg for "${name}"`).toBeTruthy();
      expect(typeof BRAND_MARKS[name]).toBe("string");
    }
  });

  it("BRAND_MARK_NAMES exactly matches the BRAND_MARKS keys (no drift, no dupes)", () => {
    const mapKeys = Object.keys(BRAND_MARKS).sort();
    const roster = [...BRAND_MARK_NAMES].sort();
    expect(roster).toEqual(mapKeys);
    expect(new Set(BRAND_MARK_NAMES).size).toBe(BRAND_MARK_NAMES.length);
  });

  it("brand marks are kept separate from the monochrome ICONS set", () => {
    for (const name of BRAND_MARK_NAMES) {
      expect(name in ICONS, `"${name}" must not be in ICONS`).toBe(false);
    }
  });
});

describe("brandMarkSvg()", () => {
  it("returns a complete multicolour <svg> with a viewBox", () => {
    for (const name of BRAND_MARK_NAMES) {
      const svg = brandMarkSvg(name);
      expect(svg.startsWith("<svg")).toBe(true);
      expect(svg.endsWith("</svg>")).toBe(true);
      expect(svg).toMatch(/viewBox="0 0 \d+ \d+"/);
    }
  });

  it("sizes to a given height and preserves aspect ratio", () => {
    // visa is a 48×32 (3:2) mark → height 16 ⇒ width 24
    const svg = brandMarkSvg("visa", { height: 16 });
    // the root <svg> carries exactly one width/height, at the requested size
    const root = svg.slice(0, svg.indexOf(">") + 1);
    expect(root).toContain('height="16"');
    expect(root).toContain('width="24"');
    expect((root.match(/\swidth="/g) ?? []).length).toBe(1);
    expect((root.match(/\sheight="/g) ?? []).length).toBe(1);
  });

  it("throws on an unknown name", () => {
    expect(() => brandMarkSvg("not-a-brand" as BrandMarkName)).toThrow(RangeError);
  });

  it("isBrandMarkName guards correctly", () => {
    expect(isBrandMarkName("visa")).toBe(true);
    expect(isBrandMarkName("nope")).toBe(false);
  });
});
