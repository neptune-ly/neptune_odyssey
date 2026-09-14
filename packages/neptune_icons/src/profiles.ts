// Neptune Odyssey — per-bank icon profiles · © 2026 Neptune.Fintech (neptune.ly)
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// ONE roster, THREE renderings. A bank's icon set is not a separate drawing of
// every glyph — it is the shared roster drawn through that bank's profile. The
// difference between the banks is therefore DATA, in this table, and nothing
// downstream asks which bank it is drawing.
//
// These are the same numbers `bank-sets/emit.py` applies when it writes the
// Flutter apps' SVG assets. `test/profiles.test.ts` reads that file and fails
// if the two drift, so the table cannot be true in one platform and stale in
// another.

/** The banks Odyssey ships an icon profile for. */
export type IconProfileName = "andalus" | "nuran" | "fglb";

export interface IconProfile {
  /** Stroke weight in viewBox units, at the canonical 24 grid. */
  readonly strokeWidth: number;
  readonly linecap: "round" | "butt" | "square";
  readonly linejoin: "round" | "miter";
  readonly miterlimit: number;
  /** Optical size: how much of the 24 box the glyph claims. */
  readonly scale: number;
  /** Multiplier applied to every corner radius in the source geometry. */
  readonly cornerScale: number;
  /**
   * Coordinate snap in viewBox units; 0 keeps the drawn curve.
   * Nuran's set is drawn on a grid because a ledger is.
   */
  readonly grid: number;
  /** Does this bank's selected/active state use a filled cut of the glyph? */
  readonly filledActiveState: boolean;
}

export const ICON_PROFILES: Record<IconProfileName, IconProfile> = {
  // Confident, card-led, roundest of the three. The only bank with a filled
  // state, and the only one that keeps its own drawings — 1.25 is what its
  // existing set measured at, not a number chosen for it.
  andalus: {
    strokeWidth: 1.25,
    linecap: "round",
    linejoin: "round",
    miterlimit: 4,
    scale: 1.0,
    cornerScale: 1.4,
    grid: 0,
    filledActiveState: true,
  },
  // Quiet, documentary. Finest stroke, drawn smallest in the box, every corner
  // square, every coordinate on a 0.25 grid. Marks in a ledger. No filled
  // state: the nav pill already carries selection, and a second signal for one
  // fact is two things arguing.
  nuran: {
    strokeWidth: 1.0,
    linecap: "butt",
    linejoin: "miter",
    miterlimit: 2,
    scale: 0.88,
    cornerScale: 0.0,
    grid: 0.25,
    filledActiveState: false,
  },
  // Institutional. Heaviest stroke, square terminals, full-frame, right-angled.
  // Nothing in the set names a colour, so the bank's one red spend per screen
  // is never taken by an icon.
  fglb: {
    strokeWidth: 1.6,
    linecap: "square",
    linejoin: "miter",
    miterlimit: 2,
    scale: 1.0,
    cornerScale: 0.65,
    grid: 0,
    filledActiveState: false,
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
 * rather than silently render in another bank's weight — the same rule the
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
