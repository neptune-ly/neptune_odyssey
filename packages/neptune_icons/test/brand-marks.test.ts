// Neptune Odyssey — brand-mark contract tests · © 2026 Neptune.Fintech (neptune.ly)
import { describe, it, expect, afterEach } from "vitest";
import {
  BRAND_MARKS,
  BRAND_MARK_NAMES,
  brandMarkSvg,
  isBrandMarkName,
  registerBrandMark,
  unregisterBrandMark,
  hasBrandMarkOverride,
} from "../src/brand-marks.js";
import type { BrandMarkName, BrandMarkVariant } from "../src/brand-marks.js";
import { ICONS } from "../src/icons.js";

const VARIANTS: BrandMarkVariant[] = ["color", "mono", "outline"];

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

describe("three-variant rendering", () => {
  // A spread of marks: text-only, multicolour fills, and stroke/line marks.
  const SAMPLE: BrandMarkName[] = [
    "visa",
    "mastercard",
    "onepay",
    "lypay",
    "contactless-pay",
    "bank-building",
  ];

  it("returns a valid <svg> for each variant of several marks", () => {
    for (const name of SAMPLE) {
      for (const variant of VARIANTS) {
        const svg = brandMarkSvg(name, { variant });
        expect(svg.startsWith("<svg"), `${name}/${variant} should start <svg`).toBe(true);
        expect(svg.endsWith("</svg>"), `${name}/${variant} should end </svg>`).toBe(true);
        expect(svg).toMatch(/viewBox="0 0 \d+ \d+"/);
        expect(svg).toContain(`data-variant="${variant}"`);
      }
    }
  });

  it("EVERY mark renders cleanly in all three variants", () => {
    for (const name of BRAND_MARK_NAMES) {
      for (const variant of VARIANTS) {
        const svg = brandMarkSvg(name, { variant });
        expect(svg.startsWith("<svg"), `${name}/${variant}`).toBe(true);
        expect(svg.endsWith("</svg>"), `${name}/${variant}`).toBe(true);
      }
    }
  });

  it("mono uses currentColor and carries no brand hex colours", () => {
    for (const name of BRAND_MARK_NAMES) {
      const svg = brandMarkSvg(name, { variant: "mono" });
      expect(svg, `${name} mono missing currentColor`).toContain("currentColor");
      // No literal hex colours in a mono silhouette.
      expect(svg, `${name} mono leaks a hex colour`).not.toMatch(/#[0-9A-Fa-f]{3,6}/);
    }
  });

  it("outline uses stroke=currentColor and fill=none, no brand hex", () => {
    for (const name of BRAND_MARK_NAMES) {
      const svg = brandMarkSvg(name, { variant: "outline" });
      expect(svg, `${name} outline`).toContain('stroke="currentColor"');
      expect(svg, `${name} outline`).toMatch(/fill="none"|fill:none/);
      expect(svg, `${name} outline leaks a hex colour`).not.toMatch(/#[0-9A-Fa-f]{3,6}/);
    }
  });

  it("color is the default variant and keeps brand colours", () => {
    const def = brandMarkSvg("mastercard");
    const explicit = brandMarkSvg("mastercard", { variant: "color" });
    expect(def).toBe(explicit);
    expect(def).toContain("#EB001B"); // Mastercard red
  });

  it("variant marks still size to a height and preserve aspect ratio", () => {
    for (const variant of VARIANTS) {
      const svg = brandMarkSvg("visa", { height: 16, variant });
      const root = svg.slice(0, svg.indexOf(">") + 1);
      expect(root).toContain('height="16"');
      expect(root).toContain('width="24"');
    }
  });
});

describe("new + refined marks", () => {
  it("onepay and lypay exist in BRAND_MARK_NAMES", () => {
    expect(BRAND_MARK_NAMES).toContain("onepay");
    expect(BRAND_MARK_NAMES).toContain("lypay");
    expect(isBrandMarkName("onepay")).toBe(true);
    expect(isBrandMarkName("lypay")).toBe(true);
  });

  it("refined Libyan placeholders all render in three variants", () => {
    for (const name of ["numo", "moamalat", "sadad", "tadawul"] as BrandMarkName[]) {
      for (const variant of VARIANTS) {
        expect(brandMarkSvg(name, { variant }).startsWith("<svg")).toBe(true);
      }
    }
  });
});

describe("official-asset override API", () => {
  afterEach(() => {
    // Keep tests isolated.
    for (const name of BRAND_MARK_NAMES) unregisterBrandMark(name);
    unregisterBrandMark("my-bank");
  });

  it("registerBrandMark(string) overrides every variant", () => {
    registerBrandMark("visa", "<svg>X</svg>");
    expect(hasBrandMarkOverride("visa")).toBe(true);
    expect(brandMarkSvg("visa")).toBe("<svg>X</svg>");
    expect(brandMarkSvg("visa", { variant: "mono" })).toBe("<svg>X</svg>");
    expect(brandMarkSvg("visa", { variant: "outline" })).toBe("<svg>X</svg>");
  });

  it("registerBrandMark(per-variant) returns the matching variant", () => {
    registerBrandMark("mastercard", {
      color: '<svg viewBox="0 0 48 32">COLOR</svg>',
      mono: '<svg viewBox="0 0 48 32">MONO</svg>',
      outline: '<svg viewBox="0 0 48 32">OUTLINE</svg>',
    });
    expect(brandMarkSvg("mastercard", { variant: "color" })).toContain("COLOR");
    expect(brandMarkSvg("mastercard", { variant: "mono" })).toContain("MONO");
    expect(brandMarkSvg("mastercard", { variant: "outline" })).toContain("OUTLINE");
  });

  it("falls back across variants when only one is provided", () => {
    registerBrandMark("amex", { color: '<svg viewBox="0 0 48 32">ONLY</svg>' });
    expect(brandMarkSvg("amex", { variant: "mono" })).toContain("ONLY");
    expect(brandMarkSvg("amex", { variant: "outline" })).toContain("ONLY");
  });

  it("an override is sized to a requested height", () => {
    registerBrandMark("visa", '<svg viewBox="0 0 48 32">X</svg>');
    const svg = brandMarkSvg("visa", { height: 16 });
    const root = svg.slice(0, svg.indexOf(">") + 1);
    expect(root).toContain('height="16"');
    expect(root).toContain('width="24"');
  });

  it("lets you register a brand-new (non-bundled) name", () => {
    registerBrandMark("my-bank", "<svg>BANK</svg>");
    expect(hasBrandMarkOverride("my-bank")).toBe(true);
    // brandMarkSvg accepts arbitrary registered names at runtime.
    expect(brandMarkSvg("my-bank" as BrandMarkName)).toBe("<svg>BANK</svg>");
  });

  it("still throws for an unknown name with no override", () => {
    expect(() => brandMarkSvg("not-a-brand" as BrandMarkName)).toThrow(RangeError);
  });
});
