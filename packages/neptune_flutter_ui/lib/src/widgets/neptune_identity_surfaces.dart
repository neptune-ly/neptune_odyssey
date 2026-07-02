// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The Odyssey identity surfaces: the brand motif layer (web `--npt-motif`),
// real glass (web `npt-card[glass]` / the dock pane), and the branded card
// surface with the web's four variants. These are what give every screen the
// Odyssey signature instead of a generic Material look. Theme-only, RTL-safe.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/identity.dart';

/// Paints the brand's signature motif as a fill layer (web
/// `background-image: var(--npt-motif)`). Place inside a Stack over a hero or
/// card surface; it ignores pointer events.
///
/// [color] defaults to the ambient `onSurface`; on gradient heroes pass
/// `onPrimary`. [strength] multiplies the brand's base motif strength — the
/// web uses 1.0 on emblems, ~0.65–0.8 on cards, ~0.055 tinted page washes.
class NeptuneMotifLayer extends StatelessWidget {
  final Color? color;
  final double strength;

  const NeptuneMotifLayer({super.key, this.color, this.strength = 1});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final identity = theme.extension<NptIdentity>()!;
    final c = color ?? theme.colorScheme.onSurface;
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _MotifPainter(
            kind: identity.motif,
            color: c,
            strength: identity.motifStrength * strength,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Ports the four `--npt-motif` CSS gradients to Canvas. Opacities are the
/// web's per-motif ink levels multiplied by [strength].
class _MotifPainter extends CustomPainter {
  final NptMotifKind kind;
  final Color color;
  final double strength;

  const _MotifPainter({
    required this.kind,
    required this.color,
    required this.strength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0) return;
    switch (kind) {
      case NptMotifKind.sonarRings:
        _sonar(canvas, size);
      case NptMotifKind.coastalArcs:
        _arcs(canvas, size);
      case NptMotifKind.gridSpark:
        _grid(canvas, size);
      case NptMotifKind.guilloche:
        _guilloche(canvas, size);
    }
  }

  Paint _ink(double alpha, double stroke) => Paint()
    ..color = color.withValues(alpha: (alpha * strength).clamp(0.0, 1.0))
    ..style = PaintingStyle.stroke
    ..strokeWidth = stroke;

  /// Neptune — repeating radial rings at (86%, 6%), 1.5px ink every 27px.
  void _sonar(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.86, size.height * 0.06);
    final paint = _ink(0.11, 1.5);
    // Cover to the farthest corner.
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    var maxR = 0.0;
    for (final c in corners) {
      final d = (c - center).distance;
      if (d > maxR) maxR = d;
    }
    for (var r = 0.75; r <= maxR; r += 27) {
      canvas.drawCircle(center, r, paint);
    }
  }

  /// Triton — 40×32 tiles, each an arc crest rising from the tile's bottom
  /// centre (ring at r≈12.75, 1.5px ink).
  void _arcs(Canvas canvas, Size size) {
    final paint = _ink(0.13, 1.5);
    const tw = 40.0, th = 32.0;
    for (var y = 0.0; y < size.height; y += th) {
      for (var x = 0.0; x < size.width; x += tw) {
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(x, y, tw, th));
        canvas.drawCircle(Offset(x + tw / 2, y + th), 12.75, paint);
        canvas.restore();
      }
    }
  }

  /// Nereid — a fine 23×23 luminous grid, 1px ink.
  void _grid(Canvas canvas, Size size) {
    final paint = _ink(0.08, 1);
    const cell = 23.0;
    for (var x = 0.5; x < size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.5; y < size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  /// Proteus — ±45° guilloché crosshatch, 1px ink every 12px.
  void _guilloche(Canvas canvas, Size size) {
    final paint = _ink(0.07, 1);
    final diag = size.width + size.height;
    for (final dir in const [1.0, -1.0]) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(dir * 0.7853981633974483); // 45°
      for (var x = -diag; x <= diag; x += 12) {
        canvas.drawLine(Offset(x, -diag), Offset(x, diag), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MotifPainter old) =>
      old.kind != kind || old.color != color || old.strength != strength;
}

/// Real Odyssey glass (web `npt-card[glass]` / `--npt-glass-tint`): a
/// backdrop-blurred pane tinted with the brand accent, sealed with a hairline
/// `outlineVariant` border. Use only on approved surfaces — nav, hero, auth,
/// overlays — never on tables/forms (docs/06 §3).
class NeptuneGlass extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;

  /// Use the dock pane recipe (surfaceContainer @ 86%) instead of the tinted
  /// card glass.
  final bool dock;

  final EdgeInsetsGeometry? padding;

  const NeptuneGlass({
    super.key,
    required this.child,
    this.borderRadius,
    this.dock = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final identity = theme.extension<NptIdentity>()!;
    final radius = borderRadius ?? shape.rLg;
    final sigma = identity.glassBlur / 2; // CSS blur(px) ≈ 2σ

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dock
                ? identity.dockGlass(scheme)
                : identity.glassTint(scheme),
            borderRadius: radius,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}

/// The web `<npt-card>` variants.
enum NeptuneCardVariant { standard, elevated, tonal, glass }

/// The brand-shaped content surface (web `<npt-card variant=…>`):
/// `standard` = surface-container-low · `elevated` = surface-container +
/// elevation-2 · `tonal` = secondary-container · `glass` = the translucent
/// brand pane. Corner = brand `lg`, padding 24 — exactly the web recipe.
class NeptuneCard extends StatelessWidget {
  final Widget child;
  final NeptuneCardVariant variant;
  final EdgeInsetsGeometry? padding;

  /// Overlay the brand motif (web hero-card treatment, strength ~0.65).
  final bool motif;

  final VoidCallback? onTap;

  const NeptuneCard({
    super.key,
    required this.child,
    this.variant = NeptuneCardVariant.standard,
    this.padding,
    this.motif = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final identity = theme.extension<NptIdentity>()!;
    final radius = shape.rLg;
    final pad = padding ?? const EdgeInsetsDirectional.all(24);

    final (Color? bg, Color fg, List<BoxShadow>? shadows) = switch (variant) {
      NeptuneCardVariant.standard => (
          scheme.surfaceContainerLow,
          scheme.onSurface,
          null
        ),
      NeptuneCardVariant.elevated => (
          scheme.surfaceContainer,
          scheme.onSurface,
          identity.elevation2(scheme)
        ),
      NeptuneCardVariant.tonal => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
          null
        ),
      NeptuneCardVariant.glass => (null, scheme.onSurface, null),
    };

    Widget core = Padding(padding: pad, child: child);
    if (motif) {
      core = Stack(children: [
        Positioned.fill(
          child: NeptuneMotifLayer(color: fg, strength: 0.65),
        ),
        core,
      ]);
    }
    if (onTap != null) {
      core = Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, borderRadius: radius, child: core),
      );
    }

    if (variant == NeptuneCardVariant.glass) {
      return NeptuneGlass(borderRadius: radius, child: core);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        boxShadow: shadows,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: fg),
        child: core,
      ),
    );
  }
}

/// The Odyssey eyebrow — the uppercase, letter-spaced display-face micro-label
/// that tops heroes and sections on the web (`.scheme`/`.eyebrow`:
/// display font, 700, tracking 0.08em, uppercase).
class NeptuneEyebrow extends StatelessWidget {
  final String text;
  final Color? color;

  const NeptuneEyebrow(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = theme.extension<NptType>()!;
    final base = theme.textTheme.labelMedium ?? const TextStyle();
    final fontSize = base.fontSize ?? 12;
    return Text(
      text.toUpperCase(),
      style: base.copyWith(
        fontFamily: type.display,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.08 * fontSize,
        color: color ?? theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
