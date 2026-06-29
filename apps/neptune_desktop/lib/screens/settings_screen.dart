// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Settings — the white-label showcase. Switching the active brandprint, dark
// mode and RTL/Arabic here reskins the entire app instantly, because every
// screen reads colour/shape/type from the active theme. A live typography
// preview makes the brand + Arabic font swap visible at a glance. Theme-only.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../app/app_scope.dart';
import '../app/app_state.dart';
import '../data/fmt.dart';
import '../widgets/content_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final brandBlock = Block(
      title: 'Brand',
      description:
          'Switch the active brandprint — the whole app reskins instantly.',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final brand in AppState.brands)
            NeptuneChip(
              label: _capitalize(brand),
              selected: app.brand == brand,
              onTap: () {
                app.brand = brand;
                showNeptuneToast(
                    context, '${_capitalize(brand)} brandprint applied');
              },
            ),
        ],
      ),
    );

    final appearanceBlock = Block(
      title: 'Appearance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeptunePermissionToggle(
            label: 'Dark mode',
            description: 'Use the dark brandprint',
            value: app.isDark,
            onChanged: (_) => app.toggleMode(),
          ),
          const SizedBox(height: 4),
          NeptunePermissionToggle(
            label: 'Right-to-left (Arabic)',
            description: 'Mirror layout and use Arabic faces',
            value: app.rtl,
            onChanged: (_) => app.toggleRtl(),
          ),
        ],
      ),
    );

    final typographyBlock = Block(
      title: 'Typography preview',
      description: 'The active brand and direction drive every face below.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Display ${_capitalize(app.brand)}',
            style: text.displaySmall?.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 12),
          Text(
            'Headline sample',
            style: text.headlineSmall?.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Body text shows how supporting copy reads across the active '
            'brandprint, in light and dark, left-to-right and Arabic.',
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            money(12480.5),
            style: NeptuneTheme.moneyStyle(context, base: text.headlineMedium)
                .copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );

    const aboutBlock = Block(
      title: 'About',
      child: NeptuneAlert(
        title: 'White-label',
        message:
            'Neptune Odyssey desktop — white-label by brandprint. Built on '
            'neptune_flutter_ui.',
        tone: NeptuneAlertTone.success,
      ),
    );

    return ContentScaffold(
      title: 'Settings',
      subtitle: 'Brand, appearance and preferences.',
      children: [
        brandBlock,
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 720) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [appearanceBlock, typographyBlock],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: appearanceBlock),
                const SizedBox(width: 16),
                Expanded(child: typographyBlock),
              ],
            );
          },
        ),
        aboutBlock,
      ],
    );
  }
}
