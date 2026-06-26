// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The unified theming surface. Three ways to theme (docs/04, docs/11):
//   1. brand id     — NeptuneTheme.light('andalus') / .dark('andalus')
//   2. brandprint   — NeptuneTheme.fromBrandprint('NO1-…')
//   3. config       — NeptuneTheme.fromConfig(BrandprintConfig)
// Reference brands resolve via the pinned const schemes; custom seeds generate
// deterministically through the shared OKLCH ramp. Same brandprint ⇒ identical
// theme on every platform.

import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

import '../brandprint/codec.dart';
import '../color/oklch.dart';
import '../color/palette.dart';
import 'brand_tables.dart';
import 'color_schemes.dart';
import 'extensions.dart';

/// Entry points for building Neptune Odyssey [ThemeData].
class NeptuneTheme {
  NeptuneTheme._();

  /// Light theme for a reference brand id ('neptune'|'andalus'|'nuran'|'fglb').
  static ThemeData light(String brand) => _forBrand(brand, Brightness.light);

  /// Dark theme for a reference brand id.
  static ThemeData dark(String brand) => _forBrand(brand, Brightness.dark);

  /// Build a theme from a `NO1-…` brandprint. Defaults brightness to the
  /// brandprint's `defaultDark` flag unless [brightness] is given.
  static ThemeData fromBrandprint(String brandprint, {Brightness? brightness}) =>
      fromConfig(Brandprint.decode(brandprint), brightness: brightness);

  /// Build a theme from a [BrandprintConfig]. If the seeds match a reference
  /// brand, the pinned canonical scheme is used (byte-identical); otherwise the
  /// palette is generated deterministically from the seeds.
  static ThemeData fromConfig(BrandprintConfig cfg, {Brightness? brightness}) {
    final mode = brightness ?? (cfg.defaultDark ? Brightness.dark : Brightness.light);
    final ref = _matchReferenceBrand(cfg.primary, cfg.tertiary);
    if (ref != null) {
      return _forBrandWithConfig(ref, mode, cfg);
    }
    return _custom(cfg, mode);
  }

  // --- reference brands -----------------------------------------------------

  static ThemeData _forBrand(String brand, Brightness mode) {
    final cfg = brandConfig[brand];
    if (cfg == null) {
      throw ArgumentError.value(brand, 'brand', 'unknown reference brand');
    }
    return _forBrandWithConfig(brand, mode, cfg);
  }

  static ThemeData _forBrandWithConfig(
      String brand, Brightness mode, BrandprintConfig cfg) {
    final isLight = mode == Brightness.light;
    final schemes = neptuneSchemes[brand]!;
    final scheme = isLight ? schemes.$1 : schemes.$2;
    final success = brandSuccess[brand]!;
    final colors = isLight ? success.$1 : success.$2;
    final shape = brandShape[brand]!;
    final type = brandType[brand]!;
    final motion = motionFor(cfg.motion);
    return _assemble(scheme, colors, shape, type, motion);
  }

  // --- custom seeds ---------------------------------------------------------

  static ThemeData _custom(BrandprintConfig cfg, Brightness mode) {
    final isLight = mode == Brightness.light;
    final modeStr = isLight ? 'light' : 'dark';
    final primary = Oklch(cfg.primary.l, cfg.primary.c, cfg.primary.h.toDouble());
    final tertiary = Oklch(cfg.tertiary.l, cfg.tertiary.c, cfg.tertiary.h.toDouble());
    final p = generatePaletteArgb(primary, tertiary, modeStr);
    Color c(String role) => Color(p[role]!);

    final scheme = ColorScheme(
      brightness: mode,
      primary: c('primary'),
      onPrimary: c('on-primary'),
      primaryContainer: c('primary-container'),
      onPrimaryContainer: c('on-primary-container'),
      secondary: c('secondary'),
      onSecondary: c('on-secondary'),
      secondaryContainer: c('secondary-container'),
      onSecondaryContainer: c('on-secondary-container'),
      tertiary: c('tertiary'),
      onTertiary: c('on-tertiary'),
      tertiaryContainer: c('tertiary-container'),
      onTertiaryContainer: c('on-tertiary-container'),
      error: c('error'),
      onError: c('on-error'),
      errorContainer: c('error-container'),
      onErrorContainer: c('on-error-container'),
      surface: c('surface'),
      onSurface: c('on-surface'),
      surfaceContainerLowest: c('surface-container-lowest'),
      surfaceContainerLow: c('surface-container-low'),
      surfaceContainer: c('surface-container'),
      surfaceContainerHigh: c('surface-container-high'),
      surfaceContainerHighest: c('surface-container-highest'),
      onSurfaceVariant: c('on-surface-variant'),
      outline: c('outline'),
      outlineVariant: c('outline-variant'),
      inverseSurface: c('inverse-surface'),
      onInverseSurface: c('inverse-on-surface'),
      inversePrimary: c('inverse-primary'),
      scrim: c('scrim'),
      surfaceTint: c('primary'),
      shadow: const Color(0xFF000000),
    );

    final colors = NptColors(
      success: c('success'),
      onSuccess: c('on-success'),
      successContainer: c('success-container'),
      onSuccessContainer: c('on-success-container'),
    );

    final cc = cfg.corners;
    final shape = NptShape(
      xs: cc.xs.toDouble(),
      sm: cc.sm.toDouble(),
      md: cc.md.toDouble(),
      lg: cc.lg.toDouble(),
      xl: cc.xl.toDouble(),
      xxl: cc.xxl.toDouble(),
    );
    final type = NptType(
      display: cfg.fontDisplay,
      text: cfg.fontText,
      num: cfg.fontNum,
      displayWeight: cfg.displayWeight,
      displayTracking: cfg.displayTracking,
    );
    return _assemble(scheme, colors, shape, type, motionFor(cfg.motion));
  }

  // --- assembly -------------------------------------------------------------

  static ThemeData _assemble(
    ColorScheme scheme,
    NptColors colors,
    NptShape shape,
    NptType type,
    NptMotion motion,
  ) {
    final textTheme = _buildTextTheme(scheme, type);
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      fontFamily: type.text,
      extensions: [colors, shape, type, motion],
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: shape.rLg),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(borderRadius: shape.rSm),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: shape.rSm,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: shape.rSm,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: shape.rSm,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: shape.rSm),
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme scheme, NptType type) {
    final display = type.display;
    final text = type.text;
    final w = type.displayFontWeight;
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: display,
        fontSize: 57,
        height: 64 / 57,
        fontWeight: w,
        letterSpacing: type.displayTracking * 57,
      ),
      displayMedium: TextStyle(
        fontFamily: display,
        fontSize: 45,
        height: 52 / 45,
        fontWeight: w,
        letterSpacing: type.displayTracking * 45,
      ),
      displaySmall: TextStyle(
        fontFamily: display,
        fontSize: 36,
        height: 44 / 36,
        fontWeight: w,
      ),
      headlineLarge: TextStyle(fontFamily: display, fontSize: 32, fontWeight: w),
      headlineMedium: TextStyle(fontFamily: display, fontSize: 28, fontWeight: w),
      headlineSmall: TextStyle(fontFamily: display, fontSize: 24, fontWeight: w),
      titleLarge: TextStyle(
          fontFamily: text, fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
          fontFamily: text, fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(
          fontFamily: text, fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: text, fontSize: 16),
      bodyMedium: TextStyle(fontFamily: text, fontSize: 14),
      bodySmall: TextStyle(fontFamily: text, fontSize: 12),
      labelLarge: TextStyle(
          fontFamily: text, fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(
          fontFamily: text, fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(
          fontFamily: text, fontSize: 11, fontWeight: FontWeight.w600),
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
  }

  /// A money/number text style for the active theme: the brand `num` family with
  /// tabular figures so digits stay column-aligned.
  static TextStyle moneyStyle(BuildContext context, {TextStyle? base}) {
    final type = Theme.of(context).extension<NptType>()!;
    final b = base ?? Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    return b.copyWith(
      fontFamily: type.num,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // --- reference matching ---------------------------------------------------

  /// Return the reference brand id whose seeds match [primary]/[tertiary] within
  /// the brandprint quantisation tolerance, or null for a custom seed set.
  static String? _matchReferenceBrand(Seed primary, Seed tertiary) {
    for (final brand in kBrands) {
      final cfg = brandConfig[brand]!;
      if (_seedClose(cfg.primary, primary) && _seedClose(cfg.tertiary, tertiary)) {
        return brand;
      }
    }
    return null;
  }

  static bool _seedClose(Seed a, Seed b) {
    // L quantised to 1/255, C to 0.001, H integer degrees.
    return (a.l - b.l).abs() <= 1 / 255 + 1e-9 &&
        (a.c - b.c).abs() <= 0.001 + 1e-9 &&
        a.h == b.h;
  }
}
