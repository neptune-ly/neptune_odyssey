// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// A horizontal progress stepper (web `<npt-stepper>`): numbered nodes joined by
/// connector lines, with a label under each. Done steps are filled
/// [ColorScheme.primary], the active step is outlined primary, and future steps
/// use [ColorScheme.outlineVariant]. Theme-only, RTL-safe.
class NeptuneStepper extends StatelessWidget {
  final List<String> steps;
  final int active;

  const NeptuneStepper({
    super.key,
    required this.steps,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;

    final children = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      final state = i < active
          ? _StepState.done
          : i == active
              ? _StepState.active
              : _StepState.upcoming;

      // Node colours by state.
      final Color fill;
      final Color border;
      final Color fg;
      switch (state) {
        case _StepState.done:
        case _StepState.active:
          fill = scheme.primary;
          border = scheme.primary;
          fg = scheme.onPrimary;
          break;
        case _StepState.upcoming:
          fill = scheme.surfaceContainerHighest;
          border = scheme.outlineVariant;
          fg = scheme.onSurfaceVariant;
          break;
      }
      // The active node reads as an outlined ring (primary outline, hollow fill).
      final isActive = state == _StepState.active;

      final node = Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? scheme.surface : fill,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 2),
        ),
        child: state == _StepState.done
            ? Icon(Icons.check, size: 18, color: fg)
            : Text(
                '${i + 1}',
                style: text.labelLarge?.copyWith(
                  fontFamily: type.num,
                  color: isActive ? scheme.primary : fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
      );

      final label = SizedBox(
        width: 80,
        child: Text(
          steps[i],
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: text.labelSmall?.copyWith(
            color: isActive ? scheme.onSurface : scheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      );

      children.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [node, const SizedBox(height: 8), label],
        ),
      );

      // Connector between this node and the next.
      if (i < steps.length - 1) {
        final done = i < active;
        children.add(
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsetsDirectional.only(top: 15, start: 4, end: 4),
              decoration: BoxDecoration(
                color: done ? scheme.primary : scheme.outlineVariant,
                borderRadius: shape.rXs,
              ),
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

enum _StepState { done, active, upcoming }

/// A transfer review card (web `<npt-transfer-review>`): a
/// [ColorScheme.surfaceContainer] card with key/value rows (From, To, Amount,
/// optional Fee) and a highlighted, bold [Total] rendered in the money style.
/// Theme-only, RTL-safe.
class NeptuneTransferReview extends StatelessWidget {
  final String fromLabel;
  final String toLabel;
  final String amount;
  final String? fee;
  final String? total;
  final String? currency;

  const NeptuneTransferReview({
    super.key,
    required this.fromLabel,
    required this.toLabel,
    required this.amount,
    this.fee,
    this.total,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final totalStyle = NeptuneTheme.moneyStyle(context, base: text.titleLarge)
        .copyWith(color: scheme.primary, fontWeight: FontWeight.w700);

    final rows = <Widget>[
      _ReviewRow(label: 'From', value: fromLabel),
      const SizedBox(height: 12),
      _ReviewRow(label: 'To', value: toLabel),
      const SizedBox(height: 12),
      _ReviewRow(label: 'Amount', value: amount, numeric: true),
      if (fee != null) ...[
        const SizedBox(height: 12),
        _ReviewRow(label: 'Fee', value: fee!, numeric: true),
      ],
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: shape.rLg,
      ),
      padding: const EdgeInsetsDirectional.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...rows,
          if (total != null) ...[
            const SizedBox(height: 16),
            Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    'Total',
                    style: text.labelLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          total!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: totalStyle,
                        ),
                      ),
                      if (currency != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          currency!,
                          style: text.bodyMedium?.copyWith(
                            color: scheme.primary.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One key/value line in a [NeptuneTransferReview]. Numeric values use the money
/// style for column-aligned figures.
class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool numeric;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final valueStyle = numeric
        ? NeptuneTheme.moneyStyle(context, base: text.bodyLarge)
            .copyWith(color: scheme.onSurface)
        : text.bodyLarge?.copyWith(color: scheme.onSurface);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}

/// A selectable payment-method row (web `<npt-method-row>`): a leading rounded
/// icon, a title with optional subtitle, and a trailing radio that fills with a
/// check when [selected]. The whole row is tappable and at least 48dp tall.
/// Theme-only, RTL-safe.
class NeptuneMethodRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  const NeptuneMethodRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: shape.rMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          decoration: BoxDecoration(
            borderRadius: shape.rMd,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: shape.rSm,
                ),
                child: Icon(icon, size: 20, color: scheme.onSecondaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _SelectIndicator(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

/// A trailing radio that fills [ColorScheme.primary] with a check when selected,
/// or shows an empty outlined circle when not.
class _SelectIndicator extends StatelessWidget {
  final bool selected;

  const _SelectIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? scheme.primary : null,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? scheme.primary : scheme.outline,
          width: 2,
        ),
      ),
      child: selected
          ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
          : null,
    );
  }
}

/// A selectable beneficiary tile (web `<npt-beneficiary-tile>`): a circular
/// avatar (provided [avatar] or generated initials), the [name], and a masked
/// [account] in tabular figures. When [selected] the tile lifts onto a
/// highlighted container with a primary ring. At least 48dp tall.
/// Theme-only, RTL-safe.
class NeptuneBeneficiaryTile extends StatelessWidget {
  final String name;
  final String? account;
  final Widget? avatar;
  final bool selected;
  final VoidCallback? onTap;

  const NeptuneBeneficiaryTile({
    super.key,
    required this.name,
    this.account,
    this.avatar,
    this.selected = false,
    this.onTap,
  });

  String _initials(String value) {
    final parts =
        value.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '•';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    final out = (first + last).toUpperCase();
    return out.isEmpty ? '•' : out;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;

    final accountStyle = NeptuneTheme.moneyStyle(context, base: text.bodyMedium)
        .copyWith(color: scheme.onSurfaceVariant);

    return Material(
      color: selected ? scheme.surfaceContainerHigh : scheme.surface,
      borderRadius: shape.rMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            borderRadius: shape.rMd,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: avatar ??
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _initials(name),
                        style: text.labelLarge?.copyWith(
                          fontFamily: type.display,
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(color: scheme.onSurface),
                    ),
                    if (account != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        account!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: accountStyle,
                      ),
                    ],
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 12),
                Icon(Icons.check_circle, size: 22, color: scheme.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
