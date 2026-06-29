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
        const Row(
          children: [
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
        const Row(
          children: [
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
  // Keep the google_fonts runtime loader offline in tests; build/theme checks
  // only need the family names, not the downloaded glyphs.
  NeptuneTheme.debugSkipFontLoading = true;

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

  testWidgets('extended widget set builds (money / movement / data-viz / corporate / wallet / shell)',
      (tester) async {
    await tester.pumpWidget(_host(Column(
      children: [
        // money inputs
        const NeptuneAmountInput(value: '1,250.00', currency: 'LYD'),
        const NeptuneCurrencyField(amount: '1,250.00', currency: 'LYD', currencies: ['LYD', 'USD']),
        const NeptuneIbanField(value: 'LY83 0020 0001 2345', valid: true),
        const NeptuneOtpInput(length: 6),
        const NeptunePinInput(length: 4),
        SizedBox(height: 280, child: NeptuneAmountKeypad(onKey: (_) {}, onBackspace: () {})),
        // movement
        const NeptuneStepper(steps: ['Amount', 'Review', 'Done'], active: 1),
        const NeptuneTransferReview(
          fromLabel: 'Everyday •••• 4821',
          toLabel: 'Sara N.',
          amount: '250.00',
          fee: '0.00',
          total: '250.00',
          currency: 'LYD',
        ),
        NeptuneMethodRow(icon: Icons.account_balance, title: 'Bank transfer', subtitle: 'NUMO', selected: true, onTap: () {}),
        NeptuneBeneficiaryTile(name: 'Sara Nuri', account: '•••• 7390', selected: true, onTap: () {}),
        const NeptuneSuccess(title: 'Sent!', amount: 'LYD 250.00', subtitle: 'To Sara N.'),
        NeptuneReceipt(
          title: 'Receipt',
          rows: const [(label: 'Amount', value: 'LYD 250.00'), (label: 'Fee', value: 'LYD 0.00')],
          onShare: () {},
        ),
        // data-viz
        const SizedBox(width: 200, child: NeptuneSparkline(points: [3, 4, 4, 6, 5, 7, 8])),
        const NeptuneDonut(segments: [3, 2, 1], centerLabel: '6'),
        const NeptuneLimitMeter(value: 0.62, label: 'Monthly spend', amount: '620 / 1,000 LYD'),
        const NeptuneTrend(value: 8.2),
        const NeptuneTrend(value: 2.1, down: true),
        // corporate
        NeptuneApprovalItem(title: 'Payroll batch', subtitle: '42 payments', amount: 'LYD 18,200', onApprove: () {}, onReject: () {}),
        const NeptuneBatchCard(title: 'June payroll', count: '42', total: 'LYD 18,200', status: 'Pending'),
        const NeptuneAuditRow(actor: 'Lina A.', action: 'Approved transfer', time: '12:04'),
        NeptuneUserRow(name: 'Omar K.', role: 'Approver', status: 'Active', onTap: () {}),
        NeptunePermissionToggle(label: 'Can approve', description: 'Up to LYD 50k', value: true, onChanged: (_) {}),
        const NeptuneWorkflowStatus(label: 'Review', step: 2, total: 3),
        // wallet-pay
        const NeptuneMerchantRow(name: 'Grocery Market', category: 'Card', amount: '-86.40 LYD', time: 'Today'),
        const NeptuneVoucherCard(title: 'Cashback', value: 'LYD 10', code: 'NPT-10', expiry: 'Aug 27'),
        const NeptuneQrPay(amount: 'LYD 45.00', merchant: 'Coffee Bar'),
        NeptuneTopupRow(label: 'Top up', sublabel: 'Card', amount: 'LYD 50', onTap: () {}),
        const NeptuneTierBadge(tier: 'Gold'),
        // shell + feedback
        const NeptunePageHeader(title: 'Accounts', subtitle: 'All your money'),
        const NeptuneSearchField(hint: 'Search'),
        const NeptuneEmptyState(icon: Icons.inbox_outlined, title: 'Nothing yet', message: 'Your activity will show here.'),
        const NeptuneAlert(message: 'Transfer completed.', tone: NeptuneAlertTone.success, title: 'Done'),
        const NeptuneBanner(message: 'Scheduled maintenance tonight.'),
        const NeptuneSkeleton(width: 160),
      ],
    )));
    expect(find.byType(NeptuneSparkline), findsOneWidget);
    expect(find.byType(NeptuneDonut), findsOneWidget);
    expect(find.byType(NeptuneTransferReview), findsOneWidget);
    expect(find.byType(NeptuneApprovalItem), findsOneWidget);
    expect(find.byType(NeptuneVoucherCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('structural widgets build (data-table / shell-nav / card-controls / toast)',
      (tester) async {
    await tester.pumpWidget(_host(Column(
      children: [
        const NeptuneDataTable(
          caption: 'Recent',
          columns: [
            NeptuneColumn('Merchant'),
            NeptuneColumn('Date'),
            NeptuneColumn('Amount', numeric: true),
          ],
          rows: [
            ['Coffee Bar', 'Today', '4.50'],
            ['Grocery Market', 'Yesterday', '86.40'],
          ],
        ),
        const SizedBox(height: 12),
        NeptuneToolbar(
          start: [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))],
          center: const [Text('Accounts')],
          end: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
        ),
        const SizedBox(height: 12),
        NeptuneSideNav(
          children: [
            NeptuneSideNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', active: true, onTap: () {}),
            NeptuneSideNavItem(icon: Icons.swap_horiz, label: 'Transfers', trailing: const NeptuneStatusChip(label: '3', tone: NeptuneStatusTone.neutral), onTap: () {}),
            const NeptuneSideNavItem(icon: Icons.settings_outlined, label: 'Settings', enabled: false),
          ],
        ),
        const SizedBox(height: 12),
        NeptuneCardControls(frozen: true, onControl: (_) {}),
        const SizedBox(height: 12),
        NeptuneAddCard(onTap: () {}),
        const SizedBox(height: 12),
        const NeptuneToast(message: 'Saved'),
        const SizedBox(height: 12),
        SizedBox(
          height: 360,
          child: NeptuneAppShell(
            header: const NeptunePageHeader(title: 'Accounts'),
            nav: NeptuneSideNav(
              children: [
                NeptuneSideNavItem(icon: Icons.home_outlined, label: 'Home', active: true, onTap: () {}),
              ],
            ),
            child: const Text('content'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: Row(
            children: [
              NeptuneNavRail(
                selectedIndex: 0,
                onSelect: (_) {},
                items: const [
                  NeptuneNavRailItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
                  NeptuneNavRailItem(icon: Icons.credit_card, label: 'Cards'),
                ],
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ],
    )));
    expect(find.byType(NeptuneDataTable), findsOneWidget);
    expect(find.byType(NeptuneToolbar), findsOneWidget);
    expect(find.byType(NeptuneSideNavItem), findsWidgets);
    expect(find.byType(NeptuneCardControls), findsOneWidget);
    expect(find.byType(NeptuneAddCard), findsOneWidget);
    expect(find.byType(NeptuneNavRail), findsOneWidget);
    expect(find.text('Unfreeze'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('showNeptuneToast floats over the overlay', (tester) async {
    await tester.pumpWidget(_host(
      Builder(
        builder: (context) => Center(
          child: NeptuneButton(
            label: 'Toast',
            onPressed: () => showNeptuneToast(context, 'Saved'),
          ),
        ),
      ),
      scroll: false,
    ));
    await tester.tap(find.text('Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(NeptuneToast), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    // auto-dismiss
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(NeptuneToast), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
