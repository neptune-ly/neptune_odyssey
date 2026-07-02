// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The unified theming surface. Three ways to theme (docs/04, docs/11):
//   1. brand id     — NeptuneTheme.light('triton') / .dark('triton')
//   2. brandprint   — NeptuneTheme.fromBrandprint('NO1-…')
//   3. config       — NeptuneTheme.fromConfig(BrandprintConfig)
// Reference brands resolve via the pinned const schemes; custom seeds generate
// deterministically through the shared OKLCH ramp. Same brandprint ⇒ identical
// theme on every platform.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../brandprint/codec.dart';
import '../color/oklch.dart';
import '../color/palette.dart';
import 'brand_tables.dart';
import 'color_schemes.dart';
import 'extensions.dart';
import 'identity.dart';

/// Entry points for building Neptune Odyssey [ThemeData].
class NeptuneTheme {
  NeptuneTheme._();

  /// Debug/test escape hatch. When true, the theme references brand font
  /// families by name only and skips the `google_fonts` runtime loader (which
  /// would otherwise fetch from the network). Production leaves this false so
  /// the real brand faces load and render. Tests flip it true to stay offline.
  static bool debugSkipFontLoading = false;

  /// Light theme for a reference brand id ('neptune'|'triton'|'nereid'|'proteus').
  ///
  /// Pass `arabic: true` for an RTL/Arabic build: the brand's Arabic faces
  /// (`displayAr`/`textAr`) drive the text theme, matching the web's
  /// `[dir="rtl"]` font swap. Colours/shape/motion are unaffected.
  static ThemeData light(String brand, {bool arabic = false}) =>
      _forBrand(brand, Brightness.light, arabic);

  /// Dark theme for a reference brand id. See [light] for `arabic`.
  static ThemeData dark(String brand, {bool arabic = false}) =>
      _forBrand(brand, Brightness.dark, arabic);

  /// Build a theme from a `NO1-…` brandprint. Defaults brightness to the
  /// brandprint's `defaultDark` flag unless [brightness] is given.
  static ThemeData fromBrandprint(String brandprint,
          {Brightness? brightness, bool arabic = false}) =>
      fromConfig(Brandprint.decode(brandprint),
          brightness: brightness, arabic: arabic);

  /// Build a theme from a [BrandprintConfig]. If the seeds match a reference
  /// brand, the pinned canonical scheme is used (byte-identical); otherwise the
  /// palette is generated deterministically from the seeds.
  static ThemeData fromConfig(BrandprintConfig cfg,
      {Brightness? brightness, bool arabic = false}) {
    final mode = brightness ?? (cfg.defaultDark ? Brightness.dark : Brightness.light);
    final ref = _matchReferenceBrand(cfg.primary, cfg.tertiary);
    if (ref != null) {
      return _forBrandWithConfig(ref, mode, cfg, arabic);
    }
    return _custom(cfg, mode, arabic);
  }

  // --- reference brands -----------------------------------------------------

  static ThemeData _forBrand(String brand, Brightness mode, bool arabic) {
    final cfg = brandConfig[brand];
    if (cfg == null) {
      throw ArgumentError.value(brand, 'brand', 'unknown reference brand');
    }
    return _forBrandWithConfig(brand, mode, cfg, arabic);
  }

  static ThemeData _forBrandWithConfig(
      String brand, Brightness mode, BrandprintConfig cfg, bool arabic) {
    final isLight = mode == Brightness.light;
    final schemes = neptuneSchemes[brand]!;
    final scheme = isLight ? schemes.$1 : schemes.$2;
    final success = brandSuccess[brand]!;
    final colors = isLight ? success.$1 : success.$2;
    final shape = brandShape[brand]!;
    final type = brandType[brand]!;
    final motion = motionFor(cfg.motion);
    return _assemble(scheme, colors, shape, type, motion, identityFor(cfg), arabic);
  }

  // --- custom seeds ---------------------------------------------------------

  static ThemeData _custom(BrandprintConfig cfg, Brightness mode, bool arabic) {
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
    return _assemble(
        scheme, colors, shape, type, motionFor(cfg.motion), identityFor(cfg), arabic);
  }

  // --- assembly -------------------------------------------------------------

  static ThemeData _assemble(
    ColorScheme scheme,
    NptColors colors,
    NptShape shape,
    NptType type,
    NptMotion motion,
    NptIdentity identity,
    bool arabic,
  ) {
    final textTheme = _buildTextTheme(scheme, type, arabic);
    // The default body family for any text the textTheme doesn't name. Resolve
    // through google_fonts so it is an actually-loaded family, not just a name.
    final resolvedTextFamily = _gf(arabic ? type.textAr : type.text).fontFamily;
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      fontFamily: resolvedTextFamily,
      extensions: [colors, shape, type, motion, identity],
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

  static TextTheme _buildTextTheme(ColorScheme scheme, NptType type, bool arabic) {
    final display = arabic ? type.displayAr : type.display;
    final text = arabic ? type.textAr : type.text;
    final w = type.displayFontWeight;
    TextStyle disp(double size, {double? height, double? letterSpacing}) => _gf(
          display,
          TextStyle(
            fontSize: size,
            height: height,
            fontWeight: w,
            letterSpacing: letterSpacing,
          ),
        );
    TextStyle body(double size, {FontWeight? weight}) =>
        _gf(text, TextStyle(fontSize: size, fontWeight: weight));
    return TextTheme(
      displayLarge: disp(57, height: 64 / 57, letterSpacing: type.displayTracking * 57),
      displayMedium: disp(45, height: 52 / 45, letterSpacing: type.displayTracking * 45),
      displaySmall: disp(36, height: 44 / 36),
      headlineLarge: disp(32),
      headlineMedium: disp(28),
      headlineSmall: disp(24),
      titleLarge: body(22, weight: FontWeight.w600),
      titleMedium: body(18, weight: FontWeight.w600),
      titleSmall: body(14, weight: FontWeight.w600),
      bodyLarge: body(16),
      bodyMedium: body(14),
      bodySmall: body(12),
      labelLarge: body(14, weight: FontWeight.w600),
      labelMedium: body(12, weight: FontWeight.w600),
      labelSmall: body(11, weight: FontWeight.w600),
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
  }

  /// Resolve a family name to an actually-loaded [TextStyle] via `google_fonts`.
  /// All Neptune brand faces (Latin + Arabic) are Google Fonts; an unknown
  /// custom name falls back to a plain `fontFamily` reference.
  static TextStyle _gf(String family, [TextStyle base = const TextStyle()]) {
    if (debugSkipFontLoading) return base.copyWith(fontFamily: family);
    try {
      return GoogleFonts.getFont(family, textStyle: base);
    } catch (_) {
      return base.copyWith(fontFamily: family);
    }
  }

  /// A money/number text style for the active theme: the brand `num` family with
  /// tabular figures so digits stay column-aligned. Direction-aware — under RTL
  /// it uses the Arabic numeral face, mirroring the web's `dir="rtl"` swap.
  static TextStyle moneyStyle(BuildContext context, {TextStyle? base}) {
    final type = Theme.of(context).extension<NptType>()!;
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final family = rtl ? type.numAr : type.num;
    final b = base ?? Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    return _gf(family, b)
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
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
