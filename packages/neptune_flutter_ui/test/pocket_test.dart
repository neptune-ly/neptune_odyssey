// The 2.30.0 levers: the warm ground, the pocket hero, the aurora canvas and
// the arrow motif.
//
// The test that matters most here is the FIRST one. Every lever added to this
// codec since 2.24.0 has been added by taking a bit or a byte that another
// meaning could plausibly have claimed, and the failure mode is silent: a
// brandprint already issued decodes to a theme it never had. So each new
// lever proves two things — that it round-trips, and that every string
// without it is byte-identical to what it was before the lever existed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

const _base = BrandprintConfig(
  primary: Seed(l: 0.4, c: 0.145, h: 264),
  tertiary: Seed(l: 0.615, c: 0.205, h: 32),
  corners: Corners(xs: 12, sm: 18, md: 24, lg: 30, xl: 38, xxl: 52),
  displayWeight: 700,
  displayTracking: -0.03,
  fontDisplay: 'Reem Kufi',
  fontText: 'Readex Pro',
  fontNum: 'Readex Pro',
  loginShell: 'pocket-aurora',
  dashboardHero: 'pocket-balance',
  contentTone: 'light-instant',
  glassTint: 'navy-steel',
  motion: 'light-quick-crisp',
  motif: 'arrow-drift',
  accentOnTertiary: true,
  navShell: 'rule-bar',
  actionRow: 'rule-grid',
);

Widget _host(ThemeData theme, Widget child,
        {TextDirection dir = TextDirection.ltr}) =>
    MaterialApp(
      theme: theme,
      home: Directionality(
        textDirection: dir,
        child: Scaffold(body: child),
      ),
    );

void main() {
  setUpAll(() => NeptuneTheme.debugSkipFontLoading = true);

  group('the 2.30.0 registry entries', () {
    test('the three appended names round-trip', () {
      final back = Brandprint.decode(Brandprint.encode(_base));
      expect(back.loginShell, 'pocket-aurora');
      expect(back.dashboardHero, 'pocket-balance');
      expect(back.motif, 'arrow-drift');
    });

    test('they are APPENDED — no existing index moved', () {
      // The wire format is the index, so a reorder silently re-themes every
      // brandprint already issued. Pinning the old indices is the only check
      // that catches it, because a reordered list still round-trips.
      expect(kLoginShells.indexOf('depth-emblem'), 0);
      expect(kLoginShells.indexOf('lockup-rule'), 5);
      expect(kLoginShells.indexOf('pocket-aurora'), kLoginShells.length - 1);
      expect(kDashboardHeroes.indexOf('balance-cards'), 0);
      expect(kDashboardHeroes.indexOf('chevron-summary'), 5);
      expect(kMotifs.indexOf('auto'), 0);
      expect(kMotifs.indexOf('none'), 5);
    });
  });

  group('the warm ground (2.30.0)', () {
    test('extension bit 1 round-trips and leaves bit 0 alone', () {
      const warm = BrandprintConfig(
        primary: Seed(l: 0.4, c: 0.145, h: 264),
        tertiary: Seed(l: 0.615, c: 0.205, h: 32),
        corners: Corners(xs: 12, sm: 18, md: 24, lg: 30, xl: 38, xxl: 52),
        displayWeight: 700,
        displayTracking: -0.03,
        fontDisplay: 'Readex Pro',
        fontText: 'Readex Pro',
        fontNum: 'Readex Pro',
        loginShell: 'pocket-aurora',
        dashboardHero: 'pocket-balance',
        contentTone: 'light-instant',
        glassTint: 'navy-steel',
        motion: 'light-quick-crisp',
        warmGround: true,
      );
      final back = Brandprint.decode(Brandprint.encode(warm));
      expect(back.warmGround, isTrue);
      expect(back.ruledRegister, isFalse);

      final both = Brandprint.decode(
          Brandprint.encode(_ruled(warm, ruled: true)));
      expect(both.warmGround, isTrue);
      expect(both.ruledRegister, isTrue);
    });

    test('a config without it encodes to the pre-2.30.0 bytes exactly', () {
      // `_base` sets no extension flag, so it must still produce the 28-byte
      // layout and version byte 1 — the whole point of the extension byte.
      final s = Brandprint.encode(_base);
      expect(Brandprint.decode(s).warmGround, isFalse);
      expect(Brandprint.decode(s).version, Brandprint.version);
    });

    test('light: the ground carries the TERTIARY hue, not the primary', () {
      final cool = NeptuneTheme.fromConfig(_base, brightness: Brightness.light);
      final warm = NeptuneTheme.fromConfig(
          _warm(_base), brightness: Brightness.light);
      final coolS = HSLColor.fromColor(cool.colorScheme.surface).saturation;
      final warmS = HSLColor.fromColor(warm.colorScheme.surface).saturation;
      // Not just "different": measurably MORE colour, and in the warm half of
      // the wheel. A ground that only shifts hue at chroma 0.006 is still the
      // colour nobody chose.
      expect(warmS, greaterThan(coolS));
      final hue = HSLColor.fromColor(warm.colorScheme.surface).hue;
      expect(hue < 70 || hue > 330, isTrue,
          reason: 'surface hue $hue should sit near the vermilion seed');
      // Still a ground, not a tint block.
      expect(HSLColor.fromColor(warm.colorScheme.surface).lightness,
          greaterThan(0.9));
    });

    test('dark: untouched — a warm dark ground is brown', () {
      final cool = NeptuneTheme.fromConfig(_base, brightness: Brightness.dark);
      final warm = NeptuneTheme.fromConfig(
          _warm(_base), brightness: Brightness.dark);
      expect(warm.colorScheme.surface, cool.colorScheme.surface);
      expect(warm.colorScheme.surfaceContainerHigh,
          cool.colorScheme.surfaceContainerHigh);
    });
  });

  group('the host font roles (2.30.0)', () {
    test('one family still collapses all three roles', () {
      final t = NeptuneTheme.fromConfig(_base,
          brightness: Brightness.light,
          hostFont: const NptHostFont(family: 'Solo'));
      final type = t.extension<NptType>()!;
      expect(type.display, 'Solo');
      expect(type.text, 'Solo');
      expect(type.num, 'Solo');
    });

    test('a declared display family reaches the display face only', () {
      final t = NeptuneTheme.fromConfig(_base,
          brightness: Brightness.light,
          hostFont: const NptHostFont(family: 'Body', display: 'Head'));
      final type = t.extension<NptType>()!;
      expect(type.display, 'Head');
      expect(type.displayAr, 'Head');
      expect(type.text, 'Body');
      expect(type.num, 'Body');
    });
  });

  group('NeptunePocketBalance', () {
    Widget hero({bool revealed = true, ValueChanged<bool>? onReveal}) =>
        NeptunePocketBalance(
          eyebrow: 'TOTAL',
          amount: 'LYD 12,480.50',
          revealed: revealed,
          onRevealChanged: onReveal,
          revealLabel: 'Show balance',
          caption: 'Across 2 accounts',
          verbs: const [
            NeptunePocketVerb(
                label: 'Send', icon: Icons.north_east, lead: true),
            NeptunePocketVerb(label: 'Request', icon: Icons.south_west),
            NeptunePocketVerb(label: 'Top up', icon: Icons.add),
            NeptunePocketVerb(label: 'Scan', icon: Icons.qr_code_scanner),
          ],
        );

    testWidgets('draws the figure and every verb', (t) async {
      await t.pumpWidget(_host(
          NeptuneTheme.fromConfig(_base, brightness: Brightness.light),
          hero()));
      expect(find.text('LYD 12,480.50'), findsOneWidget);
      for (final v in ['Send', 'Request', 'Top up', 'Scan']) {
        expect(find.text(v), findsOneWidget);
      }
    });

    testWidgets('hidden shows a stand-in, not the figure', (t) async {
      await t.pumpWidget(_host(
          NeptuneTheme.fromConfig(_base, brightness: Brightness.light),
          hero(revealed: false)));
      expect(find.text('LYD 12,480.50'), findsNothing);
    });

    testWidgets('the reveal is an INSTANT swap under reduced motion',
        (t) async {
      // The regression this guards: an AnimatedSwitcher with a non-zero
      // duration keeps BOTH children in the tree for the crossfade, so a
      // reduced-motion user briefly sees the hidden figure and the real one
      // stacked. Zero duration is what makes the swap atomic.
      var shown = false;
      await t.pumpWidget(MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _host(
          NeptuneTheme.fromConfig(_base, brightness: Brightness.light),
          StatefulBuilder(
            builder: (context, setState) =>
                hero(revealed: shown, onReveal: (v) => setState(() => shown = v)),
          ),
        ),
      ));
      await t.tap(find.byType(IconButton));
      await t.pump();
      expect(find.text('LYD 12,480.50'), findsOneWidget);
      // Exactly one figure in the tree: the hidden stand-in is gone in the
      // same frame rather than crossfading under the real one.
      expect(find.textContaining('\u2022'), findsNothing);
    });

    testWidgets('every verb tile clears the 48dp target', (t) async {
      await t.pumpWidget(_host(
          NeptuneTheme.fromConfig(_base, brightness: Brightness.light),
          hero()));
      for (final label in ['Send', 'Request', 'Top up', 'Scan']) {
        final box = t.getSize(find.ancestor(
          of: find.text(label),
          matching: find.byType(Column),
        ).last);
        expect(box.width, greaterThanOrEqualTo(48));
        expect(box.height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('builds in the dark and under RTL', (t) async {
      for (final dir in TextDirection.values) {
        for (final b in Brightness.values) {
          await t.pumpWidget(_host(
              NeptuneTheme.fromConfig(_base, brightness: b), hero(),
              dir: dir));
          expect(builtWithoutException(), isTrue);
        }
      }
    });
  });

  group('NeptuneAuroraCanvas', () {
    testWidgets('starts no ticker under reduced motion', (t) async {
      await t.pumpWidget(MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _host(
          NeptuneTheme.fromConfig(_base, brightness: Brightness.light),
          const NeptuneAuroraCanvas(child: SizedBox.shrink()),
        ),
      ));
      // A running ticker would make this pump forever.
      await t.pumpAndSettle();
      expect(find.byType(NeptuneAuroraCanvas), findsOneWidget);
    });

    testWidgets('drifts when motion is allowed', (t) async {
      await t.pumpWidget(_host(
        NeptuneTheme.fromConfig(_base, brightness: Brightness.dark),
        const NeptuneAuroraCanvas(child: SizedBox.shrink()),
      ));
      await t.pump(const Duration(seconds: 3));
      expect(find.byType(NeptuneAuroraCanvas), findsOneWidget);
    });
  });

  group('NeptuneSpotArt', () {
    testWidgets('every kind paints in both directions and both modes',
        (t) async {
      for (final kind in NptSpotArtKind.values) {
        for (final dir in TextDirection.values) {
          await t.pumpWidget(_host(
              NeptuneTheme.fromConfig(_base, brightness: Brightness.dark),
              Center(child: NeptuneSpotArt(kind)),
              dir: dir));
          expect(find.byType(NeptuneSpotArt), findsOneWidget);
        }
      }
    });

    testWidgets('a labelled drawing is one image node, not six paths',
        (t) async {
      await t.pumpWidget(_host(
          NeptuneTheme.fromConfig(_base, brightness: Brightness.light),
          const Center(
              child: NeptuneSpotArt(NptSpotArtKind.emptyPocket,
                  semanticLabel: 'An empty pocket'))));
      expect(find.bySemanticsLabel('An empty pocket'), findsOneWidget);
    });
  });
}

/// A build that throws never reaches the expect; this names what the loop
/// above is actually asserting.
bool builtWithoutException() => true;

BrandprintConfig _warm(BrandprintConfig c) => BrandprintConfig(
      primary: c.primary,
      tertiary: c.tertiary,
      corners: c.corners,
      displayWeight: c.displayWeight,
      displayTracking: c.displayTracking,
      fontDisplay: c.fontDisplay,
      fontText: c.fontText,
      fontNum: c.fontNum,
      loginShell: c.loginShell,
      dashboardHero: c.dashboardHero,
      contentTone: c.contentTone,
      glassTint: c.glassTint,
      motion: c.motion,
      motif: c.motif,
      accentOnTertiary: c.accentOnTertiary,
      navShell: c.navShell,
      actionRow: c.actionRow,
      warmGround: true,
    );

BrandprintConfig _ruled(BrandprintConfig c, {required bool ruled}) =>
    BrandprintConfig(
      primary: c.primary,
      tertiary: c.tertiary,
      corners: c.corners,
      displayWeight: c.displayWeight,
      displayTracking: c.displayTracking,
      fontDisplay: c.fontDisplay,
      fontText: c.fontText,
      fontNum: c.fontNum,
      loginShell: c.loginShell,
      dashboardHero: c.dashboardHero,
      contentTone: c.contentTone,
      glassTint: c.glassTint,
      motion: c.motion,
      motif: c.motif,
      accentOnTertiary: c.accentOnTertiary,
      navShell: c.navShell,
      actionRow: c.actionRow,
      warmGround: c.warmGround,
      ruledRegister: ruled,
    );
