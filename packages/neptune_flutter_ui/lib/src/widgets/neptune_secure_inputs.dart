// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// A row of boxed single-digit OTP cells (web `<npt-otp-input>`): auto-advance,
/// backspace-rewind, and paste-fill. Focused/filled cells lift to a
/// [ColorScheme.primary] border. Numeric only. Theme-only, RTL-safe (the cell
/// row stays LTR like the web `direction: ltr`). Emits [onChanged] on every
/// edit and [onCompleted] once all [length] cells are filled.
class NeptuneOtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  /// When true the digits render as dots (used by [NeptunePinInput]).
  final bool obscure;

  const NeptuneOtpInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.obscure = false,
  });

  @override
  State<NeptuneOtpInput> createState() => _NeptuneOtpInputState();
}

class _NeptuneOtpInputState extends State<NeptuneOtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(covariant NeptuneOtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length != widget.length) {
      _disposeAll();
      _build();
    }
  }

  void _disposeAll() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _emit() {
    final value = _value;
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  void _onChanged(int index, String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    // Paste-fill: spread multiple digits across this cell and the following.
    if (digits.length > 1) {
      var i = index;
      for (final ch in digits.split('')) {
        if (i >= widget.length) break;
        _controllers[i].text = ch;
        i++;
      }
      final next = i < widget.length ? i : widget.length - 1;
      _nodes[next].requestFocus();
      _controllers[next].selection = TextSelection.collapsed(
        offset: _controllers[next].text.length,
      );
      setState(_emit);
      return;
    }

    final ch = digits.isEmpty ? '' : digits.characters.last;
    _controllers[index].text = ch;
    _controllers[index].selection =
        TextSelection.collapsed(offset: ch.length);
    if (ch.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }
    setState(_emit);
  }

  KeyEventResult _onKey(int index, FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].text = '';
      _nodes[index - 1].requestFocus();
      setState(_emit);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft && index > 0) {
      _nodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _OtpCell(
              controller: _controllers[i],
              focusNode: _nodes[i],
              obscure: widget.obscure,
              isLast: i == widget.length - 1,
              onChanged: (raw) => _onChanged(i, raw),
              onKey: (node, event) => _onKey(i, node, event),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single OTP/PIN cell. Filled or focused cells take the primary border.
class _OtpCell extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscure;
  final bool isLast;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(FocusNode, KeyEvent) onKey;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.obscure,
    required this.isLast,
    required this.onChanged,
    required this.onKey,
  });

  @override
  State<_OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<_OtpCell> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus) {
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.controller.text.length,
      );
    }
    setState(() {});
  }

  void _onTextChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;

    final focused = widget.focusNode.hasFocus;
    final filled = widget.controller.text.isNotEmpty;
    final active = focused || filled;

    final cellStyle = (text.headlineSmall ?? text.titleLarge)?.copyWith(
      fontFamily: type.num,
      color: scheme.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return SizedBox(
      width: 48,
      height: 56,
      child: Focus(
        onKeyEvent: widget.onKey,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          obscureText: widget.obscure,
          obscuringCharacter: '•',
          maxLength: 1,
          showCursor: true,
          style: cellStyle,
          textInputAction:
              widget.isLast ? TextInputAction.done : TextInputAction.next,
          onChanged: widget.onChanged,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            isDense: true,
            filled: true,
            fillColor: scheme.surfaceContainerLowest,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: shape.rSm,
              borderSide: BorderSide(
                color: active ? scheme.primary : scheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: shape.rSm,
              borderSide: BorderSide(color: scheme.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

/// A masked variant of [NeptuneOtpInput] (web `<npt-pin-input>`): the same boxed
/// cells, but always obscured with dots and defaulting to 4 digits.
class NeptunePinInput extends StatelessWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const NeptunePinInput({
    super.key,
    this.length = 4,
    this.onChanged,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return NeptuneOtpInput(
      length: length,
      obscure: true,
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}

/// A 3×4 numeric keypad (web `<npt-amount-keypad>`): digits 1–9, a decimal '.',
/// 0, and a backspace. Each key is a large (>= 56dp) themed tile in the number
/// font. Emits the pressed key string ('0'–'9' or '.') via [onKey], and
/// [onBackspace] for the delete key. Theme-only, RTL-safe (logical grid).
class NeptuneAmountKeypad extends StatelessWidget {
  final ValueChanged<String>? onKey;
  final VoidCallback? onBackspace;

  const NeptuneAmountKeypad({super.key, this.onKey, this.onBackspace});

  @override
  Widget build(BuildContext context) {
    const keys = <String>[
      '1', '2', '3', //
      '4', '5', '6', //
      '7', '8', '9', //
      '.', '0', 'back', //
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: [
        for (final k in keys)
          _KeypadKey(
            value: k,
            onTap: () {
              if (k == 'back') {
                onBackspace?.call();
              } else {
                onKey?.call(k);
              }
            },
          ),
      ],
    );
  }
}

/// One keypad tile. Digits/decimal use the number font; backspace is an icon.
class _KeypadKey extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _KeypadKey({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final isAction = value == 'back' || value == '.';

    final keyStyle = NeptuneTheme.moneyStyle(
      context,
      base: text.headlineSmall ?? text.titleLarge,
    ).copyWith(color: scheme.onSurface);

    final Widget child = value == 'back'
        ? Icon(Icons.backspace_outlined,
            size: 24, color: scheme.onSurfaceVariant)
        : Text(value, style: keyStyle);

    return Material(
      color: isAction ? null : scheme.surfaceContainerHigh,
      borderRadius: shape.rMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape.rMd,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
