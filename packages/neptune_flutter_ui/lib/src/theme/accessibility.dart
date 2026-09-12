// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Accessibility contract for the widget set (2.23.1).
//
// The library speaks to assistive technology in the HOST's language. Odyssey
// ships no l10n layer of its own, so every string a screen reader hears from
// a library widget - "credit", "debit", "digit 3 of 6", "loading" - arrives
// through [NeptuneA11yStrings], supplied once by the host via
// [NeptuneAccessibility] above its navigator. The English defaults are the
// fallback for a host that has not wired translations yet; a bank whose
// customers speak Arabic MUST provide them, or a blind Arabic-speaking
// customer hears English in the middle of an Arabic screen.
//
// Money is the other half. "12,480.500 LYD" is a visual form; a screen reader
// should say "12,480.500 Libyan dinars". [NeptuneA11yStrings.money] is the one
// hook: library widgets that show an amount call [NeptuneAccessibility.money]
// and put the result in the semantic label while the visual stays tabular.

import 'package:flutter/widgets.dart';

/// The spoken vocabulary the library needs from its host.
///
/// Every field is a plain string or a small formatter. Keep values free of
/// the em dash, ellipsis and non-breaking space: a host font may lack those
/// glyphs, and a semantic label is occasionally rendered (tooltips).
class NeptuneA11yStrings {
  /// "credit" - money coming in.
  final String credit;

  /// "debit" - money going out.
  final String debit;

  /// "balance" - prefix for an account balance.
  final String balance;

  /// "amount" - label for a bare amount field.
  final String amount;

  /// "IBAN" - label for the IBAN field.
  final String iban;

  /// "valid IBAN" / "invalid IBAN" - the state of the IBAN field's check icon.
  final String ibanValid;
  final String ibanInvalid;

  /// "select currency".
  final String selectCurrency;

  /// "currency" - label of the currency selector pill.
  final String currency;

  /// "decrease" / "increase" - the stepper controls.
  final String decrease;
  final String increase;

  /// "backspace" / "decimal point" - amount keypad keys.
  final String backspace;
  final String decimalPoint;

  /// "loading" - a busy button, a skeleton, a spinner.
  final String loading;

  /// "success" / "rejected" / "processing" - the outcome motion.
  final String success;
  final String rejected;
  final String processing;

  /// "information" / "warning" / "error" - alert tones spoken before the
  /// message so tone is never colour-only.
  final String info;
  final String warning;
  final String error;

  /// "selected" - appended to a chosen row where the platform has no flag.
  final String selected;

  /// "share", "OK", "search", "close", "remove", "step".
  final String share;
  final String ok;
  final String search;
  final String close;
  final String remove;

  /// "from", "to", "fee", "total" - transfer review rows.
  final String from;
  final String to;
  final String fee;
  final String total;

  /// "digit {n} of {total}" - one OTP cell.
  final String Function(int index, int total) otpDigit;

  /// "step {n} of {total}: {label}" - one node of the progress stepper.
  final String Function(int index, int total, String label) step;

  /// "{done} of {total} steps done" - the stepper as a whole.
  final String Function(int done, int total) stepsProgress;

  /// "page {n} of {total}".
  final String Function(int index, int total) page;

  /// "previous page" / "next page".
  final String previousPage;
  final String nextPage;

  /// "account ending in {digits}" - a masked account or card number.
  final String Function(String lastDigits) endingIn;

  /// "{n} percent".
  final String Function(int percent) percent;

  /// "{n} of {max} stars".
  final String Function(int value, int max) rating;

  /// "{n} more".
  final String Function(int count) more;

  /// "up" / "down" - direction of a stat delta.
  final String up;
  final String down;

  /// Spoken form of a money amount. [amount] is the visual string the widget
  /// was given ("12,480.500", "-1,200.00"); [currency] is the ISO code or
  /// symbol the host paired it with, if any. Return a human sentence:
  /// "12,480.500 Libyan dinars". The default appends the currency code, which
  /// a screen reader spells letter by letter - wire a real formatter.
  final String Function(String amount, String? currency) money;

  /// Spoken name of a currency code or symbol on its own ("LYD" -> "Libyan
  /// dinars"), used where a field names the currency it accepts. The default
  /// returns the code unchanged.
  final String Function(String currency) currencyName;

  const NeptuneA11yStrings({
    required this.credit,
    required this.debit,
    required this.balance,
    required this.amount,
    required this.iban,
    required this.ibanValid,
    required this.ibanInvalid,
    required this.selectCurrency,
    required this.currency,
    required this.decrease,
    required this.increase,
    required this.backspace,
    required this.decimalPoint,
    required this.loading,
    required this.success,
    required this.rejected,
    required this.processing,
    required this.info,
    required this.warning,
    required this.error,
    required this.selected,
    required this.share,
    required this.ok,
    required this.search,
    required this.close,
    required this.remove,
    required this.from,
    required this.to,
    required this.fee,
    required this.total,
    required this.otpDigit,
    required this.step,
    required this.stepsProgress,
    required this.page,
    required this.previousPage,
    required this.nextPage,
    required this.endingIn,
    required this.percent,
    required this.rating,
    required this.more,
    required this.up,
    required this.down,
    required this.money,
    this.currencyName = _currencyNameEn,
  });

  /// The English fallback. Used when no [NeptuneAccessibility] is above the
  /// widget. Hosts localise by constructing their own instance.
  const NeptuneA11yStrings.english()
      : credit = 'credit',
        debit = 'debit',
        balance = 'balance',
        amount = 'amount',
        iban = 'IBAN',
        ibanValid = 'valid IBAN',
        ibanInvalid = 'invalid IBAN',
        selectCurrency = 'select currency',
        currency = 'currency',
        decrease = 'decrease',
        increase = 'increase',
        backspace = 'backspace',
        decimalPoint = 'decimal point',
        loading = 'loading',
        success = 'success',
        rejected = 'rejected',
        processing = 'processing',
        info = 'information',
        warning = 'warning',
        error = 'error',
        selected = 'selected',
        share = 'Share',
        ok = 'OK',
        search = 'Search',
        close = 'close',
        remove = 'remove',
        from = 'From',
        to = 'To',
        fee = 'Fee',
        total = 'Total',
        otpDigit = _otpDigitEn,
        step = _stepEn,
        stepsProgress = _stepsProgressEn,
        page = _pageEn,
        previousPage = 'previous page',
        nextPage = 'next page',
        endingIn = _endingInEn,
        percent = _percentEn,
        rating = _ratingEn,
        more = _moreEn,
        up = 'up',
        down = 'down',
        money = _moneyEn,
        currencyName = _currencyNameEn;

  static String _currencyNameEn(String c) => c;
  static String _otpDigitEn(int index, int total) => 'digit $index of $total';
  static String _stepEn(int index, int total, String label) =>
      'step $index of $total, $label';
  static String _stepsProgressEn(int done, int total) =>
      '$done of $total steps done';
  static String _pageEn(int index, int total) => 'page $index of $total';
  static String _endingInEn(String d) => 'ending in $d';
  static String _percentEn(int p) => '$p percent';
  static String _ratingEn(int v, int max) => '$v of $max stars';
  static String _moreEn(int n) => '$n more';
  static String _moneyEn(String amount, String? currency) =>
      currency == null || currency.isEmpty ? amount : '$amount $currency';
}

/// Provides [NeptuneA11yStrings] to every Odyssey widget below it.
///
/// Mount it once, inside `MaterialApp.builder` so it sits above the navigator
/// and every route, sheet and dialog inherits it. Rebuild it when the locale
/// changes; every widget reading it through [of] re-renders its labels.
class NeptuneAccessibility extends InheritedWidget {
  final NeptuneA11yStrings strings;

  const NeptuneAccessibility({
    super.key,
    required this.strings,
    required super.child,
  });

  static const NeptuneA11yStrings _fallback = NeptuneA11yStrings.english();

  /// The host's vocabulary, or the English fallback when none is mounted.
  static NeptuneA11yStrings of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<NeptuneAccessibility>();
    return scope?.strings ?? _fallback;
  }

  /// The spoken form of a money amount. See [NeptuneA11yStrings.money].
  static String money(BuildContext context, String amount, {String? currency}) =>
      of(context).money(amount, currency);

  /// The spoken form of a masked number such as "•••• 4821" or "**** 1234":
  /// "ending in 4 8 2 1". Digits are spaced so a screen reader reads them one
  /// by one instead of as a four-thousand number. A value with no masking
  /// characters is returned digit-spaced but without the "ending in" prefix.
  static String maskedNumber(BuildContext context, String masked) {
    final digits = masked.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
    final spaced = digits.split('').join(' ');
    final wasMasked = RegExp(r'[•*xX]').hasMatch(masked);
    return wasMasked ? of(context).endingIn(spaced) : spaced;
  }

  /// True when the platform asked for animations to be disabled. Widgets
  /// that animate a STATE (a dock selection, a toggle) jump to the end state;
  /// widgets that animate a FLOURISH (a sheen, a shimmer) stop.
  static bool reducedMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// A motion duration that collapses to zero under reduced motion, so an
  /// implicitly-animated widget shows its end state on the first frame.
  static Duration duration(BuildContext context, Duration normal) =>
      reducedMotion(context) ? Duration.zero : normal;

  @override
  bool updateShouldNotify(NeptuneAccessibility oldWidget) =>
      !identical(strings, oldWidget.strings);
}
