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
    defaultDark: c['defaultDark'] as bool,
    defaultRtl: c['defaultRtl'] as bool,
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
    }
  });

  group('brandprint error handling', () {
    final valid = brands['andalus']['brandprint'] as String;

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
