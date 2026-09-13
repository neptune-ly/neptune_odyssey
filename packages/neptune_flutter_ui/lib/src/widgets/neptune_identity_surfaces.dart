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
///
/// IT IS A FILL LAYER, SO IT FILLS ITS BOX AND NOTHING ELSE. `CustomPaint`
/// does not clip, and `sonarRings` draws to the farthest corner of the size it
/// is given: dropped into a 132dp band it painted rings of ~500dp radius
/// straight through the band, across the whole page and over every field and
/// label on it. The caller had sized the band precisely to keep the pattern
/// off the content and the pattern ignored it. `ClipRect` is what makes the
/// caller's box mean something; on the web the same layer is a
/// `background-image`, which has never been able to leave its element.
class NeptuneMotifLayer extends StatelessWidget {
  final Color? color;
  final double strength;

  /// Dissolve the pattern away from its own origin instead of ending at the
  /// clip.
  ///
  /// A CLIP EDGE IS WORSE THAN NO PATTERN. Bounded to a band behind a lockup,
  /// `sonarRings` ends in two dead-straight horizontal cuts and the whole
  /// thing reads as a rectangular window onto wallpaper - a texture fragment,
  /// which is exactly the decoration a restrained brand is trying not to
  /// draw. Faded from the source the same rings read as a signal attenuating
  /// with distance, which is what the motif means.
  ///
  /// Off by default: a full-bleed hero has no edge to hide and every existing
  /// caller keeps the pattern it has.
  final bool fade;

  /// Shifts the pattern's ORIGIN, in logical pixels, without moving the box.
  ///
  /// It exists so a caller can animate a tiled field without laying anything
  /// out. Translating the widget is the obvious way and it is wrong twice: a
  /// tiled motif drawn from (0,0) leaves a bare wedge at the trailing edge as
  /// soon as it moves, and the usual fix — an `OverflowBox` with infinite
  /// constraints around it — hands unbounded width to a `CustomPaint` sized
  /// `Size.infinite`, which does not render, it hangs.
  final Offset offset;

  const NeptuneMotifLayer({
    super.key,
    this.color,
    this.strength = 1,
    this.fade = false,
    this.offset = Offset.zero,
  });

  /// Where each motif emanates from, as a fraction of its box - the same
  /// origin its painter uses, so the fade and the pattern cannot disagree.
  /// The tiled motifs have no source and fade from the centre.
  static Alignment _originOf(NptMotifKind kind) => switch (kind) {
        NptMotifKind.sonarRings => const Alignment(0.72, -0.88),
        NptMotifKind.coastalArcs => Alignment.center,
        NptMotifKind.gridSpark => Alignment.center,
        NptMotifKind.guilloche => Alignment.center,
        NptMotifKind.none => Alignment.center,
        // The drift enters from the start-top corner and travels with the
        // reading direction; the fade has to start where the pattern does or
        // the two disagree. Mirrored by the caller under RTL.
        NptMotifKind.arrowDrift => const Alignment(-0.9, -0.85),
      };

  /// A directional motif's origin mirrors with the page; a centred one is
  /// unchanged by the flip, so this is safe to apply to all of them.
  static Alignment _mirror(Alignment a, bool rtl) =>
      rtl ? Alignment(-a.x, a.y) : a;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final identity = theme.extension<NptIdentity>()!;
    final c = color ?? theme.colorScheme.onSurface;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    Widget layer = CustomPaint(
      painter: _MotifPainter(
        kind: identity.motif,
        color: c,
        strength: identity.motifStrength * strength,
        rtl: rtl,
        offset: offset,
      ),
      size: Size.infinite,
    );
    if (fade) {
      layer = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => RadialGradient(
          center: _mirror(_originOf(identity.motif), rtl),
          radius: 1.1,
          colors: const [Colors.white, Colors.white, Colors.transparent],
          stops: const [0, 0.28, 1],
        ).createShader(rect),
        child: layer,
      );
    }
    return IgnorePointer(
      child: RepaintBoundary(
        child: ClipRect(child: layer),
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

  /// Only [NptMotifKind.arrowDrift] reads it — the other four are symmetric
  /// or unsigned, and mirroring them would be a no-op that still cost a
  /// canvas transform.
  final bool rtl;

  /// See [NeptuneMotifLayer.offset].
  final Offset offset;

  const _MotifPainter({
    required this.kind,
    required this.color,
    required this.strength,
    this.rtl = false,
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0) return;
    if (offset != Offset.zero) {
      // The box is unchanged; only the pattern moves inside it. The layer is
      // already clipped by `NeptuneMotifLayer`, and every motif here draws
      // past its own bounds by design, so a shifted origin exposes nothing.
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      _draw(canvas, size);
      canvas.restore();
      return;
    }
    _draw(canvas, size);
  }

  void _draw(Canvas canvas, Size size) {
    switch (kind) {
      case NptMotifKind.sonarRings:
        _sonar(canvas, size);
      case NptMotifKind.coastalArcs:
        _arcs(canvas, size);
      case NptMotifKind.gridSpark:
        _grid(canvas, size);
      case NptMotifKind.guilloche:
        _guilloche(canvas, size);
      case NptMotifKind.none:
        return;
      case NptMotifKind.arrowDrift:
        _arrows(canvas, size);
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

  /// FGLB — a drift of chevrons on the reading diagonal. 44x38 tiles, every
  /// other row offset by half a tile so the field never reads as a grid, and
  /// the ink falling off along the travel so it behaves like a trail rather
  /// than wallpaper. Stroked, never filled: a filled arrow at this density is
  /// a dazzle pattern.
  ///
  /// Mirrored under RTL. It is the one motif that MEANS something
  /// directional, so a brand that reads right-to-left and keeps it pointing
  /// left-to-right has drawn its own logo backwards.
  void _arrows(Canvas canvas, Size size) {
    const tw = 44.0, th = 38.0;
    const w = 9.0, h = 7.0; // half-extents of one chevron
    canvas.save();
    if (rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    var row = 0;
    for (var y = th / 2; y < size.height + th; y += th) {
      final dx = row.isEven ? 0.0 : tw / 2;
      for (var x = tw / 2 + dx; x < size.width + tw; x += tw) {
        // Fade along the travel: full ink at the start-top corner, a third of
        // it by the far corner, so the drift has a source.
        final t = ((x / size.width) + (y / size.height)) / 2;
        final paint = _ink(0.16 * (1 - 0.66 * t.clamp(0.0, 1.0)), 2)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        final path = Path()
          ..moveTo(x - w, y - h)
          ..lineTo(x + w * 0.35, y)
          ..lineTo(x - w, y + h);
        canvas.drawPath(path, paint);
      }
      row++;
    }
    canvas.restore();
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
      old.offset != offset ||
      old.rtl != rtl ||
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
    // ARABIC IS NOT TRACKED, AND `toUpperCase` IS A NO-OP ON IT.
    //
    // The eyebrow's whole recipe — uppercase, 0.08em of tracking — is a Latin
    // typographic device. Arabic is a CONNECTED script: letter-spacing does
    // not open a word up, it pulls the joins apart, so `الرصيد المتاح` came
    // out as a row of disconnected shapes with the ligature seams showing.
    // Found on a device in the primary language of every bank on this system,
    // which is the only place it could have been found: it is valid text in a
    // valid style and nothing about it is detectable from code.
    //
    // Keyed on the DIRECTION, not on a scan of the string: a mixed eyebrow
    // ("الرصيد المتاح  LYD") has Latin in it and still must not be tracked,
    // because the Arabic is the part that breaks.
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    return Text(
      rtl ? text : text.toUpperCase(),
      style: base.copyWith(
        // THE TEXT FACE, NOT THE DISPLAY FACE. An eyebrow is labelMedium —
        // twelve logical pixels — and a display face is chosen to work at
        // thirty-six and up. A brand that bundles a genuinely expressive
        // display face (a kufic, a high-contrast serif) had its smallest
        // label set in it, and the result was mush: closed counters, joins
        // that merge, a word a customer has to decode. It costs nothing for a
        // brand whose display and text faces are the same family, which until
        // now was every brand here — which is exactly why nobody saw it.
        fontFamily: rtl ? type.textAr : type.text,
        fontWeight: FontWeight.w700,
        letterSpacing: rtl ? 0 : 0.08 * fontSize,
        color: color ?? theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
