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

/// The four signature motif families (themes.css `--npt-motif`).
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

  List<BoxShadow> elevation1(ColorScheme s) => [
        BoxShadow(
            color: s.shadow.withValues(alpha: 0.20),
            blurRadius: 3,
            offset: const Offset(0, 1)),
      ];

  List<BoxShadow> elevation2(ColorScheme s) => [
        BoxShadow(
            color: s.shadow.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 2)),
      ];

  List<BoxShadow> elevation3(ColorScheme s) => [
        BoxShadow(
            color: s.shadow.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8)),
      ];

  List<BoxShadow> elevation5(ColorScheme s) => [
        BoxShadow(
            color: s.shadow.withValues(alpha: 0.30),
            blurRadius: 60,
            offset: const Offset(0, 28)),
      ];

  /// The primary key-light glow used under hero/selected surfaces
  /// (web `--npt-glow-primary`).
  List<BoxShadow> glowPrimary(ColorScheme s) => [
        BoxShadow(
            color: s.primary.withValues(alpha: 0.28),
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
