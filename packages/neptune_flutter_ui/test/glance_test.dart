// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  group('NptGlance (2.26.0)', () {
    test('every assembled theme carries the standard wrist scale', () {
      for (final brand in kBrands) {
        for (final dark in [false, true]) {
          final theme = dark ? NeptuneTheme.dark(brand) : NeptuneTheme.light(brand);
          final glance = theme.extension<NptGlance>();
          expect(glance, isNotNull, reason: '$brand dark=$dark');
          expect(glance, same(NptGlance.standard));
        }
      }
    });

    test('the scale is the one the native watch targets pin', () {
      // Wear OS `GlanceScale.kt` and watchOS `GlanceBrand.swift` copy these
      // numbers and test against them; a change here is a change there.
      const g = NptGlance.standard;
      expect(g.figure, 30);
      expect(g.unit, 13);
      expect(g.eyebrow, 11);
      expect(g.eyebrowTracking, 0.08);
      expect(g.provenance, 12);
      expect(g.rowTitle, 14);
      expect(g.rowMeta, 12);
      expect(g.roundInsetFraction, 0.10);
      expect(g.sectionGap, 12);
      expect(g.rowGap, 6);
      expect(g.minTouch, 48);
    });

    test('inset is a tenth of the diameter on every side', () {
      expect(NptGlance.standard.insetFor(200), const EdgeInsetsDirectional.all(20));
    });

    testWidgets('figure style is tabular and swaps to the Arabic num face under RTL',
        (tester) async {
      late TextStyle ltr;
      late TextStyle rtl;
      await tester.pumpWidget(MaterialApp(
        theme: NeptuneTheme.light('neptune'),
        home: Builder(builder: (context) {
          ltr = Theme.of(context).extension<NptGlance>()!.figureStyle(context);
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(builder: (context) {
              rtl = Theme.of(context).extension<NptGlance>()!.figureStyle(context);
              return const SizedBox();
            }),
          );
        }),
      ));
      final NptType type = NeptuneTheme.light('neptune').extension<NptType>()!;
      expect(ltr.fontFamily, type.num);
      expect(rtl.fontFamily, type.numAr);
      expect(ltr.fontFeatures, contains(const FontFeature.tabularFigures()));
      expect(ltr.fontSize, 30);
    });

    test('lerp interpolates every field', () {
      final a = NptGlance.standard;
      final b = a.copyWith(figure: 40, rowGap: 10);
      final mid = a.lerp(b, 0.5);
      expect(mid.figure, 35);
      expect(mid.rowGap, 8);
      expect(mid.unit, a.unit);
    });
  });
}
