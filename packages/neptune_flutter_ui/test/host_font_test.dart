// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// A host that bundles its own faces passes them AT assembly. The theme that
/// comes back names the host family everywhere - text theme, button labels,
/// `NptType` (Arabic faces included), the money style - and never consults the
/// google_fonts loader, so production has no debug flag to flip.
void main() {
  const host = NptHostFont(family: 'SomarSans', fallback: ['Inter']);

  setUp(() => NeptuneTheme.debugSkipFontLoading = true);

  test('hostFont reaches the text theme, BOTH button label styles and the fallback', () {
    final theme = NeptuneTheme.fromConfig(brandConfig['neptune']!, hostFont: host);

    expect(theme.textTheme.bodyMedium?.fontFamily, 'SomarSans');
    expect(theme.textTheme.bodyMedium?.fontFamilyFallback, ['Inter']);
    expect(theme.textTheme.displayLarge?.fontFamily, 'SomarSans',
        reason: 'the display face is the host face too');
    expect(theme.primaryTextTheme.bodyMedium?.fontFamily, 'SomarSans');
    expect(theme.primaryTextTheme.bodyMedium?.fontFamilyFallback, ['Inter']);

    // The regression `withHostFont` existed for: filled/outlined button themes
    // capture `labelLarge` at assembly, so a post-hoc textTheme patch left
    // button LABELS in the brandprint's face while every other string moved.
    for (final style in [
      theme.filledButtonTheme.style?.textStyle?.resolve(<WidgetState>{}),
      theme.outlinedButtonTheme.style?.textStyle?.resolve(<WidgetState>{}),
      // 2.24.1: the text button too - `withHostFont` filled all three.
      theme.textButtonTheme.style?.textStyle?.resolve(<WidgetState>{}),
    ]) {
      expect(style?.fontFamily, 'SomarSans');
      expect(style?.fontFamilyFallback, contains('Inter'));
    }
  });

  test('hostFont reaches NptType - every face, the Arabic ones included', () {
    final type = NeptuneTheme.fromConfig(brandConfig['neptune']!, hostFont: host)
        .extension<NptType>()!;
    expect(type.bundled, isTrue);
    expect(type.fontFamilyFallback, ['Inter']);
    for (final face in [
      type.display,
      type.text,
      type.num,
      type.displayAr,
      type.textAr,
      type.numAr,
    ]) {
      expect(face, 'SomarSans');
    }
    // Weight and tracking are still the brand's.
    expect(type.displayWeight, brandConfig['neptune']!.displayWeight);
    expect(type.displayTracking, brandConfig['neptune']!.displayTracking);
  });

  testWidgets('moneyStyle under RTL resolves the host family (the numAr regression)',
      (tester) async {
    // Before 2.24.0 `NptType.numAr` defaulted to 'IBM Plex Sans Arabic' and
    // moneyStyle resolved it through google_fonts, so every Arabic figure was
    // in a different typeface from the words beside it.
    late TextStyle money;
    await tester.pumpWidget(MaterialApp(
      theme: NeptuneTheme.fromConfig(brandConfig['neptune']!,
          arabic: true, hostFont: host),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Builder(builder: (context) {
          money = NeptuneTheme.moneyStyle(context);
          return const SizedBox();
        }),
      ),
    ));
    expect(money.fontFamily, 'SomarSans');
    expect(money.fontFamilyFallback, ['Inter']);
    expect(money.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  test('a theme assembled with hostFont never needs the debug flag', () {
    // With every face bundled no code path reaches `_gf`, so leaving the
    // loader ENABLED must build the same theme. (A registry family reaching
    // the loader here would surface as an async error in this zone.)
    NeptuneTheme.debugSkipFontLoading = false;
    addTearDown(() => NeptuneTheme.debugSkipFontLoading = true);
    final theme = NeptuneTheme.light('neptune', hostFont: host);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'SomarSans');
    expect(theme.extension<NptType>()!.bundled, isTrue);
  });

  test('every entry point takes hostFont', () {
    const golden = 'NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA';
    for (final theme in [
      NeptuneTheme.light('triton', hostFont: host),
      NeptuneTheme.dark('triton', hostFont: host),
      NeptuneTheme.fromBrandprint(golden, hostFont: host),
      NeptuneTheme.fromConfig(brandConfig['triton']!, hostFont: host),
    ]) {
      expect(theme.textTheme.bodyMedium?.fontFamily, 'SomarSans');
      expect(theme.extension<NptType>()!.numAr, 'SomarSans');
    }
  });

  test('without hostFont nothing changes: registry faces, not bundled', () {
    final theme = NeptuneTheme.light('neptune');
    final type = theme.extension<NptType>()!;
    expect(type.bundled, isFalse);
    expect(type.fontFamilyFallback, isEmpty);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Hanken Grotesk');
    expect(type.numAr, 'IBM Plex Sans Arabic');
  });

  test('withHostFont still works for hosts on the old API (deprecated)', () {
    // ignore: deprecated_member_use_from_same_package
    final themed = NeptuneTheme.withHostFont(NeptuneTheme.light('neptune'),
        fontFamily: 'SomarSans', fontFamilyFallback: const ['Inter']);
    expect(themed.textTheme.bodyMedium?.fontFamily, 'SomarSans');
    expect(
        themed.filledButtonTheme.style?.textStyle
            ?.resolve(<WidgetState>{})?.fontFamily,
        'SomarSans');
  });
}
