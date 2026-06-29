// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// A live components gallery built ONLY from neptune_flutter_ui. Cycle the brand
// (neptune / triton / nereid / proteus), flip light/dark, and toggle RTL to see
// the Arabic faces + direction-aware money figures. Every widget below is themed
// purely from the active NeptuneTheme — swap the brand and the whole gallery
// reskins, byte-identically to the web.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  static const _brands = ['neptune', 'triton', 'nereid', 'proteus'];
  int _brandIndex = 0;
  ThemeMode _mode = ThemeMode.light;
  bool _rtl = false;

  String get _brand => _brands[_brandIndex];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neptune Odyssey · Flutter',
      theme: NeptuneTheme.light(_brand, arabic: _rtl),
      darkTheme: NeptuneTheme.dark(_brand, arabic: _rtl),
      themeMode: _mode,
      home: Directionality(
        textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
        child: GalleryScreen(
          brand: _brand,
          rtl: _rtl,
          onCycleBrand: () =>
              setState(() => _brandIndex = (_brandIndex + 1) % _brands.length),
          onToggleMode: () => setState(() =>
              _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light),
          onToggleRtl: () => setState(() => _rtl = !_rtl),
        ),
      ),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  final String brand;
  final bool rtl;
  final VoidCallback onCycleBrand;
  final VoidCallback onToggleMode;
  final VoidCallback onToggleRtl;

  const GalleryScreen({
    super.key,
    required this.brand,
    required this.rtl,
    required this.onCycleBrand,
    required this.onToggleMode,
    required this.onToggleRtl,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _dock = 0;
  int _rail = 0;
  bool _frozen = false;
  bool _canApprove = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            NeptuneAppBar(
              title: 'Components · ${widget.brand}',
              leading: const CircleAvatar(child: Text('NO')),
              actions: [
                IconButton(
                  onPressed: widget.onToggleRtl,
                  tooltip: 'Toggle RTL',
                  icon: Icon(widget.rtl ? Icons.format_textdirection_r_to_l : Icons.format_textdirection_l_to_r),
                ),
                IconButton(
                  onPressed: widget.onToggleMode,
                  tooltip: 'Toggle dark',
                  icon: const Icon(Icons.brightness_6_outlined),
                ),
                IconButton(
                  onPressed: widget.onCycleBrand,
                  tooltip: 'Cycle brand',
                  icon: const Icon(Icons.palette_outlined),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 120),
                children: [
                  // ---- Typography ------------------------------------------
                  _Section(
                    title: 'Typography',
                    description: 'Brand display / text faces + tabular money figures',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Display', style: text.displaySmall),
                        Text('Headline', style: text.headlineSmall),
                        Text('Title — the quick brown fox', style: text.titleMedium),
                        Text('Body — open an account in minutes.', style: text.bodyMedium),
                        const SizedBox(height: 8),
                        Text(
                          'LYD 12,480.50',
                          style: NeptuneTheme.moneyStyle(context, base: text.headlineMedium)
                              .copyWith(color: scheme.onSurface),
                        ),
                      ],
                    ),
                  ),

                  // ---- Cards / finance -------------------------------------
                  _Section(
                    title: 'Cards & balances',
                    child: Column(
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
                        NeptuneCardControls(
                          frozen: _frozen,
                          onControl: (action) {
                            if (action == 'freeze') setState(() => _frozen = !_frozen);
                            showNeptuneToast(context, 'Card action: $action');
                          },
                        ),
                        const SizedBox(height: 12),
                        NeptuneAddCard(onTap: () => showNeptuneToast(context, 'Add a card')),
                        const SizedBox(height: 12),
                        const NeptuneAccountTile(
                          name: 'Everyday',
                          maskedNumber: '•••• 4821',
                          balance: 'LYD 12,480.50',
                        ),
                      ],
                    ),
                  ),

                  // ---- Actions ---------------------------------------------
                  _Section(
                    title: 'Actions',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            NeptuneButton(label: 'Filled', onPressed: () {}),
                            NeptuneButton(label: 'Tonal', variant: NeptuneButtonStyle.tonal, onPressed: () {}),
                            NeptuneButton(label: 'Outlined', variant: NeptuneButtonStyle.outlined, icon: Icons.add, onPressed: () {}),
                            NeptuneButton(label: 'Text', variant: NeptuneButtonStyle.text, onPressed: () {}),
                          ],
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
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            NeptuneChip(label: 'Selected', selected: true),
                            NeptuneChip(label: 'Default'),
                            NeptuneStatusChip(label: 'Active', tone: NeptuneStatusTone.success),
                            NeptuneStatusChip(label: 'Pending', tone: NeptuneStatusTone.warning),
                            NeptuneStatusChip(label: 'Failed', tone: NeptuneStatusTone.danger),
                          ],
                        ),
                        const SizedBox(height: 12),
                        NeptuneCta(
                          label: 'Get started',
                          arrow: true,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const _WelcomeScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---- Money inputs ----------------------------------------
                  _Section(
                    title: 'Money inputs',
                    child: Column(
                      children: [
                        const NeptuneAmountInput(value: '1,250.00', currency: 'LYD'),
                        const SizedBox(height: 12),
                        const NeptuneCurrencyField(amount: '1,250.00', currency: 'LYD', currencies: ['LYD', 'USD', 'EUR']),
                        const SizedBox(height: 12),
                        const NeptuneIbanField(value: 'LY83 0020 0001 2345', valid: true),
                        const SizedBox(height: 12),
                        const NeptuneOtpInput(length: 6),
                        const SizedBox(height: 12),
                        const NeptunePinInput(length: 4),
                        const SizedBox(height: 12),
                        SizedBox(height: 280, child: NeptuneAmountKeypad(onKey: (_) {}, onBackspace: () {})),
                      ],
                    ),
                  ),

                  // ---- Money movement --------------------------------------
                  _Section(
                    title: 'Money movement',
                    child: Column(
                      children: [
                        const NeptuneStepper(steps: ['Amount', 'Review', 'Done'], active: 1),
                        const SizedBox(height: 12),
                        const NeptuneTransferReview(
                          fromLabel: 'Everyday •••• 4821',
                          toLabel: 'Sara N.',
                          amount: '250.00',
                          fee: '0.00',
                          total: '250.00',
                          currency: 'LYD',
                        ),
                        const SizedBox(height: 12),
                        NeptuneMethodRow(icon: Icons.account_balance, title: 'Bank transfer', subtitle: 'NUMO', selected: true, onTap: () {}),
                        NeptuneBeneficiaryTile(name: 'Sara Nuri', account: '•••• 7390', selected: true, onTap: () {}),
                        const SizedBox(height: 12),
                        const NeptuneSuccess(title: 'Sent!', amount: 'LYD 250.00', subtitle: 'To Sara N.'),
                        const SizedBox(height: 12),
                        NeptuneReceipt(
                          title: 'Receipt',
                          rows: const [
                            (label: 'Amount', value: 'LYD 250.00'),
                            (label: 'Fee', value: 'LYD 0.00'),
                            (label: 'Total', value: 'LYD 250.00'),
                          ],
                          onShare: () => showNeptuneToast(context, 'Shared receipt'),
                        ),
                      ],
                    ),
                  ),

                  // ---- Data table + data-viz -------------------------------
                  const _Section(
                    title: 'Data table & charts',
                    child: Column(
                      children: [
                        NeptuneDataTable(
                          caption: 'Recent activity',
                          columns: [
                            NeptuneColumn('Merchant'),
                            NeptuneColumn('Date'),
                            NeptuneColumn('Amount', numeric: true),
                          ],
                          rows: [
                            ['Coffee Bar', 'Today', '4.50'],
                            ['Grocery Market', 'Yesterday', '86.40'],
                            ['Salary', 'Sun', '3,200.00'],
                          ],
                        ),
                        SizedBox(height: 12),
                        SizedBox(width: double.infinity, height: 56, child: NeptuneSparkline(points: [3, 4, 4, 6, 5, 7, 8])),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            NeptuneDonut(segments: [3, 2, 1], centerLabel: '6'),
                            SizedBox(width: 16),
                            Expanded(child: NeptuneLimitMeter(value: 0.62, label: 'Monthly spend', amount: '620 / 1,000 LYD')),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            NeptuneTrend(value: 8.2),
                            SizedBox(width: 16),
                            NeptuneTrend(value: 2.1, down: true),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ---- Corporate -------------------------------------------
                  _Section(
                    title: 'Corporate',
                    child: Column(
                      children: [
                        NeptuneApprovalItem(title: 'Payroll batch', subtitle: '42 payments', amount: 'LYD 18,200', onApprove: () {}, onReject: () {}),
                        const SizedBox(height: 12),
                        const NeptuneBatchCard(title: 'June payroll', count: '42', total: 'LYD 18,200', status: 'Pending'),
                        const SizedBox(height: 12),
                        const NeptuneAuditRow(actor: 'Lina A.', action: 'Approved transfer', time: '12:04'),
                        NeptuneUserRow(name: 'Omar K.', role: 'Approver', status: 'Active', onTap: () {}),
                        NeptunePermissionToggle(
                          label: 'Can approve',
                          description: 'Up to LYD 50k',
                          value: _canApprove,
                          onChanged: (v) => setState(() => _canApprove = v),
                        ),
                        const SizedBox(height: 12),
                        const NeptuneWorkflowStatus(label: 'Review', step: 2, total: 3),
                      ],
                    ),
                  ),

                  // ---- Wallet / pay ----------------------------------------
                  _Section(
                    title: 'Wallet & pay',
                    child: Column(
                      children: [
                        const NeptuneMerchantRow(name: 'Grocery Market', category: 'Card', amount: '-86.40 LYD', time: 'Today'),
                        const SizedBox(height: 12),
                        const NeptuneVoucherCard(title: 'Cashback', value: 'LYD 10', code: 'NPT-10', expiry: 'Aug 27'),
                        const SizedBox(height: 12),
                        const NeptuneQrPay(amount: 'LYD 45.00', merchant: 'Coffee Bar'),
                        const SizedBox(height: 12),
                        NeptuneTopupRow(label: 'Top up', sublabel: 'Card', amount: 'LYD 50', onTap: () {}),
                        const SizedBox(height: 12),
                        const Wrap(spacing: 8, children: [NeptuneTierBadge(tier: 'Gold'), NeptuneTierBadge(tier: 'Silver')]),
                      ],
                    ),
                  ),

                  // ---- Shell & navigation ----------------------------------
                  _Section(
                    title: 'Shell & navigation',
                    child: Column(
                      children: [
                        const NeptunePageHeader(title: 'Accounts', subtitle: 'All your money in one place'),
                        NeptuneToolbar(
                          start: [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))],
                          center: const [NeptuneSearchField(hint: 'Search')],
                          end: [IconButton(onPressed: () {}, icon: const Icon(Icons.tune))],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 280,
                          child: Row(
                            children: [
                              NeptuneNavRail(
                                selectedIndex: _rail,
                                onSelect: (i) => setState(() => _rail = i),
                                items: const [
                                  NeptuneNavRailItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
                                  NeptuneNavRailItem(icon: Icons.credit_card, label: 'Cards'),
                                  NeptuneNavRailItem(icon: Icons.bar_chart_outlined, label: 'Stats'),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NeptuneSideNav(
                                  children: [
                                    NeptuneSideNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', active: true, onTap: () {}),
                                    NeptuneSideNavItem(
                                      icon: Icons.swap_horiz,
                                      label: 'Transfers',
                                      trailing: const NeptuneStatusChip(label: '3', tone: NeptuneStatusTone.neutral),
                                      onTap: () {},
                                    ),
                                    NeptuneSideNavItem(icon: Icons.people_outline, label: 'Beneficiaries', onTap: () {}),
                                    const NeptuneSideNavItem(icon: Icons.settings_outlined, label: 'Settings (disabled)', enabled: false),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---- Feedback --------------------------------------------
                  _Section(
                    title: 'Feedback',
                    child: Column(
                      children: [
                        const NeptuneAlert(message: 'Transfer completed.', tone: NeptuneAlertTone.success, title: 'Done'),
                        const SizedBox(height: 12),
                        const NeptuneBanner(message: 'Scheduled maintenance tonight.'),
                        const SizedBox(height: 12),
                        const NeptuneEmptyState(icon: Icons.inbox_outlined, title: 'Nothing yet', message: 'Your activity will show here.'),
                        const SizedBox(height: 12),
                        const NeptuneSkeleton(width: 220),
                        const SizedBox(height: 12),
                        NeptuneToast(
                          message: 'Saved to favourites',
                          action: TextButton(onPressed: () {}, child: const Text('Undo')),
                        ),
                        const SizedBox(height: 12),
                        NeptuneButton(
                          label: 'Show toast',
                          variant: NeptuneButtonStyle.tonal,
                          onPressed: () => showNeptuneToast(
                            context,
                            'Transfer sent',
                            action: TextButton(onPressed: () {}, child: const Text('View')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 14),
        child: NeptuneDock(
          items: [
            NeptuneDockItem(icon: Icons.home_rounded, label: 'Home', active: _dock == 0, onTap: () => setState(() => _dock = 0)),
            NeptuneDockItem(icon: Icons.credit_card, label: 'Cards', active: _dock == 1, onTap: () => setState(() => _dock = 1)),
            NeptuneDockItem(icon: Icons.qr_code_rounded, label: 'Pay', active: _dock == 2, onTap: () => setState(() => _dock = 2)),
            NeptuneDockItem(icon: Icons.person_outline, label: 'Profile', active: _dock == 3, onTap: () => setState(() => _dock = 3)),
          ],
        ),
      ),
    );
  }
}

/// A labelled gallery section, themed via NeptuneSection.
class _Section extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;

  const _Section({required this.title, this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: NeptuneSection(title: title, description: description, child: child),
    );
  }
}

/// The onboarding / get-started hero, built from NeptuneOnboarding + NeptuneCta.
class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: NeptuneOnboarding(
          eyebrow: 'NEPTUNE ODYSSEY',
          headline: RichText(
            text: TextSpan(
              style: text.displaySmall?.copyWith(color: scheme.onSurface),
              children: [
                const TextSpan(text: 'Your money,\n'),
                TextSpan(
                  text: 'everywhere you are.',
                  style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          supporting: 'Open an account in minutes. Send, spend and save across borders — beautifully.',
          steps: 3,
          activeStep: 0,
          cta: NeptuneCta(
            label: 'Get started',
            arrow: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
