// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

const _goldenTriton = 'NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA';

/// A seed set no reference brand matches, so the custom (generated) path runs.
const _custom = BrandprintConfig(
  primary: Seed(l: 0.411, c: 0.099, h: 270),
  tertiary: Seed(l: 0.63, c: 0.212, h: 28),
  corners: Corners(xs: 8, sm: 12, md: 16, lg: 22, xl: 28, xxl: 40),
  displayWeight: 700,
  displayTracking: -0.01,
  fontDisplay: 'IBM Plex Sans Arabic',
  fontText: 'IBM Plex Sans Arabic',
  fontNum: 'IBM Plex Sans Arabic',
  loginShell: 'shield-guilloche',
  dashboardHero: 'restrained-balance',
  contentTone: 'formal-authoritative',
  glassTint: 'navy-steel',
  motion: 'stable-minimal-authoritative',
);

void main() {
  // Keep the google_fonts runtime loader offline in tests — name families only.
  NeptuneTheme.debugSkipFontLoading = true;

  group('NeptuneTheme', () {
    test('light(triton) builds with correct M3 colors + extensions', () {
      final theme = NeptuneTheme.light('triton');
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.colorScheme.primary.toARGB32(), 0xFF00774D);
      expect(theme.extension<NptColors>(), isNotNull);
      expect(theme.extension<NptShape>()!.md, 26);
      expect(theme.extension<NptType>()!.display, 'Bricolage Grotesque');
      expect(theme.extension<NptMotion>(), isNotNull);
    });

    test('dark(triton) builds with dark scheme', () {
      final theme = NeptuneTheme.dark('triton');
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary.toARGB32(), 0xFF7EDBAE);
    });

    test('fromBrandprint(goldenTriton) == light(triton) primary', () {
      final fromBp =
          NeptuneTheme.fromBrandprint(_goldenTriton, brightness: Brightness.light);
      final fromBrand = NeptuneTheme.light('triton');
      expect(fromBp.colorScheme.primary.toARGB32(),
          fromBrand.colorScheme.primary.toARGB32());
      // The brandprint resolves to the pinned reference scheme, so the whole
      // scheme matches, not just primary.
      expect(fromBp.colorScheme.tertiary.toARGB32(),
          fromBrand.colorScheme.tertiary.toARGB32());
      expect(fromBp.extension<NptShape>()!.md,
          fromBrand.extension<NptShape>()!.md);
    });

    test('unknown brand throws', () {
      expect(() => NeptuneTheme.light('nope'), throwsArgumentError);
    });

    test('custom config builds a valid theme', () {
      const cfg = BrandprintConfig(
        primary: Seed(l: 0.55, c: 0.16, h: 20), // teal-free custom seed
        tertiary: Seed(l: 0.60, c: 0.10, h: 120),
        corners: Corners(xs: 5, sm: 9, md: 13, lg: 19, xl: 27, xxl: 37),
        displayWeight: 600,
        displayTracking: -0.015,
        fontDisplay: 'Sora',
        fontText: 'Hanken Grotesk',
        fontNum: 'Sora',
        loginShell: 'depth-emblem',
        dashboardHero: 'balance-cards',
        contentTone: 'clear-calm',
        glassTint: 'oceanic',
        motion: 'smooth-fluid',
      );
      final theme = NeptuneTheme.fromConfig(cfg, brightness: Brightness.light);
      expect(theme.useMaterial3, isTrue);
      // primary is generated from the seed via the ramp, not a reference brand.
      expect(theme.colorScheme.primary.toARGB32() >> 24, 0xFF);
      expect(theme.extension<NptShape>()!.md, 13);
      expect(theme.extension<NptColors>()!.success.toARGB32() >> 24, 0xFF);
      expect(theme.extension<NptType>()!.display, 'Sora');
    });

    // 2.24.0: the four slots a host used to patch after assembly are set from
    // tokens, on every theme the library builds - reference and custom alike.
    for (final (name, theme) in [
      ('light(proteus)', NeptuneTheme.light('proteus')),
      ('dark(proteus)', NeptuneTheme.dark('proteus')),
      ('custom light', NeptuneTheme.fromConfig(_custom, brightness: Brightness.light)),
      ('custom dark', NeptuneTheme.fromConfig(_custom, brightness: Brightness.dark)),
    ]) {
      test('$name is a finished bank theme', () {
        final scheme = theme.colorScheme;
        final shape = theme.extension<NptShape>()!;

        // App bar: leading-aligned on every platform, no M3 scroll tint.
        expect(theme.appBarTheme.centerTitle, isFalse);
        expect(theme.appBarTheme.surfaceTintColor, Colors.transparent);
        expect(theme.appBarTheme.scrolledUnderElevation, 0);
        expect(theme.appBarTheme.backgroundColor, scheme.surface);

        // FAB: the brand primary, not Material's primaryContainer fallback,
        // on the brand's smallest corner token.
        final fab = theme.floatingActionButtonTheme;
        expect(fab.backgroundColor, scheme.primary);
        expect(fab.foregroundColor, scheme.onPrimary);
        expect((fab.shape as RoundedRectangleBorder).borderRadius, shape.rXs);

        // Fields: every state carries a non-outline border, error included,
        // so the floating label never straddles the fill's top edge.
        final input = theme.inputDecorationTheme;
        expect(input.filled, isTrue);
        for (final border in [
          input.border,
          input.enabledBorder,
          input.focusedBorder,
          input.errorBorder,
          input.focusedErrorBorder,
          input.disabledBorder,
        ]) {
          expect(border, isA<NeptuneFieldBorder>());
          expect((border as NeptuneFieldBorder).isOutline, isFalse);
          expect(border.borderRadius, shape.rSm);
        }
        expect(input.errorBorder!.borderSide.color, scheme.error);
        expect(input.focusedBorder!.borderSide.width, 2);
        expect(input.enabledBorder!.borderSide.color, scheme.outline,
            reason: 'outline, not outlineVariant - the variant ring measures '
                'under 1.2:1 against the fill it encloses');

        // Brand canvas: present on every theme, dark included.
        expect(theme.extension<NptBrandCanvas>(), isNotNull);

        // All three button families carry the label captured at assembly:
        // unset, TextButton alone would read the LOCALIZED labelLarge at
        // build time (M3 height 1.43) and sit on a different line box.
        final captured = theme.filledButtonTheme.style!.textStyle!.resolve(<WidgetState>{});
        expect(captured?.fontFamily, theme.textTheme.labelLarge?.fontFamily);
        for (final style in [
          theme.outlinedButtonTheme.style,
          theme.textButtonTheme.style,
        ]) {
          expect(style?.textStyle?.resolve(<WidgetState>{}), captured);
        }
      });
    }

    test('the DARK theme brand canvas is the LIGHT primary (reference + custom)', () {
      expect(NeptuneTheme.dark('proteus').extension<NptBrandCanvas>()!.canvas,
          NeptuneTheme.light('proteus').colorScheme.primary);
      expect(
          NeptuneTheme.fromConfig(_custom, brightness: Brightness.dark)
              .extension<NptBrandCanvas>()!
              .canvas,
          NeptuneTheme.fromConfig(_custom, brightness: Brightness.light)
              .colorScheme
              .primary);
      // And it really is a different colour from the dark scheme's primary,
      // otherwise this test would prove nothing.
      final dark = NeptuneTheme.dark('proteus');
      expect(dark.extension<NptBrandCanvas>()!.canvas,
          isNot(dark.colorScheme.primary));
    });

    group('motif is its own lever (2.24.0)', () {
      BrandprintConfig withMotif(String motif) => BrandprintConfig(
            primary: _custom.primary,
            tertiary: _custom.tertiary,
            corners: _custom.corners,
            displayWeight: _custom.displayWeight,
            displayTracking: _custom.displayTracking,
            fontDisplay: _custom.fontDisplay,
            fontText: _custom.fontText,
            fontNum: _custom.fontNum,
            loginShell: _custom.loginShell,
            dashboardHero: _custom.dashboardHero,
            contentTone: _custom.contentTone,
            glassTint: 'warm-amber',
            motion: _custom.motion,
            motif: motif,
          );
      NptIdentity identity(String motif) =>
          NeptuneTheme.fromConfig(withMotif(motif)).extension<NptIdentity>()!;

      test('auto derives from glassTint exactly as before', () {
        expect(identity('auto').motif, NptMotifKind.coastalArcs);
        expect(identity('auto').motifStrength, greaterThan(0));
      });

      test('none paints nothing, by definition, with the glass untouched', () {
        final none = identity('none');
        final auto = identity('auto');
        expect(none.motif, NptMotifKind.none);
        expect(none.motifStrength, 0);
        // The glass recipe keeps its tint key: retiring a motif must not move
        // a single pane's mix, opacity or blur.
        expect(none.glassOnTertiary, auto.glassOnTertiary);
        expect(none.glassMixRatio, auto.glassMixRatio);
        expect(none.glassSurfaceOpacity, auto.glassSurfaceOpacity);
        expect(none.glassBlur, auto.glassBlur);
      });

      test('a named motif overrides the tint-derived one', () {
        expect(identity('sonar-rings').motif, NptMotifKind.sonarRings);
        expect(identity('sonar-rings').motifStrength, greaterThan(0));
        expect(identity('guilloche').motif, NptMotifKind.guilloche);
      });

      testWidgets('NeptuneMotifLayer under motif none paints no strokes', (tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: NeptuneTheme.fromConfig(withMotif('none')),
          home: const Scaffold(body: SizedBox.expand(child: NeptuneMotifLayer())),
        ));
        await tester.pump();
        // The layer builds (the widget contract holds) and its painter has
        // an exhaustive arm for `none` - the compile is the proof of that;
        // the zero strength is what keeps every existing strength<=0 guard
        // short-circuiting too.
        expect(find.byType(NeptuneMotifLayer), findsOneWidget);
        expect(Theme.of(tester.element(find.byType(NeptuneMotifLayer)))
            .extension<NptIdentity>()!
            .motifStrength, 0);
      });
    });

    group('the direction accent (2.24.0)', () {
      BrandprintConfig flagged(bool on) => BrandprintConfig(
            primary: _custom.primary,
            tertiary: _custom.tertiary,
            corners: _custom.corners,
            displayWeight: _custom.displayWeight,
            displayTracking: _custom.displayTracking,
            fontDisplay: _custom.fontDisplay,
            fontText: _custom.fontText,
            fontNum: _custom.fontNum,
            loginShell: 'lockup-rule',
            dashboardHero: 'chevron-summary',
            contentTone: _custom.contentTone,
            glassTint: _custom.glassTint,
            motion: _custom.motion,
            motif: 'none',
            accentOnTertiary: on,
          );

      test('without the flag the accent IS the primary, reference and custom', () {
        for (final theme in [
          NeptuneTheme.light('proteus'),
          NeptuneTheme.dark('proteus'),
          NeptuneTheme.fromConfig(flagged(false), brightness: Brightness.light),
          NeptuneTheme.fromConfig(flagged(false), brightness: Brightness.dark),
        ]) {
          final colors = theme.extension<NptColors>()!;
          expect(colors.accent, theme.colorScheme.primary);
          expect(colors.onAccent, theme.colorScheme.onPrimary);
        }
      });

      for (final mode in Brightness.values) {
        test('${mode.name}: with the flag the tertiary seed is the accent and reaches no Material role', () {
          final theme = NeptuneTheme.fromConfig(flagged(true), brightness: mode);
          final plain = NeptuneTheme.fromConfig(flagged(false), brightness: mode);
          final colors = theme.extension<NptColors>()!;
          final scheme = theme.colorScheme;

          // The accent is the red - the tone the tertiary recipe gives the seed
          // in the unflagged theme - and is not the primary.
          expect(colors.accent, plain.colorScheme.tertiary);
          expect(colors.onAccent, plain.colorScheme.onTertiary);
          expect(colors.accent, isNot(scheme.primary));

          // And the red is nowhere in chrome: the tertiary roles and the card
          // gradient are ramped from the primary seed instead.
          expect(scheme.tertiary, isNot(plain.colorScheme.tertiary));
          expect(scheme.tertiaryContainer, isNot(plain.colorScheme.tertiaryContainer));
          expect(colors.cardGradientEnd, isNot(plain.extension<NptColors>()!.cardGradientEnd));
          for (final role in [
            scheme.primary,
            scheme.tertiary,
            scheme.tertiaryContainer,
            scheme.secondary,
            scheme.error,
            colors.cardGradientEnd,
          ]) {
            expect(role, isNot(colors.accent));
          }
          // Everything that is not tertiary-derived is untouched by the flag.
          expect(scheme.primary, plain.colorScheme.primary);
          expect(scheme.surface, plain.colorScheme.surface);
          expect(colors.success, plain.extension<NptColors>()!.success);
          // The pre-login canvas is still the primary, not the accent.
          expect(theme.extension<NptBrandCanvas>()!.canvas,
              NeptuneTheme.fromConfig(flagged(true), brightness: Brightness.light)
                  .colorScheme
                  .primary);
        });
      }

      test('a config that resolves to a pinned reference scheme re-points the accent only', () {
        final ref = brandConfig['proteus']!;
        final cfg = BrandprintConfig(
          primary: ref.primary,
          tertiary: ref.tertiary,
          corners: ref.corners,
          displayWeight: ref.displayWeight,
          displayTracking: ref.displayTracking,
          fontDisplay: ref.fontDisplay,
          fontText: ref.fontText,
          fontNum: ref.fontNum,
          loginShell: ref.loginShell,
          dashboardHero: ref.dashboardHero,
          contentTone: ref.contentTone,
          glassTint: ref.glassTint,
          motion: ref.motion,
          accentOnTertiary: true,
        );
        final theme = NeptuneTheme.fromConfig(cfg, brightness: Brightness.light);
        expect(theme.colorScheme, NeptuneTheme.light('proteus').colorScheme,
            reason: 'a pinned scheme is never regenerated');
        expect(theme.extension<NptColors>()!.accent, theme.colorScheme.tertiary);
      });

      test('the appended shell and hero names ride NptIdentity as given', () {
        final id = NeptuneTheme.fromConfig(flagged(true)).extension<NptIdentity>()!;
        expect(id.loginShell, 'lockup-rule');
        expect(id.dashboardHero, 'chevron-summary');
        expect(id.motif, NptMotifKind.none);
      });

      testWidgets('NeptuneCta paints the accent - and only the forward CTA does', (tester) async {
        Future<Color?> ctaFill(ThemeData theme, {bool tonal = false}) async {
          await tester.pumpWidget(MaterialApp(
            theme: theme,
            // Each call swaps the theme under a live MaterialApp, whose
            // AnimatedTheme would otherwise lerp NptColors.accent from the
            // previous theme for 200ms and hand back a blend.
            themeAnimationDuration: Duration.zero,
            home: Scaffold(
              body: Center(
                child: Column(children: [
                  NeptuneCta(label: 'Continue', tonal: tonal, onPressed: () {}),
                  FilledButton(onPressed: () {}, child: const Text('Other')),
                ]),
              ),
            ),
          ));
          await tester.pump();
          final material = tester.widget<Material>(find.descendant(
            of: find.byType(NeptuneCta),
            matching: find.byType(Material),
          ));
          return material.color;
        }

        final flaggedTheme = NeptuneTheme.fromConfig(flagged(true), brightness: Brightness.light);
        final accent = flaggedTheme.extension<NptColors>()!.accent;
        expect(await ctaFill(flaggedTheme), accent);
        expect(accent, isNot(flaggedTheme.colorScheme.primary));
        // The tonal variant is chrome, not direction: no accent.
        expect(await ctaFill(flaggedTheme, tonal: true), flaggedTheme.colorScheme.secondaryContainer);
        // A plain FilledButton next to it stays on the primary - the accent
        // is spent on the forward CTA and nowhere else the theme paints.
        expect(flaggedTheme.filledButtonTheme.style?.backgroundColor, isNull,
            reason: 'FilledButton falls through to Material primary, never to the accent');

        // No flag: the CTA is the primary, as it has always been.
        final plain = NeptuneTheme.light('proteus');
        expect(await ctaFill(plain), plain.colorScheme.primary);
      });
    });

    group('the white ground (2.25.0)', () {
      BrandprintConfig grounded(bool on) => BrandprintConfig(
            primary: _custom.primary,
            tertiary: _custom.tertiary,
            corners: _custom.corners,
            displayWeight: _custom.displayWeight,
            displayTracking: _custom.displayTracking,
            fontDisplay: _custom.fontDisplay,
            fontText: _custom.fontText,
            fontNum: _custom.fontNum,
            loginShell: 'lockup-rule',
            dashboardHero: 'chevron-summary',
            contentTone: _custom.contentTone,
            glassTint: _custom.glassTint,
            motion: _custom.motion,
            motif: 'none',
            accentOnTertiary: true,
            whiteGround: on,
          );

      test('flags bit 3 round-trips and leaves bits 0-2 alone', () {
        final d = Brandprint.decode(Brandprint.encode(grounded(true)));
        expect(d.whiteGround, isTrue);
        expect(d.accentOnTertiary, isTrue);
        expect(d.defaultDark, isFalse);
        expect(Brandprint.decode(Brandprint.encode(grounded(false))).whiteGround,
            isFalse);
      });

      test('light: the ground, the app bar and the field fill are tone 100', () {
        final theme = NeptuneTheme.fromConfig(grounded(true));
        final plain = NeptuneTheme.fromConfig(grounded(false));
        final white = theme.colorScheme.surfaceContainerLowest;
        expect(theme.scaffoldBackgroundColor, white);
        expect(theme.appBarTheme.backgroundColor, white);
        expect(theme.inputDecorationTheme.fillColor, white);
        // The flag moves the ground, not the scheme: every role is unchanged.
        expect(theme.colorScheme, plain.colorScheme);
        expect(plain.scaffoldBackgroundColor, plain.colorScheme.surface);
        expect(plain.inputDecorationTheme.fillColor,
            plain.colorScheme.surfaceContainerHighest);
        // And a paper canvas built from the theme sits on that ground.
        expect(NptBrandCanvas.paperOf(theme).canvas, white);
        expect(NptBrandCanvas.paperOf(plain).canvas, plain.colorScheme.surface);
      });

      test('dark: untouched - there is no white to be', () {
        final theme =
            NeptuneTheme.fromConfig(grounded(true), brightness: Brightness.dark);
        expect(theme.scaffoldBackgroundColor, theme.colorScheme.surface);
        expect(theme.inputDecorationTheme.fillColor,
            theme.colorScheme.surfaceContainerHighest);
      });
    });

    group('NptBrandCanvas.paper (2.24.0)', () {
      test('re-tones with brightness, unlike the brand canvas', () {
        final light = NeptuneTheme.light('proteus');
        final dark = NeptuneTheme.dark('proteus');
        final paperL = NptBrandCanvas.paper(light.colorScheme);
        final paperD = NptBrandCanvas.paper(dark.colorScheme);
        expect(paperL.canvas, light.colorScheme.surface);
        expect(paperD.canvas, dark.colorScheme.surface);
        expect(paperL.canvas, isNot(paperD.canvas));
        expect(paperL.onCanvas, light.colorScheme.onSurface);
        expect(paperL.card, light.colorScheme.surfaceContainerLow);
        expect(paperL.onCardError, light.colorScheme.error);
        // Whereas the theme's own canvas is the light primary in both.
        expect(dark.extension<NptBrandCanvas>()!.canvas,
            light.extension<NptBrandCanvas>()!.canvas);
      });
    });

    testWidgets('widgets render under the theme (LTR + RTL)', (tester) async {
      for (final dir in [TextDirection.ltr, TextDirection.rtl]) {
        await tester.pumpWidget(MaterialApp(
          theme: NeptuneTheme.light('nereid'),
          home: Directionality(
            textDirection: dir,
            child: Scaffold(
              body: ListView(
                children: const [
                  NeptuneBalanceCard(
                      label: 'Available', amount: '1,234.56', caption: 'KWD'),
                  NeptuneTransactionRow(
                      title: 'Salary', amount: '+2,000.00', isCredit: true),
                  NeptuneAccountTile(
                      name: 'Current',
                      maskedNumber: '•••• 1234',
                      balance: '500.00'),
                  NeptunePrimaryButton(label: 'Send'),
                ],
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.text('Available'), findsOneWidget);
        expect(find.text('Send'), findsOneWidget);
      }
    });
  });
}
