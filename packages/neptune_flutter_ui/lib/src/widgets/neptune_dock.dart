// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

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

/// A floating bottom navigation bar (web `<npt-dock>`): a rounded, elevated
/// surface where the active item lifts into a filled accent circle — the
/// signature "raised active" indicator. Theme-only, RTL-safe.
class NeptuneDock extends StatelessWidget {
  final List<NeptuneDockItem> items;

  const NeptuneDock({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: shape.rXxl,
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [for (final it in items) Expanded(child: _DockItem(item: it))],
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final NeptuneDockItem item;

  const _DockItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final active = item.active;

    final circle = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: active ? scheme.primary : null,
        shape: BoxShape.circle,
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
            Transform.translate(offset: Offset(0, active ? -12 : 0), child: circle),
            Transform.translate(
              offset: Offset(0, active ? -8 : 2),
              child: Text(
                item.label,
                style: text.labelSmall?.copyWith(
                  color: active ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A lightweight themed top bar (web `<npt-app-bar>`): an optional leading
/// widget, an expanded display-font title, and trailing actions. A plain
/// themed widget — not a Material [AppBar]. RTL-safe.
class NeptuneAppBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const NeptuneAppBar({super.key, required this.title, this.leading, this.actions});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;

    return Container(
      color: scheme.surface,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleLarge?.copyWith(
                fontFamily: type.display,
                fontWeight: type.displayFontWeight,
                color: scheme.onSurface,
              ),
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
