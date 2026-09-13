// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The two composition levers added in 2.28.0: `navShell` (the bar a bank's
// signed-in app stands on) and `actionRow` (the quick-action treatment).
//
// The point of the levers is that the three shells are DIFFERENT SHAPES, not
// three tints of one shape - so these tests assert the structure each one
// draws, and that the raised dock and the tonal circle are still exactly what
// a brandprint that names no shell gets.

import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  Widget host(Widget child,
          {TextDirection dir = TextDirection.ltr,
          Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: brightness == Brightness.light
            ? NeptuneTheme.light('neptune')
            : NeptuneTheme.dark('neptune'),
        home: Directionality(
          textDirection: dir,
          child: Scaffold(body: child),
        ),
      );

  List<NeptuneDockItem> items({int active = 0}) => [
        for (final (i, label) in ['Home', 'Cards', 'Pay', 'More'].indexed)
          NeptuneDockItem(
            icon: Icons.circle_outlined,
            label: label,
            active: i == active,
            onTap: () {},
          ),
      ];

  List<NeptuneQuickAction> actions() => [
        for (final label in ['Transfer', 'QR', 'Vouchers', 'Services'])
          NeptuneQuickAction(
            icon: Icons.circle_outlined,
            label: label,
            onTap: () {},
          ),
      ];

  group('the navShell lever', () {
    test('every wire name in the registry has a shell behind it', () {
      expect(kNavShells.length, NeptuneDockShell.values.length);
      expect(kActionRows.length, NeptuneQuickActionShell.values.length);
    });

    test('both levers survive the wire, and default to what exists today', () {
      const base = BrandprintConfig(
        primary: Seed(l: 0.48, c: 0.15, h: 258),
        tertiary: Seed(l: 0.55, c: 0.10, h: 200),
        corners: Corners(xs: 8, sm: 12, md: 16, lg: 24, xl: 32, xxl: 44),
        displayWeight: 700,
        displayTracking: -0.02,
        fontDisplay: 'Hanken Grotesk',
        fontText: 'Hanken Grotesk',
        fontNum: 'Hanken Grotesk',
        loginShell: 'depth-emblem',
        dashboardHero: 'balance-cards',
        contentTone: 'clear-calm',
        glassTint: 'oceanic',
        motion: 'smooth-fluid',
      );

      // A config that names no shell is byte-for-byte the string it was
      // before the nibble was claimed, and decodes to the dock it has today.
      expect(Brandprint.decode(Brandprint.encode(base)).navShell,
          'raised-dock');
      expect(Brandprint.decode(Brandprint.encode(base)).actionRow,
          'filled-circles');

      for (final nav in kNavShells) {
        for (final row in kActionRows) {
          final cfg = BrandprintConfig(
            primary: base.primary,
            tertiary: base.tertiary,
            corners: base.corners,
            displayWeight: base.displayWeight,
            displayTracking: base.displayTracking,
            fontDisplay: base.fontDisplay,
            fontText: base.fontText,
            fontNum: base.fontNum,
            loginShell: base.loginShell,
            dashboardHero: base.dashboardHero,
            contentTone: base.contentTone,
            glassTint: base.glassTint,
            motion: base.motion,
            whiteGround: true,
            accentOnTertiary: true,
            navShell: nav,
            actionRow: row,
          );
          final back = Brandprint.decode(Brandprint.encode(cfg));
          expect(back.navShell, nav);
          expect(back.actionRow, row);
          // The nibble must not eat the flags that share the byte.
          expect(back.whiteGround, isTrue);
          expect(back.accentOnTertiary, isTrue);
        }
      }
    });

    test('the levers reach the theme extension', () {
      final identity = NeptuneTheme.light('neptune').extension<NptIdentity>()!;
      expect(identity.navShell, 'raised-dock');
      expect(identity.actionRow, 'filled-circles');
    });
  });

  group('the dock shells are different shapes', () {
    testWidgets('raised keeps the glass pane and the lifting circle',
        (tester) async {
      await tester.pumpWidget(host(NeptuneDock(items: items())));
      expect(find.byType(NeptuneGlass), findsOneWidget);
      expect(find.byType(AnimatedSlide), findsNWidgets(4));
    });

    testWidgets('register floats nothing and lifts nothing', (tester) async {
      await tester.pumpWidget(host(NeptuneDock(
        items: items(),
        shell: NeptuneDockShell.register,
      )));
      expect(find.byType(NeptuneGlass), findsNothing);
      expect(find.byType(AnimatedSlide), findsNothing);
      // The active item is marked by weight, so it reads in greyscale.
      final active = tester.widget<DefaultTextStyle>(find
          .ancestor(
              of: find.text('Home'), matching: find.byType(DefaultTextStyle))
          .first);
      final idle = tester.widget<DefaultTextStyle>(find
          .ancestor(
              of: find.text('Cards'), matching: find.byType(DefaultTextStyle))
          .first);
      expect(active.style.fontWeight, FontWeight.w700);
      expect(idle.style.fontWeight, FontWeight.w500);
    });

    testWidgets('rule marks the active item on the rule, in the accent',
        (tester) async {
      await tester.pumpWidget(host(NeptuneDock(
        items: items(active: 2),
        shell: NeptuneDockShell.rule,
      )));
      expect(find.byType(NeptuneGlass), findsNothing);

      final accent =
          NeptuneTheme.light('neptune').extension<NptColors>()!.accent;
      final segments = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.color == accent)
          .toList();
      expect(segments, hasLength(1),
          reason: 'the accent is spent once: one segment, on the active item');
    });

    testWidgets('every shell builds under RTL and in the dark',
        (tester) async {
      for (final shell in NeptuneDockShell.values) {
        await tester.pumpWidget(host(
          NeptuneDock(items: items(active: 1), shell: shell),
          dir: TextDirection.rtl,
          brightness: Brightness.dark,
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Cards'), findsOneWidget);
      }
    });

    testWidgets('a flat bar eats the bottom safe area inside its own fill',
        (tester) async {
      // The bar is opaque all the way to the screen edge, or a page that
      // scrolls behind it (`extendBody: true`) shows through the gesture-bar
      // strip - which is how a transaction divider ended up drawn beside the
      // home pill on a real handset. Padding the widget from OUTSIDE cannot
      // fix that, so the inset has to be measured inside the fill: the flat
      // bar must grow by exactly the inset it was handed.
      for (final shell in [NeptuneDockShell.register, NeptuneDockShell.rule]) {
        final heights = <double>[];
        for (final inset in [0.0, 48.0]) {
          await tester.pumpWidget(MaterialApp(
            theme: NeptuneTheme.light('neptune'),
            home: MediaQuery(
              data: MediaQueryData(padding: EdgeInsets.only(bottom: inset)),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Scaffold(
                  body: Align(
                    alignment: Alignment.bottomCenter,
                    child: NeptuneDock(items: items(), shell: shell),
                  ),
                ),
              ),
            ),
          ));
          await tester.pumpAndSettle();
          heights.add(tester.getSize(find.byType(NeptuneDock).first).height);
        }
        expect(heights[1] - heights[0], 48.0, reason: '$shell');
      }
    });

    testWidgets('a flat item is still a selected tab to a screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(NeptuneDock(
        items: items(active: 1),
        shell: NeptuneDockShell.register,
      )));
      final node = tester.getSemantics(find.bySemanticsLabel('Cards'));
      expect(node.flagsCollection.isSelected, Tristate.isTrue);
      expect(node.flagsCollection.isButton, isTrue);
      handle.dispose();
    });
  });

  group('the quick-action shells are different shapes', () {
    Color? chipColour(WidgetTester tester) => tester
        .widgetList<Material>(find.descendant(
            of: find.byType(NeptuneQuickActions), matching: find.byType(Material)))
        .map((m) => m.color)
        .firstWhere((c) => c != null, orElse: () => null);

    testWidgets('filled circles is still the default treatment',
        (tester) async {
      await tester.pumpWidget(host(NeptuneQuickActions(actions: actions())));
      final scheme = NeptuneTheme.light('neptune').colorScheme;
      expect(chipColour(tester), scheme.secondaryContainer);
    });

    testWidgets('register rows draw no chip at all', (tester) async {
      await tester.pumpWidget(host(NeptuneQuickActions(
        actions: actions(),
        shell: NeptuneQuickActionShell.registerRows,
      )));
      final scheme = NeptuneTheme.light('neptune').colorScheme;
      expect(chipColour(tester), isNot(scheme.secondaryContainer));
      expect(find.byType(IntrinsicHeight), findsOneWidget);
    });

    testWidgets('the rule grid spends the accent on the lead action only',
        (tester) async {
      await tester.pumpWidget(host(NeptuneQuickActions(
        actions: actions(),
        shell: NeptuneQuickActionShell.ruleGrid,
      )));
      final accent =
          NeptuneTheme.light('neptune').extension<NptColors>()!.accent;
      final accented = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where((d) =>
              (d.decoration as BoxDecoration).border?.top.color == accent)
          .toList();
      expect(accented, hasLength(1));
    });

    testWidgets('every shell builds under RTL and in the dark',
        (tester) async {
      for (final shell in NeptuneQuickActionShell.values) {
        await tester.pumpWidget(host(
          NeptuneQuickActions(actions: actions(), shell: shell),
          dir: TextDirection.rtl,
          brightness: Brightness.dark,
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Vouchers'), findsOneWidget);
      }
    });
  });
}
