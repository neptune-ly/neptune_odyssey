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

  /// Fallback chain behind [family] — a host's Latin safety net behind an
  /// Arabic-first face, for example. Rides on every text style the theme
  /// builds.
  final List<String> fallback;

  const NptHostFont({required this.family, this.fallback = const []});
}

/// Entry points for building Neptune Odyssey [ThemeData].
class NeptuneTheme {
  NeptuneTheme._();

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
      _forBrand(brand, Brightness.light, arabic, density, numerals, feedback, hostFont);

  /// Dark theme for a reference brand id. See [light] for the other params.
  static ThemeData dark(
    String brand, {
    bool arabic = false,
    NeptuneDensityMode density = NeptuneDensityMode.comfortable,
    NeptuneNumeralStyle numerals = NeptuneNumeralStyle.latin,
    NptFeedback? feedback,
    NptHostFont? hostFont,
  }) =>
      _forBrand(brand, Brightness.dark, arabic, density, numerals, feedback, hostFont);

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
  }) =>
      fromConfig(Brandprint.decode(brandprint),
          brightness: brightness,
          arabic: arabic,
          density: density,
          numerals: numerals,
          feedback: feedback,
          hostFont: hostFont);

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
  }) {
    final mode = brightness ?? (cfg.defaultDark ? Brightness.dark : Brightness.light);
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
    );
  }

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
    final primary = Oklch(cfg.primary.l, cfg.primary.c, cfg.primary.h.toDouble());
    final tertiary = Oklch(cfg.tertiary.l, cfg.tertiary.c, cfg.tertiary.h.toDouble());
    // With `accentOnTertiary` the tertiary seed is a direction accent and
    // nothing else: every Material role - `tertiary*` and the card gradient
    // included - is ramped from the primary seed, so the accent has no path
    // into chrome. The seed itself surfaces only as `NptColors.accent`.
    final chromeTertiary = cfg.accentOnTertiary ? primary : tertiary;
    final palette = isLight ? 'light' : 'dark';
    final p = generatePaletteArgb(primary, chromeTertiary, palette);
    Color c(String role) => Color(p[role]!);

    final scheme = _customScheme(p, mode);
    // The brand canvas is brightness-INVARIANT (see NptBrandCanvas): a dark
    // theme still derives it from the light ramp, generated once here.
    final lightScheme = isLight
        ? scheme
        : _customScheme(
            generatePaletteArgb(primary, chromeTertiary, 'light'),
            Brightness.light);

    final Color accent;
    final Color onAccent;
    if (cfg.accentOnTertiary) {
      // The same tone the tertiary recipe would have given it, so a bank's
      // accent sits at the chroma and lightness a second brand colour does.
      final a = generatePaletteArgb(primary, tertiary, palette);
      accent = Color(a['tertiary']!);
      onAccent = Color(a['on-tertiary']!);
    } else {
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
  ) {
    // The white register (`BrandprintConfig.whiteGround`): the ground is
    // tone 100, not the tinted tone 98, and a field is white inside its ring.
    // Light only - a dark scheme's `surfaceContainerLowest` is its darkest
    // tone and would invert the meaning.
    final white = whiteGround && scheme.brightness == Brightness.light;
    final ground = white ? scheme.surfaceContainerLowest : scheme.surface;
    final fieldFill =
        white ? scheme.surfaceContainerLowest : scheme.surfaceContainerHighest;
    // A host face replaces EVERY face, Arabic ones included: the host has one
    // typeface for both scripts and the brandprint's registry names are for
    // the web/Studio ports, not this theme.
    final type = hostFont == null
        ? brandType
        : NptType(
            display: hostFont.family,
            text: hostFont.family,
            num: hostFont.family,
            displayAr: hostFont.family,
            textAr: hostFont.family,
            numAr: hostFont.family,
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

  static TextTheme _buildTextTheme(ColorScheme scheme, NptType type, bool arabic) {
    final display = arabic ? type.displayAr : type.display;
    final text = arabic ? type.textAr : type.text;
    final w = type.displayFontWeight;
    TextStyle disp(double size, {double? height, double? letterSpacing}) => _face(
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
  static TextStyle moneyStyle(BuildContext context, {TextStyle? base}) {
    final type = Theme.of(context).extension<NptType>()!;
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final family = rtl ? type.numAr : type.num;
    final b = base ?? Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    return _face(type, family, b)
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
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
