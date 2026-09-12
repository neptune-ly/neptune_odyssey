// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/accessibility.dart';
import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';
import 'neptune_buttons.dart';

/// A centred success hero (web `<npt-success>`): a large success-coloured
/// circular check, a display-font title, an optional big amount in money style,
/// and an optional subtitle. Announced as one live stop - "success: Transfer
/// sent, 1,250.000 Libyan dinars, to Ahmed" - the moment it appears.
/// Theme-only, RTL-safe.
class NeptuneSuccess extends StatelessWidget {
  final String title;
  final String? amount;
  final String? subtitle;
  final IconData icon;

  /// The ISO code or symbol for the spoken amount when [amount] carries none.
  final String? currency;

  const NeptuneSuccess({
    super.key,
    required this.title,
    this.amount,
    this.subtitle,
    this.icon = Icons.check_circle,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final npt = Theme.of(context).extension<NptColors>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: text.displaySmall)
        .copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700);
    final strings = NeptuneAccessibility.of(context);

    final spoken = [
      '${strings.success}: $title',
      if (amount != null)
        NeptuneAccessibility.money(context, amount!, currency: currency),
      if (subtitle != null) subtitle!,
    ].join(', ');

    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Semantics(
        liveRegion: true,
        label: spoken,
        excludeSemantics: true,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: npt.successContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: npt.success),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text.headlineSmall?.copyWith(
              fontFamily: type.display,
              fontWeight: type.displayFontWeight,
              color: scheme.onSurface,
            ),
          ),
          if (amount != null) ...[
            const SizedBox(height: 12),
            Text(amount!, textAlign: TextAlign.center, style: money),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
        ),
      ),
    );
  }
}

/// A receipt card (web `<npt-receipt>`): a title, a list of label/value rows
/// (value right-aligned, amounts rendered in money style), a divider, and an
/// optional Share action. Each row is one spoken stop, "Fee: 1.500", never
/// a label and a value read as unrelated fragments. Theme-only, RTL-safe.
class NeptuneReceipt extends StatelessWidget {
  final String title;
  final List<({String label, String value})> rows;
  final VoidCallback? onShare;

  /// The Share button's label. Defaults to the host's word via
  /// [NeptuneA11yStrings.share].
  final String? shareLabel;

  const NeptuneReceipt({
    super.key,
    required this.title,
    required this.rows,
    this.onShare,
    this.shareLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: text.bodyLarge)
        .copyWith(color: scheme.onSurface);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: shape.rLg,
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsetsDirectional.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: text.titleLarge?.copyWith(
                fontFamily: type.display,
                fontWeight: type.displayFontWeight,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final row in rows)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 12),
              child: Semantics(
                label: '${row.label}: ${row.value}',
                excludeSemantics: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      row.label,
                      style: text.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        row.value,
                        textAlign: TextAlign.end,
                        style: money,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
          if (onShare != null) ...[
            const SizedBox(height: 16),
            NeptuneButton(
              label: shareLabel ?? NeptuneAccessibility.of(context).share,
              icon: Icons.ios_share,
              variant: NeptuneButtonStyle.tonal,
              onPressed: onShare,
            ),
          ],
        ],
      ),
    );
  }
}
