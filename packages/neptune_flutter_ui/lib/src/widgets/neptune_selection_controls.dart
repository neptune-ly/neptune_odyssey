// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Branded selection controls — checkbox, checkbox tile, radio group, switch,
// segmented control and slider. Built from theme roles only (no literals), with
// >=48dp targets, brand corners, surfaceContainer fills and smooth feedback.
// RTL-safe throughout. These mirror the web `<npt-*>` selection primitives.

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// A branded checkbox: a 22dp rounded ([NptShape.xs]) box that fills with
/// [ColorScheme.primary] and shows an [ColorScheme.onPrimary] check when
/// [value] is true, else an outline border. The control sits inside a 48dp
/// tappable area. Pass `onChanged: null` (or `enabled: false`) to disable it.
class NeptuneCheckbox extends StatelessWidget {
  /// Whether the box is checked.
  final bool value;

  /// Called with the toggled value when tapped. Null disables the control.
  final ValueChanged<bool>? onChanged;

  /// Whether the control is interactive. When false it reads as disabled.
  final bool enabled;

  const NeptuneCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final motion = Theme.of(context).extension<NptMotion>()!;
    final isOn = onChanged != null && enabled;
    final tap = isOn ? () => onChanged!(!value) : null;

    final fill = value
        ? (isOn ? scheme.primary : scheme.onSurface.withValues(alpha: 0.12))
        : scheme.surface.withValues(alpha: 0);
    final borderColor = value
        ? (isOn ? scheme.primary : scheme.onSurface.withValues(alpha: 0.12))
        : (isOn ? scheme.outline : scheme.outlineVariant);
    final checkColor =
        isOn ? scheme.onPrimary : scheme.onSurface.withValues(alpha: 0.38);

    return Semantics(
      checked: value,
      enabled: isOn,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: tap,
            customBorder: const CircleBorder(),
            child: Center(
              child: AnimatedContainer(
                duration: motion.fast,
                curve: motion.standard,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: shape.rXs,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: value
                    ? Icon(Icons.check_rounded, size: 16, color: checkColor)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A full-width selectable row: a [NeptuneCheckbox] beside a [label]
/// ([TextTheme.bodyLarge]) and optional [description]
/// ([TextTheme.bodySmall], [ColorScheme.onSurfaceVariant]) on a rounded
/// [ColorScheme.surfaceContainerLow] background. Tapping anywhere on the row
/// toggles the value. At least 48dp tall.
class NeptuneCheckboxTile extends StatelessWidget {
  /// The primary label for the row.
  final String label;

  /// Optional secondary line under the label.
  final String? description;

  /// Whether the tile is checked.
  final bool value;

  /// Called with the toggled value when the row is tapped. Null disables it.
  final ValueChanged<bool>? onChanged;

  const NeptuneCheckboxTile({
    super.key,
    required this.label,
    this.description,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final enabled = onChanged != null;
    final radius = shape.rMd;
    final fg = enabled ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.38);

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        customBorder: RoundedRectangleBorder(borderRadius: radius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, end: 16),
            child: Row(
              children: [
                NeptuneCheckbox(
                  value: value,
                  enabled: enabled,
                  onChanged: enabled ? (v) => onChanged!(v) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: text.bodyLarge?.copyWith(color: fg),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          description!,
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One option in a [NeptuneRadioGroup]: its [value], a [label] and an optional
/// secondary [description] line.
class NeptuneRadioOption<T> {
  /// The value this option represents.
  final T value;

  /// The option label.
  final String label;

  /// Optional secondary line under the label.
  final String? description;

  const NeptuneRadioOption({
    required this.value,
    required this.label,
    this.description,
  });
}

/// A vertical list of branded radio tiles. The selected tile shows a filled
/// [ColorScheme.primary] dot inside its ring; others show an empty
/// [ColorScheme.outline] ring. Each tile is at least 48dp tall and toggles via
/// [onChanged]. RTL-safe.
class NeptuneRadioGroup<T> extends StatelessWidget {
  /// The options to render, in order.
  final List<NeptuneRadioOption<T>> options;

  /// The currently selected value, or null for none.
  final T? value;

  /// Called with an option's value when its tile is tapped. Null disables all.
  final ValueChanged<T>? onChanged;

  const NeptuneRadioGroup({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _NeptuneRadioTile<T>(
            option: options[i],
            selected: value == options[i].value,
            onTap: onChanged == null
                ? null
                : () => onChanged!(options[i].value),
          ),
        ],
      ],
    );
  }
}

/// A single tappable radio row used by [NeptuneRadioGroup].
class _NeptuneRadioTile<T> extends StatelessWidget {
  final NeptuneRadioOption<T> option;
  final bool selected;
  final VoidCallback? onTap;

  const _NeptuneRadioTile({
    required this.option,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final motion = Theme.of(context).extension<NptMotion>()!;
    final text = Theme.of(context).textTheme;
    final enabled = onTap != null;
    final radius = shape.rMd;
    final ringColor = selected
        ? (enabled ? scheme.primary : scheme.onSurface.withValues(alpha: 0.12))
        : (enabled ? scheme.outline : scheme.outlineVariant);
    final dotColor =
        enabled ? scheme.primary : scheme.onSurface.withValues(alpha: 0.38);
    final fg = enabled ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.38);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: enabled,
      child: Material(
        color: selected
            ? scheme.secondaryContainer.withValues(alpha: 0.4)
            : scheme.surfaceContainerLow,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(borderRadius: radius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: motion.fast,
                    curve: motion.standard,
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ringColor, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedScale(
                      duration: motion.fast,
                      curve: motion.standard,
                      scale: selected ? 1 : 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dotColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          option.label,
                          style: text.bodyLarge?.copyWith(color: fg),
                        ),
                        if (option.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            option.description!,
                            style: text.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A branded on/off switch built without Material's [Switch]: an
/// [AnimatedContainer] pill track ([NptShape.full]) that is
/// [ColorScheme.primary] when on and [ColorScheme.surfaceContainerHighest] when
/// off, plus an [AnimatedAlign] thumb ([ColorScheme.onPrimary] /
/// [ColorScheme.outline]). The whole control lives in a 48dp tap area.
class NeptuneSwitch extends StatelessWidget {
  /// Whether the switch is on.
  final bool value;

  /// Called with the toggled value when tapped. Null disables the control.
  final ValueChanged<bool>? onChanged;

  /// Whether the control is interactive. When false it reads as disabled.
  final bool enabled;

  const NeptuneSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final motion = Theme.of(context).extension<NptMotion>()!;
    final isOn = onChanged != null && enabled;
    final tap = isOn ? () => onChanged!(!value) : null;

    final trackColor = value
        ? (isOn ? scheme.primary : scheme.onSurface.withValues(alpha: 0.12))
        : (isOn
            ? scheme.surfaceContainerHighest
            : scheme.onSurface.withValues(alpha: 0.06));
    final thumbColor = value
        ? (isOn ? scheme.onPrimary : scheme.surface)
        : (isOn ? scheme.outline : scheme.onSurface.withValues(alpha: 0.38));

    return Semantics(
      toggled: value,
      enabled: isOn,
      child: SizedBox(
        width: 56,
        height: 48,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: tap,
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(shape.full),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: motion.fast,
                curve: motion.standard,
                width: 52,
                height: 32,
                padding: const EdgeInsetsDirectional.all(3),
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(shape.full),
                ),
                child: AnimatedAlign(
                  duration: motion.fast,
                  curve: motion.emphasized,
                  alignment: value
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: thumbColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One segment in a [NeptuneSegmented] control: its [value], a [label] and an
/// optional leading [icon].
class NeptuneSegment<T> {
  /// The value this segment represents.
  final T value;

  /// The segment label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  const NeptuneSegment({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// A pill-shaped segmented control ([NptShape.full],
/// [ColorScheme.surfaceContainer]) of equal-width segments. The selected
/// segment renders as a [ColorScheme.secondaryContainer] pill with
/// [ColorScheme.onSecondaryContainer] content; the rest use
/// [ColorScheme.onSurfaceVariant]. RTL-safe; uses [IntrinsicHeight] so its
/// stretched [Row] is well-bounded.
class NeptuneSegmented<T> extends StatelessWidget {
  /// The segments to render, in order.
  final List<NeptuneSegment<T>> segments;

  /// The currently selected value.
  final T value;

  /// Called with a segment's value when it is tapped. Null disables the control.
  final ValueChanged<T>? onChanged;

  const NeptuneSegmented({
    super.key,
    required this.segments,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final motion = Theme.of(context).extension<NptMotion>()!;
    final text = Theme.of(context).textTheme;
    final enabled = onChanged != null;
    final radius = BorderRadius.circular(shape.full);

    return Container(
      padding: const EdgeInsetsDirectional.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: radius,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final segment in segments)
              Expanded(
                child: _SegmentButton<T>(
                  segment: segment,
                  selected: segment.value == value,
                  onTap: enabled ? () => onChanged!(segment.value) : null,
                  scheme: scheme,
                  text: text,
                  motion: motion,
                  pill: radius,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A single segment inside a [NeptuneSegmented] control.
class _SegmentButton<T> extends StatelessWidget {
  final NeptuneSegment<T> segment;
  final bool selected;
  final VoidCallback? onTap;
  final ColorScheme scheme;
  final TextTheme text;
  final NptMotion motion;
  final BorderRadius pill;

  const _SegmentButton({
    required this.segment,
    required this.selected,
    required this.onTap,
    required this.scheme,
    required this.text,
    required this.motion,
    required this.pill,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = selected
        ? scheme.onSecondaryContainer
        : (enabled
            ? scheme.onSurfaceVariant
            : scheme.onSurface.withValues(alpha: 0.38));

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: AnimatedContainer(
        duration: motion.fast,
        curve: motion.standard,
        decoration: BoxDecoration(
          color: selected
              ? scheme.secondaryContainer
              : scheme.surface.withValues(alpha: 0),
          borderRadius: pill,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(borderRadius: pill),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (segment.icon != null) ...[
                      Icon(segment.icon, size: 18, color: fg),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        segment.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelLarge?.copyWith(color: fg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A branded slider: a Material [Slider] wrapped in a [SliderTheme] keyed off
/// the active [ColorScheme] (active track [ColorScheme.primary], inactive
/// [ColorScheme.surfaceContainerHighest], thumb [ColorScheme.primary]). An
/// optional [label] sits above the track. RTL-safe.
class NeptuneSlider extends StatelessWidget {
  /// The current value, within [[min], [max]].
  final double value;

  /// The minimum value.
  final double min;

  /// The maximum value.
  final double max;

  /// Optional number of discrete divisions; null for a continuous track.
  final int? divisions;

  /// Called with the new value as the thumb is dragged. Null disables it.
  final ValueChanged<double>? onChanged;

  /// Optional caption shown above the track.
  final String? label;

  const NeptuneSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final enabled = onChanged != null;

    final slider = SliderTheme(
      data: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        disabledActiveTrackColor: scheme.onSurface.withValues(alpha: 0.38),
        disabledInactiveTrackColor: scheme.onSurface.withValues(alpha: 0.12),
        disabledThumbColor: scheme.onSurface.withValues(alpha: 0.38),
        activeTickMarkColor: scheme.onPrimary.withValues(alpha: 0.6),
        inactiveTickMarkColor: scheme.onSurfaceVariant.withValues(alpha: 0.4),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle:
            text.labelMedium?.copyWith(color: scheme.onPrimary),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: divisions != null ? value.toStringAsFixed(0) : null,
        onChanged: enabled ? onChanged : null,
      ),
    );

    if (label == null) return slider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 4),
          child: Text(
            label!,
            style: text.labelLarge?.copyWith(
              color: enabled
                  ? scheme.onSurfaceVariant
                  : scheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ),
        // Brand corner hint so the wrapper reads as a Neptune control even
        // before interaction; the Slider paints its own rounded track on top.
        ClipRRect(
          borderRadius: shape.rSm,
          child: slider,
        ),
      ],
    );
  }
}
