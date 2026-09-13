// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// The depth register's two contracts, both of which it was written the wrong
/// way round first.
void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  /// A brand whose canvas is a mid teal, so "did it re-tone?" is answerable:
  /// the canvas must be the SAME colour in both brightnesses.
  const cfg = BrandprintConfig(
    primary: Seed(l: 0.654, c: 0.116, h: 217),
    tertiary: Seed(l: 0.434, c: 0.097, h: 257),
    corners: Corners(xs: 14, sm: 18, md: 22, lg: 26, xl: 30, xxl: 34),
    displayWeight: 700,
    displayTracking: -0.01,
    fontDisplay: 'Readex Pro',
    fontText: 'Readex Pro',
    fontNum: 'Readex Pro',
    loginShell: 'tide-depth',
    dashboardHero: 'tide-carousel',
    navShell: 'centre-dock',
    contentTone: 'clear-calm',
    glassTint: 'oceanic',
    motion: 'smooth-fluid',
    motif: 'none',
  );

  Widget host(Brightness brightness, Widget child) => MaterialApp(
        theme: NeptuneTheme.fromConfig(cfg, brightness: brightness),
        home: Scaffold(body: child),
      );

  /// The gradient the field actually painted, read back off the render tree.
  List<Color> paintedTravel(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(NeptuneTideField),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    return ((box.decoration as BoxDecoration).gradient as LinearGradient)
        .colors;
  }

  testWidgets('the travel is the SAME in light and dark', (tester) async {
    // THE BUG THIS EXISTS FOR: built on `colorScheme.primary`/`tertiary` the
    // field came out brighter at night than in the day, because Material
    // re-tones those roles - they are chrome. A bank's ground is not chrome,
    // and `NptBrandCanvas.canvas` is the one value Odyssey pins across
    // brightness.
    await tester.pumpWidget(host(Brightness.light, const NeptuneTideField()));
    final light = paintedTravel(tester);

    await tester.pumpWidget(host(Brightness.dark, const NeptuneTideField()));
    final dark = paintedTravel(tester);

    expect(dark, light,
        reason: 'the tide field re-toned with brightness; it is derived from '
            'the colour scheme again');
    // And it is a TRAVEL, not a tint strip: the foot is a different hue from
    // the head, not merely a dimmer version of it.
    expect(HSLColor.fromColor(light.first).hue,
        isNot(closeTo(HSLColor.fromColor(light[1]).hue, 4)),
        reason: 'deep and mid are the same hue - the field is a tint strip');
    expect(light.first.computeLuminance(),
        lessThan(light.last.computeLuminance()));
  });

  testWidgets('sink deepens the whole travel, so two fields can stack',
      (tester) async {
    await tester.pumpWidget(host(Brightness.light, const NeptuneTideField()));
    final flat = paintedTravel(tester);
    await tester
        .pumpWidget(host(Brightness.light, const NeptuneTideField(sink: 0.3)));
    final sunk = paintedTravel(tester);

    for (var i = 0; i < flat.length; i++) {
      expect(sunk[i].computeLuminance(), lessThan(flat[i].computeLuminance()),
          reason: 'stop $i did not sink');
    }
  });

  testWidgets('a card with no second figure draws no band', (tester) async {
    await tester.pumpWidget(host(
      Brightness.light,
      const SizedBox(
        height: 168,
        child: NeptuneTideCard(label: 'Current', amount: 'LYD 1.00'),
      ),
    ));
    expect(find.text('IBAN'), findsNothing);

    await tester.pumpWidget(host(
      Brightness.light,
      const SizedBox(
        height: 168,
        child: NeptuneTideCard(
          label: 'Current',
          amount: 'LYD 1.00',
          bandLabel: 'IBAN',
          bandValue: '4471',
        ),
      ),
    ));
    expect(find.text('IBAN'), findsOneWidget);
    expect(find.text('4471'), findsOneWidget);
  });

  testWidgets('the card ink reads on the card, in BOTH brightnesses',
      (tester) async {
    // The second half of the same trap: in a dark scheme `primary` is a LIGHT
    // tone, so `onPrimary` is near-black - and the ground it would be painted
    // on has not re-toned. The label came out near-black on deep teal.
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(host(
        brightness,
        const SizedBox(
          height: 168,
          child: NeptuneTideCard(label: 'Current', amount: 'LYD 1.00'),
        ),
      ));
      final label = tester.widget<Text>(find.text('Current'));
      final ground = paintedTravel(tester)[1];
      expect(label.style!.color!.computeLuminance(),
          greaterThan(ground.computeLuminance()),
          reason: '$brightness: the card label is darker than the card');
    }
  });

  testWidgets('centre-dock opens the gap; raised-dock does not',
      (tester) async {
    final items = [
      for (final label in ['Home', 'Accounts', 'Cards', 'More'])
        NeptuneDockItem(icon: Icons.circle, label: label),
    ];
    // The gap is inert space spliced into the item row, so it shows up as one
    // more child than the raised shell lays out.
    Future<int> cellsFor(NeptuneDockShell shell) async {
      await tester.pumpWidget(
          host(Brightness.light, NeptuneDock(items: items, shell: shell)));
      final row = tester.widget<Row>(find
          .descendant(of: find.byType(NeptuneDock), matching: find.byType(Row))
          .first);
      return row.children.length;
    }

    expect(await cellsFor(NeptuneDockShell.centre),
        greaterThan(await cellsFor(NeptuneDockShell.raised)));
  });
}
