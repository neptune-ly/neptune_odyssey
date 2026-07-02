// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Per-brand extension data for the four reference brands, resolved from the
// single source of truth (themes.css) via `node tools/codegen.mjs` — see
// generated/brand_data.g.dart. Only the canonical BrandprintConfig table and
// the motif↔lever mapping live here (semantic, not token data).

import '../brandprint/codec.dart';
import 'extensions.dart';
import 'feedback.dart';
import 'generated/brand_data.g.dart';
import 'identity.dart';

/// success / on / container / on-container per brand × mode (generated).
final Map<String, (NptColors light, NptColors dark)> brandSuccess = {
  for (final e in genSuccess.entries)
    e.key: (
      NptColors(
        success: e.value.$1.$1,
        onSuccess: e.value.$1.$2,
        successContainer: e.value.$1.$3,
        onSuccessContainer: e.value.$1.$4,
      ),
      NptColors(
        success: e.value.$2.$1,
        onSuccess: e.value.$2.$2,
        successContainer: e.value.$2.$3,
        onSuccessContainer: e.value.$2.$4,
      ),
    ),
};

/// Corner family per brand (px) — generated.
final Map<String, NptShape> brandShape = {
  for (final e in genShape.entries)
    e.key: NptShape(
      xs: e.value.$1,
      sm: e.value.$2,
      md: e.value.$3,
      lg: e.value.$4,
      xl: e.value.$5,
      xxl: e.value.$6,
    ),
};

/// Type set per brand (Latin + Arabic faces) — generated. Under RTL the web
/// maps `num` → `text-ar`, so `numAr` mirrors `textAr`.
final Map<String, NptType> brandType = {
  for (final e in genType.entries)
    e.key: NptType(
      display: e.value.$1,
      text: e.value.$2,
      num: e.value.$3,
      displayAr: e.value.$4,
      textAr: e.value.$5,
      numAr: e.value.$5,
      displayWeight: e.value.$6,
      displayTracking: e.value.$7,
    ),
};

/// Motion presets keyed by the motion lever — generated.
final Map<String, NptMotion> motionPresets = {
  for (final e in genMotion.entries)
    e.key: NptMotion(
      standard: e.value.$1,
      emphasized: e.value.$2,
      spring: e.value.$3,
      fast: Duration(milliseconds: e.value.$4),
      durationStandard: Duration(milliseconds: e.value.$5),
      slow: Duration(milliseconds: e.value.$6),
      glassBlur: e.value.$7,
    ),
};

NptMotion motionFor(String lever) =>
    motionPresets[lever] ?? motionPresets['smooth-fluid']!;

/// Default haptic weight per `contentTone` lever (R6) — formal/authoritative
/// brands land lighter, warm/hospitable brands land heavier, matching the
/// same personality axis the motion/glass levers already encode.
const Map<String, NptHapticWeight> _hapticWeightByContentTone = {
  'formal-authoritative': NptHapticWeight.light,
  'warm-hospitable': NptHapticWeight.heavy,
  'light-instant': NptHapticWeight.medium,
  'clear-calm': NptHapticWeight.medium,
};

NptHapticWeight hapticWeightFor(String contentTone) =>
    _hapticWeightByContentTone[contentTone] ?? NptHapticWeight.medium;

/// The canonical brandprint config per reference brand (brandprints.golden.json).
const Map<String, BrandprintConfig> brandConfig = {
  'neptune': BrandprintConfig(
    primary: Seed(l: 0.48, c: 0.15, h: 258),
    tertiary: Seed(l: 0.55, c: 0.10, h: 200),
    corners: Corners(xs: 8, sm: 12, md: 16, lg: 24, xl: 32, xxl: 44),
    displayWeight: 700,
    displayTracking: -0.02,
    fontDisplay: 'Hanken Grotesk',
    fontText: 'Hanken Grotesk',
    fontNum: 'Hanken Grotesk',
    loginShell: 'depth-emblem',
    dashboardHero: 'balance-cards',
    contentTone: 'clear-calm',
    glassTint: 'oceanic',
    motion: 'smooth-fluid',
  ),
  'triton': BrandprintConfig(
    primary: Seed(l: 0.50, c: 0.12, h: 162),
    tertiary: Seed(l: 0.62, c: 0.12, h: 86),
    corners: Corners(xs: 12, sm: 18, md: 26, lg: 34, xl: 44, xxl: 56),
    displayWeight: 700,
    displayTracking: -0.01,
    fontDisplay: 'Bricolage Grotesque',
    fontText: 'Hanken Grotesk',
    fontNum: 'Hanken Grotesk',
    loginShell: 'arcade-arches',
    dashboardHero: 'warm-balance-cards',
    contentTone: 'warm-hospitable',
    glassTint: 'warm-amber',
    motion: 'calm-graceful',
  ),
  'nereid': BrandprintConfig(
    primary: Seed(l: 0.52, c: 0.18, h: 292),
    tertiary: Seed(l: 0.60, c: 0.16, h: 350),
    corners: Corners(xs: 4, sm: 8, md: 12, lg: 18, xl: 26, xxl: 36),
    displayWeight: 600,
    displayTracking: -0.03,
    fontDisplay: 'Space Grotesk',
    fontText: 'Hanken Grotesk',
    fontNum: 'Space Grotesk',
    loginShell: 'light-grid-spark',
    dashboardHero: 'wallet-hero',
    contentTone: 'light-instant',
    glassTint: 'violet-luminous',
    motion: 'light-quick-crisp',
  ),
  'proteus': BrandprintConfig(
    primary: Seed(l: 0.42, c: 0.13, h: 248),
    tertiary: Seed(l: 0.66, c: 0.12, h: 85),
    corners: Corners(xs: 6, sm: 10, md: 14, lg: 20, xl: 28, xxl: 38),
    displayWeight: 700,
    displayTracking: -0.02,
    fontDisplay: 'Sora',
    fontText: 'Hanken Grotesk',
    fontNum: 'Sora',
    loginShell: 'shield-guilloche',
    dashboardHero: 'restrained-balance',
    contentTone: 'formal-authoritative',
    glassTint: 'navy-steel',
    motion: 'stable-minimal-authoritative',
  ),
};

/// The four reference brand ids in canonical order.
const List<String> kBrands = ['neptune', 'triton', 'nereid', 'proteus'];

/// Identity recipes keyed by the glass-tint lever — glass numbers generated
/// from themes.css; the motif painter mapping is semantic and lives here.
const Map<String, NptMotifKind> _motifByGlassTint = {
  'oceanic': NptMotifKind.sonarRings,
  'warm-amber': NptMotifKind.coastalArcs,
  'violet-luminous': NptMotifKind.gridSpark,
  'navy-steel': NptMotifKind.guilloche,
};

/// Resolve the [NptIdentity] for a brandprint config (reference or custom).
NptIdentity identityFor(BrandprintConfig cfg) {
  final g = genGlass[cfg.glassTint] ?? genGlass['oceanic']!;
  return NptIdentity(
    motif: _motifByGlassTint[cfg.glassTint] ?? NptMotifKind.sonarRings,
    motifStrength: g.$5,
    glassOnTertiary: g.$1,
    glassMixRatio: g.$2,
    glassSurfaceOpacity: g.$3,
    glassBlur: g.$4,
    dashboardHero: cfg.dashboardHero,
    loginShell: cfg.loginShell,
    contentTone: cfg.contentTone,
  );
}
