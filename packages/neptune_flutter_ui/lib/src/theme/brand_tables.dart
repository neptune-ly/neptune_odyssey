// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Pinned per-brand extension data for the four reference brands: success colour
// role (tokens.resolved.json), corner family + typography (tokens.json), and the
// motion presets keyed by the motion lever (tokens.json levers.byBrand). Plus the
// canonical BrandprintConfig per brand (brandprints.golden.json) for round-trips.

import 'package:flutter/material.dart';

import '../brandprint/codec.dart';
import 'extensions.dart';

/// success / on / container / on-container per brand × mode (from tokens.resolved.json).
const Map<String, (NptColors light, NptColors dark)> brandSuccess = {
  'neptune': (
    NptColors(
      success: Color(0xFF2E9052),
      onSuccess: Color(0xFFF2FFF5),
      successContainer: Color(0xFFBCECC8),
      onSuccessContainer: Color(0xFF003006),
    ),
    NptColors(
      success: Color(0xFF79CE91),
      onSuccess: Color(0xFF002405),
      successContainer: Color(0xFF00461B),
      onSuccessContainer: Color(0xFFBCECC8),
    ),
  ),
  'triton': (
    NptColors(
      success: Color(0xFF2D8949),
      onSuccess: Color(0xFFF3FFF5),
      successContainer: Color(0xFFBEECC6),
      onSuccessContainer: Color(0xFF003003),
    ),
    NptColors(
      success: Color(0xFF7CCD8E),
      onSuccess: Color(0xFF002403),
      successContainer: Color(0xFF004519),
      onSuccessContainer: Color(0xFFBEECC6),
    ),
  ),
  'nereid': (
    NptColors(
      success: Color(0xFF2E9052),
      onSuccess: Color(0xFFF2FFF5),
      successContainer: Color(0xFFBCECC8),
      onSuccessContainer: Color(0xFF003006),
    ),
    NptColors(
      success: Color(0xFF79CE91),
      onSuccess: Color(0xFF002405),
      successContainer: Color(0xFF00461B),
      onSuccessContainer: Color(0xFFBCECC8),
    ),
  ),
  'proteus': (
    NptColors(
      success: Color(0xFF2E9052),
      onSuccess: Color(0xFFF2FFF5),
      successContainer: Color(0xFFBCECC8),
      onSuccessContainer: Color(0xFF003006),
    ),
    NptColors(
      success: Color(0xFF79CE91),
      onSuccess: Color(0xFF002405),
      successContainer: Color(0xFF00461B),
      onSuccessContainer: Color(0xFFBCECC8),
    ),
  ),
};

/// Corner family per brand (px), from tokens.json themes.<brand>.shape.
const Map<String, NptShape> brandShape = {
  'neptune': NptShape(xs: 8, sm: 12, md: 16, lg: 24, xl: 32, xxl: 44),
  'triton': NptShape(xs: 12, sm: 18, md: 26, lg: 34, xl: 44, xxl: 56),
  'nereid': NptShape(xs: 4, sm: 8, md: 12, lg: 18, xl: 26, xxl: 36),
  'proteus': NptShape(xs: 6, sm: 10, md: 14, lg: 20, xl: 28, xxl: 38),
};

/// Type set per brand. displayWeight/Tracking from the canonical brandprint
/// config; Latin + Arabic faces from tokens.json (`--npt-font-*` / `*-ar`).
/// Under RTL the web maps `num` → `text-ar`, so `numAr` mirrors `textAr`.
const Map<String, NptType> brandType = {
  'neptune': NptType(
    display: 'Hanken Grotesk',
    text: 'Hanken Grotesk',
    num: 'Hanken Grotesk',
    displayAr: 'IBM Plex Sans Arabic',
    textAr: 'IBM Plex Sans Arabic',
    numAr: 'IBM Plex Sans Arabic',
    displayWeight: 700,
    displayTracking: -0.02,
  ),
  'triton': NptType(
    display: 'Bricolage Grotesque',
    text: 'Hanken Grotesk',
    num: 'Hanken Grotesk',
    displayAr: 'Reem Kufi',
    textAr: 'Tajawal',
    numAr: 'Tajawal',
    displayWeight: 700,
    displayTracking: -0.01,
  ),
  'nereid': NptType(
    display: 'Space Grotesk',
    text: 'Hanken Grotesk',
    num: 'Space Grotesk',
    displayAr: 'Readex Pro',
    textAr: 'Readex Pro',
    numAr: 'Readex Pro',
    displayWeight: 600,
    displayTracking: -0.03,
  ),
  'proteus': NptType(
    display: 'Sora',
    text: 'Hanken Grotesk',
    num: 'Sora',
    displayAr: 'Noto Kufi Arabic',
    textAr: 'IBM Plex Sans Arabic',
    numAr: 'IBM Plex Sans Arabic',
    displayWeight: 700,
    displayTracking: -0.02,
  ),
};

/// Motion presets keyed by the motion lever (tokens.json levers.byBrand).
/// Cubic-bezier control points ported verbatim; the spring uses an overshoot
/// curve (matched to the web `spring` bezier).
const Map<String, NptMotion> motionPresets = {
  'smooth-fluid': NptMotion(
    standard: Cubic(0.2, 0, 0, 1),
    emphasized: Cubic(0.2, 0, 0, 1),
    spring: Cubic(0.34, 1.56, 0.64, 1),
    fast: Duration(milliseconds: 240),
    durationStandard: Duration(milliseconds: 300),
    slow: Duration(milliseconds: 500),
    glassBlur: 18,
  ),
  'calm-graceful': NptMotion(
    standard: Cubic(0.25, 0, 0.2, 1),
    emphasized: Cubic(0.2, 0, 0.1, 1),
    spring: Cubic(0.3, 1.3, 0.5, 1),
    fast: Duration(milliseconds: 280),
    durationStandard: Duration(milliseconds: 340),
    slow: Duration(milliseconds: 560),
    glassBlur: 16,
  ),
  'light-quick-crisp': NptMotion(
    standard: Cubic(0.2, 0, 0, 1),
    emphasized: Cubic(0.2, 0, 0, 1),
    spring: Cubic(0.34, 1.56, 0.64, 1),
    fast: Duration(milliseconds: 200),
    durationStandard: Duration(milliseconds: 240),
    slow: Duration(milliseconds: 400),
    glassBlur: 22,
  ),
  'stable-minimal-authoritative': NptMotion(
    standard: Cubic(0.3, 0, 0.2, 1),
    emphasized: Cubic(0.25, 0, 0.15, 1),
    spring: Cubic(0.2, 0.9, 0.3, 1),
    fast: Duration(milliseconds: 240),
    durationStandard: Duration(milliseconds: 280),
    slow: Duration(milliseconds: 460),
    glassBlur: 14,
  ),
};

const NptMotion _fallbackMotion = NptMotion(
  standard: Cubic(0.2, 0, 0, 1),
  emphasized: Cubic(0.2, 0, 0, 1),
  spring: Cubic(0.34, 1.56, 0.64, 1),
  fast: Duration(milliseconds: 240),
  durationStandard: Duration(milliseconds: 300),
  slow: Duration(milliseconds: 500),
  glassBlur: 18,
);

NptMotion motionFor(String lever) => motionPresets[lever] ?? _fallbackMotion;

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
