// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// 3.2.0: what Nuran built app-side and the design system now owns.
//
//  * `NeptuneQuickActionShell.boxedTiles` - rounded-square tiles on a band;
//  * `NeptuneTopBar` / `NeptuneSliverTopBar` - the flat, collapsing top bar;
//  * `NeptuneAccountNumber` - the IBAN in groups of four, tap to copy.
//
// The goldens render with the test font (every glyph a block), so they pin
// geometry, fill, corner and mirroring - which is what this component is made
// of - and not a typeface. They are compared with a small tolerance because the
// engine's anti-aliasing differs by a pixel here and there between hosts.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
        imageBytes, await getGoldenBytes(golden));
    if (result.passed || result.diffPercent <= 0.005) return true;
    throw FlutterError(await generateFailureOutput(result, golden, basedir));
  }
}

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  final original = goldenFileComparator;
  setUpAll(() {
    goldenFileComparator = _TolerantComparator(
        (goldenFileComparator as LocalFileComparator).basedir.resolve('x'));
  });
  tearDownAll(() => goldenFileComparator = original);

  List<NeptuneQuickAction> actions([void Function()? onTap]) => [
        for (final label in ['Transfer', 'QR', 'Cards store', 'Services'])
          NeptuneQuickAction(
              icon: Icons.circle_outlined, label: label, onTap: onTap ?? () {}),
      ];

  Widget host(Widget child,
          {ThemeData? theme,
          TextDirection dir = TextDirection.ltr,
          TextScaler scaler = TextScaler.noScaling,
          bool reduced = false}) =>
      MaterialApp(
        theme: theme ?? NeptuneTheme.light('neptune'),
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: scaler, disableAnimations: reduced),
          child: Directionality(textDirection: dir, child: app!),
        ),
        home: Scaffold(body: child),
      );

  Widget band(ThemeData theme, {NeptuneQuickActionShell? shell}) {
    final scheme = theme.colorScheme;
    return Container(
      color: scheme.primary,
      padding: const EdgeInsetsDirectional.all(24),
      child: NeptuneQuickActions(
        actions: actions(),
        shell: shell ?? NeptuneQuickActionShell.boxedTiles,
        ink: scheme.onPrimary,
      ),
    );
  }

  double extentOf(WidgetTester tester) =>
      (tester.renderObject(find.byType(SliverAppBar)) as RenderSliver)
          .geometry!
          .paintExtent;

  Material tileOf(WidgetTester tester, String label) => tester.widget<Material>(
      find
          .ancestor(of: find.text(label), matching: find.byType(Material))
          .first);

  group('boxedTiles', () {
    testWidgets('is flat: the ink at a state-layer opacity, no shadow',
        (tester) async {
      final theme = NeptuneTheme.light('neptune');
      await tester.pumpWidget(host(band(theme), theme: theme));

      final tile = tileOf(tester, 'Transfer');
      expect(tile.color, theme.colorScheme.onPrimary.withValues(alpha: 0.14));
      expect(tile.elevation, 0);
      expect(tile.shadowColor, isNull);
      expect(find.byType(DecoratedBox).evaluate().where((e) {
        final d = (e.widget as DecoratedBox).decoration;
        return d is BoxDecoration && (d.gradient != null || d.boxShadow != null);
      }), isEmpty);

      final shape = theme.extension<NptShape>()!;
      expect((tile.shape as RoundedRectangleBorder).borderRadius, shape.rXl);
    });

    testWidgets('every tile is one height and at least 80dp, a caption may wrap',
        (tester) async {
      final theme = NeptuneTheme.light('neptune');
      await tester.pumpWidget(host(band(theme), theme: theme));
      final heights = [
        for (final l in ['Transfer', 'QR', 'Cards store', 'Services'])
          tester.getSize(find
              .ancestor(of: find.text(l), matching: find.byType(Material))
              .first)
              .height,
      ];
      expect(heights.toSet(), hasLength(1));
      expect(heights.first, greaterThanOrEqualTo(80));
    });

    testWidgets('reflows to two columns at a large text scale', (tester) async {
      final theme = NeptuneTheme.light('neptune');
      await tester.pumpWidget(host(band(theme),
          theme: theme, scaler: const TextScaler.linear(1.6)));
      final a = tester.getTopLeft(find.text('Transfer'));
      final b = tester.getTopLeft(find.text('QR'));
      final c = tester.getTopLeft(find.text('Cards store'));
      expect(a.dy, b.dy, reason: 'two to a row');
      expect(c.dy, greaterThan(a.dy), reason: 'the third wraps to a second row');
    });

    testWidgets('mirrors under RTL', (tester) async {
      final theme = NeptuneTheme.light('neptune');
      await tester.pumpWidget(host(band(theme), theme: theme));
      final ltr = tester.getCenter(find.text('Transfer')).dx;
      await tester.pumpWidget(
          host(band(theme), theme: theme, dir: TextDirection.rtl));
      final rtl = tester.getCenter(find.text('Transfer')).dx;
      expect(ltr, lessThan(400 / 2));
      expect(rtl, greaterThan(400 / 2));
    });

    testWidgets('press morphs xl to lg on the brand spring and settles back',
        (tester) async {
      final theme = NeptuneTheme.light('neptune');
      final shape = theme.extension<NptShape>()!;
      var taps = 0;
      await tester.pumpWidget(host(
          NeptuneQuickActions(
              actions: actions(() => taps++),
              shell: NeptuneQuickActionShell.boxedTiles),
          theme: theme));

      final g = await tester.startGesture(tester.getCenter(find.text('QR')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      var r = (tileOf(tester, 'QR').shape as RoundedRectangleBorder)
          .borderRadius as BorderRadius;
      expect(r.topLeft.x, closeTo(shape.lg, 0.01));

      await g.up();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      r = (tileOf(tester, 'QR').shape as RoundedRectangleBorder).borderRadius
          as BorderRadius;
      expect(r.topLeft.x, closeTo(shape.xl, 0.01));
      expect(taps, 1);
    });

    testWidgets('under reduced motion the press is immediate', (tester) async {
      final theme = NeptuneTheme.light('neptune');
      final shape = theme.extension<NptShape>()!;
      await tester.pumpWidget(host(
          NeptuneQuickActions(
              actions: actions(), shell: NeptuneQuickActionShell.boxedTiles),
          theme: theme,
          reduced: true));
      await tester.startGesture(tester.getCenter(find.text('QR')));
      await tester.pump();
      await tester.pump();
      final r = (tileOf(tester, 'QR').shape as RoundedRectangleBorder)
          .borderRadius as BorderRadius;
      expect(r.topLeft.x, closeTo(shape.lg, 0.01));
    });

    testWidgets('is one named button per action', (tester) async {
      final theme = NeptuneTheme.light('neptune');
      await tester.pumpWidget(host(band(theme), theme: theme));
      final handle = tester.ensureSemantics();
      expect(tester.getSemantics(find.text('QR')),
          matchesSemantics(
              label: 'QR',
              isButton: true,
              hasTapAction: true,
              hasEnabledState: true,
              isEnabled: true));
      handle.dispose();
    });

    testWidgets('the other shells and the default are untouched',
        (tester) async {
      await tester.pumpWidget(host(NeptuneQuickActions(actions: actions())));
      expect(find.byType(InkWell), findsNWidgets(4));
      // The tonal disc, not a boxed tile: a circle chip is a full-radius Material.
      final m = tester.widget<Material>(find
          .ancestor(of: find.byIcon(Icons.circle_outlined).first, matching: find.byType(Material))
          .first);
      expect((m.borderRadius as BorderRadius).topLeft.x, greaterThan(100));
    });
  });

  group('boxedTiles goldens', () {
    for (final brand in kBrands) {
      for (final (mode, dir) in [
        ('light', TextDirection.ltr),
        ('dark', TextDirection.rtl),
      ]) {
        testWidgets('$brand $mode ${dir.name}', (tester) async {
          await tester.binding.setSurfaceSize(const Size(390, 170));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final theme = mode == 'light'
              ? NeptuneTheme.light(brand)
              : NeptuneTheme.dark(brand);
          await tester.pumpWidget(host(
              Align(alignment: Alignment.topCenter, child: band(theme)),
              theme: theme,
              dir: dir));
          await tester.pumpAndSettle();
          await expectLater(find.byType(Scaffold),
              matchesGoldenFile('goldens/boxed_tiles_${brand}_${mode}_${dir.name}.png'));
        });
      }
    }
  });

  // A brand the registry has never seen, with the ruled register set: the
  // tiles must not read it - a lever that is unset leaves a brand alone, and
  // one that is set elsewhere in the theme must not leak in here.
  for (final (mode, dir) in [
    ('light', TextDirection.ltr),
    ('dark', TextDirection.rtl),
  ]) {
    testWidgets('boxedTiles golden ruled-register brand $mode ${dir.name}',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 170));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const cfg = BrandprintConfig(
        primary: Seed(l: 0.34, c: 0.132, h: 255),
        tertiary: Seed(l: 0.48, c: 0.087, h: 242),
        corners: Corners(xs: 6, sm: 8, md: 12, lg: 16, xl: 20, xxl: 200),
        displayWeight: 700,
        displayTracking: -0.02,
        fontDisplay: 'IBM Plex Sans Arabic',
        fontText: 'IBM Plex Sans Arabic',
        fontNum: 'IBM Plex Sans Arabic',
        loginShell: 'field-paper',
        dashboardHero: 'balance-field',
        contentTone: 'formal-authoritative',
        glassTint: 'oceanic',
        motion: 'calm-graceful',
        motif: 'none',
        navShell: 'ink-pill',
        actionRow: 'tonal-tiles',
        ruledRegister: true,
      );
      final theme = NeptuneTheme.fromConfig(cfg,
          brightness: mode == 'light' ? Brightness.light : Brightness.dark);
      await tester.pumpWidget(host(
          Align(alignment: Alignment.topCenter, child: band(theme)),
          theme: theme,
          dir: dir));
      await tester.pumpAndSettle();
      await expectLater(find.byType(Scaffold),
          matchesGoldenFile('goldens/boxed_tiles_ruled_${mode}_${dir.name}.png'));
    });
  }

  group('NeptuneTopBar', () {
    Widget scrolling(String title,
        {NeptuneTopBarSize size = NeptuneTopBarSize.large,
        Widget? leading,
        ThemeData? theme}) {
      return host(
        CustomScrollView(
          slivers: [
            NeptuneSliverTopBar(
              title: title,
              size: size,
              leading: leading,
              actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.info))],
            ),
            SliverList.builder(
                itemCount: 40,
                itemBuilder: (_, i) => SizedBox(height: 56, child: Text('row $i'))),
          ],
        ),
        theme: theme,
      );
    }

    testWidgets('the small bar is 64dp, flat, and shows its title once',
        (tester) async {
      final theme = NeptuneTheme.light('neptune');
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          appBar: NeptuneTopBar(
            title: 'Cards',
            leading: IconButton(
                onPressed: () {}, icon: const Icon(Icons.arrow_back)),
          ),
        ),
      ));
      expect(tester.getSize(find.byType(AppBar)).height, 64);
      final bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.scrolledUnderElevation, 0);
      expect(bar.backgroundColor, theme.colorScheme.surface);
      expect(find.text('Cards'), findsOneWidget);
    });

    testWidgets('the leading mark sits at the end of an RTL page',
        (tester) async {
      Widget bar(TextDirection d) => MaterialApp(
            theme: NeptuneTheme.light('neptune'),
            builder: (c, app) => Directionality(textDirection: d, child: app!),
            home: Scaffold(
              appBar: NeptuneTopBar(
                title: 'Cards',
                leading: IconButton(
                    onPressed: () {}, icon: const Icon(Icons.arrow_back)),
              ),
            ),
          );
      await tester.pumpWidget(bar(TextDirection.ltr));
      final ltr = tester.getCenter(find.byIcon(Icons.arrow_back)).dx;
      await tester.pumpWidget(bar(TextDirection.rtl));
      final rtl = tester.getCenter(find.byIcon(Icons.arrow_back)).dx;
      expect(ltr, lessThan(100));
      expect(rtl, greaterThan(700));
    });

    for (final (size, rest) in [
      (NeptuneTopBarSize.large, 128.0),
      (NeptuneTopBarSize.medium, 112.0),
    ]) {
      testWidgets('${size.name}: $rest at rest, collapses to 64 and cross-fades',
          (tester) async {
        await tester.pumpWidget(scrolling('Cards', size: size));
        expect(extentOf(tester), rest);

        double opacityOf(int i) =>
            tester.widgetList<Opacity>(find.byType(Opacity)).elementAt(i).opacity;
        // [0] is the big title, [1] the small one.
        expect(opacityOf(0), 1);
        expect(opacityOf(1), 0);

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(extentOf(tester), 64);
        expect(opacityOf(0), 0);
        expect(opacityOf(1), 1);
      });
    }

    testWidgets('exposes the title to a screen reader exactly once',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(scrolling('Cards'));
      expect(find.bySemanticsLabel('Cards'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('clearAtRest is transparent at rest and fills when scrolled under',
        (tester) async {
      final theme = NeptuneTheme.light('neptune');
      await tester.pumpWidget(host(
        CustomScrollView(slivers: [
          NeptuneSliverTopBar(title: 'Home', clearAtRest: true, background: theme.colorScheme.primary),
          SliverList.builder(
              itemCount: 40,
              itemBuilder: (_, i) => SizedBox(height: 56, child: Text('row $i'))),
        ]),
        theme: theme,
      ));
      WidgetStateColor bg() => tester
          .widget<SliverAppBar>(find.byType(SliverAppBar))
          .backgroundColor! as WidgetStateColor;
      expect(bg().resolve({}).a, 0);
      expect(bg().resolve({WidgetState.scrolledUnder}), theme.colorScheme.primary);
    });
  });

  group('NeptuneAccountNumber', () {
    const iban = 'LY87027101101907091501015';
    final copied = <String>[];

    setUp(() {
      copied.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      });
    });
    tearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    Widget pump(Widget w, {TextDirection dir = TextDirection.ltr}) =>
        host(Center(child: SizedBox(width: 320, child: w)), dir: dir);

    test('groups in fours, upper-cases, ignores whitespace; masks to one width', () {
      expect(groupedAccountNumber(iban), 'LY87 0271 0110 1907 0915 0101 5');
      expect(groupedAccountNumber(' ly87 0271 0110 1907 0915 0101 5 '),
          'LY87 0271 0110 1907 0915 0101 5');
      expect(maskedAccountNumber(iban), 'LY87 •••• •••• •••• 1015');
      expect(maskedAccountNumber('1234'), '••••');
    });

    testWidgets('16sp or more, semibold, tabular, one LTR run in an RTL page',
        (tester) async {
      await tester.pumpWidget(pump(
          const NeptuneAccountNumber(value: iban, copyLabel: 'copy'),
          dir: TextDirection.rtl));
      final text = tester.widget<Text>(find.text('LY87 0271 0110 1907 0915 0101 5'));
      expect(text.style!.fontSize, greaterThanOrEqualTo(16));
      expect(text.style!.fontWeight, FontWeight.w600);
      expect(text.style!.fontFeatures, contains(const FontFeature.tabularFigures()));
      expect(
          Directionality.of(tester.element(find.text('LY87 0271 0110 1907 0915 0101 5'))),
          TextDirection.ltr);
    });

    testWidgets('a tap and a long press copy the raw value and tell the host',
        (tester) async {
      var told = 0;
      await tester.pumpWidget(pump(NeptuneAccountNumber(
          value: iban, copyLabel: 'copy', onCopied: () => told++)));
      await tester.tap(find.byType(NeptuneAccountNumber));
      await tester.longPress(find.byType(NeptuneAccountNumber));
      expect(copied, [iban, iban]);
      expect(told, 2);
      expect(tester.getSize(find.byType(InkWell)).height, greaterThanOrEqualTo(48));
    });

    testWidgets('masked draws hidden, still copies the whole value, speaks no digit',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(pump(const NeptuneAccountNumber(
          value: iban,
          copyLabel: 'copy',
          masked: true,
          label: 'IBAN',
          hiddenLabel: 'hidden')));
      expect(find.text('LY87 •••• •••• •••• 1015'), findsOneWidget);
      expect(find.bySemanticsLabel('IBAN, hidden, copy'), findsOneWidget);
      await tester.tap(find.byType(NeptuneAccountNumber));
      expect(copied, [iban]);
      handle.dispose();
    });

    testWidgets('a number that must not be copied has no copy mark and copies nothing',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(pump(NeptuneAccountNumber(
          value: '•••• 4471',
          copyLabel: 'copy',
          copyable: false,
          onTap: () => taps++)));
      expect(find.byIcon(Icons.copy_outlined), findsNothing);
      await tester.tap(find.byType(NeptuneAccountNumber));
      expect(copied, isEmpty);
      expect(taps, 1);
    });

    testWidgets('spells the digits a group at a time', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(pump(const NeptuneAccountNumber(
          value: 'LY870271', label: 'IBAN', copyLabel: 'copy')));
      expect(find.bySemanticsLabel('IBAN, L Y 8 7, 0 2 7 1, copy'), findsOneWidget);
      handle.dispose();
    });
  });
}
