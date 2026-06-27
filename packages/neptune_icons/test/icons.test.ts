// Neptune Odyssey — icon contract tests · © 2026 Neptune.Fintech (neptune.ly)
import { describe, it, expect } from "vitest";
import { ICONS } from "../src/icons.js";
import { ICON_NAMES } from "../src/types.js";
import { iconSvg, isIconName } from "../src/svg.js";
import type { IconName } from "../src/types.js";

describe("ICONS map ↔ ICON_NAMES roster", () => {
  it("every IconName has an entry in ICONS", () => {
    for (const name of ICON_NAMES) {
      expect(ICONS[name], `missing path for "${name}"`).toBeTruthy();
      expect(typeof ICONS[name]).toBe("string");
    }
  });

  it("ICON_NAMES exactly matches the ICONS keys (no drift, no dupes)", () => {
    const mapKeys = Object.keys(ICONS).sort();
    const roster = [...ICON_NAMES].sort();
    expect(roster).toEqual(mapKeys);
    expect(new Set(ICON_NAMES).size).toBe(ICON_NAMES.length);
  });

  it("ships at least 50 icons", () => {
    expect(ICON_NAMES.length).toBeGreaterThanOrEqual(50);
  });
});

describe("iconSvg()", () => {
  it("returns a complete <svg> with the 24×24 viewBox and inner markup", () => {
    for (const name of ICON_NAMES) {
      const svg = iconSvg(name);
      expect(svg.startsWith("<svg")).toBe(true);
      expect(svg.endsWith("</svg>")).toBe(true);
      expect(svg).toContain('viewBox="0 0 24 24"');
      expect(svg).toContain(ICONS[name]);
      expect(svg).toContain('stroke="currentColor"');
    }
  });

  it("honours size, stroke and class options", () => {
    const svg = iconSvg("card", { size: 32, stroke: 2, class: "lead" });
    expect(svg).toContain('width="32"');
    expect(svg).toContain('height="32"');
    expect(svg).toContain('stroke-width="2"');
    expect(svg).toContain('class="lead"');
  });

  it("throws on an unknown name", () => {
    expect(() => iconSvg("not-a-real-icon" as IconName)).toThrow(RangeError);
  });

  it("isIconName guards correctly", () => {
    expect(isIconName("card")).toBe(true);
    expect(isIconName("nope")).toBe(false);
  });
});

describe("SVG validity & uniqueness", () => {
  it("inner markup carries no <svg>, no inline style, no literal colour", () => {
    for (const name of ICON_NAMES) {
      const inner = ICONS[name];
      // geometry width/height on <rect>/<circle> is fine; an embedded <svg>,
      // an inline style, or a hard-coded hex colour is not.
      expect(inner).not.toContain("<svg");
      expect(inner).not.toMatch(/\bstyle=/);
      expect(inner).not.toMatch(/#[0-9a-fA-F]{3,6}/);
      // balanced tag delimiters
      const open = (inner.match(/</g) ?? []).length;
      const close = (inner.match(/>/g) ?? []).length;
      expect(open, `unbalanced tags in "${name}"`).toBe(close);
      expect(open).toBeGreaterThan(0);
    }
  });

  it("only the root <svg> carries viewBox/width/height (never the inner markup)", () => {
    for (const name of ICON_NAMES) {
      const svg = iconSvg(name);
      const root = svg.slice(0, svg.indexOf(">") + 1);
      expect(root).toContain('viewBox="0 0 24 24"');
      // exactly one viewBox / one root width / one root height in the whole doc
      expect((svg.match(/viewBox=/g) ?? []).length).toBe(1);
      // the inner data must not declare its own viewBox
      expect(ICONS[name]).not.toMatch(/viewBox=/);
    }
  });

  it("no two icons share identical path data (catches copy-paste)", () => {
    const seen = new Map<string, IconName>();
    for (const name of ICON_NAMES) {
      const inner = ICONS[name];
      const prior = seen.get(inner);
      expect(prior, `"${name}" duplicates "${prior}"`).toBeUndefined();
      seen.set(inner, name);
    }
  });

  it("every inner markup uses currentColor or none for fill/stroke only", () => {
    for (const name of ICON_NAMES) {
      const inner = ICONS[name];
      // any fill/stroke attribute present must be currentColor or none
      for (const m of inner.matchAll(/(?:fill|stroke)="([^"]*)"/g)) {
        expect(["currentColor", "none"], `bad color in "${name}"`).toContain(m[1]);
      }
    }
  });
});
