// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// One action in a [NeptuneCardControls] bar.
class _CardAction {
  final String action;
  final String label;
  final IconData icon;

  const _CardAction(this.action, this.label, this.icon);
}

const List<_CardAction> _kCardActions = [
  _CardAction('freeze', 'Freeze', Icons.ac_unit),
  _CardAction('limits', 'Limits', Icons.tune),
  _CardAction('details', 'Details', Icons.receipt_long),
  _CardAction('pin', 'PIN', Icons.dialpad),
];

/// A row of card-management toggles (web `<npt-card-controls>`): Freeze, Limits,
/// Details, PIN. Each press calls [onControl] with the action key
/// (`freeze` | `limits` | `details` | `pin`). [frozen] flips the first tile to
/// an active "Unfreeze" affordance. Theme-only, RTL-safe, ≥64dp.
class NeptuneCardControls extends StatelessWidget {
  final ValueChanged<String> onControl;
  final bool frozen;

  const NeptuneCardControls({
    super.key,
    required this.onControl,
    this.frozen = false,
  });

  @override
  Widget build(BuildContext context) {
    // Equal-height tiles regardless of the parent's (possibly unbounded) height:
    // CrossAxisAlignment.stretch on a Row needs a bounded height, so cap it with
    // IntrinsicHeight.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _kCardActions.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _button(context, _kCardActions[i])),
          ],
        ],
      ),
    );
  }

  Widget _button(BuildContext context, _CardAction a) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    final isFreeze = a.action == 'freeze';
    final pressed = isFreeze && frozen;
    final label = pressed ? 'Unfreeze' : a.label;
    final bg = pressed ? scheme.primaryContainer : scheme.surfaceContainerLow;
    final fg = pressed ? scheme.onPrimaryContainer : scheme.onSurface;
    final border = pressed
        ? BorderSide(color: scheme.primaryContainer)
        : BorderSide(color: scheme.outlineVariant);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: shape.rMd, side: border),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onControl(a.action),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(a.icon, size: 22, color: fg),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelMedium?.copyWith(color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A dashed "add a card" tile (web `<npt-add-card>`): a dashed-outline row with a
/// circular plus and a [label]. Calls [onTap] on press unless [disabled].
/// Theme-only, RTL-safe, ≥48dp.
class NeptuneAddCard extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool disabled;

  const NeptuneAddCard({
    super.key,
    this.label = 'Add card',
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    final tile = CustomPaint(
      painter: _DashedBorderPainter(color: scheme.outline, radius: shape.lg),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: shape.rLg,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 88),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '+',
                    style: text.titleLarge?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return disabled ? Opacity(opacity: 0.38, child: tile) : tile;
  }
}

/// Strokes a rounded-rect dashed border using the theme [color] and corner
/// [radius]. No colour literals — the colour is passed in from the widget.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  static const double dash = 6;
  static const double gap = 5;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
