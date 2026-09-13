// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The balance on NeptuneAccountTile must survive large text (2.31.1).
//
// What FAILS on 2.31.0: the tile put the name column in an `Expanded` and the
// balance in a `Flexible` of the same weight, so the two split the row down
// the middle and the balance — the figure that decides which account a
// transfer leaves from — lost its digits first. At 2.0x `1,000.000` rendered
// as `1,000.` and a customer using large text could not read the number.
//
// The assertion is on the TEXT, not the box: `didExceedMaxLines` is the
// paragraph's own record of having dropped content it could not show. A test
// that only measured the row would pass on a tile that ellipsizes.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// The three production brandprints (see `brandprint_production_test.dart`).
const _banks = {
  'andalus': 'NO1-AY_RAQVwoAEdCg4SGCAsCOwEBAQAAAABAAAFKQ',
  'nuran': 'NO1-AVeEAP96VwDyBgoMEBQcBgoEBAQEBAMAAQABIw',
  'fglb': 'NO1-AVtjAQaNvgAbCAwQFBokB-IEBAQFBQMDAwQFsw',
};

const _balance = '1,000.000';
const _longName = 'Salary current account — Tripoli main branch';

Widget _host(String brandprint, {required bool arabic, required double scale}) =>
    MaterialApp(
      theme: NeptuneTheme.fromBrandprint(brandprint,
          brightness: Brightness.light, arabic: arabic),
      home: Builder(
        builder: (c) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
          child: Directionality(
            textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
            child: const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 390,
                  child: NeptuneAccountTile(
                    name: _longName,
                    maskedNumber: '•••• 4821',
                    balance: _balance,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  for (final bank in _banks.entries) {
    for (final arabic in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        final tag = '${bank.key}/${arabic ? 'ar' : 'en'}/${scale}x';

        testWidgets('balance keeps every digit — $tag', (tester) async {
          tester.view.physicalSize = const Size(780, 1600);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.reset);

          await tester
              .pumpWidget(_host(bank.value, arabic: arabic, scale: scale));
          await tester.pumpAndSettle();

          final paragraph =
              tester.renderObject<RenderParagraph>(find.text(_balance));

          expect(
            paragraph.didExceedMaxLines,
            isFalse,
            reason: 'the balance dropped characters at $tag — a customer reads '
                'a different number from the one the account holds',
          );
        });
      }
    }
  }

  testWidgets('above the large-text step the balance reflows under the name, '
      'it does not compete with it for the line', (tester) async {
    tester.view.physicalSize = const Size(780, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        _host(_banks['andalus']!, arabic: false, scale: 1.0));
    await tester.pumpAndSettle();
    final small = tester.getRect(find.byType(NeptuneAccountTile));
    final sideBySide = tester.getRect(find.text(_balance));
    expect(sideBySide.top, lessThan(tester.getRect(find.text('•••• 4821')).top),
        reason: 'at 1.0x the balance sits beside the name column, not under it');

    await tester.pumpWidget(
        _host(_banks['andalus']!, arabic: false, scale: 2.0));
    await tester.pumpAndSettle();
    final large = tester.getRect(find.byType(NeptuneAccountTile));
    final stacked = tester.getRect(find.text(_balance));

    expect(stacked.top,
        greaterThan(tester.getRect(find.text('•••• 4821')).bottom - 1),
        reason: 'at 2.0x the balance belongs on its own line under the name');
    expect(large.height, greaterThan(small.height),
        reason: 'the row grows rather than truncating; minHeight 64 is a floor');
  });
}
