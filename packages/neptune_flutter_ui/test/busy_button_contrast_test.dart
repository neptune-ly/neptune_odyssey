import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// A busy filled button keeps the colours it was chosen with, so the spinner is never drawn on the grey disabled ground.
void main() {
  for (final seed in [const Color(0xFF07A1BF), const Color(0xFFC9A227), const Color(0xFF1B1B1B), const Color(0xFFFFE0B2)]) {
    testWidgets('busy filled button: spinner on primary, seed $seed', (tester) async {
      final scheme = ColorScheme.fromSeed(seedColor: seed);
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(colorScheme: scheme, useMaterial3: true),
        home: const Scaffold(body: NeptuneButton(label: 'Confirm', busy: true)),
      ));
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final bg = button.style!.backgroundColor?.resolve({WidgetState.disabled});
      final fg = button.style!.foregroundColor?.resolve({WidgetState.disabled});
      expect(bg, scheme.primary);
      expect(fg, scheme.onPrimary);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  }

  for (final style in NeptuneButtonStyle.values) {
    testWidgets('a label that wraps stays centred in the button ($style)', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
            body: NeptuneButton(
                label: 'Make another transaction', variant: style, onPressed: () {})),
      ));
      expect(tester.widget<Text>(find.text('Make another transaction')).textAlign,
          TextAlign.center);
    });
  }
}
