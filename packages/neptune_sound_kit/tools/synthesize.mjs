#!/usr/bin/env node
// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Synthesizes the four feedback chimes as 44.1kHz mono 16-bit PCM WAV — no
// recorded samples, no external audio assets: every sample is generated from
// sine partials with an ADSR-style envelope, the same technique behind most
// platform system sounds. Run: node tools/synthesize.mjs

import { writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const OUT = join(ROOT, 'assets/sfx');
mkdirSync(OUT, { recursive: true });

const SR = 44100;

/** A single sine partial at [freq]Hz, [amp] relative amplitude, [phase] radians. */
const partial = (freq, amp, phase = 0) => ({ freq, amp, phase });

/**
 * Render [seconds] of audio as an array of -1..1 floats: the sum of [partials]
 * (each optionally sliding in pitch via [glideTo]/[glideAt]) shaped by a
 * linear-attack / exponential-decay envelope (soft, no click at onset or cutoff).
 */
function renderTone(seconds, partials, { attack = 0.012, decay = 3.2, glideTo, glideAt = 0 } = {}) {
  const n = Math.round(seconds * SR);
  const out = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    const t = i / SR;
    const env = t < attack
      ? t / attack
      : Math.exp(-decay * (t - attack));
    let s = 0;
    for (const p of partials) {
      let freq = p.freq;
      if (glideTo && t > glideAt) {
        const gt = Math.min(1, (t - glideAt) / Math.max(0.001, seconds - glideAt));
        freq = p.freq + (glideTo - p.freq) * gt;
      }
      s += p.amp * Math.sin(2 * Math.PI * freq * t + (p.phase ?? 0));
    }
    out[i] = s * env;
  }
  return out;
}

/** Concatenate renders with [gapSeconds] of silence between each. */
function sequence(renders, gapSeconds = 0.03) {
  const gap = new Float32Array(Math.round(gapSeconds * SR));
  const total = renders.reduce((sum, r) => sum + r.length, 0) + gap.length * (renders.length - 1);
  const out = new Float32Array(total);
  let offset = 0;
  renders.forEach((r, i) => {
    out.set(r, offset);
    offset += r.length;
    if (i < renders.length - 1) {
      out.set(gap, offset);
      offset += gap.length;
    }
  });
  return out;
}

/** Normalize to a gentle peak (never full-scale — these should read as soft). */
function normalize(samples, peak = 0.5) {
  let max = 0;
  for (const s of samples) max = Math.max(max, Math.abs(s));
  if (max === 0) return samples;
  const scale = peak / max;
  return samples.map((s) => s * scale);
}

/** Float -1..1 samples -> a 44-byte-header mono 16-bit PCM WAV buffer. */
function toWav(samples) {
  const dataSize = samples.length * 2;
  const buf = Buffer.alloc(44 + dataSize);
  buf.write('RIFF', 0);
  buf.writeUInt32LE(36 + dataSize, 4);
  buf.write('WAVE', 8);
  buf.write('fmt ', 12);
  buf.writeUInt32LE(16, 16); // fmt chunk size
  buf.writeUInt16LE(1, 20); // PCM
  buf.writeUInt16LE(1, 22); // mono
  buf.writeUInt32LE(SR, 24);
  buf.writeUInt32LE(SR * 2, 28); // byte rate
  buf.writeUInt16LE(2, 32); // block align
  buf.writeUInt16LE(16, 34); // bits per sample
  buf.write('data', 36);
  buf.writeUInt32LE(dataSize, 40);
  for (let i = 0; i < samples.length; i++) {
    const clamped = Math.max(-1, Math.min(1, samples[i]));
    buf.writeInt16LE(Math.round(clamped * 32767), 44 + i * 2);
  }
  return buf;
}

// --- the four cues -----------------------------------------------------------
// Musical, not beepy: every tone carries a quiet octave-up partial for warmth
// and a soft attack so nothing reads as a harsh "system beep".

const warm = (freq, amp = 0.6) => [partial(freq, amp), partial(freq * 2, amp * 0.18)];

const tap = normalize(
  renderTone(0.05, warm(1046.5, 0.5), { attack: 0.002, decay: 28 }),
  0.22, // quietest cue — it fires on every tap
);

const success = normalize(
  sequence([
    renderTone(0.16, warm(659.25), { attack: 0.01, decay: 7 }), // E5
    renderTone(0.26, warm(1046.5), { attack: 0.008, decay: 4.2 }), // C6 — rising major sixth
  ], 0.02),
  0.5,
);

const warning = normalize(
  sequence([
    renderTone(0.09, warm(783.99, 0.5), { attack: 0.006, decay: 9 }), // G5
    renderTone(0.09, warm(783.99, 0.5), { attack: 0.006, decay: 9 }), // same note again — a soft double-tap
  ], 0.07),
  0.42,
);

const error = normalize(
  renderTone(0.42, warm(587.33, 0.55), { attack: 0.01, decay: 3.4, glideTo: 392.0, glideAt: 0.06 }), // D5 -> G4, soft downward slide
  0.45,
);

for (const [name, samples] of Object.entries({ tap, success, warning, error })) {
  writeFileSync(join(OUT, `${name}.wav`), toWav(samples));
  console.log(`wrote assets/sfx/${name}.wav (${(samples.length / SR).toFixed(2)}s)`);
}
