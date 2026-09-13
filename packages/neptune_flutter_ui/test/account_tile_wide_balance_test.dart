// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The OTHER failure mode of NeptuneAccountTile's row, and the one 2.31.1
// introduced while fixing the first (2.31.2).
//
// What FAILS on 2.31.1: 2.31.0 gave the balance no claim on the row, so it was
// ellipsized at large text. 2.31.1 answered that by making the balance a
// non-flex child measured first — with no ceiling. A real balance of
// `14,678,363.00` then took 235.9dp of a 358dp row and left the name column
// 18dp. A masked account number is ONE unbreakable token, so it wrapped to a
// character per line and the tile went 76dp -> 284dp: a tower.
//
// These two test files pull against each other on purpose. Widening the
// balance's claim until this file fails re-truncates the balance in
// `account_tile_large_text_test.dart`; narrowing it until that file fails
// rebuilds the tower here. Both must stay green.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

const _banks = {
  'andalus': 'NO1-AY_RAQVwoAEdCg4SGCAsCOwEBAQAAAABAAAFKQ',
  'nuran': 'NO1-AVeEAP96VwDyBgoMEBQcBgoEBAQEBAMAAQABIw',
  'fglb': 'NO1-AVtjAQaNvgAbCAwQFBokB-IEBAQFBQMDAwQFsw',
};

/// The balance that built the tower — a real one, from a real account.
const _wide = '14,678,363.00';
const _narrow = '1.000';
const _masked = '•••• 4821';
const _longName = 'Salary current account — Tripoli main branch';

const _tileWidth = 390.0;

Widget _host(String brandprint, {required bool arabic, required String balance}) =>
    MaterialApp(
      theme: NeptuneTheme.fromBrandprint(brandprint,
          brightness: Brightness.light, arabic: arabic),
      home: Directionality(
        textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: _tileWidth,
              child: NeptuneAccountTile(
                name: _longName,
                maskedNumber: _masked,
                balance: balance,
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  for (final bank in _banks.entries) {
    for (final arabic in [false, true]) {
      final tag = '${bank.key}/${arabic ? 'ar' : 'en'}';

      testWidgets('a wide balance does not turn the row into a tower — $tag',
          (tester) async {
        tester.view.physicalSize = const Size(780, 1600);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        // The height this row has when the balance asks for nothing. Measured,
        // not hardcoded: it is a function of the brand's type scale.
        await tester
            .pumpWidget(_host(bank.value, arabic: arabic, balance: _narrow));
        await tester.pumpAndSettle();
        final singleRowHeight =
            tester.getRect(find.byType(NeptuneAccountTile)).height;
        final oneLineOfMasked =
            tester.renderObject<RenderParagraph>(find.text(_masked)).size.height;

        await tester
            .pumpWidget(_host(bank.value, arabic: arabic, balance: _wide));
        await tester.pumpAndSettle();

        expect(
          tester.renderObject<RenderParagraph>(find.text(_masked)).size.height,
          oneLineOfMasked,
          reason: 'the masked number wrapped at $tag — it is one unbreakable '
              'token, so wrapping it means one character per line',
        );

        expect(
          tester.getRect(find.byType(NeptuneAccountTile)).height,
          singleRowHeight,
          reason: 'a wide balance grew the row at $tag; at 1.0x the account '
              'row is one row whatever the figure costs',
        );

        // The name column must keep a real share of the measure, not whatever
        // the balance happens to leave behind.
        final nameColumn = tester.getRect(find.ancestor(
          of: find.text(_longName),
          matching: find.byType(Column),
        ));
        expect(
          nameColumn.width,
          greaterThan(_tileWidth * 0.25),
          reason: 'the name column was starved to ${nameColumn.width}dp '
              'at $tag',
        );
      });
    }
  }

  testWidgets('a balance wider than its ceiling is shrunk, never clipped and '
      'never broken across lines', (tester) async {
    tester.view.physicalSize = const Size(780, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        _host(_banks['andalus']!, arabic: false, balance: _wide));
    await tester.pumpAndSettle();

    final paragraph = tester.renderObject<RenderParagraph>(find.text(_wide));
    expect(paragraph.didExceedMaxLines, isFalse,
        reason: 'the balance dropped characters');
    expect(paragraph.size.height, lessThan(paragraph.size.width),
        reason: 'the balance is laid out on one line');
    expect(
      find.ancestor(of: find.text(_wide), matching: find.byType(FittedBox)),
      findsOneWidget,
      reason: 'the ceiling is enforced by scaling the figure down, not by '
          'dropping its digits',
    );
  });
}
