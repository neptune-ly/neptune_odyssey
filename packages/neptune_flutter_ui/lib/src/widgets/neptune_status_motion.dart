// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The Odyssey outcome motion — an animated hourglass for in-flight work that
// hands off smoothly to an animated SUCCESS check or an animated REJECTED
// cross. One widget, three linked states: drive it with a [NeptuneFlowStatus]
// and the transitions (spin-out → spring-in, stroke-drawn glyphs, rejection
// shake) run on the brand's motion curves. Honours reduced-motion by rendering
// static glyphs. Theme-only, RTL-safe.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// The three linked states of [NeptuneStatusMotion].
enum NeptuneFlowStatus { loading, success, rejected }

/// Animated hourglass → check / cross outcome indicator.
///
/// While [status] is [NeptuneFlowStatus.loading] an hourglass drains and flips
/// on a gentle loop. Flip the status to `success` and the glass spins away
/// while a tinted disc springs in and DRAWS the check stroke ([color] defaults
/// to the brand success role — pass any colour); `rejected` draws the cross in
/// the error role with a decaying shake.
class NeptuneStatusMotion extends StatelessWidget {
  final NeptuneFlowStatus status;

  /// Diameter of the indicator disc.
  final double size;

  /// Override the success tint (defaults to the brand `success` role).
  final Color? color;

  const NeptuneStatusMotion({
    super.key,
    required this.status,
    this.size = 96,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = theme.extension<NptMotion>()!;

    return AnimatedSwitcher(
      duration: motion.durationStandard,
      switchInCurve: motion.spring,
      switchOutCurve: motion.standard,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: RotationTransition(
          // A quarter-turn hand-off links the glass to the outcome disc.
          turns: Tween<double>(begin: 0.25, end: 0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
      ),
      child: switch (status) {
        NeptuneFlowStatus.loading =>
          _Hourglass(key: const ValueKey('loading'), size: size),
        NeptuneFlowStatus.success => _OutcomeDisc(
            key: const ValueKey('success'),
            size: size,
            success: true,
            tint: color,
          ),
        NeptuneFlowStatus.rejected => _OutcomeDisc(
            key: const ValueKey('rejected'),
            size: size,
            success: false,
            tint: color,
          ),
      },
    );
  }
}

// --- hourglass ---------------------------------------------------------------

class _Hourglass extends StatefulWidget {
  final double size;

  const _Hourglass({super.key, required this.size});

  @override
  State<_Hourglass> createState() => _HourglassState();
}

class _HourglassState extends State<_Hourglass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) {
      _c.stop();
      _c.value = 0.35;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          // 0 → .72: sand drains. .72 → 1: the glass flips half a turn.
          final drain = (t / 0.72).clamp(0.0, 1.0);
          final flipT = ((t - 0.72) / 0.28).clamp(0.0, 1.0);
          final flip = Curves.easeInOutCubic.transform(flipT) * math.pi;
          return Transform.rotate(
            angle: flip,
            child: CustomPaint(
              painter: _HourglassPainter(
                drain: drain,
                frame: scheme.onSurfaceVariant,
                sand: scheme.primary,
              ),
              size: Size.square(widget.size),
            ),
          );
        },
      ),
    );
  }
}

/// Draws the glass frame + draining sand. All geometry is relative to size.
class _HourglassPainter extends CustomPainter {
  final double drain;
  final Color frame;
  final Color sand;

  const _HourglassPainter({
    required this.drain,
    required this.frame,
    required this.sand,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    // Glass bounds: a 38%-wide, 44%-tall hourglass centred in the disc.
    final gw = w * 0.34;
    final gh = w * 0.44;
    final top = (w - gh) / 2;
    final bottom = top + gh;
    final waist = top + gh / 2;
    final left = cx - gw / 2;
    final right = cx + gw / 2;

    final framePaint = Paint()
      ..color = frame
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Frame: two mirrored funnels + caps.
    final glass = Path()
      ..moveTo(left, top)
      ..lineTo(right, top)
      ..lineTo(cx + gw * 0.06, waist)
      ..lineTo(right, bottom)
      ..lineTo(left, bottom)
      ..lineTo(cx - gw * 0.06, waist)
      ..close();
    canvas.drawPath(glass, framePaint);

    final sandPaint = Paint()..color = sand;

    // Top sand: a triangle shrinking towards the waist as it drains.
    final topLevel = top + (waist - top) * drain; // surface sinks
    if (drain < 1) {
      final hw = (gw / 2) * (1 - drain) * 0.92;
      final topSand = Path()
        ..moveTo(cx - hw, topLevel)
        ..lineTo(cx + hw, topLevel)
        ..lineTo(cx, waist)
        ..close();
      canvas.drawPath(topSand, sandPaint);
    }

    // Falling stream.
    if (drain > 0.02 && drain < 1) {
      canvas.drawLine(
        Offset(cx, waist),
        Offset(cx, bottom - w * 0.03),
        Paint()
          ..color = sand
          ..strokeWidth = w * 0.02
          ..strokeCap = StrokeCap.round,
      );
    }

    // Bottom pile growing.
    final pileH = (gh / 2) * 0.8 * drain;
    if (pileH > 0.5) {
      final hw = (gw / 2) * 0.92 * drain;
      final pile = Path()
        ..moveTo(cx - hw, bottom - w * 0.015)
        ..lineTo(cx + hw, bottom - w * 0.015)
        ..lineTo(cx, bottom - w * 0.015 - pileH)
        ..close();
      canvas.drawPath(pile, sandPaint);
    }
  }

  @override
  bool shouldRepaint(_HourglassPainter old) =>
      old.drain != drain || old.frame != frame || old.sand != sand;
}

// --- outcome disc (check / cross) --------------------------------------------

class _OutcomeDisc extends StatefulWidget {
  final double size;
  final bool success;
  final Color? tint;

  const _OutcomeDisc({
    super.key,
    required this.size,
    required this.success,
    this.tint,
  });

  @override
  State<_OutcomeDisc> createState() => _OutcomeDiscState();
}

class _OutcomeDiscState extends State<_OutcomeDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.value = 1;
    } else if (_c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final npt = theme.extension<NptColors>()!;

    final Color fill;
    final Color glyph;
    if (widget.success) {
      fill = widget.tint ?? npt.success;
      glyph = npt.onSuccess;
    } else {
      fill = widget.tint ?? scheme.error;
      glyph = scheme.onError;
    }

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final draw = Curves.easeOutCubic.transform(t);
        // Rejection carries a decaying shake while the cross draws.
        final shake = widget.success
            ? 0.0
            : math.sin(t * math.pi * 5) * (1 - t) * widget.size * 0.05;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: fill.withValues(alpha: 0.35),
                  blurRadius: widget.size * 0.25,
                  offset: Offset(0, widget.size * 0.08),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _GlyphPainter(
                progress: draw,
                color: glyph,
                success: widget.success,
              ),
              size: Size.square(widget.size),
            ),
          ),
        );
      },
    );
  }
}

/// Stroke-draws the check or cross from 0 → [progress].
class _GlyphPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool success;

  const _GlyphPainter({
    required this.progress,
    required this.color,
    required this.success,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path;
    if (success) {
      path = Path()
        ..moveTo(w * 0.30, w * 0.52)
        ..lineTo(w * 0.45, w * 0.66)
        ..lineTo(w * 0.71, w * 0.36);
    } else {
      path = Path()
        ..moveTo(w * 0.35, w * 0.35)
        ..lineTo(w * 0.65, w * 0.65)
        ..moveTo(w * 0.65, w * 0.35)
        ..lineTo(w * 0.35, w * 0.65);
    }

    // Draw the stroke progressively along its metrics.
    var total = 0.0;
    final metrics = path.computeMetrics().toList();
    for (final m in metrics) {
      total += m.length;
    }
    var budget = total * progress;
    for (final m in metrics) {
      if (budget <= 0) break;
      final len = math.min(budget, m.length);
      canvas.drawPath(m.extractPath(0, len), paint);
      budget -= len;
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.progress != progress || old.color != color || old.success != success;
}
