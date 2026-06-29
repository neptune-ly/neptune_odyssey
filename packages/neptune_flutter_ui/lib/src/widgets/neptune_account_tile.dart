// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// A list tile for an account: avatar/icon, name + masked number, balance.
/// Theme-only, RTL-safe, 48dp-min target.
class NeptuneAccountTile extends StatelessWidget {
  final String name;
  final String maskedNumber;
  final String balance;
  final IconData icon;
  final VoidCallback? onTap;

  const NeptuneAccountTile({
    super.key,
    required this.name,
    required this.maskedNumber,
    required this.balance,
    this.icon = Icons.account_balance_wallet_outlined,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final textTheme = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: textTheme.titleMedium)
        .copyWith(color: scheme.onSurface);

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: shape.rMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: shape.rSm,
                  ),
                  alignment: AlignmentDirectional.center,
                  child: Icon(icon, color: scheme.onPrimaryContainer),
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
                        style: textTheme.titleSmall,
                      ),
                      Text(
                        maskedNumber,
                        style: textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    balance,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: money,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
