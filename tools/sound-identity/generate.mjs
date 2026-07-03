#!/usr/bin/env node
// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The sound half of white-label: generate a distinct 5-file sound identity
// (success + 4 notification cues) for any bank/tenant, the same way
// tools/client-demo/generate.mjs generates a visual brandprint. Built from
// the FluidSynth pipeline proven in neptune-mobile's Andalus/Nuran work
// (see SOUND_IDENTITY_HANDOFF.md) — generalized so a new identity is a CLI
// call, not a bespoke session.
//
// Usage:
//   node generate.mjs --name "First Gulf Libyan Bank" [--shape rising-phrase|tap-chord]
//     [--patch 29] [--layer-patch 119] [--base-note 79] [--out dir]
//
// With no --shape/--patch, both are auto-picked deterministically from the
// bank name (stable across re-runs) while avoiding collisions already
// recorded in registry.json — "each bank gets its own" without requiring
// manual curation, but --shape/--patch let an operator override by ear.

import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { SHAPES, CUE_DURATIONS, FADE_DURATIONS } from './lib/shapes.mjs';
import { makeMidiFile } from './lib/midi.mjs';
import { renderCue } from './lib/pipeline.mjs';

const ROOT = dirname(fileURLToPath(import.meta.url));
const REGISTRY_PATH = join(ROOT, 'registry.json');

const SHAPE_NAMES = Object.keys(SHAPES);
// Curated "known good" patches (from the source pipeline's exploration of
// the bundled soundfont) — 32 excluded from the auto-pick pool since both
// existing identities already use it as their hero voice; still available
// via explicit --patch for an operator who wants that vibraphone character.
const PATCH_POOL = [29, 86, 40, 90, 68, 119, 26];

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith('--')) {
      const key = a.slice(2);
      const next = argv[i + 1];
      if (next === undefined || next.startsWith('--')) {
        args[key] = true;
      } else {
        args[key] = next;
        i++;
      }
    }
  }
  return args;
}

function loadRegistry() {
  return JSON.parse(readFileSync(REGISTRY_PATH, 'utf8'));
}

function saveRegistry(registry) {
  writeFileSync(REGISTRY_PATH, JSON.stringify(registry, null, 2) + '\n');
}

/** Deterministic pick from `pool`, seeded by `seed`, skipping `taken` values when possible. */
function pickDeterministic(seed, pool, taken) {
  const hash = createHash('sha256').update(seed).digest();
  const available = pool.filter((p) => !taken.has(p));
  const search = available.length ? available : pool; // fall back to full pool if everything's taken
  const idx = hash.readUInt32BE(0) % search.length;
  return search[idx];
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.name || args.name === true) {
    console.error('Usage: node generate.mjs --name "Bank Name" [--shape ...] [--patch N] [--out dir]');
    process.exit(1);
  }

  const slug = String(args.name)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

  const registry = loadRegistry();
  const takenShapes = new Set(registry.identities.map((i) => i.shape));
  const takenPatches = new Set(registry.identities.map((i) => i.patch));

  const shape = args.shape && SHAPE_NAMES.includes(args.shape)
    ? args.shape
    : pickDeterministic(slug + ':shape', SHAPE_NAMES, takenShapes);
  const patch = args.patch ? Number(args.patch) : pickDeterministic(slug + ':patch', PATCH_POOL, takenPatches);
  const layerPatch = args['layer-patch'] ? Number(args['layer-patch']) : (shape === 'tap-chord' ? 119 : undefined);
  const baseNote = args['base-note'] ? Number(args['base-note']) : 79; // G5, matches the source identities' register

  const outDir = args.out || join(ROOT, 'output', slug);
  mkdirSync(outDir, { recursive: true });

  console.log(`Generating sound identity for "${args.name}"`);
  console.log(`  shape: ${shape}   patch: ${patch}${layerPatch ? `   layer: ${layerPatch}` : ''}   base note: ${baseNote}`);

  const phrases = SHAPES[shape]({ baseNote, patch, layerPatch });

  for (const [cue, phrase] of Object.entries(phrases)) {
    const midi = makeMidiFile(phrase);
    const outPath = join(outDir, `${cue}.wav`);
    renderCue(midi, outPath, {
      durationSeconds: CUE_DURATIONS[cue],
      fadeSeconds: FADE_DURATIONS[cue],
    });
    console.log(`  wrote ${cue}.wav (${CUE_DURATIONS[cue]}s)`);
  }

  registry.identities.push({ bank: slug, displayName: args.name, shape, patch, layerPatch: layerPatch ?? null, external: false });
  saveRegistry(registry);

  console.log(`\nDone. Assets in ${outDir}`);
  console.log('Registered in registry.json — future generations will avoid this (shape, patch) pair.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
