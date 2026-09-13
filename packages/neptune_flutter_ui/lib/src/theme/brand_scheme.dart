// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

/// A BRAND'S OWN `ColorScheme`, SUPPLIED WHOLE, INSTEAD OF ONE GENERATED FROM
/// SEEDS.
///
/// Odyssey builds a bank's palette from two OKLCH seeds through the v1 ramp
/// (`color/palette.dart`). That is right for a brand being designed inside
/// Odyssey and wrong for one that has already shipped, because **the ramp
/// reads only hue and chroma off a seed and pins every role's LIGHTNESS to a
/// constant**: `_light['primary']` is `_Recipe(0.48, …)` whatever it is given.
/// A bank whose primary is a deep navy therefore cannot be seeded into
/// existence. Nuran's `#114075` sits at L 0.372 and comes back at L 0.48 — a
/// mid blue. That is not a tuning problem; no seed produces it, because the
/// seed's `l` is discarded on the way in.
///
/// It matters beyond fidelity. A bank with an app in customers' hands has a
/// palette that is already a fact: printed, screenshotted, approved, and in
/// places contractually fixed. Re-deriving it is not a decision we are
/// entitled to make, and "close enough" is the wrong standard for a colour a
/// customer has been looking at for a year.
///
/// So a brand may hand Odyssey its finished schemes. Pass one of these to
/// [NeptuneTheme.fromConfig] / `.fromBrandprint` and the ramp is bypassed for
/// the Material roles; pass nothing and the generated path runs exactly as it
/// did before, byte for byte.
///
/// WHAT IT IS NOT:
///
/// * **Not a brandprint field, and not a wire change.** This is theme
///   construction, so it costs no byte, no flag bit and no registry slot. A
///   brandprint still carries the seeds, which is what the web and Studio
///   ports and every non-Material token are built from; this only says "for
///   the Material roles, use these instead of the ramp's answer".
/// * **Not a licence to hand-mix colour in a screen.** The point is that the
///   exact palette arrives through the THEME, so no widget has to know which
///   bank it is drawing. A colour literal in a screen is still the bug this
///   exists to make unnecessary.
/// * **Not brightness-optional.** Both schemes are required. A brand that
///   supplied only one would silently fall back to the ramp at the other
///   brightness — the bank's real navy by day and a generated blue at night,
///   which is the inversion class of bug [NptBrandCanvas] exists to prevent.
@immutable
class NptBrandScheme {
  /// The brand's finished light scheme, used verbatim.
  final ColorScheme light;

  /// The brand's finished dark scheme, used verbatim.
  final ColorScheme dark;

  /// The brand's success colour per brightness.
  ///
  /// Material has no `success` role, so a shipped brand's scheme cannot carry
  /// one and every bank that needs it keeps it beside the scheme. Odyssey does
  /// have the role ([NptColors.success]), so it is asked for here rather than
  /// left to the ramp: a generated green at a fixed hue, standing next to a
  /// hand-picked palette, is the one colour on the screen that would not be
  /// the bank's.
  ///
  /// The CONTAINER pair is derived from these rather than asked for, because
  /// no shipped scheme has ever had one to give — see `_successContainer` in
  /// `neptune_theme.dart`.
  final Color successLight;
  final Color successDark;

  // NOT `const`: the asserts read `ColorScheme.brightness`, a field on an
  // object that is not const-evaluable. Keeping the asserts is worth more than
  // keeping the constructor const — a brand that handed over two LIGHT schemes
  // by copy-paste would otherwise get a dark theme that is silently light, and
  // that is not a failure anyone catches in a code review.
  NptBrandScheme({
    required this.light,
    required this.dark,
    required this.successLight,
    required this.successDark,
  })  : assert(light.brightness == Brightness.light,
            'NptBrandScheme.light must declare Brightness.light.'),
        assert(dark.brightness == Brightness.dark,
            'NptBrandScheme.dark must declare Brightness.dark.');

  /// The scheme for [mode].
  ColorScheme of(Brightness mode) => mode == Brightness.light ? light : dark;

  /// The success ink for [mode].
  Color successOf(Brightness mode) =>
      mode == Brightness.light ? successLight : successDark;

  @override
  bool operator ==(Object other) =>
      other is NptBrandScheme &&
      other.light == light &&
      other.dark == dark &&
      other.successLight == successLight &&
      other.successDark == successDark;

  @override
  int get hashCode => Object.hash(light, dark, successLight, successDark);
}
