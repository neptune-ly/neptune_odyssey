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

  testWidgets('an action that does not close keeps the dialog; busy hides actions',
      (tester) async {
    final ctx = await pump(tester);
    var ran = 0;
    showDialog<void>(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (c, set) => NeptuneDialog<Object>(
          title: 'Sign out?',
          busyIndicator: ran > 0 ? const Text('BUSY') : null,
          actions: [
            NeptuneDialogAction(
                label: 'Sign out',
                primary: true,
                closes: false,
                onPressed: () => set(() => ran++)),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(ran, 1);
    expect(find.text('BUSY'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);
  });

  testWidgets('a long message at 200% text scrolls, the actions stay',
      (tester) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      theme: NeptuneTheme.light('neptune'),
      builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!),
      home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold();
      }),
    ));
    showNeptuneDialog<Object>(
        context: ctx,
        title: 'Stop this payment?',
        message: List.filled(40, 'Your bank will never ask for this code.').join(' '),
        actions: const [NeptuneDialogAction(label: 'Stop it', primary: true)]);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Stop it').hitTestable(), findsOneWidget);
  });
}
