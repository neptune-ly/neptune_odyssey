// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// THE 2.31.0 MERGE OF `design/fglb-wallet` AND `design/nuran-ink`.
//
// Both lines appended a seventh entry at index 6 of `kLoginShells`. FGLB's
// `pocket-drift` kept 6; Nuran's `drift-depth` moved to 7. An index in that
// registry IS the wire format, so a renumber is a wire change and every claim
// made for its safety is asserted here rather than argued in a comment.
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import 'brandprint_production_test.dart' as prod;

List<int> _payload(String s) =>
    base64Url.decode(s.substring(4).padRight((s.length - 4 + 3) ~/ 4 * 4, '='));

/// Byte 20 of the payload is the login-shell ordinal. Hardcoded rather than
/// computed so that a layout change has to come past this test.
const int _loginShellByte = 20;

void main() {
  group('the login-shell ordinal after the merge', () {
    test('pocket-drift kept index 6, drift-depth moved to 7', () {
      expect(kLoginShells.indexOf('pocket-drift'), 6);
      expect(kLoginShells.indexOf('drift-depth'), 7);
      expect(kLoginShells.length, 8);
    });

    test('the registry is a WHOLE BYTE, not a packed field', () {
      // The claim the renumber rests on: the payload does not have to grow to
      // hold an eighth shell, and would not have to grow for a 256th. Proven
      // by encoding both new shells and showing the payload length is the same
      // as a shell from the original 0-5 set, and that the ordinal lands in
      // one byte that carries nothing else.
      const base = prod.nuranBrandprint;
      final lengths = <int>{};
      for (final shell in kLoginShells) {
        final bytes = _payload(Brandprint.encode(_withShell(base, shell)));
        lengths.add(bytes.length);
        expect(bytes[_loginShellByte], kLoginShells.indexOf(shell));
      }
      expect(lengths, {28}, reason: 'no shell in the registry grows the payload');
    });

    test('both new shells round-trip by name', () {
      for (final shell in ['pocket-drift', 'drift-depth']) {
        final cfg = _withShell(prod.nuranBrandprint, shell);
        expect(Brandprint.decode(Brandprint.encode(cfg)).loginShell, shell);
      }
    });
  });

  group('nothing in production moved', () {
    // The three strings that are in customers' hands. `kIssuedBefore2280` was
    // captured from a v2.27.0 worktree - a value this tree produced could not
    // prove this tree did not shift it.
    const production = {
      'andalus': prod.andalusBrandprint,
      'nuran': prod.nuranBrandprint,
      'fglb': prod.fglbBrandprint,
    };

    test('no production brandprint encodes login-shell index 6 or 7', () {
      for (final e in prod.kIssuedBefore2280.entries) {
        final ordinal = _payload(e.value)[_loginShellByte];
        expect(ordinal, lessThan(6),
            reason: '${e.key} would have been repointed by the renumber');
      }
      // Stated as names too, so a future reorder of 0-5 cannot quietly pass.
      expect(
        prod.kIssuedBefore2280.map(
            (k, v) => MapEntry(k, Brandprint.decode(v).loginShell)),
        {
          'andalus': 'depth-emblem',
          'nuran': 'paper-lockup',
          'fglb': 'lockup-rule',
        },
      );
    });

    test('ANDALUS is byte-identical to before the merge', () {
      // Andalus is the only bank in customers' hands. Asserted on the BYTES,
      // not on the string, so an encoding change could not hide here either.
      final before = _payload(prod.kIssuedBefore2280['andalus']!);
      final after = _payload(Brandprint.encode(prod.andalusBrandprint));
      expect(after, orderedEquals(before));
      expect(Brandprint.encode(prod.andalusBrandprint),
          prod.kIssuedBefore2280['andalus']);
    });

    test('nuran and fglb are byte-identical too - the renumber cost nothing',
        () {
      // The merge was expected to move Nuran's string by one byte. It does
      // NOT: Nuran's production brandprint declares `paper-lockup` (index 4),
      // not the new shell, so the renumber does not reach it. Asserted rather
      // than left unnoticed, because "it didn't change" and "we forgot to
      // check" look identical in a green suite.
      for (final bank in ['nuran', 'fglb']) {
        final cfg = production[bank]!;
        expect(_payload(Brandprint.encode(cfg)),
            orderedEquals(_payload(prod.kIssuedBefore2280[bank]!)),
            reason: '$bank moved');
      }
    });

    test('decode(encode(cfg)) returns identical levers for all three', () {
      for (final e in production.entries) {
        final round = Brandprint.decode(Brandprint.encode(e.value));
        expect(round.loginShell, e.value.loginShell, reason: e.key);
        expect(round.dashboardHero, e.value.dashboardHero, reason: e.key);
        expect(round.motif, e.value.motif, reason: e.key);
        expect(round.navShell, e.value.navShell, reason: e.key);
        expect(round.actionRow, e.value.actionRow, reason: e.key);
        expect(round.contentTone, e.value.contentTone, reason: e.key);
        expect(round.glassTint, e.value.glassTint, reason: e.key);
        expect(round.motion, e.value.motion, reason: e.key);
        expect(round.accentOnTertiary, e.value.accentOnTertiary, reason: e.key);
        expect(round.whiteGround, e.value.whiteGround, reason: e.key);
        expect(round.ruledRegister, e.value.ruledRegister, reason: e.key);
        expect(round.warmGround, e.value.warmGround, reason: e.key);
        expect(round.amountFirstTransfer, e.value.amountFirstTransfer,
            reason: e.key);
        expect(round.corners, e.value.corners, reason: e.key);
        expect(round.displayWeight, e.value.displayWeight, reason: e.key);
        expect(round.displayTracking, e.value.displayTracking, reason: e.key);
        // And the whole string is stable under a second pass.
        expect(Brandprint.encode(round), Brandprint.encode(e.value),
            reason: e.key);
      }
    });
  });

  group('the one thing the renumber DOES break', () {
    test('a pre-merge nuran string carrying byte 6 now decodes as pocket-drift',
        () {
      // The hazard, asserted so it is a documented fact and not a surprise: a
      // brandprint minted by a `design/nuran-ink` build BEFORE this merge put
      // 6 in byte 20 meaning `drift-depth`. That byte is still valid, so the
      // string still decodes - to the OTHER bank's shell, silently. Those
      // builds were never distributed; any such string must be re-minted.
      final legacy = _mintWithShellOrdinal(prod.nuranBrandprint, 6);
      expect(Brandprint.decode(legacy).loginShell, 'pocket-drift');

      final reminted =
          Brandprint.encode(_withShell(prod.nuranBrandprint, 'drift-depth'));
      expect(_payload(reminted)[_loginShellByte], 7);
      expect(Brandprint.decode(reminted).loginShell, 'drift-depth');
    });
  });

  group('the extension byte needed no arbitration', () {
    test('bit 1 is amountFirstTransfer, bit 2 is warmGround', () {
      final amount = _payload(Brandprint.encode(
          _withFlags(prod.fglbBrandprint, amountFirst: true)));
      expect(amount.length, 29);
      expect(amount[27], 2);

      final warm =
          _payload(Brandprint.encode(_withFlags(prod.fglbBrandprint, warm: true)));
      expect(warm.length, 29);
      expect(warm[27], 4);

      final both = _payload(Brandprint.encode(
          _withFlags(prod.fglbBrandprint, amountFirst: true, warm: true)));
      expect(both[27], 6);
      final d = Brandprint.decode(Brandprint.encode(
          _withFlags(prod.fglbBrandprint, amountFirst: true, warm: true)));
      expect(d.amountFirstTransfer, isTrue);
      expect(d.warmGround, isTrue);
      expect(d.ruledRegister, isFalse);
    });

    test('ink-pill kept the last slot of the two-bit nav field', () {
      expect(kNavShells.indexOf('ink-pill'), 3);
      expect(kNavShells.length, 4);
    });
  });
}

BrandprintConfig _withShell(BrandprintConfig c, String shell) =>
    _rebuild(c, loginShell: shell);

BrandprintConfig _withFlags(BrandprintConfig c,
        {bool amountFirst = false, bool warm = false}) =>
    _rebuild(c, amountFirstTransfer: amountFirst, warmGround: warm);

BrandprintConfig _rebuild(
  BrandprintConfig c, {
  String? loginShell,
  bool? amountFirstTransfer,
  bool? warmGround,
}) =>
    BrandprintConfig(
      primary: c.primary,
      tertiary: c.tertiary,
      corners: c.corners,
      displayWeight: c.displayWeight,
      displayTracking: c.displayTracking,
      fontDisplay: c.fontDisplay,
      fontText: c.fontText,
      fontNum: c.fontNum,
      loginShell: loginShell ?? c.loginShell,
      dashboardHero: c.dashboardHero,
      contentTone: c.contentTone,
      glassTint: c.glassTint,
      motion: c.motion,
      motif: c.motif,
      defaultDark: c.defaultDark,
      defaultRtl: c.defaultRtl,
      accentOnTertiary: c.accentOnTertiary,
      whiteGround: c.whiteGround,
      navShell: c.navShell,
      actionRow: c.actionRow,
      ruledRegister: c.ruledRegister,
      warmGround: warmGround ?? c.warmGround,
      amountFirstTransfer: amountFirstTransfer ?? c.amountFirstTransfer,
    );

/// Mint a string with a RAW login-shell ordinal, bypassing the registry, to
/// stand in for a build that had a different registry compiled in.
String _mintWithShellOrdinal(BrandprintConfig c, int ordinal) {
  final bytes = List<int>.from(_payload(Brandprint.encode(c)));
  bytes[_loginShellByte] = ordinal;
  var sum = 0;
  for (var i = 0; i < bytes.length - 1; i++) {
    sum = (sum + bytes[i]) & 255;
  }
  bytes[bytes.length - 1] = sum;
  return 'NO1-${base64Url.encode(bytes).replaceAll('=', '')}';
}
