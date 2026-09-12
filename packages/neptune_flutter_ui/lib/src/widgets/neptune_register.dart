// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The REGISTER composition (2.25.0): what `dashboardHero: 'statement-ledger'`
// draws. A bank whose character is quiet and documentary does not carry a
// carousel of cards - it carries one figure set large, then grouped rows on
// hairlines, the way a passbook or a brokerage statement does. Every widget
// here is flat: no radius, no shadow, no fill except the group header's tint.
// Flutter-ahead: there is no `<npt-register>` web element yet.

import 'package:flutter/material.dart';

import '../theme/density.dart';
import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';
import 'neptune_identity_surfaces.dart';

/// A one-pixel rule in `outlineVariant` - the register's only divider. Web
/// counterpart: the `1px solid var(--md-sys-color-outline-variant)` rule every
/// list in `system.css` draws between rows.
class NeptuneHairline extends StatelessWidget {
  /// Inset from the start edge, so a rule can align with row content rather
  /// than the screen edge.
  final double indent;

  /// Inset from the end edge.
  final double endIndent;

  const NeptuneHairline({super.key, this.indent = 0, this.endIndent = 0});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: scheme.outlineVariant),
      ),
    );
  }
}

/// The register's figure: an eyebrow label, then the amount with its integer
/// part in the display face at `displaySmall` and the fraction stepped down to
/// `headlineSmall` in `onSurfaceVariant` - the eye lands on the dinars, the
/// dirhams are there when wanted. Tabular figures throughout
/// ([NeptuneTheme.moneyStyle]), and the figure is always laid out LTR so the
/// fraction stays on the same side under RTL.
///
/// [amount] is the pre-formatted string the host already shows elsewhere
/// (`1,234.500`). The fraction is split at the last `.` only when everything
/// after it is digits; any other shape renders whole, which is what a masked
/// or non-decimal amount should do.
class NeptuneLedgerFigure extends StatelessWidget {
  /// The eyebrow above the figure (`Available balance`, `Total`).
  final String label;

  /// The amount, pre-formatted.
  final String amount;

  /// Currency code set after the figure at `labelLarge` (`LYD`).
  final String? currency;

  /// A slot after the figure on the same line - a visibility toggle, say.
  final Widget? trailing;

  const NeptuneLedgerFigure({
    super.key,
    required this.label,
    required this.amount,
    this.currency,
    this.trailing,
  });

  /// Splits `1,234.500` into (`1,234`, `.500`); anything else is (amount, null).
  static (String, String?) splitFraction(String amount) {
    final dot = amount.lastIndexOf('.');
    if (dot <= 0 || dot == amount.length - 1) return (amount, null);
    final fraction = amount.substring(dot + 1);
    final digitsOnly = RegExp(r'^[0-9٠-٩]+$').hasMatch(fraction);
    if (!digitsOnly) return (amount, null);
    return (amount.substring(0, dot), amount.substring(dot));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final type = theme.extension<NptType>()!;
    final text = theme.textTheme;
    final (whole, fraction) = splitFraction(amount);

    final wholeStyle = NeptuneTheme.moneyStyle(context, base: text.displaySmall)
        .copyWith(
      fontWeight: type.displayFontWeight,
      color: scheme.onSurface,
      height: 1,
    );
    final fractionStyle =
        NeptuneTheme.moneyStyle(context, base: text.headlineSmall).copyWith(
      fontWeight: type.displayFontWeight,
      color: scheme.onSurfaceVariant,
      height: 1,
    );
    final currencyStyle = (text.labelLarge ?? const TextStyle()).copyWith(
      color: scheme.onSurfaceVariant,
      letterSpacing: 0.08 * (text.labelLarge?.fontSize ?? 14),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        NeptuneEyebrow(label),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: whole, style: wholeStyle),
                      if (fraction != null)
                        TextSpan(text: fraction, style: fractionStyle),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                  ),
                ),
              ),
            ),
            if (currency != null) ...[
              const SizedBox(width: 8),
              Text(currency!.toUpperCase(), style: currencyStyle),
            ],
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing!,
            ],
          ],
        ),
      ],
    );
  }
}

/// The tinted band that opens a register group: an eyebrow at the start
/// (`Current`, `LYD`) and an optional tabular figure at the end (the group's
/// subtotal). `surfaceContainerLow` fill, no radius - it is a band across the
/// page, not a chip.
class NeptuneRegisterGroupHeader extends StatelessWidget {
  final String title;

  /// A figure set at the end edge in `labelLarge` tabular - the subtotal.
  final String? figure;

  const NeptuneRegisterGroupHeader({super.key, required this.title, this.figure});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final money = NeptuneTheme.moneyStyle(context, base: theme.textTheme.labelLarge)
        .copyWith(color: scheme.onSurfaceVariant);
    return ColoredBox(
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(child: NeptuneEyebrow(title)),
            if (figure != null) ...[
              const SizedBox(width: 12),
              Text(figure!, style: money, textDirection: TextDirection.ltr),
            ],
          ],
        ),
      ),
    );
  }
}

/// One register row: a title with an optional subtitle at the start, a
/// tabular [figure] at the end, and nothing else - no avatar square, no
/// chevron. 48dp minimum, tappable via [onTap]. A [leading] slot exists for a
/// mark that MEANS something (a frozen-account glyph); it is not for
/// decoration.
class NeptuneRegisterRow extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// The figure at the end edge, `titleMedium` tabular in [figureColor]
  /// (default `onSurface`).
  final String? figure;
  final Color? figureColor;

  /// A meaningful mark before the figure.
  final Widget? leading;

  final VoidCallback? onTap;

  const NeptuneRegisterRow({
    super.key,
    required this.title,
    this.subtitle,
    this.figure,
    this.figureColor,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final density = theme.extension<NptDensity>() ?? const NptDensity(1);
    final money = NeptuneTheme.moneyStyle(context, base: text.titleMedium)
        .copyWith(color: figureColor ?? scheme.onSurface);

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: density.s(56)),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: density.s(12)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: text.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: NeptuneTheme.moneyStyle(context,
                                base: text.bodySmall)
                            .copyWith(color: scheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (leading != null) ...[
                const SizedBox(width: 8),
                leading!,
              ],
              if (figure != null) ...[
                const SizedBox(width: 12),
                Text(figure!, style: money, textDirection: TextDirection.ltr),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A register group: its [header] band, then [rows] separated by hairlines,
/// closed by a hairline. Rows are usually [NeptuneRegisterRow]s but any
/// widget fits - the group only supplies the rhythm.
class NeptuneRegisterGroup extends StatelessWidget {
  final NeptuneRegisterGroupHeader header;
  final List<Widget> rows;

  /// Start inset of the hairlines between rows, so the rule starts where the
  /// row text starts.
  final double ruleIndent;

  const NeptuneRegisterGroup({
    super.key,
    required this.header,
    required this.rows,
    this.ruleIndent = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        for (var i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i < rows.length - 1) NeptuneHairline(indent: ruleIndent),
        ],
        const NeptuneHairline(),
      ],
    );
  }
}

/// One line of a review ledger (a transfer's confirm step): the [label] at
/// the start in `onSurfaceVariant`, the [value] at the end in `onSurface`.
/// A value that is a figure passes [tabular] so its digits align with the
/// lines above and below; a long value (a reference) wraps at the end edge
/// rather than truncating.
class NeptuneLedgerLine extends StatelessWidget {
  final String label;
  final String value;
  final bool tabular;

  /// Forces the value LTR (references, IBANs) regardless of the ambient
  /// direction.
  final bool valueLtr;

  const NeptuneLedgerLine({
    super.key,
    required this.label,
    required this.value,
    this.tabular = false,
    this.valueLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final base = (text.bodyLarge ?? const TextStyle()).copyWith(
      color: scheme.onSurface,
    );
    final valueStyle =
        tabular ? NeptuneTheme.moneyStyle(context, base: base) : base;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.end,
              textDirection: valueLtr ? TextDirection.ltr : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// A review ledger: [lines] on hairlines, optionally opened by a
/// [NeptuneLedgerFigure] so the amount being confirmed is the first and
/// largest thing on the page.
class NeptuneLedger extends StatelessWidget {
  final NeptuneLedgerFigure? figure;
  final List<Widget> lines;

  const NeptuneLedger({super.key, this.figure, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (figure != null) ...[
          figure!,
          const SizedBox(height: 20),
          const NeptuneHairline(),
        ],
        for (var i = 0; i < lines.length; i++) ...[
          lines[i],
          const NeptuneHairline(),
        ],
      ],
    );
  }
}
