// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// NeptuneDemoShellApp is the whole point of R5: hand it ANY BrandprintConfig
// (not just a reference brand) and get a running, navigable, bilingual demo
// app for free. This proves that end to end with a custom seed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  const customBrand = BrandprintConfig(
    primary: Seed(l: 0.411, c: 0.099, h: 270),
    tertiary: Seed(l: 0.63, c: 0.212, h: 28),
    corners: Corners(xs: 6, sm: 10, md: 14, lg: 20, xl: 28, xxl: 38),
    displayWeight: 700,
    displayTracking: -0.01,
    fontDisplay: 'Sora',
    fontText: 'Hanken Grotesk',
    fontNum: 'Sora',
    loginShell: 'shield-guilloche',
    dashboardHero: 'restrained-balance',
    contentTone: 'formal-authoritative',
    glassTint: 'navy-steel',
    motion: 'stable-minimal-authoritative',
  );

  testWidgets('demo shell: welcome -> in-app tabs -> transfer outcome -> logout',
      (tester) async {
    await tester.pumpWidget(const NeptuneDemoShellApp(
      brandprint: customBrand,
      bankNameEn: 'Test Bank',
      bankNameAr: 'مصرف تجريبي',
      logo: FlutterLogo(size: 26),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    // Welcome screen renders with the custom brand.
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byType(NeptuneAmbientBackdrop), findsOneWidget);

    // Enter the app.
    await tester.tap(find.text('Get started'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(NeptuneDock), findsOneWidget);
    expect(find.byType(NeptuneDashboardTemplate), findsOneWidget);

    // Walk every tab.
    for (final label in ['Transfer', 'Cards', 'Insights', 'Profile']) {
      await tester.tap(find.text(label));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'tab $label');
    }

    // Transfer -> continue -> confirm -> the linked hourglass/success motion.
    await tester.tap(find.text('Transfer'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Confirm & send'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(NeptuneStatusMotion), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2200));
    expect(find.text('Transfer sent'), findsOneWidget);

    // Logout returns to Welcome.
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Log out'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Get started'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('demo shell: Arabic start + RTL mirrors', (tester) async {
    await tester.pumpWidget(const NeptuneDemoShellApp(
      brandprint: customBrand,
      bankNameEn: 'Test Bank',
      bankNameAr: 'مصرف تجريبي',
      logo: FlutterLogo(size: 26),
      startArabic: true,
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('ابدأ الآن'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
