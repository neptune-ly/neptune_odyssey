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
  // Card-art gradient. Light rides the raw brand seeds.
  'card-start': _Recipe(0.48, _Chroma.mult(1), _primary),
  'card-end': _Recipe(0.55, _Chroma.mult(1), _tertiary),
  'on-card': _Recipe(0.99, _Chroma.abs(0.02), _primary),
};

// Dark-mode ramp.
const Map<String, _Recipe> _dark = {
  // L 0.66, not 0.80. At L 0.80 the sRGB gamut caps chroma near 0.10 for a
  // blue hue, so a brand seed of 0.209 lost ~40% of its saturation and read
  // as a washed-out pale blue (device-reported). At 0.66 the full brand
  // chroma survives, and contrast still measures 5.9:1 against both the dark
  // surface and on-primary — comfortably past WCAG AA.
  'primary': _Recipe(0.66, _Chroma.mult(0.85), _primary),
  'on-primary': _Recipe(0.2, _Chroma.mult(0.67), _primary),
  'primary-container': _Recipe(0.36, _Chroma.mult(0.8), _primary),
  'on-primary-container': _Recipe(0.9, _Chroma.mult(0.47), _primary),
  'secondary': _Recipe(0.76, _Chroma.abs(0.05), _primary),
  'on-secondary': _Recipe(0.22, _Chroma.abs(0.04), _primary),
  'secondary-container': _Recipe(0.34, _Chroma.abs(0.04), _primary),
  'on-secondary-container': _Recipe(0.9, _Chroma.abs(0.035), _primary),
  'tertiary': _Recipe(0.70, _Chroma.mult(0.85), _tertiary),
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
  // Neutral floor at M3's dark-surface level (#141218 ≈ OKLCH L 0.18), not
  // near-black: L 0.13 read as "pitch black with floating cards" and made
  // every elevation step invisible. Chroma halved — at low lightness even
  // 0.012 of the primary hue reads as a coloured cast on what should be
  // neutral ground.
  'background': _Recipe(0.18, _Chroma.abs(0.008), _neutral),
  'on-background': _Recipe(0.92, _Chroma.abs(0.008), _neutral),
  'surface': _Recipe(0.18, _Chroma.abs(0.008), _neutral),
  'on-surface': _Recipe(0.92, _Chroma.abs(0.008), _neutral),
  'surface-variant': _Recipe(0.34, _Chroma.abs(0.02), _neutral),
  'on-surface-variant': _Recipe(0.78, _Chroma.abs(0.02), _neutral),
  'outline': _Recipe(0.58, _Chroma.abs(0.02), _neutral),
  'outline-variant': _Recipe(0.32, _Chroma.abs(0.02), _neutral),
  'surface-container-lowest': _Recipe(0.14, _Chroma.abs(0.008), _neutral),
  'surface-container-low': _Recipe(0.205, _Chroma.abs(0.008), _neutral),
  'surface-container': _Recipe(0.225, _Chroma.abs(0.009), _neutral),
  'surface-container-high': _Recipe(0.25, _Chroma.abs(0.01), _neutral),
  'surface-container-highest': _Recipe(0.29, _Chroma.abs(0.011), _neutral),
  'inverse-surface': _Recipe(0.92, _Chroma.abs(0.01), _neutral),
  'inverse-on-surface': _Recipe(0.2, _Chroma.abs(0.02), _neutral),
  'inverse-primary': _Recipe(0.48, _Chroma.mult(1), _primary),
  'scrim': _Recipe(0, _Chroma.abs(0), _neutral),
  // Card-art gradient, DARK: deeper and slightly desaturated. The light
  // gradient at full seed brightness glared against dark surfaces — the
  // card was the only light-mode object on a dark screen.
  'card-start': _Recipe(0.42, _Chroma.mult(0.9), _primary),
  'card-end': _Recipe(0.36, _Chroma.mult(0.85), _tertiary),
  'on-card': _Recipe(0.97, _Chroma.abs(0.015), _primary),
};

/// How much chroma a branded ground carries, as a multiplier on the recipe's
/// own declared (absolute) chroma.
///
/// 2.4 is the smallest value at which the light ground reads as a chosen
/// paper rather than as a cast: tone 98 at 0.006 is a colour nobody picked,
/// and at 0.0144 it is a cream. Above ~3 the surface starts competing with
/// `tertiary-container` and a page of cards stops separating from it.
const double _groundChroma = 2.4;

/// The neutral roles the ground lever is allowed to touch: the PAPER, never
/// the INK.
///
/// Found on a device, not in a review. The first cut warmed every role whose
/// hue came from the neutral channel, which is also where `on-surface`,
/// `outline` and `inverse-surface` live — so a bank whose identity is navy
/// and red shipped a home screen with no navy anywhere on it: the balance
/// figure, the greeting and every label had gone brown along with the page
/// they sat on. The ground is a surface the brand chose; the text on it is
/// still the brand's ink.
const Set<String> _groundRoles = {
  'background',
  'surface',
  'surface-variant',
  'surface-container-lowest',
  'surface-container-low',
  'surface-container',
  'surface-container-high',
  'surface-container-highest',
  // The hairline BETWEEN rows is part of the paper — a cool rule on a warm
  // page is the one seam that gives the tint away.
  'outline-variant',
};

/// Chrome roles that follow the ground's HUE but keep their own chroma.
///
/// `secondary-container` is the tonal chip behind a glyph — a quick action, a
/// list-row avatar, a selected segment — and it is ramped from the primary at
/// a fixed low chroma, so on a navy brand it is pale BLUE. Against a warmed
/// page that is the only foreign tint on the screen, and a screen with a cream
/// ground, peach controls and blue chips reads as an accident rather than a
/// scheme. Hue only: it already carries enough chroma to separate from the
/// paper, and multiplying it would turn a chip into a swatch.
///
/// `primary-container` AND `on-primary-container` WERE IN THIS SET AND ARE NOT
/// ANY MORE. The argument for them was the same one as above — a pale
/// periwinkle square on a cream page is the one cool object on the screen —
/// and on its own terms it was right. What it did not account for is the
/// brand that makes the ground warm in the first place.
///
/// `warmGround` is fed the brand's TERTIARY seed, and on a brand that also
/// sets `accentOnTertiary` that seed is the ACCENT — a colour whose whole
/// contract is that it feeds `NptColors.accent` and no Material role at all,
/// so that it cannot collide with an error state and cannot be spent twice on
/// one screen. Tinting a container role to it broke that contract at the
/// source: FGLB's light `primary-container` generated as #ffd4c9 with
/// #400000 ink — a pink chip with near-black-red text — while its `primary`
/// was navy #385aa3. Every account row, every balance card, every overlay
/// glyph square the bank drew in light mode carried it.
///
/// THE ASYMMETRY IS WHAT GIVES IT AWAY. The ground lever is two-sided (see
/// [generatePalette]): `groundH` is the warm seed's hue in light but the
/// PRIMARY's in dark. So in dark these two roles were already resolving to
/// exactly the hue they resolve to without this set, and the same line of code
/// produced a correct navy there and a pink here. A rule that only fires in
/// one brightness is not a rule about tint; it is a leak with a tint-shaped
/// comment on it.
///
/// Consequence, stated rather than discovered later: on a warm-ground brand
/// the tonal square is once again a cool tint on a warm page. That is the
/// trade the original comment was trying to avoid, and it is the right way
/// round — a brand role that reads slightly cool is a smaller fault than a
/// brand role wearing the one colour the brandprint reserved. A brand that
/// wants the square in its ground's family should say so with a lever, not
/// inherit it from the paper.
///
/// `secondary-container` STAYS, deliberately and narrowly: it is not a
/// `primary-*` Material role, nothing reserves it, and it is what the pocket
/// hero's own tonal chips resolve through on the one composition that is
/// already signed off. Removing it is a separate change with a separate
/// review, not a free rider on this one.
const Set<String> _groundTintedChrome = {
  'secondary-container',
  'on-secondary-container',
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
Map<String, String> generatePalette(Oklch primary, Oklch tertiary, String mode,
    {Oklch? warmSeed}) {
  final ramp = mode == 'light' ? _light : _dark;
  final light = mode == 'light';
  // The ground lever is TWO-SIDED, because "the brand chose its own page" is
  // one idea with two correct answers. In light the paper warms toward the
  // brand's warm seed — a cream, a sand, a blush. In dark it does NOT: warming
  // a dark ground toward a red-orange is brown, and nothing makes a brown app
  // read as anything but a mistake. Dark instead DEEPENS on the primary hue at
  // the same chroma, which turns a characterless near-black into the brand's
  // own ink. Same bit, same sentence, opposite direction.
  final groundH = warmSeed == null ? null : (light ? warmSeed.h : primary.h);
  final out = <String, String>{};
  ramp.forEach((role, recipe) {
    var hue = _resolveHue(recipe.hue, primary.h, tertiary.h);
    var c = _resolveChroma(
        recipe.c, recipe.hue.channel == 'tertiary' ? tertiary.c : primary.c);
    if (groundH != null && _groundRoles.contains(role)) {
      hue = groundH;
      c *= _groundChroma;
    } else if (groundH != null && _groundTintedChrome.contains(role)) {
      hue = groundH;
    }
    out[role] = oklchToHex(Oklch(recipe.l, c, hue));
  });
  return out;
}

/// Same as [generatePalette] but returns 0xAARRGGBB ints per role.
Map<String, int> generatePaletteArgb(Oklch primary, Oklch tertiary, String mode,
    {Oklch? warmSeed}) {
  final ramp = mode == 'light' ? _light : _dark;
  final light = mode == 'light';
  // The ground lever is TWO-SIDED, because "the brand chose its own page" is
  // one idea with two correct answers. In light the paper warms toward the
  // brand's warm seed — a cream, a sand, a blush. In dark it does NOT: warming
  // a dark ground toward a red-orange is brown, and nothing makes a brown app
  // read as anything but a mistake. Dark instead DEEPENS on the primary hue at
  // the same chroma, which turns a characterless near-black into the brand's
  // own ink. Same bit, same sentence, opposite direction.
  final groundH = warmSeed == null ? null : (light ? warmSeed.h : primary.h);
  final out = <String, int>{};
  ramp.forEach((role, recipe) {
    var hue = _resolveHue(recipe.hue, primary.h, tertiary.h);
    var c = _resolveChroma(
        recipe.c, recipe.hue.channel == 'tertiary' ? tertiary.c : primary.c);
    if (groundH != null && _groundRoles.contains(role)) {
      hue = groundH;
      c *= _groundChroma;
    } else if (groundH != null && _groundTintedChrome.contains(role)) {
      hue = groundH;
    }
    out[role] = oklchToArgb(Oklch(recipe.l, c, hue));
  });
  return out;
}
