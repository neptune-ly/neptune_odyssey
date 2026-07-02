// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The nine published templates build under LTR + RTL with no exceptions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  Widget host(Widget child, TextDirection dir) => MaterialApp(
        theme: NeptuneTheme.light('triton'),
        home: Directionality(
            textDirection: dir, child: Scaffold(body: child)),
      );

  final templates = <String, Widget>{
    'auth-credentials': const NeptuneAuthTemplate(
        brandInitial: 'N', brandName: 'Neptune'),
    'auth-otp': const NeptuneAuthTemplate(
        brandInitial: 'N', brandName: 'Neptune', step: 1),
    'kyc': const NeptuneKycTemplate(notice: 'Your data is encrypted.'),
    'dashboard': NeptuneDashboardTemplate(
      balanceCaption: '•••• 4821',
      actions: [
        NeptuneQuickAction(icon: Icons.north_east, label: 'Send', onTap: () {}),
        NeptuneQuickAction(icon: Icons.qr_code, label: 'Pay', onTap: () {}),
      ],
      statPair: ('Spending', '3,540', 'LYD', '−2.1%'),
      transactions: const [
        NeptuneTxData('Salary', 'Today · Transfer', '+3,200.00 LYD',
            credit: true),
        NeptuneTxData('Grocery Market', 'Today · Card', '−86.40 LYD'),
      ],
    ),
    'cards': const NeptuneCardsTemplate(
      cards: [
        NeptuneCardData(
            holder: 'LINA ATIYA',
            last4: '4821',
            expiry: '08/27',
            scheme: 'VISA'),
        NeptuneCardData(
            holder: 'LINA ATIYA',
            last4: '6642',
            expiry: '01/29',
            scheme: 'VIRTUAL',
            virtual: true),
      ],
      transactions: [
        NeptuneTxData('Coffee Bar', 'Yesterday · Card', '−4.50 LYD'),
      ],
    ),
    'transfer-amount': NeptuneTransferTemplate(
      payees: const [
        NeptunePayeeData('Sara Nuri', '•••• 7390'),
        NeptunePayeeData('Omar K.', '•••• 1204'),
      ],
      onPayee: (_) {},
      onContinue: () {},
    ),
    'transfer-review': const NeptuneTransferTemplate(
        step: 1, payees: [NeptunePayeeData('Sara Nuri', '•••• 7390')]),
    'transfer-success': const NeptuneTransferTemplate(
        step: 2,
        outcome: NeptuneFlowStatus.success,
        payees: [NeptunePayeeData('Sara Nuri', '•••• 7390')]),
    'wallet': NeptuneWalletTemplate(
      actions: [
        NeptuneQuickAction(icon: Icons.qr_code, label: 'Pay', onTap: () {}),
        NeptuneQuickAction(icon: Icons.add, label: 'Top up', onTap: () {}),
      ],
      merchants: const [('Coffee Bar', 'Card', '−4.50 LYD', 'Today')],
      voucher: ('Cashback', 'LYD 10', 'NPT-10', 'Aug 27'),
    ),
    'corporate': NeptuneCorporateTemplate(
      subtitle: 'Pending your decision',
      approvals: const [
        NeptuneApprovalData('Payroll batch', '42 payments', 'LYD 18,200'),
      ],
      onDecide: (_, __) {},
      batch: ('June payroll', '42', 'LYD 18,200', 'Pending'),
      audit: const [('Lina A.', 'Approved transfer', '12:04')],
    ),
  };

  for (final entry in templates.entries) {
    testWidgets('template ${entry.key} builds LTR + RTL', (tester) async {
      for (final dir in TextDirection.values) {
        await tester.pumpWidget(host(entry.value, dir));
        await tester.pump(const Duration(milliseconds: 350));
        expect(tester.takeException(), isNull, reason: '${entry.key} $dir');
        await tester.pumpWidget(const SizedBox());
      }
    });
  }
}
