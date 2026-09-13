// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// THE THREE BRANDPRINTS THAT ARE ACTUALLY IN PRODUCTION.
//
// `brandprint_golden_test.dart` proves the codec against the four reference
// brands and two synthetic entries in the fixture. None of those is a bank.
// The three configs below are copied verbatim from the app that ships to
// customers - `lib/core/brand/brandprints.dart` in neptune-mobile - and the
// strings beside them are what the 2.27.0 codec, the one live on every
// installed handset, encodes them to.
//
// 2.28.0 grew the payload from 28 bytes to 29 (version byte 2) so
// `ruledRegister` could have a bit of its own rather than share one with
// `navShell`. That growth is only safe if a bank's brandprint does not move,
// so this file asserts it against real banks' strings rather than a synthetic
// one: byte-identical encoding, and a decode that gives every lever back.
//
// If a config below is edited to disagree with the app, this test fails and
// it SHOULD - the two files are one contract.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// Andalus: the confident, card-led bank. `motif: none` - the arch is retired.
const BrandprintConfig andalusBrandprint = BrandprintConfig(
  primary: Seed(l: 0.562, c: 0.209, h: 261),
  tertiary: Seed(l: 0.44, c: 0.16, h: 285),
  corners: Corners(xs: 10, sm: 14, md: 18, lg: 24, xl: 32, xxl: 44),
  displayWeight: 800,
  displayTracking: -0.02,
  fontDisplay: 'IBM Plex Sans Arabic',
  fontText: 'IBM Plex Sans Arabic',
  fontNum: 'IBM Plex Sans Arabic',
  loginShell: 'depth-emblem',
  dashboardHero: 'balance-cards',
  contentTone: 'clear-calm',
  glassTint: 'warm-amber',
  motion: 'smooth-fluid',
  motif: 'none',
);

/// Nuran: the quiet, documentary bank. Paper lockup, statement ledger, sonar
/// rings on the login shell only.
const BrandprintConfig nuranBrandprint = BrandprintConfig(
  primary: Seed(l: 0.34, c: 0.132, h: 255),
  tertiary: Seed(l: 0.48, c: 0.087, h: 242),
  corners: Corners(xs: 6, sm: 10, md: 12, lg: 16, xl: 20, xxl: 28),
  displayWeight: 600,
  displayTracking: 0.01,
  fontDisplay: 'IBM Plex Sans Arabic',
  fontText: 'IBM Plex Sans Arabic',
  fontNum: 'IBM Plex Sans Arabic',
  loginShell: 'paper-lockup',
  dashboardHero: 'statement-ledger',
  contentTone: 'formal-authoritative',
  glassTint: 'oceanic',
  motion: 'calm-graceful',
  motif: 'sonar-rings',
);

/// FGLB: navy structure, the arrow spent once per screen - which is why it is
/// the one production brand carrying `accentOnTertiary`, i.e. flags bit 2 set.
const BrandprintConfig fglbBrandprint = BrandprintConfig(
  primary: Seed(l: 0.358, c: 0.099, h: 262),
  tertiary: Seed(l: 0.551, c: 0.19, h: 27),
  accentOnTertiary: true,
  corners: Corners(xs: 8, sm: 12, md: 16, lg: 20, xl: 26, xxl: 36),
  displayWeight: 700,
  displayTracking: -0.03,
  fontDisplay: 'IBM Plex Sans Arabic',
  fontText: 'IBM Plex Sans Arabic',
  fontNum: 'IBM Plex Sans Arabic',
  loginShell: 'lockup-rule',
  dashboardHero: 'chevron-summary',
  contentTone: 'formal-authoritative',
  glassTint: 'navy-steel',
  motion: 'stable-minimal-authoritative',
  motif: 'none',
);

/// What the 2.27.0 codec encodes each production config to. Captured from a
/// worktree at tag `v2.27.0`, not from this tree - a value this tree produced
/// could not prove this tree did not shift it.
const Map<String, String> kIssuedBefore2280 = {
  'andalus': 'NO1-AY_RAQVwoAEdCg4SGCAsCOwEBAQAAAABAAAFKQ',
  'nuran': 'NO1-AVeEAP96VwDyBgoMEBQcBgoEBAQEBAMAAQABIw',
  'fglb': 'NO1-AVtjAQaNvgAbCAwQFBokB-IEBAQFBQMDAwQFsw',
};

const Map<String, BrandprintConfig> _production = {
  'andalus': andalusBrandprint,
  'nuran': nuranBrandprint,
  'fglb': fglbBrandprint,
};

List<int> _payload(String s) =>
    base64Url.decode(s.substring(4).padRight((s.length - 4 + 3) ~/ 4 * 4, '='));

void main() {
  group('the brandprints in production do not move', () {
    for (final entry in _production.entries) {
      final bank = entry.key;
      final cfg = entry.value;
      final issued = kIssuedBefore2280[bank]!;

      test('$bank: encodes to the identical string 2.27.0 issued', () {
        expect(Brandprint.encode(cfg), issued);
      });

      test('$bank: still 28 bytes, still version byte 1', () {
        final bytes = _payload(issued);
        expect(bytes.length, 28);
        expect(bytes.first, Brandprint.version);
        expect(Brandprint.encode(cfg).length, issued.length);
      });

      test('$bank: decodes to the config it always did, lever for lever', () {
        final d = Brandprint.decode(issued);
        expect(
          d,
          equals(BrandprintConfig(
            // Seeds are quantised on the wire (L to 1/255), so they come from
            // the decode; every enum and flag must come back exactly.
            primary: d.primary,
            tertiary: d.tertiary,
            corners: cfg.corners,
            displayWeight: cfg.displayWeight,
            displayTracking: cfg.displayTracking,
            fontDisplay: cfg.fontDisplay,
            fontText: cfg.fontText,
            fontNum: cfg.fontNum,
            loginShell: cfg.loginShell,
            dashboardHero: cfg.dashboardHero,
            contentTone: cfg.contentTone,
            glassTint: cfg.glassTint,
            motion: cfg.motion,
            motif: cfg.motif,
            defaultDark: cfg.defaultDark,
            defaultRtl: cfg.defaultRtl,
            accentOnTertiary: cfg.accentOnTertiary,
          )),
        );
      });

      test('$bank: the 2.28.0 levers all decode to their index-0 default', () {
        final d = Brandprint.decode(issued);
        expect(d.navShell, 'raised-dock');
        expect(d.actionRow, 'filled-circles');
        expect(d.ruledRegister, isFalse);
        expect(d.whiteGround, isFalse);
      });

      test('$bank: encode(decode(x)) == x', () {
        expect(Brandprint.encode(Brandprint.decode(issued)), issued);
      });
    }
  });

  group('the extension byte', () {
    test('a brand that declares the ruled register grows to 29 bytes', () {
      const ruled = BrandprintConfig(
        primary: Seed(l: 0.34, c: 0.132, h: 255),
        tertiary: Seed(l: 0.48, c: 0.087, h: 242),
        corners: Corners(xs: 6, sm: 10, md: 12, lg: 16, xl: 20, xxl: 28),
        displayWeight: 600,
        displayTracking: 0.01,
        fontDisplay: 'IBM Plex Sans Arabic',
        fontText: 'IBM Plex Sans Arabic',
        fontNum: 'IBM Plex Sans Arabic',
        loginShell: 'paper-lockup',
        dashboardHero: 'statement-ledger',
        contentTone: 'formal-authoritative',
        glassTint: 'oceanic',
        motion: 'calm-graceful',
        motif: 'sonar-rings',
        ruledRegister: true,
      );
      final s = Brandprint.encode(ruled);
      final bytes = _payload(s);
      expect(bytes.length, 29);
      expect(bytes.first, Brandprint.versionExtended);
      expect(bytes[27], 1, reason: 'byte 27 is the extension byte, bit 0 set');
      expect(s, isNot(kIssuedBefore2280['nuran']));
      expect(Brandprint.decode(s).ruledRegister, isTrue);
      expect(Brandprint.encode(Brandprint.decode(s)), s);
    });

    test('it does not disturb the flags byte the shells share', () {
      const both = BrandprintConfig(
        primary: Seed(l: 0.34, c: 0.132, h: 255),
        tertiary: Seed(l: 0.48, c: 0.087, h: 242),
        corners: Corners(xs: 6, sm: 10, md: 12, lg: 16, xl: 20, xxl: 28),
        displayWeight: 600,
        displayTracking: 0.01,
        fontDisplay: 'IBM Plex Sans Arabic',
        fontText: 'IBM Plex Sans Arabic',
        fontNum: 'IBM Plex Sans Arabic',
        loginShell: 'paper-lockup',
        dashboardHero: 'statement-ledger',
        contentTone: 'formal-authoritative',
        glassTint: 'oceanic',
        motion: 'calm-graceful',
        motif: 'sonar-rings',
        defaultRtl: true,
        whiteGround: true,
        navShell: 'rule-bar',
        actionRow: 'register-rows',
        ruledRegister: true,
      );
      final d = Brandprint.decode(Brandprint.encode(both));
      expect(d.navShell, 'rule-bar');
      expect(d.actionRow, 'register-rows');
      expect(d.whiteGround, isTrue);
      expect(d.defaultRtl, isTrue);
      expect(d.defaultDark, isFalse);
      expect(d.accentOnTertiary, isFalse);
      expect(d.ruledRegister, isTrue);
    });

    test('the version byte and the length must agree', () {
      // A 29-byte payload claiming version 1, or a 28-byte one claiming
      // version 2, is a truncated or padded string - never a real one. Both
      // are re-checksummed first, so it is the version check that rejects
      // them, not the checksum.
      String reissue(List<int> bytes) {
        var sum = 0;
        for (var i = 0; i < bytes.length - 1; i++) {
          sum = (sum + bytes[i]) & 255;
        }
        bytes[bytes.length - 1] = sum;
        return 'NO1-${base64Url.encode(bytes).replaceAll('=', '')}';
      }

      final short = _payload(kIssuedBefore2280['nuran']!).toList();
      short[0] = Brandprint.versionExtended;
      expect(() => Brandprint.decode(reissue(short)), throwsFormatException);

      final long = [...short.sublist(0, 27), 0, 0];
      long[0] = Brandprint.version;
      expect(() => Brandprint.decode(reissue(long)), throwsFormatException);
    });
  });
}
