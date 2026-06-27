// {{PROJECT_TITLE}} — sample dashboard, composed from neptune_flutter_ui widgets
// over a NeptuneTheme. Colours/shape/type all come from the theme — no literals.
import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('{{PROJECT_TITLE}}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const NeptuneBalanceCard(
            label: 'Available balance',
            amount: 'LYD 12,480.50',
            caption: '•••• 4821',
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _StatCard(label: 'Income', value: '9,120 LYD')),
              SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Spending', value: '3,540 LYD')),
            ],
          ),
          const SizedBox(height: 16),
          Text('Recent activity', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          const Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                NeptuneTransactionRow(
                  title: 'Salary',
                  subtitle: 'Today · Transfer',
                  amount: '+3,200.00 LYD',
                  isCredit: true,
                ),
                Divider(height: 1),
                NeptuneTransactionRow(
                  title: 'Grocery Market',
                  subtitle: 'Yesterday · Card',
                  amount: '-86.40 LYD',
                ),
                Divider(height: 1),
                NeptuneTransactionRow(
                  title: 'Electricity',
                  subtitle: 'Mon · Bill',
                  amount: '-120.00 LYD',
                ),
                Divider(height: 1),
                NeptuneTransactionRow(
                  title: 'Refund',
                  subtitle: 'Sun · OnePay',
                  amount: '+45.00 LYD',
                  isCredit: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          NeptunePrimaryButton(
            label: 'Send money',
            expand: true,
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Pay',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
