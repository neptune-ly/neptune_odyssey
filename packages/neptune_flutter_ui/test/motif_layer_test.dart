// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Guards the exact failure mode _MotifPainter's switch is exposed to: it has
// no `default:` case, so a motif kind missing from the switch paints nothing
// — a silent blank region, not a compile error. One golden per kind catches
// that immediately instead of relying on code review.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

Widget _harness(NptMotifKind kind) => MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          width: 240,
          height: 160,
          child: NeptuneMotifLayer(color: Colors.black, strength: 1),
        ),
      ),
      theme: ThemeData(
        extensions: [
          NptIdentity(
            motif: kind,
            motifStrength: 1,
            glassOnTertiary: false,
            glassMixRatio: 0.1,
            glassSurfaceOpacity: 0.7,
            glassBlur: 16,
            dashboardHero: 'x',
            loginShell: 'x',
            contentTone: 'x',
          ),
        ],
      ),
    );

void main() {
  for (final kind in NptMotifKind.values) {
    testWidgets('motif ${kind.name} paints a non-blank layer', (tester) async {
      await tester.pumpWidget(_harness(kind));
      await expectLater(
        find.byType(NeptuneMotifLayer),
        matchesGoldenFile('goldens/motif_${kind.name}.png'),
      );
    });
  }
}
