// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// A single transaction line: leading glyph, title/subtitle, signed amount.
/// Credits use the `success` role; debits use `onSurface`. Theme-only, RTL-safe,
/// 48dp-min touch target.
class NeptuneTransactionRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String amount;
  final bool isCredit;
  final IconData icon;
  final VoidCallback? onTap;

  const NeptuneTransactionRow({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.isCredit = false,
    this.icon = Icons.swap_horiz,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final npt = Theme.of(context).extension<NptColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final amountColor = isCredit ? npt.success : scheme.onSurface;
    final money = NeptuneTheme.moneyStyle(context, base: textTheme.titleMedium)
        .copyWith(color: amountColor);

    return InkWell(
      onTap: onTap,
      borderRadius: shape.rSm,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: shape.rSm,
                ),
                alignment: AlignmentDirectional.center,
                child: Icon(icon, size: 20, color: scheme.onSecondaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(amount, style: money),
            ],
          ),
        ),
      ),
    );
  }
}
