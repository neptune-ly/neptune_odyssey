// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// MIDI -> FluidSynth render -> trim/fade -> loudness-normalize -> mono
// 44.1kHz PCM WAV. The exact pipeline documented in neptune-mobile's
// SOUND_IDENTITY_HANDOFF.md §2, generalized to take any MIDI buffer.
// FluidSynth renders the FULL natural decay tail (can be 5-7s for a short
// phrase) — always trim + fade, never ship the raw render.

import { execFileSync } from 'node:child_process';
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const DEFAULT_SOUNDFONT =
  '/opt/homebrew/Cellar/fluid-synth/2.5.5/share/fluid-synth/sf2/VintageDreamsWaves-v2.sf2';

/**
 * Render a MIDI buffer to a finished, trimmed, faded, loudness-normalized
 * mono 44.1kHz PCM WAV file at `outPath`.
 * @param {Buffer} midiBuffer
 * @param {string} outPath
 * @param {{ durationSeconds: number, fadeSeconds: number, soundfont?: string }} opts
 */
export function renderCue(midiBuffer, outPath, { durationSeconds, fadeSeconds, soundfont = DEFAULT_SOUNDFONT }) {
  const dir = mkdtempSync(join(tmpdir(), 'npt-sound-'));
  const midiPath = join(dir, 'phrase.mid');
  const rawWav = join(dir, 'raw.wav');
  const trimmedWav = join(dir, 'trimmed.wav');

  try {
    writeFileSync(midiPath, midiBuffer);

    // Render — full natural decay tail, reverb tuned to the values that
    // read as "soft and modern" in the source pipeline.
    execFileSync('fluidsynth', [
      '-ni', '-F', rawWav, '-r', '44100', '-R', '1', '-C', '1', '-g', '0.6',
      '-o', 'synth.reverb.room-size=0.55',
      '-o', 'synth.reverb.damp=0.35',
      '-o', 'synth.reverb.width=0.75',
      '-o', 'synth.reverb.level=0.35',
      soundfont, midiPath,
    ], { stdio: ['ignore', 'ignore', 'pipe'] });

    // Trim to target length + fade the tail (abrupt cuts sound broken).
    const fadeStart = Math.max(0, durationSeconds - fadeSeconds);
    execFileSync('ffmpeg', [
      '-y', '-i', rawWav,
      '-t', String(durationSeconds),
      '-af', `afade=t=out:st=${fadeStart}:d=${fadeSeconds}`,
      trimmedWav,
    ], { stdio: ['ignore', 'ignore', 'pipe'] });

    // Loudness-match + finalize as mono 44.1kHz PCM WAV (the native
    // notification-channel requirement on both platforms).
    execFileSync('ffmpeg', [
      '-y', '-i', trimmedWav,
      '-af', 'loudnorm=I=-16:TP=-1.5:LRA=8',
      '-ar', '44100', '-ac', '1', '-sample_fmt', 's16',
      outPath,
    ], { stdio: ['ignore', 'ignore', 'pipe'] });
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}
