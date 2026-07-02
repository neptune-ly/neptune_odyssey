// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// R6: the standalone loading-indicator family — a spinner, a three-dot
// waiter, a breathing pulse, and the hourglass (extracted from
// neptune_status_motion.dart so it's usable on its own, not just as the
// "loading" phase of an outcome hand-off). All four share [NeptuneLoaderStyle]
// so [NeptuneStatusMotion] can drive any of them into the same success/reject
// morph — one continuous animation, four different "waiting" feelings.
// Theme-only (colour from ColorScheme, timing from NptMotion), honours
// reduced-motion by freezing on a representative static frame.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// Which waiting indicator a loader-family widget renders. Shared by the
/// standalone loaders and by [NeptuneStatusMotion]'s `loading` phase.
enum NeptuneLoaderStyle { hourglass, spinner, dots, pulse }

/// Render the loader for [style] at [size], reading colour from [scheme].
/// Used internally by [NeptuneStatusMotion] and by each standalone widget so
/// both paths render pixel-identically.
Widget neptuneLoaderFor(NeptuneLoaderStyle style, {required double size, Key? key}) {
  return switch (style) {
    NeptuneLoaderStyle.hourglass => NeptuneHourglassLoader(key: key, size: size),
    NeptuneLoaderStyle.spinner => NeptuneSpinner(key: key, size: size),
    NeptuneLoaderStyle.dots => NeptuneDotsLoader(key: key, size: size),
    NeptuneLoaderStyle.pulse => NeptunePulseLoader(key: key, size: size),
  };
}

/// The draining/flipping hourglass on a tinted disc (web `<npt-status-motion
/// state="loading">`'s idle phase). Standalone use: any in-progress moment
/// that isn't part of a success/reject hand-off.
class NeptuneHourglassLoader extends StatefulWidget {
  final double size;

  const NeptuneHourglassLoader({super.key, this.size = 96});

  @override
  State<NeptuneHourglassLoader> createState() => _NeptuneHourglassLoaderState();
}

class _NeptuneHourglassLoaderState extends State<NeptuneHourglassLoader>
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
      decoration: BoxDecoration(color: scheme.surfaceContainerHigh, shape: BoxShape.circle),
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

  const _HourglassPainter({required this.drain, required this.frame, required this.sand});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
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

    final topLevel = top + (waist - top) * drain;
    if (drain < 1) {
      final hw = (gw / 2) * (1 - drain) * 0.92;
      final topSand = Path()
        ..moveTo(cx - hw, topLevel)
        ..lineTo(cx + hw, topLevel)
        ..lineTo(cx, waist)
        ..close();
      canvas.drawPath(topSand, sandPaint);
    }

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

/// A branded ring spinner: a partial arc (not a full circle — reads as
/// "spinning", not "static ring") sweeping on the brand's `spring` curve
/// timing so its personality matches the rest of the brand's motion, not a
/// generic Material spinner feel.
class NeptuneSpinner extends StatefulWidget {
  final double size;
  final Color? color;

  const NeptuneSpinner({super.key, this.size = 40, this.color});

  @override
  State<NeptuneSpinner> createState() => _NeptuneSpinnerState();
}

class _NeptuneSpinnerState extends State<NeptuneSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = Theme.of(context).extension<NptMotion>();
    if (motion != null) _c.duration = motion.slow * 2;
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
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
    final color = widget.color ?? scheme.primary;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _SpinnerPainter(
            t: _c.value,
            track: scheme.surfaceContainerHighest,
            arc: color,
          ),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final double t;
  final Color track;
  final Color arc;

  const _SpinnerPainter({required this.t, required this.track, required this.arc});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final stroke = w * 0.09;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, w - stroke, w - stroke);
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    // Arc sweeps around while its own length breathes — classic "spinner",
    // not a spinning static gap.
    final rotation = t * math.pi * 2;
    final sweep = 0.18 + 0.55 * (0.5 - 0.5 * math.cos(t * math.pi * 2));
    final arcPaint = Paint()
      ..color = arc
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, rotation, sweep * math.pi * 2, false, arcPaint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.t != t || old.track != track || old.arc != arc;
}

/// Three dots waiting in sequence — the classic "typing/loading" indicator,
/// rendered in the brand's primary colour on the brand's `standard` curve.
class NeptuneDotsLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const NeptuneDotsLoader({super.key, this.size = 40, this.color});

  @override
  State<NeptuneDotsLoader> createState() => _NeptuneDotsLoaderState();
}

class _NeptuneDotsLoaderState extends State<NeptuneDotsLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
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
    final color = widget.color ?? scheme.primary;
    final dot = widget.size * 0.22;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(3, (i) {
              // Each dot lags the last by a third of the cycle.
              final phase = (_c.value - i * 0.18) % 1.0;
              final bounce = phase < 0.5
                  ? Curves.easeOut.transform(phase * 2)
                  : Curves.easeIn.transform(1 - (phase - 0.5) * 2);
              return Transform.translate(
                offset: Offset(0, -bounce * widget.size * 0.32),
                child: Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.55 + 0.45 * bounce),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// A single breathing disc — the softest, most ambient "still working" cue
/// (a good fit for a splash screen or a quiet background sync indicator).
class NeptunePulseLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const NeptunePulseLoader({super.key, this.size = 56, this.color});

  @override
  State<NeptunePulseLoader> createState() => _NeptunePulseLoaderState();
}

class _NeptunePulseLoaderState extends State<NeptunePulseLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = Theme.of(context).extension<NptMotion>();
    if (motion != null) _c.duration = motion.slow * 3;
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
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
    final color = widget.color ?? scheme.primary;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_c.value);
        final scale = 0.82 + 0.18 * t;
        return Opacity(
          opacity: 0.55 + 0.45 * t,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color, color.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
