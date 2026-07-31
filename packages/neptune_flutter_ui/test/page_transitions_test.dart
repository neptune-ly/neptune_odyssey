import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  setUp(() => NeptuneTheme.debugSkipFontLoading = true);

  test('every generated theme carries the Neptune transition', () {
    final theme = NeptuneTheme.fromConfig(const BrandprintConfig(
      primary: Seed(l: 0.5, c: 0.15, h: 260),
      tertiary: Seed(l: 0.5, c: 0.1, h: 300),
      corners: Corners(xs: 8, sm: 12, md: 16, lg: 20, xl: 28, xxl: 32),
      displayWeight: 700,
      displayTracking: -0.01,
      fontDisplay: "Inter",
      fontText: "Inter",
      fontNum: "Inter",
      loginShell: "brand-canvas",
      dashboardHero: "balance-first",
      contentTone: "calm",
      glassTint: "cool-slate",
      motion: "smooth-fluid",
    ));
    final builders = theme.pageTransitionsTheme.builders;
    expect(builders[TargetPlatform.android],
        isA<NeptunePageTransitionsBuilder>());
    // iOS keeps FLUTTER'S OWN default so the native edge-swipe back gesture
    // survives. Asserted by identity against the framework default rather
    // than by naming CupertinoPageTransitionsBuilder — that symbol moved
    // between Flutter versions and broke a release build once.
    expect(builders[TargetPlatform.iOS],
        same(const PageTransitionsTheme().builders[TargetPlatform.iOS]));
    expect(builders[TargetPlatform.iOS],
        isNot(isA<NeptunePageTransitionsBuilder>()));
  });

  testWidgets('push animates — no hard cut', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(
        platform: TargetPlatform.android,
        pageTransitionsTheme: NeptunePageTransitionsBuilder.theme,
      ),
      home: const Scaffold(body: Text('first')),
    ));
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute(
        builder: (_) => const Scaffold(body: Text('second'))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    // Mid-transition both pages exist and the incoming one is mid-fade.
    expect(find.text('second'), findsOneWidget);
    expect(find.text('first'), findsOneWidget);
    final fades = tester
        .widgetList<FadeTransition>(find.ancestor(
            of: find.text('second'), matching: find.byType(FadeTransition)))
        .toList();
    expect(fades.any((f) => f.opacity.value > 0 && f.opacity.value < 1), isTrue,
        reason: 'incoming page should be mid-fade, not hard-cut');
    await tester.pumpAndSettle();
    expect(find.text('first'), findsNothing);
  });

  testWidgets('reduced motion falls back to plain cross-fade', (tester) async {
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(
        theme: ThemeData(
          platform: TargetPlatform.android,
          pageTransitionsTheme: NeptunePageTransitionsBuilder.theme,
        ),
        home: const Scaffold(body: Text('first')),
      ),
    ));
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute(
        builder: (_) => const Scaffold(body: Text('second'))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    // No SlideTransition wrapping the incoming page under reduced motion.
    final slides = tester.widgetList<SlideTransition>(find.ancestor(
        of: find.text('second'), matching: find.byType(SlideTransition)));
    expect(
        slides.where((s) => s.position.value != Offset.zero), isEmpty,
        reason: 'position must never animate under reduced motion');
    await tester.pumpAndSettle();
  });
}
