// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Data-visualisation primitives (web `data-viz.ts`): sparkline, donut ring,
// limit meter and trend chip. Charts paint with CustomPainter; every colour is
// read from the theme in build() and passed into the painter (painters never
// touch Theme). Theme-only, RTL-safe.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// An inline line sparkline (web `<npt-sparkline>`): a smooth polyline with no
/// axes, normalised to its box. Stroke defaults to `scheme.primary`.
class NeptuneSparkline extends StatelessWidget {
  final List<double> points;
  final Color? color;
  final double height;

  const NeptuneSparkline({
    super.key,
    required this.points,
    this.color,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stroke = color ?? scheme.primary;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(points: points, color: stroke),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  const _SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 2.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Fewer than two points → flat midline (matches web fallback).
    if (points.length < 2) {
      final y = h / 2;
      canvas.drawLine(Offset(pad, y), Offset(w - pad, y), paint);
      return;
    }

    var min = points.first;
    var max = points.first;
    for (final v in points) {
      if (v < min) min = v;
      if (v > max) max = v;
    }
    final span = (max - min) == 0 ? 1.0 : (max - min);
    final stepX = (w - pad * 2) / (points.length - 1);

    final dx = <double>[];
    final dy = <double>[];
    for (var i = 0; i < points.length; i++) {
      dx.add(pad + i * stepX);
      dy.add(pad + (h - pad * 2) * (1 - (points[i] - min) / span));
    }

    // Smooth Catmull-Rom → cubic Bézier path through the normalised points.
    final path = Path()..moveTo(dx[0], dy[0]);
    for (var i = 0; i < points.length - 1; i++) {
      final p0x = dx[i == 0 ? 0 : i - 1];
      final p0y = dy[i == 0 ? 0 : i - 1];
      final p1x = dx[i];
      final p1y = dy[i];
      final p2x = dx[i + 1];
      final p2y = dy[i + 1];
      final p3x = dx[i + 2 < points.length ? i + 2 : points.length - 1];
      final p3y = dy[i + 2 < points.length ? i + 2 : points.length - 1];

      final c1x = p1x + (p2x - p0x) / 6;
      final c1y = p1y + (p2y - p0y) / 6;
      final c2x = p2x - (p3x - p1x) / 6;
      final c2y = p2y - (p3y - p1y) / 6;
      path.cubicTo(c1x, c1y, c2x, c2y, p2x, p2y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.color != color || !_sameList(old.points, points);

  static bool _sameList(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// A proportional ring/donut chart (web `<npt-donut>`): each value becomes an
/// arc. Default segment colours are `primary / secondary / tertiary / success`
/// (passed in from the theme); an optional [centerLabel] sits in the hole.
class NeptuneDonut extends StatelessWidget {
  final List<double> segments;
  final List<Color>? colors;
  final double size;
  final String? centerLabel;

  const NeptuneDonut({
    super.key,
    required this.segments,
    this.colors,
    this.size = 96,
    this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // Default success role lives on NptColors, not ColorScheme.
    final npt = Theme.of(context).extension<NptColors>()!;
    final segColors = colors ??
        [scheme.primary, scheme.secondary, scheme.tertiary, npt.success];
    final money = NeptuneTheme.moneyStyle(context, base: text.titleMedium)
        .copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          segments: segments,
          colors: segColors,
          track: scheme.surfaceContainerHighest,
          thickness: size * 0.14,
        ),
        child: centerLabel == null
            ? null
            : Center(
                child: Text(
                  centerLabel!,
                  textAlign: TextAlign.center,
                  style: money,
                ),
              ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> segments;
  final List<Color> colors;
  final Color track;
  final double thickness;

  const _DonutPainter({
    required this.segments,
    required this.colors,
    required this.track,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = track;
    canvas.drawCircle(center, radius, base);

    final valid = <double>[];
    for (final v in segments) {
      valid.add(v.isFinite && v > 0 ? v : 0);
    }
    final total = valid.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;

    // Start at 12 o'clock, sweep clockwise (web rotates the SVG -90°).
    var start = -math.pi / 2;
    for (var i = 0; i < valid.length; i++) {
      if (valid[i] <= 0) continue;
      final sweep = (valid[i] / total) * 2 * math.pi;
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.butt
        ..color = colors[i % colors.length];
      canvas.drawArc(rect, start, sweep, false, arc);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.track != track ||
      old.thickness != thickness ||
      !_sameDoubles(old.segments, segments) ||
      !_sameColors(old.colors, colors);

  static bool _sameDoubles(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// A labelled progress meter (web `<npt-limit-meter>`): a header row with the
/// [label] and a trailing [amount], then a rounded track with a filled bar.
/// [value] is 0..1; [warn] flips the fill to `scheme.error`.
class NeptuneLimitMeter extends StatelessWidget {
  final double value;
  final String label;
  final String? amount;
  final bool warn;

  const NeptuneLimitMeter({
    super.key,
    required this.value,
    required this.label,
    this.amount,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: text.labelLarge)
        .copyWith(color: scheme.onSurfaceVariant);

    final pct = value.isNaN ? 0.0 : value.clamp(0.0, 1.0).toDouble();
    final fill = warn ? scheme.error : scheme.primary;
    final radius = BorderRadius.circular(shape.full);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                label,
                style: text.labelLarge?.copyWith(color: scheme.onSurface),
              ),
            ),
            if (amount != null) ...[
              const SizedBox(width: 12),
              Text(amount!, style: money),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: radius,
          child: Container(
            height: 8,
            color: scheme.surfaceContainerHighest,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: pct,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: fill, borderRadius: radius),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A small signed-percent trend chip (web `<npt-trend>`): an up/down arrow plus
/// the value, coloured `npt.success` when up and `scheme.error` when down.
/// Direction follows [down] if given, else the sign of [value].
class NeptuneTrend extends StatelessWidget {
  final double value;
  final bool? down;

  const NeptuneTrend({super.key, required this.value, this.down});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final npt = Theme.of(context).extension<NptColors>()!;

    final isDown = down ?? value < 0;
    final fg = isDown ? scheme.error : npt.success;
    final arrow = isDown ? Icons.arrow_downward : Icons.arrow_upward;
    final sign = value > 0 ? '+' : '';
    final label = '$sign${value.toStringAsFixed(1)}%';
    final money = NeptuneTheme.moneyStyle(context, base: text.labelMedium)
        .copyWith(color: fg, fontWeight: FontWeight.w700);

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(shape.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(arrow, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(label, style: money),
        ],
      ),
    );
  }
}
