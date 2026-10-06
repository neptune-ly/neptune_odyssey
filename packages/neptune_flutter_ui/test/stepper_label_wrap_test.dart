// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// NeptuneStepper labels wrap BETWEEN words, never inside one.
//
// What FAILS on 3.0.2: every label sat in a fixed `SizedBox(width: 80)`. At 200%
// text a single word wider than 80dp is split by the engine at the grapheme
// (`Beneficiary` -> `Benefic` / `iary`, Arabic `المستفيدين` the same) and the
// customer reads two half-words. Five labels at 80dp are 400dp, so a five-step
// flow overflowed a 360dp phone at ANY text size.
//
// The assertion is on the LAID-OUT paragraph, not on the box: for every line the
// engine started, the character before the break or the one at it must be
// whitespace. A test that only measured widths would pass a stepper that
// ellipsizes, so `didExceedMaxLines` is checked for the same reason.
//
// Real faces are loaded because the test engine's block font gives every glyph
// the same width - "a wide word" would then measure its length, not the type
// that wrapped on a customer's phone.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

const _flows = <String, Map<int, List<String>>>{
  'en': {
    2: ['Beneficiary', 'Confirmation'],
    3: ['Beneficiary', 'Review transfer', 'Done'],
    4: ['Beneficiary', 'Amount', 'Review transfer', 'Done'],
    5: ['Beneficiary', 'Amount', 'Review transfer', 'Payment', 'Done'],
  },
  'ar': {
    2: ['المستفيدين', 'المحفظة'],
    3: ['المستفيدين', 'مراجعة التحويل', 'تم'],
    4: ['المستفيدين', 'المبلغ', 'مراجعة التحويل', 'تم'],
    5: ['المستفيدين', 'المبلغ', 'مراجعة التحويل', 'الحسابات', 'تم'],
  },
};

Future<void> _loadFace(String family, String file, List<int> weights) async {
  final root = Directory.current.parent.path;
  final face = FontLoader(family);
  for (final weight in weights) {
    final bytes = await File(
      '$root/neptune_kmp_ui/odyssey-compose-ui/src/commonMain/'
      'composeResources/font/${file}_$weight.ttf',
    ).readAsBytes();
    face.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await face.load();
}

Widget _host(
  List<String> steps, {
  required bool arabic,
  required double scale,
  double width = 360,
  bool bold = false,
}) =>
    MaterialApp(
      theme: NeptuneTheme.light('neptune', arabic: arabic),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale), boldText: bold),
          child: Directionality(
            textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              body: Align(
                alignment: AlignmentDirectional.topStart,
                child: SizedBox(
                  width: width,
                  child: NeptuneStepper(steps: steps, active: 1),
                ),
              ),
            ),
          ),
        ),
      ),
    );

void _viewWidth(WidgetTester tester, double dp) {
  tester.view.physicalSize = Size(dp * 2, 1600);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

/// Every place a label's paragraph broke inside a word, as `"Benefic|iary"`.
List<String> _brokenWords(WidgetTester tester, List<String> steps) {
  final broken = <String>[];
  for (final label in steps) {
    final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
    final text = paragraph.text.toPlainText();
    double lineTop(int offset) =>
        paragraph.getOffsetForCaret(TextPosition(offset: offset), Rect.zero).dy;

    var top = lineTop(0);
    for (var i = 1; i < text.length; i++) {
      final next = lineTop(i);
      if (next <= top + 1) continue;
      top = next;
      final atWordEdge = text[i - 1].trim().isEmpty || text[i].trim().isEmpty;
      if (!atWordEdge) {
        broken.add('${text.substring(0, i)}|${text.substring(i)}');
      }
    }
    if (paragraph.didExceedMaxLines) broken.add('$label (clipped by maxLines)');
  }
  return broken;
}

/// How far the labels' tops are from each other: 0 means one rail of nodes,
/// anything else means the steps were stacked.
double _topSpread(WidgetTester tester, List<String> steps) {
  final tops = [for (final s in steps) tester.getTopLeft(find.text(s)).dy];
  return tops.reduce((a, b) => a > b ? a : b) -
      tops.reduce((a, b) => a < b ? a : b);
}

void _expectIntact(WidgetTester tester, List<String> steps, String tag) {
  expect(tester.takeException(), isNull, reason: tag);
  expect(_brokenWords(tester, steps), isEmpty,
      reason: '$tag: a label broke inside a word');

  final stepper = tester.getRect(find.byType(NeptuneStepper));
  for (final label in steps) {
    final rect = tester.getRect(find.text(label));
    expect(rect.left, greaterThanOrEqualTo(stepper.left - 0.5),
        reason: '$tag: "$label" paints before the stepper');
    expect(rect.right, lessThanOrEqualTo(stepper.right + 0.5),
        reason: '$tag: "$label" paints past the stepper');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  NeptuneTheme.debugSkipFontLoading = true;

  setUpAll(() async {
    await _loadFace('Hanken Grotesk', 'hanken_grotesk', [400, 500, 600, 700]);
    await _loadFace(
        'IBM Plex Sans Arabic', 'ibm_plex_sans_arabic', [400, 500, 600, 700]);
  });

  for (final lang in _flows.keys) {
    for (final entry in _flows[lang]!.entries) {
      for (final scale in [1.0, 2.0]) {
        // 360 is the phone; 320 is the same phone inside the 20dp page padding
        // the templates give a stepper.
        for (final width in [360.0, 320.0]) {
          final tag = '$lang ${entry.key} steps ${scale}x ${width.toInt()}dp';

          testWidgets('wraps between words - $tag', (tester) async {
            _viewWidth(tester, 360);
            await tester.pumpWidget(_host(entry.value,
                arabic: lang == 'ar', scale: scale, width: width));
            await tester.pumpAndSettle();

            _expectIntact(tester, entry.value, tag);
          });
        }
      }
    }
  }

  for (final lang in _flows.keys) {
    // Without this a stepper that stacks every flow vertically would pass every
    // test above. The label columns must stay between the nodes while there is
    // room for them.
    for (final n in [2, 3]) {
      testWidgets('$lang $n steps at 2x stay on one rail', (tester) async {
        _viewWidth(tester, 360);
        final steps = _flows[lang]![n]!;
        await tester.pumpWidget(_host(steps, arabic: lang == 'ar', scale: 2.0));
        await tester.pumpAndSettle();

        expect(_topSpread(tester, steps), lessThan(0.5));
      });
    }

    for (final n in _flows[lang]!.keys) {
      testWidgets('$lang $n steps at 1x stay on one rail', (tester) async {
        _viewWidth(tester, 360);
        final steps = _flows[lang]![n]!;
        await tester.pumpWidget(_host(steps, arabic: lang == 'ar', scale: 1.0));
        await tester.pumpAndSettle();

        expect(_topSpread(tester, steps), lessThan(0.5));
      });
    }

    // The numeral is text in a 32dp circle, so it scales with the text and, at
    // 2x, was taller than the circle it counts the step in.
    for (final scale in [1.0, 2.0, 3.0]) {
      testWidgets('numerals stay inside their circle - $lang ${scale}x',
          (tester) async {
        _viewWidth(tester, 360);
        final steps = _flows[lang]![5]!;
        await tester
            .pumpWidget(_host(steps, arabic: lang == 'ar', scale: scale));
        await tester.pumpAndSettle();

        // Step 1 is done (a check), step 2 is active, so the numerals are 2..5.
        for (var k = 2; k <= steps.length; k++) {
          final numeral = find.text('$k');
          final node = tester.getRect(find
              .ancestor(of: numeral, matching: find.byType(Container))
              .first);
          // The scaled bounds: `getSize` would report the unscaled layout box.
          final glyph = Rect.fromPoints(
              tester.getTopLeft(numeral), tester.getBottomRight(numeral));
          expect(node.inflate(0.5).expandToInclude(glyph), node.inflate(0.5),
              reason: '$lang numeral $k at ${scale}x spills out of its circle');
        }
      });
    }

    // Every width between a cramped phone and a roomy one, across the point
    // where the labels run out of slack and the stepper has to change shape.
    // Bold text is a second sweep because it widens every word: a measure that
    // ignored it would hand a label its regular-weight width and split it in the
    // few dp between the two.
    for (final bold in [false, true]) {
      testWidgets(
          'no width splits a word - $lang 3 steps 2x${bold ? ' bold' : ''}, 260-440dp',
          (tester) async {
        _viewWidth(tester, 500);
        final steps = _flows[lang]![3]!;
        for (var width = 260.0; width <= 440; width += 1) {
          await tester.pumpWidget(_host(steps,
              arabic: lang == 'ar', scale: 2.0, width: width, bold: bold));
          await tester.pumpAndSettle();

          _expectIntact(tester, steps, '$lang ${width.toInt()}dp');
        }
      });
    }
  }
}
