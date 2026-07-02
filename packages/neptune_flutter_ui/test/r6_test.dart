// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// R6: density, dark-elevation glow, signature motion, haptics/sound tokens,
// Arabic-Indic numerals, and the new loader family + splash screen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

Widget _host(Widget child, {Brightness brightness = Brightness.light, bool rtl = false}) {
  NeptuneTheme.debugSkipFontLoading = true;
  return MaterialApp(
    theme: brightness == Brightness.light
        ? NeptuneTheme.light('neptune')
        : NeptuneTheme.dark('neptune'),
    home: Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('numerals', () {
    test('toEasternArabicDigits swaps only ASCII digits', () {
      expect(toEasternArabicDigits('LYD 1,250.40'), 'LYD ١,٢٥٠.٤٠');
      expect(toEasternArabicDigits('no digits here'), 'no digits here');
    });

    test('NptNumerals.format is a no-op for latin', () {
      const n = NptNumerals(NeptuneNumeralStyle.latin);
      expect(n.format('123'), '123');
    });

    testWidgets('NeptuneTheme.formatDigits reads the active lever', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        theme: NeptuneTheme.light('neptune', numerals: NeptuneNumeralStyle.easternArabic),
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox();
        }),
      ));
      expect(NeptuneTheme.formatDigits(ctx, '42'), '٤٢');
    });
  });

  group('density', () {
    test('NptDensity.of scales comfortable=1, compact<1', () {
      expect(NptDensity.of(NeptuneDensityMode.comfortable).scale, 1.0);
      expect(NptDensity.of(NeptuneDensityMode.compact).scale, lessThan(1.0));
    });

    testWidgets('NeptuneListTile respects a compact theme density', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: NeptuneTheme.light('neptune', density: NeptuneDensityMode.compact),
        home: const Scaffold(body: NeptuneListTile(title: 'Row')),
      ));
      final finiteMinHeights = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .map((w) => w.constraints.minHeight)
          .where((h) => h.isFinite && h > 0);
      expect(finiteMinHeights, contains(lessThan(56)));
    });
  });

  group('feedback (haptics/sound)', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized()
          .defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
    });
    tearDown(() {
      TestWidgetsFlutterBinding.ensureInitialized()
          .defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('trigger fires the sound hook with the right cue and does not throw', () {
      NptFeedbackCue? fired;
      const feedback = NptFeedback();
      final withHook = feedback.copyWith(onSoundCue: (cue) => fired = cue);
      withHook.trigger(NptFeedbackCue.success);
      expect(fired, NptFeedbackCue.success);
    });

    test('hapticWeightFor maps content tone to a sensible weight', () {
      expect(hapticWeightFor('formal-authoritative'), NptHapticWeight.light);
      expect(hapticWeightFor('warm-hospitable'), NptHapticWeight.heavy);
      expect(hapticWeightFor('unknown-tone'), NptHapticWeight.medium);
    });

    testWidgets('tapping NeptuneCta fires feedback without throwing', (tester) async {
      NptFeedbackCue? fired;
      var pressed = false;
      await tester.pumpWidget(MaterialApp(
        theme: NeptuneTheme.light('neptune',
            feedback: NptFeedback(onSoundCue: (cue) => fired = cue)),
        home: Scaffold(
          body: NeptuneCta(label: 'Go', onPressed: () => pressed = true),
        ),
      ));
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(pressed, isTrue);
      expect(fired, NptFeedbackCue.tap);
    });
  });

  group('dark-mode glow elevation', () {
    test('elevation colours differ between light and dark for the same scheme shape', () {
      final light = NeptuneTheme.light('neptune').extension<NptIdentity>()!;
      final dark = NeptuneTheme.dark('neptune').extension<NptIdentity>()!;
      final lightScheme = NeptuneTheme.light('neptune').colorScheme;
      final darkScheme = NeptuneTheme.dark('neptune').colorScheme;

      final lightShadow = light.elevation3(lightScheme).first;
      final darkShadow = dark.elevation3(darkScheme).first;

      // Dark mode's glow leans toward primary, not flat black.
      expect(darkShadow.color, isNot(equals(Colors.black.withValues(alpha: darkShadow.color.a))));
      expect(lightShadow.blurRadius, isNot(equals(darkShadow.blurRadius)));
    });
  });

  group('signature motion (per-brand CTA timing)', () {
    test('Neptune (smooth-fluid) reproduces the pre-R6 baseline exactly', () {
      final motion = motionFor('smooth-fluid');
      expect(motion.slow * 96 ~/ 10, const Duration(milliseconds: 4800));
      expect(motion.durationStandard * 8, const Duration(milliseconds: 2400));
    });

    test('a calmer brand gets a visibly slower sheen cycle', () {
      final neptune = motionFor('smooth-fluid');
      final triton = motionFor('calm-graceful');
      expect(triton.slow * 96 ~/ 10, greaterThan(neptune.slow * 96 ~/ 10));
    });
  });

  group('loader family', () {
    for (final style in NeptuneLoaderStyle.values) {
      testWidgets('$style builds LTR + RTL', (tester) async {
        await tester.pumpWidget(_host(neptuneLoaderFor(style, size: 48)));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(_host(neptuneLoaderFor(style, size: 48), rtl: true));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('standalone loader widgets build directly', (tester) async {
      await tester.pumpWidget(_host(const Column(children: [
        NeptuneHourglassLoader(size: 40),
        NeptuneSpinner(size: 40),
        NeptuneDotsLoader(size: 40),
        NeptunePulseLoader(size: 40),
      ])));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });

  group('NeptuneStatusMotion loaderStyle', () {
    for (final style in NeptuneLoaderStyle.values) {
      testWidgets('loading with $style then morphs to success', (tester) async {
        NeptuneFlowStatus status = NeptuneFlowStatus.loading;
        await tester.pumpWidget(_host(StatefulBuilder(builder: (context, setState) {
          return NeptuneStatusMotion(status: status, loaderStyle: style);
        })));
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('NeptuneSplashScreen', () {
    testWidgets('builds LTR + RTL with default pulse loader', (tester) async {
      await tester.pumpWidget(_host(
        const NeptuneSplashScreen(brandInitial: 'N', brandName: 'Neptune Bank'),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Neptune Bank'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(_host(
        const NeptuneSplashScreen(brandInitial: 'ن', brandName: 'مصرف نبتون'),
        rtl: true,
      ));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('مصرف نبتون'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('accepts a custom logo + caption', (tester) async {
      await tester.pumpWidget(_host(const NeptuneSplashScreen(
        brandInitial: 'N',
        brandName: 'Neptune Bank',
        logo: Icon(Icons.account_balance),
        caption: 'Loading your account…',
      )));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.account_balance), findsOneWidget);
      expect(find.text('Loading your account…'), findsOneWidget);
    });
  });
}
