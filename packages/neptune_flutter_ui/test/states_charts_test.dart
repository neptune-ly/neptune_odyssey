// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// R4b: the data-state contract cross-fades through all four faces, and the
// insights charts build under LTR/RTL with sane geometry.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  Widget host(Widget child, [TextDirection dir = TextDirection.ltr]) =>
      MaterialApp(
        theme: NeptuneTheme.light('nereid'),
        home: Directionality(
          textDirection: dir,
          child: Scaffold(
              body: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsetsDirectional.all(16),
                      child: child))),
        ),
      );

  testWidgets('state switcher walks loading → error → empty → ready',
      (tester) async {
    var state = NeptuneDataState.loading;
    late StateSetter set;
    await tester.pumpWidget(host(StatefulBuilder(builder: (context, s) {
      set = s;
      return NeptuneStateSwitcher(
        state: state,
        onRetry: () {},
        child: const Text('CONTENT'),
      );
    })));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(NeptuneSkeletonRow), findsOneWidget);

    set(() => state = NeptuneDataState.error);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Try again'), findsOneWidget);

    set(() => state = NeptuneDataState.empty);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Nothing here yet'), findsOneWidget);

    set(() => state = NeptuneDataState.ready);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('CONTENT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skeleton card + charts build LTR/RTL', (tester) async {
    for (final dir in TextDirection.values) {
      await tester.pumpWidget(host(
        const Column(children: [
          NeptuneSkeletonCard(),
          SizedBox(height: 12),
          NeptuneBarChart(
            bars: [
              NeptuneBarData('Jan', 320),
              NeptuneBarData('Feb', 480),
              NeptuneBarData('Mar', 260),
              NeptuneBarData('Apr', 610),
            ],
            highlightIndex: 3,
          ),
          SizedBox(height: 12),
          NeptuneCompareBars(data: [
            NeptuneCompareData('Food', 430, 510),
            NeptuneCompareData('Bills', 380, 330),
            NeptuneCompareData('Fun', 90, 140),
          ]),
        ]),
        dir,
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: '$dir');
      await tester.pumpWidget(const SizedBox());
    }
    // Compare delta chip: (900 vs 980) → −8.2%
    await tester.pumpWidget(host(const NeptuneCompareBars(data: [
      NeptuneCompareData('A', 450, 490),
      NeptuneCompareData('B', 450, 490),
    ])));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('−8.2%'), findsOneWidget);
  });
}
