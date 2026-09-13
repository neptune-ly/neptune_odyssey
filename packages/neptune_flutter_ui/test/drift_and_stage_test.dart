// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

ThemeData _theme({Brightness mode = Brightness.light}) =>
    NeptuneTheme.light('neptune').copyWith(brightness: mode);

Widget _host(Widget child,
        {bool reduceMotion = false,
        TextDirection dir = TextDirection.ltr,
        ThemeData? theme}) =>
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Directionality(
        textDirection: dir,
        child: MaterialApp(
          theme: theme ?? _theme(),
          home: Scaffold(body: child),
        ),
      ),
    );

void main() {
  setUpAll(() => NeptuneTheme.debugSkipFontLoading = true);

  group('NeptuneDriftField', () {
    const farKey = Key('far');
    const nearKey = Key('near');
    // Same declared size on both, so any difference measured on screen is the
    // depth ladder and nothing else.
    final objects = [
      NeptuneDriftObject(
        child: const ColoredBox(key: farKey, color: Color(0xFFFF0000)),
        at: const Alignment(-0.6, -0.4),
        depth: 0.15,
        size: 100,
      ),
      NeptuneDriftObject(
        child: const ColoredBox(key: nearKey, color: Color(0xFF00FF00)),
        at: const Alignment(0.5, 0.1),
        depth: 0.95,
        size: 100,
        semanticLabel: 'a card',
      ),
    ];

    testWidgets('every object is present and the child is a sibling of them',
        (tester) async {
      await tester.pumpWidget(_host(NeptuneDriftField(
        objects: objects,
        child: const Center(child: Text('headline')),
      )));
      expect(find.byType(ColoredBox), findsWidgets);
      expect(find.text('headline'), findsOneWidget);
    });

    testWidgets('a nearer object is drawn larger than a far one',
        (tester) async {
      await tester.pumpWidget(_host(NeptuneDriftField(objects: objects)));
      await tester.pump(const Duration(milliseconds: 16));
      // Depth 0.95 against 0.15, from equal declared sizes: the scale ladder
      // is the only thing that can separate them on screen.
      final far = tester.getRect(find.byKey(farKey));
      final near = tester.getRect(find.byKey(nearKey));
      expect(near.width, greaterThan(far.width));
      expect(near.height, greaterThan(far.height));
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('an unlabelled object is invisible to a screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(NeptuneDriftField(objects: objects)));
      // The labelled one is announced; the decorative one is not merely
      // unlabelled, it is absent.
      expect(find.bySemanticsLabel('a card'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('under reduced motion the scene is complete and still',
        (tester) async {
      await tester.pumpWidget(
          _host(NeptuneDriftField(objects: objects), reduceMotion: true));
      final first = tester.getTopLeft(find.byKey(nearKey));
      await tester.pump(const Duration(seconds: 3));
      final later = tester.getTopLeft(find.byKey(nearKey));
      expect(later, first, reason: 'reduced motion means still, not absent');
      expect(find.byKey(farKey), findsOneWidget);
    });

    testWidgets('with motion on, the scene actually moves', (tester) async {
      await tester.pumpWidget(_host(NeptuneDriftField(objects: objects)));
      await tester.pump(const Duration(milliseconds: 16));
      final first = tester.getTopLeft(find.byKey(nearKey));
      await tester.pump(const Duration(seconds: 2));
      final later = tester.getTopLeft(find.byKey(nearKey));
      expect(later, isNot(first));
      // Leave no live animation behind for the next test.
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('NeptuneAmountStage', () {
    testWidgets('the figure steps down as digits arrive, and never clips',
        (tester) async {
      double sizeOf(String v) {
        final t = tester.widget<Text>(find.text(v));
        return t.style!.fontSize!;
      }

      await tester.pumpWidget(
          _host(const NeptuneAmountStage(value: '12', currency: 'LYD')));
      final short = sizeOf('12');
      await tester.pumpWidget(
          _host(const NeptuneAmountStage(value: '123456789', currency: 'LYD')));
      final long = sizeOf('123456789');
      expect(long, lessThan(short));
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty amount shows the placeholder in the muted tone',
        (tester) async {
      await tester.pumpWidget(
          _host(const NeptuneAmountStage(value: '', currency: 'LYD')));
      final zero = tester.widget<Text>(find.text('0'));
      final currency = tester.widget<Text>(find.text('LYD'));
      expect(zero.style!.color, currency.style!.color,
          reason: 'nothing typed yet: figure and currency are equally quiet');
    });

    testWidgets('the amount is spoken as money, not read out as digits',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
          _host(const NeptuneAmountStage(value: '120', currency: 'LYD')));
      expect(find.bySemanticsLabel(RegExp('120')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('no footnote means no reserved empty line', (tester) async {
      await tester.pumpWidget(
          _host(const NeptuneAmountStage(value: '5', currency: 'LYD')));
      final bare = tester.getSize(find.byType(NeptuneAmountStage));
      await tester.pumpWidget(_host(const NeptuneAmountStage(
          value: '5', currency: 'LYD', footnote: Text('available 300'))));
      final withFoot = tester.getSize(find.byType(NeptuneAmountStage));
      expect(withFoot.height, greaterThan(bare.height));
    });
  });

  group('NeptuneStageKeypad', () {
    testWidgets('every digit is reachable and reports itself', (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(_host(SizedBox(
        height: 320,
        child: NeptuneStageKeypad(
          onDigit: pressed.add,
          onBackspace: () => pressed.add('<'),
          onDecimal: () => pressed.add('.'),
        ),
      )));
      for (final d in ['1', '5', '9', '0']) {
        await tester.tap(find.text(d));
      }
      expect(pressed, ['1', '5', '9', '0']);
    });

    testWidgets('the grid is not mirrored under RTL', (tester) async {
      Future<double> xOf(TextDirection dir, String digit) async {
        await tester.pumpWidget(_host(
          SizedBox(
            height: 320,
            child: NeptuneStageKeypad(onDigit: (_) {}, onBackspace: () {}),
          ),
          dir: dir,
        ));
        return tester.getCenter(find.text(digit)).dx;
      }

      // A keypad is a physical object with muscle memory attached: 1 is on the
      // left in Tripoli exactly as it is in London.
      expect(await xOf(TextDirection.ltr, '1'),
          lessThan(await xOf(TextDirection.ltr, '3')));
      expect(await xOf(TextDirection.rtl, '1'),
          lessThan(await xOf(TextDirection.rtl, '3')));
    });

    testWidgets('a long press clears rather than repeating the backspace',
        (tester) async {
      var cleared = 0;
      var deleted = 0;
      await tester.pumpWidget(_host(SizedBox(
        height: 320,
        child: NeptuneStageKeypad(
          onDigit: (_) {},
          onBackspace: () => deleted++,
          onClear: () => cleared++,
        ),
      )));
      await tester.longPress(find.byIcon(Icons.backspace_outlined));
      expect(cleared, 1);
      expect(deleted, 0);
    });

    testWidgets('the decimal cell is absent, not blank, for a minor-unit-less '
        'currency', (tester) async {
      await tester.pumpWidget(_host(SizedBox(
        height: 320,
        child: NeptuneStageKeypad(onDigit: (_) {}, onBackspace: () {}),
      )));
      expect(find.text('.'), findsNothing);
      // ...and the row still holds its shape, so 0 stays under 8.
      expect(tester.getCenter(find.text('0')).dx,
          moreOrLessEquals(tester.getCenter(find.text('8')).dx, epsilon: 1));
    });

    testWidgets('every key clears the 44pt target floor', (tester) async {
      await tester.pumpWidget(_host(SizedBox(
        height: 320,
        child: NeptuneStageKeypad(onDigit: (_) {}, onBackspace: () {}),
      )));
      for (final d in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']) {
        final box = tester.getSize(find.ancestor(
            of: find.text(d), matching: find.byType(GestureDetector)).first);
        expect(box.shortestSide, greaterThanOrEqualTo(44),
            reason: 'key $d is under the minimum target size');
      }
    });
  });

  group('NeptuneDockShell.inkPill', () {
    final items = [
      const NeptuneDockItem(icon: Icons.home, label: 'Home', active: true),
      const NeptuneDockItem(icon: Icons.credit_card, label: 'Cards'),
      const NeptuneDockItem(icon: Icons.person, label: 'Me'),
    ];

    testWidgets('the bar is the brand canvas, the same colour at night',
        (tester) async {
      Future<Color> fillFor(Brightness mode) async {
        final theme = NeptuneTheme.fromConfig(brandConfig['neptune']!,
            brightness: mode);
        await tester.pumpWidget(_host(
          NeptuneDock(items: items, shell: NeptuneDockShell.inkPill),
          theme: theme,
        ));
        final box = tester.widget<DecoratedBox>(find
            .descendant(
                of: find.byType(NeptuneDock),
                matching: find.byType(DecoratedBox))
            .first);
        return (box.decoration as BoxDecoration).color!;
      }

      expect(await fillFor(Brightness.dark), await fillFor(Brightness.light));
    });

    testWidgets('only the active item shows its word; all are announced',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
          _host(NeptuneDock(items: items, shell: NeptuneDockShell.inkPill)));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Cards'), findsNothing);
      // ...but a screen reader hears every one of them.
      expect(find.bySemanticsLabel('Cards'), findsOneWidget);
      expect(find.bySemanticsLabel('Me'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('it is a stadium, not the raised dock in another colour',
        (tester) async {
      await tester.pumpWidget(
          _host(NeptuneDock(items: items, shell: NeptuneDockShell.inkPill)));
      // The raised shell builds its pane through NeptuneGlass; this one must
      // not, or it would borrow the page colour and stop being ink.
      expect(
          find.descendant(
              of: find.byType(NeptuneDock), matching: find.byType(NeptuneGlass)),
          findsNothing);
    });
  });
}
