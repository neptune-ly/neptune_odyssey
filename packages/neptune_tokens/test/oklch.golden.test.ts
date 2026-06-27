// OKLCH→sRGB golden test.
//
// Two guarantees (see src/color/oklch.ts header):
//  (A) The PINNED reference palettes (getResolvedPalette) equal tokens.resolved.json
//      EXACTLY — this is what makes Flutter == Web for reference brands.
//  (B) The shared converter reproduces tokens.resolved.json to <= 1 LSB per channel
//      (>= 90% exact; residual is sub-perceptual browser rounding at gamut edges).
//      Used for custom seeds, where TS and Dart run identical math.
import { describe, it, expect } from "vitest";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { oklchToHex, parseOklch } from "../src/color/oklch.js";
import { getResolvedPalette } from "../src/resolve.js";
import { BRANDS, MODES, COLOR_ROLES } from "../src/types.js";

const read = (p: string) => readFileSync(fileURLToPath(new URL(p, import.meta.url)), "utf8");
const resolved = JSON.parse(read("../assets/tokens.resolved.json"));
const css = read("../assets/themes.css");

// Parse the themes.css cascade: base block + dark override per brand.
function blockBody(selector: string): string {
  const i = css.indexOf(selector);
  if (i < 0) return "";
  const s = css.indexOf("{", i);
  const e = css.indexOf("}", s);
  return css.slice(s + 1, e);
}
function parseRoles(body: string): Record<string, { L: number; C: number; H: number }> {
  const map: Record<string, { L: number; C: number; H: number }> = {};
  const re = /(--md-sys-color-[a-z-]+)\s*:\s*(oklch\([^)]+\))/g;
  let m: RegExpExecArray | null;
  while ((m = re.exec(body))) {
    const c = parseOklch(m[2]!);
    if (c) map[m[1]!.replace(/^--/, "")] = c;
  }
  return map;
}
const baseSel: Record<string, string> = {
  neptune: ':root,[data-theme="neptune"]',
  triton: '[data-theme="triton"]',
  nereid: '[data-theme="nereid"]',
  proteus: '[data-theme="proteus"]',
};
const darkSel: Record<string, string> = {
  neptune: '[data-theme="neptune"][data-mode="dark"]',
  triton: '[data-theme="triton"][data-mode="dark"]',
  nereid: '[data-theme="nereid"][data-mode="dark"]',
  proteus: '[data-theme="proteus"][data-mode="dark"]',
};

const chanDelta = (a: string, b: string): [number, number, number] => {
  const ai = parseInt(a.slice(1), 16);
  const bi = parseInt(b.slice(1), 16);
  return [
    Math.abs((ai >> 16) - (bi >> 16)),
    Math.abs(((ai >> 8) & 255) - ((bi >> 8) & 255)),
    Math.abs((ai & 255) - (bi & 255)),
  ];
};

describe("(A) pinned reference palettes == tokens.resolved.json EXACTLY", () => {
  for (const brand of BRANDS) {
    for (const mode of MODES) {
      it(`${brand}/${mode}`, () => {
        const pal = getResolvedPalette(brand, mode);
        const want = resolved.themes[brand][mode];
        for (const role of COLOR_ROLES) {
          expect(pal[role].toLowerCase()).toBe(want[`md-sys-color-${role}`].hex.toLowerCase());
        }
      });
    }
  }
});

describe("(B) converter reproduces tokens.resolved.json within <= 1 LSB", () => {
  let total = 0;
  let exact = 0;
  let maxDelta = 0;
  const fails: string[] = [];

  for (const brand of BRANDS) {
    const base = parseRoles(blockBody(baseSel[brand]!));
    const dark = { ...base, ...parseRoles(blockBody(darkSel[brand]!)) };
    for (const mode of MODES) {
      const vars = mode === "light" ? base : dark;
      const want = resolved.themes[brand][mode];
      for (const role of COLOR_ROLES) {
        const key = `md-sys-color-${role}`;
        if (!vars[key]) continue;
        total++;
        const got = oklchToHex(vars[key]!).toLowerCase();
        const exp = (want[key].hex as string).toLowerCase();
        const d = Math.max(...chanDelta(got, exp));
        maxDelta = Math.max(maxDelta, d);
        if (got === exp) exact++;
        else if (d > 1) fails.push(`${brand}/${mode} ${role}: ${got} vs ${exp} (Δ${d})`);
      }
    }
  }

  it("no role differs by more than 1 LSB in any channel", () => {
    expect(fails, fails.join("\n")).toHaveLength(0);
    expect(maxDelta).toBeLessThanOrEqual(1);
  });

  it("at least 90% of roles match exactly", () => {
    expect(exact / total).toBeGreaterThanOrEqual(0.9);
  });

  it("covers the full 4 brands × 2 modes × 37 roles", () => {
    expect(total).toBe(BRANDS.length * MODES.length * COLOR_ROLES.length);
  });
});
