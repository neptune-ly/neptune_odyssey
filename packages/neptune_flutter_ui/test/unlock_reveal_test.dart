// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// NeptuneUnlockReveal: builds under real NeptuneThemes, the drag ritual
// completes past the threshold and settles back below it, and the
// reduced-motion path unlocks via the cross-fade without the drag animation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

Widget _host(
  Widget child, {
  String brand = 'neptune',
  Brightness brightness = Brightness.light,
  TextDirection dir = TextDirection.ltr,
  bool reduced = false,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: brightness == Brightness.light
        ? NeptuneTheme.light(brand)
        : NeptuneTheme.dark(brand),
    home: Directionality(
      textDirection: dir,
      child: Builder(builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: Scaffold(body: child),
        );
      }),
    ),
  );
}

Finder get _chip => find.byIcon(Icons.keyboard_arrow_up_rounded);

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  testWidgets('builds under NeptuneTheme for 2 brands × light/dark × LTR/RTL',
      (tester) async {
    for (final brand in const ['neptune', 'proteus']) {
      for (final brightness in Brightness.values) {
        for (final dir in TextDirection.values) {
          await tester.pumpWidget(_host(
            NeptuneUnlockReveal(
              onUnlock: () {},
              label: 'Swipe up to open',
              logo: const FlutterLogo(size: 64),
            ),
            brand: brand,
            brightness: brightness,
            dir: dir,
          ));
          await tester.pump(const Duration(milliseconds: 50));
          expect(tester.takeException(), isNull,
              reason: 'brand=$brand $brightness $dir');
          expect(_chip, findsOneWidget);
          await tester.pumpWidget(const SizedBox());
        }
      }
    }
  });

  testWidgets('builds at narrow phone width (390dp)', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(
      NeptuneUnlockReveal(onUnlock: () {}, label: 'Swipe up to open'),
      brand: 'triton',
    ));
    expect(tester.takeException(), isNull);
    expect(_chip, findsOneWidget);
  });

  testWidgets('drag past the threshold completes and fires onUnlock once',
      (tester) async {
    var unlocked = 0;
    await tester.pumpWidget(_host(
      NeptuneUnlockReveal(
        onUnlock: () => unlocked++,
        label: 'Swipe up to open',
      ),
    ));

    // The interactive zone sits over the chip, so drive by coordinates.
    await tester.dragFrom(tester.getCenter(_chip), const Offset(0, -320));
    await tester.pumpAndSettle();
    expect(unlocked, 1);
  });

  testWidgets('release below the threshold springs back without unlocking',
      (tester) async {
    var unlocked = 0;
    await tester.pumpWidget(_host(
      NeptuneUnlockReveal(
        onUnlock: () => unlocked++,
        label: 'Swipe up to open',
      ),
    ));

    // A slow, short drag: well under 60% progress and no fling velocity.
    await tester.timedDragFrom(tester.getCenter(_chip), const Offset(0, -100),
        const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(unlocked, 0);
    // The ritual is still live and intact.
    expect(_chip, findsOneWidget);
    expect(find.text('Swipe up to open'), findsOneWidget);
  });

  testWidgets('reduced motion: tap unlocks via the cross-fade (no drag)',
      (tester) async {
    var unlocked = 0;
    await tester.pumpWidget(_host(
      NeptuneUnlockReveal(
        onUnlock: () => unlocked++,
        label: 'Swipe up to open',
      ),
      reduced: true,
    ));

    await tester.tapAt(tester.getCenter(_chip));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(unlocked, 1);
  });

  testWidgets('reduced motion: a completed drag also unlocks', (tester) async {
    var unlocked = 0;
    await tester.pumpWidget(_host(
      NeptuneUnlockReveal(onUnlock: () => unlocked++),
      reduced: true,
    ));

    await tester.dragFrom(tester.getCenter(_chip), const Offset(0, -320));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(unlocked, 1);
  });
}
