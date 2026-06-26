// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Seed -> palette: the v1 OKLCH ramp (Dart port of color/palette.ts). ONE
// palette-generation algorithm shared by every platform (docs/11 "Determinism").
// Used for CUSTOM seeds (the configurator); the four reference brands ship their
// pinned canonical palette. Pinned for v1 — any change bumps the brandprint
// version (NO2-).

import 'oklch.dart';

/// Where a role's hue comes from. Either a fixed hue (in degrees) or one of the
/// seed channels.
class _HueSource {
  /// 'primary' | 'tertiary' | 'neutral', or null when [fixed] is set.
  final String? channel;
  final double? fixed;
  const _HueSource.channel(this.channel) : fixed = null;
  const _HueSource.fixed(this.fixed) : channel = null;
}

/// Chroma is either an absolute value or a multiplier of the source seed chroma.
class _Chroma {
  final double? abs;
  final double? mult;
  const _Chroma.abs(this.abs) : mult = null;
  const _Chroma.mult(this.mult) : abs = null;
}

class _Recipe {
  final double l;
  final _Chroma c;
  final _HueSource hue;
  const _Recipe(this.l, this.c, this.hue);
}

// Fixed semantic hues (error/success are brand-invariant for trust + legibility).
const double _errorH = 27;
const double _successH = 152;

const _HueSource _primary = _HueSource.channel('primary');
const _HueSource _tertiary = _HueSource.channel('tertiary');
const _HueSource _neutral = _HueSource.channel('neutral');
const _HueSource _errorHue = _HueSource.fixed(_errorH);
const _HueSource _successHue = _HueSource.fixed(_successH);

// Light-mode ramp (role -> recipe).
const Map<String, _Recipe> _light = {
  'primary': _Recipe(0.48, _Chroma.mult(1), _primary),
  'on-primary': _Recipe(0.99, _Chroma.abs(0.02), _primary),
  'primary-container': _Recipe(0.91, _Chroma.mult(0.47), _primary),
  'on-primary-container': _Recipe(0.22, _Chroma.mult(0.87), _primary),
  'secondary': _Recipe(0.5, _Chroma.abs(0.06), _primary),
  'on-secondary': _Recipe(0.99, _Chroma.abs(0.02), _primary),
  'secondary-container': _Recipe(0.92, _Chroma.abs(0.035), _primary),
  'on-secondary-container': _Recipe(0.25, _Chroma.abs(0.05), _primary),
  'tertiary': _Recipe(0.55, _Chroma.mult(1), _tertiary),
  'on-tertiary': _Recipe(0.99, _Chroma.abs(0.02), _tertiary),
  'tertiary-container': _Recipe(0.9, _Chroma.mult(0.6), _tertiary),
  'on-tertiary-container': _Recipe(0.26, _Chroma.mult(0.8), _tertiary),
  'error': _Recipe(0.52, _Chroma.abs(0.2), _errorHue),
  'on-error': _Recipe(0.99, _Chroma.abs(0.02), _errorHue),
  'error-container': _Recipe(0.92, _Chroma.abs(0.07), _errorHue),
  'on-error-container': _Recipe(0.28, _Chroma.abs(0.16), _errorHue),
  'success': _Recipe(0.58, _Chroma.abs(0.13), _successHue),
  'on-success': _Recipe(0.99, _Chroma.abs(0.02), _successHue),
  'success-container': _Recipe(0.9, _Chroma.abs(0.07), _successHue),
  'on-success-container': _Recipe(0.26, _Chroma.abs(0.1), _successHue),
  'background': _Recipe(0.985, _Chroma.abs(0.006), _neutral),
  'on-background': _Recipe(0.16, _Chroma.abs(0.02), _neutral),
  'surface': _Recipe(0.985, _Chroma.abs(0.006), _neutral),
  'on-surface': _Recipe(0.16, _Chroma.abs(0.02), _neutral),
  'surface-variant': _Recipe(0.9, _Chroma.abs(0.018), _neutral),
  'on-surface-variant': _Recipe(0.4, _Chroma.abs(0.025), _neutral),
  'outline': _Recipe(0.62, _Chroma.abs(0.02), _neutral),
  'outline-variant': _Recipe(0.86, _Chroma.abs(0.015), _neutral),
  'surface-container-lowest': _Recipe(1, _Chroma.abs(0), _neutral),
  'surface-container-low': _Recipe(0.965, _Chroma.abs(0.006), _neutral),
  'surface-container': _Recipe(0.945, _Chroma.abs(0.008), _neutral),
  'surface-container-high': _Recipe(0.925, _Chroma.abs(0.01), _neutral),
  'surface-container-highest': _Recipe(0.905, _Chroma.abs(0.012), _neutral),
  'inverse-surface': _Recipe(0.24, _Chroma.abs(0.02), _neutral),
  'inverse-on-surface': _Recipe(0.96, _Chroma.abs(0.006), _neutral),
  'inverse-primary': _Recipe(0.82, _Chroma.mult(0.8), _primary),
  'scrim': _Recipe(0.08, _Chroma.abs(0.02), _neutral),
};

// Dark-mode ramp.
const Map<String, _Recipe> _dark = {
  'primary': _Recipe(0.8, _Chroma.mult(0.8), _primary),
  'on-primary': _Recipe(0.2, _Chroma.mult(0.67), _primary),
  'primary-container': _Recipe(0.36, _Chroma.mult(0.8), _primary),
  'on-primary-container': _Recipe(0.9, _Chroma.mult(0.47), _primary),
  'secondary': _Recipe(0.82, _Chroma.abs(0.04), _primary),
  'on-secondary': _Recipe(0.22, _Chroma.abs(0.04), _primary),
  'secondary-container': _Recipe(0.34, _Chroma.abs(0.04), _primary),
  'on-secondary-container': _Recipe(0.9, _Chroma.abs(0.035), _primary),
  'tertiary': _Recipe(0.82, _Chroma.mult(0.8), _tertiary),
  'on-tertiary': _Recipe(0.22, _Chroma.mult(0.6), _tertiary),
  'tertiary-container': _Recipe(0.34, _Chroma.mult(0.7), _tertiary),
  'on-tertiary-container': _Recipe(0.9, _Chroma.mult(0.6), _tertiary),
  'error': _Recipe(0.78, _Chroma.abs(0.13), _errorHue),
  'on-error': _Recipe(0.24, _Chroma.abs(0.1), _errorHue),
  'error-container': _Recipe(0.36, _Chroma.abs(0.14), _errorHue),
  'on-error-container': _Recipe(0.92, _Chroma.abs(0.06), _errorHue),
  'success': _Recipe(0.78, _Chroma.abs(0.12), _successHue),
  'on-success': _Recipe(0.22, _Chroma.abs(0.08), _successHue),
  'success-container': _Recipe(0.34, _Chroma.abs(0.1), _successHue),
  'on-success-container': _Recipe(0.9, _Chroma.abs(0.07), _successHue),
  'background': _Recipe(0.13, _Chroma.abs(0.012), _neutral),
  'on-background': _Recipe(0.92, _Chroma.abs(0.01), _neutral),
  'surface': _Recipe(0.13, _Chroma.abs(0.012), _neutral),
  'on-surface': _Recipe(0.92, _Chroma.abs(0.01), _neutral),
  'surface-variant': _Recipe(0.34, _Chroma.abs(0.02), _neutral),
  'on-surface-variant': _Recipe(0.78, _Chroma.abs(0.02), _neutral),
  'outline': _Recipe(0.58, _Chroma.abs(0.02), _neutral),
  'outline-variant': _Recipe(0.32, _Chroma.abs(0.02), _neutral),
  'surface-container-lowest': _Recipe(0.09, _Chroma.abs(0.012), _neutral),
  'surface-container-low': _Recipe(0.16, _Chroma.abs(0.014), _neutral),
  'surface-container': _Recipe(0.18, _Chroma.abs(0.016), _neutral),
  'surface-container-high': _Recipe(0.22, _Chroma.abs(0.018), _neutral),
  'surface-container-highest': _Recipe(0.27, _Chroma.abs(0.02), _neutral),
  'inverse-surface': _Recipe(0.92, _Chroma.abs(0.01), _neutral),
  'inverse-on-surface': _Recipe(0.2, _Chroma.abs(0.02), _neutral),
  'inverse-primary': _Recipe(0.48, _Chroma.mult(1), _primary),
  'scrim': _Recipe(0, _Chroma.abs(0), _neutral),
};

double _resolveHue(_HueSource src, double primaryH, double tertiaryH) {
  if (src.fixed != null) return src.fixed!;
  if (src.channel == 'tertiary') return tertiaryH;
  return primaryH; // primary + neutral both ride the primary hue
}

double _resolveChroma(_Chroma c, double seedC) =>
    c.abs ?? seedC * c.mult!;

/// Generate a full 37-role palette (role -> "#rrggbb") from primary + tertiary
/// seeds via the v1 ramp. Used for custom (non-reference) seeds.
Map<String, String> generatePalette(Oklch primary, Oklch tertiary, String mode) {
  final ramp = mode == 'light' ? _light : _dark;
  final out = <String, String>{};
  ramp.forEach((role, recipe) {
    final hue = _resolveHue(recipe.hue, primary.h, tertiary.h);
    final seedC = recipe.hue.channel == 'tertiary' ? tertiary.c : primary.c;
    final c = _resolveChroma(recipe.c, seedC);
    out[role] = oklchToHex(Oklch(recipe.l, c, hue));
  });
  return out;
}

/// Same as [generatePalette] but returns 0xAARRGGBB ints per role.
Map<String, int> generatePaletteArgb(Oklch primary, Oklch tertiary, String mode) {
  final ramp = mode == 'light' ? _light : _dark;
  final out = <String, int>{};
  ramp.forEach((role, recipe) {
    final hue = _resolveHue(recipe.hue, primary.h, tertiary.h);
    final seedC = recipe.hue.channel == 'tertiary' ? tertiary.c : primary.c;
    final c = _resolveChroma(recipe.c, seedC);
    out[role] = oklchToArgb(Oklch(recipe.l, c, hue));
  });
  return out;
}
