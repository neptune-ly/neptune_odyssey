// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// A minimal, hand-rolled Standard MIDI File (SMF format 1) encoder — no
// external MIDI library needed for the short melodic phrases this generator
// produces. Ported from the pipeline documented in neptune-mobile's
// SOUND_IDENTITY_HANDOFF.md, carrying forward two real bugs already found
// and fixed there — DO NOT reintroduce either:
//
//   1. A variable-length-quantity delta MUST reject negative input. A
//      negative delta silently spins forever under JS's `>>` on negative
//      numbers approaching -1 (never reaching 0) — this hung a background
//      process at ~90% CPU for 10+ minutes before being caught upstream.
//   2. Events must be built with ABSOLUTE tick times and SORTED BY TIME
//      before delta-encoding — never assume caller order is chronological
//      (overlapping/legato notes are naturally listed out of order, e.g. a
//      chord's notes, or a note-off arriving after the next note's note-on).

/** Variable-length quantity encode — the SMF delta-time format. */
function vlq(n) {
  if (n < 0 || !Number.isInteger(n)) {
    throw new RangeError(`vlq() requires a non-negative integer, got ${n}`);
  }
  const bytes = [n & 0x7f];
  n >>= 7;
  while (n > 0) {
    bytes.unshift((n & 0x7f) | 0x80);
    n >>= 7;
  }
  return Buffer.from(bytes);
}

function u32(n) {
  const b = Buffer.alloc(4);
  b.writeUInt32BE(n >>> 0, 0);
  return b;
}

function u16(n) {
  const b = Buffer.alloc(2);
  b.writeUInt16BE(n, 0);
  return b;
}

/**
 * Encode one track's absolute-time events into MTrk bytes.
 * @param {Array<{tick:number, bytes:number[]}>} events - absolute-tick events
 *   (each `bytes` is the raw MIDI event bytes, e.g. [0x90|ch, pitch, vel]).
 * @param {boolean} isTempoTrack - true for track 0 in format 1 (adds a Set
 *   Tempo meta event at tick 0).
 * @param {number} [microsecondsPerQuarter]
 */
function encodeTrack(events, { tempoUsPerQuarter } = {}) {
  // Sort by ABSOLUTE tick before delta-encoding (bug #2 guard) — a stable
  // sort so same-tick events (e.g. a chord) keep their given relative order.
  const sorted = [...events].sort((a, b) => a.tick - b.tick);

  const chunks = [];
  if (tempoUsPerQuarter != null) {
    chunks.push(vlq(0), Buffer.from([0xff, 0x51, 0x03]), u32(tempoUsPerQuarter).subarray(1));
  }

  let prevTick = 0;
  for (const ev of sorted) {
    const delta = ev.tick - prevTick;
    chunks.push(vlq(delta), Buffer.from(ev.bytes));
    prevTick = ev.tick;
  }
  // End-of-track meta event, delta 0 from the last event.
  chunks.push(vlq(0), Buffer.from([0xff, 0x2f, 0x00]));

  const body = Buffer.concat(chunks);
  return Buffer.concat([Buffer.from('MTrk'), u32(body.length), body]);
}

/**
 * Build a format-1 Standard MIDI File.
 * @param {object} opts
 * @param {number} opts.ppq - ticks per quarter note (division).
 * @param {number} opts.tempoBpm
 * @param {Array<{channel:number, program:number, notes:Array<{tick:number, duration:number, pitch:number, velocity?:number}>}>} opts.tracks
 */
export function makeMidiFile({ ppq = 480, tempoBpm = 100, tracks }) {
  if (!tracks?.length) throw new Error('makeMidiFile: at least one track is required');

  const tempoUs = Math.round(60_000_000 / tempoBpm);
  const trackChunks = tracks.map((t, i) => {
    const events = [];
    events.push({ tick: 0, bytes: [0xc0 | t.channel, t.program] });
    for (const n of t.notes) {
      const vel = n.velocity ?? 96;
      events.push({ tick: n.tick, bytes: [0x90 | t.channel, n.pitch, vel] });
      events.push({ tick: n.tick + n.duration, bytes: [0x80 | t.channel, n.pitch, 0] });
    }
    return encodeTrack(events, i === 0 ? { tempoUsPerQuarter: tempoUs } : {});
  });

  const header = Buffer.concat([
    Buffer.from('MThd'),
    u32(6),
    u16(1), // format 1
    u16(tracks.length),
    u16(ppq),
  ]);

  return Buffer.concat([header, ...trackChunks]);
}

export { vlq };
