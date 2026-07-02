// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// sRGB<->OKLCH is bidirectional and exact (needed for R5's colour extraction
// — a client logo's hex must round-trip through OKLCH to seed a brandprint),
// and the dominant-colour extractor finds sane seeds from raw pixels.

import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  group('hexToOklch / oklchToHex round-trip', () {
    const cases = [
      Oklch(0.48, 0.15, 258),
      Oklch(0.411, 0.099, 270),
      Oklch(0.63, 0.212, 28),
      Oklch(0.985, 0.006, 258), // near-white — edge case
      Oklch(0.16, 0.02, 258), // near-black — edge case
    ];
    for (final c in cases) {
      test('${c.l},${c.c},${c.h}', () {
        final hex = oklchToHex(c);
        final back = hexToOklch(hex);
        expect(oklchToHex(back), hex);
      });
    }

    test('reproduces known brand seeds from their hex', () {
      final navy = hexToOklch('#364680');
      expect(navy.l, closeTo(0.411, 0.01));
      expect(navy.c, closeTo(0.099, 0.01));
      expect(navy.h, closeTo(270, 2));

      final red = hexToOklch('#EE4037');
      expect(red.l, closeTo(0.63, 0.01));
      expect(red.c, closeTo(0.212, 0.01));
      expect(red.h, closeTo(28, 2));
    });
  });

  group('extractSeedsFromRgba', () {
    List<int> solidRgba(int w, int h, int r, int g, int b) =>
        List.generate(w * h * 4, (i) {
          switch (i % 4) {
            case 0:
              return r;
            case 1:
              return g;
            case 2:
              return b;
            default:
              return 255;
          }
        });

    // Colours are bucketed to the nearest 8 per channel (matching the Python
    // extractor exactly), so e.g. 0x36 -> 0x30. Assert on the bucketed value.
    test('finds the dominant saturated colour in a solid image', () {
      final rgba = solidRgba(40, 40, 0x36, 0x46, 0x80); // FGLB navy
      final seeds = extractSeedsFromRgba(rgba, 40, 40, sampleStep: 1);
      expect(seeds.primaryHex, '#304080');
    });

    test('finds two distinct colours in a split image', () {
      const w = 40, h = 40;
      final rgba = List<int>.filled(w * h * 4, 0);
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          final i = (y * w + x) * 4;
          final left = x < w ~/ 2;
          rgba[i] = left ? 0x36 : 0xEE;
          rgba[i + 1] = left ? 0x46 : 0x40;
          rgba[i + 2] = left ? 0x80 : 0x37;
          rgba[i + 3] = 255;
        }
      }
      final seeds = extractSeedsFromRgba(rgba, w, h, sampleStep: 1);
      expect({seeds.primaryHex, seeds.accentHex}, {'#304080', '#E84030'});
    });

    test('falls back sanely on an all-white (unsaturated) image', () {
      final rgba = solidRgba(20, 20, 255, 255, 255);
      final seeds = extractSeedsFromRgba(rgba, 20, 20, sampleStep: 1);
      // Fallback pair must still be valid, round-trippable colours.
      expect(seeds.primaryHex, isNotEmpty);
      expect(hexToOklch(seeds.primaryHex).l, greaterThan(0));
    });
  });
}
