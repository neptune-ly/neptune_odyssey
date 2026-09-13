// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// Nuran's production light scheme, trimmed to the roles these tests assert.
/// The real thing lives in the app; what matters here is that whatever is
/// handed over comes back unchanged.
ColorScheme _light() => const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff114075),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd4e3ff),
      onPrimaryContainer: Color(0xff224876),
      secondary: Color(0xff2a638a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfff4f9ff),
      onSecondaryContainer: Color(0xff024b71),
      tertiary: Color(0x1f767680),
      onTertiary: Color(0xffffffff),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      surface: Color(0xffffffff),
      onSurface: Color(0xff171d1e),
      outlineVariant: Color(0xffd1d5dc),
    );

ColorScheme _dark() => const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff4587fd),
      onPrimary: Color(0xff00315e),
      primaryContainer: Color(0xff224876),
      onPrimaryContainer: Color(0xffd4e3ff),
      secondary: Color(0xff97ccf9),
      onSecondary: Color(0xff003450),
      secondaryContainer: Color(0xff024b71),
      onSecondaryContainer: Color(0xffcbe6ff),
      tertiary: Color(0xffdabde2),
      onTertiary: Color(0xff3d2946),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      surface: Color(0xff121a2a),
      onSurface: Color(0xfffeffff),
      outlineVariant: Color(0xff2e394e),
    );

NptBrandScheme _nuran() => NptBrandScheme(
      light: _light(),
      dark: _dark(),
      successLight: const Color(0xff2e7d5b),
      successDark: const Color(0xff6fd3a5),
    );

/// A config whose seeds are the OKLCH reading of the same navy, so the test
/// proves the SCHEME wins rather than that the seeds were wrong.
const _cfg = BrandprintConfig(
  primary: Seed(l: 0.372, c: 0.104, h: 262),
  tertiary: Seed(l: 0.47, c: 0.083, h: 243),
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
  navShell: 'register-bar',
  actionRow: 'register-rows',
  motif: 'none',
);

void main() {
  setUpAll(() => NeptuneTheme.debugSkipFontLoading = true);

  group('NptBrandScheme', () {
    test('the supplied scheme is used verbatim, not approximated', () {
      final theme = NeptuneTheme.fromConfig(_cfg,
          brightness: Brightness.light, scheme: _nuran());
      // The whole reason this lever exists: the ramp pins light `primary` at
      // L 0.48 and would have returned a mid blue for this navy.
      expect(theme.colorScheme.primary, const Color(0xff114075));
      expect(theme.colorScheme.secondary, const Color(0xff2a638a));
      expect(theme.colorScheme.surface, const Color(0xffffffff));
      expect(theme.colorScheme.outlineVariant, const Color(0xffd1d5dc));
    });

    test('the ramp really would not have produced it', () {
      final generated =
          NeptuneTheme.fromConfig(_cfg, brightness: Brightness.light);
      expect(generated.colorScheme.primary, isNot(const Color(0xff114075)),
          reason: 'if the ramp can hit this navy the lever is unnecessary');
    });

    test('the dark scheme is the brand\'s own, not the ramp\'s', () {
      final theme = NeptuneTheme.fromConfig(_cfg,
          brightness: Brightness.dark, scheme: _nuran());
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xff4587fd));
      expect(theme.colorScheme.surface, const Color(0xff121a2a));
    });

    test('passing no scheme leaves the generated path byte-identical', () {
      final before = NeptuneTheme.fromConfig(_cfg, brightness: Brightness.light);
      final after = NeptuneTheme.fromConfig(_cfg,
          brightness: Brightness.light, scheme: null);
      expect(after.colorScheme, before.colorScheme);
      // NptColors is a ThemeExtension without value equality, so the roles are
      // compared rather than the instances.
      final a = after.extension<NptColors>()!;
      final b = before.extension<NptColors>()!;
      expect(
        [a.success, a.successContainer, a.cardGradientStart, a.cardGradientEnd, a.onCard, a.accent],
        [b.success, b.successContainer, b.cardGradientStart, b.cardGradientEnd, b.onCard, b.accent],
      );
      final ac = after.extension<NptBrandCanvas>()!;
      final bc = before.extension<NptBrandCanvas>()!;
      expect([ac.canvas, ac.onCanvas, ac.card, ac.onCard],
          [bc.canvas, bc.onCanvas, bc.card, bc.onCard]);
    });

    test('the brand canvas is the bank\'s colour at BOTH brightnesses', () {
      final day = NeptuneTheme.fromConfig(_cfg,
              brightness: Brightness.light, scheme: _nuran())
          .extension<NptBrandCanvas>()!;
      final night = NeptuneTheme.fromConfig(_cfg,
              brightness: Brightness.dark, scheme: _nuran())
          .extension<NptBrandCanvas>()!;
      // The inversion bug this guards: a ground built from `colorScheme` comes
      // out BRIGHTER at night, because a dark scheme's `primary` is a light
      // tone. The canvas is built from the LIGHT scheme in both themes.
      expect(night.canvas, day.canvas);
      expect(night.onCanvas, day.onCanvas);
    });

    test('the card is the brand pair, and its ink is the light on-primary',
        () {
      for (final mode in Brightness.values) {
        final colors = NeptuneTheme.fromConfig(_cfg,
                brightness: mode, scheme: _nuran())
            .extension<NptColors>()!;
        expect(colors.cardGradientStart, const Color(0xff114075));
        expect(colors.cardGradientEnd, const Color(0xff2a638a));
        // Not `scheme.onPrimary`: in the dark scheme that is #00315e, which
        // would have drawn the card's own label near-black on deep navy.
        expect(colors.onCard, const Color(0xffffffff));
      }
    });

    test('the tertiary alpha fill never reaches the card', () {
      final colors = NeptuneTheme.fromConfig(_cfg,
              brightness: Brightness.light, scheme: _nuran())
          .extension<NptColors>()!;
      expect(colors.cardGradientEnd.a, 1.0,
          reason: 'a translucent gradient stop shows whatever is behind it');
    });

    test('success is the brand\'s green and its container is opaque', () {
      final light = NeptuneTheme.fromConfig(_cfg,
              brightness: Brightness.light, scheme: _nuran())
          .extension<NptColors>()!;
      expect(light.success, const Color(0xff2e7d5b));
      expect(light.successContainer.a, 1.0);
      final dark = NeptuneTheme.fromConfig(_cfg,
              brightness: Brightness.dark, scheme: _nuran())
          .extension<NptColors>()!;
      expect(dark.success, const Color(0xff6fd3a5));
    });

    test('non-colour levers still come from the brandprint', () {
      final theme = NeptuneTheme.fromConfig(_cfg,
          brightness: Brightness.light, scheme: _nuran());
      expect(theme.extension<NptShape>()!.md, 12);
      expect(theme.extension<NptShape>()!.xxl, 28);
      expect(theme.extension<NptIdentity>()!.navShell, 'register-bar');
      expect(theme.extension<NptIdentity>()!.dashboardHero, 'statement-ledger');
    });

    test('two light schemes by copy-paste is caught at construction', () {
      expect(
        () => NptBrandScheme(
          light: _light(),
          dark: _light(),
          successLight: const Color(0xff2e7d5b),
          successDark: const Color(0xff6fd3a5),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
