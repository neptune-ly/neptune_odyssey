// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// 2.26.0: the labelled-value list, and the field recipe it shipped beside.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

Widget _host(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    MaterialApp(
      theme: NeptuneTheme.light('neptune'),
      home: Directionality(
        textDirection: dir,
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  setUpAll(() => NeptuneTheme.debugSkipFontLoading = true);

  testWidgets('a group draws one hairline between every two rows',
      (tester) async {
    await tester.pumpWidget(_host(const NeptuneDetailList(
      title: 'Details',
      children: [
        NeptuneDetailItem(label: 'Reference', value: 'FT26123ABC', numeric: true),
        NeptuneDetailItem(label: 'Date', value: '12 Sep 2026'),
        NeptuneDetailItem(label: 'Amount', value: '1,250.000', emphasis: true),
      ],
    )));
    expect(find.byType(Divider), findsNWidgets(2));
    expect(find.text('DETAILS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a numeric value keeps its glyph order under RTL',
      (tester) async {
    await tester.pumpWidget(_host(
      const NeptuneDetailList(children: [
        NeptuneDetailItem(label: 'رقم', value: 'LY83 0020 4800', numeric: true),
      ]),
      dir: TextDirection.rtl,
    ));
    final numeral = tester.widget<NeptuneNumeral>(find.byType(NeptuneNumeral));
    expect(numeral.value, 'LY83 0020 4800');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a trailing action gets a fixed 40dp slot', (tester) async {
    await tester.pumpWidget(_host(NeptuneDetailList(children: [
      NeptuneDetailItem(
        label: 'Reference',
        value: 'FT26123ABC',
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.copy_outlined, size: 18),
        ),
      ),
    ])));
    final slot = tester.getSize(find
        .ancestor(
          of: find.byIcon(Icons.copy_outlined),
          matching: find.byType(SizedBox),
        )
        .first);
    expect(slot.width, 40);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the theme field is the lightest tone inside an outline ring',
      (tester) async {
    await tester.pumpWidget(_host(const TextField()));
    final theme = Theme.of(tester.element(find.byType(TextField)));
    final decoration = theme.inputDecorationTheme;
    expect(decoration.fillColor, theme.colorScheme.surfaceContainerLowest);
    expect((decoration.enabledBorder as NeptuneFieldBorder).borderSide.color,
        theme.colorScheme.outline);
  });

  testWidgets('NeptuneTextField and NeptuneSelect wear the same field',
      (tester) async {
    await tester.pumpWidget(_host(Column(children: [
      const NeptuneTextField(label: 'Meter'),
      NeptuneSelect<int>(
        label: 'Account',
        options: const [NeptuneSelectOption(value: 1, label: 'One')],
        value: 1,
        onChanged: (_) {},
      ),
    ])));
    final scheme =
        Theme.of(tester.element(find.byType(TextField))).colorScheme;
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.fillColor, scheme.surfaceContainerLowest);
    expect(
        (field.decoration!.enabledBorder as OutlineInputBorder)
            .borderSide
            .color,
        scheme.outline);
    final select = tester.widget<DropdownButtonFormField<int>>(
        find.byType(DropdownButtonFormField<int>));
    expect(select.decoration.fillColor, scheme.surfaceContainerLowest);
  });

  testWidgets('a flat list tile paints no surface of its own', (tester) async {
    await tester.pumpWidget(
        _host(const NeptuneListTile(title: 'Ahmed', flat: true)));
    final material = tester.widget<Material>(find
        .ancestor(of: find.text('Ahmed'), matching: find.byType(Material))
        .first);
    expect(material.type, MaterialType.transparency);
  });
}
