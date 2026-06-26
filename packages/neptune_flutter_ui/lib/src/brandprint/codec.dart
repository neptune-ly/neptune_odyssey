// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Brandprint codec (Dart port). Faithful, byte-identical port of the TypeScript
// reference (packages/neptune_tokens/src/brandprint/codec.ts). 28-byte fixed
// layout -> base64url, version "NO1-", checksummed. Golden-tested against the
// four reference brands. See docs/11-config-hash.md for the wire format.

import 'dart:convert';
import 'dart:typed_data';

/// Append-only font registry. Indices ARE the wire format — never reorder.
const List<String> kFonts = [
  'Hanken Grotesk',
  'Bricolage Grotesque',
  'Space Grotesk',
  'Sora',
  'IBM Plex Sans Arabic',
  'Reem Kufi',
  'Tajawal',
  'Readex Pro',
  'Noto Kufi Arabic',
];

/// Append-only login-shell registry.
const List<String> kLoginShells = [
  'depth-emblem',
  'arcade-arches',
  'light-grid-spark',
  'shield-guilloche',
];

/// Append-only dashboard-hero registry.
const List<String> kDashboardHeroes = [
  'balance-cards',
  'warm-balance-cards',
  'wallet-hero',
  'restrained-balance',
];

/// Append-only content-tone registry.
const List<String> kContentTones = [
  'clear-calm',
  'warm-hospitable',
  'light-instant',
  'formal-authoritative',
];

/// Append-only glass-tint registry.
const List<String> kGlassTints = [
  'oceanic',
  'warm-amber',
  'violet-luminous',
  'navy-steel',
];

/// Append-only motion registry.
const List<String> kMotions = [
  'smooth-fluid',
  'calm-graceful',
  'light-quick-crisp',
  'stable-minimal-authoritative',
];

/// An OKLCH seed colour (perceptual lightness, chroma, hue degrees).
class Seed {
  final double l;
  final double c;
  final int h;
  const Seed({required this.l, required this.c, required this.h});

  @override
  bool operator ==(Object other) =>
      other is Seed && other.l == l && other.c == c && other.h == h;
  @override
  int get hashCode => Object.hash(l, c, h);
}

/// The six corner radii (px), xs..xxl.
class Corners {
  final int xs, sm, md, lg, xl, xxl;
  const Corners({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  @override
  bool operator ==(Object other) =>
      other is Corners &&
      other.xs == xs &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.xl == xl &&
      other.xxl == xxl;
  @override
  int get hashCode => Object.hash(xs, sm, md, lg, xl, xxl);
}

/// A complete brandprint input config — the inputs a theme is generated from.
/// Mirrors `BrandprintConfig` in codec.ts field-for-field.
class BrandprintConfig {
  final int version;
  final Seed primary;
  final Seed tertiary;
  final Corners corners;
  final int displayWeight;

  /// Tracking in em, e.g. -0.02.
  final double displayTracking;
  final String fontDisplay;
  final String fontText;
  final String fontNum;
  final String loginShell;
  final String dashboardHero;
  final String contentTone;
  final String glassTint;
  final String motion;
  final bool defaultDark;
  final bool defaultRtl;

  const BrandprintConfig({
    this.version = 1,
    required this.primary,
    required this.tertiary,
    required this.corners,
    required this.displayWeight,
    required this.displayTracking,
    required this.fontDisplay,
    required this.fontText,
    required this.fontNum,
    required this.loginShell,
    required this.dashboardHero,
    required this.contentTone,
    required this.glassTint,
    required this.motion,
    this.defaultDark = false,
    this.defaultRtl = false,
  });

  @override
  bool operator ==(Object other) =>
      other is BrandprintConfig &&
      other.version == version &&
      other.primary == primary &&
      other.tertiary == tertiary &&
      other.corners == corners &&
      other.displayWeight == displayWeight &&
      other.displayTracking == displayTracking &&
      other.fontDisplay == fontDisplay &&
      other.fontText == fontText &&
      other.fontNum == fontNum &&
      other.loginShell == loginShell &&
      other.dashboardHero == dashboardHero &&
      other.contentTone == contentTone &&
      other.glassTint == glassTint &&
      other.motion == motion &&
      other.defaultDark == defaultDark &&
      other.defaultRtl == defaultRtl;

  @override
  int get hashCode => Object.hashAll([
        version,
        primary,
        tertiary,
        corners,
        displayWeight,
        displayTracking,
        fontDisplay,
        fontText,
        fontNum,
        loginShell,
        dashboardHero,
        contentTone,
        glassTint,
        motion,
        defaultDark,
        defaultRtl,
      ]);
}

/// Encode/decode the portable `NO1-…` brandprint string.
class Brandprint {
  Brandprint._();

  static const int version = 1;
  static const String _prefix = 'NO1-';
  static const int _payloadBytes = 28;

  static int _ix(List<String> arr, String v) {
    final i = arr.indexOf(v);
    return i < 0 ? 0 : i;
  }

  static String _toBase64Url(Uint8List bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  static Uint8List _fromBase64Url(String s) {
    var t = s;
    while (t.length % 4 != 0) {
      t += '=';
    }
    return base64Url.decode(t);
  }

  /// Encode a config to its `NO1-…` brandprint string.
  static String encode(BrandprintConfig cfg) {
    final buf = Uint8List(_payloadBytes);
    final dv = ByteData.view(buf.buffer);
    var o = 0;
    buf[o++] = version;
    buf[o++] = (cfg.primary.l * 255).round();
    buf[o++] = (cfg.primary.c * 1000).round().clamp(0, 255);
    dv.setUint16(o, cfg.primary.h, Endian.big);
    o += 2;
    buf[o++] = (cfg.tertiary.l * 255).round();
    buf[o++] = (cfg.tertiary.c * 1000).round().clamp(0, 255);
    dv.setUint16(o, cfg.tertiary.h, Endian.big);
    o += 2;
    final c = cfg.corners;
    for (final v in [c.xs, c.sm, c.md, c.lg, c.xl, c.xxl]) {
      buf[o++] = v.clamp(0, 255);
    }
    buf[o++] = (cfg.displayWeight / 100).round();
    dv.setInt8(o, (cfg.displayTracking * 1000).round());
    o += 1;
    buf[o++] = _ix(kFonts, cfg.fontDisplay);
    buf[o++] = _ix(kFonts, cfg.fontText);
    buf[o++] = _ix(kFonts, cfg.fontNum);
    buf[o++] = _ix(kLoginShells, cfg.loginShell);
    buf[o++] = _ix(kDashboardHeroes, cfg.dashboardHero);
    buf[o++] = _ix(kContentTones, cfg.contentTone);
    buf[o++] = _ix(kGlassTints, cfg.glassTint);
    buf[o++] = _ix(kMotions, cfg.motion);
    var f = 0;
    if (cfg.defaultDark) f |= 1;
    if (cfg.defaultRtl) f |= 2;
    buf[o++] = f;
    buf[o++] = 0; // reserved
    var sum = 0;
    for (var i = 0; i < o; i++) {
      sum = (sum + buf[i]) & 255;
    }
    buf[o++] = sum; // checksum
    return _prefix + _toBase64Url(buf);
  }

  /// Decode a `NO1-…` brandprint string.
  /// Throws [FormatException] on bad prefix/length/checksum/version.
  static BrandprintConfig decode(String str) {
    if (!str.startsWith(_prefix)) {
      throw const FormatException('bad prefix');
    }
    final buf = _fromBase64Url(str.substring(4));
    if (buf.length != _payloadBytes) {
      throw const FormatException('bad length');
    }
    final dv = ByteData.view(buf.buffer, buf.offsetInBytes, buf.lengthInBytes);
    var sum = 0;
    for (var i = 0; i < 27; i++) {
      sum = (sum + buf[i]) & 255;
    }
    if (sum != buf[27]) {
      throw const FormatException('checksum mismatch');
    }
    var o = 0;
    final ver = buf[o++];
    if (ver != version) {
      throw FormatException('version $ver unsupported');
    }
    final primary = Seed(
      l: buf[o++] / 255,
      c: buf[o++] / 1000,
      h: dv.getUint16((o += 2) - 2, Endian.big),
    );
    final tertiary = Seed(
      l: buf[o++] / 255,
      c: buf[o++] / 1000,
      h: dv.getUint16((o += 2) - 2, Endian.big),
    );
    final corners = Corners(
      xs: buf[o++],
      sm: buf[o++],
      md: buf[o++],
      lg: buf[o++],
      xl: buf[o++],
      xxl: buf[o++],
    );
    final displayWeight = buf[o++] * 100;
    final displayTracking = dv.getInt8(o) / 1000;
    o += 1;
    final fontDisplay = kFonts[buf[o++]];
    final fontText = kFonts[buf[o++]];
    final fontNum = kFonts[buf[o++]];
    final loginShell = kLoginShells[buf[o++]];
    final dashboardHero = kDashboardHeroes[buf[o++]];
    final contentTone = kContentTones[buf[o++]];
    final glassTint = kGlassTints[buf[o++]];
    final motion = kMotions[buf[o++]];
    final f = buf[o++];
    return BrandprintConfig(
      version: ver,
      primary: primary,
      tertiary: tertiary,
      corners: corners,
      displayWeight: displayWeight,
      displayTracking: displayTracking,
      fontDisplay: fontDisplay,
      fontText: fontText,
      fontNum: fontNum,
      loginShell: loginShell,
      dashboardHero: dashboardHero,
      contentTone: contentTone,
      glassTint: glassTint,
      motion: motion,
      defaultDark: (f & 1) != 0,
      defaultRtl: (f & 2) != 0,
    );
  }
}
