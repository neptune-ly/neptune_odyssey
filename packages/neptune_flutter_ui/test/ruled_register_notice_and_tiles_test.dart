// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The 3.1.0 levers behind Nuran's Odyssey 3 design:
//
//  * three wire names appended to registries that are append-only
//    (`field-paper`, `balance-field`, `tonal-tiles`), none of which may move a
//    string that already exists;
//  * the `tonal-tiles` quick-action shell;
//  * what the ruled register now reaches: the field's corner, the segmented
//    control and the alert.
//
// Every claim about "nothing else moved" is asserted on the unruled theme too,
// because the register is a lever and an unset lever must leave a brand alone.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import 'brandprint_production_test.dart' as prod;

List<int> _payload(String s) =>
    base64Url.decode(s.substring(4).padRight((s.length - 4 + 3) ~/ 4 * 4, '='));

BrandprintConfig _cfg({bool ruled = false, String action = 'filled-circles'}) =>
    BrandprintConfig(
      primary: const Seed(l: 0.34, c: 0.132, h: 255),
      tertiary: const Seed(l: 0.48, c: 0.087, h: 242),
      corners: const Corners(xs: 6, sm: 8, md: 12, lg: 16, xl: 20, xxl: 200),
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
      actionRow: action,
      ruledRegister: ruled,
    );

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  group('the registries stay append-only', () {
    test('the new names sit at the end and nothing before them moved', () {
      expect(kLoginShells.indexOf('field-paper'), 8);
      expect(kLoginShells.sublist(0, 8), [
        'depth-emblem',
        'arcade-arches',
        'light-grid-spark',
        'shield-guilloche',
        'paper-lockup',
        'lockup-rule',
        'pocket-drift',
        'drift-depth',
      ]);
      expect(kDashboardHeroes.indexOf('balance-field'), 8);
      expect(kDashboardHeroes.sublist(0, 8).last, 'pocket-balance');
      expect(kActionRows, [
        'filled-circles',
        'register-rows',
        'rule-grid',
        'tonal-tiles',
      ]);
    });

    test('they round-trip by name and do not grow the payload', () {
      for (final action in kActionRows) {
        final cfg = _cfg(action: action);
        final back = Brandprint.decode(Brandprint.encode(cfg));
        expect(back.actionRow, action);
        expect(back.loginShell, 'field-paper');
        expect(back.dashboardHero, 'balance-field');
        expect(_payload(Brandprint.encode(cfg)).length, lessThanOrEqualTo(29));
      }
    });

    test('every string already in the wild decodes exactly as before', () {
      expect(
        prod.kIssuedBefore2280.map(
            (k, v) => MapEntry(k, Brandprint.decode(v).actionRow)),
        {
          'andalus': 'filled-circles',
          'nuran': 'filled-circles',
          'fglb': 'filled-circles',
        },
      );
      for (final e in {
        'andalus': prod.andalusBrandprint,
        'nuran': prod.nuranBrandprint,
        'fglb': prod.fglbBrandprint,
      }.entries) {
        expect(Brandprint.encode(e.value),
            Brandprint.encode(Brandprint.decode(Brandprint.encode(e.value))),
            reason: '${e.key} must still round-trip byte-for-byte');
      }
    });

    test('every action-row name has a shell behind it', () {
      expect(kActionRows.length, NeptuneQuickActionShell.values.length);
    });
  });

  Widget host(ThemeData theme, Widget child,
          {TextDirection dir = TextDirection.ltr}) =>
      MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: dir,
          child: Scaffold(body: Center(child: child)),
        ),
      );

  group('the tonal-tiles shell', () {
    List<NeptuneQuickAction> actions() => [
          for (final label in ['Transfer', 'QR', 'Vouchers', 'Services'])
            NeptuneQuickAction(
                icon: Icons.circle_outlined, label: label, onTap: () {}),
        ];

    testWidgets('the lead is filled in secondary, the peers in the container',
        (tester) async {
      final theme = NeptuneTheme.fromConfig(_cfg(action: 'tonal-tiles'));
      await tester.pumpWidget(host(
          theme,
          NeptuneQuickActions(
              shell: NeptuneQuickActionShell.tonalTiles, actions: actions())));
      final scheme = theme.colorScheme;
      final materials = tester
          .widgetList<Material>(find.descendant(
              of: find.byType(NeptuneQuickActions),
              matching: find.byType(Material)))
          .where((m) => m.color != null && m.borderRadius != null)
          .toList();
      expect(materials.length, 4);
      expect(materials.first.color, scheme.secondary);
      for (final peer in materials.skip(1)) {
        expect(peer.color, scheme.secondaryContainer);
      }
      final xl = theme.extension<NptShape>()!.rXl;
      for (final m in materials) {
        expect(m.borderRadius, xl);
      }
    });

    testWidgets('the tiles are one height and at least a 48dp target',
        (tester) async {
      final theme = NeptuneTheme.fromConfig(_cfg(action: 'tonal-tiles'));
      await tester.pumpWidget(host(
          theme,
          SizedBox(
            width: 360,
            child: NeptuneQuickActions(
                shell: NeptuneQuickActionShell.tonalTiles,
                actions: [
                  for (final label in ['Transfer', 'A much longer caption', 'x', 'y'])
                    NeptuneQuickAction(
                        icon: Icons.circle_outlined, label: label, onTap: () {}),
                ]),
          )));
      final heights = tester
          .widgetList<Material>(find.descendant(
              of: find.byType(NeptuneQuickActions),
              matching: find.byType(Material)))
          .where((m) => m.color != null && m.borderRadius != null)
          .map((m) => tester.getSize(find.byWidget(m)).height)
          .toSet();
      expect(heights.length, 1, reason: 'one row, one tile height');
      expect(heights.single, greaterThanOrEqualTo(48));
    });

    testWidgets('a caption that does not fit wraps to a second line, one height',
        (tester) async {
      final theme = NeptuneTheme.fromConfig(_cfg(action: 'tonal-tiles'));
      await tester.pumpWidget(host(
          theme,
          SizedBox(
            width: 336,
            child: NeptuneQuickActions(
                shell: NeptuneQuickActionShell.tonalTiles,
                actions: [
                  // Two short words: under the test's square font a long one is wider
                  // than any tile whatever the wrap.
                  for (final label in ['Send', 'Top up', 'QR', 'More'])
                    NeptuneQuickAction(
                        icon: Icons.circle_outlined, label: label, onTap: () {}),
                ]),
          )));
      final long = tester.renderObject<RenderParagraph>(find.text('Top up'));
      final short = tester.renderObject<RenderParagraph>(find.text('Send'));
      expect(long.didExceedMaxLines, isFalse,
          reason: 'the caption is wrapped, not cut with an ellipsis');
      expect(long.size.height, greaterThan(short.size.height * 1.5));
      final heights = tester
          .widgetList<Material>(find.descendant(
              of: find.byType(NeptuneQuickActions),
              matching: find.byType(Material)))
          .where((m) => m.color != null && m.borderRadius != null)
          .map((m) => tester.getSize(find.byWidget(m)).height)
          .toSet();
      expect(heights.length, 1, reason: 'the row stays one height');
    });

    testWidgets('mirrors under RTL: the lead is on the right', (tester) async {
      final theme = NeptuneTheme.fromConfig(_cfg(action: 'tonal-tiles'));
      await tester.pumpWidget(host(
          theme,
          NeptuneQuickActions(
              shell: NeptuneQuickActionShell.tonalTiles, actions: actions()),
          dir: TextDirection.rtl));
      final lead = tester.getCenter(find.text('Transfer'));
      final last = tester.getCenter(find.text('Services'));
      expect(lead.dx, greaterThan(last.dx));
    });
  });

  group('what the ruled register reaches', () {
    test('a field takes the md corner, and sm when the register is off', () {
      final on = NeptuneTheme.fromConfig(_cfg(ruled: true));
      final off = NeptuneTheme.fromConfig(_cfg());
      final shape = on.extension<NptShape>()!;
      for (final border in [
        on.inputDecorationTheme.border,
        on.inputDecorationTheme.enabledBorder,
        on.inputDecorationTheme.focusedBorder,
        on.inputDecorationTheme.errorBorder,
        on.inputDecorationTheme.disabledBorder,
      ]) {
        expect((border! as OutlineInputBorder).borderRadius, shape.rMd);
      }
      expect((off.inputDecorationTheme.enabledBorder! as OutlineInputBorder)
              .borderRadius,
          shape.rSm);
    });

    testWidgets('the segmented control is a soft rectangle, not a capsule',
        (tester) async {
      final on = NeptuneTheme.fromConfig(_cfg(ruled: true));
      await tester.pumpWidget(host(
          on,
          SizedBox(
            width: 320,
            child: NeptuneSegmented<int>(
              value: 1,
              onChanged: (_) {},
              segments: const [
                NeptuneSegment(value: 0, label: 'Personal'),
                NeptuneSegment(value: 1, label: 'Business'),
              ],
            ),
          )));
      final shape = on.extension<NptShape>()!;
      final track = tester
          .widgetList<Container>(find.descendant(
              of: find.byType(NeptuneSegmented<int>),
              matching: find.byType(Container)))
          .first;
      final deco = track.decoration! as BoxDecoration;
      expect(deco.borderRadius, shape.rMd);
      expect(deco.color, on.colorScheme.secondaryContainer);
      final selected = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((c) => (c.decoration as BoxDecoration?))
          .whereType<BoxDecoration>()
          .where((d) => d.color == on.colorScheme.surfaceContainerLowest);
      expect(selected.length, 1, reason: 'exactly the chosen segment is raised');
    });

    testWidgets('an unruled brand keeps the capsule and the tonal pill',
        (tester) async {
      final off = NeptuneTheme.fromConfig(_cfg());
      await tester.pumpWidget(host(
          off,
          SizedBox(
            width: 320,
            child: NeptuneSegmented<int>(
              value: 0,
              onChanged: (_) {},
              segments: const [
                NeptuneSegment(value: 0, label: 'A'),
                NeptuneSegment(value: 1, label: 'B'),
              ],
            ),
          )));
      final track = tester
          .widgetList<Container>(find.descendant(
              of: find.byType(NeptuneSegmented<int>),
              matching: find.byType(Container)))
          .first;
      final deco = track.decoration! as BoxDecoration;
      expect(deco.color, off.colorScheme.surfaceContainer);
      expect(deco.borderRadius,
          BorderRadius.circular(off.extension<NptShape>()!.full));
    });

    testWidgets('an alert is one tonal ground with the tone on glyph and title',
        (tester) async {
      final on = NeptuneTheme.fromConfig(_cfg(ruled: true));
      await tester.pumpWidget(host(
          on,
          const SizedBox(
            width: 340,
            child: NeptuneAlert(
              tone: NeptuneAlertTone.danger,
              title: 'Check the details',
              message: 'Use the details shown on your account.',
            ),
          )));
      final box = tester.widget<Container>(find
          .descendant(
              of: find.byType(NeptuneAlert), matching: find.byType(Container))
          .first);
      final deco = box.decoration! as BoxDecoration;
      expect(deco.color, on.colorScheme.secondaryContainer);
      expect(deco.border, isNull, reason: 'no accent bar in the ruled register');
      final title = tester.widget<Text>(find.text('Check the details'));
      expect(title.style!.color, on.colorScheme.error);
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, on.colorScheme.error);
      expect(icon.size, 24);
    });

    testWidgets('information is ink, never the brand secondary', (tester) async {
      final on = NeptuneTheme.fromConfig(_cfg(ruled: true));
      await tester.pumpWidget(host(
          on,
          const SizedBox(
            width: 340,
            child: NeptuneAlert(title: 'Information', message: 'A message.'),
          )));
      final title = tester.widget<Text>(find.text('Information'));
      expect(title.style!.color, on.colorScheme.onSurface);
    });

    testWidgets('an unruled brand keeps the washed ground and the accent bar',
        (tester) async {
      final off = NeptuneTheme.fromConfig(_cfg());
      await tester.pumpWidget(host(
          off,
          const SizedBox(
            width: 340,
            child: NeptuneAlert(
              tone: NeptuneAlertTone.danger,
              title: 'Check the details',
              message: 'Use the details shown on your account.',
            ),
          )));
      final box = tester.widget<Container>(find
          .descendant(
              of: find.byType(NeptuneAlert), matching: find.byType(Container))
          .first);
      final deco = box.decoration! as BoxDecoration;
      expect(deco.border, isNotNull);
      expect(deco.color,
          off.colorScheme.error.withValues(alpha: 0.12));
    });
  });
}
