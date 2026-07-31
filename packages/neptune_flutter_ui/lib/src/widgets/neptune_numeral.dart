import 'package:flutter/widgets.dart';

/// Text that always reads left-to-right, whatever the surrounding locale.
///
/// Account numbers, IBANs, card numbers, amounts and reference codes are
/// LTR sequences even in an Arabic UI. Rendered by a plain [Text] under an
/// RTL [Directionality] they visually reorder — a "12.500 LYD" can render as
/// "LYD 12.500", and an IBAN with spaced groups can shuffle its groups
/// outright. That is not a cosmetic issue on a banking surface: a customer
/// reading a reordered account number back to a teller reads the wrong one.
///
/// This widget forces only the *internal* text direction. Its position within
/// a Row/Column still follows the parent's direction, so RTL layouts stay
/// mirrored exactly as before — only the glyph order inside the value is
/// pinned.
///
/// For a value that must sit *inside* a translated sentence, use
/// [NeptuneNumeral.isolated] instead: a nested [Text] cannot fix ordering
/// that happens at the string level.
class NeptuneNumeral extends StatelessWidget {
  /// The already-formatted value ("1,250.000 LYD", "LY83 0270 …", "•••• 4821").
  final String value;

  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const NeptuneNumeral(
    this.value, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  /// Wraps [value] in Unicode isolate marks so it can be interpolated into a
  /// localized sentence without disturbing — or being disturbed by — the
  /// surrounding bidirectional text.
  ///
  /// Uses LRI (U+2066) … PDI (U+2069) rather than a bare LRM (U+200E): an
  /// isolate contains the run completely, so neighbouring digits or
  /// punctuation on either side cannot merge with it. LRM only nudges
  /// direction at a single point and still lets adjacent weak characters
  /// join the run — the failure mode that shows up with grouped IBANs and
  /// amounts followed by a currency word.
  static String isolated(String value) => '⁦$value⁩';

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      // The whole point. Position still comes from the parent's direction.
      textDirection: TextDirection.ltr,
    );
  }
}
