import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// `NptShape.pill` — the stadium a brand can square, and the circle it cannot.
///
/// `ruledRegister` already said "this brand draws structure in lines"; the
/// button theme and the CTA honoured it and every chip, segmented track and
/// switch on the same screen went on drawing a capsule, because they read
/// `full` — which also means "a circle", so squaring `full` would have squared
/// the avatars too. These tests pin the split.
BrandprintConfig _cfg({required bool ruled}) => BrandprintConfig(
      primary: const Seed(l: 0.358, c: 0.099, h: 262),
      tertiary: const Seed(l: 0.551, c: 0.19, h: 27),
      corners: const Corners(xs: 4, sm: 6, md: 8, lg: 10, xl: 12, xxl: 16),
      displayWeight: 700,
      displayTracking: -0.03,
      fontDisplay: 'IBM Plex Sans Arabic',
      fontText: 'IBM Plex Sans Arabic',
      fontNum: 'IBM Plex Sans Arabic',
      loginShell: 'lockup-rule',
      dashboardHero: 'position-line',
      contentTone: 'formal-authoritative',
      glassTint: 'navy-steel',
      motion: 'stable-minimal-authoritative',
      motif: 'none',
      ruledRegister: ruled,
    );

void main() {
  setUpAll(() => NeptuneTheme.debugSkipFontLoading = true);

  test('a ruled brand resolves the stadium to its own md corner', () {
    final theme = NeptuneTheme.fromConfig(_cfg(ruled: true));
    final shape = theme.extension<NptShape>()!;
    expect(shape.pill, shape.md);
    expect(shape.pill, 8);
    // The circle is untouched: an avatar is round whatever the brand is.
    expect(shape.full, 9999);
    expect(shape.pillBorder, isA<RoundedRectangleBorder>());
  });

  test('an unruled brand keeps a real StadiumBorder', () {
    final theme = NeptuneTheme.fromConfig(_cfg(ruled: false));
    final shape = theme.extension<NptShape>()!;
    expect(shape.pill, shape.full);
    // A real StadiumBorder, not a 9999 rounded rectangle: a Material widget
    // that lerps its shape keeps lerping between the classes it always did.
    expect(shape.pillBorder, isA<StadiumBorder>());
  });

  test('position-line is in the hero registry and survives the codec', () {
    expect(kDashboardHeroes, contains('position-line'));
    final cfg = _cfg(ruled: true);
    final decoded = Brandprint.decode(Brandprint.encode(cfg));
    expect(decoded.dashboardHero, 'position-line');
    expect(decoded.ruledRegister, isTrue);
    expect(decoded.corners, cfg.corners);
  });

  testWidgets('the ruled segmented control draws a rule, not a filled track',
      (tester) async {
    Future<BoxDecoration> track({required bool ruled}) async {
      await tester.pumpWidget(MaterialApp(
        theme: NeptuneTheme.fromConfig(_cfg(ruled: ruled)),
        home: Scaffold(
          body: NeptuneSegmented<int>(
            segments: const [
              NeptuneSegment(value: 0, label: 'A'),
              NeptuneSegment(value: 1, label: 'B'),
            ],
            value: 0,
            onChanged: (_) {},
          ),
        ),
      ));
      // The theme CHANGES between the two calls and MaterialApp lerps it, so
      // the frame straight after the pump still carries the previous brand's
      // identity extension.
      await tester.pumpAndSettle();
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(NeptuneSegmented<int>),
              matching: find.byType(Container),
            )
            .first,
      );
      return container.decoration! as BoxDecoration;
    }

    final ruled = await track(ruled: true);
    expect(ruled.color, isNull, reason: 'no tone-filled slab');
    expect(ruled.border, isNotNull, reason: 'the strip is a hairline');

    final filled = await track(ruled: false);
    expect(filled.color, isNotNull);
    expect(filled.border, isNull);
  });
}
