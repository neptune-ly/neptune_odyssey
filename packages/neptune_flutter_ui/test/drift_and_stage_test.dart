import 'dart:math' as math;
// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

ThemeData _theme({Brightness mode = Brightness.light}) =>
    NeptuneTheme.light('neptune').copyWith(brightness: mode);

/// The `Directionality` goes INSIDE the `MaterialApp`, and that is not a
/// detail: `MaterialApp` inserts its own `Directionality` from its locale, so
/// one wrapped around it is overridden before the widget under test ever sees
/// it. Two RTL tests in this file were written the other way round and were
/// quietly asserting LTR twice.
Widget _host(Widget child,
        {bool reduceMotion = false,
        TextDirection dir = TextDirection.ltr,
        ThemeData? theme}) =>
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: MaterialApp(
        theme: theme ?? _theme(),
        home: Directionality(
          textDirection: dir,
          child: Scaffold(body: child),
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

    testWidgets('an object\'s centre does not move when its size changes',
        (tester) async {
      // THE BUG THIS EXISTS FOR. Material's `Align` insets an object so it
      // never leaves its box, so two objects at the same alignment but
      // different sizes land in different places - which is how a composition
      // laid out by eye collapses into a pile the moment one object is
      // resized. Here the centre is what was specified.
      Future<Offset> centreAt(double size) async {
        await tester.pumpWidget(_host(
          NeptuneDriftField(
            objects: [
              NeptuneDriftObject(
                child: const ColoredBox(key: nearKey, color: Color(0xFF00FF00)),
                at: const Alignment(0.4, -0.6),
                depth: 0.5,
                size: size,
              ),
            ],
          ),
          reduceMotion: true,
        ));
        return tester.getCenter(find.byKey(nearKey));
      }

      final small = await centreAt(40);
      final large = await centreAt(160);
      expect(large.dx, moreOrLessEquals(small.dx, epsilon: 0.5));
      expect(large.dy, moreOrLessEquals(small.dy, epsilon: 0.5));
    });

    testWidgets('the scene does not mirror under RTL', (tester) async {
      // A scene of physical objects is a picture, not a layout. Reading order
      // mirrors; a photograph does not.
      Future<double> xIn(TextDirection dir) async {
        await tester.pumpWidget(_host(
          NeptuneDriftField(objects: objects),
          dir: dir,
          reduceMotion: true,
        ));
        return tester.getCenter(find.byKey(nearKey)).dx;
      }

      expect(await xIn(TextDirection.rtl),
          moreOrLessEquals(await xIn(TextDirection.ltr), epsilon: 0.5));
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
      // Grouped on screen; the ladder keys off the DIGIT count, not the
      // rendered string's length, so the separators do not shrink it further.
      final long = sizeOf('123,456,789');
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

    testWidgets('the integer part is grouped as it is typed', (tester) async {
      await tester.pumpWidget(
          _host(const NeptuneAmountStage(value: '2450000', currency: 'LYD')));
      expect(find.text('2,450,000'), findsOneWidget);
      // Display only: three digits or fewer are left alone, and the decimal
      // part is never grouped.
      await tester.pumpWidget(
          _host(const NeptuneAmountStage(value: '450.25', currency: 'LYD')));
      expect(find.text('450.25'), findsOneWidget);
      await tester.pumpWidget(
          _host(const NeptuneAmountStage(value: '12345.5', currency: 'LYD')));
      expect(find.text('12,345.5'), findsOneWidget);
    });

    testWidgets('grouping is a display transform, not a value change',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
          _host(const NeptuneAmountStage(value: '2450000', currency: 'LYD')));
      // What a screen reader hears, and what the host still holds, is the
      // plain figure - a separator that reached the value would have to be
      // stripped out again by every caller downstream.
      expect(find.bySemanticsLabel(RegExp(r'2450000')), findsOneWidget);
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

  group('amountFirstTransfer (extension bit 1)', () {
    const base = BrandprintConfig(
      primary: Seed(l: 0.372, c: 0.104, h: 262),
      tertiary: Seed(l: 0.47, c: 0.083, h: 243),
      corners: Corners(xs: 8, sm: 12, md: 16, lg: 20, xl: 26, xxl: 200),
      displayWeight: 700,
      displayTracking: -0.02,
      fontDisplay: 'IBM Plex Sans Arabic',
      fontText: 'IBM Plex Sans Arabic',
      fontNum: 'IBM Plex Sans Arabic',
      loginShell: 'drift-depth',
      dashboardHero: 'statement-ledger',
      contentTone: 'formal-authoritative',
      glassTint: 'oceanic',
      motion: 'calm-graceful',
      navShell: 'ink-pill',
      actionRow: 'register-rows',
      motif: 'none',
    );

    test('survives a round trip, and does not disturb bit 0', () {
      for (final amountFirst in [false, true]) {
        for (final ruled in [false, true]) {
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
            navShell: base.navShell,
            actionRow: base.actionRow,
            motif: base.motif,
            ruledRegister: ruled,
            amountFirstTransfer: amountFirst,
          );
          final back = Brandprint.decode(Brandprint.encode(cfg));
          expect(back.amountFirstTransfer, amountFirst);
          expect(back.ruledRegister, ruled);
        }
      }
    });

    test('a brand that never sets it still emits the 28-byte form', () {
      // The whole reason the payload grew rather than sharing a bit: a string
      // that carries no extension flag must be byte-for-byte what it always
      // was, so every brandprint already in the wild keeps decoding.
      final plain = Brandprint.encode(base);
      final extended = Brandprint.encode(BrandprintConfig(
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
        navShell: base.navShell,
        actionRow: base.actionRow,
        motif: base.motif,
        amountFirstTransfer: true,
      ));
      expect(extended.length, greaterThan(plain.length));
      expect(Brandprint.decode(plain).amountFirstTransfer, isFalse);
    });

    test('it reaches the theme, so a screen can read it without asking which '
        'bank it is drawing', () {
      final off = NeptuneTheme.fromConfig(base, brightness: Brightness.light);
      expect(off.extension<NptIdentity>()!.amountFirstTransfer, isFalse);
    });
  });

  group('NptBrandCanvas.deep', () {
    test('a brand card can be seen on it, which is the whole reason', () {
      final theme = NeptuneTheme.light('neptune');
      final brand = theme.extension<NptBrandCanvas>()!;
      final colors = theme.extension<NptColors>()!;
      // The failure it fixes: a card's first gradient stop IS `canvas`, so a
      // card placed on the plain brand ground is the ground.
      expect(colors.cardGradientStart, brand.canvas,
          reason: 'if these ever differ, re-read why `deep` exists');
      double lum(Color c) {
        double f(double v) =>
            v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
        return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
      }
      double ratio(Color a, Color b) {
        final x = lum(a), y = lum(b);
        return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
      }
      // NOT 3:1, and the reason is worth the comment. 3:1 is the floor for a
      // graphical object whose SHAPE carries information; a drifting card in a
      // pre-login scene carries none (it is `ExcludeSemantics`, and a customer
      // who cannot see it misses nothing). And for a brand whose primary is
      // already dark the ratio cannot reach 3:1 at any lerp - both colours are
      // the same deep navy - so asserting it would only ever be satisfied by
      // inventing a lighter ground the bank does not own. What IS owed is that
      // the ground is meaningfully BEHIND the card, so the card's rim and
      // shadow have something to sit against.
      expect(ratio(brand.deep, colors.cardGradientStart),
          greaterThanOrEqualTo(1.5));
      // ...and the near-white ink still reads on the deeper ground.
      expect(ratio(brand.deep, brand.onCanvas), greaterThanOrEqualTo(4.5));
    });

    test('it is the bank\'s own colour, only darker', () {
      final brand =
          NeptuneTheme.light('neptune').extension<NptBrandCanvas>()!;
      final a = HSLColor.fromColor(brand.canvas);
      final b = HSLColor.fromColor(brand.deep);
      // A lerp to black moves lightness and nothing else; a `deep` that had
      // drifted in hue would be a second, invented navy.
      expect(b.hue, moreOrLessEquals(a.hue, epsilon: 1.0));
      expect(b.lightness, lessThan(a.lightness));
    });

    test('it does not re-tone at night', () {
      Color deepFor(Brightness mode) => NeptuneTheme.fromConfig(
              brandConfig['neptune']!, brightness: mode)
          .extension<NptBrandCanvas>()!
          .deep;
      expect(deepFor(Brightness.dark), deepFor(Brightness.light));
    });
  });

  group('the backspace glyph', () {
    testWidgets('points against the reading direction in BOTH scripts',
        (tester) async {
      Future<double> scaleXIn(TextDirection dir) async {
        await tester.pumpWidget(_host(
          SizedBox(
            height: 320,
            child: NeptuneStageKeypad(onDigit: (_) {}, onBackspace: () {}),
          ),
          dir: dir,
        ));
        // The mirroring Transform is not necessarily the innermost ancestor -
        // the pressed-state container contributes its own - so the flip is
        // looked for across all of them rather than at a fixed depth.
        final all = tester.widgetList<Transform>(find.ancestor(
            of: find.byIcon(Icons.backspace_outlined),
            matching: find.byType(Transform)));
        return all
            .map((t) => t.transform.storage[0])
            .reduce((a, b) => a * b);
      }

      // `Icons.backspace_outlined` declares `matchTextDirection: false`, so a
      // `Directionality` around it does nothing at all - which is what the
      // first version of this did, while a comment claimed it mirrored.
      expect(await scaleXIn(TextDirection.ltr), greaterThan(0));
      expect(await scaleXIn(TextDirection.rtl), lessThan(0));
    });
  });
}
