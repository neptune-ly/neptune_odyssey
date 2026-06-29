// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// A real example: a themed dashboard + onboarding screen built ONLY from the
// neptune_flutter_ui widget set. Swap `brand` for triton/nereid/proteus, or
// pass a NO1-… brandprint to NeptuneTheme.fromBrandprint — every widget reskins.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  String _brand = 'neptune';
  ThemeMode _mode = ThemeMode.light;

  void _cycleBrand() {
    const brands = ['neptune', 'triton', 'nereid', 'proteus'];
    setState(() => _brand = brands[(brands.indexOf(_brand) + 1) % brands.length]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neptune Odyssey · Flutter',
      theme: NeptuneTheme.light(_brand),
      darkTheme: NeptuneTheme.dark(_brand),
      themeMode: _mode,
      home: DashboardScreen(
        brand: _brand,
        onCycleBrand: _cycleBrand,
        onToggleMode: () => setState(
          () => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String brand;
  final VoidCallback onCycleBrand;
  final VoidCallback onToggleMode;

  const DashboardScreen({
    super.key,
    required this.brand,
    required this.onCycleBrand,
    required this.onToggleMode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            NeptuneAppBar(
              title: 'Hi, Lina',
              leading: const CircleAvatar(child: Text('LA')),
              actions: [
                IconButton(onPressed: widget.onCycleBrand, icon: const Icon(Icons.palette_outlined)),
                IconButton(onPressed: widget.onToggleMode, icon: const Icon(Icons.brightness_6_outlined)),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 110),
                children: [
                  const NeptuneBalanceCard(
                    label: 'Available balance',
                    amount: 'LYD 12,480.50',
                    caption: '•••• 4821',
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: NeptuneStatCard(label: 'Income', value: '9,120', unit: 'LYD', delta: '+8.2%')),
                      SizedBox(width: 12),
                      Expanded(child: NeptuneStatCard(label: 'Spending', value: '3,540', unit: 'LYD', delta: '-2.1%')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Your cards', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  const NeptuneCardArt(
                    holder: 'LINA ATIYA',
                    last4: '4821',
                    expiry: '08/27',
                    scheme: 'Visa',
                    selected: true,
                  ),
                  const SizedBox(height: 16),
                  NeptuneQuickActions(
                    actions: [
                      NeptuneQuickAction(icon: Icons.north_east, label: 'Send', onTap: () {}),
                      NeptuneQuickAction(icon: Icons.account_balance_wallet_outlined, label: 'Request', onTap: () {}),
                      NeptuneQuickAction(icon: Icons.qr_code_rounded, label: 'Pay', onTap: () {}),
                      NeptuneQuickAction(icon: Icons.add_card_outlined, label: 'Top up', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const NeptuneSection(
                    title: 'Recent activity',
                    description: 'Last 30 days',
                    child: Column(
                      children: [
                        NeptuneTransactionRow(title: 'Salary', subtitle: 'Today · Transfer', amount: '+3,200.00 LYD', isCredit: true),
                        Divider(height: 1),
                        NeptuneTransactionRow(title: 'Grocery Market', subtitle: 'Yesterday · Card', amount: '-86.40 LYD'),
                        Divider(height: 1),
                        NeptuneTransactionRow(title: 'Refund', subtitle: 'Sun · OnePay', amount: '+45.00 LYD', isCredit: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeptuneCta(
                    label: 'Send money',
                    arrow: true,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const _WelcomeScreen()),
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
            NeptuneDockItem(icon: Icons.home_rounded, label: 'Home', active: _tab == 0, onTap: () => setState(() => _tab = 0)),
            NeptuneDockItem(icon: Icons.credit_card, label: 'Cards', active: _tab == 1, onTap: () => setState(() => _tab = 1)),
            NeptuneDockItem(icon: Icons.qr_code_rounded, label: 'Pay', active: _tab == 2, onTap: () => setState(() => _tab = 2)),
            NeptuneDockItem(icon: Icons.person_outline, label: 'Profile', active: _tab == 3, onTap: () => setState(() => _tab = 3)),
          ],
        ),
      ),
      backgroundColor: scheme.surface,
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
