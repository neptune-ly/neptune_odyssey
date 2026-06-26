// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

int _argbToInt(String s) => int.parse(s.substring(2), radix: 16);

List<dynamic> _loadRoles() {
  final f = File('test/fixtures/oklch_roles.json');
  return jsonDecode(f.readAsStringSync()) as List<dynamic>;
}

void main() {
  group('pinned ColorSchemes match tokens.resolved.json exactly', () {
    // A few key roles per brand × mode, asserted byte-exact against resolved.json.
    final cases = <String, ({int light, int dark})>{
      // primary
      'neptune': (light: 0xFF1D5AB0, dark: 0xFF8DC0FF),
      'andalus': (light: 0xFF00774E, dark: 0xFF7DDBAE),
      'nuran': (light: 0xFF6F4CC6, dark: 0xFFC0AAFF),
      'fglb': (light: 0xFF004F8F, dark: 0xFF7DBDFB),
    };
    cases.forEach((brand, primaries) {
      test('$brand primary (light+dark)', () {
        final schemes = neptuneSchemes[brand]!;
        expect(schemes.$1.primary.toARGB32(), primaries.light);
        expect(schemes.$2.primary.toARGB32(), primaries.dark);
      });
    });

    test('andalus tertiary + success roles', () {
      expect(andalusLight.tertiary.toARGB32(), 0xFFA68018);
      expect(andalusDark.tertiary.toARGB32(), 0xFFE1C076);
      expect(brandSuccess['andalus']!.$1.success.toARGB32(), 0xFF2D8949);
      expect(brandSuccess['andalus']!.$2.success.toARGB32(), 0xFF7CCD8E);
    });

    test('every brand has matching surface + error roles', () {
      // light surface / error are stable references in resolved.json.
      expect(neptuneLight.surface.toARGB32(), 0xFFF8FAFE);
      expect(nuranLight.error.toARGB32(), 0xFFC2181D);
      expect(fglbDark.surface.toARGB32(), 0xFF03060A);
    });
  });

  group('OKLCH converter reproduces resolved.json', () {
    final roles = _loadRoles();

    test('every role within <= 1 LSB per channel', () {
      var worst = 0;
      for (final r in roles) {
        final m = r as Map<String, dynamic>;
        final argb = oklchToArgb(Oklch(
          (m['L'] as num).toDouble(),
          (m['C'] as num).toDouble(),
          (m['H'] as num).toDouble(),
        ));
        final exp = _argbToInt(m['argb'] as String);
        for (var shift = 0; shift <= 16; shift += 8) {
          final d = ((argb >> shift) & 0xFF) - ((exp >> shift) & 0xFF);
          worst = d.abs() > worst ? d.abs() : worst;
        }
      }
      expect(worst, lessThanOrEqualTo(1),
          reason: 'worst per-channel delta was $worst LSB');
    });

    test('>= 90% of roles reproduce exactly', () {
      var exact = 0;
      for (final r in roles) {
        final m = r as Map<String, dynamic>;
        final argb = oklchToArgb(Oklch(
          (m['L'] as num).toDouble(),
          (m['C'] as num).toDouble(),
          (m['H'] as num).toDouble(),
        ));
        if (argb == _argbToInt(m['argb'] as String)) exact++;
      }
      final pct = 100 * exact / roles.length;
      expect(pct, greaterThanOrEqualTo(90.0),
          reason: 'only $exact/${roles.length} (${pct.toStringAsFixed(1)}%) exact');
    });
  });

  group('oklchToHex / oklchToRgb255', () {
    test('neptune light primary hex', () {
      expect(oklchToHex(const Oklch(0.48, 0.15, 258)), '#1d5ab0');
    });
    test('rgb255 channels', () {
      expect(oklchToRgb255(const Oklch(0.48, 0.15, 258)), [0x1d, 0x5a, 0xb0]);
    });
  });
}
