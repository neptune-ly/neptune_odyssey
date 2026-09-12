// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/accessibility.dart';
import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';
import 'neptune_identity_surfaces.dart';

/// A primary account/balance card. Reads colour, shape and type from the active
/// theme only — no literals. RTL-safe.
///
/// [hero] promotes it to the dashboard hero treatment: the brand gradient
/// (`primary` → `tertiary`, 135°) under white/on-primary text, a larger radius
/// and a soft branded key-light — matching the web `npt-balance-card[hero]`.
class NeptuneBalanceCard extends StatelessWidget {
  final String label;
  final String amount;
  final String? caption;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool hero;

  /// The ISO code or symbol for the spoken amount when [amount] carries none.
  final String? currency;

  const NeptuneBalanceCard({
    super.key,
    required this.label,
    required this.amount,
    this.caption,
    this.trailing,
    this.onTap,
    this.hero = false,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final textTheme = Theme.of(context).textTheme;

    // Hero rides the brand gradient with on-primary text; the flat variant is a
    // tonal container. All colours come from the theme — no literals.
    final onColor = hero ? scheme.onPrimary : scheme.onPrimaryContainer;
    final radius = hero ? shape.rXl : shape.rLg;
    // Web hero amount rides display-md (45px); the flat variant stays smaller.
    final money = NeptuneTheme.moneyStyle(
      context,
      base: hero ? textTheme.displayMedium : textTheme.displaySmall,
    ).copyWith(color: onColor);

    final decoration = BoxDecoration(
      borderRadius: radius,
      color: hero ? null : scheme.primaryContainer,
      gradient: hero
          ? LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: <Color>[scheme.primary, scheme.tertiary],
            )
          : null,
      boxShadow: hero
          ? <BoxShadow>[
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.28),
                blurRadius: 28,
                spreadRadius: -12,
                offset: const Offset(0, 14),
              ),
            ]
          : null,
    );

    // The card announces as one live stop - "Available balance, 12,480.500
    // Libyan dinars, ending in 4 8 2 1" - and re-announces when the balance
    // changes under a refresh. [trailing] stays its own node (it is usually
    // a button the host owns).
    final spoken = [
      label,
      NeptuneAccessibility.money(context, amount, currency: currency),
      if (caption != null) NeptuneAccessibility.maskedNumber(context, caption!),
    ].join(', ');

    return DecoratedBox(
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Stack(
            children: [
              // The dashboard-hero treatment on the site etches the brand
              // motif over the gradient (templates layer `--npt-motif`).
              if (hero)
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: NeptuneMotifLayer(color: onColor, strength: 0.8),
                  ),
                ),
              Padding(
            padding: EdgeInsetsDirectional.all(hero ? 24 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        button: onTap != null,
                        liveRegion: true,
                        label: spoken,
                        excludeSemantics: true,
                        child: Text(
                          label,
                          style: textTheme.labelLarge?.copyWith(color: onColor),
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                SizedBox(height: hero ? 14 : 12),
                ExcludeSemantics(
                  child: Text(NeptuneTheme.formatDigits(context, amount),
                      style: money),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 6),
                  ExcludeSemantics(
                    child: Text(
                      caption!,
                      style: textTheme.bodySmall?.copyWith(
                        color: onColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
