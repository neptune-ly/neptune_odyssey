// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/extensions.dart';

/// An IBAN, or any account number, in groups of four: `LY87 0271 0110 1907 0915
/// 0101 5`. Whitespace in [raw] is ignored and the letters are upper-case.
String groupedAccountNumber(String raw) {
  final compact = raw.replaceAll(RegExp(r'\s'), '').toUpperCase();
  return [
    for (var i = 0; i < compact.length; i += 4)
      compact.substring(i, math.min(i + 4, compact.length)),
  ].join(' ');
}

/// The number with its middle hidden: the first four characters (country and
/// check digits of an IBAN), three fixed groups of dots, the last four. How
/// much is hidden is not shown either, so every number masks to the same width.
String maskedAccountNumber(String raw) {
  final compact = raw.replaceAll(RegExp(r'\s'), '');
  if (compact.length <= 8) return '••••';
  return '${compact.substring(0, 4)} •••• •••• •••• '
      '${compact.substring(compact.length - 4)}';
}

/// The one way to show an account number or IBAN, and to copy it (web
/// `<npt-account-number>`).
///
/// Grouped in fours, in Western digits and as ONE left-to-right run, so an
/// Arabic page cannot reorder it. Body large and semibold with tabular figures,
/// never below 16sp, wrapping at a group boundary before it would ever be
/// clipped. The whole row is one 48dp target: a tap or a long press puts the
/// RAW, unspaced value on the clipboard and calls [onCopied] - the host's
/// haptic and "copied" toast, because the library owns no strings.
///
/// [masked] follows the balance-visibility toggle: the value is drawn hidden.
/// A tap still copies, because copying is something the customer asks for.
///
/// A number the app must not hand out - a card number it never holds whole - is
/// not copyable: pass [copyable] false, and the row has no copy mark and a tap
/// does nothing but call [onTap]. Draw the value masked yourself and pass it
/// as [value]; it is grouped, not re-masked.
class NeptuneAccountNumber extends StatelessWidget {
  /// The account number or IBAN, raw or already grouped.
  final String value;

  /// Draw it hidden (see [maskedAccountNumber]). The copy still yields [value].
  final bool masked;

  /// Whether a tap copies [value]. False: no copy mark, nothing is copied.
  final bool copyable;

  /// "IBAN", above the number at label size, and spoken before it.
  final String? label;

  /// The spoken name of the copy action ("copy"). The host's language.
  final String copyLabel;

  /// What a screen reader says for a [masked] number ("hidden"). Null speaks
  /// the label alone, so no digit is ever read out of a hidden number.
  final String? hiddenLabel;

  /// Called after [value] was copied, for the host's haptic and toast.
  final VoidCallback? onCopied;

  /// Called on a tap when [copyable] is false, so the host can say why.
  final VoidCallback? onTap;

  /// The copy mark. Null is the Material copy glyph.
  final Widget? copyIcon;

  /// The number's ink and the copy mark's. Null is the page's `onSurface`.
  final Color? color;

  /// The label's ink. Null is `onSurfaceVariant`.
  final Color? labelColor;

  /// A base style; the size is held to [minSize] or more and the weight to
  /// semibold.
  final TextStyle? style;

  /// The smallest size an account number is drawn at, before the customer's own
  /// text scale.
  static const double minSize = 16;

  const NeptuneAccountNumber({
    super.key,
    required this.value,
    required this.copyLabel,
    this.masked = false,
    this.copyable = true,
    this.label,
    this.hiddenLabel,
    this.onCopied,
    this.onTap,
    this.copyIcon,
    this.color,
    this.labelColor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = color ?? scheme.onSurface;
    final quiet = labelColor ?? scheme.onSurfaceVariant;
    final raw = value.replaceAll(RegExp(r'\s'), '');
    final canCopy = copyable && raw.isNotEmpty;
    final shown = masked ? maskedAccountNumber(raw) : groupedAccountNumber(raw);
    final base = style ?? theme.textTheme.bodyLarge;
    final numberStyle = (base ?? const TextStyle()).copyWith(
      fontSize: math.max(base?.fontSize ?? minSize, minSize),
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: 0.4,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    void press() {
      if (!canCopy) return onTap?.call();
      Clipboard.setData(ClipboardData(text: raw));
      onCopied?.call();
    }

    // Digits are spoken one at a time, a group at a time: "L Y 8 7, 0 2 7 1".
    final spokenNumber = masked
        ? hiddenLabel
        : groupedAccountNumber(raw)
            .split(' ')
            .map((group) => group.split('').join(' '))
            .join(', ');

    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      onTap: press,
      onLongPress: canCopy ? press : null,
      label: [
        if (label != null) label!,
        if (spokenNumber != null) spokenNumber,
        if (canCopy) copyLabel,
      ].join(', '),
      child: InkWell(
        onTap: press,
        onLongPress: canCopy ? press : null,
        borderRadius: theme.extension<NptShape>()!.rSm,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label != null)
                      Text(label!,
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: quiet)),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(shown,
                            softWrap: true,
                            textAlign: TextAlign.start,
                            style: numberStyle),
                      ),
                    ),
                  ],
                ),
              ),
              if (canCopy) ...[
                const SizedBox(width: 8),
                IconTheme(
                  data: IconThemeData(size: 24, color: quiet),
                  child: copyIcon ?? const Icon(Icons.copy_outlined),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
