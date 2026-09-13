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

/// Append-only login-shell registry. The last two (2.24.0) are the shells a
/// bank picks when the pre-login moment is the lockup on a plain ground:
/// `paper-lockup` (light surface, the lockup centred and small, no watermark,
/// no motif) and `lockup-rule` (white ground, the lockup, one hairline rule
/// under it echoing the wordmark's baseline).
const List<String> kLoginShells = [
  'depth-emblem',
  'arcade-arches',
  'light-grid-spark',
  'shield-guilloche',
  'paper-lockup',
  'lockup-rule',
  // 2.29.0. The lockup on a luminous depth field rather than on a plane:
  // the brand gradient travelling under a bloom, framed by one arc. For a
  // bank whose identity is light arriving, which neither a flat canvas nor
  // paper can state.
  'tide-depth',
];

/// Append-only dashboard-hero registry. The last two (2.24.0):
/// `statement-ledger` (one tabular balance statement, then compact account
/// rows - no carousel) and `chevron-summary` (the total across the top, each
/// account row carrying a movement chevron in the brand's accent).
const List<String> kDashboardHeroes = [
  'balance-cards',
  'warm-balance-cards',
  'wallet-hero',
  'restrained-balance',
  'statement-ledger',
  'chevron-summary',
  // 2.29.0. A carousel again, but in the depth register: cards that travel
  // from a deep tone to a bright one with the brand's own wave planes struck
  // across them, sized so the next card peeks in at the reading edge. The
  // peek is the lever's point - `balance-cards` fills the viewport, so a
  // customer with four accounts has to be TOLD there are four.
  'tide-carousel',
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

/// Append-only motif registry - byte 26, which was reserved (always `0`)
/// until 2.24.0. Index 0 is `auto`: derive the motif from `glassTint` exactly
/// as before the byte was claimed, so every brandprint already in the wild
/// decodes to the identical theme. The named entries decouple the motif from
/// the glass recipe; `none` is a brand with no pattern at all.
const List<String> kMotifs = [
  'auto',
  'sonar-rings',
  'coastal-arcs',
  'grid-spark',
  'guilloche',
  'none',
];

/// Append-only navigation-shell registry - flags bits 4-5 (2.28.0). The bar a
/// bank's signed-in app stands on, which until now every bank inherited from
/// Andalus:
///
/// * `raised-dock` - the floating glass pill, the active item lifted into a
///   filled circle. Index 0, so every brandprint already in the wild decodes
///   to exactly the dock it has today.
/// * `register-bar` - a flat, full-width bar on one `outlineVariant`
///   hairline. No pill, no float, no fill: the active item is marked by
///   weight and the brand colour, nothing else.
/// * `rule-bar` - a full-width bar under a rule, the active item marked by a
///   segment of that rule in the brand's accent. Structure drawn in lines.
///
/// FOUR ENTRIES MAX: this registry is two bits on the wire (the 28-byte
/// layout has no spare byte left), so a fifth shell needs a format bump, not
/// another list entry.
const List<String> kNavShells = [
  'raised-dock',
  'register-bar',
  'rule-bar',
  // 2.29.0, AND THE LAST ENTRY THIS REGISTRY CAN TAKE - two bits, four values,
  // full. A fifth navigation shell needs a format bump, not another line here.
  //
  // `centre-dock` is the raised pill with a hole in the middle of it: the
  // bank's primary verb has left the quick-action row at the top of the page
  // and become a circle in the bar, reachable with one thumb from any tab.
  // The dock still does not own that button (see [NeptuneDock.centerGap]) -
  // it reserves the space and the host stacks its own action over it, because
  // which verb is primary is the host's decision and the route behind it is
  // the host's too.
  'centre-dock',
];

/// Append-only quick-action-row registry - flags bits 6-7 (2.28.0). The
/// treatment behind a home quick action:
///
/// * `filled-circles` - the tonal `secondaryContainer` circle behind every
///   glyph. Index 0: what every existing brandprint already draws.
/// * `register-rows` - no chip at all. One strip ruled top and bottom, the
///   actions divided by hairlines, like a column header in a ledger.
/// * `rule-grid` - each action in its own hairline cell, and the FIRST action
///   - the one that moves the customer forward - carries the brand accent.
///
/// FOUR ENTRIES MAX, for the same reason as [kNavShells].
const List<String> kActionRows = [
  'filled-circles',
  'register-rows',
  'rule-grid',
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

  /// One of [kMotifs]. `auto` (the default, and what every pre-2.24.0 string
  /// decodes to) keeps the motif keyed on [glassTint].
  final String motif;
  final bool defaultDark;
  final bool defaultRtl;

  /// Flags bit 2 (2.24.0). When true the [tertiary] seed is the brand's
  /// ACCENT - spent on direction and confirmation only (`NptColors.accent`:
  /// the forward CTA, the active step, an upward movement) - and it feeds no
  /// Material role: the `tertiary*` roles and the card gradient are generated
  /// from [primary] instead, so the accent cannot leak into chrome. False,
  /// which every pre-2.24.0 string decodes to, keeps tertiary as a second
  /// chrome colour and makes the accent equal to primary.
  final bool accentOnTertiary;

  /// Flags bit 3 (2.25.0). The WHITE, STRUCTURAL register: the page ground
  /// and the app bar are `surfaceContainerLowest` (pure white in a light
  /// scheme) instead of `surface` (the tinted tone 98), and a text field is
  /// white inside its ring instead of filled with `surfaceContainerHighest`,
  /// so structure is drawn in lines rather than in grey slabs. Dark mode is
  /// untouched - there is no white to be. False, which every pre-2.25.0
  /// string decodes to, keeps the tinted ground and the filled fields.
  final bool whiteGround;

  /// One of [kNavShells], flags bits 4-5 (2.28.0). The signed-in bar. Index 0
  /// (`raised-dock`) is what every pre-2.28.0 string decodes to.
  final String navShell;

  /// One of [kActionRows], flags bits 6-7 (2.28.0). The home quick-action
  /// treatment. Index 0 (`filled-circles`) is what every pre-2.28.0 string
  /// decodes to.
  final String actionRow;

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
    this.motif = 'auto',
    this.defaultDark = false,
    this.defaultRtl = false,
    this.accentOnTertiary = false,
    this.whiteGround = false,
    this.navShell = 'raised-dock',
    this.actionRow = 'filled-circles',
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
      other.motif == motif &&
      other.defaultDark == defaultDark &&
      other.defaultRtl == defaultRtl &&
      other.accentOnTertiary == accentOnTertiary &&
      other.whiteGround == whiteGround &&
      other.navShell == navShell &&
      other.actionRow == actionRow;

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
        motif,
        defaultDark,
        defaultRtl,
        accentOnTertiary,
        whiteGround,
        navShell,
        actionRow,
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
    if (cfg.accentOnTertiary) f |= 4;
    if (cfg.whiteGround) f |= 8;
    // The high nibble carries the two composition shells, two bits each. The
    // 28-byte layout is full, and both registries default to index 0, so
    // every brandprint issued before 2.28.0 encodes and decodes unchanged.
    f |= (_ix(kNavShells, cfg.navShell) & 3) << 4;
    f |= (_ix(kActionRows, cfg.actionRow) & 3) << 6;
    buf[o++] = f;
    buf[o++] = _ix(kMotifs, cfg.motif);
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
    final motif = kMotifs[buf[o++]];
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
      motif: motif,
      defaultDark: (f & 1) != 0,
      defaultRtl: (f & 2) != 0,
      accentOnTertiary: (f & 4) != 0,
      whiteGround: (f & 8) != 0,
      navShell: kNavShells[((f >> 4) & 3).clamp(0, kNavShells.length - 1)],
      actionRow: kActionRows[((f >> 6) & 3).clamp(0, kActionRows.length - 1)],
    );
  }
}
