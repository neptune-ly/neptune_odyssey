// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Activity — a single ledger of every transaction across all accounts. A filter
// row (All / Income / Spending) drives a themed data table, with month in/out
// stat cards and a trend chip up top. Follows the Overview reference shape:
// AppScope for data, ContentScaffold + Block frame, money()/number() formatting,
// theme-only styling, RTL-safe.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../app/app_scope.dart';
import '../app/nav.dart';
import '../data/fmt.dart';
import '../data/models.dart';
import '../widgets/content_scaffold.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  // One of: 'all', 'income', 'spending'.
  String _filter = 'all';

  List<Txn> _filtered(List<Txn> txns) {
    switch (_filter) {
      case 'income':
        return txns.where((t) => t.isCredit).toList();
      case 'spending':
        return txns.where((t) => !t.isCredit).toList();
      default:
        return txns;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final rows = _filtered(app.txns);

    return ContentScaffold(
      title: 'Activity',
      subtitle: 'Every transaction across your accounts.',
      actions: [
        NeptuneButton(
          label: 'Transfer',
          icon: Icons.north_east,
          onPressed: () => app.go(NavDest.transfers),
        ),
      ],
      children: [
        // ---- filter row --------------------------------------------------
        Block(
          title: 'Filter',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              NeptuneChip(
                label: 'All',
                selected: _filter == 'all',
                onTap: () => setState(() => _filter = 'all'),
              ),
              NeptuneChip(
                label: 'Income',
                selected: _filter == 'income',
                onTap: () => setState(() => _filter = 'income'),
              ),
              NeptuneChip(
                label: 'Spending',
                selected: _filter == 'spending',
                onTap: () => setState(() => _filter = 'spending'),
              ),
            ],
          ),
        ),

        // ---- summary row -------------------------------------------------
        Block(
          title: 'This month',
          child: LayoutBuilder(
            builder: (context, c) {
              final moneyIn = NeptuneStatCard(
                label: 'Money in',
                value: number(app.monthIn),
                unit: 'LYD',
                delta: '+8.2%',
              );
              final moneyOut = NeptuneStatCard(
                label: 'Money out',
                value: number(app.monthOut),
                unit: 'LYD',
                delta: '-2.1%',
              );
              const trend = Align(
                alignment: AlignmentDirectional.centerStart,
                child: NeptuneTrend(value: 8.2),
              );

              if (c.maxWidth < 720) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: moneyIn),
                        const SizedBox(width: 16),
                        Expanded(child: moneyOut),
                      ],
                    ),
                    const SizedBox(height: 16),
                    trend,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: moneyIn),
                  const SizedBox(width: 16),
                  Expanded(child: moneyOut),
                  const SizedBox(width: 16),
                  trend,
                ],
              );
            },
          ),
        ),

        // ---- ledger ------------------------------------------------------
        Block(
          title: 'Transactions',
          description: rows.isEmpty
              ? 'No transactions match this filter.'
              : '${number(rows.length)} of ${number(app.txns.length)} shown.',
          child: NeptuneDataTable(
            caption: 'Transactions',
            columns: const [
              NeptuneColumn('Description'),
              NeptuneColumn('Category'),
              NeptuneColumn('Date'),
              NeptuneColumn('Amount', numeric: true),
            ],
            rows: [
              for (final t in rows)
                [
                  t.title,
                  t.category,
                  t.date,
                  money(t.amount, signed: true),
                ],
            ],
          ),
        ),
      ],
    );
  }
}
