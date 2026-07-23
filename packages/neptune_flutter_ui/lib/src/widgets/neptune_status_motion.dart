// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The Odyssey outcome motion — a loading indicator for in-flight work that
// hands off smoothly to an animated SUCCESS check or an animated REJECTED
// cross. One widget, three linked states: drive it with a [NeptuneFlowStatus]
// and the transitions (spin-out → spring-in, stroke-drawn glyphs, rejection
// shake) run on the brand's motion curves. Honours reduced-motion by rendering
// static glyphs. Theme-only, RTL-safe.
//
// R6: the loading phase is no longer hourglass-only — [loaderStyle] picks
// any of the standalone loaders in neptune_loaders.dart, all sharing the same
// hand-off choreography into the outcome disc.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import 'neptune_loaders.dart';

/// The three linked states of [NeptuneStatusMotion].
enum NeptuneFlowStatus { loading, success, rejected }

/// Animated loader → check / cross outcome indicator.
///
/// While [status] is [NeptuneFlowStatus.loading], [loaderStyle] (hourglass by
/// default) animates on a gentle loop. Flip the status to `success` and it
/// spins away while a tinted disc springs in and DRAWS the check stroke
/// ([color] defaults to the brand success role — pass any colour); `rejected`
/// draws the cross in the error role with a decaying shake.
class NeptuneStatusMotion extends StatelessWidget {
  final NeptuneFlowStatus status;

  /// Diameter of the indicator disc.
  final double size;

  /// Override the success tint (defaults to the brand `success` role).
  final Color? color;

  /// Which loader animates during [NeptuneFlowStatus.loading].
  final NeptuneLoaderStyle loaderStyle;

  const NeptuneStatusMotion({
    super.key,
    required this.status,
    this.size = 96,
    this.color,
    this.loaderStyle = NeptuneLoaderStyle.hourglass,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = theme.extension<NptMotion>()!;

    // Self-size to [size]x[size] regardless of the ambient constraints — a
    // caller that asks for a 168dp indicator shouldn't also have to know to
    // wrap it in a SizedBox. Without this, AnimatedSwitcher sizes to its
    // child's own intrinsic size, and not every loaderStyle/outcome-disc
    // combination self-constrains identically in a loose-constraint context
    // (e.g. a bare Column(mainAxisSize: min) in a widget test), which showed
    // up as a five-figure RenderFlex overflow in a real consuming app.
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedSwitcher(
        duration: motion.durationStandard,
        switchInCurve: motion.spring,
        switchOutCurve: motion.standard,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: RotationTransition(
            // A quarter-turn hand-off links the loader to the outcome disc.
            turns: Tween<double>(begin: 0.25, end: 0).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
        ),
        child: switch (status) {
          NeptuneFlowStatus.loading =>
            neptuneLoaderFor(loaderStyle, key: const ValueKey('loading'), size: size),
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
      ),
    );
  }
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
