// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// The page-level masthead (web `<npt-page-header>`): a display-font title, an
/// optional supporting subtitle below, and trailing actions inline-end of the
/// title row. Theme-only, RTL-safe.
class NeptunePageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const NeptunePageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: text.displaySmall?.copyWith(
                    fontFamily: type.display,
                    fontWeight: type.displayFontWeight,
                    letterSpacing: type.displayTracking,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(width: 16),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: actions!,
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: text.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

/// A themed pill search field (web `<npt-search-field>`): a rounded
/// surface-container with a leading magnifier and a borderless [TextField].
/// Theme-only, RTL-safe.
class NeptuneSearchField extends StatelessWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const NeptuneSearchField({
    super.key,
    this.hint,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(shape.full),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: text.bodyLarge?.copyWith(color: scheme.onSurface),
              cursorColor: scheme.primary,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint ?? 'Search',
                hintStyle: text.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                contentPadding: const EdgeInsetsDirectional.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A centred placeholder for empty collections (web `<npt-empty-state>`): an
/// icon in a tinted circle, a display-font title, an optional supporting
/// message, and an optional action. Theme-only, RTL-safe.
class NeptuneEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const NeptuneEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(shape.full),
            ),
            child: Icon(icon, size: 28, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text.titleLarge?.copyWith(
              fontFamily: type.display,
              fontWeight: type.displayFontWeight,
              color: scheme.onSurface,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Tone of a [NeptuneAlert] — drives its tinted background and accent colour.
enum NeptuneAlertTone { info, success, warning, danger }

/// An inline tonal alert (web `<npt-alert>`): a tinted background (alpha-blended
/// by [tone]), a leading accent bar + icon, and an optional title above the
/// message. Theme-only, RTL-safe.
class NeptuneAlert extends StatelessWidget {
  final String message;
  final NeptuneAlertTone tone;
  final String? title;
  final IconData? icon;

  const NeptuneAlert({
    super.key,
    required this.message,
    this.tone = NeptuneAlertTone.info,
    this.title,
    this.icon,
  });

  /// The accent colour for [tone], drawn from the active scheme / Neptune roles.
  Color _accent(ColorScheme scheme, NptColors npt) => switch (tone) {
        NeptuneAlertTone.info => scheme.secondary,
        NeptuneAlertTone.success => npt.success,
        NeptuneAlertTone.warning => scheme.tertiary,
        NeptuneAlertTone.danger => scheme.error,
      };

  /// The default leading icon for [tone].
  IconData _defaultIcon() => switch (tone) {
        NeptuneAlertTone.info => Icons.info_outline,
        NeptuneAlertTone.success => Icons.check_circle_outline,
        NeptuneAlertTone.warning => Icons.warning_amber_outlined,
        NeptuneAlertTone.danger => Icons.error_outline,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final npt = Theme.of(context).extension<NptColors>()!;
    final text = Theme.of(context).textTheme;
    final accent = _accent(scheme, npt);

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: shape.rMd,
        border: BorderDirectional(start: BorderSide(color: accent, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? _defaultIcon(), size: 20, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: text.labelLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: text.bodyMedium?.copyWith(color: scheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width banner (web banner surface): a [secondaryContainer] strip with
/// an optional leading icon, a message, and an optional trailing action.
/// Theme-only, RTL-safe.
class NeptuneBanner extends StatelessWidget {
  final String message;
  final Widget? action;
  final IconData? icon;

  const NeptuneBanner({
    super.key,
    required this.message,
    this.action,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: shape.rMd,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: text.bodyMedium?.copyWith(color: scheme.onSecondaryContainer),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 12),
            action!,
          ],
        ],
      ),
    );
  }
}

/// A loading placeholder block (web `<npt-skeleton>`): a rounded
/// surface-container-highest bone. Set [circle] for an avatar-style dot.
/// Theme-only, RTL-safe.
class NeptuneSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final bool circle;

  const NeptuneSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;

    return Container(
      width: circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: circle ? BorderRadius.circular(shape.full) : shape.rSm,
      ),
    );
  }
}
