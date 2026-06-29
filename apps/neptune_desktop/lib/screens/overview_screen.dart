// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Overview / dashboard — the home screen. Hero balance + month in/out, quick
// actions, a recent-activity table beside a small data-viz column, and the
// account list. Pure neptune_flutter_ui widgets, all themed from the brandprint.
//
// This is the REFERENCE screen: other screens follow its shape — read
// `AppScope.of(context)` for data, wrap content in `ContentScaffold`, group with
// `Block`, format money via `money()` from data/fmt.dart, never hard-code colours.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../app/app_scope.dart';
import '../app/nav.dart';
import '../data/fmt.dart';
import '../widgets/content_scaffold.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final recent = app.txns.take(6).toList();
    final card = app.cards.first;

    // Spend by a few categories for the donut.
    final byCat = <String, double>{};
    for (final t in app.txns.where((t) => !t.isCredit)) {
      byCat.update(t.category, (v) => v + t.amount.abs(), ifAbsent: () => t.amount.abs());
    }
    final topCats = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final donutSegments = topCats.take(4).map((e) => e.value).toList();

    // A gentle balance trend for the sparkline (relative points only).
    final base = app.totalBalance;
    final spark = [0.86, 0.88, 0.91, 0.89, 0.94, 0.97, 1.0].map((f) => base * f).toList();

    return ContentScaffold(
      title: 'Good morning, Lina',
      subtitle: 'Here is where your money stands today.',
      actions: [
        NeptuneButton(
          label: 'Transfer',
          icon: Icons.north_east,
          onPressed: () => app.go(NavDest.transfers),
        ),
      ],
      children: [
        // ---- hero row ----------------------------------------------------
        LayoutBuilder(
          builder: (context, c) {
            final hero = NeptuneBalanceCard(
              label: 'Total balance',
              amount: money(app.totalBalance),
              caption: '${app.accounts.length} accounts',
            );
            final stats = [
              Expanded(child: NeptuneStatCard(label: 'Money in', value: number(app.monthIn), unit: 'LYD', delta: '+8.2%')),
              const SizedBox(width: 16),
              Expanded(child: NeptuneStatCard(label: 'Money out', value: number(app.monthOut), unit: 'LYD', delta: '-2.1%')),
            ];
            if (c.maxWidth < 720) {
              return Column(children: [hero, const SizedBox(height: 16), Row(children: stats)]);
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: hero),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: Row(children: stats)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        Block(
          title: 'Quick actions',
          child: NeptuneQuickActions(
            actions: [
              NeptuneQuickAction(icon: Icons.north_east, label: 'Send', onTap: () => app.go(NavDest.transfers)),
              NeptuneQuickAction(icon: Icons.account_balance_wallet_outlined, label: 'Request', onTap: () => app.go(NavDest.transfers)),
              NeptuneQuickAction(icon: Icons.qr_code_rounded, label: 'Pay', onTap: () => app.go(NavDest.payments)),
              NeptuneQuickAction(icon: Icons.add_card_outlined, label: 'Top up', onTap: () => app.go(NavDest.cards)),
            ],
          ),
        ),

        // ---- activity + viz ----------------------------------------------
        LayoutBuilder(
          builder: (context, c) {
            final table = Block(
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
            );
            final viz = Block(
              title: 'Insights',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      NeptuneDonut(
                        segments: donutSegments.isEmpty ? const [1] : donutSegments,
                        centerLabel: money(app.monthOut).split(' ').last,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: NeptuneLimitMeter(
                          value: (card.monthlySpend / card.monthlyLimit).clamp(0, 1),
                          label: '${card.label} limit',
                          amount: '${number(card.monthlySpend)} / ${number(card.monthlyLimit)} LYD',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(height: 56, child: NeptuneSparkline(points: spark)),
                ],
              ),
            );
            if (c.maxWidth < 860) {
              return Column(children: [table, viz]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: table),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: viz),
              ],
            );
          },
        ),

        Block(
          title: 'Accounts',
          child: Column(
            children: [
              for (final a in app.accounts)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 8),
                  child: NeptuneAccountTile(
                    name: a.name,
                    maskedNumber: a.maskedNumber,
                    balance: money(a.balance, currency: a.currency),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
