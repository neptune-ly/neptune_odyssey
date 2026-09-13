// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/accessibility.dart';
import '../theme/extensions.dart';
import '../theme/identity.dart';
import '../theme/neptune_theme.dart';
import 'neptune_icon_slot.dart';

/// A list tile for an account: avatar/icon, name + masked number, balance.
/// Theme-only, RTL-safe, 48dp-min target.
class NeptuneAccountTile extends StatelessWidget {
  final String name;
  final String maskedNumber;
  final String balance;

  /// The Material glyph in the leading tonal square. Ignored when [iconWidget]
  /// is supplied.
  final IconData? icon;

  /// A host-supplied mark rendered in the leading square instead of [icon] — a
  /// per-brand SVG, an [ImageIcon], a bank/account-product mark. White-label
  /// apps ship their own icon sets, so account rows never force Material glyphs
  /// on a brand.
  ///
  /// The widget is laid out in the same square the glyph would occupy and
  /// receives the [ColorScheme.onPrimaryContainer] tint through an [IconTheme] +
  /// [DefaultTextStyle] rather than a hard filter, so a multi-colour brand mark
  /// stays multi-colour. A monochrome SVG should inherit `currentColor` (i.e.
  /// read `IconTheme.of(context).color`).
  final Widget? iconWidget;

  final VoidCallback? onTap;

  /// The ISO code or symbol the [balance] is denominated in, when the visual
  /// string does not already carry it. Used only for the spoken form
  /// ("12,480.500 Libyan dinars"); nothing visible changes.
  final String? currency;

  /// Whether this row is the currently chosen account (account pickers).
  /// Spoken as "selected"; the visual is unchanged.
  final bool selected;

  const NeptuneAccountTile({
    super.key,
    required this.name,
    required this.maskedNumber,
    required this.balance,
    this.icon = Icons.account_balance_wallet_outlined,
    this.iconWidget,
    this.onTap,
    this.currency,
    this.selected = false,
  }) : assert(
          icon != null || iconWidget != null,
          'NeptuneAccountTile needs a glyph: pass `icon` (IconData) or `iconWidget`.',
        );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final textTheme = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: textTheme.titleMedium)
        .copyWith(color: scheme.onSurface);
    final strings = NeptuneAccessibility.of(context);

    // ONE stop per account: "Salary account, ending in 4 8 2 1, balance
    // 12,480.500 Libyan dinars, button". Without the merge a screen reader
    // walks three fragments and the balance is a bare digit string.
    final spoken = [
      name,
      NeptuneAccessibility.maskedNumber(context, maskedNumber),
      '${strings.balance} ${NeptuneAccessibility.money(context, balance, currency: currency)}',
    ].join(', ');

    // THE RULED REGISTER (`NptIdentity.ruledRegister`). A brand that draws
    // structure in lines gets the same row with no slab under it and a
    // hairline around it: the tone step is what makes a tile read as a card
    // floating on the page, and removing it is what makes it read as a row
    // ruled onto it. Everything else - the glyph, the measure, the tabular
    // balance at the end edge - is identical, so the two registers stay one
    // component rather than two.
    final ruled = Theme.of(context).extension<NptIdentity>()!.ruledRegister;

    // At large text the balance and the name cannot both hold a line: the row
    // is 44dp of glyph plus two gaps before either of them starts. So above
    // this step the balance moves UNDER the name column instead of competing
    // with it for the same line. `minHeight: 64` is a floor, so the row simply
    // grows.
    final stacked = MediaQuery.textScalerOf(context).scale(14) > 20;

    final balanceText = Text(
      balance,
      // No `maxLines`/`ellipsis`: a truncated account NAME is recoverable, a
      // truncated BALANCE is a different number on the screen that decides a
      // transfer. `1,000.000` must never render as `1,000.`.
      textAlign: stacked ? TextAlign.start : TextAlign.end,
      style: money,
    );

    return Material(
      color: ruled ? Colors.transparent : scheme.surfaceContainerLow,
      shape: ruled
          ? RoundedRectangleBorder(
              borderRadius: shape.rMd,
              side: BorderSide(color: scheme.outlineVariant),
            )
          : RoundedRectangleBorder(borderRadius: shape.rMd),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: onTap != null,
        selected: selected,
        label: spoken,
        excludeSemantics: true,
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
                    // A filled chip inside a ruled row is a second slab
                    // smuggled back in - and on this component the only one
                    // left, so it becomes the loudest object in the group.
                    color: ruled ? null : scheme.primaryContainer,
                    borderRadius: shape.rSm,
                    border: ruled
                        ? Border.all(color: scheme.outlineVariant)
                        : null,
                  ),
                  alignment: AlignmentDirectional.center,
                  child: NeptuneIconSlot(
                    icon: icon,
                    iconWidget: iconWidget,
                    color:
                        ruled ? scheme.primary : scheme.onPrimaryContainer,
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
                        style: textTheme.titleSmall,
                      ),
                      Text(
                        maskedNumber,
                        style: textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      if (stacked) ...[
                        const SizedBox(height: 4),
                        balanceText,
                      ],
                    ],
                  ),
                ),
                // The name column stays `Expanded` and the balance takes no
                // flex at all, so the balance is measured FIRST at its own
                // width and the name gets what is left. Before, both were flex
                // children of weight 1: they split the row down the middle and
                // the balance lost digits to a half it had no claim on.
                if (!stacked) ...[
                  const SizedBox(width: 12),
                  balanceText,
                ],
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
