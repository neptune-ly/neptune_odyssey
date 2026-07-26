#!/usr/bin/env node
// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Icon codegen — ports the Neptune Odyssey icon family (packages/neptune_icons)
// to Compose Multiplatform ImageVectors.
//
//   packages/neptune_icons/src/icons.ts   (inner SVG markup, 24×24, stroke 1.8)
//   packages/neptune_icons/src/types.ts   (the canonical ICON_NAMES roster)
//        │  parse (this file — regex, mirroring tools/codegen.mjs at the repo root)
//        └──► packages/neptune_kmp_ui/odyssey-compose-ui/src/commonMain/kotlin/
//                 ly/neptune/odyssey/ui/glyphs/NptIcons.g.kt
//
// Every <circle>/<ellipse>/<rect>/<line>/<polyline>/<polygon> is converted into
// equivalent SVG path data here, so the Kotlin side only ever parses path
// strings (androidx.compose.ui.graphics.vector.addPathNodes). Defaults match
// the family's native style and the nptGlyph builder in NptGlyphs.kt:
// SolidColor(Color.White) stroke template (replaced by Icon's tint), width
// 1.8f, round caps/joins, fill null. Per-element overrides in the source
// (e.g. fill="currentColor" stroke="none" dots) become filled paths.
//
// Usage (from the repo root):
//   node packages/neptune_kmp_ui/tools/gen-icons.mjs           # write NptIcons.g.kt
//   node packages/neptune_kmp_ui/tools/gen-icons.mjs --check   # drift gate (CI)

import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '../../..');
const ICONS_TS = join(ROOT, 'packages/neptune_icons/src/icons.ts');
const TYPES_TS = join(ROOT, 'packages/neptune_icons/src/types.ts');
const OUT_KT = join(
  ROOT,
  'packages/neptune_kmp_ui/odyssey-compose-ui/src/commonMain/kotlin/ly/neptune/odyssey/ui/glyphs/NptIcons.g.kt',
);

const CHECK = process.argv.includes('--check');

// --- parse icons.ts + types.ts ------------------------------------------------------

/** name → inner SVG markup, from the exported ICONS record. */
function parseIcons() {
  const src = readFileSync(ICONS_TS, 'utf8');
  const start = src.indexOf('export const ICONS');
  if (start < 0) throw new Error('ICONS record not found in icons.ts');
  const body = src.slice(start);
  const icons = new Map();
  // Entries look like:  home:\n    '<path …/>',   or   "card-add":\n    '<rect …/>',
  for (const m of body.matchAll(
    /(?:"([\w-]+)"|([A-Za-z_]\w*))\s*:\s*\n?\s*'([^']*)'\s*,/g,
  )) {
    icons.set(m[1] ?? m[2], m[3]);
  }
  return icons;
}

/** The ordered canonical roster from types.ts (ICON_NAMES). */
function parseRoster() {
  const src = readFileSync(TYPES_TS, 'utf8');
  const m = src.match(/export const ICON_NAMES[^=]*=\s*\[([^\]]*)\]/);
  if (!m) throw new Error('ICON_NAMES roster not found in types.ts');
  return [...m[1].matchAll(/"([\w-]+)"/g)].map((x) => x[1]);
}

// --- SVG element → path data ---------------------------------------------------------

/** Format a number the way the source does: no trailing zeros, no float noise. */
const fmt = (n) => {
  const r = Math.round(n * 1e6) / 1e6;
  return Object.is(r, -0) ? '0' : String(r);
};

/** Parse `attr="value"` pairs from an element's attribute string. */
function parseAttrs(raw) {
  const attrs = {};
  for (const m of raw.matchAll(/([a-zA-Z][\w-]*)="([^"]*)"/g)) attrs[m[1]] = m[2];
  return attrs;
}

const num = (attrs, name, fallback) => {
  if (attrs[name] === undefined) {
    if (fallback !== undefined) return fallback;
    throw new Error(`missing attribute ${name}`);
  }
  const v = Number(attrs[name]);
  if (!Number.isFinite(v)) throw new Error(`bad number for ${name}: ${attrs[name]}`);
  return v;
};

/** Full circle/ellipse as two 180° arcs (fill-safe: the subpath ends at its start). */
function ellipsePath(cx, cy, rx, ry) {
  return (
    `M${fmt(cx - rx)} ${fmt(cy)}` +
    `a${fmt(rx)} ${fmt(ry)} 0 1 0 ${fmt(2 * rx)} 0` +
    `a${fmt(rx)} ${fmt(ry)} 0 1 0 ${fmt(-2 * rx)} 0`
  );
}

function rectPath(attrs) {
  const x = num(attrs, 'x', 0);
  const y = num(attrs, 'y', 0);
  const w = num(attrs, 'width');
  const h = num(attrs, 'height');
  const rx = Math.min(num(attrs, 'rx', attrs.ry !== undefined ? num(attrs, 'ry') : 0), w / 2);
  const ry = Math.min(num(attrs, 'ry', rx), h / 2);
  if (rx <= 0 || ry <= 0) {
    return `M${fmt(x)} ${fmt(y)}h${fmt(w)}v${fmt(h)}h${fmt(-w)}Z`;
  }
  return (
    `M${fmt(x + rx)} ${fmt(y)}` +
    `h${fmt(w - 2 * rx)}` +
    `a${fmt(rx)} ${fmt(ry)} 0 0 1 ${fmt(rx)} ${fmt(ry)}` +
    `v${fmt(h - 2 * ry)}` +
    `a${fmt(rx)} ${fmt(ry)} 0 0 1 ${fmt(-rx)} ${fmt(ry)}` +
    `h${fmt(-(w - 2 * rx))}` +
    `a${fmt(rx)} ${fmt(ry)} 0 0 1 ${fmt(-rx)} ${fmt(-ry)}` +
    `v${fmt(-(h - 2 * ry))}` +
    `a${fmt(rx)} ${fmt(ry)} 0 0 1 ${fmt(rx)} ${fmt(-ry)}` +
    `Z`
  );
}

function pointsPath(attrs, close) {
  const pts = (attrs.points ?? '').trim().split(/[\s,]+/).map(Number);
  if (pts.length < 4 || pts.length % 2 !== 0 || pts.some((v) => !Number.isFinite(v))) {
    throw new Error(`bad points: "${attrs.points}"`);
  }
  let d = `M${fmt(pts[0])} ${fmt(pts[1])}`;
  for (let i = 2; i < pts.length; i += 2) d += `L${fmt(pts[i])} ${fmt(pts[i + 1])}`;
  return close ? d + 'Z' : d;
}

/** One drawable: path data + paint resolved from per-element overrides. */
function convertElement(tag, attrs, iconName) {
  let d;
  switch (tag) {
    case 'path':
      d = attrs.d;
      if (!d) throw new Error(`<path> without d in "${iconName}"`);
      break;
    case 'circle': {
      const r = num(attrs, 'r');
      d = ellipsePath(num(attrs, 'cx', 0), num(attrs, 'cy', 0), r, r);
      break;
    }
    case 'ellipse':
      d = ellipsePath(num(attrs, 'cx', 0), num(attrs, 'cy', 0), num(attrs, 'rx'), num(attrs, 'ry'));
      break;
    case 'rect':
      d = rectPath(attrs);
      break;
    case 'line':
      d = `M${fmt(num(attrs, 'x1', 0))} ${fmt(num(attrs, 'y1', 0))}` +
        `L${fmt(num(attrs, 'x2', 0))} ${fmt(num(attrs, 'y2', 0))}`;
      break;
    case 'polyline':
      d = pointsPath(attrs, false);
      break;
    case 'polygon':
      d = pointsPath(attrs, true);
      break;
    default:
      throw new Error(`unsupported element <${tag}> in "${iconName}"`);
  }

  // Paint: template stroke by default; per-element fill/stroke overrides win.
  // Only `currentColor`/`none` are legal — literal colours would break theming.
  const fillAttr = attrs.fill ?? 'none';
  const strokeAttr = attrs.stroke ?? 'currentColor';
  if (fillAttr !== 'none' && fillAttr !== 'currentColor') {
    throw new Error(`literal fill "${fillAttr}" in "${iconName}" — only currentColor/none`);
  }
  if (strokeAttr !== 'none' && strokeAttr !== 'currentColor') {
    throw new Error(`literal stroke "${strokeAttr}" in "${iconName}" — only currentColor/none`);
  }
  return {
    d,
    fill: fillAttr === 'currentColor',
    stroke: strokeAttr === 'currentColor',
    strokeWidth: attrs['stroke-width'] !== undefined ? num(attrs, 'stroke-width') : 1.8,
  };
}

/** Inner markup → ordered list of drawables. */
function convertIcon(name, markup) {
  const drawables = [];
  let consumed = 0;
  for (const m of markup.matchAll(/<([a-z]+)\b([^>]*?)\/>/g)) {
    drawables.push(convertElement(m[1], parseAttrs(m[2]), name));
    consumed += m[0].length;
  }
  // Every byte of the markup must be a self-closing element we understood.
  if (consumed !== markup.length || drawables.length === 0) {
    throw new Error(`unparsed markup in "${name}": ${markup}`);
  }
  return drawables;
}

// --- Kotlin emission ------------------------------------------------------------------

const KOTLIN_HARD_KEYWORDS = new Set([
  'as', 'break', 'class', 'continue', 'do', 'else', 'false', 'for', 'fun', 'if',
  'in', 'interface', 'is', 'null', 'object', 'package', 'return', 'super', 'this',
  'throw', 'true', 'try', 'typealias', 'typeof', 'val', 'var', 'when', 'while',
]);

/** kebab-case → camelCase; Kotlin hard keywords get a trailing underscore. */
function kotlinName(kebab) {
  const camel = kebab.replace(/-(\w)/g, (_, c) => c.toUpperCase());
  return KOTLIN_HARD_KEYWORDS.has(camel) ? `${camel}_` : camel;
}

const kstr = (s) => `"${s.replace(/[\\"$]/g, (c) => '\\' + c)}"`;

function emitKotlin(roster, icons) {
  const L = [];
  L.push('// GENERATED by packages/neptune_kmp_ui/tools/gen-icons.mjs — DO NOT EDIT.');
  L.push('// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0');
  L.push('//');
  L.push('// The full Neptune Odyssey icon family, ported from');
  L.push('// packages/neptune_icons/src/icons.ts: 24×24 grid, stroke 1.8, round');
  L.push('// caps/joins, fill none. Non-path SVG elements (circle/ellipse/rect/…) are');
  L.push('// pre-converted to path data by the generator. The Color.White paints are');
  L.push('// templates — Icon()\'s `tint` replaces them (the currentColor pattern).');
  L.push('//');
  L.push('// Regenerate: node packages/neptune_kmp_ui/tools/gen-icons.mjs');
  L.push('');
  L.push('package ly.neptune.odyssey.ui.glyphs');
  L.push('');
  L.push('import androidx.compose.ui.graphics.Color');
  L.push('import androidx.compose.ui.graphics.SolidColor');
  L.push('import androidx.compose.ui.graphics.StrokeCap');
  L.push('import androidx.compose.ui.graphics.StrokeJoin');
  L.push('import androidx.compose.ui.graphics.vector.ImageVector');
  L.push('import androidx.compose.ui.graphics.vector.addPathNodes');
  L.push('import androidx.compose.ui.unit.dp');
  L.push('');
  L.push('/** 24×24 icon canvas — mirrors the nptGlyph builder defaults. */');
  L.push('private fun nptIconBuilder(name: String): ImageVector.Builder = ImageVector.Builder(');
  L.push('    name = name,');
  L.push('    defaultWidth = 24.dp,');
  L.push('    defaultHeight = 24.dp,');
  L.push('    viewportWidth = 24f,');
  L.push('    viewportHeight = 24f,');
  L.push(')');
  L.push('');
  L.push('/** Outlined stroke path — the family default (stroke 1.8, round caps/joins). */');
  L.push('private fun ImageVector.Builder.strokePath(');
  L.push('    d: String,');
  L.push('    strokeWidth: Float = 1.8f,');
  L.push('): ImageVector.Builder = addPath(');
  L.push('    pathData = addPathNodes(d),');
  L.push('    stroke = SolidColor(Color.White),');
  L.push('    strokeLineWidth = strokeWidth,');
  L.push('    strokeLineCap = StrokeCap.Round,');
  L.push('    strokeLineJoin = StrokeJoin.Round,');
  L.push('    fill = null,');
  L.push(')');
  L.push('');
  L.push('/** Filled path — source elements with fill="currentColor" stroke="none". */');
  L.push('private fun ImageVector.Builder.fillPath(d: String): ImageVector.Builder = addPath(');
  L.push('    pathData = addPathNodes(d),');
  L.push('    fill = SolidColor(Color.White),');
  L.push('    stroke = null,');
  L.push(')');
  L.push('');
  L.push('/** The Neptune Odyssey icon family (tinted via Icon\'s `tint` / currentColor). */');
  L.push('public object NptIcons {');
  let first = true;
  for (const name of roster) {
    const prop = kotlinName(name);
    if (!first) L.push('');
    first = false;
    L.push(`    /** \`${name}\` */`);
    L.push(`    public val ${prop}: ImageVector by lazy {`);
    L.push(`        nptIconBuilder("npt.${prop}")`);
    for (const el of convertIcon(name, icons.get(name))) {
      if (el.fill && !el.stroke) {
        L.push(`            .fillPath(${kstr(el.d)})`);
      } else if (el.stroke && !el.fill && el.strokeWidth === 1.8) {
        L.push(`            .strokePath(${kstr(el.d)})`);
      } else if (el.stroke && !el.fill) {
        L.push(`            .strokePath(${kstr(el.d)}, strokeWidth = ${el.strokeWidth}f)`);
      } else if (el.stroke && el.fill) {
        L.push('            .addPath(');
        L.push(`                pathData = addPathNodes(${kstr(el.d)}),`);
        L.push('                fill = SolidColor(Color.White),');
        L.push('                stroke = SolidColor(Color.White),');
        L.push(`                strokeLineWidth = ${el.strokeWidth}f,`);
        L.push('                strokeLineCap = StrokeCap.Round,');
        L.push('                strokeLineJoin = StrokeJoin.Round,');
        L.push('            )');
      } else {
        throw new Error(`invisible element (fill=none stroke=none) in "${name}"`);
      }
    }
    L.push('            .build()');
    L.push('    }');
  }
  L.push('}');
  L.push('');
  L.push('/** Every icon name (kebab-case), in catalogue order — mirrors ICON_NAMES. */');
  L.push('public val nptIconNames: List<String> = listOf(');
  for (let i = 0; i < roster.length; i += 6) {
    L.push('    ' + roster.slice(i, i + 6).map((n) => `${kstr(n)},`).join(' '));
  }
  L.push(')');
  L.push('');
  L.push('private val nptIconLookup: Map<String, ImageVector> by lazy {');
  L.push('    mapOf(');
  for (const name of roster) {
    L.push(`        ${kstr(name)} to NptIcons.${kotlinName(name)},`);
  }
  L.push('    )');
  L.push('}');
  L.push('');
  L.push('/** Look up an icon by its kebab-case neptune_icons name, or null if unknown. */');
  L.push('public fun nptIcon(name: String): ImageVector? = nptIconLookup[name]');
  return L.join('\n') + '\n';
}

// --- run --------------------------------------------------------------------------------

const icons = parseIcons();
const roster = parseRoster();

// The set cannot drift: ICON_NAMES and the ICONS record must agree exactly.
if (icons.size !== roster.length) {
  throw new Error(`ICONS has ${icons.size} entries but ICON_NAMES has ${roster.length}`);
}
for (const name of roster) {
  if (!icons.has(name)) throw new Error(`"${name}" is in ICON_NAMES but not in ICONS`);
}

const content = emitKotlin(roster, icons);
if (CHECK) {
  const current = existsSync(OUT_KT) ? readFileSync(OUT_KT, 'utf8') : '<missing>';
  if (current !== content) {
    console.error(`DRIFT: ${OUT_KT.replace(ROOT + '/', '')}`);
    console.error('Icon drift detected — run: node packages/neptune_kmp_ui/tools/gen-icons.mjs');
    process.exit(1);
  }
  console.log(`icons in sync ✓ (${roster.length} icons)`);
} else {
  mkdirSync(dirname(OUT_KT), { recursive: true });
  writeFileSync(OUT_KT, content);
  console.log(`wrote ${OUT_KT.replace(ROOT + '/', '')} (${roster.length} icons)`);
}
