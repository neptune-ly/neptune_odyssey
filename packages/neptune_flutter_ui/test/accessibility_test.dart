// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Screen-reader contract for the widget set (2.23.1). Every test names the
// assertion that FAILS on 2.23.0: an unlabelled tap target, a colour-only
// state, an amount spoken as a digit string, a change nobody is told about.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'dart:ui' show Tristate, CheckedState;
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// A host that speaks Arabic-flavoured test strings so the test can prove the
/// LIBRARY reads the host vocabulary rather than its English fallback.
const _hostStrings = NeptuneA11yStrings(
  credit: 'ARABIC_CREDIT',
  debit: 'ARABIC_DEBIT',
  balance: 'ARABIC_BALANCE',
  amount: 'ARABIC_AMOUNT',
  iban: 'ARABIC_IBAN',
  ibanValid: 'ARABIC_IBAN_VALID',
  ibanInvalid: 'ARABIC_IBAN_INVALID',
  selectCurrency: 'ARABIC_SELECT_CURRENCY',
  currency: 'ARABIC_CURRENCY',
  decrease: 'ARABIC_DECREASE',
  increase: 'ARABIC_INCREASE',
  backspace: 'ARABIC_BACKSPACE',
  decimalPoint: 'ARABIC_DECIMAL',
  loading: 'ARABIC_LOADING',
  success: 'ARABIC_SUCCESS',
  rejected: 'ARABIC_REJECTED',
  processing: 'ARABIC_PROCESSING',
  info: 'ARABIC_INFO',
  warning: 'ARABIC_WARNING',
  error: 'ARABIC_ERROR',
  selected: 'ARABIC_SELECTED',
  share: 'ARABIC_SHARE',
  ok: 'ARABIC_OK',
  search: 'ARABIC_SEARCH',
  close: 'ARABIC_CLOSE',
  remove: 'ARABIC_REMOVE',
  from: 'ARABIC_FROM',
  to: 'ARABIC_TO',
  fee: 'ARABIC_FEE',
  total: 'ARABIC_TOTAL',
  otpDigit: _otpDigit,
  step: _step,
  stepsProgress: _stepsProgress,
  page: _page,
  previousPage: 'ARABIC_PREV',
  nextPage: 'ARABIC_NEXT',
  endingIn: _endingIn,
  percent: _percent,
  rating: _rating,
  more: _more,
  up: 'ARABIC_UP',
  down: 'ARABIC_DOWN',
  money: _money,
  currencyName: _currencyName,
);

String _currencyName(String c) => 'ARABIC_CCY_$c';

String _otpDigit(int i, int n) => 'ARABIC_DIGIT $i/$n';
String _step(int i, int n, String l) => 'ARABIC_STEP $i/$n $l';
String _stepsProgress(int d, int n) => 'ARABIC_DONE $d/$n';
String _page(int i, int n) => 'ARABIC_PAGE $i/$n';
String _endingIn(String d) => 'ARABIC_ENDING $d';
String _percent(int p) => 'ARABIC_PERCENT $p';
String _rating(int v, int m) => 'ARABIC_STARS $v/$m';
String _more(int n) => 'ARABIC_MORE $n';
String _money(String a, String? c) => 'ARABIC_MONEY $a ${c ?? ''}'.trim();

Widget _host(Widget child, {bool reducedMotion = false, bool withStrings = true}) {
  final body = Scaffold(body: Center(child: child));
  return MaterialApp(
    theme: NeptuneTheme.light('neptune'),
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
      child: withStrings
          ? NeptuneAccessibility(strings: _hostStrings, child: app!)
          : app!,
    ),
    home: body,
  );
}

SemanticsNode _nodeWithLabel(WidgetTester tester, Pattern label) =>
    tester.getSemantics(find.bySemanticsLabel(label));

/// Reads a flag through the non-deprecated [SemanticsNode.flagsCollection].
extension _Flags on SemanticsNode {
  bool get isButton => flagsCollection.isButton;
  bool get isTextField => flagsCollection.isTextField;
  bool get isLiveRegion => flagsCollection.isLiveRegion;
  bool get isSelected => flagsCollection.isSelected == Tristate.isTrue;
  bool get isEnabled => flagsCollection.isEnabled == Tristate.isTrue;
  bool get hasEnabledState => flagsCollection.isEnabled != Tristate.none;
  bool get isChecked => flagsCollection.isChecked == CheckedState.isTrue;
  bool get hasCheckedState => flagsCollection.isChecked != CheckedState.none;
  bool get isExpanded => flagsCollection.isExpanded == Tristate.isTrue;
}

void main() {
  setUpAll(() => NeptuneTheme.debugSkipFontLoading = true);

  group('vocabulary', () {
    testWidgets('the English fallback is used when no host strings are mounted',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const NeptuneTransactionRow(title: 'Coffee', amount: '12.500', currency: 'LYD'),
        withStrings: false,
      ));
      final node = _nodeWithLabel(tester, RegExp('Coffee'));
      expect(node.label, 'Coffee, debit, 12.500 LYD');
      handle.dispose();
    });

    testWidgets('host strings replace every spoken word - never English on an Arabic screen',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const NeptuneTransactionRow(title: 'Coffee', amount: '12.500', currency: 'LYD'),
      ));
      final node = _nodeWithLabel(tester, RegExp('Coffee'));
      expect(node.label, 'Coffee, ARABIC_DEBIT, ARABIC_MONEY 12.500 LYD');
      expect(node.label, isNot(contains('debit')));
      handle.dispose();
    });
  });

  group('buttons', () {
    testWidgets('NeptuneCta has the button role, its label and its enabled state',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(NeptuneCta(label: 'Send money', onPressed: () {})));
      final node = _nodeWithLabel(tester, 'Send money');
      // Fails on 2.23.0: an InkWell carries no button flag.
      expect(node.isButton, isTrue);
      expect(node.isEnabled, isTrue);
      handle.dispose();
    });

    testWidgets('a disabled NeptuneCta is announced disabled, not missing',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneCta(label: 'Send money')));
      final node = _nodeWithLabel(tester, 'Send money');
      expect(node.hasEnabledState, isTrue);
      expect(node.isEnabled, isFalse);
      handle.dispose();
    });

    testWidgets('a busy NeptuneButton keeps its name and says loading',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneButton(label: 'Confirm', busy: true)));
      // Fails on 2.23.0: the spinner replaced the label and the button was
      // an anonymous "button, disabled".
      expect(find.bySemanticsLabel('Confirm, ARABIC_LOADING'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a busy NeptunePrimaryButton keeps its name and says loading',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptunePrimaryButton(label: 'Confirm', busy: true)));
      expect(find.bySemanticsLabel('Confirm, ARABIC_LOADING'), findsOneWidget);
      handle.dispose();
    });
  });

  group('money is spoken, not spelled', () {
    testWidgets('NeptuneAccountTile is ONE stop: name, masked number, balance as money',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(NeptuneAccountTile(
        name: 'Salary',
        maskedNumber: '•••• 4821',
        balance: '12,480.500',
        currency: 'LYD',
        onTap: () {},
      )));
      final node = _nodeWithLabel(tester, RegExp('Salary'));
      expect(node.label,
          'Salary, ARABIC_ENDING 4 8 2 1, ARABIC_BALANCE ARABIC_MONEY 12,480.500 LYD');
      expect(node.isButton, isTrue);
      // The three visible Texts must not ALSO be exposed as separate stops.
      expect(find.bySemanticsLabel('12,480.500'), findsNothing);
      handle.dispose();
    });

    testWidgets('NeptuneTransactionRow says credit or debit and shows a sign - never colour alone',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const Column(children: [
        NeptuneTransactionRow(title: 'Salary', amount: '3,000.000', isCredit: true),
        NeptuneTransactionRow(title: 'Rent', amount: '1,200.000'),
      ])));
      expect(_nodeWithLabel(tester, RegExp('Salary')).label,
          'Salary, ARABIC_CREDIT, ARABIC_MONEY 3,000.000');
      expect(_nodeWithLabel(tester, RegExp('Rent')).label,
          'Rent, ARABIC_DEBIT, ARABIC_MONEY 1,200.000');
      // Visual sign: a customer who cannot see green still sees + and -.
      expect(find.text('+3,000.000'), findsOneWidget);
      expect(find.text('-1,200.000'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('NeptuneBalanceCard is a live region carrying the balance as money',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneBalanceCard(
        label: 'Available',
        amount: '9,120.000',
        currency: 'LYD',
        caption: '•••• 1234',
      )));
      final node = _nodeWithLabel(tester, RegExp('Available'));
      expect(node.label, 'Available, ARABIC_MONEY 9,120.000 LYD, ARABIC_ENDING 1 2 3 4');
      expect(node.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('NeptuneTransferReview rows and total are label: money pairs',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneTransferReview(
        fromLabel: 'Salary',
        toLabel: 'Ahmed',
        amount: '1,250.000',
        fee: '1.500',
        total: '1,251.500',
        currency: 'LYD',
      )));
      expect(find.bySemanticsLabel('ARABIC_FROM: Salary'), findsOneWidget);
      expect(find.bySemanticsLabel('ARABIC_TO: Ahmed'), findsOneWidget);
      expect(find.bySemanticsLabel('ARABIC_AMOUNT: ARABIC_MONEY 1,250.000 LYD'),
          findsOneWidget);
      expect(find.bySemanticsLabel('ARABIC_FEE: ARABIC_MONEY 1.500 LYD'), findsOneWidget);
      expect(find.bySemanticsLabel('ARABIC_TOTAL: ARABIC_MONEY 1,251.500 LYD'),
          findsOneWidget);
      // The captions are localised through the host, never hardcoded 'From'.
      expect(find.text('ARABIC_FROM'), findsOneWidget);
      expect(find.text('From'), findsNothing);
      handle.dispose();
    });

    testWidgets('NeptuneSuccess announces success and the amount as money',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneSuccess(
        title: 'Sent',
        amount: '500.000',
        currency: 'LYD',
        subtitle: 'to Ahmed',
      )));
      final node = _nodeWithLabel(tester, RegExp('Sent'));
      expect(node.label, 'ARABIC_SUCCESS: Sent, ARABIC_MONEY 500.000 LYD, to Ahmed');
      expect(node.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('NeptuneStatCard speaks the delta direction as a word',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneStatCard(
          label: 'Spending', value: '3,540', unit: 'LYD', delta: '-2.1%')));
      expect(find.bySemanticsLabel('Spending, ARABIC_MONEY 3,540 LYD, ARABIC_DOWN 2.1%'),
          findsOneWidget);
      handle.dispose();
    });
  });

  group('fields', () {
    testWidgets('NeptuneTextField label merges into the text field node',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneTextField(label: 'Recipient name')));
      final node = _nodeWithLabel(tester, 'Recipient name');
      // Fails on 2.23.0: the label was a separate text stop before an
      // unnamed edit box.
      expect(node.isTextField, isTrue);
      handle.dispose();
    });

    testWidgets('NeptuneTextField error is a live region spoken with the error word',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
          const NeptuneTextField(label: 'Amount', errorText: 'Exceeds balance')));
      final node = _nodeWithLabel(tester, 'ARABIC_ERROR: Exceeds balance');
      expect(node.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('NeptuneAmountInput names the field and its currency',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneAmountInput(value: '', currency: 'LYD')));
      // The empty field's "0.00" hint joins the label, so match the prefix.
      final node = _nodeWithLabel(tester, RegExp('^ARABIC_AMOUNT, ARABIC_CCY_LYD'));
      expect(node.isTextField, isTrue);
      handle.dispose();
    });

    testWidgets('NeptuneIbanField announces valid / invalid, not just a green or red glyph',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
          _host(const NeptuneIbanField(value: 'LY83027000000123', valid: false)));
      final verdict = _nodeWithLabel(tester, 'ARABIC_IBAN_INVALID');
      expect(verdict.isLiveRegion, isTrue);
      expect(_nodeWithLabel(tester, 'ARABIC_IBAN').isTextField, isTrue);
      handle.dispose();
    });

    testWidgets('NeptuneCurrencyField selector is a named button in the host language',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneCurrencyField(
          amount: '', currency: 'LYD', currencies: ['LYD', 'USD'])));
      final node = _nodeWithLabel(tester, 'ARABIC_SELECT_CURRENCY');
      // Fails on 2.23.0: tooltip was the hardcoded English 'Select currency'.
      expect(node.isButton, isTrue);
      expect(node.value, 'LYD');
      expect(find.bySemanticsLabel('Select currency'), findsNothing);
      handle.dispose();
    });

    testWidgets('NeptuneStepperInput controls are named in the host language',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(NeptuneStepperInput(value: 2, onChanged: (_) {})));
      // An IconButton exposes its tooltip, which Flutter's Android and iOS
      // embeddings fold into the spoken description.
      expect(find.byTooltip('ARABIC_DECREASE'), findsOneWidget);
      expect(find.byTooltip('ARABIC_INCREASE'), findsOneWidget);
      expect(find.byTooltip('Decrease'), findsNothing);
      handle.dispose();
    });

    testWidgets('NeptuneDateField is one button carrying its label and value',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(NeptuneDateField(
          label: 'Transfer date', value: DateTime(2026, 9, 12))));
      final node = _nodeWithLabel(tester, 'Transfer date');
      expect(node.isButton, isTrue);
      expect(node.value, '2026-09-12');
      handle.dispose();
    });
  });

  group('OTP and keypad', () {
    testWidgets('every OTP cell says which digit it is', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneOtpInput(length: 6)));
      for (var i = 1; i <= 6; i++) {
        final node = _nodeWithLabel(tester, 'ARABIC_DIGIT $i/6');
        expect(node.isTextField, isTrue);
      }
      handle.dispose();
    });

    testWidgets('keypad backspace and decimal point are named buttons',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneAmountKeypad()));
      // Fails on 2.23.0: backspace was an unlabelled icon tile.
      expect(_nodeWithLabel(tester, 'ARABIC_BACKSPACE').isButton, isTrue);
      expect(_nodeWithLabel(tester, 'ARABIC_DECIMAL').isButton, isTrue);
      expect(_nodeWithLabel(tester, '7').isButton, isTrue);
      handle.dispose();
    });
  });

  group('selection and navigation state', () {
    testWidgets('NeptuneDock items are buttons with a selected state',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(NeptuneDock(items: [
        NeptuneDockItem(icon: Icons.home, label: 'Home', active: true, onTap: () {}),
        NeptuneDockItem(icon: Icons.list, label: 'Accounts', onTap: () {}),
      ])));
      final home = _nodeWithLabel(tester, 'Home');
      final accounts = _nodeWithLabel(tester, 'Accounts');
      // Fails on 2.23.0: no selected flag, no button role.
      expect(home.isSelected, isTrue);
      expect(home.isButton, isTrue);
      expect(accounts.isSelected, isFalse);
      handle.dispose();
    });

    testWidgets('NeptuneTabs expose the selected tab', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(NeptuneTabs(
          tabs: const ['Sent', 'Received'], index: 1, onChanged: (_) {})));
      expect(_nodeWithLabel(tester, 'Received').isSelected, isTrue);
      expect(_nodeWithLabel(tester, 'Sent').isSelected, isFalse);
      handle.dispose();
    });

    testWidgets('NeptuneCheckboxTile is one checkbox named by its label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(NeptuneCheckboxTile(
          label: 'Save payee', value: true, onChanged: (_) {})));
      final node = _nodeWithLabel(tester, 'Save payee');
      expect(node.hasCheckedState, isTrue);
      expect(node.isChecked, isTrue);
      // Fails on 2.23.0: the inner NeptuneCheckbox was a second, anonymous
      // checked node beside the row.
      expect(
        tester.semantics.simulatedAccessibilityTraversal(),
        isNot(contains(predicate<SemanticsNode>(
            (n) => n.hasCheckedState && n.label.isEmpty))),
      );
      handle.dispose();
    });

    testWidgets('a disabled NeptuneCheckbox reads as disabled - `enabled` was the VALUE before',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneCheckbox(value: true)));
      final node = tester.getSemantics(find.byType(NeptuneCheckbox));
      expect(node.isChecked, isTrue);
      expect(node.isEnabled, isFalse);
      handle.dispose();
    });

    testWidgets('NeptuneMethodRow and NeptuneBeneficiaryTile carry their selection',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(Column(children: [
        NeptuneMethodRow(icon: Icons.bolt, title: 'Instant', selected: true, onTap: () {}),
        NeptuneBeneficiaryTile(name: 'Ahmed Ali', account: '•••• 9876', selected: true, onTap: () {}),
      ])));
      expect(_nodeWithLabel(tester, 'Instant').isChecked, isTrue);
      final ben = _nodeWithLabel(tester, RegExp('Ahmed Ali'));
      expect(ben.label, 'Ahmed Ali, ARABIC_ENDING 9 8 7 6');
      expect(ben.isSelected, isTrue);
      handle.dispose();
    });

    testWidgets('NeptunePagination arrows and pills are named and 48dp',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(NeptunePagination(page: 1, pageCount: 4, onChanged: (_) {})));
      expect(_nodeWithLabel(tester, 'ARABIC_PREV').isButton, isTrue);
      expect(_nodeWithLabel(tester, 'ARABIC_NEXT').isButton, isTrue);
      expect(_nodeWithLabel(tester, 'ARABIC_PAGE 2/4').isSelected, isTrue);
      expect(_nodeWithLabel(tester, 'ARABIC_PREV').rect.height, greaterThanOrEqualTo(48));
      expect(_nodeWithLabel(tester, 'ARABIC_PAGE 2/4').rect.height, greaterThanOrEqualTo(48));
      handle.dispose();
    });

    testWidgets('NeptuneAccordion header exposes expanded', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneAccordion(panels: [
        NeptuneAccordionPanel(title: 'Fees', child: Text('body'), initiallyExpanded: true),
      ])));
      expect(_nodeWithLabel(tester, 'Fees').isExpanded, isTrue);
      handle.dispose();
    });

    testWidgets('NeptuneTag remove is a named 48dp button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(NeptuneTag(label: 'Rent', onRemove: () {})));
      final node = _nodeWithLabel(tester, 'ARABIC_REMOVE, Rent');
      // Fails on 2.23.0: an 18dp unlabelled close glyph.
      expect(node.isButton, isTrue);
      expect(node.rect.width, greaterThanOrEqualTo(48));
      expect(node.rect.height, greaterThanOrEqualTo(48));
      handle.dispose();
    });

    testWidgets('NeptuneStepper says where the customer is', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneStepper(
          steps: ['Details', 'Review', 'Confirm'], active: 1)));
      final node = _nodeWithLabel(tester, RegExp('ARABIC_STEP'));
      expect(node.label, 'ARABIC_STEP 2/3 Review, ARABIC_DONE 1/3');
      expect(node.isLiveRegion, isTrue);
      handle.dispose();
    });
  });

  group('changes are announced', () {
    testWidgets('NeptuneAlert speaks its tone first and is a live region',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneAlert(
          message: 'Transfer refused', tone: NeptuneAlertTone.danger)));
      final node = _nodeWithLabel(tester, 'ARABIC_ERROR: Transfer refused');
      expect(node.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('NeptuneToast message is a live region', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneToast(message: 'Copied')));
      expect(_nodeWithLabel(tester, 'Copied').isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('NeptuneStatusMotion says success / rejected - the glyph is painted, not written',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneStatusMotion(status: NeptuneFlowStatus.success),
          reducedMotion: true));
      expect(_nodeWithLabel(tester, 'ARABIC_SUCCESS').isLiveRegion, isTrue);
      await tester.pumpWidget(_host(const NeptuneStatusMotion(status: NeptuneFlowStatus.rejected),
          reducedMotion: true));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('ARABIC_REJECTED'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('skeletons say loading once and expose no bones', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneSkeletonRow(count: 3)));
      expect(find.bySemanticsLabel('ARABIC_LOADING'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('loaders are named loading', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneSpinner(), reducedMotion: true));
      expect(find.bySemanticsLabel('ARABIC_LOADING'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('NeptuneProgressBar exposes its value as a percentage',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const NeptuneProgressBar(value: 0.4, label: 'Upload')));
      expect(_nodeWithLabel(tester, 'Upload').value, 'ARABIC_PERCENT 40');
      handle.dispose();
    });
  });

  group('reduced motion', () {
    testWidgets('the dock selection jumps to its end state on the first frame',
        (tester) async {
      await tester.pumpWidget(_host(
        NeptuneDock(items: [
          NeptuneDockItem(icon: Icons.home, label: 'Home', active: true, onTap: () {}),
          NeptuneDockItem(icon: Icons.list, label: 'Accounts', onTap: () {}),
        ]),
        reducedMotion: true,
      ));
      final slide = tester.widgetList<AnimatedSlide>(find.byType(AnimatedSlide)).first;
      // Fails on 2.23.0: the brand duration ran regardless of the OS setting.
      expect(slide.duration, Duration.zero);
    });

    testWidgets('the CTA press scale collapses under reduced motion', (tester) async {
      await tester.pumpWidget(_host(NeptuneCta(label: 'Go', onPressed: () {}), reducedMotion: true));
      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.duration, Duration.zero);
    });
  });

  group('helpers', () {
    testWidgets('maskedNumber spaces digits and prefixes ending-in only when masked',
        (tester) async {
      late String masked;
      late String plain;
      await tester.pumpWidget(_host(Builder(builder: (context) {
        masked = NeptuneAccessibility.maskedNumber(context, '**** 4821');
        plain = NeptuneAccessibility.maskedNumber(context, '4821');
        return const SizedBox();
      })));
      expect(masked, 'ARABIC_ENDING 4 8 2 1');
      expect(plain, '4 8 2 1');
    });
  });
}
