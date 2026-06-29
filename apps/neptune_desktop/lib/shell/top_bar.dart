// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// The desktop top bar: global search plus the white-label controls (cycle brand,
// light/dark, LTR/RTL+Arabic) and the account avatar. Responsive — the search
// flexes and the brand pill + avatar condense on narrow widths so the bar never
// overflows. Theme-only: surface, borders and type come from the brandprint.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../app/app_scope.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: BorderDirectional(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 12, 10),
          child: LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 620;
              return Row(
                children: [
                  // Search flexes to fill, capped at a readable width.
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: const NeptuneSearchField(hint: 'Search payments, payees, cards…'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (wide)
                    _BrandPill(brand: app.brand, onTap: app.cycleBrand)
                  else
                    IconButton(
                      tooltip: 'Cycle brand',
                      onPressed: app.cycleBrand,
                      icon: const Icon(Icons.palette_outlined),
                    ),
                  IconButton(
                    tooltip: 'Toggle direction (LTR / RTL)',
                    onPressed: app.toggleRtl,
                    icon: Icon(app.rtl
                        ? Icons.format_textdirection_r_to_l
                        : Icons.format_textdirection_l_to_r),
                  ),
                  IconButton(
                    tooltip: app.isDark ? 'Switch to light' : 'Switch to dark',
                    onPressed: app.toggleMode,
                    icon: Icon(app.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                  ),
                  if (wide) ...[
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: scheme.primaryContainer,
                      child: Text('LA',
                          style: text.labelLarge?.copyWith(color: scheme.onPrimaryContainer)),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandPill extends StatelessWidget {
  final String brand;
  final VoidCallback onTap;

  const _BrandPill({required this.brand, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final label = brand[0].toUpperCase() + brand.substring(1);

    return Material(
      color: scheme.secondaryContainer,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.palette_outlined, size: 18, color: scheme.onSecondaryContainer),
                const SizedBox(width: 8),
                Text('Brand · $label',
                    style: text.labelLarge?.copyWith(color: scheme.onSecondaryContainer)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
