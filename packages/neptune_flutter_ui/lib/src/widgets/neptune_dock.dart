// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/identity.dart';
import 'neptune_identity_surfaces.dart';

/// One item in a [NeptuneDock]. The parent owns selection — set [active] on the
/// current item and handle [onTap].
class NeptuneDockItem {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const NeptuneDockItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });
}

/// The floating glass dock (web `<npt-dock>`): a backdrop-blurred
/// surface-container pane with a hairline border and soft elevation, where the
/// active item lifts into a filled accent circle — the signature "raised
/// active" indicator, sprung on the brand's motion curve. Theme-only, RTL-safe.
class NeptuneDock extends StatelessWidget {
  final List<NeptuneDockItem> items;

  const NeptuneDock({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final identity = theme.extension<NptIdentity>()!;

    // The glass pane sits 12px below the top of the hit area so the active
    // item's raised circle can pop ABOVE the bar (web `overflow: visible`).
    // Shadow lives OUTSIDE the glass clip so the blur pane stays clean.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          top: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: shape.rXxl,
              boxShadow: identity.elevation3(scheme),
            ),
            child: NeptuneGlass(
              dock: true,
              borderRadius: shape.rXxl,
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 12, 8, 10),
          child: Row(
            children: [
              for (final it in items) Expanded(child: _DockItem(item: it))
            ],
          ),
        ),
      ],
    );
  }
}

class _DockItem extends StatelessWidget {
  final NeptuneDockItem item;

  const _DockItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final motion = theme.extension<NptMotion>()!;
    final text = theme.textTheme;
    final active = item.active;

    // The raised-active circle springs up on the brand's motion curve and
    // carries the primary key-light while lifted.
    final circle = AnimatedContainer(
      duration: motion.durationStandard,
      curve: motion.spring,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: active ? scheme.primary : scheme.primary.withValues(alpha: 0),
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Icon(
        item.icon,
        size: 22,
        color: active ? scheme.onPrimary : scheme.onSurfaceVariant,
      ),
    );

    return InkWell(
      onTap: item.onTap,
      borderRadius: shape.rLg,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSlide(
              duration: motion.durationStandard,
              curve: motion.spring,
              offset: Offset(0, active ? -0.30 : 0),
              child: circle,
            ),
            AnimatedDefaultTextStyle(
              duration: motion.fast,
              curve: motion.standard,
              style: (text.labelSmall ?? const TextStyle()).copyWith(
                color: active ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.only(top: active ? 0 : 2),
                child: Text(item.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Which M3 top-app-bar layout [NeptuneAppBar] renders (web `<npt-top-app-bar
/// variant="small|center|medium|large">`). `medium`/`large` stack a larger
/// headline below the action row instead of showing the title inline.
enum NeptuneAppBarVariant { small, center, medium, large }

/// A lightweight themed top bar (web `<npt-app-bar>` / `<npt-top-app-bar>`):
/// an optional leading widget, a display-font title, and trailing actions.
/// [variant] picks the M3 layout — `small` (default) and `center` keep the
/// title inline in the 56dp row; `medium`/`large` reserve the row for
/// leading/actions only and drop a bigger headline below it. A plain themed
/// widget — not a Material [AppBar]. RTL-safe.
class NeptuneAppBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final NeptuneAppBarVariant variant;

  const NeptuneAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.variant = NeptuneAppBarVariant.small,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;
    final stacked = variant == NeptuneAppBarVariant.medium || variant == NeptuneAppBarVariant.large;

    final rowTitleStyle = text.titleLarge?.copyWith(
      fontFamily: type.display,
      fontWeight: type.displayFontWeight,
      color: scheme.onSurface,
    );

    final row = Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            // In medium/large the inline title is replaced by the stacked
            // headline below — an empty Expanded still reserves the same
            // space for leading/actions as the web's `visibility:hidden` row
            // title does, without needing an invisible Text underneath.
            child: stacked
                ? const SizedBox.shrink()
                : Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: variant == NeptuneAppBarVariant.center ? TextAlign.center : TextAlign.start,
                    style: rowTitleStyle,
                  ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );

    if (!stacked) {
      // Keep the title reachable to screen readers even though it's the only
      // visible copy — the web version's row title is the sole rendering.
      return Container(color: scheme.surface, child: row);
    }

    final headlineStyle = (variant == NeptuneAppBarVariant.large ? text.displayMedium : text.headlineMedium)
        ?.copyWith(
      fontFamily: type.display,
      fontWeight: type.displayFontWeight,
      letterSpacing: type.displayTracking * (variant == NeptuneAppBarVariant.large ? 45 : 28),
      color: scheme.onSurface,
    );

    return Container(
      color: scheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row,
          // A Semantics wrapper carries the title to assistive tech once —
          // the row above intentionally has no visible/exposed title copy.
          Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 24),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: headlineStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
