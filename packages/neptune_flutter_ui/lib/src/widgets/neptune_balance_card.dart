// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// A primary account/balance card. Reads colour, shape and type from the active
/// theme only — no literals. RTL-safe.
class NeptuneBalanceCard extends StatelessWidget {
  final String label;
  final String amount;
  final String? caption;
  final Widget? trailing;
  final VoidCallback? onTap;

  const NeptuneBalanceCard({
    super.key,
    required this.label,
    required this.amount,
    this.caption,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final textTheme = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(
      context,
      base: textTheme.displaySmall,
    ).copyWith(color: scheme.onPrimaryContainer);

    return Material(
      color: scheme.primaryContainer,
      borderRadius: shape.rLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: textTheme.labelLarge
                          ?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 12),
              Text(amount, style: money),
              if (caption != null) ...[
                const SizedBox(height: 4),
                Text(
                  caption!,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
