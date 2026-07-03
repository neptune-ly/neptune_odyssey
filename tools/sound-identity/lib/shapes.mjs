// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Melodic "shapes" — the structural idea behind a bank's sound identity
// (as distinct from its *timbre*, which comes from the soundfont patch).
// Two banks can even share a patch (Andalus and Nuran both use the Cosmic
// Vibraphone patch, 32) and still sound distinct because their SHAPE
// differs — one a rising two-note phrase, the other a tap-tap-chord
// rhythm. Adding a new bank should usually mean picking an unclaimed
// (shape, patch) pair, not necessarily inventing a new shape.
//
// Every shape implements the same derivation rule (from
// neptune-mobile's SOUND_IDENTITY_HANDOFF.md §6):
//   general   = the hero phrase, trimmed to ~1.6–1.7s
//   money_in  = brighter/warmer variant (wider or major interval, higher register)
//   security  = wider interval + faster attack — more presence, still soft
//   reminder  = a single note only — calmest, quietest of the family
//   success   = the full hero phrase, ~2.2–2.4s

const PPQ = 480;

// Shape math below multiplies PPQ by fractional beat values (e.g. `PPQ *
// 0.18`), which doesn't always land on an integer tick — round here so
// every caller is safe rather than trusting each call site to round.
function note(tick, duration, pitch, velocity = 96) {
  return { tick: Math.round(tick), duration: Math.round(duration), pitch, velocity };
}

/**
 * A rising two-note phrase (Andalus's structural family): base note up to
 * base+interval. `interval` in semitones; `fast` shortens durations/attack
 * for the security variant.
 */
function risingPhrase({ baseNote, patch }) {
  const track = (notes) => ({
    ppq: PPQ,
    tempoBpm: 100,
    tracks: [{ channel: 0, program: patch, notes }],
  });

  const phrase = (interval, { firstDur, gap, secondDur, vel1 = 92, vel2 = 104 }) =>
    track([
      note(0, firstDur, baseNote, vel1),
      note(firstDur + gap, secondDur, baseNote + interval, vel2),
    ]);

  return {
    success: phrase(12, { firstDur: PPQ * 0.9, gap: PPQ * 0.1, secondDur: PPQ * 1.8 }), // octave call, long
    general: phrase(12, { firstDur: PPQ * 0.55, gap: PPQ * 0.08, secondDur: PPQ * 0.85 }),
    money_in: phrase(4, { firstDur: PPQ * 0.5, gap: PPQ * 0.08, secondDur: PPQ * 0.95, vel2: 110 }), // major third, brighter landing
    security: phrase(7, { firstDur: PPQ * 0.35, gap: PPQ * 0.04, secondDur: PPQ * 0.75, vel1: 100, vel2: 112 }), // fifth, faster attack
    reminder: track([note(0, PPQ * 0.9, baseNote, 72)]), // single soft note, no second note
  };
}

/**
 * A tap-tap-chord rhythm (Nuran's structural family): two quick same-pitch
 * taps, then a landing chord. `chordPatch` (defaults to `patch`) lets the
 * chord layer use a second, softer voice — Nuran layers Delicate Bells (119)
 * over its Cosmic Vibraphone taps.
 */
function tapChord({ baseNote, patch, layerPatch }) {
  const chordPatch = layerPatch ?? patch;
  const tapDur = PPQ * 0.18;
  const tapGap = PPQ * 0.22;

  const build = (chordIntervals, { chordDur, tapVel = 100, chordVel = 90, tapsOnly = false }) => {
    const tracks = [
      {
        channel: 0,
        program: patch,
        notes: [
          note(0, tapDur, baseNote, tapVel),
          note(tapGap, tapDur, baseNote, tapVel + 6),
        ],
      },
    ];
    if (!tapsOnly) {
      const chordStart = tapGap * 2;
      tracks.push({
        channel: 1,
        program: chordPatch,
        notes: chordIntervals.map((iv) => note(chordStart, chordDur, baseNote + iv, chordVel)),
      });
    }
    return { ppq: PPQ, tempoBpm: 100, tracks };
  };

  return {
    success: build([0, 4, 7], { chordDur: PPQ * 1.6 }), // major triad landing, full length
    general: build([0, 4, 7], { chordDur: PPQ * 1.0 }),
    money_in: build([0, 4, 7, 12], { chordDur: PPQ * 1.1, chordVel: 100 }), // + octave doubling, brighter
    security: build([0, 3, 7, 10], { chordDur: PPQ * 0.9, tapVel: 112, chordVel: 100 }), // minor 7th, more presence
    reminder: build([], { chordDur: 0, tapsOnly: true, tapVel: 76 }), // single tap rhythm only, no chord
  };
}

export const SHAPES = { 'rising-phrase': risingPhrase, 'tap-chord': tapChord };

/** Target trim length (seconds, before fade) per cue — matches the handoff's derivation rule. */
export const CUE_DURATIONS = {
  success: 2.3,
  general: 1.65,
  money_in: 1.6,
  security: 1.4,
  reminder: 1.0,
};

export const FADE_DURATIONS = {
  success: 0.5,
  general: 0.35,
  money_in: 0.35,
  security: 0.3,
  reminder: 0.35,
};
