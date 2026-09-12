// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The register composition (2.25.0): the ledger figure, grouped rows on
// hairlines, the review ledger and the paper welcome build under LTR + RTL,
// both brightnesses, and keep the promises their docs make.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  Widget host(Widget child,
          {TextDirection dir = TextDirection.ltr,
          Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: brightness == Brightness.light
            ? NeptuneTheme.light('proteus')
            : NeptuneTheme.dark('proteus'),
        home: Directionality(
          textDirection: dir,
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );

  Widget register() => Column(
        children: [
          const NeptuneLedgerFigure(
            label: 'Available balance',
            amount: '12,480.500',
            currency: 'LYD',
          ),
          NeptuneRegisterGroup(
            header: const NeptuneRegisterGroupHeader(
                title: 'Current', figure: '12,480.500'),
            rows: [
              NeptuneRegisterRow(
                title: 'Salary account',
                subtitle: '•••• 4821',
                figure: '10,000.000',
                onTap: () {},
              ),
              const NeptuneRegisterRow(
                title: 'Household',
                subtitle: '•••• 1188',
                figure: '2,480.500',
              ),
            ],
          ),
          const NeptuneLedger(
            figure: NeptuneLedgerFigure(label: 'Amount', amount: '250.000'),
            lines: [
              NeptuneLedgerLine(label: 'To', value: 'Lina Atiya'),
              NeptuneLedgerLine(label: 'Fee', value: '1.000', tabular: true),
              NeptuneLedgerLine(
                  label: 'Reference', value: 'TRX-2026-000114', valueLtr: true),
            ],
          ),
        ],
      );

  group('NeptuneLedgerFigure', () {
    test('splits the fraction only when it is all digits', () {
      expect(NeptuneLedgerFigure.splitFraction('12,480.500'),
          ('12,480', '.500'));
      expect(NeptuneLedgerFigure.splitFraction('1200'), ('1200', null));
      expect(NeptuneLedgerFigure.splitFraction('••••••'), ('••••••', null));
      expect(NeptuneLedgerFigure.splitFraction('12.5 LYD'), ('12.5 LYD', null));
      expect(NeptuneLedgerFigure.splitFraction('12.'), ('12.', null));
    });

    testWidgets('sets the integer part larger than the fraction, both tabular',
        (tester) async {
      await tester.pumpWidget(host(const NeptuneLedgerFigure(
          label: 'Total', amount: '12,480.500', currency: 'LYD')));
      final rich = tester.widget<Text>(find.byWidgetPredicate(
          (w) => w is Text && w.textSpan != null && w.textSpan!.toPlainText() == '12,480.500'));
      final spans = (rich.textSpan as TextSpan).children!.cast<TextSpan>();
      expect(spans.length, 2);
      expect(spans[0].style!.fontSize!, greaterThan(spans[1].style!.fontSize!));
      for (final s in spans) {
        expect(s.style!.fontFeatures, contains(const FontFeature.tabularFigures()));
      }
      // The eyebrow uppercases; the currency code is set apart, not inline.
      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.text('LYD'), findsOneWidget);
    });
  });

  group('register composition', () {
    for (final dir in TextDirection.values) {
      for (final b in Brightness.values) {
        testWidgets('builds under $dir / $b without exceptions', (tester) async {
          await tester.pumpWidget(host(register(), dir: dir, brightness: b));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(NeptuneHairline), findsWidgets);
        });
      }
    }

    testWidgets('figures sit at the end edge and stay LTR under RTL',
        (tester) async {
      await tester.pumpWidget(host(register(), dir: TextDirection.rtl));
      await tester.pumpAndSettle();
      final row = find.byType(NeptuneRegisterRow).first;
      final figure = find.descendant(of: row, matching: find.text('10,000.000'));
      // Under RTL the end edge is the LEFT edge of the screen.
      expect(tester.getTopLeft(figure).dx, lessThan(40));
      expect(tester.widget<Text>(figure).textDirection, TextDirection.ltr);
    });

    testWidgets('a group closes with a hairline and rules sit between rows',
        (tester) async {
      await tester.pumpWidget(host(register()));
      await tester.pumpAndSettle();
      final group = find.byType(NeptuneRegisterGroup);
      // Two rows: one rule between them, one closing the group.
      expect(find.descendant(of: group, matching: find.byType(NeptuneHairline)),
          findsNWidgets(2));
    });

    testWidgets('the row has no radius, fill or shadow of its own', (tester) async {
      await tester.pumpWidget(host(register()));
      await tester.pumpAndSettle();
      final row = find.byType(NeptuneRegisterRow).first;
      expect(find.descendant(of: row, matching: find.byType(Material)), findsNothing);
      expect(
          find.descendant(
              of: row,
              matching: find.byWidgetPredicate((w) =>
                  w is Container && w.decoration is BoxDecoration)),
          findsNothing);
    });
  });

  group('NeptunePaperWelcome', () {
    testWidgets('paints the paper ground, the rule and the eyebrow name',
        (tester) async {
      await tester.pumpWidget(host(
        SizedBox(
          height: 640,
          child: NeptunePaperWelcome(
            lockup: const FlutterLogo(size: 72),
            name: 'Nuran Bank',
            primaryAction: FilledButton(onPressed: () {}, child: const Text('Log in')),
            secondaryAction:
                OutlinedButton(onPressed: () {}, child: const Text('Open an account')),
            footer: const Text('Terms'),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final scheme = NeptuneTheme.light('proteus').colorScheme;
      final ground = tester.widget<ColoredBox>(find.byType(ColoredBox).first);
      expect(ground.color, scheme.surface);
      expect(find.text('NURAN BANK'), findsOneWidget);
      expect(find.byType(NeptuneHairline), findsOneWidget);
      // The rule is short and centred under the lockup, not a full-width divider.
      final rule = tester.getSize(find.byType(NeptuneHairline));
      expect(rule.width, 40);
      expect(rule.height, 1);
      // No ambient backdrop, no motif: the paper shell draws nothing but the lockup.
      expect(find.byType(NeptuneAmbientBackdrop), findsNothing);
      expect(find.byType(NeptuneMotifLayer), findsNothing);
    });
  });
}
