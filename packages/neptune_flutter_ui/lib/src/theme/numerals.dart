// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The numerals lever (R6): whether digits render as Latin (0-9) or
// Eastern Arabic / Arabic-Indic (٠-٩). Independent of the `arabic` RTL flag —
// many Gulf/Libyan banking apps run an Arabic UI with Latin digits (and vice
// versa), so this is its own tenant choice, not implied by text direction.

import 'package:flutter/material.dart';

/// Which digit glyphs money/numeric text renders with.
enum NeptuneNumeralStyle {
  /// 0 1 2 3 4 5 6 7 8 9
  latin,

  /// ٠ ١ ٢ ٣ ٤ ٥ ٦ ٧ ٨ ٩ (U+0660-U+0669)
  easternArabic,
}

const List<String> _easternArabicDigits = [
  '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
];

/// Replace every ASCII digit in [input] with its Eastern Arabic / Arabic-Indic
/// counterpart. Non-digit characters (currency codes, separators, RTL marks)
/// pass through unchanged.
String toEasternArabicDigits(String input) {
  final buf = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x30 && rune <= 0x39) {
      buf.write(_easternArabicDigits[rune - 0x30]);
    } else {
      buf.writeCharCode(rune);
    }
  }
  return buf.toString();
}

/// The active numerals lever, read via
/// `Theme.of(context).extension<NptNumerals>()!.format(text)`.
@immutable
class NptNumerals extends ThemeExtension<NptNumerals> {
  final NeptuneNumeralStyle style;

  const NptNumerals(this.style);

  /// Apply the active lever to [input] — a no-op for
  /// [NeptuneNumeralStyle.latin].
  String format(String input) => style == NeptuneNumeralStyle.easternArabic
      ? toEasternArabicDigits(input)
      : input;

  @override
  NptNumerals copyWith({NeptuneNumeralStyle? style}) =>
      NptNumerals(style ?? this.style);

  @override
  NptNumerals lerp(ThemeExtension<NptNumerals>? other, double t) {
    if (other is! NptNumerals) return this;
    return t < 0.5 ? this : other;
  }
}
