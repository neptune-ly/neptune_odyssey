// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// 2.26.0 — the wrist. A watch has no room for the fifteen-step Material type
// ramp, and a glance has exactly four registers: the figure, its unit, the line
// that dates it, and the rows under it. This is that scale, plus the one layout
// rule a round face imposes, as a ThemeExtension so a host reads it the way it
// reads every other Odyssey token — never from a number typed into a screen.

import 'package:flutter/material.dart';

import 'extensions.dart';

/// The glance scale: what a wrist, a tile or a complication draws with.
///
/// Sizes are logical pixels. They are NOT derived from the phone `TextTheme`
/// by a factor, because a factor keeps the phone's proportions and a wrist
/// needs different ones — the figure is nearly three times the row meta,
/// where a phone's `displaySmall`/`bodySmall` pair is three-to-one only in
/// name. The KMP token module carries the same values in `Glance.kt`, and
/// native watch targets that cannot depend on either copy them and pin the
/// copy with a test.
///
/// Web counterpart: none yet — no `<npt-glance>` element exists.
@immutable
class NptGlance extends ThemeExtension<NptGlance> {
  /// The balance itself. Large enough to read at arm's length in one second.
  final double figure;

  /// The currency, set beside the figure at a lower baseline.
  final double unit;

  /// The eyebrow over the figure: account label + tail. Uppercase, tracked
  /// by [eyebrowTracking] em, like `NeptuneEyebrow`.
  final double eyebrow;
  final double eyebrowTracking;

  /// The "as of" / stale / hidden line under the figure.
  final double provenance;

  /// A row's title, and a row's amount and date.
  final double rowTitle;
  final double rowMeta;

  /// Line heights, as multipliers.
  final double figureLineHeight;
  final double rowLineHeight;

  /// On a round face, content that reaches the edge is cut by the bezel. This
  /// fraction of the diameter on every side is the safe area; applied as
  /// padding, a rectangular face simply gets a calmer margin.
  final double roundInsetFraction;

  /// The gap between the figure block and the first row; row-to-row rhythm.
  final double sectionGap;
  final double rowGap;

  /// The platform minimum touch target on a wrist.
  final double minTouch;

  /// The direction glyph's disc beside a row.
  final double rowGlyph;

  const NptGlance({
    this.figure = 30,
    this.unit = 13,
    this.eyebrow = 11,
    this.eyebrowTracking = 0.08,
    this.provenance = 12,
    this.rowTitle = 14,
    this.rowMeta = 12,
    this.figureLineHeight = 1.15,
    this.rowLineHeight = 1.3,
    this.roundInsetFraction = 0.10,
    this.sectionGap = 12,
    this.rowGap = 6,
    this.minTouch = 48,
    this.rowGlyph = 20,
  });

  /// The scale every Odyssey theme carries. One instance, no levers: a brand
  /// changes what a glance is coloured and typeset with, not how big a wrist
  /// figure is.
  static const standard = NptGlance();

  /// The figure's style in the theme's num face, tabular, direction-aware —
  /// [NeptuneTheme.moneyStyle] at the wrist size.
  TextStyle figureStyle(BuildContext context) {
    final type = Theme.of(context).extension<NptType>()!;
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    return TextStyle(
      fontFamily: rtl ? type.numAr : type.num,
      fontFamilyFallback: type.fontFamilyFallback,
      fontSize: figure,
      height: figureLineHeight,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// The eyebrow's style: display face, uppercase is the caller's, tracking
  /// in em resolved against [eyebrow].
  TextStyle eyebrowStyle(BuildContext context) {
    final type = Theme.of(context).extension<NptType>()!;
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    return TextStyle(
      fontFamily: rtl ? type.displayAr : type.display,
      fontFamilyFallback: type.fontFamilyFallback,
      fontSize: eyebrow,
      fontWeight: FontWeight.w600,
      letterSpacing: eyebrowTracking * eyebrow,
    );
  }

  /// The safe-area inset for a face of [diameter].
  EdgeInsetsDirectional insetFor(double diameter) =>
      EdgeInsetsDirectional.all(diameter * roundInsetFraction);

  @override
  NptGlance copyWith({
    double? figure,
    double? unit,
    double? eyebrow,
    double? eyebrowTracking,
    double? provenance,
    double? rowTitle,
    double? rowMeta,
    double? figureLineHeight,
    double? rowLineHeight,
    double? roundInsetFraction,
    double? sectionGap,
    double? rowGap,
    double? minTouch,
    double? rowGlyph,
  }) =>
      NptGlance(
        figure: figure ?? this.figure,
        unit: unit ?? this.unit,
        eyebrow: eyebrow ?? this.eyebrow,
        eyebrowTracking: eyebrowTracking ?? this.eyebrowTracking,
        provenance: provenance ?? this.provenance,
        rowTitle: rowTitle ?? this.rowTitle,
        rowMeta: rowMeta ?? this.rowMeta,
        figureLineHeight: figureLineHeight ?? this.figureLineHeight,
        rowLineHeight: rowLineHeight ?? this.rowLineHeight,
        roundInsetFraction: roundInsetFraction ?? this.roundInsetFraction,
        sectionGap: sectionGap ?? this.sectionGap,
        rowGap: rowGap ?? this.rowGap,
        minTouch: minTouch ?? this.minTouch,
        rowGlyph: rowGlyph ?? this.rowGlyph,
      );

  @override
  NptGlance lerp(ThemeExtension<NptGlance>? other, double t) {
    if (other is! NptGlance) return this;
    double l(double a, double b) => a + (b - a) * t;
    return NptGlance(
      figure: l(figure, other.figure),
      unit: l(unit, other.unit),
      eyebrow: l(eyebrow, other.eyebrow),
      eyebrowTracking: l(eyebrowTracking, other.eyebrowTracking),
      provenance: l(provenance, other.provenance),
      rowTitle: l(rowTitle, other.rowTitle),
      rowMeta: l(rowMeta, other.rowMeta),
      figureLineHeight: l(figureLineHeight, other.figureLineHeight),
      rowLineHeight: l(rowLineHeight, other.rowLineHeight),
      roundInsetFraction: l(roundInsetFraction, other.roundInsetFraction),
      sectionGap: l(sectionGap, other.sectionGap),
      rowGap: l(rowGap, other.rowGap),
      minTouch: l(minTouch, other.minTouch),
      rowGlyph: l(rowGlyph, other.rowGlyph),
    );
  }
}
