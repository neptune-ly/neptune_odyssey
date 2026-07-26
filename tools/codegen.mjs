#!/usr/bin/env node
// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Token codegen — the single-source pipeline (ODYSSEY_RULEBOOK.md R1).
//
//   themes.css (hand-authored canon)
//        │  parse (this file)
//        ├──► packages/neptune_tokens/assets/tokens.resolved.json   (colors, hex+argb)
//        ├──► packages/neptune_tokens/src/data/resolved.generated.ts (same data, as a TS
//        │      module — src/resolve.ts's getResolvedPalette() reads this at runtime, so
//        │      it must never drift from tokens.resolved.json; test (A) in
//        │      oklch.golden.test.ts checks exactly that)
//        ├──► packages/neptune_flutter_ui/lib/src/theme/generated/brand_data.g.dart
//        ├──► packages/neptune_tokens/src/generated/tokens.g.ts
//        ├──► packages/neptune_kmp_ui/odyssey-tokens/src/commonMain/kotlin/
//        │        ly/neptune/odyssey/tokens/generated/BrandData.g.kt
//        └──► packages/neptune_kmp_ui/odyssey-tokens/src/commonTest/kotlin/
//                 ly/neptune/odyssey/tokens/generated/GoldenFixtures.g.kt
//
// OKLCH→sRGB is a 1:1 port of packages/neptune_flutter_ui/lib/src/color/oklch.dart
// (itself golden-tested against the web) so every target gets identical bytes.
//
// Usage:
//   node tools/codegen.mjs           # write all outputs
//   node tools/codegen.mjs --check   # drift gate: regenerate to temp + diff (CI)

import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const CSS = join(ROOT, 'packages/neptune_tokens/assets/themes.css');
const TOKENS = join(ROOT, 'packages/neptune_tokens/assets/tokens.json');
const OUT_RESOLVED = join(ROOT, 'packages/neptune_tokens/assets/tokens.resolved.json');
const OUT_RESOLVED_TS = join(ROOT, 'packages/neptune_tokens/src/data/resolved.generated.ts');
const OUT_DART = join(ROOT, 'packages/neptune_flutter_ui/lib/src/theme/generated/brand_data.g.dart');
const OUT_TS = join(ROOT, 'packages/neptune_tokens/src/generated/tokens.g.ts');
const OUT_KT = join(
  ROOT,
  'packages/neptune_kmp_ui/odyssey-tokens/src/commonMain/kotlin/ly/neptune/odyssey/tokens/generated/BrandData.g.kt',
);
const OUT_KT_FIXTURES = join(
  ROOT,
  'packages/neptune_kmp_ui/odyssey-tokens/src/commonTest/kotlin/ly/neptune/odyssey/tokens/generated/GoldenFixtures.g.kt',
);
const GOLDEN_BRANDPRINTS = join(
  ROOT,
  'packages/neptune_tokens/assets/brandprints.golden.json',
);

const CHECK = process.argv.includes('--check');
const BRANDS = ['neptune', 'triton', 'nereid', 'proteus'];

// --- OKLCH → sRGB (1:1 port of oklch.dart) -----------------------------------

const OKLAB_TO_LMS = [
  [1.0, 0.3963377774, 0.2158037573],
  [1.0, -0.1055613458, -0.0638541728],
  [1.0, -0.0894841775, -1.291485548],
];
const LMS_TO_XYZ = [
  [1.2268798733741557, -0.5578149965554813, 0.28139105017721583],
  [-0.04057576262431372, 1.1122868293970594, -0.07171106666151701],
  [-0.07637294974672142, -0.4214933239627914, 1.5869240244272418],
];
const XYZ_TO_LINSRGB = [
  [3.2409699419045226, -1.537383177570094, -0.4986107602930034],
  [-0.9692436362808796, 1.8759675015077202, 0.04155505740717559],
  [0.05563007969699366, -0.20397695888897652, 1.0569715142428786],
];
const mul = (m, v) => m.map((r) => r[0] * v[0] + r[1] * v[1] + r[2] * v[2]);
const clamp01 = (x) => (x < 0 ? 0 : x > 1 ? 1 : x);
const encodeSrgb = (x) =>
  x <= 0.0031308 ? 12.92 * x : 1.055 * Math.pow(x, 1 / 2.4) - 0.055;

function oklchToRgb255(L, C, Hdeg) {
  const h = (Hdeg * Math.PI) / 180;
  const lab = [L, C * Math.cos(h), C * Math.sin(h)];
  const lms_ = mul(OKLAB_TO_LMS, lab);
  const lms = lms_.map((v) => v * v * v);
  const xyz = mul(LMS_TO_XYZ, lms);
  const lin = mul(XYZ_TO_LINSRGB, xyz);
  return lin.map((v) => Math.round(encodeSrgb(clamp01(v)) * 255));
}
const toHex = (rgb) =>
  '#' + rgb.map((c) => c.toString(16).padStart(2, '0')).join('');
const toArgb = (rgb) =>
  ('0xff' + rgb.map((c) => c.toString(16).padStart(2, '0')).join('')).toUpperCase()
    .replace('0XFF', '0xFF');

// --- parse themes.css ----------------------------------------------------------

const css = readFileSync(CSS, 'utf8');

/** Extract the body of the block whose selector matches `sel` exactly. */
function block(sel) {
  const i = css.indexOf(sel + '{');
  if (i < 0) throw new Error(`selector not found: ${sel}`);
  const start = i + sel.length + 1;
  const end = css.indexOf('}', start);
  return css.slice(start, end);
}

const prop = (body, name) => {
  const m = body.match(new RegExp(`--${name}\\s*:\\s*([^;]+);`));
  return m ? m[1].trim() : null;
};
const oklchProps = (body) => {
  const out = {};
  for (const m of body.matchAll(
    /--(md-sys-color-[a-z-]+)\s*:\s*oklch\(([\d.]+)\s+([\d.]+)\s+([\d.]+)\)/g,
  )) {
    out[m[1]] = [Number(m[2]), Number(m[3]), Number(m[4])];
  }
  return out;
};

function parseBrand(brand) {
  const lightSel =
    brand === 'neptune' ? ':root,[data-theme="neptune"]' : `[data-theme="${brand}"]`;
  const light = block(lightSel);
  const dark = block(`[data-theme="${brand}"][data-mode="dark"]`);

  // glass: color-mix(in oklab, var(--md-sys-color-X) R%, color-mix(in oklab, var(--md-sys-color-surface) A%, transparent))
  const glassRaw = prop(light, 'npt-glass-tint') ?? '';
  const gm = glassRaw.match(
    /var\(--md-sys-color-(primary|tertiary)\)\s*([\d.]+)%.*surface\)\s*([\d.]+)%/s,
  );

  const strip = (s) => (s ?? '').replace(/^'|'$/g, '');
  return {
    colors: { light: oklchProps(light), dark: oklchProps(dark) },
    fonts: {
      display: strip(prop(light, 'npt-font-display')),
      text: strip(prop(light, 'npt-font-text')),
      num: strip(prop(light, 'npt-font-num')),
      displayAr: strip(prop(light, 'npt-font-display-ar')),
      textAr: strip(prop(light, 'npt-font-text-ar')),
    },
    displayWeight: Number(prop(light, 'npt-display-weight')),
    displayTracking: parseFloat(prop(light, 'npt-display-tracking')),
    corners: Object.fromEntries(
      ['xs', 'sm', 'md', 'lg', 'xl', '2xl'].map((k) => [
        k,
        parseFloat(prop(light, `npt-corner-${k}-base`)),
      ]),
    ),
    motion: {
      standard: prop(light, 'npt-ease-standard'),
      emphasized: prop(light, 'npt-ease-emphasized'),
      spring: prop(light, 'npt-ease-spring'),
      fastMs: parseFloat(prop(light, 'npt-dur-fast')),
      standardMs: parseFloat(prop(light, 'npt-dur-standard')),
      slowMs: parseFloat(prop(light, 'npt-dur-slow')),
    },
    glass: {
      on: gm ? gm[1] : 'primary',
      mixPct: gm ? Number(gm[2]) : 8,
      surfacePct: gm ? Number(gm[3]) : 70,
      blurPx: parseFloat(prop(light, 'npt-glass-blur')),
    },
    motifStrength: parseFloat(prop(light, 'npt-motif-strength')),
  };
}

const data = Object.fromEntries(BRANDS.map((b) => [b, parseBrand(b)]));
const tokens = JSON.parse(readFileSync(TOKENS, 'utf8'));

// --- emit tokens.resolved.json ---------------------------------------------------

function emitResolved() {
  const themes = {};
  for (const b of BRANDS) {
    themes[b] = {};
    for (const mode of ['light', 'dark']) {
      const roles = {};
      for (const [role, lch] of Object.entries(data[b].colors[mode])) {
        const rgb = oklchToRgb255(...lch);
        roles[role] = { hex: toHex(rgb), argb: toArgb(rgb) };
      }
      themes[b][mode] = roles;
    }
  }
  return (
    JSON.stringify(
      {
        $generatedBy: 'tools/codegen.mjs · OKLCH→sRGB (oklch.dart 1:1 port)',
        meta: tokens.meta,
        themes,
      },
      null,
      2,
    ) + '\n'
  );
}

// --- emit resolved.generated.ts (same data as tokens.resolved.json, as a TS module) ---

function emitResolvedTs() {
  const themes = {};
  for (const b of BRANDS) {
    themes[b] = {};
    for (const mode of ['light', 'dark']) {
      const roles = {};
      for (const [role, lch] of Object.entries(data[b].colors[mode])) {
        const rgb = oklchToRgb255(...lch);
        roles[role] = { hex: toHex(rgb), argb: toArgb(rgb) };
      }
      themes[b][mode] = roles;
    }
  }
  return (
    '// GENERATED — do not edit. Source: assets/tokens.resolved.json (pinned canonical palette).\n' +
    '// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0\n\n' +
    `export const RESOLVED = ${JSON.stringify(themes, null, 2)} as const;\n`
  );
}

// --- emit Dart -------------------------------------------------------------------

const cssBezier = (s) => {
  const m = s.match(/cubic-bezier\(([^)]+)\)/);
  return m.groups ?? m[1].split(',').map((n) => Number(n.trim()));
};

function emitDart() {
  const L = [];
  L.push('// GENERATED by tools/codegen.mjs — DO NOT EDIT.');
  L.push('// Source of truth: packages/neptune_tokens/assets/themes.css');
  L.push('// Regenerate: node tools/codegen.mjs · Verify: node tools/codegen.mjs --check');
  L.push('// ignore_for_file: prefer_const_constructors');
  L.push('');
  L.push("import 'package:flutter/material.dart';");
  L.push('');

  const role = (b, mode, name) => {
    const lch = data[b].colors[mode][name];
    if (!lch) throw new Error(`missing role ${name} for ${b}/${mode}`);
    return `Color(${toArgb(oklchToRgb255(...lch))})`;
  };

  const scheme = (b, mode) => {
    const r = (n) => role(b, mode, `md-sys-color-${n}`);
    return `ColorScheme(
    brightness: Brightness.${mode === 'light' ? 'light' : 'dark'},
    primary: ${r('primary')},
    onPrimary: ${r('on-primary')},
    primaryContainer: ${r('primary-container')},
    onPrimaryContainer: ${r('on-primary-container')},
    secondary: ${r('secondary')},
    onSecondary: ${r('on-secondary')},
    secondaryContainer: ${r('secondary-container')},
    onSecondaryContainer: ${r('on-secondary-container')},
    tertiary: ${r('tertiary')},
    onTertiary: ${r('on-tertiary')},
    tertiaryContainer: ${r('tertiary-container')},
    onTertiaryContainer: ${r('on-tertiary-container')},
    error: ${r('error')},
    onError: ${r('on-error')},
    errorContainer: ${r('error-container')},
    onErrorContainer: ${r('on-error-container')},
    surface: ${r('surface')},
    onSurface: ${r('on-surface')},
    surfaceContainerLowest: ${r('surface-container-lowest')},
    surfaceContainerLow: ${r('surface-container-low')},
    surfaceContainer: ${r('surface-container')},
    surfaceContainerHigh: ${r('surface-container-high')},
    surfaceContainerHighest: ${r('surface-container-highest')},
    onSurfaceVariant: ${r('on-surface-variant')},
    outline: ${r('outline')},
    outlineVariant: ${r('outline-variant')},
    inverseSurface: ${r('inverse-surface')},
    onInverseSurface: ${r('inverse-on-surface')},
    inversePrimary: ${r('inverse-primary')},
    scrim: ${r('scrim')},
    surfaceTint: ${r('primary')},
    shadow: Color(0xFF000000),
  )`;
  };

  L.push('/// Pinned M3 schemes per brand (light, dark) — generated from themes.css.');
  L.push('final Map<String, (ColorScheme, ColorScheme)> genSchemes = {');
  for (const b of BRANDS) {
    L.push(`  '${b}': (${scheme(b, 'light')}, ${scheme(b, 'dark')}),`);
  }
  L.push('};');
  L.push('');

  L.push('/// success / on / container / on-container per brand × mode.');
  L.push('final Map<String, ((Color, Color, Color, Color), (Color, Color, Color, Color))> genSuccess = {');
  for (const b of BRANDS) {
    const s = (mode) =>
      ['success', 'on-success', 'success-container', 'on-success-container']
        .map((n) => role(b, mode, `md-sys-color-${n}`))
        .join(', ');
    L.push(`  '${b}': ((${s('light')}), (${s('dark')})),`);
  }
  L.push('};');
  L.push('');

  L.push('/// Corner families (px).');
  L.push('const Map<String, (double, double, double, double, double, double)> genShape = {');
  for (const b of BRANDS) {
    const c = data[b].corners;
    L.push(
      `  '${b}': (${c.xs}, ${c.sm}, ${c.md}, ${c.lg}, ${c.xl}, ${c['2xl']}),`,
    );
  }
  L.push('};');
  L.push('');

  L.push('/// Type sets: display, text, num, displayAr, textAr, weight, tracking(em).');
  L.push('const Map<String, (String, String, String, String, String, int, double)> genType = {');
  for (const b of BRANDS) {
    const f = data[b].fonts;
    L.push(
      `  '${b}': ('${f.display}', '${f.text}', '${f.num}', '${f.displayAr}', '${f.textAr}', ${data[b].displayWeight}, ${data[b].displayTracking}),`,
    );
  }
  L.push('};');
  L.push('');

  // Motion + glass are keyed by their LEVER names (tokens.json levers.byBrand)
  // so the theme engine can resolve custom brandprints through the same maps.
  const leverOf = (b, k) => tokens.levers.byBrand[b][k];

  L.push('/// Motion presets keyed by the motion lever: standard/emphasized/spring');
  L.push('/// cubics + fast/standard/slow ms + glass blur px.');
  L.push('final Map<String, (Cubic, Cubic, Cubic, int, int, int, double)> genMotion = {');
  for (const b of BRANDS) {
    const m = data[b].motion;
    const cb = (s) => `Cubic(${cssBezier(s).join(', ')})`;
    L.push(
      `  '${leverOf(b, 'motion')}': (${cb(m.standard)}, ${cb(m.emphasized)}, ${cb(m.spring)}, ${m.fastMs}, ${m.standardMs}, ${m.slowMs}, ${data[b].glass.blurPx}),`,
    );
  }
  L.push('};');
  L.push('');

  L.push('/// Glass/identity recipes keyed by the glassTint lever:');
  L.push('/// mixes tertiary?, mix ratio, surface opacity, blur px, motif strength.');
  L.push('const Map<String, (bool, double, double, double, double)> genGlass = {');
  for (const b of BRANDS) {
    const g = data[b].glass;
    L.push(
      `  '${leverOf(b, 'glassTint')}': (${g.on === 'tertiary'}, ${g.mixPct / 100}, ${g.surfacePct / 100}, ${g.blurPx}, ${data[b].motifStrength}),`,
    );
  }
  L.push('};');
  return L.join('\n') + '\n';
}

// --- emit TS ---------------------------------------------------------------------

function emitTs() {
  const brands = {};
  for (const b of BRANDS) {
    const roles = (mode) =>
      Object.fromEntries(
        Object.entries(data[b].colors[mode]).map(([k, lch]) => [
          k,
          toHex(oklchToRgb255(...lch)),
        ]),
      );
    brands[b] = {
      light: roles('light'),
      dark: roles('dark'),
      fonts: data[b].fonts,
      corners: data[b].corners,
      displayWeight: data[b].displayWeight,
      displayTracking: data[b].displayTracking,
      motion: data[b].motion,
      glass: data[b].glass,
      motifStrength: data[b].motifStrength,
    };
  }
  return (
    '// GENERATED by tools/codegen.mjs — DO NOT EDIT. Source: themes.css\n' +
    `export const odysseyTokens = ${JSON.stringify(brands, null, 2)} as const;\n` +
    'export type OdysseyBrand = keyof typeof odysseyTokens;\n'
  );
}

// --- emit Kotlin (Compose Multiplatform target, packages/neptune_kmp_ui) -----------
// Neutral ARGB/data tables — NO Compose dependency; the value types live in
// odyssey-tokens/src/commonMain/kotlin/ly/neptune/odyssey/tokens/BrandDataTypes.kt.

const kd = (n) => (Number.isInteger(n) ? `${n}.0` : `${n}`);
const kq = (s) => `"${s}"`;

function emitKotlin() {
  const L = [];
  L.push('// GENERATED by tools/codegen.mjs — DO NOT EDIT.');
  L.push('// Source of truth: packages/neptune_tokens/assets/themes.css');
  L.push('// Regenerate: node tools/codegen.mjs · Verify: node tools/codegen.mjs --check');
  L.push('');
  L.push('package ly.neptune.odyssey.tokens.generated');
  L.push('');
  L.push('import ly.neptune.odyssey.tokens.Corners');
  L.push('import ly.neptune.odyssey.tokens.NptCubic');
  L.push('import ly.neptune.odyssey.tokens.NptGlassSpec');
  L.push('import ly.neptune.odyssey.tokens.NptMotionSpec');
  L.push('import ly.neptune.odyssey.tokens.NptSchemePair');
  L.push('import ly.neptune.odyssey.tokens.NptTypeSet');
  L.push('');

  L.push('/** The four reference brands. */');
  L.push(
    `public val genBrands: List<String> = listOf(${BRANDS.map(kq).join(', ')})`,
  );
  L.push('');

  const roleLines = (b, mode) =>
    Object.entries(data[b].colors[mode])
      .map(
        ([role, lch]) =>
          `            ${kq(role.replace('md-sys-color-', ''))} to ${toArgb(
            oklchToRgb255(...lch),
          )}.toInt(),`,
      )
      .join('\n');

  L.push('/** Pinned resolved role→ARGB maps per brand (light, dark) — from themes.css. */');
  L.push('public val genSchemes: Map<String, NptSchemePair> = mapOf(');
  for (const b of BRANDS) {
    L.push(`    ${kq(b)} to NptSchemePair(`);
    L.push('        light = mapOf(');
    L.push(roleLines(b, 'light'));
    L.push('        ),');
    L.push('        dark = mapOf(');
    L.push(roleLines(b, 'dark'));
    L.push('        ),');
    L.push('    ),');
  }
  L.push(')');
  L.push('');

  L.push('/** Corner families (px). */');
  L.push('public val genShape: Map<String, Corners> = mapOf(');
  for (const b of BRANDS) {
    const c = data[b].corners;
    L.push(
      `    ${kq(b)} to Corners(xs = ${Math.round(c.xs)}, sm = ${Math.round(
        c.sm,
      )}, md = ${Math.round(c.md)}, lg = ${Math.round(c.lg)}, xl = ${Math.round(
        c.xl,
      )}, xxl = ${Math.round(c['2xl'])}),`,
    );
  }
  L.push(')');
  L.push('');

  L.push('/** Type sets: display, text, num, displayAr, textAr, weight, tracking(em). */');
  L.push('public val genType: Map<String, NptTypeSet> = mapOf(');
  for (const b of BRANDS) {
    const f = data[b].fonts;
    L.push(
      `    ${kq(b)} to NptTypeSet(${kq(f.display)}, ${kq(f.text)}, ${kq(
        f.num,
      )}, ${kq(f.displayAr)}, ${kq(f.textAr)}, ${data[b].displayWeight}, ${kd(
        data[b].displayTracking,
      )}),`,
    );
  }
  L.push(')');
  L.push('');

  const leverOf = (b, k) => tokens.levers.byBrand[b][k];
  const cubicKt = (s) => {
    const p = cssBezier(s);
    return `NptCubic(${p.map(kd).join(', ')})`;
  };

  L.push('/** Motion presets keyed by the motion lever. */');
  L.push('public val genMotion: Map<String, NptMotionSpec> = mapOf(');
  for (const b of BRANDS) {
    const m = data[b].motion;
    L.push(`    ${kq(leverOf(b, 'motion'))} to NptMotionSpec(`);
    L.push(`        standard = ${cubicKt(m.standard)},`);
    L.push(`        emphasized = ${cubicKt(m.emphasized)},`);
    L.push(`        spring = ${cubicKt(m.spring)},`);
    L.push(
      `        fastMs = ${Math.round(m.fastMs)}, standardMs = ${Math.round(
        m.standardMs,
      )}, slowMs = ${Math.round(m.slowMs)},`,
    );
    L.push(`        glassBlurPx = ${kd(data[b].glass.blurPx)},`);
    L.push('    ),');
  }
  L.push(')');
  L.push('');

  L.push('/** Glass/identity recipes keyed by the glassTint lever. */');
  L.push('public val genGlass: Map<String, NptGlassSpec> = mapOf(');
  for (const b of BRANDS) {
    const g = data[b].glass;
    L.push(
      `    ${kq(leverOf(b, 'glassTint'))} to NptGlassSpec(onTertiary = ${
        g.on === 'tertiary'
      }, mixRatio = ${kd(g.mixPct / 100)}, surfaceOpacity = ${kd(
        g.surfacePct / 100,
      )}, blurPx = ${kd(g.blurPx)}, motifStrength = ${kd(data[b].motifStrength)}),`,
    );
  }
  L.push(')');
  return L.join('\n') + '\n';
}

function emitKotlinFixtures() {
  const rows = JSON.parse(readFileSync(OUT_FIXTURE, 'utf8'));
  const golden = JSON.parse(readFileSync(GOLDEN_BRANDPRINTS, 'utf8'));

  const L = [];
  L.push('// GENERATED by tools/codegen.mjs — DO NOT EDIT.');
  L.push('// Golden fixtures for the Kotlin determinism core: the OKLCH converter');
  L.push('// samples (from packages/neptune_flutter_ui/test/fixtures/oklch_roles.json)');
  L.push('// and the 4 reference brandprints (from');
  L.push('// packages/neptune_tokens/assets/brandprints.golden.json).');
  L.push('');
  L.push('package ly.neptune.odyssey.tokens.generated');
  L.push('');
  L.push('import ly.neptune.odyssey.tokens.BrandprintConfig');
  L.push('import ly.neptune.odyssey.tokens.Corners');
  L.push('import ly.neptune.odyssey.tokens.Seed');
  L.push('');
  L.push('public class GoldenOklchSample(');
  L.push('    public val brand: String,');
  L.push('    public val mode: String,');
  L.push('    public val role: String,');
  L.push('    public val l: Double,');
  L.push('    public val c: Double,');
  L.push('    public val h: Double,');
  L.push('    public val argb: Int,');
  L.push(')');
  L.push('');
  L.push('public class GoldenBrandprint(');
  L.push('    public val brand: String,');
  L.push('    public val brandprint: String,');
  L.push('    public val config: BrandprintConfig,');
  L.push(')');
  L.push('');
  L.push('public val goldenOklchSamples: List<GoldenOklchSample> = listOf(');
  for (const row of rows) {
    const argb = toArgb(oklchToRgb255(row.L, row.C, row.H));
    L.push(
      `    GoldenOklchSample(${kq(row.brand)}, ${kq(row.mode)}, ${kq(
        row.role,
      )}, ${kd(row.L)}, ${kd(row.C)}, ${kd(row.H)}, ${argb}.toInt()),`,
    );
  }
  L.push(')');
  L.push('');
  L.push('/** Every resolved brand×mode×role with its themes.css OKLCH inputs —');
  L.push(' * the “reproduce tokens.resolved.json (≤1 LSB)” gate. */');
  L.push('public val goldenResolvedRoles: List<GoldenOklchSample> = listOf(');
  for (const b of BRANDS) {
    for (const mode of ['light', 'dark']) {
      for (const [role, lch] of Object.entries(data[b].colors[mode])) {
        const argb = toArgb(oklchToRgb255(...lch));
        L.push(
          `    GoldenOklchSample(${kq(b)}, ${kq(mode)}, ${kq(
            role.replace('md-sys-color-', ''),
          )}, ${kd(lch[0])}, ${kd(lch[1])}, ${kd(lch[2])}, ${argb}.toInt()),`,
        );
      }
    }
  }
  L.push(')');
  L.push('');
  L.push('public val goldenBrandprints: List<GoldenBrandprint> = listOf(');
  for (const [brand, e] of Object.entries(golden.brands)) {
    const c = e.config;
    L.push('    GoldenBrandprint(');
    L.push(`        ${kq(brand)},`);
    L.push(`        ${kq(e.brandprint)},`);
    L.push('        BrandprintConfig(');
    L.push(
      `            primary = Seed(l = ${kd(c.primary.L)}, c = ${kd(
        c.primary.C,
      )}, h = ${c.primary.H}),`,
    );
    L.push(
      `            tertiary = Seed(l = ${kd(c.tertiary.L)}, c = ${kd(
        c.tertiary.C,
      )}, h = ${c.tertiary.H}),`,
    );
    L.push(
      `            corners = Corners(xs = ${c.corners.xs}, sm = ${c.corners.sm}, md = ${c.corners.md}, lg = ${c.corners.lg}, xl = ${c.corners.xl}, xxl = ${c.corners.xxl}),`,
    );
    L.push(`            displayWeight = ${c.displayWeight},`);
    L.push(`            displayTracking = ${kd(c.displayTracking)},`);
    L.push(`            fontDisplay = ${kq(c.fonts.display)},`);
    L.push(`            fontText = ${kq(c.fonts.text)},`);
    L.push(`            fontNum = ${kq(c.fonts.num)},`);
    L.push(`            loginShell = ${kq(c.loginShell)},`);
    L.push(`            dashboardHero = ${kq(c.dashboardHero)},`);
    L.push(`            contentTone = ${kq(c.contentTone)},`);
    L.push(`            glassTint = ${kq(c.glassTint)},`);
    L.push(`            motion = ${kq(c.motion)},`);
    L.push(`            defaultDark = ${c.defaultDark},`);
    L.push(`            defaultRtl = ${c.defaultRtl},`);
    L.push('        ),');
    L.push('    ),');
  }
  L.push(')');
  return L.join('\n') + '\n';
}

// --- Flutter oklch golden fixture: keep L/C/H entries, recompute argb -------------

const OUT_FIXTURE = join(
  ROOT,
  'packages/neptune_flutter_ui/test/fixtures/oklch_roles.json',
);

function emitFixture() {
  const rows = JSON.parse(readFileSync(OUT_FIXTURE, 'utf8'));
  for (const row of rows) {
    row.argb = toArgb(oklchToRgb255(row.L, row.C, row.H));
  }
  return JSON.stringify(rows) + '\n';
}

// --- run ---------------------------------------------------------------------------

const outputs = [
  [OUT_RESOLVED, emitResolved()],
  [OUT_RESOLVED_TS, emitResolvedTs()],
  [OUT_DART, emitDart()],
  [OUT_TS, emitTs()],
  [OUT_KT, emitKotlin()],
  [OUT_KT_FIXTURES, emitKotlinFixtures()],
  [OUT_FIXTURE, emitFixture()],
];

let drift = false;
for (const [path, content] of outputs) {
  if (CHECK) {
    const current = existsSync(path) ? readFileSync(path, 'utf8') : '<missing>';
    if (current !== content) {
      drift = true;
      console.error(`DRIFT: ${path.replace(ROOT + '/', '')}`);
    }
  } else {
    mkdirSync(dirname(path), { recursive: true });
    writeFileSync(path, content);
    console.log(`wrote ${path.replace(ROOT + '/', '')}`);
  }
}
if (CHECK) {
  if (drift) {
    console.error('\nToken drift detected — run: node tools/codegen.mjs');
    process.exit(1);
  }
  console.log('tokens in sync ✓');
}
