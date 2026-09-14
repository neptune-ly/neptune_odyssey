// Neptune Odyssey — per-bank icon profiles · © 2026 Neptune.Fintech (neptune.ly)
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// ONE roster, THREE FAMILIES. A bank's icon set is not the shared roster redrawn
// at a different stroke weight — that was the earlier shape of this table and it
// was rejected, because changing the stroke of one drawing is a filter, not a
// vocabulary. Each bank now draws from a different professionally drawn,
// permissively licensed family, chosen because its house style is that bank's
// charter entry, and the per-bank difference is WHICH GLYPH OF WHICH FAMILY —
// data, in this table and in `bank-sets/library_map.json`.
//
// These are the same values `bank-sets/emit.py` applies when it writes the
// Flutter apps' SVG assets. `test/profiles.test.ts` reads that file and fails if
// the two drift, so the table cannot be true in one platform and stale in
// another.
//
// A NOTE ON THE STROKE FIELDS, so nobody reads them as the old filter. All three
// primary families are FILLED-PATH sets: their "outline" look is a closed shape,
// not a stroked one, so a stroke weight cannot reach them and none is applied.
// The `gap*` fields exist for the STROKE-DRAWN gap-fillers — the handful of
// glyphs a bank's own family does not ship — so a fill-in sits inside its bank's
// vocabulary instead of announcing itself. Odyssey's own web ICONS map is also a
// stroke family, which is why `iconSvg({ profile })` renders through them.

/** The banks Odyssey ships an icon profile for. */
export type IconProfileName = "andalus" | "nuran" | "fglb";

export interface IconProfile {
  /** The family this bank's asset set is drawn from. */
  readonly family: string;
  /** Its licence, recorded here because an app is a redistribution. */
  readonly familyLicence: "MIT" | "Apache-2.0" | "ISC";
  /**
   * Where a glyph comes from when the bank's own family does not ship it.
   *
   * NEVER another bank's family: filling Nuran's missing credit card from
   * Material Sharp made Nuran and FGLB draw the identical card, because Sharp
   * and Outlined are the same paths.
   */
  readonly gapFamily: string;
  /** Optical size: how much of the 24 box the glyph claims. */
  readonly scale: number;
  /** Does this bank's selected/active state use a natively FILLED cut? */
  readonly filledActiveState: boolean;

  /** Stroke weight for a stroke-drawn gap-fill only. See the note above. */
  readonly gapStroke: number;
  readonly gapLinecap: "round" | "butt" | "square";
  readonly gapLinejoin: "round" | "miter";
  readonly gapMiterlimit: number;
}

export const ICON_PROFILES: Record<IconProfileName, IconProfile> = {
  // Confident, card-led, warmest, roundest. Phosphor is the only high-coverage
  // family that ships `fill` as its own drawn weight, which is what the one bank
  // with a filled selected state actually needs.
  andalus: {
    family: "phosphor",
    familyLicence: "MIT",
    gapFamily: "tabler",
    scale: 1.0,
    filledActiveState: true,
    gapStroke: 1.6,
    gapLinecap: "round",
    gapLinejoin: "round",
    gapMiterlimit: 4,
  },
  // Quiet, documentary, institutional. Carbon is IBM's enterprise design
  // language: flat terminals, orthogonal construction, no ornament, the thinnest
  // ink of the three. No filled state — the nav pill already carries selection,
  // and a second signal for one fact is two things arguing.
  nuran: {
    family: "carbon",
    familyLicence: "Apache-2.0",
    gapFamily: "iconoir",
    scale: 0.94,
    filledActiveState: false,
    gapStroke: 1.7,
    gapLinecap: "butt",
    gapLinejoin: "miter",
    gapMiterlimit: 2,
  },
  // Institutional and spacious. Material Symbols draw a 20dp live area inside a
  // 24dp box, so the space is the grid rather than a per-glyph choice; weight 600
  // matches this bank's declared heaviest ink. Nothing in the set names a colour,
  // so the bank's one red spend per screen is never taken by an icon.
  fglb: {
    family: "msym",
    familyLicence: "Apache-2.0",
    gapFamily: "lucide",
    scale: 0.94,
    filledActiveState: false,
    gapStroke: 1.9,
    gapLinecap: "butt",
    gapLinejoin: "miter",
    gapMiterlimit: 2,
  },
};

/** All profile names, in charter order. */
export const ICON_PROFILE_NAMES: IconProfileName[] = ["andalus", "nuran", "fglb"];

/** True when `name` is a known profile. Acts as a type guard. */
export function isIconProfileName(name: string): name is IconProfileName {
  return Object.prototype.hasOwnProperty.call(ICON_PROFILES, name);
}

/**
 * The profile for `name`.
 *
 * @throws RangeError when `name` is not a bank Odyssey has a profile for.
 *
 * There is deliberately NO default. A bank with no profile must fail here
 * rather than silently render in another bank's voice — the same rule the
 * asset roots follow, for the same reason.
 */
export function iconProfile(name: IconProfileName): IconProfile {
  if (!isIconProfileName(name)) {
    throw new RangeError(
      `No Neptune icon profile for "${String(name)}". Add it to ICON_PROFILES — ` +
        `do not fall back to another bank's.`,
    );
  }
  return ICON_PROFILES[name];
}
