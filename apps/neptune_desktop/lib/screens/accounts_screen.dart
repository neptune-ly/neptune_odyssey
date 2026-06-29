// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Accounts — a master-detail view. LEFT: a selectable list of every account as a
// NeptuneAccountTile. RIGHT: the selected account's balance card, IBAN, recent
// activity and quick actions. Wide windows show the two panes side by side; they
// stack when narrow. Theme-only, RTL-safe — follows the Overview reference shape.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../app/app_scope.dart';
import '../app/nav.dart';
import '../data/fmt.dart';
import '../data/models.dart';
import '../widgets/content_scaffold.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  int _selectedIndex = 0;

  String _kindLabel(AccountKind kind) {
    switch (kind) {
      case AccountKind.current:
        return 'Current account';
      case AccountKind.savings:
        return 'Savings account';
      case AccountKind.business:
        return 'Business account';
    }
  }

  IconData _kindIcon(AccountKind kind) {
    switch (kind) {
      case AccountKind.current:
        return Icons.account_balance_wallet_outlined;
      case AccountKind.savings:
        return Icons.savings_outlined;
      case AccountKind.business:
        return Icons.apartment_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final accounts = app.accounts;

    // Keep the selection in range if the data set ever shrinks.
    final index = accounts.isEmpty
        ? 0
        : _selectedIndex.clamp(0, accounts.length - 1);

    final recent = app.txns.take(8).toList();

    final list = Block(
      title: 'Your accounts',
      description: '${accounts.length} accounts · ${money(app.totalBalance)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < accounts.length; i++)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 8),
              child: _SelectableTile(
                selected: i == index,
                child: NeptuneAccountTile(
                  name: accounts[i].name,
                  maskedNumber: accounts[i].maskedNumber,
                  balance: money(accounts[i].balance,
                      currency: accounts[i].currency),
                  icon: _kindIcon(accounts[i].kind),
                  onTap: () => setState(() => _selectedIndex = i),
                ),
              ),
            ),
        ],
      ),
    );

    final detail = accounts.isEmpty
        ? const Block(
            title: 'Account details',
            child: NeptuneEmptyState(
              icon: Icons.account_balance_outlined,
              title: 'No accounts yet',
              message: 'Open an account to see balances and statements here.',
            ),
          )
        : _AccountDetail(
            account: accounts[index],
            recent: recent,
            kindLabel: _kindLabel(accounts[index].kind),
            onTransfer: () => app.go(NavDest.transfers),
            onStatement: () =>
                showNeptuneToast(context, 'Statement export started.'),
          );

    return ContentScaffold(
      title: 'Accounts',
      subtitle: 'Balances, details and statements.',
      actions: [
        NeptuneButton(
          label: 'Transfer',
          icon: Icons.north_east,
          onPressed: () => app.go(NavDest.transfers),
        ),
      ],
      children: [
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 860) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [list, detail],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: list),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: detail),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Wraps an account tile with a selection ring drawn from the theme. Keeps the
/// underlying [NeptuneAccountTile] untouched so it stays brand-correct.
class _SelectableTile extends StatelessWidget {
  final bool selected;
  final Widget child;

  const _SelectableTile({required this.selected, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: shape.rMd,
        border: Border.all(
          color: selected ? scheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: child,
    );
  }
}

/// The right-hand detail pane for a single [Account].
class _AccountDetail extends StatelessWidget {
  final Account account;
  final List<Txn> recent;
  final String kindLabel;
  final VoidCallback onTransfer;
  final VoidCallback onStatement;

  const _AccountDetail({
    required this.account,
    required this.recent,
    required this.kindLabel,
    required this.onTransfer,
    required this.onStatement,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Block(
          title: 'Account details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeptuneBalanceCard(
                label: account.name,
                amount: money(account.balance, currency: account.currency),
                caption: kindLabel,
              ),
              const SizedBox(height: 16),
              Text(
                'IBAN',
                style: text.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              NeptuneIbanField(value: account.iban, valid: true),
            ],
          ),
        ),
        Block(
          title: 'Recent activity',
          child: NeptuneDataTable(
            columns: const [
              NeptuneColumn('Description'),
              NeptuneColumn('Date'),
              NeptuneColumn('Amount', numeric: true),
            ],
            rows: [
              for (final t in recent)
                [t.title, t.date, money(t.amount, signed: true)],
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            NeptuneButton(
              label: 'Transfer',
              icon: Icons.north_east,
              onPressed: onTransfer,
            ),
            NeptuneButton(
              label: 'Statement',
              icon: Icons.description_outlined,
              variant: NeptuneButtonStyle.outlined,
              onPressed: onStatement,
            ),
          ],
        ),
      ],
    );
  }
}
