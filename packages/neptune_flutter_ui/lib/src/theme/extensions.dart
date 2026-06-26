// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Neptune Odyssey ThemeExtensions: success colour role (an M3 addition not in
// ColorScheme), the per-brand corner family, the brand type set, and brand
// motion. Read these from Theme.of(context) — never hard-code a value.

import 'package:flutter/material.dart';

/// The `success` colour role + its on/container variants. Not part of M3's
/// [ColorScheme], so carried here. Values come from tokens.resolved.json.
@immutable
class NptColors extends ThemeExtension<NptColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  const NptColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
  });

  @override
  NptColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
  }) =>
      NptColors(
        success: success ?? this.success,
        onSuccess: onSuccess ?? this.onSuccess,
        successContainer: successContainer ?? this.successContainer,
        onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
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
    );
  }
}

/// The six brand corner radii (px) plus `full` (9999 → stadium/pill).
@immutable
class NptShape extends ThemeExtension<NptShape> {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double full;

  const NptShape({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    this.full = 9999,
  });

  BorderRadius get rXs => BorderRadius.circular(xs);
  BorderRadius get rSm => BorderRadius.circular(sm);
  BorderRadius get rMd => BorderRadius.circular(md);
  BorderRadius get rLg => BorderRadius.circular(lg);
  BorderRadius get rXl => BorderRadius.circular(xl);
  BorderRadius get rXxl => BorderRadius.circular(xxl);

  @override
  NptShape copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? full,
  }) =>
      NptShape(
        xs: xs ?? this.xs,
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        xl: xl ?? this.xl,
        xxl: xxl ?? this.xxl,
        full: full ?? this.full,
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
    );
  }
}

/// Brand font families + display weight/tracking. Money/number UI should use
/// the [num] family with [FontFeature.tabularFigures].
@immutable
class NptType extends ThemeExtension<NptType> {
  final String display;
  final String text;
  final String num;
  final int displayWeight;

  /// Tracking in em (e.g. -0.02).
  final double displayTracking;

  const NptType({
    required this.display,
    required this.text,
    required this.num,
    required this.displayWeight,
    required this.displayTracking,
  });

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
    int? displayWeight,
    double? displayTracking,
  }) =>
      NptType(
        display: display ?? this.display,
        text: text ?? this.text,
        num: num ?? this.num,
        displayWeight: displayWeight ?? this.displayWeight,
        displayTracking: displayTracking ?? this.displayTracking,
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
      displayWeight: pick.displayWeight,
      displayTracking: displayTracking + (other.displayTracking - displayTracking) * t,
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
