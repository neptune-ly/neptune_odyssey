// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The unified theming surface. Three ways to theme (docs/04, docs/11):
//   1. brand id     — NeptuneTheme.light('triton') / .dark('triton')
//   2. brandprint   — NeptuneTheme.fromBrandprint('NO1-…')
//   3. config       — NeptuneTheme.fromConfig(BrandprintConfig)
// Reference brands resolve via the pinned const schemes; custom seeds generate
// deterministically through the shared OKLCH ramp. Same brandprint ⇒ identical
// theme on every platform.
//
// Since 2.24.0 the ThemeData that comes back is FINISHED: app bar, floating
// action button, every input-decoration state and the pre-login brand canvas
// are set from tokens here, so a host has nothing left to patch after
// assembly. A host that bundles its own faces passes `hostFont:` and the
// google_fonts loader is never consulted.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../brandprint/codec.dart';
import '../color/oklch.dart';
import '../color/palette.dart';
import 'brand_canvas.dart';
import 'brand_scheme.dart';
import 'brand_tables.dart';
import 'color_schemes.dart';
import 'density.dart';
import 'extensions.dart';
import 'feedback.dart';
import 'field_border.dart';
import 'glance.dart';
import 'identity.dart';
import 'page_transitions.dart';
import 'numerals.dart';
import 'generated/brand_data.g.dart';

/// Public Odyssey 3 expression choices. Banking preserves the active tenant
/// scheme; wallet uses core navy, while Drive and Orbit use public profiles.
enum NeptuneOdyssey3Product { banking, wallet, drive, orbit }

/// A face the HOST bundles as a Flutter asset, applied at assembly.
///
/// A bundled face is a property of the host, not of the brandprint: the web
/// and Studio ports cannot load a Flutter asset, so it never goes on the wire
/// and the brandprint keeps naming its portable registry family. Passing the
/// host face HERE, rather than patching the theme afterwards, is what makes
/// every component theme that captures a text style at assembly (the button
/// families) capture the right one, makes `NptType` report the host family
/// for every face including the Arabic ones (so `moneyStyle` under RTL no
/// longer falls back to a Google family), and keeps every code path away from
/// the google_fonts runtime loader.
@immutable
class NptHostFont {
  /// The bundled family, as declared under `fonts:` in the host's pubspec.
  final String family;

  /// An optional second bundled family for the DISPLAY face — headlines, the
  /// eyebrow, the hero figure. Null keeps [family] everywhere, which is what
  /// every host did before 2.30.0.
  ///
  /// It exists because a host could bundle its brand's faces and still only
  /// declare one of them. A brandprint names `fontDisplay`, `fontText` and
  /// `fontNum` separately for exactly the reason every type system does — the
  /// face that sets a 64dp balance is not the face that sets a 14dp
  /// transaction row — and then the host override collapsed all three back
  /// into one family, so a bank that bundled a display face had no way to
  /// reach it without the `google_fonts` loader it bundled the face to avoid.
  final String? display;

  /// An optional third bundled family for FIGURES (`NeptuneTheme.moneyStyle`
  /// and the numeral styles). Null falls back to [family].
  final String? num;

  /// Fallback chain behind [family] — a host's Latin safety net behind an
  /// Arabic-first face, for example. Rides on every text style the theme
  /// builds.
  final List<String> fallback;

  const NptHostFont({
    required this.family,
    this.display,
    this.num,
    this.fallback = const [],
  });

  /// The display family, or [family] when the host declared only one.
  String get displayFamily => display ?? family;

  /// The figure family, or [family] when the host declared only one.
  String get numFamily => num ?? family;
}

/// Entry points for building Neptune Odyssey [ThemeData].
class NeptuneTheme {
  NeptuneTheme._();

  /// Opt in to Odyssey 3 after assembling a normal tenant theme.
  /// Existing widgets consume the revised [ColorScheme]; v1 and NO1 callers
  /// never reach this method and therefore remain byte-for-byte unchanged.
  static ThemeData odyssey3(ThemeData base,
      {NeptuneOdyssey3Product product = NeptuneOdyssey3Product.banking,
      bool arabic = false,
      bool reducedMotion = false}) {
    if (product == NeptuneOdyssey3Product.banking) {
      return _odyssey3Foundations(base, base.colorScheme,
          arabic: arabic, reducedMotion: reducedMotion);
    }
    final productKey =
        product == NeptuneOdyssey3Product.wallet ? 'core' : product.name;
    final roles = genOdyssey3Schemes[productKey]![
        base.brightness == Brightness.dark ? 'dark' : 'light']!;
    Color c(String name) => roles[name]!;
    final scheme = base.colorScheme.copyWith(
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
      // Keep the complete legacy role contract alongside modern surface roles.
      // ignore: deprecated_member_use
      surfaceVariant: c('surface-variant'),
      onSurfaceVariant: c('on-surface-variant'),
      surfaceContainerLowest: c('surface-container-lowest'),
      surfaceContainerLow: c('surface-container-low'),
      surfaceContainer: c('surface-container'),
      surfaceContainerHigh: c('surface-container-high'),
      surfaceContainerHighest: c('surface-container-highest'),
      outline: c('outline'),
      outlineVariant: c('outline-variant'),
      inverseSurface: c('inverse-surface'),
      onInverseSurface: c('inverse-on-surface'),
      inversePrimary: c('inverse-primary'),
      scrim: c('scrim'),
      // Keep the complete legacy role contract alongside modern surface roles.
      // ignore: deprecated_member_use
      background: c('background'),
      // Keep the complete legacy role contract alongside modern surface roles.
      // ignore: deprecated_member_use
      onBackground: c('on-background'),
    );
    final colors = base.extension<NptColors>();
    final fieldFill = scheme.brightness == Brightness.light
        ? scheme.surfaceContainerLowest
        : scheme.surfaceContainerHighest;
    InputBorder? fieldBorder(InputBorder? border, Color color,
        {double? width}) {
      if (border == null) return null;
      return border.copyWith(
          borderSide: border.borderSide.copyWith(color: color, width: width));
    }

    final outlinedStyle = base.outlinedButtonTheme.style ?? const ButtonStyle();
    final outlinedSide =
        outlinedStyle.side?.resolve(<WidgetState>{}) ?? BorderSide.none;
    return _odyssey3Foundations(
        base.copyWith(
          colorScheme: scheme,
          scaffoldBackgroundColor: c('background'),
          canvasColor: c('background'),
          textTheme: base.textTheme.apply(
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
          ),
          primaryTextTheme: base.primaryTextTheme.apply(
            bodyColor: scheme.onPrimary,
            displayColor: scheme.onPrimary,
          ),
          appBarTheme:
              base.appBarTheme.copyWith(backgroundColor: c('background')),
          cardTheme: base.cardTheme.copyWith(color: scheme.surfaceContainerLow),
          floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: outlinedStyle.copyWith(
              side: WidgetStatePropertyAll(
                outlinedSide.copyWith(color: scheme.outline),
              ),
            ),
          ),
          navigationBarTheme: base.navigationBarTheme.copyWith(
            backgroundColor: scheme.surfaceContainer,
            indicatorColor: scheme.secondaryContainer,
          ),
          inputDecorationTheme: base.inputDecorationTheme.copyWith(
            fillColor: fieldFill,
            border:
                fieldBorder(base.inputDecorationTheme.border, scheme.outline),
            enabledBorder: fieldBorder(
                base.inputDecorationTheme.enabledBorder, scheme.outline),
            focusedBorder: fieldBorder(
                base.inputDecorationTheme.focusedBorder, scheme.primary,
                width: 2),
            errorBorder: fieldBorder(
                base.inputDecorationTheme.errorBorder, scheme.error),
            focusedErrorBorder: fieldBorder(
                base.inputDecorationTheme.focusedErrorBorder, scheme.error,
                width: 2),
            disabledBorder: fieldBorder(
              base.inputDecorationTheme.disabledBorder,
              scheme.onSurface.withValues(alpha: 0.12),
            ),
          ),
          extensions: colors == null
              ? base.extensions.values
              : [
                  ...base.extensions.values
                      .where((extension) => extension is! NptColors),
                  colors.copyWith(
                    success: c('success'),
                    onSuccess: c('on-success'),
                    successContainer: c('success-container'),
                    onSuccessContainer: c('on-success-container'),
                  ),
                ],
        ),
        scheme,
        arabic: arabic,
        reducedMotion: reducedMotion);
  }

  static ThemeData _odyssey3Foundations(ThemeData base, ColorScheme scheme,
      {required bool arabic, required bool reducedMotion}) {
    final oldMotion = base.extension<NptMotion>() ??
        const NptMotion(
          standard: Curves.easeOut,
          emphasized: Curves.easeOut,
          spring: Curves.easeOut,
          fast: Duration(milliseconds: 120),
          durationStandard: Duration(milliseconds: 200),
          slow: Duration(milliseconds: 320),
          celebrate: Duration(milliseconds: 600),
          glassBlur: 0,
        );
    final modes = genOdyssey3Foundation['motionMs'] as Map;
    final durations = modes[reducedMotion ? 'reduced' : 'full'] as Map;
    Duration duration(String role) =>
        Duration(milliseconds: durations[role] as int);
    final motion = oldMotion.copyWith(
      fast: duration('feedback'),
      durationStandard: duration('navigate'),
      slow: duration('reveal'),
      celebrate: duration('celebrate'),
    );
    const shape =
        NptShape(xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 32, full: 999);
    const type = NptType(
      display: 'Hanken Grotesk',
      text: 'Hanken Grotesk',
      num: 'Hanken Grotesk',
      displayAr: 'Beiruti',
      textAr: 'Beiruti',
      numAr: 'Hanken Grotesk',
      displayWeight: 700,
      displayTracking: 0,
    );
    final extensions = [
      ...base.extensions.values.where((value) =>
          value is! NptShape && value is! NptType && value is! NptMotion),
      shape,
      type,
      motion,
    ];
    InputBorder? fieldShape(InputBorder? border) => border is OutlineInputBorder
        ? border.copyWith(borderRadius: shape.rSm)
        : border;
    final text = _odyssey3TextTheme(scheme, type, arabic);
    final label = WidgetStatePropertyAll<TextStyle?>(text.labelLarge);
    final buttonShape = WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(shape.md)));
    ButtonStyle buttonStyle(ButtonStyle? style) =>
        (style ?? const ButtonStyle()).copyWith(
          shape: buttonShape,
          textStyle: label,
          minimumSize: const WidgetStatePropertyAll(Size(64, 56)),
        );
    return base.copyWith(
      textTheme: text,
      primaryTextTheme: text.apply(
          bodyColor: scheme.onPrimary, displayColor: scheme.onPrimary),
      cardTheme: base.cardTheme
          .copyWith(shape: RoundedRectangleBorder(borderRadius: shape.rLg)),
      floatingActionButtonTheme: base.floatingActionButtonTheme
          .copyWith(shape: RoundedRectangleBorder(borderRadius: shape.rXs)),
      filledButtonTheme: FilledButtonThemeData(
          style: buttonStyle(base.filledButtonTheme.style)),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: buttonStyle(base.outlinedButtonTheme.style)),
      textButtonTheme:
          TextButtonThemeData(style: buttonStyle(base.textButtonTheme.style)),
      navigationBarTheme: base.navigationBarTheme.copyWith(
          indicatorShape: RoundedRectangleBorder(borderRadius: shape.rSm)),
      chipTheme: base.chipTheme
          .copyWith(shape: RoundedRectangleBorder(borderRadius: shape.rSm)),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: fieldShape(base.inputDecorationTheme.border),
        enabledBorder: fieldShape(base.inputDecorationTheme.enabledBorder),
        focusedBorder: fieldShape(base.inputDecorationTheme.focusedBorder),
        errorBorder: fieldShape(base.inputDecorationTheme.errorBorder),
        focusedErrorBorder:
            fieldShape(base.inputDecorationTheme.focusedErrorBorder),
        disabledBorder: fieldShape(base.inputDecorationTheme.disabledBorder),
      ),
      extensions: extensions,
    );
  }

  static TextTheme _odyssey3TextTheme(
      ColorScheme scheme, NptType type, bool arabic) {
    final family = arabic ? type.textAr : type.text;
    TextStyle style(double size, double line, FontWeight weight) => _face(
        type,
        family,
        TextStyle(fontSize: size, height: line / size, fontWeight: weight));
    final body = arabic ? 20.0 : 16.0;
    final small = arabic ? 18.0 : 14.0;
    final label = arabic ? 18.0 : 14.0;
    return TextTheme(
      displayLarge: style(40, 48, FontWeight.w700),
      displayMedium: style(40, 48, FontWeight.w700),
      displaySmall: _face(
          type,
          type.num,
          const TextStyle(
              fontSize: 36, height: 44 / 36, fontWeight: FontWeight.w600)),
      headlineLarge: style(32, 40, FontWeight.w700),
      headlineMedium: style(32, 40, FontWeight.w700),
      headlineSmall: style(24, 32, FontWeight.w700),
      titleLarge: style(24, 32, FontWeight.w700),
      titleMedium: style(20, 28, FontWeight.w600),
      titleSmall: style(20, 28, FontWeight.w600),
      bodyLarge: style(body, arabic ? 28 : 24, FontWeight.w400),
      bodyMedium: style(small, arabic ? 24 : 20, FontWeight.w400),
      labelLarge: style(label, arabic ? 24 : 20, FontWeight.w600),
      labelMedium: style(label, arabic ? 24 : 20, FontWeight.w600),
      labelSmall: style(arabic ? 16 : 12, arabic ? 22 : 16, FontWeight.w600),
      bodySmall: style(arabic ? 16 : 12, arabic ? 22 : 16, FontWeight.w400),
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  }

  /// Debug/test escape hatch. When true, the theme references registry font
  /// families by name only and skips the `google_fonts` runtime loader (which
  /// would otherwise fetch from the network). Production leaves this false so
  /// the real brand faces load and render. Tests that assemble a theme WITHOUT
  /// `hostFont:` flip it true to stay offline; a theme assembled with a host
  /// font never reaches the loader and does not need it.
  static bool debugSkipFontLoading = false;

  /// Light theme for a reference brand id ('neptune'|'triton'|'nereid'|'proteus').
  ///
  /// Pass `arabic: true` for an RTL/Arabic build: the brand's Arabic faces
  /// (`displayAr`/`textAr`) drive the text theme, matching the web's
  /// `[dir="rtl"]` font swap. Colours/shape/motion are unaffected.
  ///
  /// `density` and `numerals` are independent tenant levers (R6) — neither is
  /// implied by `arabic`. `feedback` overrides the per-brand haptic weight
  /// derived from the brand's `contentTone`; pass one to also wire a sound hook.
  /// `hostFont` replaces every face with a family the host bundles — see
  /// [NptHostFont].
  static ThemeData light(
    String brand, {
    bool arabic = false,
    NeptuneDensityMode density = NeptuneDensityMode.comfortable,
    NeptuneNumeralStyle numerals = NeptuneNumeralStyle.latin,
    NptFeedback? feedback,
    NptHostFont? hostFont,
  }) =>
      _forBrand(brand, Brightness.light, arabic, density, numerals, feedback,
          hostFont);

  /// Dark theme for a reference brand id. See [light] for the other params.
  static ThemeData dark(
    String brand, {
    bool arabic = false,
    NeptuneDensityMode density = NeptuneDensityMode.comfortable,
    NeptuneNumeralStyle numerals = NeptuneNumeralStyle.latin,
    NptFeedback? feedback,
    NptHostFont? hostFont,
  }) =>
      _forBrand(brand, Brightness.dark, arabic, density, numerals, feedback,
          hostFont);

  /// Build a theme from a `NO1-…` brandprint. Defaults brightness to the
  /// brandprint's `defaultDark` flag unless [brightness] is given.
  static ThemeData fromBrandprint(
    String brandprint, {
    Brightness? brightness,
    bool arabic = false,
    NeptuneDensityMode density = NeptuneDensityMode.comfortable,
    NeptuneNumeralStyle numerals = NeptuneNumeralStyle.latin,
    NptFeedback? feedback,
    NptHostFont? hostFont,
    NptBrandScheme? scheme,
  }) =>
      fromConfig(Brandprint.decode(brandprint),
          brightness: brightness,
          arabic: arabic,
          density: density,
          numerals: numerals,
          feedback: feedback,
          hostFont: hostFont,
          scheme: scheme);

  /// Build a theme from a [BrandprintConfig]. If the seeds match a reference
  /// brand, the pinned canonical scheme is used (byte-identical); otherwise the
  /// palette is generated deterministically from the seeds.
  ///
  /// The result is a finished bank theme: `appBarTheme`,
  /// `floatingActionButtonTheme`, a seven-state [NeptuneFieldBorder]
  /// `inputDecorationTheme` and an [NptBrandCanvas] extension are all set from
  /// tokens. A host that bundles its faces passes [hostFont].
  static ThemeData fromConfig(
    BrandprintConfig cfg, {
    Brightness? brightness,
    bool arabic = false,
    NeptuneDensityMode density = NeptuneDensityMode.comfortable,
    NeptuneNumeralStyle numerals = NeptuneNumeralStyle.latin,
    NptFeedback? feedback,
    NptHostFont? hostFont,

    /// The brand's finished schemes, used INSTEAD of the generated ramp — see
    /// [NptBrandScheme]. For a bank whose palette already exists in customers'
    /// hands and therefore is not ours to re-derive.
    NptBrandScheme? scheme,
  }) {
    final mode =
        brightness ?? (cfg.defaultDark ? Brightness.dark : Brightness.light);
    // AN EXPLICIT SCHEME SHORT-CIRCUITS THE REFERENCE MATCH TOO. A brand that
    // handed over its own palette must get its own palette, and a seed pair
    // that happened to land near a reference brand's would otherwise have
    // silently swapped a shipped bank's colours for a demo brand's.
    if (scheme != null) {
      return _explicit(
          cfg, scheme, mode, arabic, density, numerals, feedback, hostFont);
    }
    final ref = _matchReferenceBrand(cfg.primary, cfg.tertiary);
    if (ref != null) {
      return _forBrandWithConfig(
          ref, mode, cfg, arabic, density, numerals, feedback, hostFont);
    }
    return _custom(cfg, mode, arabic, density, numerals, feedback, hostFont);
  }

  // --- reference brands -----------------------------------------------------

  static ThemeData _forBrand(
      String brand,
      Brightness mode,
      bool arabic,
      NeptuneDensityMode density,
      NeptuneNumeralStyle numerals,
      NptFeedback? feedback,
      NptHostFont? hostFont) {
    final cfg = brandConfig[brand];
    if (cfg == null) {
      throw ArgumentError.value(brand, 'brand', 'unknown reference brand');
    }
    return _forBrandWithConfig(
        brand, mode, cfg, arabic, density, numerals, feedback, hostFont);
  }

  static ThemeData _forBrandWithConfig(
      String brand,
      Brightness mode,
      BrandprintConfig cfg,
      bool arabic,
      NeptuneDensityMode density,
      NeptuneNumeralStyle numerals,
      NptFeedback? feedback,
      NptHostFont? hostFont) {
    final isLight = mode == Brightness.light;
    final schemes = neptuneSchemes[brand]!;
    final scheme = isLight ? schemes.$1 : schemes.$2;
    final success = brandSuccess[brand]!;
    final base = isLight ? success.$1 : success.$2;
    // A reference scheme is pinned, so the accent flag can only re-point the
    // accent at the scheme's tertiary; the custom path below also keeps the
    // seed out of the Material roles.
    final colors = cfg.accentOnTertiary
        ? base.copyWith(accent: scheme.tertiary, onAccent: scheme.onTertiary)
        : base;
    final shape = brandShape[brand]!;
    final type = brandType[brand]!;
    final motion = motionFor(cfg.motion);
    return _assemble(
      scheme,
      schemes.$1,
      colors,
      shape,
      type,
      motion,
      identityFor(cfg),
      arabic,
      NptDensity.of(density),
      NptNumerals(numerals),
      feedback ?? NptFeedback(hapticWeight: hapticWeightFor(cfg.contentTone)),
      hostFont,
      cfg.whiteGround,
      cfg.ruledRegister,
    );
  }

  // --- explicit brand scheme ------------------------------------------------

  /// The brand's own schemes, verbatim. Everything that is NOT a Material role
  /// — corners, faces, motion, the identity levers — still comes from the
  /// brandprint, because those are levers rather than colours and the ramp was
  /// never involved in them.
  static ThemeData _explicit(
      BrandprintConfig cfg,
      NptBrandScheme brand,
      Brightness mode,
      bool arabic,
      NeptuneDensityMode density,
      NeptuneNumeralStyle numerals,
      NptFeedback? feedback,
      NptHostFont? hostFont) {
    final scheme = brand.of(mode);
    final success = brand.successOf(mode);

    // THE CARD TRAVELS PRIMARY -> SECONDARY, NOT PRIMARY -> TERTIARY.
    //
    // The generated path rides the tertiary SEED, which on this path does not
    // exist as a card colour: a shipped Material scheme's `tertiary` is an
    // accent role and a tenant may put anything in it, including a translucent
    // system fill, so a card gradient
    // ending there would be a translucent smudge over whatever sat behind it.
    // `secondary` is the role a hand-written scheme reliably fills with the
    // brand's second colour, and it is what the bank's own card art uses.
    //
    // AND IT IS THE LIGHT SCHEME'S PAIR IN BOTH BRIGHTNESSES. A payment card
    // depicts a physical instrument, so it does not invert (see
    // [NptColors.cardGradientStart]); riding the dark scheme's `primary` would
    // make the card the brightest object on a dark page. It is used
    // un-deepened because a supplied palette's light pair is a real colour and
    // a darkened version of it is not: any factor we applied here would be a
    // colour the bank never approved.
    final colors = NptColors(
      success: success,
      onSuccess: scheme.onPrimary,
      successContainer: _successContainer(success, scheme),
      onSuccessContainer: _onSuccessContainer(success, scheme),
      cardGradientStart: brand.light.primary,
      cardGradientEnd: brand.light.secondary,
      onCard: brand.light.onPrimary,
      // `accentOnTertiary` still points the accent at the scheme's tertiary,
      // exactly as the pinned reference path does.
      accent: cfg.accentOnTertiary ? scheme.tertiary : scheme.primary,
      onAccent: cfg.accentOnTertiary ? scheme.onTertiary : scheme.onPrimary,
    );

    final cc = cfg.corners;
    return _assemble(
      scheme,
      // The brand canvas is brightness-INVARIANT, so it is built from the
      // brand's LIGHT scheme in both themes — the bank's blue is the same blue
      // at midnight.
      brand.light,
      colors,
      NptShape(
        xs: cc.xs.toDouble(),
        sm: cc.sm.toDouble(),
        md: cc.md.toDouble(),
        lg: cc.lg.toDouble(),
        xl: cc.xl.toDouble(),
        xxl: cc.xxl.toDouble(),
      ),
      NptType(
        display: cfg.fontDisplay,
        text: cfg.fontText,
        num: cfg.fontNum,
        displayWeight: cfg.displayWeight,
        displayTracking: cfg.displayTracking,
      ),
      motionFor(cfg.motion),
      identityFor(cfg),
      arabic,
      NptDensity.of(density),
      NptNumerals(numerals),
      feedback ?? NptFeedback(hapticWeight: hapticWeightFor(cfg.contentTone)),
      hostFont,
      cfg.whiteGround,
      cfg.ruledRegister,
    );
  }

  /// The success container, derived rather than asked for.
  ///
  /// No shipped Material scheme carries one — Material has no success family
  /// at all — so a brand supplying [NptBrandScheme] has nothing to hand over
  /// here. Taking it from the ramp instead would put a generated green at a
  /// fixed hue behind the bank's own green, which is the one pairing certain
  /// to look wrong. This keeps it in the brand's OWN green and only moves it
  /// toward the page, which is the same relationship the ramp expresses.
  static Color _successContainer(Color success, ColorScheme scheme) =>
      Color.lerp(success, scheme.surface, 0.86)!;

  /// Ink on [_successContainer]: the brand's green carried most of the way to
  /// the page's own ink, so it stays legible at body size on that tint.
  static Color _onSuccessContainer(Color success, ColorScheme scheme) =>
      Color.lerp(success, scheme.onSurface, 0.35)!;

  // --- custom seeds ---------------------------------------------------------

  static ThemeData _custom(
      BrandprintConfig cfg,
      Brightness mode,
      bool arabic,
      NeptuneDensityMode density,
      NeptuneNumeralStyle numerals,
      NptFeedback? feedback,
      NptHostFont? hostFont) {
    final isLight = mode == Brightness.light;
    final primary =
        Oklch(cfg.primary.l, cfg.primary.c, cfg.primary.h.toDouble());
    final tertiary =
        Oklch(cfg.tertiary.l, cfg.tertiary.c, cfg.tertiary.h.toDouble());
    // With `accentOnTertiary` the tertiary seed is a direction accent and
    // nothing else: every Material role - `tertiary*` and the card gradient
    // included - is ramped from the primary seed, so the accent has no path
    // into chrome. The seed itself surfaces only as `NptColors.accent`.
    final chromeTertiary = cfg.accentOnTertiary ? primary : tertiary;
    final palette = isLight ? 'light' : 'dark';
    // The warm seed is the brand's real tertiary, NOT `chromeTertiary`: with
    // `accentOnTertiary` the latter is the primary, and keying the ground off
    // it made the lever a no-op for exactly the brands most likely to want it.
    final warmSeed = cfg.warmGround ? tertiary : null;
    final p = generatePaletteArgb(primary, chromeTertiary, palette,
        warmSeed: warmSeed);
    Color c(String role) => Color(p[role]!);

    final scheme = _customScheme(p, mode);
    // The brand canvas is brightness-INVARIANT (see NptBrandCanvas): a dark
    // theme still derives it from the light ramp, generated once here.
    final lightScheme = isLight
        ? scheme
        : _customScheme(
            generatePaletteArgb(primary, chromeTertiary, 'light',
                warmSeed: warmSeed),
            Brightness.light);

    final Color accent;
    final Color onAccent;
    if (cfg.accentOnTertiary) {
      // A DECLARED ACCENT IS BRIGHTNESS-INVARIANT. It is generated from the
      // LIGHT ramp in both modes, exactly like `cardGradientStart/End` and
      // `onCard`, and for the same reason.
      //
      // A brand that sets `accentOnTertiary` has named a second colour and
      // said it means one thing: forward. That is identity, not chrome — and
      // a bank's red is the same red at midnight. Ramped per mode it came out
      // vermilion in light and SALMON in dark, so the mark on the pre-login
      // screen, the primary CTA and the lead verb all changed colour with the
      // customer's phone setting. This is the third instance of one class of
      // bug in this release (the card face inverted, then the mark's arrow
      // took `onAccent`), which is why it is fixed here in the ramp rather
      // than at the third call site.
      //
      // The contrast holds because `on-accent` is pinned with it: a near-white
      // label on a mid-tone vermilion reads in both schemes, which is exactly
      // what makes a physical card face work.
      final a = generatePaletteArgb(primary, tertiary, 'light');
      accent = Color(a['tertiary']!);
      onAccent = Color(a['on-tertiary']!);
    } else {
      // NOT pinned. Without a declared accent, `accent` IS the primary — a
      // genuine Material role that must re-tone, or every brand without a
      // second colour gets an unreadable dark mode.
      accent = c('primary');
      onAccent = c('on-primary');
    }

    final colors = NptColors(
      success: c('success'),
      onSuccess: c('on-success'),
      successContainer: c('success-container'),
      onSuccessContainer: c('on-success-container'),
      // Mode-aware: the light-seed gradient on a dark screen was the one
      // light-mode object in the room. See palette.dart's card recipes.
      cardGradientStart: c('card-start'),
      cardGradientEnd: c('card-end'),
      onCard: c('on-card'),
      accent: accent,
      onAccent: onAccent,
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
      scheme,
      lightScheme,
      colors,
      shape,
      type,
      motionFor(cfg.motion),
      identityFor(cfg),
      arabic,
      NptDensity.of(density),
      NptNumerals(numerals),
      feedback ?? NptFeedback(hapticWeight: hapticWeightFor(cfg.contentTone)),
      hostFont,
      cfg.whiteGround,
      cfg.ruledRegister,
    );
  }

  /// A [ColorScheme] from one generated palette (`generatePaletteArgb`).
  static ColorScheme _customScheme(Map<String, int> p, Brightness mode) {
    Color c(String role) => Color(p[role]!);
    return ColorScheme(
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
  }

  /// Re-applies a host's own bundled font across an Odyssey theme — the text
  /// theme AND every component theme that carries its own `textStyle`.
  ///
  /// Superseded by `hostFont:` on [fromConfig] / [fromBrandprint] / [light] /
  /// [dark], which applies the face AT assembly instead of patching the
  /// result: that also reaches `NptType` (so `moneyStyle` under RTL stops
  /// resolving a Google family) and the `fontFamilyFallback` on the default
  /// text theme, neither of which this post-hoc patch can. Body unchanged;
  /// removed at 3.0.
  @Deprecated('Pass hostFont: to fromConfig / fromBrandprint / light / dark. '
      'Removed in 3.0.')
  static ThemeData withHostFont(
    ThemeData theme, {
    required String fontFamily,
    List<String> fontFamilyFallback = const <String>[],
  }) {
    final text = theme.textTheme.apply(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
    );
    final label = WidgetStatePropertyAll<TextStyle?>(text.labelLarge);
    return theme.copyWith(
      textTheme: text,
      primaryTextTheme: theme.primaryTextTheme.apply(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: (theme.filledButtonTheme.style ?? const ButtonStyle())
            .copyWith(textStyle: label),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: (theme.outlinedButtonTheme.style ?? const ButtonStyle())
            .copyWith(textStyle: label),
      ),
      textButtonTheme: TextButtonThemeData(
        style: (theme.textButtonTheme.style ?? const ButtonStyle())
            .copyWith(textStyle: label),
      ),
    );
  }

  // --- assembly -------------------------------------------------------------

  static ThemeData _assemble(
    ColorScheme scheme,
    ColorScheme lightScheme,
    NptColors colors,
    NptShape shape,
    NptType brandType,
    NptMotion motion,
    NptIdentity identity,
    bool arabic,
    NptDensity density,
    NptNumerals numerals,
    NptFeedback feedback,
    NptHostFont? hostFont,
    bool whiteGround,
    bool ruledRegister,
  ) {
    // The white register (`BrandprintConfig.whiteGround`): the ground is
    // tone 100, not the tinted tone 98, and a field is white inside its ring.
    // Light only - a dark scheme's `surfaceContainerLowest` is its darkest
    // tone and would invert the meaning.
    final white = whiteGround && scheme.brightness == Brightness.light;
    final ground = white ? scheme.surfaceContainerLowest : scheme.surface;
    // A field is white inside its ring in EVERY light scheme, not only under
    // `whiteGround`: the tone-90 slab is the grey box that made every form look
    // unthemed. Dark keeps `surfaceContainerHighest`, which is a lift there.
    final fieldFill = scheme.brightness == Brightness.light
        ? scheme.surfaceContainerLowest
        : scheme.surfaceContainerHighest;
    // `BrandprintConfig.ruledRegister`. `md`, not `xxl`: xxl on a 52dp button
    // is past the half-height clamp for every brand in the registry, so it
    // draws the same pill it is meant to replace. `md` is the corner the
    // brand's own fields and sheets already carry, which is what makes a
    // ruled button read as part of the same drawn structure rather than as a
    // shorter pill.
    final OutlinedBorder controlShape = ruledRegister
        ? RoundedRectangleBorder(borderRadius: shape.rMd)
        : const StadiumBorder();
    // A host face replaces EVERY face, Arabic ones included: a host bundles
    // one typeface per ROLE covering both scripts, and the brandprint's
    // registry names are for the web/Studio ports, not this theme. A host
    // that declares only `family` still collapses all three roles onto it,
    // which is what every host did before 2.30.0.
    final type = hostFont == null
        ? brandType
        : NptType(
            display: hostFont.displayFamily,
            text: hostFont.family,
            num: hostFont.numFamily,
            displayAr: hostFont.displayFamily,
            textAr: hostFont.family,
            numAr: hostFont.numFamily,
            displayWeight: brandType.displayWeight,
            displayTracking: brandType.displayTracking,
            bundled: true,
            fontFamilyFallback: hostFont.fallback,
          );
    final textTheme = _buildTextTheme(scheme, type, arabic);
    // The default body family for any text the textTheme doesn't name. A
    // registry family resolves through google_fonts so it is an actually-loaded
    // family, not just a name; a bundled one IS the name.
    final bodyFamily = arabic ? type.textAr : type.text;
    final resolvedTextFamily =
        type.bundled ? bodyFamily : _gf(bodyFamily).fontFamily;

    NeptuneFieldBorder field(Color color, {double width = 1}) =>
        NeptuneFieldBorder(
          borderRadius: shape.rSm,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: ground,
      // Neptune motion on every route push/pop; Cupertino kept on iOS so the
      // native edge-swipe back gesture survives.
      pageTransitionsTheme: NeptunePageTransitionsBuilder.theme,
      textTheme: textTheme,
      fontFamily: resolvedTextFamily,
      // Reaches primaryTextTheme and the default styles the textTheme leaves
      // unnamed - the two places a post-assembly patch used to have to visit.
      fontFamilyFallback: type.bundled ? type.fontFamilyFallback : null,
      extensions: [
        colors,
        shape,
        type,
        motion,
        identity,
        density,
        numerals,
        feedback,
        // Always from the LIGHT scheme, in both brightnesses - see the class.
        NptBrandCanvas.fromLightScheme(lightScheme),
        // 2.26.0 - the wrist scale. One instance for every brand; see the class.
        NptGlance.standard,
      ],
      // Material's default is `centerTitle` per platform (CENTRED on iOS)
      // while page content below sits at the start edge; in Arabic that reads
      // as a title pushed away from where the content begins. Material 3 also
      // paints a surface tint over any bar something scrolls under.
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: ground,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: shape.rLg),
      ),
      // Unset, Material 3 falls back to `primaryContainer` - a pale tint of the
      // brand, not the brand - so every floating action button went off-brand.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: shape.rXs),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: controlShape,
          side: BorderSide(color: scheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      // The label captured at assembly, as the two above capture theirs.
      // Left unset, TextButton reads `labelLarge` at build time through
      // `Theme.of`, i.e. AFTER localization has merged the M3 geometry in
      // (height 1.43, tracking 0.1) - a different line box from every other
      // button on the screen, and the one slot `withHostFont` used to fill.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(borderRadius: shape.rSm),
      ),
      // Every state is filled in - `errorBorder`, `focusedErrorBorder` and
      // `disabledBorder` included - because `InputDecoration.applyDefaults`
      // only falls back to `decoration.border` for a state the theme leaves
      // null, and a null state with a `BorderSide.none` fallback drew an
      // errored field with no ring at all. All of them are the non-outline
      // [NeptuneFieldBorder], so a screen that passes its own `border:` can no
      // longer drag outline geometry (and the bisected label) back in.
      //
      // `outline`, NOT `outlineVariant`, for the resting ring. Measured on two
      // production brandprints in both brightnesses, the variant ring came out
      // at 1.10-1.16:1 against the fill it encloses and 1.47:1 against the
      // page behind it: a border in the code and nothing at all on the glass.
      // `outline` is Material's role for a real component boundary and
      // measures 3.47:1 (light) / 4.40:1 (dark) against the surface, clearing
      // the 3:1 non-text-contrast floor in both.
      //
      // `surfaceContainerLowest` for the fill, because that is the web recipe
      // (`inputs.ts`: `background: surface-container-lowest; border: 1px
      // outline`) and this port had drifted to `surfaceContainerHighest` - the
      // darkest container tone, a grey slab on every form. Under the ring the
      // field is the lightest tone the scheme has, which is what makes the
      // ring the boundary rather than the fill-vs-page step (2.26.0).
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        border: field(scheme.outline),
        enabledBorder: field(scheme.outline),
        focusedBorder: field(scheme.primary, width: 2),
        errorBorder: field(scheme.error),
        focusedErrorBorder: field(scheme.error, width: 2),
        disabledBorder: field(scheme.onSurface.withValues(alpha: 0.12)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: shape.rSm),
      ),
    );
  }

  static TextTheme _buildTextTheme(
      ColorScheme scheme, NptType type, bool arabic) {
    final display = arabic ? type.displayAr : type.display;
    final text = arabic ? type.textAr : type.text;
    final w = type.displayFontWeight;
    TextStyle disp(double size, {double? height, double? letterSpacing}) =>
        _face(
          type,
          display,
          TextStyle(
            fontSize: size,
            height: height,
            fontWeight: w,
            letterSpacing: letterSpacing,
          ),
        );
    TextStyle body(double size, {FontWeight? weight}) =>
        _face(type, text, TextStyle(fontSize: size, fontWeight: weight));
    // ARABIC IS NEVER TRACKED. Tracking is a Latin device; Arabic is a
    // CONNECTED script, so positive tracking pulls the joins apart and
    // negative tracking — which is what most display faces here declare —
    // crashes the letters into each other. A brand that declared -0.03 set its
    // own slogan as an unreadable pile. Same rule as `NeptuneEyebrow`.
    final tracking = arabic ? 0.0 : type.displayTracking;
    return TextTheme(
      displayLarge: disp(57, height: 64 / 57, letterSpacing: tracking * 57),
      displayMedium: disp(45, height: 52 / 45, letterSpacing: tracking * 45),
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

  /// A [TextStyle] in [family] for the given type set: by name (with the
  /// host's fallback chain) when the faces are bundled, through the
  /// google_fonts loader when they are registry families.
  static TextStyle _face(NptType type, String family, TextStyle base) =>
      type.bundled
          ? base.copyWith(
              fontFamily: family, fontFamilyFallback: type.fontFamilyFallback)
          : _gf(family, base);

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
  /// With a host font at assembly both faces ARE the host family.
  ///
  /// TABULAR FIGURES ARE THE CONTRACT; the brand face is the enhancement. Under
  /// a theme with no [NptType] - a bare `MaterialApp` in a host's test harness,
  /// a widget mounted above the Odyssey theme - the `!` here threw, so a host
  /// that routed a list of amounts through this crashed the row rather than
  /// setting it in the default face. The digits still line up without a brand.
  static TextStyle moneyStyle(BuildContext context, {TextStyle? base}) {
    final type = Theme.of(context).extension<NptType>();
    final b =
        base ?? Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    const tabular = [FontFeature.tabularFigures()];
    if (type == null) return b.copyWith(fontFeatures: tabular);
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final family = rtl ? type.numAr : type.num;
    return _face(type, family, b).copyWith(fontFeatures: tabular);
  }

  /// The display tracking a host should apply at [fontSize], in logical
  /// pixels — `NptType.displayTracking` is an em fraction, the way the web
  /// token is, and it is ZERO under RTL.
  ///
  /// It exists because the rule cannot live only in the text theme. A host
  /// that sets its own headline (a pre-login masthead, a hero) reaches for
  /// `displayTracking * fontSize` by hand, and every one of those call sites
  /// was a place to crash a connected script into itself.
  static double displayTracking(BuildContext context, double fontSize) {
    if (Directionality.maybeOf(context) == TextDirection.rtl) return 0;
    final type = Theme.of(context).extension<NptType>();
    return (type?.displayTracking ?? 0) * fontSize;
  }

  /// Apply the active theme's numerals lever (R6) to [text] — swaps ASCII
  /// digits for Eastern Arabic / Arabic-Indic glyphs when the tenant has
  /// opted in, otherwise returns [text] unchanged. Money/amount widgets that
  /// receive pre-formatted strings should route them through this before
  /// rendering (see [moneyStyle] for the paired text style).
  static String formatDigits(BuildContext context, String text) =>
      Theme.of(context).extension<NptNumerals>()?.format(text) ?? text;

  // --- reference matching ---------------------------------------------------

  /// Return the reference brand id whose seeds match [primary]/[tertiary] within
  /// the brandprint quantisation tolerance, or null for a custom seed set.
  static String? _matchReferenceBrand(Seed primary, Seed tertiary) {
    for (final brand in kBrands) {
      final cfg = brandConfig[brand]!;
      if (_seedClose(cfg.primary, primary) &&
          _seedClose(cfg.tertiary, tertiary)) {
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
