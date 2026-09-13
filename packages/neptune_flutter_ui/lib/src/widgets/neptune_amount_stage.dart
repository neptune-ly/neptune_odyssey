// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';
import '../theme/accessibility.dart';
import '../theme/feedback.dart';
import '../theme/extensions.dart';
import '../theme/numerals.dart';

/// THE AMOUNT AS THE SCREEN, rather than a field on a form.
///
/// Everywhere else in a banking app an amount is a value inside a labelled
/// input: a box, a ring, a prefix, a helper line. That is right when the amount
/// is one of eight things the customer is filling in. It is wrong when the
/// amount is the ONLY thing, because every one of those parts is chrome
/// explaining a control that needs no explanation — a number the size of a fist
/// with a keypad under it is already self-evident.
///
/// So there is no container here, and that is the design: no box, no
/// underline, no fill, no placeholder ring. The amount is type on the ground.
/// [NeptuneAmountStage] is the number; [NeptuneStageKeypad] is what changes it.
///
/// IT SHRINKS RATHER THAN SCROLLS OR CLIPS. A customer typing a large figure
/// must never see their own number truncated or run under the edge of the
/// screen, so the type size steps down as digits arrive. It steps rather than
/// scales continuously because a continuously-scaling numeral has a different
/// stroke weight at every size, and money that gets visibly lighter as it gets
/// larger reads as a rendering fault.
class NeptuneAmountStage extends StatelessWidget {
  /// The amount as the customer has typed it — digits and at most one decimal
  /// separator. The host owns the string; this widget never edits it.
  final String value;

  /// Shown at full size beside the amount. A currency's short form, never a
  /// symbol scaled down and raised: a superscripted currency reads as a
  /// footnote marker, and this one is part of the figure.
  final String currency;

  /// Drawn in place of [value] when it is empty. Defaults to "0".
  final String placeholder;

  /// The ink. Defaults to the nearest [DefaultTextStyle] colour, so a stage on
  /// the brand canvas inherits the canvas's on-colour without being told.
  final Color? color;

  /// Ink for [placeholder] and for the currency when nothing is typed.
  /// Defaults to [color] at 40%.
  final Color? mutedColor;

  /// A line under the figure — an available balance, a fee, a conversion. It
  /// is a slot and not a fixture: a host with nothing to say passes null and
  /// the stage does not reserve an empty line for symmetry.
  final Widget? footnote;

  /// Overrides the largest size. The scale steps down from here.
  final double maxFontSize;

  /// The thousands separator drawn between groups of the integer part. Pass
  /// the locale's; null switches grouping off for a currency that is not
  /// grouped.
  final String? groupSeparator;

  const NeptuneAmountStage({
    super.key,
    required this.value,
    required this.currency,
    this.placeholder = '0',
    this.color,
    this.mutedColor,
    this.footnote,
    this.maxFontSize = 84,
    this.groupSeparator = ',',
  });

  /// The integer part in groups of three, the decimal part untouched.
  ///
  /// GROUPED AS IT IS TYPED, not at the end. An ungrouped seven-digit figure
  /// is the one number on this screen a customer cannot check at a glance, and
  /// "is that two hundred thousand or two million" is a question they should
  /// never have to count digits to answer. It is a DISPLAY transform only: the
  /// host's value is untouched, so what the rail form receives is still plain
  /// digits and nothing downstream has to strip a separator out again.
  String _grouped(String raw) {
    final sep = groupSeparator;
    if (sep == null) return raw;
    final dot = raw.indexOf('.');
    final whole = dot < 0 ? raw : raw.substring(0, dot);
    final rest = dot < 0 ? '' : raw.substring(dot);
    if (whole.length <= 3) return raw;
    final buf = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buf.write(sep);
      buf.write(whole[i]);
    }
    return '$buf$rest';
  }

  /// The step-down ladder. Chosen so a 9-digit figure with a currency still
  /// fits the narrowest phone this app supports at the largest Dynamic Type
  /// setting; beyond that the ladder holds and [FittedBox] takes over, which is
  /// the one place a continuous scale is the lesser evil.
  double _sizeFor(int digits) {
    if (digits <= 4) return maxFontSize;
    if (digits <= 6) return maxFontSize * 0.82;
    if (digits <= 8) return maxFontSize * 0.66;
    return maxFontSize * 0.54;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = theme.extension<NptType>();
    final numerals = theme.extension<NptNumerals>();
    final typed = value.isNotEmpty;
    final shown = typed ? value : placeholder;
    final ink = color ?? DefaultTextStyle.of(context).style.color ?? theme.colorScheme.onSurface;
    final muted = mutedColor ?? ink.withValues(alpha: 0.4);

    final size = _sizeFor(shown.replaceAll(RegExp(r'[^0-9]'), '').length);

    final figure = TextStyle(
      fontFamily: type?.num,
      fontSize: size,
      height: 1.0,
      fontWeight: FontWeight.w700,
      // Negative tracking at display size, and ONLY at display size. A figure
      // set this large has too much air between the numerals at default
      // tracking; the same tracking on a 14dp row would close the counters up.
      letterSpacing: size * -0.025,
      color: typed ? ink : muted,
      // Tabular figures, so the number does not jitter sideways as the
      // customer types: proportional digits change the whole string's width
      // every time a 1 becomes a 4.
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final currencyStyle = figure.copyWith(
      fontSize: size * 0.44,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: muted,
    );

    return Semantics(
      // Spoken as money in the host's language — "one hundred and twenty
      // Libyan dinars" — while the visual stays a tabular figure.
      label: NeptuneAccessibility.money(
          context, typed ? value : '0', currency: currency),
      liveRegion: true,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textBaseline: TextBaseline.alphabetic,
              // The currency sits on the FIGURE'S baseline, not centred
              // against its box: an optically centred currency floats above
              // the numerals' feet and reads as a superscript.
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(numerals?.format(_grouped(shown)) ?? _grouped(shown),
                    style: figure),
                const SizedBox(width: 10),
                Text(currency, style: currencyStyle),
              ],
            ),
          ),
          if (footnote != null) ...[
            const SizedBox(height: 14),
            DefaultTextStyle.merge(
              style: TextStyle(color: muted, fontSize: 14, height: 1.3),
              textAlign: TextAlign.center,
              child: footnote!,
            ),
          ],
        ],
      ),
    );
  }
}

/// The STAGE's keypad: digits on the screen's own ground, and nothing else.
///
/// THERE ARE NOW TWO KEYPADS AND THE DIFFERENCE IS MEANING, NOT TASTE.
/// [NeptuneAmountKeypad] is the one with drawn keys — tinted tiles at the
/// brand's corner, spaced on a grid. It is right when the amount is a VALUE ON
/// A FORM: one field among several, with a source row above it and a label
/// beside it, where the pad has to announce itself as the thing that edits
/// that particular field. This one is right when the amount IS the screen,
/// which is the composition [NeptuneAmountStage] exists for. A host that shows
/// both on one surface has made a mistake somewhere above this line.
///
/// NO KEYS. There are no key backgrounds, no separators, no borders and no
/// grid lines — a 3x4 arrangement of numerals IS a keypad, and every part
/// drawn around them is a part a customer has to look past. This is the
/// strongest restraint move in the composition and also the riskiest, so the
/// two things a drawn key really provides are provided another way: the target
/// is the full cell rather than the glyph (56dp minimum in both axes, well
/// clear of the 44pt floor), and the press is confirmed by a tonal disc that
/// blooms under the thumb plus the brand's own haptic weight.
///
/// The layout is LOGICAL, NOT MIRRORED. Under RTL the columns stay 1-2-3 left
/// to right, because a keypad is a physical object a customer has muscle memory
/// for — a phone, a calculator, an ATM — and no Arabic keypad in the world
/// mirrors. The BACKSPACE does mirror, because it is an arrow and an arrow
/// points against the reading direction.
class NeptuneStageKeypad extends StatelessWidget {
  /// A digit was pressed. The host appends it; the keypad holds no value.
  final ValueChanged<String> onDigit;

  /// The decimal separator was pressed. Null hides that key and leaves the
  /// cell empty, for a currency with no minor unit.
  final VoidCallback? onDecimal;

  /// Backspace. A long press clears the whole amount — see [onClear].
  final VoidCallback onBackspace;

  /// Long-press-to-clear. Null leaves the long press inert rather than
  /// repeating the backspace, because a customer who holds a key expecting
  /// "clear" and gets "delete 30 characters" has lost their amount either way
  /// and only one of those is recoverable by releasing.
  final VoidCallback? onClear;

  /// The separator glyph. The host passes its locale's — "." or "٫".
  final String decimalGlyph;

  /// Ink for the glyphs. Defaults to the ambient [DefaultTextStyle] colour.
  final Color? color;

  const NeptuneStageKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onDecimal,
    this.onClear,
    this.decimalGlyph = '.',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = theme.extension<NptType>();
    final numerals = theme.extension<NptNumerals>();
    final strings = NeptuneAccessibility.of(context);
    final ink = color ?? DefaultTextStyle.of(context).style.color ?? theme.colorScheme.onSurface;

    Widget cell(Widget child, {VoidCallback? onTap, VoidCallback? onLongPress, String? label}) =>
        Expanded(
          child: _KeypadCell(
            ink: ink,
            onTap: onTap,
            onLongPress: onLongPress,
            semanticLabel: label,
            child: child,
          ),
        );

    Widget digit(String d) {
      final glyph = numerals?.format(d) ?? d;
      return cell(
        Text(
          glyph,
          style: TextStyle(
            fontFamily: type?.num,
            fontSize: 30,
            // Body weight, deliberately. A keypad digit is not a heading: the
            // AMOUNT is the heavy figure on this screen and the pad under it
            // is the quiet one, which is also what keeps a pad drawn with no
            // keys from reading as twelve competing headlines.
            fontWeight: FontWeight.w400,
            color: ink,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        onTap: () => onDigit(d),
        label: glyph,
      );
    }

    Widget row(List<Widget> children) => Expanded(
          child: Row(children: children),
        );

    return Directionality(
      // The GRID is pinned to LTR so 1-2-3 reads left to right in every
      // locale; the glyphs inside the cells keep the ambient direction
      // through their own Directionality below, and the backspace arrow is
      // mirrored explicitly.
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          row([digit('1'), digit('2'), digit('3')]),
          row([digit('4'), digit('5'), digit('6')]),
          row([digit('7'), digit('8'), digit('9')]),
          row([
            if (onDecimal != null)
              cell(
                Text(
                  decimalGlyph,
                  style: TextStyle(
                      fontFamily: type?.num,
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: ink),
                ),
                onTap: onDecimal,
                label: strings.decimalPoint,
              )
            else
              const Expanded(child: SizedBox.shrink()),
            digit('0'),
            cell(
              // THE ONE MIRRORED GLYPH ON THE PAD, and it has to be mirrored by
              // hand. Backspace means "back along the line of text", which in
              // Arabic is the other way round - and `Icons.backspace_outlined`
              // declares `matchTextDirection: false`, so wrapping it in a
              // `Directionality` does exactly nothing. That was the first
              // version of this and the glyph pointed the wrong way in every
              // Arabic build while a comment above it claimed otherwise.
              Transform.scale(
                scaleX: Directionality.of(context) == TextDirection.rtl ? -1 : 1,
                child: Icon(Icons.backspace_outlined, size: 26, color: ink),
              ),
              onTap: onBackspace,
              onLongPress: onClear,
              label: strings.backspace,
            ),
          ]),
        ],
      ),
    );
  }
}

class _KeypadCell extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final Color ink;

  const _KeypadCell({
    required this.child,
    required this.ink,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  @override
  State<_KeypadCell> createState() => _KeypadCellState();
}

class _KeypadCellState extends State<_KeypadCell> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final motion = Theme.of(context).extension<NptMotion>();
    final feedback = Theme.of(context).extension<NptFeedback>();

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
        onTapCancel: widget.onTap == null ? null : () => setState(() => _down = false),
        onTapUp: widget.onTap == null
            ? null
            : (_) {
                setState(() => _down = false);
                // The brand's own haptic weight and its own sound hook, so a
                // formal bank taps lighter than an expressive one. A keypad
                // with no drawn key has to confirm the press somehow, and on a
                // phone held in a noisy street that confirmation is the one
                // the customer actually receives.
                feedback?.trigger(NptFeedbackCue.tap);
                widget.onTap!();
              },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                // Clearing the whole amount is a heavier event than deleting a
                // digit, so it lands as a warning rather than as a tap.
                feedback?.trigger(NptFeedbackCue.warning);
                widget.onLongPress!();
              },
        child: Center(
          child: AnimatedContainer(
            duration: NeptuneAccessibility.duration(
                context, motion?.fast ?? const Duration(milliseconds: 120)),
            curve: motion?.standard ?? Curves.easeOut,
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              // The press bloom is the ink itself at low alpha, so it belongs
              // to whatever ground the pad is on — brand canvas or paper —
              // without the pad being told which.
              color: _down ? widget.ink.withValues(alpha: 0.14) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
