// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Branded form inputs (web `<npt-text-field>`, `<npt-select>`,
// `<npt-stepper>`, `<npt-date-field>`): themed text/select/stepper/date
// controls that match the brand decoration of the money inputs — filled
// surfaceContainerHighest, shape.rSm corners, primary focus ring, error
// states. Theme-only (no literal colours/radii/fonts), RTL-safe.

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// A labelled, branded text input (web `<npt-text-field>`).
///
/// Renders an optional [label] (labelMedium, onSurfaceVariant) above a filled
/// [TextField] (surfaceContainerHighest, [NptShape.rSm] corners: no border at
/// rest, a 2px primary ring on focus, the error colour when [errorText] is
/// set), with optional prefix/suffix icons and helper/error text below.
/// Theme-only, RTL-safe.
class NeptuneTextField extends StatelessWidget {
  /// Optional field label shown above the input.
  final String? label;

  /// Placeholder text shown when the field is empty.
  final String? hint;

  /// Supporting text shown below the field when there is no [errorText].
  final String? helperText;

  /// Error text shown below the field; also recolours the border + label.
  final String? errorText;

  /// Optional leading icon inside the field.
  final IconData? prefixIcon;

  /// Optional trailing icon inside the field.
  final IconData? suffixIcon;

  /// Whether to obscure the value (e.g. passwords).
  final bool obscureText;

  /// Whether the field accepts input.
  final bool enabled;

  /// The editing controller for the field.
  final TextEditingController? controller;

  /// Called whenever the value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (e.g. taps done).
  final ValueChanged<String>? onSubmitted;

  /// The keyboard type to request.
  final TextInputType? keyboardType;

  /// Optional maximum length (shows the counter when set).
  final int? maxLength;

  const NeptuneTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    final hasError = errorText != null;
    final labelColor = hasError
        ? scheme.error
        : (enabled ? scheme.onSurfaceVariant : scheme.onSurfaceVariant.withValues(alpha: 0.5));

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: shape.rSm,
          borderSide: width == 0 && color == scheme.surface
              ? BorderSide.none
              : BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: text.labelMedium?.copyWith(color: labelColor),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          keyboardType: keyboardType,
          maxLength: maxLength,
          cursorColor: scheme.primary,
          style: text.bodyLarge?.copyWith(color: scheme.onSurface),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled
                ? scheme.surfaceContainerHighest
                : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            hintText: hint,
            hintStyle: text.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: scheme.onSurfaceVariant),
            suffixIcon: suffixIcon == null
                ? null
                : Icon(suffixIcon, size: 20, color: scheme.onSurfaceVariant),
            counterText: maxLength == null ? '' : null,
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            // No visible border at rest; primary ring on focus; error tint.
            border: OutlineInputBorder(
              borderRadius: shape.rSm,
              borderSide: BorderSide.none,
            ),
            enabledBorder: hasError
                ? border(scheme.error, 1)
                : OutlineInputBorder(
                    borderRadius: shape.rSm,
                    borderSide: BorderSide.none,
                  ),
            disabledBorder: OutlineInputBorder(
              borderRadius: shape.rSm,
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            focusedBorder: border(hasError ? scheme.error : scheme.primary, 2),
            errorBorder: border(scheme.error, 1),
            focusedErrorBorder: border(scheme.error, 2),
            // We render our own helper/error row below for full style control.
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
        ),
        if (hasError || helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText ?? helperText!,
            style: text.bodySmall?.copyWith(
              color: hasError ? scheme.error : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// One option in a [NeptuneSelect]: a [value], its [label], and an optional
/// leading [icon].
class NeptuneSelectOption<T> {
  /// The value carried by this option.
  final T value;

  /// The human-readable label.
  final String label;

  /// Optional leading icon shown in the menu + the closed field.
  final IconData? icon;

  const NeptuneSelectOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// A labelled, branded dropdown select (web `<npt-select>`).
///
/// A themed [DropdownButtonFormField] whose decoration matches
/// [NeptuneTextField] (filled surfaceContainerHighest, [NptShape.rSm] corners,
/// primary focus ring). Menu items show an optional [NeptuneSelectOption.icon]
/// before the label. Theme-only, RTL-safe.
class NeptuneSelect<T> extends StatelessWidget {
  /// Optional field label shown above the select.
  final String? label;

  /// Placeholder shown when no value is selected.
  final String? hint;

  /// The selectable options.
  final List<NeptuneSelectOption<T>> options;

  /// The currently selected value.
  final T? value;

  /// Called when the selection changes.
  final ValueChanged<T?>? onChanged;

  /// Whether the select accepts input.
  final bool enabled;

  const NeptuneSelect({
    super.key,
    this.label,
    this.hint,
    required this.options,
    this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: shape.rSm,
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: text.labelMedium?.copyWith(
              color: enabled
                  ? scheme.onSurfaceVariant
                  : scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: enabled ? onChanged : null,
          isExpanded: true,
          borderRadius: shape.rSm,
          icon: Icon(Icons.arrow_drop_down, color: scheme.onSurfaceVariant),
          dropdownColor: scheme.surfaceContainerHigh,
          style: text.bodyLarge?.copyWith(color: scheme.onSurface),
          hint: hint == null
              ? null
              : Text(
                  hint!,
                  style: text.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled
                ? scheme.surfaceContainerHighest
                : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: shape.rSm,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: shape.rSm,
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: shape.rSm,
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            focusedBorder: border(scheme.primary, 2),
          ),
          items: [
            for (final option in options)
              DropdownMenuItem<T>(
                value: option.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.icon != null) ...[
                      Icon(option.icon, size: 20, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Text(
                        option.label,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyLarge?.copyWith(color: scheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A branded numeric +/- stepper (web `<npt-stepper>`).
///
/// A pill row: a minus [IconButton], the centred [value] (tabular, titleMedium)
/// and a plus [IconButton]. Minus disables at [min], plus disables at [max].
/// Controls are ≥48dp. Theme-only, RTL-safe.
class NeptuneStepperInput extends StatelessWidget {
  /// The current value.
  final int value;

  /// The smallest allowed value (inclusive).
  final int min;

  /// The largest allowed value (inclusive).
  final int max;

  /// The increment/decrement applied per tap.
  final int step;

  /// Called with the clamped new value when +/- is tapped.
  final ValueChanged<int>? onChanged;

  /// Optional label shown above the stepper.
  final String? label;

  const NeptuneStepperInput({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 9999,
    this.step = 1,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    final canDecrement = onChanged != null && value > min;
    final canIncrement = onChanged != null && value < max;
    final radius = BorderRadius.circular(shape.full);

    void emit(int next) => onChanged?.call(next.clamp(min, max));

    Widget control({
      required IconData icon,
      required bool enabled,
      required VoidCallback onTap,
      required String tooltip,
    }) {
      final fg = enabled ? scheme.onSurface : scheme.onSurfaceVariant.withValues(alpha: 0.4);
      return IconButton(
        onPressed: enabled ? onTap : null,
        tooltip: tooltip,
        iconSize: 20,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Icon(icon, color: fg),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: radius,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              control(
                icon: Icons.remove,
                enabled: canDecrement,
                onTap: () => emit(value - step),
                tooltip: 'Decrease',
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 40),
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: text.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              control(
                icon: Icons.add,
                enabled: canIncrement,
                onTap: () => emit(value + step),
                tooltip: 'Increase',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A branded date field (web `<npt-date-field>`).
///
/// A tappable field with a calendar_today suffix that opens [showDatePicker]
/// (inheriting the active theme) and shows the selected [value] formatted as
/// `yyyy-MM-dd`. Decoration matches [NeptuneTextField]. Theme-only, RTL-safe.
class NeptuneDateField extends StatelessWidget {
  /// Optional field label shown above the input.
  final String? label;

  /// Placeholder shown when no date is selected.
  final String? hint;

  /// The currently selected date.
  final DateTime? value;

  /// Called with the picked date when the user confirms.
  final ValueChanged<DateTime>? onChanged;

  /// The earliest selectable date (defaults to 100 years ago).
  final DateTime? firstDate;

  /// The latest selectable date (defaults to 100 years ahead).
  final DateTime? lastDate;

  const NeptuneDateField({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  /// Format a date as `yyyy-MM-dd` without depending on `intl`.
  static String _format(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final first = firstDate ?? DateTime(now.year - 100);
    final last = lastDate ?? DateTime(now.year + 100);
    var initial = value ?? now;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) onChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    final hasValue = value != null;
    final display = hasValue ? _format(value!) : (hint ?? 'yyyy-MM-dd');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
        ],
        Material(
          color: scheme.surfaceContainerHighest,
          borderRadius: shape.rSm,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _pick(context),
            customBorder: RoundedRectangleBorder(borderRadius: shape.rSm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        display,
                        style: text.bodyLarge?.copyWith(
                          color: hasValue
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant.withValues(alpha: 0.6),
                          fontFeatures:
                              hasValue ? const [FontFeature.tabularFigures()] : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
