// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// A transaction-like merchant row (web `<npt-merchant-row>`): a circular
/// merchant logo/avatar (or the name's initial), the merchant name + category,
/// and a trailing tabular amount + time. When [pending] the amount dims and a
/// "pending" pill appears. Theme-only, RTL-safe.
class NeptuneMerchantRow extends StatelessWidget {
  final String name;
  final String? category;
  final String amount;
  final String? time;
  final bool pending;
  final Widget? logo;

  const NeptuneMerchantRow({
    super.key,
    required this.name,
    this.category,
    required this.amount,
    this.time,
    this.pending = false,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;
    final amountColor = pending ? scheme.onSurfaceVariant : scheme.onSurface;
    final money = NeptuneTheme.moneyStyle(context, base: text.bodyLarge)
        .copyWith(color: amountColor, fontWeight: FontWeight.w600);
    final initial =
        name.trim().isEmpty ? '•' : name.trim().substring(0, 1).toUpperCase();

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          // Logo / avatar.
          ClipOval(
            child: Container(
              width: 44,
              height: 44,
              color: scheme.secondaryContainer,
              alignment: Alignment.center,
              child: logo ??
                  Text(
                    initial,
                    style: text.labelLarge?.copyWith(
                      fontFamily: type.display,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 16),
          // Name + category/pending.
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
                if (category != null || pending) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (category != null)
                        Flexible(
                          child: Text(
                            category!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      if (pending) ...[
                        if (category != null) const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 8, vertical: 1),
                          decoration: BoxDecoration(
                            color: scheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(shape.full),
                          ),
                          child: Text(
                            'pending',
                            style: text.labelSmall?.copyWith(
                              color: scheme.onTertiaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Trailing amount + time.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(amount, style: money),
              if (time != null) ...[
                const SizedBox(height: 2),
                Text(
                  time!,
                  style: NeptuneTheme.moneyStyle(context, base: text.labelSmall)
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// A reward/voucher coupon (web `<npt-voucher-card>`): a big tabular value stub
/// separated by a dashed tear line from the title, an optional dashed/mono code
/// chip, and an expiry caption. Painted on the primary container. Theme-only,
/// RTL-safe.
class NeptuneVoucherCard extends StatelessWidget {
  final String title;
  final String value;
  final String? code;
  final String? expiry;

  const NeptuneVoucherCard({
    super.key,
    required this.title,
    required this.value,
    this.code,
    this.expiry,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;
    final onContainer = scheme.onPrimaryContainer;
    final valueStyle =
        NeptuneTheme.moneyStyle(context, base: text.headlineSmall).copyWith(
      color: onContainer,
      fontWeight: FontWeight.w700,
    );

    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: shape.rLg,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsetsDirectional.all(20),
      child: IntrinsicHeight(
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Value stub with a dashed tear line on the inline-end edge.
          IntrinsicHeight(
            child: Container(
              padding: const EdgeInsetsDirectional.only(end: 16),
              decoration: BoxDecoration(
                border: BorderDirectional(
                  end: BorderSide(color: scheme.outline, width: 2),
                ),
              ),
              alignment: Alignment.center,
              child: Text(value, style: valueStyle),
            ),
          ),
          const SizedBox(width: 16),
          // Body: title, code chip, expiry.
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: text.titleMedium?.copyWith(
                    fontFamily: type.display,
                    fontWeight: FontWeight.w600,
                    color: onContainer,
                  ),
                ),
                if (code != null || expiry != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (code != null)
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: shape.rXs,
                          ),
                          child: Text(
                            code!,
                            style: NeptuneTheme.moneyStyle(context,
                                    base: text.labelLarge)
                                .copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      if (expiry != null)
                        Text(
                          expiry!,
                          style: text.bodySmall?.copyWith(
                            color: onContainer.withValues(alpha: 0.78),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// A scan-to-pay panel (web `<npt-qr-pay>`): a bordered QR placeholder sized
/// [size], an optional merchant caption, and a big tabular amount. Theme-only,
/// RTL-safe.
class NeptuneQrPay extends StatelessWidget {
  final String amount;
  final String? merchant;
  final double size;

  const NeptuneQrPay({
    super.key,
    required this.amount,
    this.merchant,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final money =
        NeptuneTheme.moneyStyle(context, base: text.displaySmall).copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w700,
    );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: shape.rXl,
      ),
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // QR placeholder.
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: shape.rMd,
              border: Border.all(color: scheme.outlineVariant, width: 2),
            ),
            child: Icon(
              Icons.qr_code_2,
              size: size * 0.7,
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (merchant != null) ...[
            const SizedBox(height: 20),
            Text(
              merchant!,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 8),
          Text(amount, style: money),
        ],
      ),
    );
  }
}

/// A selectable top-up option row (web `<npt-topup-row>`): a squared icon tile
/// slot, a label + optional sublabel, a trailing tabular amount, and a chevron
/// that mirrors in RTL. Theme-only, RTL-safe.
class NeptuneTopupRow extends StatelessWidget {
  final String label;
  final String? sublabel;
  final String amount;
  final VoidCallback? onTap;

  const NeptuneTopupRow({
    super.key,
    required this.label,
    this.sublabel,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: text.bodyLarge)
        .copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600);

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: shape.rMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon tile.
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: shape.rSm,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.add_card,
                  size: 24,
                  color: scheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              // Label + sublabel.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(color: scheme.onSurface),
                    ),
                    if (sublabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sublabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(amount, style: money),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: scheme.onSurfaceVariant,
                textDirection: Directionality.of(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The membership tier tones for [NeptuneTierBadge], mirroring the web
/// `tone` attribute (`gold`/`silver`/`primary`/`neutral`).
enum NeptuneTierTone { neutral, primary, gold, silver }

/// A small membership tier pill (web `<npt-tier-badge>`): a leading dot + the
/// tier label, coloured from the theme by [tone]. Theme-only, RTL-safe.
class NeptuneTierBadge extends StatelessWidget {
  final String tier;
  final String? tone;

  const NeptuneTierBadge({
    super.key,
    required this.tier,
    this.tone,
  });

  NeptuneTierTone get _tone => switch (tone?.toLowerCase()) {
        'primary' => NeptuneTierTone.primary,
        'gold' => NeptuneTierTone.gold,
        'silver' => NeptuneTierTone.silver,
        _ => NeptuneTierTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;

    final (Color bg, Color fg, Color? border) = switch (_tone) {
      NeptuneTierTone.primary => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          null,
        ),
      NeptuneTierTone.gold => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          null,
        ),
      NeptuneTierTone.silver => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
          null,
        ),
      NeptuneTierTone.neutral => (
          scheme.surfaceContainerHighest,
          scheme.onSurface,
          scheme.outlineVariant,
        ),
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(shape.full),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            tier,
            style: text.labelLarge?.copyWith(
              fontFamily: type.display,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.28,
            ),
          ),
        ],
      ),
    );
  }
}
