// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// The application frame (web `<npt-app-shell>`): an optional sticky [header]
/// row, an inline-start [nav] sidebar (full 280dp, or a narrow 88dp [rail]), and
/// the [child] content region. The nav collapses away below [breakpoint] so the
/// content takes the full width — exactly like the web `@max-width:768` rule.
/// Theme-only, RTL-safe (logical layout mirrors automatically).
class NeptuneAppShell extends StatelessWidget {
  final Widget? header;
  final Widget? nav;
  final Widget child;
  final bool rail;
  final double breakpoint;

  const NeptuneAppShell({
    super.key,
    this.header,
    this.nav,
    required this.child,
    this.rail = false,
    this.breakpoint = 768,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= breakpoint && nav != null;
        final Widget body = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      border: BorderDirectional(
                        end: BorderSide(color: scheme.outlineVariant),
                      ),
                    ),
                    child: SizedBox(width: rail ? 88 : 280, child: nav),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(24),
                      child: child,
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsetsDirectional.all(16),
                child: child,
              );

        return Column(
          children: [
            if (header != null)
              Material(color: scheme.surfaceContainer, child: header),
            Expanded(child: body),
          ],
        );
      },
    );
  }
}

/// The vertical sidebar nav container (web `<npt-side-nav>`): a
/// [surfaceContainer] column of [NeptuneSideNavItem]s. Theme-only, RTL-safe.
class NeptuneSideNav extends StatelessWidget {
  final List<Widget> children;

  const NeptuneSideNav({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: 4),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// One row of a [NeptuneSideNav] (web `<npt-side-nav-item>`): a pill with an
/// optional leading [icon], a [label], and an optional [trailing] slot (counts /
/// badges). [active] fills it with the secondary container; [enabled] gates
/// taps. Theme-only, RTL-safe, ≥48dp.
class NeptuneSideNavItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool active;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const NeptuneSideNavItem({
    super.key,
    this.icon,
    required this.label,
    this.active = false,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fg = active ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;

    final row = Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: fg),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelLarge?.copyWith(color: fg),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const StadiumBorder(),
        child: row,
      ),
    );

    final pill = active
        ? Material(
            color: scheme.secondaryContainer,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: content,
          )
        : Material(
            type: MaterialType.transparency,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: content,
          );

    return enabled ? pill : Opacity(opacity: 0.38, child: pill);
  }
}

/// A horizontal toolbar surface (web `<npt-toolbar>`) with [start] / [center] /
/// [end] regions. `start` and `end` mirror in RTL via logical layout; `center`
/// stays centred. Theme-only, RTL-safe, ≥56dp.
class NeptuneToolbar extends StatelessWidget {
  final List<Widget> start;
  final List<Widget> center;
  final List<Widget> end;

  const NeptuneToolbar({
    super.key,
    this.start = const [],
    this.center = const [],
    this.end = const [],
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: shape.rLg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _group(start),
              // Center children get BOUNDED width (Flexible) — a bare Row hands
              // its children unbounded width, which breaks flex widgets like
              // NeptuneSearchField placed in the center slot.
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < center.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Flexible(child: center[i]),
                    ],
                  ],
                ),
              ),
              _group(end),
            ],
          ),
        ),
      ),
    );
  }

  Widget _group(List<Widget> items) =>
      Row(mainAxisSize: MainAxisSize.min, children: _spaced(items));

  List<Widget> _spaced(List<Widget> items) => [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          items[i],
        ],
      ];
}

/// One destination of a [NeptuneNavRail].
class NeptuneNavRailItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const NeptuneNavRailItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// The desktop/tablet side rail (web `<npt-nav-rail>`): a themed Material
/// [NavigationRail] that picks its brand colours from the active theme. Provide
/// [leading] (e.g. a FAB/logo) and [trailing] slots as needed. Theme-only,
/// RTL-safe.
class NeptuneNavRail extends StatelessWidget {
  final List<NeptuneNavRailItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Widget? leading;
  final Widget? trailing;

  const NeptuneNavRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return NavigationRail(
      backgroundColor: scheme.surface,
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      leading: leading,
      trailing: trailing,
      labelType: NavigationRailLabelType.all,
      destinations: [
        for (final item in items)
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon ?? item.icon),
            label: Text(item.label),
          ),
      ],
    );
  }
}
