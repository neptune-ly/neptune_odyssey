import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_living_worlds.dart';

void main() {
  testWidgets('Living Worlds supports both modes and directions with scaled controls', (tester) async {
    for (final brand in ['Clarity', 'Reserve', 'Drive', 'Orbit']) {
      for (final brightness in Brightness.values) {
        for (final direction in TextDirection.values) {
          await tester.pumpWidget(MaterialApp(
            theme: odyssey3Theme(brand: brand, brightness: brightness, arabic: direction == TextDirection.rtl),
            home: Directionality(
              textDirection: direction,
              child: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
                child: Scaffold(body: ListView(padding: const EdgeInsets.all(24), children: [
                  const TextField(decoration: InputDecoration(labelText: 'Amount / المبلغ')),
                  FilledButton(onPressed: () {}, child: const Text('Continue / متابعة')),
                ])),
              ),
            ),
          ));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$brand $brightness $direction');
          expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(56));
        }
      }
    }
  });
}
