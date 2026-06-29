// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// A compact metric tile (web `<npt-stat-card>`): a label, a big tabular value
/// with an optional unit, a signed delta coloured success/error, and an
/// optional chart slot (e.g. a sparkline). Theme-only, RTL-safe.
class NeptuneStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String? delta;
  final Widget? chart;

  const NeptuneStatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.delta,
    this.chart,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final npt = Theme.of(context).extension<NptColors>()!;
    final text = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: text.titleLarge)
        .copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700);
    final isDown = (delta ?? '').trimLeft().startsWith('-');
    final deltaColor = isDown ? scheme.error : npt.success;

    return Container(
      decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: shape.rLg),
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value, style: money, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (unit != null) ...[
                const SizedBox(width: 6),
                Text(unit!, style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ],
          ),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Text(
              delta!,
              style: text.labelMedium?.copyWith(color: deltaColor, fontWeight: FontWeight.w700),
            ),
          ],
          if (chart != null) ...[const SizedBox(height: 10), chart!],
        ],
      ),
    );
  }
}
