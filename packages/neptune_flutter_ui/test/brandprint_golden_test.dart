// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

BrandprintConfig _configFromJson(Map<String, dynamic> c) {
  Seed seed(Map<String, dynamic> m) =>
      Seed(l: (m['L'] as num).toDouble(), c: (m['C'] as num).toDouble(), h: (m['H'] as num).toInt());
  final corners = c['corners'] as Map<String, dynamic>;
  final fonts = c['fonts'] as Map<String, dynamic>;
  return BrandprintConfig(
    primary: seed(c['primary'] as Map<String, dynamic>),
    tertiary: seed(c['tertiary'] as Map<String, dynamic>),
    corners: Corners(
      xs: corners['xs'] as int,
      sm: corners['sm'] as int,
      md: corners['md'] as int,
      lg: corners['lg'] as int,
      xl: corners['xl'] as int,
      xxl: corners['xxl'] as int,
    ),
    displayWeight: c['displayWeight'] as int,
    displayTracking: (c['displayTracking'] as num).toDouble(),
    fontDisplay: fonts['display'] as String,
    fontText: fonts['text'] as String,
    fontNum: fonts['num'] as String,
    loginShell: c['loginShell'] as String,
    dashboardHero: c['dashboardHero'] as String,
    contentTone: c['contentTone'] as String,
    glassTint: c['glassTint'] as String,
    motion: c['motion'] as String,
    // Absent on the four reference entries: they predate the lever and must
    // keep encoding byte 26 as 0.
    motif: c['motif'] as String? ?? 'auto',
    defaultDark: c['defaultDark'] as bool,
    defaultRtl: c['defaultRtl'] as bool,
    // Likewise absent on every entry but custom-accent: flags bit 2 stays
    // clear for the four references.
    accentOnTertiary: c['accentOnTertiary'] as bool? ?? false,
  );
}

Map<String, dynamic> _loadGolden() {
  // Prefer the bundled fixture; fall back to the repo build artifact.
  final candidates = [
    File('test/fixtures/brandprints.golden.json'),
    File('../../build/brandprints.golden.json'),
  ];
  for (final f in candidates) {
    if (f.existsSync()) {
      return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    }
  }
  throw StateError('brandprints.golden.json not found');
}

void main() {
  final golden = _loadGolden();
  final brands = golden['brands'] as Map<String, dynamic>;

  group('brandprint golden', () {
    for (final entry in brands.entries) {
      final brand = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final goldenString = data['brandprint'] as String;
      final cfg = _configFromJson(data['config'] as Map<String, dynamic>);

      test('$brand: encode(config) == golden string', () {
        expect(Brandprint.encode(cfg), goldenString);
      });

      test('$brand: decode(golden) re-encodes to golden (idempotent)', () {
        final decoded = Brandprint.decode(goldenString);
        expect(Brandprint.encode(decoded), goldenString);
      });

      test('$brand: encode(decode(x)) == x', () {
        expect(
          Brandprint.encode(Brandprint.decode(goldenString)),
          goldenString,
        );
      });

      test('$brand: the motif lever survives the wire', () {
        expect(Brandprint.decode(goldenString).motif, cfg.motif);
      });

      test('$brand: decode(golden) == config, every lever and flag', () {
        // The whole config, not one field: a registry appended in the wrong
        // place or a flag bit read at the wrong shift would decode to a
        // plausible-looking neighbour and pass a per-field check. Seeds are
        // quantised on the wire (L to 1/255), so they are taken from the
        // decode; everything else must come back exactly as written.
        final d = Brandprint.decode(goldenString);
        expect(
          d,
          equals(BrandprintConfig(
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
    }

    test('2.24.0 registry appends and flags bit 2: references clear, custom-accent set', () {
      for (final ref in kBrands) {
        final d = Brandprint.decode(brands[ref]['brandprint'] as String);
        expect(d.accentOnTertiary, isFalse, reason: ref);
      }
      expect(brands, contains('custom-accent'));
      final d = Brandprint.decode(brands['custom-accent']['brandprint'] as String);
      expect(d.loginShell, 'lockup-rule');
      expect(d.dashboardHero, 'chevron-summary');
      expect(d.accentOnTertiary, isTrue);
      expect(d.defaultRtl, isTrue,
          reason: 'bit 2 must not clobber bits 0-1 on the same byte');
      expect(d.defaultDark, isFalse);
      // The other appended names round-trip too, at their own indices.
      expect(kLoginShells.indexOf('paper-lockup'), 4);
      expect(kDashboardHeroes.indexOf('statement-ledger'), 4);
    });

    test('byte 26: the four references stay at 0 (auto), custom-none carries none', () {
      // The reserved byte was claimed for the motif in 2.24.0. Every string in
      // the wild carries 0 there, so the reference goldens above are unchanged
      // and decode to `auto`; only the synthetic entry sets it.
      for (final ref in kBrands) {
        final s = brands[ref]['brandprint'] as String;
        expect(Brandprint.decode(s).motif, 'auto', reason: ref);
      }
      expect(brands, contains('custom-none'),
          reason: 'the fixture must carry the synthetic entry that proves the lever');
      expect(Brandprint.decode(brands['custom-none']['brandprint'] as String).motif, 'none');
    });

    test('an unregistered motif name encodes as auto, like every other registry', () {
      final cfg = _configFromJson(brands['triton']['config'] as Map<String, dynamic>);
      final odd = BrandprintConfig(
        primary: cfg.primary,
        tertiary: cfg.tertiary,
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
        motif: 'facet-lattice',
      );
      expect(Brandprint.encode(odd), brands['triton']['brandprint']);
      expect(Brandprint.decode(Brandprint.encode(odd)).motif, 'auto');
    });
  });

  group('brandprint error handling', () {
    final valid = brands['triton']['brandprint'] as String;

    test('throws on bad prefix', () {
      expect(() => Brandprint.decode('XX1-${valid.substring(4)}'),
          throwsFormatException);
    });

    test('throws on checksum mismatch', () {
      // Flip a payload character (not the prefix) to corrupt the checksum.
      final body = valid.substring(4);
      final mutated = (body[0] == 'A' ? 'B' : 'A') + body.substring(1);
      expect(() => Brandprint.decode('NO1-$mutated'), throwsFormatException);
    });

    test('throws on bad length', () {
      // 'NO1-' + base64url of a 4-byte payload -> wrong length.
      final short = base64Url.encode([1, 2, 3, 4]).replaceAll('=', '');
      expect(() => Brandprint.decode('NO1-$short'), throwsFormatException);
    });
  });
}
