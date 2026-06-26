// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// OKLCH -> sRGB converter (Dart port of color/oklch.ts). The SAME math ships on
// every platform so custom seeds resolve identically. CSS Color 4 reference path:
// OKLab -> LMS -> XYZ(D65) -> linear sRGB -> gamma-encoded sRGB.

import 'dart:math' as math;

/// An OKLCH colour: perceptual lightness 0..1, chroma ~0..0.4, hue degrees 0..360.
class Oklch {
  final double l;
  final double c;
  final double h;
  const Oklch(this.l, this.c, this.h);
}

const List<List<double>> _oklabToLms = [
  [1, 0.3963377773761749, 0.2158037573099136],
  [1, -0.1055613458156586, -0.0638541728258133],
  [1, -0.0894841775298119, -1.2914855480194092],
];

const List<List<double>> _lmsToXyz = [
  [1.2268798733741557, -0.5578149965554813, 0.2813910501772159],
  [-0.0405757452148008, 1.1122868293970594, -0.0717110580655164],
  [-0.0763729366746601, -0.4214933324022432, 1.5869240198367816],
];

const List<List<double>> _xyzToLinSrgb = [
  [3.2409699419045226, -1.537383177570094, -0.4986107602930034],
  [-0.9692436362808796, 1.8759675015077202, 0.04155505740717559],
  [0.05563007969699366, -0.20397695888897652, 1.0569715142428786],
];

List<double> _mul(List<List<double>> m, List<double> v) => [
      m[0][0] * v[0] + m[0][1] * v[1] + m[0][2] * v[2],
      m[1][0] * v[0] + m[1][1] * v[1] + m[1][2] * v[2],
      m[2][0] * v[0] + m[2][1] * v[1] + m[2][2] * v[2],
    ];

double _clamp01(double x) => x < 0 ? 0 : (x > 1 ? 1 : x);

/// Linear-light sRGB channel -> gamma-encoded sRGB (0..1).
double _encodeSrgb(double x) {
  final c = _clamp01(x);
  return c <= 0.0031308 ? 12.92 * c : 1.055 * math.pow(c, 1 / 2.4) - 0.055;
}

/// OKLCH -> linear-light sRGB (unclamped).
List<double> oklchToLinearSrgb(Oklch o) {
  final hr = o.h * math.pi / 180;
  final lab = [o.l, o.c * math.cos(hr), o.c * math.sin(hr)];
  final lms_ = _mul(_oklabToLms, lab);
  final lms = [lms_[0] * lms_[0] * lms_[0], lms_[1] * lms_[1] * lms_[1], lms_[2] * lms_[2] * lms_[2]];
  final xyz = _mul(_lmsToXyz, lms);
  return _mul(_xyzToLinSrgb, xyz);
}

/// True if the OKLCH colour is inside the sRGB gamut (no channel clamped).
bool inSrgbGamut(Oklch c) {
  final rgb = oklchToLinearSrgb(c);
  const lo = -1e-4;
  const hi = 1 + 1e-4;
  return rgb[0] >= lo &&
      rgb[0] <= hi &&
      rgb[1] >= lo &&
      rgb[1] <= hi &&
      rgb[2] >= lo &&
      rgb[2] <= hi;
}

/// OKLCH -> sRGB 0..255 integer channels (per-channel clamp). Returns [r, g, b].
List<int> oklchToRgb255(Oklch c) {
  final lin = oklchToLinearSrgb(c);
  return [
    (_encodeSrgb(lin[0]) * 255).round(),
    (_encodeSrgb(lin[1]) * 255).round(),
    (_encodeSrgb(lin[2]) * 255).round(),
  ];
}

String _hex2(int n) => n.toRadixString(16).padLeft(2, '0');

/// OKLCH -> "#rrggbb" lowercase.
String oklchToHex(Oklch c) {
  final rgb = oklchToRgb255(c);
  return '#${_hex2(rgb[0])}${_hex2(rgb[1])}${_hex2(rgb[2])}';
}

/// OKLCH -> 0xAARRGGBB 32-bit ARGB int (alpha = 0xFF). Feed straight to Color().
int oklchToArgb(Oklch c) {
  final rgb = oklchToRgb255(c);
  return 0xFF000000 | (rgb[0] << 16) | (rgb[1] << 8) | rgb[2];
}
