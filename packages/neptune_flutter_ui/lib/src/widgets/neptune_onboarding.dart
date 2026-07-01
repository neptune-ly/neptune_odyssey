// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// A full-height get-started hero: a media region on top, then an eyebrow,
/// headline, supporting copy, page dots and a call to action. Mirrors the web
/// `<npt-onboarding>`. Reads colour, shape and type from the active theme only —
/// no literals. RTL-safe.
class NeptuneOnboarding extends StatelessWidget {
  /// Small uppercase label above the headline (e.g. "Welcome").
  final String? eyebrow;

  /// The hero headline. The caller passes a fully styled [Text]/[RichText] so it
  /// can mix weights like the reference designs; this widget only positions it.
  final Widget headline;

  /// Supporting paragraph under the headline.
  final String? supporting;

  /// Total number of page dots to render (0 = none).
  final int steps;

  /// Index of the active dot (widened + primary-coloured).
  final int activeStep;

  /// Optional media/illustration in the top region. When null a brand gradient
  /// (primary → primaryContainer) fills the space.
  final Widget? media;

  /// Optional call-to-action (e.g. a [NeptunePrimaryButton]) at the bottom.
  final Widget? cta;

  const NeptuneOnboarding({
    super.key,
    this.eyebrow,
    required this.headline,
    this.supporting,
    this.steps = 0,
    this.activeStep = 0,
    this.media,
    this.cta,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    // Media region: caller content, or a brand gradient fallback.
    final mediaRegion = Container(
      margin: const EdgeInsetsDirectional.all(12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: shape.rXl,
        gradient: media == null
            ? LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [scheme.primary, scheme.tertiary],
              )
            : null,
      ),
      alignment: Alignment.center,
      child: media,
    );

    // Fill the screen when the parent bounds our height (a real onboarding
    // screen); fall back to a fixed hero height when we're inside an unbounded
    // scroll column (e.g. the builder canvas) so the gradient hero still shows.
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedHeight;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            bounded
                ? Expanded(child: mediaRegion)
                : SizedBox(height: 300, child: mediaRegion),
            // Content block.
            Padding(
          padding: const EdgeInsetsDirectional.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: text.labelMedium?.copyWith(
                    color: scheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // Hero headline in the display face; a lighter base weight lets a
              // bold emphasis run (mixed-weight) read the way the web does.
              DefaultTextStyle.merge(
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.12,
                  color: scheme.onSurface,
                ),
                child: headline,
              ),
              if (supporting != null) ...[
                const SizedBox(height: 12),
                Text(
                  supporting!,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (steps > 0) ...[
                const SizedBox(height: 16),
                _PageDots(
                  steps: steps,
                  activeStep: activeStep,
                  shape: shape,
                  scheme: scheme,
                ),
              ],
              if (cta != null) ...[
                const SizedBox(height: 16),
                cta!,
              ],
            ],
          ),
        ),
          ],
        );
      },
    );
  }
}

/// A row of small rounded bars; the active one is wider and primary-coloured,
/// the rest use [ColorScheme.outlineVariant].
class _PageDots extends StatelessWidget {
  final int steps;
  final int activeStep;
  final NptShape shape;
  final ColorScheme scheme;

  const _PageDots({
    required this.steps,
    required this.activeStep,
    required this.shape,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < steps; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Container(
            width: i == activeStep ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(shape.full),
              color: i == activeStep ? scheme.primary : scheme.outlineVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// A titled content section with an optional supporting description and a body
/// [child]. Mirrors the web `<npt-section>`.
class NeptuneSection extends StatelessWidget {
  /// The section heading.
  final String title;

  /// Optional supporting description under the title.
  final String? description;

  /// The section body.
  final Widget child;

  const NeptuneSection({
    super.key,
    required this.title,
    this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final type = Theme.of(context).extension<NptType>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: text.titleMedium?.copyWith(
            fontFamily: type.display,
            color: scheme.onSurface,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

/// A pill-shaped chip with an optional leading icon. When [selected] it uses the
/// secondary-container tonal treatment; otherwise a neutral surface. Mirrors the
/// web `<npt-chip>`. Tappable surfaces use Material + InkWell. >=44dp tall.
class NeptuneChip extends StatelessWidget {
  /// The chip label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the chip is in the selected (tonal) state.
  final bool selected;

  /// Tap handler. When null the chip is non-interactive.
  final VoidCallback? onTap;

  const NeptuneChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    final bg =
        selected ? scheme.secondaryContainer : scheme.surfaceContainerHigh;
    final fg =
        selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;
    final radius = BorderRadius.circular(shape.full);

    return Material(
      color: bg,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: radius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: text.labelLarge?.copyWith(color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tone of a [NeptuneStatusChip].
enum NeptuneStatusTone { neutral, success, warning, danger }

/// A small rounded status pill with a coloured dot + tonal background, coloured
/// by [tone]. Mirrors the web `<npt-status-chip>`.
class NeptuneStatusChip extends StatelessWidget {
  /// The status label.
  final String label;

  /// The colour tone for the chip.
  final NeptuneStatusTone tone;

  const NeptuneStatusChip({
    super.key,
    required this.label,
    this.tone = NeptuneStatusTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final npt = Theme.of(context).extension<NptColors>()!;

    // Resolve the dot/foreground accent and a tinted background per tone.
    final Color accent;
    final Color fg;
    final Color bg;
    switch (tone) {
      case NeptuneStatusTone.success:
        accent = npt.success;
        fg = npt.onSuccessContainer;
        bg = npt.success.withValues(alpha: 0.15);
        break;
      case NeptuneStatusTone.warning:
        accent = scheme.tertiary;
        fg = scheme.onTertiaryContainer;
        bg = scheme.tertiary.withValues(alpha: 0.15);
        break;
      case NeptuneStatusTone.danger:
        accent = scheme.error;
        fg = scheme.onErrorContainer;
        bg = scheme.error.withValues(alpha: 0.15);
        break;
      case NeptuneStatusTone.neutral:
        accent = scheme.onSurfaceVariant;
        fg = scheme.onSurfaceVariant;
        bg = scheme.surfaceContainerHighest;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(shape.full),
      ),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(shape.full),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: text.labelMedium?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
