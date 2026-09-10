// Regression: EVERY DIRECTIONAL ARROW IN THE SYSTEM POINTED BACKWARDS IN RTL.
//
// `NeptuneCta`'s trailing arrow, `NeptuneBreadcrumbs`' separator and
// `NeptunePagination`'s Previous/Next each chose the OPPOSITE Material glyph
// when the ambient direction was RTL. But `arrow_forward_rounded`,
// `arrow_back_rounded`, `chevron_left_rounded` and `chevron_right_rounded` all
// carry `matchTextDirection: true`, so `Icon` was already mirroring them
// (`flutter/src/widgets/icon.dart:334`). Two mirrors cancel: the CTA on every
// screen of an Arabic app drew a right-pointing arrow, which is backwards.
//
// THE ASSERTIONS ARE ABOUT WHAT IS PAINTED, never about which constant was
// chosen. A test written against the constant passes on the broken code,
// because the broken code picks the constant whose NAME reads correctly - which
// is exactly how this survived a version release.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  Widget host(TextDirection direction, Widget child) => MaterialApp(
        theme: NeptuneTheme.light('proteus'),
        home: Directionality(
          textDirection: direction,
          child: Scaffold(body: Center(child: child)),
        ),
      );

  /// Which way an icon is actually PAINTED: the glyph, then the mirror `Icon`
  /// applies for the ambient direction.
  bool pointsRight(Icon icon, TextDirection direction) {
    final data = icon.icon!;
    final rightish = {
      Icons.arrow_forward_rounded.codePoint,
      Icons.chevron_right_rounded.codePoint,
    }.contains(data.codePoint);
    final mirrored =
        data.matchTextDirection && direction == TextDirection.rtl;

    return mirrored ? !rightish : rightish;
  }

  List<bool> painted(WidgetTester tester, TextDirection direction) => [
        for (final icon in tester.widgetList<Icon>(find.byType(Icon)))
          pointsRight(icon, direction),
      ];

  group('the CTA arrow follows the reading direction', () {
    for (final direction in TextDirection.values) {
      testWidgets('$direction', (tester) async {
        await tester.pumpWidget(host(
          direction,
          NeptuneCta(label: 'التالي', arrow: true, onPressed: () {}),
        ));
        await tester.pump(const Duration(milliseconds: 400));

        expect(painted(tester, direction),
            [direction == TextDirection.ltr],
            reason: 'forward means rightwards in LTR and leftwards in RTL');
      });
    }
  });

  group('the breadcrumb separator points down the trail', () {
    for (final direction in TextDirection.values) {
      testWidgets('$direction', (tester) async {
        await tester.pumpWidget(host(
          direction,
          const NeptuneBreadcrumbs(crumbs: [NeptuneCrumb('أ'), NeptuneCrumb('ب'), NeptuneCrumb('ج')]),
        ));

        final chevrons = painted(tester, direction);

        expect(chevrons, isNotEmpty);
        expect(chevrons, everyElement(direction == TextDirection.ltr));
      });
    }
  });

  group('pagination puts Previous behind and Next ahead', () {
    for (final direction in TextDirection.values) {
      testWidgets('$direction', (tester) async {
        await tester.pumpWidget(host(
          direction,
          NeptunePagination(page: 1, pageCount: 4, onChanged: (_) {}),
        ));

        final arrows = painted(tester, direction);

        // Previous first in tree order, Next second - and they must disagree,
        // or one of them is drawn pointing the same way as the other.
        expect(arrows.length, greaterThanOrEqualTo(2));
        expect(arrows.first, direction == TextDirection.rtl,
            reason: 'Previous points against the reading direction');
        expect(arrows.last, direction == TextDirection.ltr,
            reason: 'Next points along it');
      });
    }
  });
}
