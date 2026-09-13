// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Neptune Odyssey ThemeExtensions: success colour role (an M3 addition not in
// ColorScheme), the per-brand corner family, the brand type set, and brand
// motion. Read these from Theme.of(context) — never hard-code a value.

import 'package:flutter/material.dart';

/// The `success` colour role + its on/container variants (not part of M3's
/// [ColorScheme]) plus the card-art identity roles. Values come from
/// tokens.resolved.json.
@immutable
class NptColors extends ThemeExtension<NptColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  /// Card-art gradient start (135°, paired with [cardGradientEnd]) —
  /// brightness-INVARIANT: always the brand's light tone in both light and
  /// dark theme. A payment-card face depicts a physical instrument, not a
  /// themed UI surface, so it doesn't invert with dark mode the way
  /// [ColorScheme.primary] does. See `NeptuneCardArt`.
  final Color cardGradientStart;

  /// Card-art gradient end, paired with [cardGradientStart]. Same
  /// brightness-invariance rationale.
  final Color cardGradientEnd;

  /// Card-art text/icon colour, paired with the card gradient — always the
  /// brand's light on-primary tone regardless of app brightness.
  final Color onCard;

  /// The direction-and-confirmation accent: the forward CTA, the active step
  /// in a flow, an upward movement in a chart - and nothing else. Equal to
  /// `ColorScheme.primary` unless the brandprint sets `accentOnTertiary`, in
  /// which case it is the tertiary seed and that seed feeds NO Material role,
  /// so the accent cannot reach chrome through `tertiary*` or the card
  /// gradient. A red spent on every surface reads as an error state; spent
  /// once per screen it reads as the brand's mark. Widgets that are not one of
  /// those three things keep using the scheme roles.
  final Color accent;

  /// Content on [accent].
  final Color onAccent;

  const NptColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.onCard,
    required this.accent,
    required this.onAccent,
  });

  @override
  NptColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? cardGradientStart,
    Color? cardGradientEnd,
    Color? onCard,
    Color? accent,
    Color? onAccent,
  }) =>
      NptColors(
        success: success ?? this.success,
        onSuccess: onSuccess ?? this.onSuccess,
        successContainer: successContainer ?? this.successContainer,
        onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
        cardGradientStart: cardGradientStart ?? this.cardGradientStart,
        cardGradientEnd: cardGradientEnd ?? this.cardGradientEnd,
        onCard: onCard ?? this.onCard,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
      );

  @override
  NptColors lerp(ThemeExtension<NptColors>? other, double t) {
    if (other is! NptColors) return this;
    return NptColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      cardGradientStart: Color.lerp(cardGradientStart, other.cardGradientStart, t)!,
      cardGradientEnd: Color.lerp(cardGradientEnd, other.cardGradientEnd, t)!,
      onCard: Color.lerp(onCard, other.onCard, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}

/// The six brand corner radii (px) plus `full` (9999 → a circle) and [pill].
@immutable
class NptShape extends ThemeExtension<NptShape> {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  /// A CIRCLE. Reach for it when the thing being drawn is round whatever the
  /// brand is: an avatar, a badge, a dot, a round icon button, the dock's
  /// raised-active puck.
  final double full;

  /// A STADIUM-SHAPED CONTAINER — a chip, a segmented track, a switch track,
  /// a search field, a pill button.
  ///
  /// It is a separate token from [full] because those two used to be the same
  /// number and a brand had no way to tell them apart: `ruledRegister` said
  /// "this bank draws structure in lines, not slabs", the button theme and
  /// the CTA honoured it, and then every chip, tab indicator and segmented
  /// control on the same screen went on drawing a stadium — because they read
  /// `full`, which also means "circle", and squaring `full` would have turned
  /// the avatars into squares too. A sharp institutional brand shipped a
  /// ruled button sitting on a row of pills, which is exactly the mushy middle
  /// the lever exists to prevent.
  ///
  /// Resolves to [full] for a brand in the default register and to [md] under
  /// `BrandprintConfig.ruledRegister` — the same corner its ruled buttons,
  /// fields and sheets carry, so the whole screen is drawn at one radius.
  final double pill;

  const NptShape({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    this.full = 9999,
    double? pill,
  }) : pill = pill ?? full;

  BorderRadius get rXs => BorderRadius.circular(xs);
  BorderRadius get rSm => BorderRadius.circular(sm);
  BorderRadius get rMd => BorderRadius.circular(md);
  BorderRadius get rLg => BorderRadius.circular(lg);
  BorderRadius get rXl => BorderRadius.circular(xl);
  BorderRadius get rXxl => BorderRadius.circular(xxl);

  /// The stadium container's radius, ready to use.
  BorderRadius get rPill => BorderRadius.circular(pill);

  /// The stadium container as an [OutlinedBorder] — a real [StadiumBorder]
  /// when the brand is round, so a Material widget that lerps its shape keeps
  /// lerping between the same two classes it always did.
  OutlinedBorder get pillBorder => pill >= 9999
      ? const StadiumBorder()
      : RoundedRectangleBorder(borderRadius: rPill);

  @override
  NptShape copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? full,
    double? pill,
  }) =>
      NptShape(
        xs: xs ?? this.xs,
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        xl: xl ?? this.xl,
        xxl: xxl ?? this.xxl,
        full: full ?? this.full,
        pill: pill ?? this.pill,
      );

  @override
  NptShape lerp(ThemeExtension<NptShape>? other, double t) {
    if (other is! NptShape) return this;
    double l(double a, double b) => a + (b - a) * t;
    return NptShape(
      xs: l(xs, other.xs),
      sm: l(sm, other.sm),
      md: l(md, other.md),
      lg: l(lg, other.lg),
      xl: l(xl, other.xl),
      xxl: l(xxl, other.xxl),
      full: l(full, other.full),
      pill: l(pill, other.pill),
    );
  }
}

/// Brand font families + display weight/tracking. Money/number UI should use
/// the [num] family with [FontFeature.tabularFigures].
///
/// Each family has a Latin face and an Arabic face. Under RTL the web swaps
/// `--npt-font-*` to the `*-ar` token (and maps `num` → `text-ar`); the Flutter
/// theme does the same via [NeptuneTheme]'s `arabic` flag and a
/// direction-aware [NeptuneTheme.moneyStyle].
@immutable
class NptType extends ThemeExtension<NptType> {
  final String display;
  final String text;
  final String num;

  /// Arabic display face (web `--npt-font-display-ar`).
  final String displayAr;

  /// Arabic text face (web `--npt-font-text-ar`).
  final String textAr;

  /// Arabic numeral face. The web maps `--npt-font-num` → `--npt-font-text-ar`
  /// under RTL, so this is normally the same as [textAr].
  final String numAr;

  final int displayWeight;

  /// Tracking in em (e.g. -0.02).
  final double displayTracking;

  /// True when every face above is one the HOST bundles as a Flutter asset
  /// (passed as `hostFont:` at assembly) rather than a google_fonts registry
  /// family. Text styles are then built by family name - the runtime loader
  /// is never consulted - and [fontFamilyFallback] rides on each of them.
  final bool bundled;

  /// Fallback chain behind a bundled face (a host's Latin safety net behind
  /// an Arabic-first family, say). Empty for registry families.
  final List<String> fontFamilyFallback;

  const NptType({
    required this.display,
    required this.text,
    required this.num,
    required this.displayWeight,
    required this.displayTracking,
    String? displayAr,
    String? textAr,
    String? numAr,
    this.bundled = false,
    this.fontFamilyFallback = const [],
  })  : displayAr = displayAr ?? 'IBM Plex Sans Arabic',
        textAr = textAr ?? 'IBM Plex Sans Arabic',
        numAr = numAr ?? textAr ?? 'IBM Plex Sans Arabic';

  FontWeight get displayFontWeight => switch (displayWeight) {
        100 => FontWeight.w100,
        200 => FontWeight.w200,
        300 => FontWeight.w300,
        400 => FontWeight.w400,
        500 => FontWeight.w500,
        600 => FontWeight.w600,
        700 => FontWeight.w700,
        800 => FontWeight.w800,
        900 => FontWeight.w900,
        _ => FontWeight.w700,
      };

  @override
  NptType copyWith({
    String? display,
    String? text,
    String? num,
    String? displayAr,
    String? textAr,
    String? numAr,
    int? displayWeight,
    double? displayTracking,
    bool? bundled,
    List<String>? fontFamilyFallback,
  }) =>
      NptType(
        display: display ?? this.display,
        text: text ?? this.text,
        num: num ?? this.num,
        displayAr: displayAr ?? this.displayAr,
        textAr: textAr ?? this.textAr,
        numAr: numAr ?? this.numAr,
        displayWeight: displayWeight ?? this.displayWeight,
        displayTracking: displayTracking ?? this.displayTracking,
        bundled: bundled ?? this.bundled,
        fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      );

  @override
  NptType lerp(ThemeExtension<NptType>? other, double t) {
    if (other is! NptType) return this;
    // Fonts/weights are discrete: snap to the target past the midpoint.
    final pick = t < 0.5 ? this : other;
    return NptType(
      display: pick.display,
      text: pick.text,
      num: pick.num,
      displayAr: pick.displayAr,
      textAr: pick.textAr,
      numAr: pick.numAr,
      displayWeight: pick.displayWeight,
      displayTracking: displayTracking + (other.displayTracking - displayTracking) * t,
      bundled: pick.bundled,
      fontFamilyFallback: pick.fontFamilyFallback,
    );
  }
}

/// Brand motion: easing curves, durations and glass blur radius.
@immutable
class NptMotion extends ThemeExtension<NptMotion> {
  final Curve standard;
  final Curve emphasized;
  final Curve spring;
  final Duration fast;
  final Duration durationStandard;
  final Duration slow;
  final double glassBlur;

  const NptMotion({
    required this.standard,
    required this.emphasized,
    required this.spring,
    required this.fast,
    required this.durationStandard,
    required this.slow,
    required this.glassBlur,
  });

  @override
  NptMotion copyWith({
    Curve? standard,
    Curve? emphasized,
    Curve? spring,
    Duration? fast,
    Duration? durationStandard,
    Duration? slow,
    double? glassBlur,
  }) =>
      NptMotion(
        standard: standard ?? this.standard,
        emphasized: emphasized ?? this.emphasized,
        spring: spring ?? this.spring,
        fast: fast ?? this.fast,
        durationStandard: durationStandard ?? this.durationStandard,
        slow: slow ?? this.slow,
        glassBlur: glassBlur ?? this.glassBlur,
      );

  @override
  NptMotion lerp(ThemeExtension<NptMotion>? other, double t) {
    if (other is! NptMotion) return this;
    final pick = t < 0.5 ? this : other;
    Duration ld(Duration a, Duration b) => Duration(
        microseconds:
            (a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t).round());
    return NptMotion(
      standard: pick.standard,
      emphasized: pick.emphasized,
      spring: pick.spring,
      fast: ld(fast, other.fast),
      durationStandard: ld(durationStandard, other.durationStandard),
      slow: ld(slow, other.slow),
      glassBlur: glassBlur + (other.glassBlur - glassBlur) * t,
    );
  }
}
