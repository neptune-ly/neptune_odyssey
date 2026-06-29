// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Smoke/build tests for the widget set: every widget must build under a real
// NeptuneTheme (light + dark + RTL) with no exceptions, proving theme parity.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

Widget _host(
  Widget child, {
  String brand = 'neptune',
  Brightness brightness = Brightness.light,
  TextDirection dir = TextDirection.ltr,
  bool scroll = true,
}) {
  final body = scroll ? SingleChildScrollView(child: child) : child;
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: brightness == Brightness.light
        ? NeptuneTheme.light(brand)
        : NeptuneTheme.dark(brand),
    home: Directionality(
      textDirection: dir,
      child: Scaffold(body: SafeArea(child: body)),
    ),
  );
}

Widget _dashboard() => Column(
      children: [
        const NeptuneBalanceCard(
          label: 'Available balance',
          amount: 'LYD 12,480.50',
          caption: '•••• 4821',
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: NeptuneStatCard(label: 'Income', value: '9,120', unit: 'LYD', delta: '+8.2%')),
            SizedBox(width: 12),
            Expanded(child: NeptuneStatCard(label: 'Spending', value: '3,540', unit: 'LYD', delta: '-2.1%')),
          ],
        ),
        const SizedBox(height: 12),
        const NeptuneCardArt(
          holder: 'LINA ATIYA',
          last4: '4821',
          expiry: '08/27',
          scheme: 'Visa',
          selected: true,
        ),
        const SizedBox(height: 12),
        NeptuneQuickActions(
          actions: [
            NeptuneQuickAction(icon: Icons.north_east, label: 'Send', onTap: () {}),
            NeptuneQuickAction(icon: Icons.account_balance_wallet_outlined, label: 'Request', onTap: () {}),
            NeptuneQuickAction(icon: Icons.qr_code_rounded, label: 'Pay', onTap: () {}),
            NeptuneQuickAction(icon: Icons.add_card_outlined, label: 'Top up', onTap: () {}),
          ],
        ),
        const SizedBox(height: 12),
        NeptuneButton(label: 'Filled', onPressed: () {}),
        NeptuneButton(label: 'Tonal', variant: NeptuneButtonStyle.tonal, onPressed: () {}),
        NeptuneButton(label: 'Outlined', variant: NeptuneButtonStyle.outlined, icon: Icons.add, onPressed: () {}),
        NeptuneButton(label: 'Text', variant: NeptuneButtonStyle.text, onPressed: () {}),
        NeptuneCta(label: 'Get started', arrow: true, onPressed: () {}),
        const SizedBox(height: 12),
        Row(
          children: const [
            NeptuneChip(label: 'Selected', selected: true),
            SizedBox(width: 8),
            NeptuneStatusChip(label: 'Active', tone: NeptuneStatusTone.success),
            SizedBox(width: 8),
            NeptuneStatusChip(label: 'Pending', tone: NeptuneStatusTone.warning),
          ],
        ),
        const SizedBox(height: 12),
        const NeptuneSection(
          title: 'Recent activity',
          description: 'Last 30 days',
          child: NeptuneTransactionRow(
            title: 'Salary',
            subtitle: 'Today · Transfer',
            amount: '+3,200.00 LYD',
            isCredit: true,
          ),
        ),
        const NeptuneAccountTile(name: 'Everyday', maskedNumber: '•••• 4821', balance: 'LYD 12,480.50'),
      ],
    );

void main() {
  testWidgets('dashboard widgets build (light, neptune)', (tester) async {
    await tester.pumpWidget(_host(_dashboard()));
    expect(find.byType(NeptuneBalanceCard), findsOneWidget);
    expect(find.byType(NeptuneCardArt), findsOneWidget);
    expect(find.byType(NeptuneStatCard), findsNWidgets(2));
    expect(find.byType(NeptuneQuickAction), findsNWidgets(4));
    expect(find.byType(NeptuneCta), findsOneWidget);
    expect(find.byType(NeptuneStatusChip), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard builds in dark + RTL across all four brands', (tester) async {
    for (final brand in const ['neptune', 'triton', 'nereid', 'proteus']) {
      await tester.pumpWidget(_host(
        _dashboard(),
        brand: brand,
        brightness: Brightness.dark,
        dir: TextDirection.rtl,
      ));
      expect(tester.takeException(), isNull, reason: 'brand=$brand dark/RTL');
    }
  });

  testWidgets('NeptuneAppBar + NeptuneDock build', (tester) async {
    await tester.pumpWidget(_host(
      Column(
        children: [
          NeptuneAppBar(
            title: 'Hi, Lina',
            leading: const Icon(Icons.account_circle_outlined),
            actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))],
          ),
          const Spacer(),
          NeptuneDock(
            items: [
              NeptuneDockItem(icon: Icons.home_rounded, label: 'Home', active: true, onTap: () {}),
              NeptuneDockItem(icon: Icons.credit_card, label: 'Cards', onTap: () {}),
              NeptuneDockItem(icon: Icons.qr_code_rounded, label: 'Pay', onTap: () {}),
              NeptuneDockItem(icon: Icons.person_outline, label: 'Profile', onTap: () {}),
            ],
          ),
        ],
      ),
      scroll: false,
    ));
    expect(find.byType(NeptuneDock), findsOneWidget);
    expect(find.text('Hi, Lina'), findsOneWidget);
    expect(find.byType(NeptuneDockItem), findsNothing); // data class, not a widget in the tree
    expect(tester.takeException(), isNull);
  });

  testWidgets('NeptuneOnboarding builds', (tester) async {
    await tester.pumpWidget(_host(
      SizedBox(
        height: 640,
        child: NeptuneOnboarding(
          eyebrow: 'NEPTUNE ODYSSEY',
          headline: const Text('Your money, everywhere you are.'),
          supporting: 'Open an account in minutes.',
          steps: 3,
          activeStep: 0,
          cta: NeptuneCta(label: 'Get started', arrow: true, onPressed: () {}),
        ),
      ),
      scroll: false,
    ));
    expect(find.byType(NeptuneOnboarding), findsOneWidget);
    expect(find.text('Your money, everywhere you are.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
