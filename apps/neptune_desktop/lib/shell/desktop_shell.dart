// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// The persistent desktop frame: a branded side nav (logo + destinations, Settings
// pinned to the bottom) beside a content column (TopBar + the active screen). An
// IndexedStack keeps each screen's state alive across navigation. Below a narrow
// width the side nav collapses to a compact rail.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../app/app_scope.dart';
import '../app/nav.dart';
import '../screens/accounts_screen.dart';
import '../screens/activity_screen.dart';
import '../screens/cards_screen.dart';
import '../screens/corporate_screen.dart';
import '../screens/overview_screen.dart';
import '../screens/payees_screen.dart';
import '../screens/payments_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/transfers_screen.dart';
import 'top_bar.dart';

class DesktopShell extends StatelessWidget {
  const DesktopShell({super.key});

  static const List<Widget> _screens = [
    OverviewScreen(),
    AccountsScreen(),
    CardsScreen(),
    TransfersScreen(),
    PaymentsScreen(),
    ActivityScreen(),
    PayeesScreen(),
    CorporateScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 920;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SideNav(
                compact: compact,
                current: app.nav,
                onSelect: app.go,
              ),
              Expanded(
                child: Column(
                  children: [
                    const TopBar(),
                    Expanded(
                      child: IndexedStack(
                        index: app.nav.index,
                        children: _screens,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  final bool compact;
  final NavDest current;
  final ValueChanged<NavDest> onSelect;

  const _SideNav({
    required this.compact,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final width = compact ? 76.0 : 248.0;
    final items = kNav.where((m) => m.dest != NavDest.settings).toList();
    const settings = NavMeta(NavDest.settings, 'Settings', Icons.settings_outlined, Icons.settings);

    Widget tile(NavMeta meta) {
      final active = meta.dest == current;
      if (compact) {
        return Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 3),
          child: _CompactNavButton(meta: meta, active: active, onTap: () => onSelect(meta.dest)),
        );
      }
      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 2),
        child: NeptuneSideNavItem(
          icon: active ? meta.selectedIcon : meta.icon,
          label: meta.label,
          active: active,
          onTap: () => onSelect(meta.dest),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        border: BorderDirectional(end: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Leaves room for the macOS window controls.
            const SizedBox(height: 28),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(compact ? 0 : 22, 12, compact ? 0 : 22, 12),
              child: compact
                  ? Center(child: _Logo(scheme: scheme))
                  : Row(
                      children: [
                        _Logo(scheme: scheme),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Neptune', style: text.titleMedium?.copyWith(color: scheme.onSurface, height: 1.05)),
                              Text('Odyssey', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.05)),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.only(top: 4),
                children: items.map(tile).toList(),
              ),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 6, bottom: 14),
              child: tile(settings),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final ColorScheme scheme;
  const _Logo({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
      child: Icon(Icons.water_drop_rounded, size: 20, color: scheme.onPrimary),
    );
  }
}

class _CompactNavButton extends StatelessWidget {
  final NavMeta meta;
  final bool active;
  final VoidCallback onTap;

  const _CompactNavButton({required this.meta, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = active ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;
    return Tooltip(
      message: meta.label,
      child: Material(
        color: active ? scheme.secondaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: Theme.of(context).extension<NptShape>()!.rMd,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Icon(active ? meta.selectedIcon : meta.icon, color: fg, size: 22),
          ),
        ),
      ),
    );
  }
}
