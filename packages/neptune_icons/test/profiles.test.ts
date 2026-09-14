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

/** Pull one bank's row out of emit.py's PROFILES table.
 *
 * The row now spans two lines and carries a `libs=[...]` list, so the scan runs
 * from the bank's key to the closing `)` rather than over a single line. */
function pythonProfile(bank: string): Record<string, string> {
  const m = new RegExp(`"${bank}":\\s*dict\\(`).exec(emitPy);
  expect(m !== null, `emit.py has no profile for ${bank}`).toBe(true);
  const start = m!.index;
  const row = emitPy.slice(start, emitPy.indexOf("),", start));
  const out: Record<string, string> = {};
  const libs = row.match(/libs=\[([^\]]*)\]/);
  if (libs) out.libs = libs[1].replace(/["\s]/g, "");
  for (const [, k, v] of row.matchAll(/(\w+)=("?[\w.]+"?)(?!\w)/g)) {
    if (k !== "libs") out[k] = v.replace(/"/g, "");
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
      const libs = py.libs.split(",");
      expect(libs[0]).toBe(ts.family);
      expect(libs[1]).toBe(ts.gapFamily);
      expect(Number(py.scale)).toBe(ts.scale);
      expect(py.filledActive).toBe(ts.filledActiveState ? "True" : "False");
      expect(Number(py.gapStroke)).toBe(ts.gapStroke);
      expect(py.gapCap).toBe(ts.gapLinecap);
      expect(py.gapJoin).toBe(ts.gapLinejoin);
      expect(Number(py.gapMiter)).toBe(ts.gapMiterlimit);
    },
  );

  it("gives each bank a DIFFERENT family, and never another bank's as its filler", () => {
    const families = ICON_PROFILE_NAMES.map((n) => ICON_PROFILES[n].family);
    expect(new Set(families).size).toBe(3);
    // THE TRAP THIS GUARDS. Filling Nuran's missing credit card from Material
    // Sharp made Nuran and FGLB draw the identical card, because Sharp and
    // Outlined are the same paths. A gap-filler must never be a bank's family.
    for (const n of ICON_PROFILE_NAMES) {
      expect(families).not.toContain(ICON_PROFILES[n].gapFamily);
    }
  });

  it("records a permissive licence for every family it ships", () => {
    for (const n of ICON_PROFILE_NAMES) {
      expect(["MIT", "Apache-2.0", "ISC"]).toContain(ICON_PROFILES[n].familyLicence);
    }
  });

  it("has NO default — a bank with no profile throws", () => {
    expect(isIconProfileName("sahara")).toBe(false);
    expect(() => iconProfile("sahara" as IconProfileName)).toThrow(RangeError);
    // The whole point: it must not quietly render as Andalus.
    expect(() => iconSvg("home", { profile: "sahara" as IconProfileName })).toThrow(
      RangeError,
    );
  });

  it("renders each bank's own terminal on the web family", () => {
    const nuran = iconSvg("home", { profile: "nuran" });
    expect(nuran).toContain('stroke-linecap="butt"');
    expect(nuran).toContain('data-npt-profile="nuran"');
    // 1.7 / 0.94 — the group scale is compensated for, so the ink is 1.7 wide.
    expect(nuran).toContain(`stroke-width="${1.7 / 0.94}"`);
    expect(nuran).toContain("scale(0.94)");

    const fglb = iconSvg("home", { profile: "fglb" });
    expect(fglb).toContain('stroke-linecap="butt"');
    expect(fglb).toContain(`stroke-width="${1.9 / 0.94}"`);

    const andalus = iconSvg("home", { profile: "andalus" });
    expect(andalus).toContain('stroke-linecap="round"');
    expect(andalus).toContain('stroke-width="1.6"');

    // And an unprofiled call is untouched — the family's native cut.
    expect(iconSvg("home")).toContain('stroke-width="1.8"');
    expect(iconSvg("home")).not.toContain("data-npt-profile");
  });
});
