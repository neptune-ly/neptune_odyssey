// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Tiny money/number formatting — no `intl` dependency, so the app stays lean and
// the formatting is deterministic across platforms.

/// Group-separated currency, e.g. `money(12480.5) == 'LYD 12,480.50'`.
/// [signed] prefixes an explicit `+` for non-negative values (for ledgers).
String money(double value, {String currency = 'LYD', bool signed = false}) {
  final negative = value < 0;
  final cents = (value.abs() * 100).round();
  final whole = cents ~/ 100;
  final frac = (cents % 100).toString().padLeft(2, '0');
  final core = '$currency ${_grouped(whole)}.$frac';
  if (negative) return '-$core';
  return signed ? '+$core' : core;
}

/// Bare grouped number with [decimals] places, e.g. `number(3540) == '3,540'`.
String number(num value, {int decimals = 0}) {
  if (decimals == 0) return _grouped(value.round());
  final factor = decimals == 2 ? 100 : 1000;
  final scaled = (value.abs() * factor).round();
  final whole = scaled ~/ factor;
  final frac = (scaled % factor).toString().padLeft(decimals, '0');
  final sign = value < 0 ? '-' : '';
  return '$sign${_grouped(whole)}.$frac';
}

String _grouped(int n) {
  final digits = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
