// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// A single quick action: a circular tonal icon chip above a short label.
///
/// Mirrors the web `<npt-quick-action>` tonal treatment — a
/// [ColorScheme.secondaryContainer] chip with an
/// [ColorScheme.onSecondaryContainer] icon, captioned by a
/// [TextTheme.labelMedium] label in [ColorScheme.onSurfaceVariant].
/// Theme-only (no literal colours/radii/fonts), RTL-safe, 48dp-min target.
class NeptuneQuickAction extends StatelessWidget {
  /// The glyph shown inside the circular chip.
  final IconData icon;

  /// The caption shown beneath the chip.
  final String label;

  /// Invoked when the action is tapped. When null the action is inert.
  final VoidCallback? onTap;

  const NeptuneQuickAction({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final textTheme = Theme.of(context).textTheme;

    final chipRadius = BorderRadius.circular(shape.full);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: scheme.secondaryContainer,
          borderRadius: chipRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(borderRadius: chipRadius),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(icon, color: scheme.onSecondaryContainer),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// A row of evenly-spaced [NeptuneQuickAction]s.
///
/// Mirrors the web `<npt-quick-actions>` — actions are laid out in equal,
/// top-aligned [Expanded] cells so they share the available width. When more
/// actions than [columns] are supplied they wrap onto further rows. Theme-only,
/// RTL-safe (logical layout mirrors automatically).
class NeptuneQuickActions extends StatelessWidget {
  /// The actions to display.
  final List<NeptuneQuickAction> actions;

  /// The number of actions per row before wrapping. Defaults to 4.
  final int columns;

  const NeptuneQuickActions({
    super.key,
    required this.actions,
    this.columns = 4,
  });

  @override
  Widget build(BuildContext context) {
    final perRow = columns < 1 ? 1 : columns;

    final rows = <Widget>[];
    for (var start = 0; start < actions.length; start += perRow) {
      final end =
          (start + perRow) < actions.length ? start + perRow : actions.length;
      final slice = actions.sublist(start, end);

      final cells = <Widget>[
        for (final action in slice) Expanded(child: action),
        // Pad the final row so trailing cells keep their natural width.
        for (var i = slice.length; i < perRow; i++)
          const Expanded(child: SizedBox.shrink()),
      ];

      if (rows.isNotEmpty) rows.add(const SizedBox(height: 16));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cells,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}
