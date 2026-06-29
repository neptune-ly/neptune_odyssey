// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// Keep only digits and a single decimal point (first separator wins).
String _sanitizeAmount(String raw) {
  var seenDot = false;
  final out = StringBuffer();
  for (final ch in raw.split('')) {
    if (ch.compareTo('0') >= 0 && ch.compareTo('9') <= 0) {
      out.write(ch);
    } else if ((ch == '.' || ch == ',') && !seenDot) {
      seenDot = true;
      out.write('.');
    }
  }
  return out.toString();
}

/// Strip everything but A–Z and 0–9, uppercased — for IBANs.
String _cleanIban(String raw) =>
    raw.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

/// Space-group an IBAN into blocks of four.
String _groupIban(String raw) =>
    _cleanIban(raw).replaceAllMapped(RegExp('.{4}'), (m) => '${m[0]} ').trim();

/// A large display-font amount field (web `<npt-amount-input>`): big tabular
/// figures with an optional currency affix. Numeric keyboard; reflects the
/// sanitized value through [onChanged]. Theme-only, RTL-safe.
class NeptuneAmountInput extends StatefulWidget {
  final String value;
  final String? currency;
  final String? hint;
  final ValueChanged<String>? onChanged;

  const NeptuneAmountInput({
    super.key,
    required this.value,
    this.currency,
    this.hint,
    this.onChanged,
  });

  @override
  State<NeptuneAmountInput> createState() => _NeptuneAmountInputState();
}

class _NeptuneAmountInputState extends State<NeptuneAmountInput> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant NeptuneAmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text && widget.value != oldWidget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String raw) {
    final clean = _sanitizeAmount(raw);
    if (clean != raw) {
      _controller.value = TextEditingValue(
        text: clean,
        selection: TextSelection.collapsed(offset: clean.length),
      );
    }
    widget.onChanged?.call(clean);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: text.displaySmall)
        .copyWith(
      color: scheme.onSurface,
      fontWeight: type.displayFontWeight,
      letterSpacing: type.displayTracking,
    );
    final affix = text.titleMedium?.copyWith(color: scheme.onSurfaceVariant);

    final currency = widget.currency;

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: shape.rMd,
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (currency != null && currency.isNotEmpty) ...[
            Text(currency, style: affix),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _handleChanged,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              style: money,
              cursorColor: scheme.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hint ?? '0.00',
                hintStyle: money.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled outlined money field (web `<npt-currency-field>`): a themed
/// tabular amount [TextField] paired with a tappable currency-selector pill.
/// Theme-only, RTL-safe.
class NeptuneCurrencyField extends StatefulWidget {
  final String amount;
  final String currency;
  final List<String>? currencies;
  final ValueChanged<String>? onCurrencyChanged;
  final ValueChanged<String>? onAmountChanged;

  const NeptuneCurrencyField({
    super.key,
    required this.amount,
    required this.currency,
    this.currencies,
    this.onCurrencyChanged,
    this.onAmountChanged,
  });

  @override
  State<NeptuneCurrencyField> createState() => _NeptuneCurrencyFieldState();
}

class _NeptuneCurrencyFieldState extends State<NeptuneCurrencyField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.amount);

  @override
  void didUpdateWidget(covariant NeptuneCurrencyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amount != _controller.text &&
        widget.amount != oldWidget.amount) {
      _controller.text = widget.amount;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String raw) {
    final clean = _sanitizeAmount(raw);
    if (clean != raw) {
      _controller.value = TextEditingValue(
        text: clean,
        selection: TextSelection.collapsed(offset: clean.length),
      );
    }
    widget.onAmountChanged?.call(clean);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final amountStyle = NeptuneTheme.moneyStyle(context, base: text.titleMedium)
        .copyWith(color: scheme.onSurface);
    final currencyStyle = text.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    final options = widget.currencies;
    final hasMenu = options != null && options.isNotEmpty;

    final pill = Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: shape.rSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.currency, style: currencyStyle),
          if (hasMenu) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: shape.rSm,
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _handleChanged,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              style: amountStyle,
              cursorColor: scheme.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: amountStyle.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (hasMenu)
            PopupMenuButton<String>(
              tooltip: 'Select currency',
              padding: EdgeInsets.zero,
              position: PopupMenuPosition.under,
              onSelected: (c) => widget.onCurrencyChanged?.call(c),
              itemBuilder: (context) => [
                for (final c in options)
                  PopupMenuItem<String>(
                    value: c,
                    child: Text(c, style: currencyStyle),
                  ),
              ],
              child: pill,
            )
          else
            pill,
        ],
      ),
    );
  }
}

/// A themed IBAN field (web `<npt-iban-field>`): groups the value into blocks
/// of four as it is typed and shows a trailing valid/invalid state icon driven
/// by [valid]. Theme-only, RTL-safe.
class NeptuneIbanField extends StatefulWidget {
  final String value;
  final ValueChanged<String>? onChanged;
  final bool valid;

  const NeptuneIbanField({
    super.key,
    required this.value,
    this.onChanged,
    this.valid = true,
  });

  @override
  State<NeptuneIbanField> createState() => _NeptuneIbanFieldState();
}

class _NeptuneIbanFieldState extends State<NeptuneIbanField> {
  late final TextEditingController _controller =
      TextEditingController(text: _groupIban(widget.value));

  @override
  void didUpdateWidget(covariant NeptuneIbanField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_cleanIban(widget.value) != _cleanIban(_controller.text) &&
        widget.value != oldWidget.value) {
      _controller.text = _groupIban(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String raw) {
    final clean = _cleanIban(raw);
    final formatted = _groupIban(clean);
    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    widget.onChanged?.call(clean);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final npt = Theme.of(context).extension<NptColors>()!;
    final text = Theme.of(context).textTheme;
    final hasValue = _cleanIban(widget.value).isNotEmpty;
    final ibanStyle =
        NeptuneTheme.moneyStyle(context, base: text.bodyLarge).copyWith(
      color: scheme.onSurface,
      letterSpacing: 1.2,
    );
    final borderColor = !hasValue
        ? scheme.outline
        : (widget.valid ? npt.success : scheme.error);

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: shape.rSm,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _handleChanged,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              style: ibanStyle,
              cursorColor: scheme.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'LY00 0000 0000 0000',
                hintStyle: ibanStyle.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          if (hasValue) ...[
            const SizedBox(width: 12),
            Icon(
              widget.valid ? Icons.check_circle : Icons.cancel,
              size: 20,
              color: widget.valid ? npt.success : scheme.error,
            ),
          ],
        ],
      ),
    );
  }
}
