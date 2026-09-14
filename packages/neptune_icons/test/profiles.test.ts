// Neptune Odyssey — per-bank icon profile contract · © 2026 Neptune.Fintech
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";
import { ICON_PROFILES, ICON_PROFILE_NAMES, iconProfile, isIconProfileName } from "../src/profiles.js";
import { iconSvg } from "../src/svg.js";
import type { IconProfileName } from "../src/profiles.js";

const emitPy = readFileSync(
  fileURLToPath(new URL("../bank-sets/emit.py", import.meta.url)),
  "utf8",
);

/** Pull one bank's row out of emit.py's PROFILES table. */
function pythonProfile(bank: string): Record<string, string> {
  const line = emitPy
    .split("\n")
    .find((l) => l.trim().startsWith(`"${bank}":`));
  expect(line, `emit.py has no profile for ${bank}`).toBeTruthy();
  const out: Record<string, string> = {};
  for (const [, k, v] of line!.matchAll(/(\w+)=("?[\w.]+"?)/g)) {
    out[k] = v.replace(/"/g, "");
  }
  return out;
}

describe("the three banks' icon profiles", () => {
  it("names exactly the banks the platform ships", () => {
    expect(ICON_PROFILE_NAMES.sort()).toEqual(["andalus", "fglb", "nuran"]);
    expect(Object.keys(ICON_PROFILES).sort()).toEqual(ICON_PROFILE_NAMES.sort());
  });

  // THE POINT OF THIS FILE. The Flutter apps' assets are written by emit.py and
  // the web renders through iconSvg(); if the two tables drift, one platform
  // ships a bank in another bank's weight and nothing says so.
  it.each(["andalus", "nuran", "fglb"] as IconProfileName[])(
    "%s matches the generator that writes the Flutter assets",
    (bank) => {
      const py = pythonProfile(bank);
      const ts = ICON_PROFILES[bank];
      expect(Number(py.stroke)).toBe(ts.strokeWidth);
      expect(py.cap).toBe(ts.linecap);
      expect(py.join).toBe(ts.linejoin);
      expect(Number(py.miter)).toBe(ts.miterlimit);
      expect(Number(py.scale)).toBe(ts.scale);
      expect(Number(py.rx)).toBe(ts.cornerScale);
      expect(Number(py.quant)).toBe(ts.grid);
      expect(py.filledActive).toBe(ts.filledActiveState ? "True" : "False");
    },
  );

  it("keeps the three visibly apart on every lever that shows", () => {
    const strokes = ICON_PROFILE_NAMES.map((n) => ICON_PROFILES[n].strokeWidth);
    const caps = ICON_PROFILE_NAMES.map((n) => ICON_PROFILES[n].linecap);
    const corners = ICON_PROFILE_NAMES.map((n) => ICON_PROFILES[n].cornerScale);
    expect(new Set(strokes).size).toBe(3);
    expect(new Set(caps).size).toBe(3);
    expect(new Set(corners).size).toBe(3);
    // The charter's ordering: Nuran squarest, Andalus roundest, FGLB between.
    expect(ICON_PROFILES.nuran.cornerScale).toBeLessThan(ICON_PROFILES.fglb.cornerScale);
    expect(ICON_PROFILES.fglb.cornerScale).toBeLessThan(ICON_PROFILES.andalus.cornerScale);
    expect(ICON_PROFILES.nuran.strokeWidth).toBeLessThan(ICON_PROFILES.andalus.strokeWidth);
    expect(ICON_PROFILES.andalus.strokeWidth).toBeLessThan(ICON_PROFILES.fglb.strokeWidth);
  });

  it("has NO default — a bank with no profile throws", () => {
    expect(isIconProfileName("sahara")).toBe(false);
    expect(() => iconProfile("sahara" as IconProfileName)).toThrow(RangeError);
    // The whole point: it must not quietly render as Andalus.
    expect(() => iconSvg("home", { profile: "sahara" as IconProfileName })).toThrow(
      RangeError,
    );
  });

  it("renders each bank's own weight and terminal", () => {
    const nuran = iconSvg("home", { profile: "nuran" });
    expect(nuran).toContain('stroke-linecap="butt"');
    expect(nuran).toContain('data-npt-profile="nuran"');
    // 1.0 / 0.88 — the group scale is compensated for, so the ink is 1.0 wide.
    expect(nuran).toContain(`stroke-width="${1.0 / 0.88}"`);
    expect(nuran).toContain("scale(0.88)");

    const fglb = iconSvg("home", { profile: "fglb" });
    expect(fglb).toContain('stroke-linecap="square"');
    expect(fglb).toContain('stroke-width="1.6"');

    const andalus = iconSvg("home", { profile: "andalus" });
    expect(andalus).toContain('stroke-linecap="round"');
    expect(andalus).toContain('stroke-width="1.25"');

    // And an unprofiled call is untouched — the family's native cut.
    expect(iconSvg("home")).toContain('stroke-width="1.8"');
    expect(iconSvg("home")).not.toContain("data-npt-profile");
  });
});
