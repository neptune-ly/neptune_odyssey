// LOCAL-ONLY showcase for R6's new widget family — not part of the published
// example app entry point. Run: flutter build web --target=lib/r6_showcase_main.dart
import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  runApp(const R6ShowcaseApp());
}

class R6ShowcaseApp extends StatefulWidget {
  const R6ShowcaseApp({super.key});

  @override
  State<R6ShowcaseApp> createState() => _R6ShowcaseAppState();
}

class _R6ShowcaseAppState extends State<R6ShowcaseApp> {
  String _brand = 'proteus';
  bool _dark = false;
  bool _showSplash = false;

  final Map<NeptuneLoaderStyle, NeptuneFlowStatus> _statusByStyle = {
    for (final s in NeptuneLoaderStyle.values) s: NeptuneFlowStatus.loading,
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _dark ? NeptuneTheme.dark(_brand) : NeptuneTheme.light(_brand),
      home: _showSplash
          ? NeptuneSplashScreen(
              brandInitial: _brand[0].toUpperCase(),
              brandName: 'Neptune ${_brand[0].toUpperCase()}${_brand.substring(1)}',
              caption: 'Loading your account…',
            )
          : _Showcase(
              brand: _brand,
              dark: _dark,
              statusByStyle: _statusByStyle,
              onBrand: (b) => setState(() => _brand = b),
              onDark: (v) => setState(() => _dark = v),
              onShowSplash: () => setState(() => _showSplash = true),
              onCycle: (style) => setState(() {
                _statusByStyle[style] = switch (_statusByStyle[style]!) {
                  NeptuneFlowStatus.loading => NeptuneFlowStatus.success,
                  NeptuneFlowStatus.success => NeptuneFlowStatus.rejected,
                  NeptuneFlowStatus.rejected => NeptuneFlowStatus.loading,
                };
              }),
            ),
    );
  }
}

class _Showcase extends StatelessWidget {
  final String brand;
  final bool dark;
  final Map<NeptuneLoaderStyle, NeptuneFlowStatus> statusByStyle;
  final ValueChanged<String> onBrand;
  final ValueChanged<bool> onDark;
  final VoidCallback onShowSplash;
  final ValueChanged<NeptuneLoaderStyle> onCycle;

  const _Showcase({
    required this.brand,
    required this.dark,
    required this.statusByStyle,
    required this.onBrand,
    required this.onDark,
    required this.onShowSplash,
    required this.onCycle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('R6 showcase — loaders, splash, status motion'),
        actions: [
          for (final b in kBrands)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(b),
                selected: brand == b,
                onSelected: (_) => onBrand(b),
              ),
            ),
          const SizedBox(width: 12),
          Row(children: [
            const Text('Dark'),
            Switch(value: dark, onChanged: onDark),
          ]),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeptuneEyebrow('Splash screen', color: scheme.primary),
            const SizedBox(height: 8),
            FilledButton(onPressed: onShowSplash, child: const Text('View full-screen splash')),
            const SizedBox(height: 32),

            NeptuneEyebrow('Standalone loaders', color: scheme.primary),
            const SizedBox(height: 12),
            Wrap(
              spacing: 32,
              runSpacing: 24,
              children: [
                _labeled('Hourglass', const NeptuneHourglassLoader(size: 72)),
                _labeled('Spinner', const NeptuneSpinner(size: 56)),
                _labeled('Dots', const NeptuneDotsLoader(size: 56)),
                _labeled('Pulse', const NeptunePulseLoader(size: 64)),
              ],
            ),
            const SizedBox(height: 32),

            NeptuneEyebrow('Status motion — tap a card to cycle loading → success → reject → loading',
                color: scheme.primary),
            const SizedBox(height: 12),
            Wrap(
              spacing: 32,
              runSpacing: 24,
              children: [
                for (final style in NeptuneLoaderStyle.values)
                  _statusCard(context, style, statusByStyle[style]!),
              ],
            ),
            const SizedBox(height: 32),

            NeptuneEyebrow('Every outcome, statically (no interaction needed)',
                color: scheme.primary),
            const SizedBox(height: 12),
            Wrap(
              spacing: 32,
              runSpacing: 24,
              children: [
                for (final style in NeptuneLoaderStyle.values)
                  _statusCard(context, style, NeptuneFlowStatus.success),
                for (final style in NeptuneLoaderStyle.values)
                  _statusCard(context, style, NeptuneFlowStatus.rejected),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeled(String label, Widget child) {
    return Column(
      children: [
        SizedBox(width: 96, height: 96, child: Center(child: child)),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _statusCard(BuildContext context, NeptuneLoaderStyle style, NeptuneFlowStatus status) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    return InkWell(
      onTap: () => onCycle(style),
      borderRadius: shape.rLg,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: shape.rLg,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Center(child: NeptuneStatusMotion(status: status, loaderStyle: style, size: 84)),
            ),
            const SizedBox(height: 8),
            Text('$style'.split('.').last),
            Text(status.name, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
