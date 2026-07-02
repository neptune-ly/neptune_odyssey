// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/identity.dart';
import '../theme/neptune_theme.dart';
import 'neptune_identity_surfaces.dart';

/// A payment-card visual — the Flutter counterpart of web `<npt-card-art>`.
///
/// Renders a 1.586 aspect-ratio card on the brand gradient (`scheme.primary` →
/// `scheme.tertiary`; [virtual] flips the order). The top row shows the
/// [scheme] label (display font) and an optional [brandMark] in the
/// top-trailing corner; the bottom shows a masked number ending in [last4],
/// then the [holder] and [expiry]. When [selected], an accent ring + glow lift
/// the card out of a stack. Reads colour, shape and type from the active theme
/// only — no literals. RTL-safe.
class NeptuneCardArt extends StatelessWidget {
  /// Cardholder name, e.g. "A. KELLER".
  final String holder;

  /// The last four digits of the card number, e.g. "4821".
  final String last4;

  /// Expiry label, e.g. "08/29".
  final String? expiry;

  /// Scheme label, e.g. "VISA". Shown uppercase in the display font.
  final String? scheme;

  /// When true, the gradient runs tertiary → primary (a virtual-card accent).
  final bool virtual;

  /// When true, draws an accent ring + glow to mark the chosen card.
  final bool selected;

  /// Optional brand mark, placed in the top-trailing corner.
  final Widget? brandMark;

  /// Tap handler; when non-null the whole card becomes an [InkWell].
  final VoidCallback? onTap;

  const NeptuneCardArt({
    super.key,
    required this.holder,
    required this.last4,
    this.expiry,
    this.scheme,
    this.virtual = false,
    this.selected = false,
    this.brandMark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final textTheme = Theme.of(context).textTheme;
    final onCard = scheme.onPrimary;

    // Gradient runs primary → tertiary (135°); virtual cards flip the order.
    final gradientColors = virtual
        ? <Color>[scheme.tertiary, scheme.primary]
        : <Color>[scheme.primary, scheme.tertiary];

    // The masked number: 12 dots + the real last four (tabular figures).
    final numberStyle = NeptuneTheme.moneyStyle(
      context,
      base: textTheme.titleMedium,
    ).copyWith(color: onCard, letterSpacing: 3);

    final schemeStyle = textTheme.labelLarge?.copyWith(
      color: onCard.withValues(alpha: 0.92),
      fontFamily: type.display,
      fontWeight: type.displayFontWeight,
      letterSpacing: 1.2,
    );

    final identity = Theme.of(context).extension<NptIdentity>()!;

    final card = AspectRatio(
      aspectRatio: 1.586,
      child: DecoratedBox(
        // Elevation-2 at rest (web box-shadow) — outside the ink clip.
        decoration: BoxDecoration(
          borderRadius: shape.rLg,
          boxShadow: identity.elevation2(scheme),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: shape.rLg,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: shape.rLg,
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: gradientColors,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  // The brand's signature motif, embossed over the gradient —
                  // the web layers `--npt-motif` on card art at full strength.
                  Positioned.fill(
                    child: NeptuneMotifLayer(color: onCard, strength: 1),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top row: scheme label + brand mark (top-trailing).
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                this.scheme?.toUpperCase() ?? '',
                                style: schemeStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (brandMark != null) ...[
                              const SizedBox(width: 16),
                              IconTheme.merge(
                                data: IconThemeData(color: onCard),
                                child: DefaultTextStyle.merge(
                                  style: TextStyle(color: onCard),
                                  child: brandMark!,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Masked card number.
                        Text(
                          '•••• •••• •••• $last4',
                          style: numberStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Bottom row: holder + expiry block.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                holder.toUpperCase(),
                                style: textTheme.labelMedium?.copyWith(
                                  color: onCard,
                                  letterSpacing: 0.6,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (expiry != null) ...[
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Expires',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: onCard.withValues(alpha: 0.85),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    expiry!,
                                    style: NeptuneTheme.moneyStyle(
                                      context,
                                      base: textTheme.labelLarge,
                                    ).copyWith(color: onCard),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!selected) return card;

    // Selected: an accent ring sits *outside* the card (outer padding) plus a
    // glow that lifts the chosen card out of a stack.
    final ringRadius = BorderRadius.circular(shape.lg + 3);
    return Container(
      padding: const EdgeInsetsDirectional.all(3),
      decoration: BoxDecoration(
        borderRadius: ringRadius,
        border: Border.all(color: scheme.primary, width: 3),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: card,
    );
  }
}
