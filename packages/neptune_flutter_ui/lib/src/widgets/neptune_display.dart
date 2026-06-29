// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// A circular avatar. Renders, in priority order: an [image], otherwise
/// [initials] (on a `primaryContainer` fill), otherwise an [icon]. Falls back to
/// a neutral person glyph when nothing is supplied. The text/icon scale with
/// [size]. Theme-only, RTL-safe.
class NeptuneAvatar extends StatelessWidget {
  /// One or two letters shown when no [image] is given.
  final String? initials;

  /// An image to fill the circle. Takes priority over [initials]/[icon].
  final ImageProvider? image;

  /// A glyph shown when neither [image] nor [initials] is given.
  final IconData? icon;

  /// The diameter of the avatar in logical pixels.
  final double size;

  /// Optional fill override. Defaults to the theme `primaryContainer`.
  final Color? background;

  const NeptuneAvatar({
    super.key,
    this.initials,
    this.image,
    this.icon,
    this.size = 40,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final bg = background ?? scheme.primaryContainer;
    final fg = scheme.onPrimaryContainer;

    final Widget content;
    if (image != null) {
      content = Image(image: image!, fit: BoxFit.cover, width: size, height: size);
    } else if (initials != null && initials!.trim().isNotEmpty) {
      content = Center(
        child: Text(
          initials!.trim().toUpperCase(),
          style: (text.labelLarge ?? const TextStyle()).copyWith(
            color: fg,
            fontSize: size * 0.4,
            height: 1,
          ),
        ),
      );
    } else {
      content = Icon(icon ?? Icons.person, size: size * 0.55, color: fg);
    }

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: image == null ? bg : null,
        shape: BoxShape.circle,
      ),
      child: content,
    );
  }
}

/// A row of overlapping [NeptuneAvatar]s, each ringed in the surface colour so
/// it reads cleanly against the stack. Renders at most [max] avatars; any
/// surplus collapses into a trailing `+N` count chip. Theme-only, RTL-safe.
class NeptuneAvatarGroup extends StatelessWidget {
  /// The avatars to stack, in display order (first is inline-start, on top).
  final List<NeptuneAvatar> avatars;

  /// The maximum number of avatars to show before collapsing into `+N`.
  final int max;

  /// The diameter of each avatar in the group.
  final double size;

  /// How many logical pixels each avatar overlaps the previous one.
  final double overlap;

  const NeptuneAvatarGroup({
    super.key,
    required this.avatars,
    this.max = 4,
    this.size = 36,
    this.overlap = 12,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final shown = avatars.length > max ? max : avatars.length;
    final extra = avatars.length - shown;
    final ring = size * 0.06 + 1.5;
    final step = size - overlap;

    // A surface-ringed cell wrapping any circular child.
    Widget cell(Widget child) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: scheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: scheme.surface, width: ring),
          ),
          child: ClipOval(child: child),
        );

    final entries = <Widget>[
      for (var i = 0; i < shown; i++)
        PositionedDirectional(
          start: i * step,
          child: cell(
            NeptuneAvatar(
              initials: avatars[i].initials,
              image: avatars[i].image,
              icon: avatars[i].icon,
              size: size,
              background: avatars[i].background,
            ),
          ),
        ),
      if (extra > 0)
        PositionedDirectional(
          start: shown * step,
          child: cell(
            Container(
              color: scheme.secondaryContainer,
              alignment: Alignment.center,
              child: Text(
                '+$extra',
                style: (text.labelMedium ?? const TextStyle()).copyWith(
                  color: scheme.onSecondaryContainer,
                  fontSize: size * 0.34,
                ),
              ),
            ),
          ),
        ),
    ];

    final cells = shown + (extra > 0 ? 1 : 0);
    final width = cells == 0 ? 0.0 : size + (cells - 1) * step;

    return SizedBox(
      width: width,
      height: size,
      child: Stack(children: entries),
    );
  }
}

/// A small error-coloured badge. When a [child] is given the badge is overlaid
/// at the top inline-end corner via a [Stack]; otherwise it renders standalone.
/// Shows a [label], a [count] (capped at 99+), or — with [dot] — a bare dot.
/// Theme-only, RTL-safe.
class NeptuneBadge extends StatelessWidget {
  /// The element the badge decorates. When null the badge renders on its own.
  final Widget? child;

  /// A numeric count to show. Values above 99 render as `99+`.
  final int? count;

  /// When true, render a bare dot with no label (overrides [count]/[label]).
  final bool dot;

  /// An explicit text label. Takes priority over [count].
  final String? label;

  const NeptuneBadge({
    super.key,
    this.child,
    this.count,
    this.dot = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final badge = _buildBadge(context);
    if (child == null) return badge;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        PositionedDirectional(top: -4, end: -4, child: badge),
      ],
    );
  }

  Widget _buildBadge(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    if (dot) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: scheme.error,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.surface, width: 1.5),
        ),
      );
    }

    final content = label ??
        (count != null ? (count! > 99 ? '99+' : '$count') : '');

    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 5, vertical: 1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.error,
        borderRadius: BorderRadius.circular(shape.full),
        border: Border.all(color: scheme.surface, width: 1.5),
      ),
      child: Text(
        content,
        style: (text.labelSmall ?? const TextStyle()).copyWith(
          color: scheme.onError,
          height: 1,
        ),
      ),
    );
  }
}

/// A small tonal tag pill (`secondaryContainer`, stadium-shaped) with an optional
/// leading [icon] and, when [onRemove] is given, a trailing close button.
/// Theme-only, RTL-safe.
class NeptuneTag extends StatelessWidget {
  /// The tag label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// When non-null, a trailing close button invokes this on tap.
  final VoidCallback? onRemove;

  /// Optional fill override. Defaults to the theme `secondaryContainer`.
  final Color? color;

  const NeptuneTag({
    super.key,
    required this.label,
    this.icon,
    this.onRemove,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final bg = color ?? scheme.secondaryContainer;
    final fg = scheme.onSecondaryContainer;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(shape.full),
      ),
      padding: EdgeInsetsDirectional.only(
        start: icon != null ? 8 : 12,
        end: onRemove != null ? 4 : 12,
        top: 4,
        bottom: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: (text.labelMedium ?? const TextStyle()).copyWith(color: fg),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(2),
                child: Icon(Icons.close, size: 14, color: fg),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A rounded linear progress track. Shows a primary-coloured fill scaled to
/// [value] (0..1), or — with [indeterminate] — an animated bar. An optional
/// [label] + percentage row sits above the track. Theme-only, RTL-safe.
class NeptuneProgressBar extends StatelessWidget {
  /// Progress in the range 0..1. Ignored when [indeterminate] is true.
  final double value;

  /// Optional caption shown above the track, inline-start of the percentage.
  final String? label;

  /// When true, render an indeterminate animation instead of a fixed fill.
  final bool indeterminate;

  /// Optional fill override. Defaults to the theme `primary`.
  final Color? color;

  const NeptuneProgressBar({
    super.key,
    required this.value,
    this.label,
    this.indeterminate = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final fill = color ?? scheme.primary;
    final track = scheme.surfaceContainerHighest;
    final clamped = value.clamp(0.0, 1.0);
    final radius = BorderRadius.circular(shape.full);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || !indeterminate) ...[
          Row(
            children: [
              if (label != null)
                Expanded(
                  child: Text(
                    label!,
                    style: (text.labelMedium ?? const TextStyle())
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                )
              else
                const Spacer(),
              if (!indeterminate)
                Text(
                  '${(clamped * 100).round()}%',
                  style: (text.labelMedium ?? const TextStyle())
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            height: 8,
            child: indeterminate
                ? LinearProgressIndicator(
                    backgroundColor: track,
                    valueColor: AlwaysStoppedAnimation<Color>(fill),
                  )
                : Container(
                    color: track,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FractionallySizedBox(
                        widthFactor: clamped,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: fill,
                            borderRadius: radius,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// A circular progress ring drawn with [CustomPaint]: a full `outlineVariant`
/// track behind a `primary` progress arc that sweeps clockwise from the top.
/// Optionally shows a [centerLabel] in the middle. Theme-only, RTL-safe.
class NeptuneProgressRing extends StatelessWidget {
  /// Progress in the range 0..1.
  final double value;

  /// The outer diameter of the ring in logical pixels.
  final double size;

  /// The stroke width of the track and progress arc.
  final double stroke;

  /// Optional text centred inside the ring.
  final String? centerLabel;

  const NeptuneProgressRing({
    super.key,
    required this.value,
    this.size = 48,
    this.stroke = 6,
    this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0.0, 1.0),
          stroke: stroke,
          track: scheme.outlineVariant,
          progress: scheme.primary,
        ),
        child: centerLabel == null
            ? null
            : Center(
                child: Text(
                  centerLabel!,
                  textAlign: TextAlign.center,
                  style: (text.labelLarge ?? const TextStyle())
                      .copyWith(color: scheme.onSurface),
                ),
              ),
      ),
    );
  }
}

/// Paints a circular track and a progress arc for [NeptuneProgressRing].
class _RingPainter extends CustomPainter {
  final double value;
  final double stroke;
  final Color track;
  final Color progress;

  const _RingPainter({
    required this.value,
    required this.stroke,
    required this.track,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);

    if (value <= 0) return;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = progress;
    const start = -math.pi / 2;
    canvas.drawArc(rect, start, 2 * math.pi * value, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.stroke != stroke ||
      old.track != track ||
      old.progress != progress;
}

/// A row of rating stars. Filled stars use `primary`; a half-value renders a
/// half star; empties use an `onSurfaceVariant` outline. When [onChanged] is
/// given the stars become tappable (each target ≥ 48dp). Theme-only, RTL-safe.
class NeptuneRating extends StatelessWidget {
  /// The current rating value (may be fractional, e.g. 3.5).
  final double value;

  /// The total number of stars.
  final int count;

  /// When non-null, taps report the 1-based star index.
  final ValueChanged<int>? onChanged;

  /// The visual size of each star glyph.
  final double size;

  const NeptuneRating({
    super.key,
    required this.value,
    this.count = 5,
    this.onChanged,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final interactive = onChanged != null;

    Widget star(int i) {
      final filled = value >= i;
      final half = !filled && value > i - 1;
      final IconData glyph;
      final Color color;
      if (filled) {
        glyph = Icons.star_rounded;
        color = scheme.primary;
      } else if (half) {
        glyph = Icons.star_half_rounded;
        color = scheme.primary;
      } else {
        glyph = Icons.star_outline_rounded;
        color = scheme.onSurfaceVariant;
      }

      final icon = Icon(glyph, size: size, color: color);
      if (!interactive) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 2),
          child: icon,
        );
      }
      return InkWell(
        onTap: () => onChanged!(i),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(child: icon),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [for (var i = 1; i <= count; i++) star(i)],
    );
  }
}

/// A branded list row (min 56dp) on a rounded `surfaceContainerLow` surface. A
/// [leadingIcon] renders inside a tinted `primaryContainer` square; a [leading]
/// widget is used as-is. The [title] uses `bodyLarge`, the [subtitle]
/// `bodySmall` in `onSurfaceVariant`. Tappable via [onTap]. Theme-only,
/// RTL-safe.
class NeptuneListTile extends StatelessWidget {
  /// A custom leading widget. Takes priority over [leadingIcon].
  final Widget? leading;

  /// A leading icon rendered inside a tinted rounded square.
  final IconData? leadingIcon;

  /// The primary line of text.
  final String title;

  /// Optional secondary line under the title.
  final String? subtitle;

  /// Optional trailing widget, inline-end (e.g. a chevron or amount).
  final Widget? trailing;

  /// Tap handler. When null the row is non-interactive.
  final VoidCallback? onTap;

  const NeptuneListTile({
    super.key,
    this.leading,
    this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final radius = shape.rMd;

    Widget? lead = leading;
    lead ??= leadingIcon == null
        ? null
        : Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: shape.rSm,
            ),
            child: Icon(leadingIcon, size: 20, color: scheme.onPrimaryContainer),
          );

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Row(
          children: [
            if (lead != null) ...[lead, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: (text.bodyLarge ?? const TextStyle())
                        .copyWith(color: scheme.onSurface),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: (text.bodySmall ?? const TextStyle())
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? row
          : InkWell(
              onTap: onTap,
              customBorder: RoundedRectangleBorder(borderRadius: radius),
              child: row,
            ),
    );
  }
}

/// One step in a [NeptuneTimeline]: a [title], optional [subtitle] and [time],
/// and a [done] flag that fills the step's dot.
class NeptuneTimelineEntry {
  /// The step heading.
  final String title;

  /// Optional supporting line under the title.
  final String? subtitle;

  /// Optional timestamp shown inline-end of the title.
  final String? time;

  /// Whether this step is complete (a filled dot) or pending (an outline dot).
  final bool done;

  const NeptuneTimelineEntry({
    required this.title,
    this.subtitle,
    this.time,
    this.done = false,
  });
}

/// A vertical timeline of [NeptuneTimelineEntry]s. Each entry shows a dot —
/// filled `primary` when done, otherwise an `outline` ring — joined to the next
/// by an `outlineVariant` connector, beside its title/subtitle/time text.
/// Theme-only, RTL-safe.
class NeptuneTimeline extends StatelessWidget {
  /// The ordered steps, top to bottom.
  final List<NeptuneTimelineEntry> entries;

  const NeptuneTimeline({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    const dot = 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < entries.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Rail: the dot for this step + a connector to the next.
                SizedBox(
                  width: dot,
                  child: Column(
                    children: [
                      Container(
                        width: dot,
                        height: dot,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: entries[i].done
                              ? scheme.primary
                              : scheme.surface,
                          border: Border.all(
                            color: entries[i].done
                                ? scheme.primary
                                : scheme.outline,
                            width: 2,
                          ),
                        ),
                      ),
                      if (i < entries.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: scheme.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Content beside the rail.
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      bottom: i < entries.length - 1 ? 16 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entries[i].title,
                                style: (text.labelLarge ?? const TextStyle())
                                    .copyWith(color: scheme.onSurface),
                              ),
                            ),
                            if (entries[i].time != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                entries[i].time!,
                                style: (text.labelSmall ?? const TextStyle())
                                    .copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ],
                        ),
                        if (entries[i].subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            entries[i].subtitle!,
                            style: (text.bodySmall ?? const TextStyle())
                                .copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
