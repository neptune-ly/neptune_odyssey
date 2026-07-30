// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// 2.15.0 — white-label icon slots. NeptuneDockItem / NeptuneQuickAction /
// NeptuneAccountTile accept a host-supplied `iconWidget` (a per-brand SVG,
// ImageIcon, lettermark…) alongside the Material `IconData` path, and the
// supplied widget inherits exactly the tint the glyph would have received.
// Plus NeptuneDock's optional centre gap for a host-owned FAB.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

Widget _host(
  Widget child, {
  String brand = 'neptune',
  Brightness brightness = Brightness.light,
  TextDirection dir = TextDirection.ltr,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: brightness == Brightness.light
        ? NeptuneTheme.light(brand)
        : NeptuneTheme.dark(brand),
    home: Directionality(
      textDirection: dir,
      child: Scaffold(
        body: SafeArea(
          child: Column(children: [const Spacer(), child]),
        ),
      ),
    ),
  );
}

/// A stand-in for a host's brand SVG: it reports the [IconTheme] /
/// [DefaultTextStyle] tint it was handed, which is precisely what a mark
/// painting with `currentColor` would resolve.
class _ProbeMark extends StatelessWidget {
  final void Function(Color? icon, Color? text, double? size) onResolve;

  const _ProbeMark({required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    onResolve(
      iconTheme.color,
      DefaultTextStyle.of(context).style.color,
      iconTheme.size,
    );
    return const SizedBox.shrink();
  }
}

/// Non-const so the constructor's assert is evaluated at runtime rather than
/// const-folded into a compile-time error.
String _runtimeLabel() => 'Home';

/// Horizontal centres of the dock's item cells, in visual order. The raised
/// circle's [AnimatedSlide] is one-per-item, cross-axis-centred, so its centre
/// dx is the cell's centre dx.
List<double> _cellCentres(WidgetTester tester) {
  final slides = find.descendant(
    of: find.byType(NeptuneDock),
    matching: find.byType(AnimatedSlide),
  );
  return [
    for (var i = 0; i < tester.widgetList(slides).length; i++)
      tester.getCenter(slides.at(i)).dx,
  ];
}

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  // ── The IconData path is untouched ────────────────────────────────────────

  testWidgets('IconData path renders unchanged on all three widgets',
      (tester) async {
    await tester.pumpWidget(_host(
      Column(
        children: [
          const NeptuneAccountTile(
            name: 'Everyday',
            maskedNumber: '•••• 4821',
            balance: 'LYD 12,480.50',
            icon: Icons.savings_outlined,
          ),
          NeptuneQuickActions(
            actions: [
              NeptuneQuickAction(icon: Icons.north_east, label: 'Send', onTap: () {}),
            ],
          ),
          NeptuneDock(items: [
            NeptuneDockItem(icon: Icons.home_rounded, label: 'Home', active: true, onTap: () {}),
            NeptuneDockItem(icon: Icons.person_outline, label: 'Profile', onTap: () {}),
          ]),
        ],
      ),
    ));

    expect(find.byIcon(Icons.savings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.north_east), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the default account-tile glyph still applies', (tester) async {
    await tester.pumpWidget(_host(const NeptuneAccountTile(
      name: 'Everyday',
      maskedNumber: '•••• 4821',
      balance: 'LYD 12,480.50',
    )));
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
  });

  // ── The iconWidget path ──────────────────────────────────────────────────

  testWidgets('iconWidget replaces the glyph on all three widgets',
      (tester) async {
    await tester.pumpWidget(_host(
      Column(
        children: [
          const NeptuneAccountTile(
            name: 'Everyday',
            maskedNumber: '•••• 4821',
            balance: 'LYD 12,480.50',
            icon: null,
            iconWidget: FlutterLogo(size: 20),
          ),
          NeptuneQuickActions(
            actions: [
              NeptuneQuickAction(
                iconWidget: const FlutterLogo(size: 20),
                label: 'Send',
                onTap: () {},
              ),
            ],
          ),
          NeptuneDock(items: [
            NeptuneDockItem(
              iconWidget: const FlutterLogo(size: 18),
              label: 'Home',
              active: true,
              onTap: () {},
            ),
            NeptuneDockItem(
              iconWidget: const FlutterLogo(size: 18),
              label: 'Profile',
              onTap: () {},
            ),
          ]),
        ],
      ),
    ));

    expect(find.byType(FlutterLogo), findsNWidgets(4));
    // No Material glyph is substituted in for a supplied mark.
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('iconWidget builds across brands × light/dark × LTR/RTL',
      (tester) async {
    for (final brand in const ['neptune', 'triton', 'nereid', 'proteus']) {
      for (final brightness in Brightness.values) {
        for (final dir in TextDirection.values) {
          await tester.pumpWidget(_host(
            NeptuneDock(centerGap: true, items: [
              NeptuneDockItem(iconWidget: const FlutterLogo(size: 18), label: 'Home', active: true, onTap: () {}),
              NeptuneDockItem(icon: Icons.credit_card, label: 'Cards', onTap: () {}),
              NeptuneDockItem(iconWidget: const FlutterLogo(size: 18), label: 'Pay', onTap: () {}),
              NeptuneDockItem(icon: Icons.person_outline, label: 'Profile', onTap: () {}),
            ]),
            brand: brand,
            brightness: brightness,
            dir: dir,
          ));
          await tester.pump(const Duration(milliseconds: 50));
          expect(tester.takeException(), isNull,
              reason: 'brand=$brand $brightness $dir');
          await tester.pumpWidget(const SizedBox());
        }
      }
    }
  });

  // ── Colour inheritance ───────────────────────────────────────────────────

  testWidgets('dock: a supplied mark inherits the active/inactive tint',
      (tester) async {
    Color? activeIcon, activeText, inactiveIcon, inactiveText;
    double? activeSize;

    await tester.pumpWidget(_host(
      NeptuneDock(items: [
        NeptuneDockItem(
          iconWidget: _ProbeMark(onResolve: (i, t, s) {
            activeIcon = i;
            activeText = t;
            activeSize = s;
          }),
          label: 'Home',
          active: true,
          onTap: () {},
        ),
        NeptuneDockItem(
          iconWidget: _ProbeMark(onResolve: (i, t, _) {
            inactiveIcon = i;
            inactiveText = t;
          }),
          label: 'Profile',
          onTap: () {},
        ),
      ]),
    ));

    final scheme = NeptuneTheme.light('neptune').colorScheme;
    expect(activeIcon, scheme.onPrimary);
    expect(activeText, scheme.onPrimary);
    expect(inactiveIcon, scheme.onSurfaceVariant);
    expect(inactiveText, scheme.onSurfaceVariant);
    // The mark is handed the same 22dp box the Material glyph occupies.
    expect(activeSize, 22);
  });

  testWidgets('dock: the inherited tint follows a selection change',
      (tester) async {
    Color? first;

    Widget dock({required bool firstActive}) => _host(
          NeptuneDock(items: [
            NeptuneDockItem(
              iconWidget: _ProbeMark(onResolve: (i, _, __) => first = i),
              label: 'Home',
              active: firstActive,
              onTap: () {},
            ),
            NeptuneDockItem(icon: Icons.person_outline, label: 'Profile', active: !firstActive, onTap: () {}),
          ]),
        );

    final scheme = NeptuneTheme.light('neptune').colorScheme;

    await tester.pumpWidget(dock(firstActive: false));
    expect(first, scheme.onSurfaceVariant);

    await tester.pumpWidget(dock(firstActive: true));
    await tester.pump();
    expect(first, scheme.onPrimary);
  });

  testWidgets('quick action + account tile publish their container tints',
      (tester) async {
    Color? quickIcon, quickText, tileIcon, tileText;

    await tester.pumpWidget(_host(Column(
      children: [
        NeptuneAccountTile(
          name: 'Everyday',
          maskedNumber: '•••• 4821',
          balance: 'LYD 12,480.50',
          iconWidget: _ProbeMark(onResolve: (i, t, _) {
            tileIcon = i;
            tileText = t;
          }),
        ),
        NeptuneQuickActions(actions: [
          NeptuneQuickAction(
            iconWidget: _ProbeMark(onResolve: (i, t, _) {
              quickIcon = i;
              quickText = t;
            }),
            label: 'Send',
            onTap: () {},
          ),
        ]),
      ],
    )));

    final scheme = NeptuneTheme.light('neptune').colorScheme;
    expect(tileIcon, scheme.onPrimaryContainer);
    expect(tileText, scheme.onPrimaryContainer);
    expect(quickIcon, scheme.onSecondaryContainer);
    expect(quickText, scheme.onSecondaryContainer);
  });

  // ── The dock's centre gap ────────────────────────────────────────────────

  testWidgets('centerGap reserves space and is a no-op when unused',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    List<NeptuneDockItem> items() => [
          NeptuneDockItem(icon: Icons.home_rounded, label: 'Home', onTap: () {}),
          NeptuneDockItem(icon: Icons.credit_card, label: 'Cards', onTap: () {}),
          NeptuneDockItem(icon: Icons.qr_code_rounded, label: 'Pay', onTap: () {}),
          NeptuneDockItem(icon: Icons.person_outline, label: 'Profile', onTap: () {}),
        ];

    // No-op path: four evenly-pitched cells, exactly as before the option.
    await tester.pumpWidget(_host(NeptuneDock(items: items())));
    final plain = _cellCentres(tester);
    expect(plain, hasLength(4));
    final pitch = plain[1] - plain[0];
    expect(plain[2] - plain[1], closeTo(pitch, 0.5));
    expect(plain[3] - plain[2], closeTo(pitch, 0.5));

    // Gapped path: the two middle cells are pushed apart by exactly the gap,
    // and the outer pitches stay uniform (narrower cells, even pitch).
    await tester.pumpWidget(_host(
      NeptuneDock(items: items(), centerGap: true, centerGapWidth: 72),
    ));
    final gapped = _cellCentres(tester);
    expect(gapped, hasLength(4));
    final gappedPitch = gapped[1] - gapped[0];
    expect(gapped[3] - gapped[2], closeTo(gappedPitch, 0.5));
    expect(gapped[2] - gapped[1], closeTo(gappedPitch + 72, 0.5));
    // Cells give up exactly the gap between them: 4 cells lose 72/4 each.
    expect(gappedPitch, closeTo(pitch - 72 / 4, 0.5));
    // With an even item count the hole straddles the dock's centre line.
    expect((gapped[1] + gapped[2]) / 2, closeTo(400 / 2, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('centerGap keeps the glass pane and the raised-active spring',
      (tester) async {
    Widget dock({required bool homeActive}) =>
        _host(NeptuneDock(centerGap: true, items: [
          NeptuneDockItem(icon: Icons.home_rounded, label: 'Home', active: homeActive, onTap: () {}),
          NeptuneDockItem(icon: Icons.person_outline, label: 'Profile', active: !homeActive, onTap: () {}),
        ]));

    await tester.pumpWidget(dock(homeActive: false));
    expect(find.descendant(of: find.byType(NeptuneDock), matching: find.byType(NeptuneGlass)), findsOneWidget);
    // One raised-active slide + circle per item, gap or no gap.
    expect(find.descendant(of: find.byType(NeptuneDock), matching: find.byType(AnimatedSlide)), findsNWidgets(2));
    expect(find.descendant(of: find.byType(NeptuneDock), matching: find.byType(AnimatedContainer)), findsNWidgets(2));

    // The spring still lifts the newly-active circle above the bar.
    final resting = tester.getCenter(find.byIcon(Icons.home_rounded)).dy;
    await tester.pumpWidget(dock(homeActive: true));
    await tester.pump(const Duration(milliseconds: 120));
    final midFlight = tester.getCenter(find.byIcon(Icons.home_rounded)).dy;
    expect(midFlight, lessThan(resting));
    await tester.pumpAndSettle();
    expect(tester.getCenter(find.byIcon(Icons.home_rounded)).dy, lessThan(resting));
    expect(tester.takeException(), isNull);
  });

  // Regression: the raised-active key-light used to be `active ? [shadow] :
  // null`, so BoxDecoration.lerp padded the shorter list with
  // BoxShadow.scale(1 - t) — and the brand spring overshoots outside 0..1, so
  // the factor went negative and dart:ui asserted on a negative blur radius the
  // first time the selection actually changed. Plain dock, no gap.
  testWidgets('changing the active item does not throw on the spring overshoot',
      (tester) async {
    Widget dock({required int active}) => _host(NeptuneDock(items: [
          for (var i = 0; i < 4; i++)
            NeptuneDockItem(icon: Icons.home_rounded, label: 'Tab $i', active: i == active, onTap: () {}),
        ]));

    await tester.pumpWidget(dock(active: 0));
    for (final next in const [1, 2, 3, 0]) {
      await tester.pumpWidget(dock(active: next));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'active=$next');
    }
  });

  testWidgets('centerGap taps still reach the surviving items', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(NeptuneDock(centerGap: true, items: [
      NeptuneDockItem(icon: Icons.home_rounded, label: 'Home', onTap: () => taps++),
      NeptuneDockItem(icon: Icons.person_outline, label: 'Profile', onTap: () => taps++),
    ])));

    await tester.tap(find.text('Home'));
    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(taps, 2);
  });

  // ── Narrow width ─────────────────────────────────────────────────────────

  testWidgets('builds at 430dp with iconWidget + centerGap', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(
      Column(
        children: [
          NeptuneAccountTile(
            name: 'Everyday current account',
            maskedNumber: '•••• 4821',
            balance: 'LYD 12,480,999.50',
            iconWidget: const FlutterLogo(size: 20),
            onTap: () {},
          ),
          NeptuneQuickActions(actions: [
            NeptuneQuickAction(iconWidget: const FlutterLogo(size: 20), label: 'Send', onTap: () {}),
            NeptuneQuickAction(iconWidget: const FlutterLogo(size: 20), label: 'Request', onTap: () {}),
            NeptuneQuickAction(icon: Icons.qr_code_rounded, label: 'Pay', onTap: () {}),
            NeptuneQuickAction(icon: Icons.add_card_outlined, label: 'Top up', onTap: () {}),
          ]),
          NeptuneDock(centerGap: true, items: [
            NeptuneDockItem(iconWidget: const FlutterLogo(size: 18), label: 'Home', active: true, onTap: () {}),
            NeptuneDockItem(icon: Icons.swap_horiz_rounded, label: 'Transfer', onTap: () {}),
            NeptuneDockItem(iconWidget: const FlutterLogo(size: 18), label: 'Cards', onTap: () {}),
            NeptuneDockItem(icon: Icons.person_outline, label: 'Profile', onTap: () {}),
          ]),
        ],
      ),
      dir: TextDirection.rtl,
    ));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });

  // ── The assert ───────────────────────────────────────────────────────────

  testWidgets('an item with neither icon nor iconWidget asserts',
      (tester) async {
    expect(() => NeptuneDockItem(label: _runtimeLabel()), throwsAssertionError);
    expect(() => NeptuneQuickAction(label: _runtimeLabel()), throwsAssertionError);
    expect(
      () => NeptuneAccountTile(
        name: _runtimeLabel(),
        maskedNumber: '•••• 4821',
        balance: 'LYD 1.00',
        icon: null,
      ),
      throwsAssertionError,
    );
  });
}
