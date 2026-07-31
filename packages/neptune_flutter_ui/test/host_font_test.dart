import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  setUp(() => NeptuneTheme.debugSkipFontLoading = true);

  test('withHostFont reaches BUTTON labels, not just the text theme', () {
    final base = NeptuneTheme.light('neptune');
    final themed = NeptuneTheme.withHostFont(base,
        fontFamily: 'SomarSans', fontFamilyFallback: const ['Inter']);

    expect(themed.textTheme.bodyMedium?.fontFamily, 'SomarSans');

    // The regression this exists to prevent: patching textTheme alone leaves
    // filledButtonTheme holding the ORIGINAL family, so button labels render
    // in a different face than every other string on the screen.
    final resolved = themed.filledButtonTheme.style?.textStyle
        ?.resolve(<WidgetState>{});
    expect(resolved?.fontFamily, 'SomarSans');
    expect(resolved?.fontFamilyFallback, contains('Inter'));

    final outlined = themed.outlinedButtonTheme.style?.textStyle
        ?.resolve(<WidgetState>{});
    expect(outlined?.fontFamily, 'SomarSans');
  });

  test('the naive patch really does miss buttons (why this API exists)', () {
    final base = NeptuneTheme.light('neptune');
    final naive = base.copyWith(
        textTheme: base.textTheme.apply(fontFamily: 'SomarSans'));
    final resolved =
        naive.filledButtonTheme.style?.textStyle?.resolve(<WidgetState>{});
    expect(resolved?.fontFamily, isNot('SomarSans'));
  });
}
