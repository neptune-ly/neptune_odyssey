// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Premium fintech components: a tonal insight card, an FX-rate card, a budget
// ring, a stacked spend breakdown, and a credit-score gauge. Charts paint with
// CustomPainter; every colour is read from the theme in build() and passed into
// the painter (painters never touch Theme). Theme-only, RTL-safe.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';
import 'neptune_onboarding.dart' show NeptuneStatusTone;

/// A tinted insight surface (web `<npt-insight-card>`): a leading icon, a
/// [titleSmall] title, a [bodyMedium] message, and an optional text-button
/// action. The [tone] picks a tonal container fill with its matching on-colour:
/// neutral → secondaryContainer, success → the Neptune success container,
/// warning → tertiaryContainer, danger → errorContainer. Theme-only, RTL-safe.
class NeptuneInsightCard extends StatelessWidget {
  /// Leading icon, tinted with the on-container colour.
  final IconData icon;

  /// The insight title ([TextTheme.titleSmall]).
  final String title;

  /// The supporting message ([TextTheme.bodyMedium]).
  final String message;

  /// Optional action label; renders a trailing text button when [onAction] set.
  final String? actionLabel;

  /// Tap handler for the optional action.
  final VoidCallback? onAction;

  /// The tonal colour family for the card.
  final NeptuneStatusTone tone;

  const NeptuneInsightCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.tone = NeptuneStatusTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final npt = Theme.of(context).extension<NptColors>()!;
    final text = Theme.of(context).textTheme;

    // Resolve the container fill + matching on-colour per tone.
    final Color bg;
    final Color fg;
    switch (tone) {
      case NeptuneStatusTone.success:
        bg = npt.successContainer;
        fg = npt.onSuccessContainer;
        break;
      case NeptuneStatusTone.warning:
        bg = scheme.tertiaryContainer;
        fg = scheme.onTertiaryContainer;
        break;
      case NeptuneStatusTone.danger:
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
        break;
      case NeptuneStatusTone.neutral:
        bg = scheme.secondaryContainer;
        fg = scheme.onSecondaryContainer;
        break;
    }

    final hasAction = actionLabel != null && actionLabel!.isNotEmpty;

    return Container(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: shape.rLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: text.titleSmall?.copyWith(color: fg),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: text.bodyMedium?.copyWith(
                    color: fg.withValues(alpha: 0.85),
                  ),
                ),
                if (hasAction) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: fg,
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// An exchange-rate card (web `<npt-fx-card>`): a `FROM → TO` header with a
/// swap glyph, the [rate] rendered large via [NeptuneTheme.moneyStyle], and an
/// optional change pill. When [up] the pill tints with the Neptune success role
/// and a trending-up arrow; otherwise it tints with `scheme.error` (down arrow).
/// Theme-only, RTL-safe.
class NeptuneFxCard extends StatelessWidget {
  /// The source currency code (e.g. 'USD').
  final String fromCurrency;

  /// The destination currency code (e.g. 'LYD').
  final String toCurrency;

  /// The exchange rate, rendered in the money/number style.
  final String rate;

  /// Optional signed change label for the pill (e.g. '+0.4%').
  final String? change;

  /// Whether the change is positive (success tint) or negative (error tint).
  final bool up;

  const NeptuneFxCard({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    this.change,
    this.up = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final npt = Theme.of(context).extension<NptColors>()!;
    final text = Theme.of(context).textTheme;

    final pairStyle = text.titleSmall?.copyWith(color: scheme.onSurface);
    final rateStyle = NeptuneTheme.moneyStyle(context, base: text.displaySmall)
        .copyWith(color: scheme.onSurface);

    final hasChange = change != null && change!.isNotEmpty;
    final accent = up ? npt.success : scheme.error;

    return Container(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: shape.rLg,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  fromCurrency,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pairStyle,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.swap_horiz, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  toCurrency,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pairStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  rate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: rateStyle,
                ),
              ),
              if (hasChange) ...[
                const SizedBox(width: 12),
                _ChangePill(
                  label: change!,
                  accent: accent,
                  up: up,
                  shape: shape,
                  text: text,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// The trending up/down change pill used by [NeptuneFxCard].
class _ChangePill extends StatelessWidget {
  final String label;
  final Color accent;
  final bool up;
  final NptShape shape;
  final TextTheme text;

  const _ChangePill({
    required this.label,
    required this.accent,
    required this.up,
    required this.shape,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(shape.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: accent,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: text.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A budget progress ring (web `<npt-budget-ring>`): a [CustomPaint] arc that
/// fills `spent / limit`, switching from `scheme.primary` to `scheme.error`
/// when over budget. The [spent] amount (money style) and [label] sit centred.
/// The arc clamps to 0..1 but the real numbers are still shown. Theme-only.
class NeptuneBudgetRing extends StatelessWidget {
  /// Amount spent so far.
  final double spent;

  /// The budget limit.
  final double limit;

  /// Caption under the amount (e.g. 'of \$2,000').
  final String label;

  /// Diameter of the ring in logical pixels.
  final double size;

  const NeptuneBudgetRing({
    super.key,
    required this.spent,
    required this.limit,
    required this.label,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final safeLimit = limit.isFinite && limit > 0 ? limit : 0.0;
    final raw = safeLimit == 0 ? 0.0 : spent / safeLimit;
    final fraction = raw.isNaN ? 0.0 : raw.clamp(0.0, 1.0).toDouble();
    final over = safeLimit > 0 && spent > safeLimit;
    final arcColor = over ? scheme.error : scheme.primary;

    final amountStyle = NeptuneTheme.moneyStyle(context, base: text.titleLarge)
        .copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700);
    final labelStyle = text.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BudgetRingPainter(
          fraction: fraction,
          arcColor: arcColor,
          track: scheme.surfaceContainerHighest,
          thickness: size * 0.1,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: size * 0.18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _format(spent),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: amountStyle,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Compact thousands-grouped amount without forcing a currency symbol.
  static String _format(double v) {
    if (!v.isFinite) return '0';
    final neg = v < 0;
    final abs = v.abs();
    final whole = abs.truncate();
    final digits = whole.toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    final frac = abs - whole;
    if (frac > 0) {
      final cents = (frac * 100).round().toString().padLeft(2, '0');
      buf.write('.$cents');
    }
    return neg ? '-$buf' : buf.toString();
  }
}

class _BudgetRingPainter extends CustomPainter {
  final double fraction;
  final Color arcColor;
  final Color track;
  final double thickness;

  const _BudgetRingPainter({
    required this.fraction,
    required this.arcColor,
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
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawCircle(center, radius, base);

    if (fraction <= 0) return;

    // Start at 12 o'clock, sweep clockwise.
    final sweep = fraction.clamp(0.0, 1.0) * 2 * math.pi;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = arcColor;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(_BudgetRingPainter old) =>
      old.fraction != fraction ||
      old.arcColor != arcColor ||
      old.track != track ||
      old.thickness != thickness;
}

/// One slice of a [NeptuneSpendBreakdown]: a [label], an [amount], and an
/// optional [icon] shown in the legend.
class NeptuneSpendSlice {
  /// The category label (e.g. 'Groceries').
  final String label;

  /// The spent amount for this slice.
  final double amount;

  /// Optional legend icon.
  final IconData? icon;

  const NeptuneSpendSlice({
    required this.label,
    required this.amount,
    this.icon,
  });
}

/// A spend breakdown (web `<npt-spend-breakdown>`): a single horizontal stacked
/// bar where each [NeptuneSpendSlice] is a proportional segment, above a legend
/// of dot + label + amount (money style, end-aligned). Segment colours cycle
/// through `primary / secondary / tertiary / success`. Theme-only, RTL-safe.
class NeptuneSpendBreakdown extends StatelessWidget {
  /// The slices to chart, in display order.
  final List<NeptuneSpendSlice> slices;

  const NeptuneSpendBreakdown({super.key, required this.slices});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final npt = Theme.of(context).extension<NptColors>()!;
    final text = Theme.of(context).textTheme;

    final palette = <Color>[
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      npt.success,
    ];

    final money = NeptuneTheme.moneyStyle(context, base: text.labelLarge)
        .copyWith(color: scheme.onSurface);

    var total = 0.0;
    for (final s in slices) {
      if (s.amount.isFinite && s.amount > 0) total += s.amount;
    }
    final radius = BorderRadius.circular(shape.full);

    // Stacked bar: each segment flexes by its share of the total.
    final segments = <Widget>[];
    for (var i = 0; i < slices.length; i++) {
      final amount = slices[i].amount;
      if (!amount.isFinite || amount <= 0) continue;
      final flex = (amount * 1000).round().clamp(1, 1 << 30);
      segments.add(
        Expanded(
          flex: flex,
          child: ColoredBox(
            color: palette[i % palette.length].withValues(alpha: 0.9),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            height: 12,
            child: segments.isEmpty
                ? ColoredBox(color: scheme.surfaceContainerHighest)
                : Row(children: segments),
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < slices.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _LegendRow(
            slice: slices[i],
            color: palette[i % palette.length],
            total: total,
            money: money,
            shape: shape,
            scheme: scheme,
            text: text,
          ),
        ],
      ],
    );
  }
}

/// A single legend line: dot + (optional icon) + label, with the amount and a
/// faint share percentage end-aligned.
class _LegendRow extends StatelessWidget {
  final NeptuneSpendSlice slice;
  final Color color;
  final double total;
  final TextStyle money;
  final NptShape shape;
  final ColorScheme scheme;
  final TextTheme text;

  const _LegendRow({
    required this.slice,
    required this.color,
    required this.total,
    required this.money,
    required this.shape,
    required this.scheme,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final share = total > 0 ? (slice.amount / total) : 0.0;
    final pct = (share * 100).round();

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(shape.full),
          ),
        ),
        const SizedBox(width: 10),
        if (slice.icon != null) ...[
          Icon(slice.icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            slice.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium?.copyWith(color: scheme.onSurface),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$pct%',
          style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Text(
          _format(slice.amount),
          textAlign: TextAlign.end,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: money,
        ),
      ],
    );
  }

  static String _format(double v) {
    if (!v.isFinite) return '0';
    final neg = v < 0;
    final abs = v.abs();
    final whole = abs.truncate();
    final digits = whole.toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    final frac = abs - whole;
    if (frac > 0) {
      final cents = (frac * 100).round().toString().padLeft(2, '0');
      buf.write('.$cents');
    }
    return neg ? '-$buf' : buf.toString();
  }
}

/// A credit-score gauge (web `<npt-credit-gauge>`): a 240° [CustomPaint] arc
/// with an `outlineVariant` track and a `scheme.primary` fill up to the score's
/// fraction of [min]..[max]. The [score] sits large in the centre (display
/// type) with an optional [band] label (e.g. 'Good') below. Theme-only.
class NeptuneCreditScoreGauge extends StatelessWidget {
  /// The current score.
  final int score;

  /// The minimum of the score range (default 300).
  final int min;

  /// The maximum of the score range (default 850).
  final int max;

  /// Optional band label under the score (e.g. 'Good', 'Excellent').
  final String? band;

  /// Diameter of the gauge in logical pixels.
  final double size;

  const NeptuneCreditScoreGauge({
    super.key,
    required this.score,
    this.min = 300,
    this.max = 850,
    this.band,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;

    final span = (max - min) == 0 ? 1 : (max - min);
    final fraction = ((score - min) / span).clamp(0.0, 1.0).toDouble();

    final scoreStyle = text.displaySmall?.copyWith(
      fontFamily: type.display,
      fontWeight: type.displayFontWeight,
      letterSpacing: type.displayTracking,
      color: scheme.onSurface,
    );
    final bandStyle = text.titleSmall?.copyWith(color: scheme.onSurfaceVariant);

    final hasBand = band != null && band!.isNotEmpty;

    return SizedBox(
      width: size,
      // 240° arc leaves a gap at the bottom; trim the box accordingly.
      height: size * 0.82,
      child: CustomPaint(
        painter: _CreditGaugePainter(
          fraction: fraction,
          fill: scheme.primary,
          track: scheme.outlineVariant,
          thickness: size * 0.09,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(bottom: size * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score', style: scoreStyle),
              if (hasBand) ...[
                const SizedBox(height: 2),
                Text(band!, style: bandStyle),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditGaugePainter extends CustomPainter {
  final double fraction;
  final Color fill;
  final Color track;
  final double thickness;

  const _CreditGaugePainter({
    required this.fraction,
    required this.fill,
    required this.track,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // A 240° gauge: leave a 120° gap centred at the bottom. Start at
    // 90° + 60° = 150° and sweep 240° clockwise.
    const start = math.pi * (150 / 180);
    const sweep = math.pi * (240 / 180);

    final radius = (size.width - thickness) / 2;
    final center = Offset(size.width / 2, radius + thickness / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(rect, start, sweep, false, base);

    if (fraction <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = fill;
    canvas.drawArc(rect, start, sweep * fraction.clamp(0.0, 1.0), false, arc);
  }

  @override
  bool shouldRepaint(_CreditGaugePainter old) =>
      old.fraction != fraction ||
      old.fill != fill ||
      old.track != track ||
      old.thickness != thickness;
}
