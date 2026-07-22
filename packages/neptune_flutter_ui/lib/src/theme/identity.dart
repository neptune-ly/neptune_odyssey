// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The brand identity layer — what makes Odyssey look like Odyssey and not
// generic Material. Ports the web token levers (themes.css) that sit ABOVE the
// M3 colour scheme:
//   · glass    — --npt-glass-tint / --npt-glass-blur (per-brand translucency)
//   · motif    — --npt-motif (the brand's signature pattern: sonar tide-rings,
//                coastal arcs, grid-spark, shield guilloché)
//   · shadows  — --npt-elevation-1/2/3/5 and the primary key-light glow
//   · levers   — login shell / dashboard hero / content tone names
// Everything resolves from the active ColorScheme at build time, so custom
// brandprint seeds get the same treatment as the reference brands.

import 'package:flutter/material.dart';

/// The signature motif families (themes.css `--npt-motif` for the four
/// reference brands; `facetLattice` is a Flutter-side addition for custom
/// brandprints — see `identity.dart` header).
enum NptMotifKind {
  /// Neptune — sonar tide-rings: concentric hairline rings radiating from the
  /// top-trailing corner.
  sonarRings,

  /// Triton — coastal arcs: a tiled wave of soft arc crests.
  coastalArcs,

  /// Nereid — grid-spark: a fine luminous grid.
  gridSpark,

  /// Proteus — shield guilloché: a diagonal crosshatch weave.
  guilloche,

  /// A custom-brand motif: a faceted chevron lattice — interlocking angular
  /// V-facets in an offset (herringbone) tiling. Not tied to a reference
  /// brand; named for its geometry, for any brand whose mark reads as
  /// angular/faceted rather than organic.
  facetLattice,
}

/// Brand identity levers + material recipes. Read via
/// `Theme.of(context).extension<NptIdentity>()!`.
@immutable
class NptIdentity extends ThemeExtension<NptIdentity> {
  /// The brand's signature background pattern.
  final NptMotifKind motif;

  /// Base opacity multiplier for the motif (web `--npt-motif-strength`).
  final double motifStrength;

  /// Glass mixes `tertiary` instead of `primary` into the pane (Triton).
  final bool glassOnTertiary;

  /// Fraction of accent colour mixed into the glass pane (web 7–12%).
  final double glassMixRatio;

  /// Opacity of the surface component of the glass pane (web 62–76%).
  final double glassSurfaceOpacity;

  /// Backdrop blur radius in px (web `--npt-glass-blur`, 14–22).
  final double glassBlur;

  /// Named treatment levers (informational; drive app-level composition).
  final String dashboardHero;
  final String loginShell;
  final String contentTone;

  const NptIdentity({
    required this.motif,
    required this.motifStrength,
    required this.glassOnTertiary,
    required this.glassMixRatio,
    required this.glassSurfaceOpacity,
    required this.glassBlur,
    required this.dashboardHero,
    required this.loginShell,
    required this.contentTone,
  });

  // --- glass ----------------------------------------------------------------

  /// The translucent glass pane colour (web `--npt-glass-tint`):
  /// `color-mix(in oklab, accent R%, color-mix(surface A%, transparent))`.
  /// Composited: alpha = R + (1-R)·A, colour = lerp(surface, accent, R/alpha).
  Color glassTint(ColorScheme scheme) {
    final accent = glassOnTertiary ? scheme.tertiary : scheme.primary;
    final alpha = glassMixRatio + (1 - glassMixRatio) * glassSurfaceOpacity;
    final w = glassMixRatio / alpha;
    return Color.lerp(scheme.surface, accent, w)!.withValues(alpha: alpha);
  }

  /// The dock/nav glass (web dock: `color-mix(surface-container 86%, transparent)`).
  Color dockGlass(ColorScheme scheme) =>
      scheme.surfaceContainer.withValues(alpha: 0.86);

  // --- elevation ------------------------------------------------------------
  // Web tokens: e1 `0 1px 3px .20` · e2 `0 2px 6px .18` · e3 `0 8px 20px .20`
  // · e5 `0 28px 60px .30`. Colour comes from the scheme's shadow role.
  //
  // R6: that recipe reads correctly in light mode (a dark shadow against a
  // near-white surface) but goes nearly invisible in dark mode — a black
  // shadow at 18-30% alpha barely registers against an already-dark
  // background. Dark mode swaps to a soft, primary-tinted GLOW instead: less
  // directional offset (a glow reads as ambient, not cast), more blur, and a
  // colour lerp toward `primary` so raised surfaces read as lit rather than
  // shadowed. Light mode is untouched (proven against the web reference).

  bool _isDark(ColorScheme s) => s.brightness == Brightness.dark;

  List<BoxShadow> _elevation(ColorScheme s,
      {required double lightAlpha,
      required double lightBlur,
      required double lightOffset,
      required double darkAlpha,
      required double darkBlur,
      required double darkOffset}) {
    if (!_isDark(s)) {
      return [
        BoxShadow(
            color: s.shadow.withValues(alpha: lightAlpha),
            blurRadius: lightBlur,
            offset: Offset(0, lightOffset)),
      ];
    }
    final glow = Color.lerp(s.shadow, s.primary, 0.35)!;
    return [
      BoxShadow(
          color: glow.withValues(alpha: darkAlpha),
          blurRadius: darkBlur,
          offset: Offset(0, darkOffset)),
    ];
  }

  List<BoxShadow> elevation1(ColorScheme s) => _elevation(s,
      lightAlpha: 0.20, lightBlur: 3, lightOffset: 1,
      darkAlpha: 0.16, darkBlur: 6, darkOffset: 0.5);

  List<BoxShadow> elevation2(ColorScheme s) => _elevation(s,
      lightAlpha: 0.18, lightBlur: 6, lightOffset: 2,
      darkAlpha: 0.20, darkBlur: 12, darkOffset: 1);

  List<BoxShadow> elevation3(ColorScheme s) => _elevation(s,
      lightAlpha: 0.20, lightBlur: 20, lightOffset: 8,
      darkAlpha: 0.26, darkBlur: 32, darkOffset: 3);

  List<BoxShadow> elevation5(ColorScheme s) => _elevation(s,
      lightAlpha: 0.30, lightBlur: 60, lightOffset: 28,
      darkAlpha: 0.34, darkBlur: 76, darkOffset: 10);

  /// The primary key-light glow used under hero/selected surfaces
  /// (web `--npt-glow-primary`). Already a glow, not a shadow — dark mode
  /// just runs it a touch stronger, since it's competing with less ambient
  /// light from the (dark) surface around it.
  List<BoxShadow> glowPrimary(ColorScheme s) => [
        BoxShadow(
            color: s.primary.withValues(alpha: _isDark(s) ? 0.36 : 0.28),
            blurRadius: 22,
            offset: const Offset(0, 8)),
      ];

  // --- ThemeExtension -------------------------------------------------------

  @override
  NptIdentity copyWith({
    NptMotifKind? motif,
    double? motifStrength,
    bool? glassOnTertiary,
    double? glassMixRatio,
    double? glassSurfaceOpacity,
    double? glassBlur,
    String? dashboardHero,
    String? loginShell,
    String? contentTone,
  }) =>
      NptIdentity(
        motif: motif ?? this.motif,
        motifStrength: motifStrength ?? this.motifStrength,
        glassOnTertiary: glassOnTertiary ?? this.glassOnTertiary,
        glassMixRatio: glassMixRatio ?? this.glassMixRatio,
        glassSurfaceOpacity: glassSurfaceOpacity ?? this.glassSurfaceOpacity,
        glassBlur: glassBlur ?? this.glassBlur,
        dashboardHero: dashboardHero ?? this.dashboardHero,
        loginShell: loginShell ?? this.loginShell,
        contentTone: contentTone ?? this.contentTone,
      );

  @override
  NptIdentity lerp(ThemeExtension<NptIdentity>? other, double t) {
    if (other is! NptIdentity) return this;
    final pick = t < 0.5 ? this : other;
    double l(double a, double b) => a + (b - a) * t;
    return NptIdentity(
      motif: pick.motif,
      motifStrength: l(motifStrength, other.motifStrength),
      glassOnTertiary: pick.glassOnTertiary,
      glassMixRatio: l(glassMixRatio, other.glassMixRatio),
      glassSurfaceOpacity: l(glassSurfaceOpacity, other.glassSurfaceOpacity),
      glassBlur: l(glassBlur, other.glassBlur),
      dashboardHero: pick.dashboardHero,
      loginShell: pick.loginShell,
      contentTone: pick.contentTone,
    );
  }
}
