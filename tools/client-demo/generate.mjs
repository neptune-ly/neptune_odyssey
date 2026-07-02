#!/usr/bin/env node
// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Client-demo factory (R5): logo -> seeds -> BrandprintConfig -> a running
// NeptuneDemoShellApp. Orchestrates extract_colors.py, converts the two
// dominant hexes to OKLCH seeds, picks fitting identity levers, and writes
// gitignored client_config.dart / client_main.dart into the example app
// (ODYSSEY_RULEBOOK §7: client material never enters the public repo).
//
// Usage:
//   node tools/client-demo/generate.mjs --logo <file> --name "Bank Name" \
//     [--name-ar "اسم المصرف"] [--tone formal|friendly|modern|calm] \
//     [--primary "#RRGGBB"] [--tertiary "#RRGGBB"] [--run]
//
// --primary/--tertiary override the auto-extracted colours (use when the
// logo's dominant colours aren't the brand palette). --run builds and
// launches the demo on macOS after generating.

import { execFileSync, spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, writeFileSync, copyFileSync } from 'node:fs';
import { dirname, join, extname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '../..');
const EXAMPLE = join(ROOT, 'packages/neptune_flutter_ui/example');

function parseArgs(argv) {
  const out = { run: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--run') out.run = true;
    else if (a.startsWith('--')) out[a.slice(2)] = argv[++i];
  }
  return out;
}

const args = parseArgs(process.argv.slice(2));
if (!args.logo || !args.name) {
  console.error(`usage: node tools/client-demo/generate.mjs --logo <file> --name "Bank Name" [options]

  --logo <path>       Logo file (PDF/PNG/JPG) — required
  --name <text>        English bank name — required
  --name-ar <text>      Arabic bank name (defaults to --name)
  --primary <#hex>       Override the auto-extracted primary colour
  --tertiary <#hex>       Override the auto-extracted accent colour
  --tone <preset>          formal | friendly | modern | calm (default: formal)
  --run                     Build + launch the demo on macOS after generating`);
  process.exit(1);
}
if (!existsSync(args.logo)) {
  console.error(`logo not found: ${args.logo}`);
  process.exit(1);
}

// --- 1. extract colours (or use overrides) ------------------------------------

let primaryHex = args.primary;
let tertiaryHex = args.tertiary;
let logoPngPath;

if (!primaryHex || !tertiaryHex) {
  console.log('Extracting colours from logo…');
  const raw = execFileSync(
    'python3',
    [join(ROOT, 'tools/client-demo/extract_colors.py'), args.logo],
    { encoding: 'utf8' },
  );
  const extracted = JSON.parse(raw);
  if (extracted.error) {
    console.error(`colour extraction failed: ${extracted.error}`);
    process.exit(1);
  }
  primaryHex ??= extracted.primary;
  tertiaryHex ??= extracted.accent;
  logoPngPath = extracted.logoPng;
  console.log(`  primary  ${primaryHex}`);
  console.log(`  accent   ${tertiaryHex}`);
} else {
  logoPngPath = args.logo;
}

// If the logo isn't already a PNG (e.g. a manual --primary/--tertiary run with
// a PDF logo), rasterize it via the same extractor helper.
if (extname(logoPngPath).toLowerCase() !== '.png') {
  const raw = execFileSync(
    'python3',
    [join(ROOT, 'tools/client-demo/extract_colors.py'), args.logo],
    { encoding: 'utf8' },
  );
  logoPngPath = JSON.parse(raw).logoPng;
}

// --- 2. sRGB -> OKLCH (inverse of codegen.mjs's OKLCH -> sRGB) -----------------

function srgbToOklch(hex) {
  const n = parseInt(hex.replace('#', ''), 16);
  const srgb = [(n >> 16) & 255, (n >> 8) & 255, n & 255].map((c) => c / 255);
  const toLinear = (c) => (c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4));
  const [r, g, b] = srgb.map(toLinear);

  const l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
  const m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
  const s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;
  const l_ = Math.cbrt(l);
  const m_ = Math.cbrt(m);
  const s_ = Math.cbrt(s);

  const L = 0.2104542553 * l_ + 0.793617785 * m_ - 0.0040720468 * s_;
  const a = 1.9779984951 * l_ - 2.428592205 * m_ + 0.4505937099 * s_;
  const bb = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.808675766 * s_;

  const C = Math.hypot(a, bb);
  let H = (Math.atan2(bb, a) * 180) / Math.PI;
  if (H < 0) H += 360;
  return { l: Math.round(L * 1000) / 1000, c: Math.round(C * 1000) / 1000, h: Math.round(H) };
}

const primary = srgbToOklch(primaryHex);
const tertiary = srgbToOklch(tertiaryHex);
console.log(`OKLCH seeds: primary(${primary.l}, ${primary.c}, ${primary.h}) tertiary(${tertiary.l}, ${tertiary.c}, ${tertiary.h})`);

// --- 3. pick identity levers by tone preset -----------------------------------

const TONE_PRESETS = {
  formal: {
    corners: { xs: 6, sm: 10, md: 14, lg: 20, xl: 28, xxl: 38 },
    fontDisplay: 'Sora', fontNum: 'Sora',
    displayWeight: 700, displayTracking: -0.01,
    loginShell: 'shield-guilloche', dashboardHero: 'restrained-balance',
    contentTone: 'formal-authoritative', glassTint: 'navy-steel',
    motion: 'stable-minimal-authoritative',
  },
  friendly: {
    corners: { xs: 12, sm: 18, md: 26, lg: 34, xl: 44, xxl: 56 },
    fontDisplay: 'Bricolage Grotesque', fontNum: 'Hanken Grotesk',
    displayWeight: 700, displayTracking: -0.01,
    loginShell: 'arcade-arches', dashboardHero: 'warm-balance-cards',
    contentTone: 'warm-hospitable', glassTint: 'warm-amber',
    motion: 'calm-graceful',
  },
  modern: {
    corners: { xs: 4, sm: 8, md: 12, lg: 18, xl: 26, xxl: 36 },
    fontDisplay: 'Space Grotesk', fontNum: 'Space Grotesk',
    displayWeight: 600, displayTracking: -0.03,
    loginShell: 'light-grid-spark', dashboardHero: 'wallet-hero',
    contentTone: 'light-instant', glassTint: 'violet-luminous',
    motion: 'light-quick-crisp',
  },
  calm: {
    corners: { xs: 8, sm: 12, md: 16, lg: 24, xl: 32, xxl: 44 },
    fontDisplay: 'Hanken Grotesk', fontNum: 'Hanken Grotesk',
    displayWeight: 700, displayTracking: -0.02,
    loginShell: 'depth-emblem', dashboardHero: 'balance-cards',
    contentTone: 'clear-calm', glassTint: 'oceanic',
    motion: 'smooth-fluid',
  },
};
const tone = TONE_PRESETS[args.tone] ?? TONE_PRESETS.formal;

// --- 4. emit client_config.dart + client_main.dart ----------------------------

const nameAr = args['name-ar'] ?? args.name;
const c = tone.corners;

const configDart = `// LOCAL-ONLY generated file — gitignored (ODYSSEY_RULEBOOK §7: client
// material never enters the public repo). Regenerate with:
//   node tools/client-demo/generate.mjs --logo <file> --name "${args.name}"
import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

const BrandprintConfig clientBrandprint = BrandprintConfig(
  primary: Seed(l: ${primary.l}, c: ${primary.c}, h: ${primary.h}),
  tertiary: Seed(l: ${tertiary.l}, c: ${tertiary.c}, h: ${tertiary.h}),
  corners: Corners(xs: ${c.xs}, sm: ${c.sm}, md: ${c.md}, lg: ${c.lg}, xl: ${c.xl}, xxl: ${c.xxl}),
  displayWeight: ${tone.displayWeight},
  displayTracking: ${tone.displayTracking},
  fontDisplay: '${tone.fontDisplay}',
  fontText: 'Hanken Grotesk',
  fontNum: '${tone.fontNum}',
  loginShell: '${tone.loginShell}',
  dashboardHero: '${tone.dashboardHero}',
  contentTone: '${tone.contentTone}',
  glassTint: '${tone.glassTint}',
  motion: '${tone.motion}',
);

const String clientNameEn = '${args.name}';
const String clientNameAr = '${nameAr}';

/// The client's real logo, on a clean plate (banks present the mark on white).
class ClientLogo extends StatelessWidget {
  final double height;
  const ClientLogo({super.key, this.height = 40});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: shape.rSm,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Image.asset('assets/client_logo.png', height: height),
    );
  }
}
`;

const mainDart = `// LOCAL-ONLY generated entrypoint — gitignored (ODYSSEY_RULEBOOK §7).
// Run: flutter build macos --debug --target=lib/client_main.dart
import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import 'client_config.dart';

void main() => runApp(const NeptuneDemoShellApp(
      brandprint: clientBrandprint,
      bankNameEn: clientNameEn,
      bankNameAr: clientNameAr,
      logo: ClientLogo(height: 26),
    ));
`;

mkdirSync(join(EXAMPLE, 'lib'), { recursive: true });
mkdirSync(join(EXAMPLE, 'assets'), { recursive: true });
writeFileSync(join(EXAMPLE, 'lib/client_config.dart'), configDart);
writeFileSync(join(EXAMPLE, 'lib/client_main.dart'), mainDart);
copyFileSync(logoPngPath, join(EXAMPLE, 'assets/client_logo.png'));

console.log('\nGenerated:');
console.log('  packages/neptune_flutter_ui/example/lib/client_config.dart');
console.log('  packages/neptune_flutter_ui/example/lib/client_main.dart');
console.log('  packages/neptune_flutter_ui/example/assets/client_logo.png');

// --- 5. optionally build + launch ---------------------------------------------

if (args.run) {
  console.log('\nBuilding macOS demo (this takes a minute)…');
  const flutter = '/Users/mtellesy/development/flutter/bin/flutter';
  const build = spawnSync(
    flutter,
    ['build', 'macos', '--debug', '--target=lib/client_main.dart'],
    { cwd: EXAMPLE, stdio: 'inherit' },
  );
  if (build.status !== 0) {
    console.error('build failed');
    process.exit(build.status ?? 1);
  }
  const appPath = join(
    EXAMPLE,
    'build/macos/Build/Products/Debug/neptune_flutter_ui_example.app',
  );
  console.log(`\nLaunching ${appPath}`);
  spawnSync('open', [appPath]);
}
