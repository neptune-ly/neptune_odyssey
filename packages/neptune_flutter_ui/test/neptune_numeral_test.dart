import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  testWidgets('renders LTR even under an RTL parent', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.rtl,
      child: NeptuneNumeral('LY83 0270 0000 0000 0000 9999'),
    ));
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.textDirection, TextDirection.ltr);
  });

  testWidgets('does NOT change layout direction of its parent', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.rtl,
      child: Row(children: [NeptuneNumeral('123'), Text('label')]),
    ));
    // The numeral sits where RTL puts the first child — mirroring is intact;
    // only the glyphs inside the value are pinned.
    final numeral = tester.getCenter(find.text('123'));
    final label = tester.getCenter(find.text('label'));
    expect(numeral.dx, greaterThan(label.dx));
  });

  test('isolated() uses LRI/PDI, not a bare LRM', () {
    final out = NeptuneNumeral.isolated('12.500 LYD');
    expect(out.codeUnitAt(0), 0x2066);
    expect(out.codeUnitAt(out.length - 1), 0x2069);
    expect(out.contains('‎'), isFalse);
  });
}
