// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Data-viz expansion (R4b): branded bar charts for the Insights tier —
//   · NeptuneBarChart     — labelled vertical bars, brand-rounded, optional
//                           highlight of one period
//   · NeptuneCompareBars  — this-vs-last paired bars per category (the web
//                           "vs last month" story)
// CustomPainter-drawn; every colour arrives from build(). Theme-only, RTL-safe
// (bars lay out with the reading direction).

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// One bar of a [NeptuneBarChart].
class NeptuneBarData {
  final String label;
  final double value;

  const NeptuneBarData(this.label, this.value);
}

/// A compact vertical bar chart: brand-rounded bars on a hairline baseline,
/// labels underneath, optional [highlightIndex] tinted primary (others use
/// secondary-container ink).
class NeptuneBarChart extends StatelessWidget {
  final List<NeptuneBarData> bars;
  final int? highlightIndex;
  final double height;

  /// Optional value formatter for the tooltip-style caption over the
  /// highlighted bar (e.g. `(v) => 'LYD ${v.toStringAsFixed(0)}'`).
  final String Function(double value)? caption;

  const NeptuneBarChart({
    super.key,
    required this.bars,
    this.highlightIndex,
    this.height = 160,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: text.labelSmall)
        .copyWith(color: scheme.onSurface);
    final maxV = bars.fold<double>(0, (m, b) => b.value > m ? b.value : m);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < bars.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (i == highlightIndex && caption != null) ...[
                    Text(caption!(bars[i].value), style: money),
                    const SizedBox(height: 4),
                  ],
                  AnimatedContainer(
                    duration: Theme.of(context)
                        .extension<NptMotion>()!
                        .durationStandard,
                    height: maxV == 0
                        ? 0
                        : (bars[i].value / maxV) * (height - 46),
                    decoration: BoxDecoration(
                      color: i == highlightIndex
                          ? scheme.primary
                          : scheme.secondaryContainer,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(shape.xs)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bars[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One category of a [NeptuneCompareBars].
class NeptuneCompareData {
  final String label;
  final double current;
  final double previous;

  const NeptuneCompareData(this.label, this.current, this.previous);
}

/// Paired-period comparison ("vs last month"): per category, the previous
/// period as a muted bar behind the current period in primary. A delta chip
/// summarises the change.
class NeptuneCompareBars extends StatelessWidget {
  final List<NeptuneCompareData> data;
  final String currentLabel;
  final String previousLabel;
  final double height;

  const NeptuneCompareBars({
    super.key,
    required this.data,
    this.currentLabel = 'This month',
    this.previousLabel = 'Last month',
    this.height = 170,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final npt = Theme.of(context).extension<NptColors>()!;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    final maxV = data.fold<double>(
        0, (m, d) => [m, d.current, d.previous].reduce((a, b) => a > b ? a : b));
    final curSum = data.fold<double>(0, (m, d) => m + d.current);
    final prevSum = data.fold<double>(0, (m, d) => m + d.previous);
    final deltaPct =
        prevSum == 0 ? 0.0 : ((curSum - prevSum) / prevSum) * 100;
    final down = deltaPct <= 0;

    Widget legendDot(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label,
                style:
                    text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          legendDot(scheme.primary, currentLabel),
          const SizedBox(width: 14),
          legendDot(scheme.outlineVariant, previousLabel),
          const Spacer(),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: down
                  ? npt.successContainer
                  : scheme.errorContainer,
              borderRadius: BorderRadius.circular(shape.full),
            ),
            child: Text(
              '${down ? '−' : '+'}${deltaPct.abs().toStringAsFixed(1)}%',
              style: text.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: down
                    ? npt.onSuccessContainer
                    : scheme.onErrorContainer,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < data.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: height - 26,
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            // previous period — muted, slightly wider
                            FractionallySizedBox(
                              alignment: Alignment.bottomCenter,
                              heightFactor: maxV == 0
                                  ? 0
                                  : (data[i].previous / maxV)
                                      .clamp(0.02, 1.0),
                              child: Container(
                                margin: const EdgeInsetsDirectional
                                    .symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: scheme.outlineVariant,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(shape.xs)),
                                ),
                              ),
                            ),
                            // current period — primary, narrower on top
                            FractionallySizedBox(
                              alignment: Alignment.bottomCenter,
                              heightFactor: maxV == 0
                                  ? 0
                                  : (data[i].current / maxV)
                                      .clamp(0.02, 1.0),
                              child: Container(
                                margin: const EdgeInsetsDirectional
                                    .symmetric(horizontal: 9),
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(shape.xs)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
