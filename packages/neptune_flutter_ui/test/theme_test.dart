// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

const _goldenTriton = 'NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA';

void main() {
  // Keep the google_fonts runtime loader offline in tests — name families only.
  NeptuneTheme.debugSkipFontLoading = true;

  group('NeptuneTheme', () {
    test('light(triton) builds with correct M3 colors + extensions', () {
      final theme = NeptuneTheme.light('triton');
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.colorScheme.primary.toARGB32(), 0xFF00774E);
      expect(theme.extension<NptColors>(), isNotNull);
      expect(theme.extension<NptShape>()!.md, 26);
      expect(theme.extension<NptType>()!.display, 'Bricolage Grotesque');
      expect(theme.extension<NptMotion>(), isNotNull);
    });

    test('dark(triton) builds with dark scheme', () {
      final theme = NeptuneTheme.dark('triton');
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary.toARGB32(), 0xFF7DDBAE);
    });

    test('fromBrandprint(goldenTriton) == light(triton) primary', () {
      final fromBp =
          NeptuneTheme.fromBrandprint(_goldenTriton, brightness: Brightness.light);
      final fromBrand = NeptuneTheme.light('triton');
      expect(fromBp.colorScheme.primary.toARGB32(),
          fromBrand.colorScheme.primary.toARGB32());
      // The brandprint resolves to the pinned reference scheme, so the whole
      // scheme matches, not just primary.
      expect(fromBp.colorScheme.tertiary.toARGB32(),
          fromBrand.colorScheme.tertiary.toARGB32());
      expect(fromBp.extension<NptShape>()!.md,
          fromBrand.extension<NptShape>()!.md);
    });

    test('unknown brand throws', () {
      expect(() => NeptuneTheme.light('nope'), throwsArgumentError);
    });

    test('custom config builds a valid theme', () {
      const cfg = BrandprintConfig(
        primary: Seed(l: 0.55, c: 0.16, h: 20), // teal-free custom seed
        tertiary: Seed(l: 0.60, c: 0.10, h: 120),
        corners: Corners(xs: 5, sm: 9, md: 13, lg: 19, xl: 27, xxl: 37),
        displayWeight: 600,
        displayTracking: -0.015,
        fontDisplay: 'Sora',
        fontText: 'Hanken Grotesk',
        fontNum: 'Sora',
        loginShell: 'depth-emblem',
        dashboardHero: 'balance-cards',
        contentTone: 'clear-calm',
        glassTint: 'oceanic',
        motion: 'smooth-fluid',
      );
      final theme = NeptuneTheme.fromConfig(cfg, brightness: Brightness.light);
      expect(theme.useMaterial3, isTrue);
      // primary is generated from the seed via the ramp, not a reference brand.
      expect(theme.colorScheme.primary.toARGB32() >> 24, 0xFF);
      expect(theme.extension<NptShape>()!.md, 13);
      expect(theme.extension<NptColors>()!.success.toARGB32() >> 24, 0xFF);
      expect(theme.extension<NptType>()!.display, 'Sora');
    });

    testWidgets('widgets render under the theme (LTR + RTL)', (tester) async {
      for (final dir in [TextDirection.ltr, TextDirection.rtl]) {
        await tester.pumpWidget(MaterialApp(
          theme: NeptuneTheme.light('nereid'),
          home: Directionality(
            textDirection: dir,
            child: Scaffold(
              body: ListView(
                children: const [
                  NeptuneBalanceCard(
                      label: 'Available', amount: '1,234.56', caption: 'KWD'),
                  NeptuneTransactionRow(
                      title: 'Salary', amount: '+2,000.00', isCredit: true),
                  NeptuneAccountTile(
                      name: 'Current',
                      maskedNumber: '•••• 1234',
                      balance: '500.00'),
                  NeptunePrimaryButton(label: 'Send'),
                ],
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.text('Available'), findsOneWidget);
        expect(find.text('Send'), findsOneWidget);
      }
    });
  });
}
