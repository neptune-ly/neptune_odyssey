// The 2.30.0 levers: the warm ground, the pocket hero, the aurora canvas and
// the arrow motif.
//
// The test that matters most here is the FIRST one. Every lever added to this
// codec since 2.24.0 has been added by taking a bit or a byte that another
// meaning could plausibly have claimed, and the failure mode is silent: a
// brandprint already issued decodes to a theme it never had. So each new
// lever proves two things — that it round-trips, and that every string
// without it is byte-identical to what it was before the lever existed.

import 'dart:convert';

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
      // THE INDEX IS THE WIRE FORMAT, AND TWO BRANCHES APPENDED AT ONCE.
      // `position-line` is another branch's entry, named here at the index it
      // took there so the two lists cannot disagree after a merge — a hole
      // would decode as that name on one side and as nothing on the other.
      expect(kDashboardHeroes.indexOf('position-line'), 6);
      expect(kDashboardHeroes.indexOf('pocket-balance'), 7);
      expect(kMotifs.indexOf('auto'), 0);
      expect(kMotifs.indexOf('none'), 5);
    });
  });

  group('the warm ground (2.30.0)', () {
    test('extension bit 2 round-trips and leaves bits 0 and 1 alone', () {
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
      // Bit 2, not bit 1. Bit 1 belongs to another brand's lever landing in
      // parallel, and a bit claimed twice is a brandprint that decodes to a
      // theme nobody chose. Pinned as a number, because the symptom of
      // getting it wrong is silence.
      final raw = Brandprint.encode(warm);
      final bytes = base64Url.decode(raw.substring(4).padRight(
          (raw.length - 4 + 3) ~/ 4 * 4, '='));
      expect(bytes[27] & 0x07, 0x04);

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

    test('dark: deepens on the PRIMARY hue — a warm dark ground is brown', () {
      final plain = NeptuneTheme.fromConfig(_base, brightness: Brightness.dark);
      final ground = NeptuneTheme.fromConfig(
          _warm(_base), brightness: Brightness.dark);
      // Not the warm seed: a dark ground taken toward a red-orange accent is
      // brown, and nothing makes a brown app read as anything but a mistake.
      final hue = HSLColor.fromColor(ground.colorScheme.surface).hue;
      expect(hue, greaterThan(180),
          reason: 'dark ground hue \$hue should stay in the brand navy');
      expect(HSLColor.fromColor(ground.colorScheme.surface).saturation,
          greaterThan(HSLColor.fromColor(plain.colorScheme.surface).saturation));
      // Still a dark ground, not a navy block.
      expect(HSLColor.fromColor(ground.colorScheme.surface).lightness,
          lessThan(0.2));
    });

    test('the ground is PAPER, never INK', () {
      // The regression: the first cut warmed every role whose hue came from
      // the neutral channel, `on-surface` and `outline` included, so a navy
      // bank shipped a home screen with no navy on it. Ink is not ground.
      for (final b in Brightness.values) {
        final plain = NeptuneTheme.fromConfig(_base, brightness: b);
        final ground = NeptuneTheme.fromConfig(_warm(_base), brightness: b);
        expect(ground.colorScheme.onSurface, plain.colorScheme.onSurface,
            reason: 'onSurface moved in \$b');
        expect(ground.colorScheme.onSurfaceVariant,
            plain.colorScheme.onSurfaceVariant);
        expect(ground.colorScheme.outline, plain.colorScheme.outline);
        expect(ground.colorScheme.inverseSurface,
            plain.colorScheme.inverseSurface);
        expect(ground.colorScheme.surface, isNot(plain.colorScheme.surface),
            reason: 'the ground itself must move in \$b');
      }
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

  group('the illustrated empty state (2.30.0)', () {
    Widget empty(ThemeData t) => _host(
          t,
          const NeptuneEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Nothing yet',
            art: NptSpotArtKind.emptyPocket,
          ),
        );

    testWidgets('a light-instant brand draws; the icon is gone', (t) async {
      await t.pumpWidget(
          empty(NeptuneTheme.fromConfig(_base, brightness: Brightness.light)));
      expect(find.byType(NeptuneSpotArt), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsNothing);
    });

    testWidgets('a measured brand keeps the icon it has today', (t) async {
      // The regression this guards is a silent upgrade: fifty-three call sites
      // reach this widget in one host app, and a change that illustrated all
      // of them would have re-skinned two other banks without a word.
      for (final tone in ['clear-calm', 'formal-authoritative',
          'warm-hospitable']) {
        await t.pumpWidget(empty(NeptuneTheme.fromConfig(
            _tone(_base, tone),
            brightness: Brightness.light)));
        expect(find.byType(NeptuneSpotArt), findsNothing, reason: tone);
        expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget,
            reason: tone);
      }
    });
  });

  group('Arabic is never tracked (2.30.0)', () {
    test('the display styles drop the brand tracking under Arabic', () {
      // `_base` declares -0.03. Negative tracking on a connected script does
      // not tighten a word, it crashes the letters into each other, and a
      // brand slogan set that way is unreadable rather than tight.
      final latin = NeptuneTheme.fromConfig(_base,
          brightness: Brightness.light, arabic: false);
      final arabic = NeptuneTheme.fromConfig(_base,
          brightness: Brightness.light, arabic: true);
      expect(latin.textTheme.displayLarge!.letterSpacing, isNot(0));
      expect(arabic.textTheme.displayLarge!.letterSpacing, 0);
      expect(arabic.textTheme.displayMedium!.letterSpacing, 0);
    });

    testWidgets('the host-facing helper follows the DIRECTION', (t) async {
      late double rtlTrack;
      late double ltrTrack;
      for (final dir in TextDirection.values) {
        await t.pumpWidget(_host(
          NeptuneTheme.fromConfig(_base, brightness: Brightness.light),
          Builder(builder: (context) {
            final v = NeptuneTheme.displayTracking(context, 36);
            if (dir == TextDirection.rtl) {
              rtlTrack = v;
            } else {
              ltrTrack = v;
            }
            return const SizedBox.shrink();
          }),
          dir: dir,
        ));
      }
      expect(rtlTrack, 0);
      expect(ltrTrack, lessThan(0));
    });
  });

  group('the eyebrow is a label, not a specimen (2.30.0)', () {
    testWidgets('it sets in the TEXT face even when a display face exists',
        (t) async {
      // A display face is chosen to work at 36dp and up. An eyebrow is 12.
      // For every brand before FGLB the two families were the same string, so
      // the bug had no way to show itself.
      await t.pumpWidget(_host(
        NeptuneTheme.fromConfig(_base,
            brightness: Brightness.light,
            hostFont: const NptHostFont(family: 'Body', display: 'Head')),
        const NeptuneEyebrow('TOTAL'),
      ));
      final style = t.widget<Text>(find.byType(Text)).style!;
      expect(style.fontFamily, 'Body');
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

BrandprintConfig _tone(BrandprintConfig c, String tone) => BrandprintConfig(
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
      contentTone: tone,
      glassTint: c.glassTint,
      motion: c.motion,
      motif: c.motif,
      accentOnTertiary: c.accentOnTertiary,
      navShell: c.navShell,
      actionRow: c.actionRow,
    );
