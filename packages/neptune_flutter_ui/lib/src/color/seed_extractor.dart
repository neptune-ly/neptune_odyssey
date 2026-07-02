// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Dominant-colour extraction from a logo image — the Dart port of
// tools/client-demo/extract_colors.py's algorithm, so the desktop Studio app
// (and any other Dart consumer) can turn a client's logo into brand seeds
// without shelling out to Python. Takes raw decoded RGBA pixels (e.g. from
// `dart:ui`'s `Image.toByteData`); has no Flutter/IO dependency itself.

import 'oklch.dart';

/// Two dominant colours extracted from an image: the most-frequent saturated
/// colour ([primary]) and the most-frequent saturated colour sufficiently
/// distinct from it ([accent]).
class NptExtractedSeeds {
  final Oklch primary;
  final Oklch accent;
  final String primaryHex;
  final String accentHex;

  const NptExtractedSeeds({
    required this.primary,
    required this.accent,
    required this.primaryHex,
    required this.accentHex,
  });
}

double _saturation(int r, int g, int b) {
  final mx = [r, g, b].reduce((a, b) => a > b ? a : b);
  final mn = [r, g, b].reduce((a, b) => a < b ? a : b);
  return mx == 0 ? 0 : (mx - mn) / mx;
}

double _dist(List<int> a, List<int> b) {
  var sum = 0;
  for (var i = 0; i < 3; i++) {
    final d = a[i] - b[i];
    sum += d * d;
  }
  return sum.toDouble();
}

/// Extracts [NptExtractedSeeds] from raw RGBA8888 pixel bytes (the format
/// `dart:ui`'s `Image.toByteData(format: ImageByteFormat.rawRgba)` returns).
/// [width]/[height] describe the image; [sampleStep] skips pixels for speed
/// on large images (4 = every 4th pixel in each axis).
NptExtractedSeeds extractSeedsFromRgba(
  List<int> rgba,
  int width,
  int height, {
  int sampleStep = 4,
}) {
  final buckets = <int, int>{}; // packed (r<<16|g<<8|b) bucket -> count
  final bucketRgb = <int, List<int>>{};

  for (var y = 0; y < height; y += sampleStep) {
    for (var x = 0; x < width; x += sampleStep) {
      final i = (y * width + x) * 4;
      if (i + 3 >= rgba.length) continue;
      final r = rgba[i], g = rgba[i + 1], b = rgba[i + 2], a = rgba[i + 3];
      if (a < 128) continue;
      final mx = [r, g, b].reduce((a, b) => a > b ? a : b);
      final mn = [r, g, b].reduce((a, b) => a < b ? a : b);
      final sat = mx == 0 ? 0.0 : (mx - mn) / mx;
      if (sat < 0.18) continue;
      if (mx > 250 && mn > 235) continue; // near-white
      final br = (r ~/ 8) * 8, bg = (g ~/ 8) * 8, bb = (b ~/ 8) * 8;
      final key = (br << 16) | (bg << 8) | bb;
      buckets[key] = (buckets[key] ?? 0) + 1;
      bucketRgb[key] = [br, bg, bb];
    }
  }

  if (buckets.isEmpty) {
    // Fallback: a neutral navy/teal pair so the caller always gets a result.
    return NptExtractedSeeds(
      primary: hexToOklch('#1D5AB0'),
      accent: hexToOklch('#008388'),
      primaryHex: '#1D5AB0',
      accentHex: '#008388',
    );
  }

  final sorted = buckets.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final primaryRgb = bucketRgb[sorted.first.key]!;
  var accentRgb = primaryRgb;
  for (final e in sorted.skip(1)) {
    final rgb = bucketRgb[e.key]!;
    if (_dist(rgb, primaryRgb) > 3600 && // ~60px euclidean, matches the .py
        _saturation(rgb[0], rgb[1], rgb[2]) > 0.25) {
      accentRgb = rgb;
      break;
    }
  }

  String hexOf(List<int> rgb) =>
      '#${rgb.map((c) => c.toRadixString(16).padLeft(2, '0')).join()}'
          .toUpperCase();

  final primaryHex = hexOf(primaryRgb);
  final accentHex = hexOf(accentRgb);
  return NptExtractedSeeds(
    primary: hexToOklch(primaryHex),
    accent: hexToOklch(accentHex),
    primaryHex: primaryHex,
    accentHex: accentHex,
  );
}
