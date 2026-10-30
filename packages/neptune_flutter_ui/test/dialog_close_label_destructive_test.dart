import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// The dialog and sheet barriers speak the host's word for close (the English
/// fallback is 'close'; Material's is 'Dismiss', and its Arabic is "reject"),
/// and a destructive primary action is drawn in error.
void main() {
  Future<BuildContext> pump(WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      theme: NeptuneTheme.light('neptune'),
      home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold();
      }),
    ));
    return ctx;
  }

  ModalBarrier barrier(WidgetTester tester) =>
      tester.widgetList<ModalBarrier>(find.byType(ModalBarrier)).last;

  testWidgets('dialog barrier uses the host close label', (tester) async {
    final ctx = await pump(tester);
    showNeptuneDialog<Object>(context: ctx, title: 'T');
    await tester.pumpAndSettle();
    expect(barrier(tester).semanticsLabel, 'close');
  });

  testWidgets('sheet barrier uses the host close label', (tester) async {
    final ctx = await pump(tester);
    showNeptuneSheet<Object>(context: ctx, child: const Text('x'));
    await tester.pumpAndSettle();
    expect(barrier(tester).semanticsLabel, 'close');
  });

  testWidgets('destructive primary is filled in error', (tester) async {
    final ctx = await pump(tester);
    final error = Theme.of(ctx).colorScheme.error;
    showNeptuneDialog<Object>(context: ctx, title: 'Remove?', actions: const [
      NeptuneDialogAction(label: 'Remove', primary: true, destructive: true),
    ]);
    await tester.pumpAndSettle();
    final b = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(b.style!.backgroundColor!.resolve({}), error);
  });
}
