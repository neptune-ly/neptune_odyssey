// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Pay — QR pay, top-ups, recent merchants, vouchers and membership tiers. A
// two-column wallet surface built from neptune_flutter_ui wallet/pay widgets,
// themed entirely from the brandprint. Read `AppScope.of(context)` for data and
// format money via `money()`; never hard-code colours.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../app/app_scope.dart';
import '../app/nav.dart';
import '../data/fmt.dart';
import '../widgets/content_scaffold.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    // ~5 recent merchants derived from outgoing transactions.
    final merchants = app.txns.where((t) => !t.isCredit).take(5).toList();

    // ---- left column: scan to pay + top up --------------------------------
    final left = [
      Block(
        title: 'Scan to pay',
        description: 'Point your camera at a merchant code to pay instantly.',
        child: const Align(
          alignment: AlignmentDirectional.center,
          child: NeptuneQrPay(amount: 'LYD 45.00', merchant: 'Coffee Bar'),
        ),
      ),
      Block(
        title: 'Top up',
        child: Column(
          children: [
            NeptuneTopupRow(
              label: 'Card',
              sublabel: 'Instant · Visa or Mastercard',
              amount: money(50),
              onTap: () => showNeptuneToast(context, 'Top up from card started'),
            ),
            const SizedBox(height: 8),
            NeptuneTopupRow(
              label: 'Bank',
              sublabel: 'From a linked account',
              amount: money(100),
              onTap: () => showNeptuneToast(context, 'Bank top up started'),
            ),
            const SizedBox(height: 8),
            NeptuneTopupRow(
              label: 'Voucher',
              sublabel: 'Redeem a top-up code',
              amount: money(25),
              onTap: () => showNeptuneToast(context, 'Enter a voucher code to redeem'),
            ),
          ],
        ),
      ),
    ];

    // ---- right column: recent merchants + vouchers ------------------------
    final right = [
      Block(
        title: 'Recent merchants',
        description: 'Tap a name on your statement to pay again.',
        child: Column(
          children: [
            for (final t in merchants)
              NeptuneMerchantRow(
                name: t.title,
                category: t.category,
                amount: money(t.amount, signed: true),
                time: t.date,
              ),
          ],
        ),
      ),
      Block(
        title: 'Vouchers',
        description: 'Your active rewards and membership tier.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NeptuneVoucherCard(
              title: 'Welcome reward',
              value: 'LYD 25',
              code: 'NEPTUNE25',
              expiry: 'Expires 31 Dec 2026',
            ),
            const SizedBox(height: 12),
            const NeptuneVoucherCard(
              title: 'Cashback boost',
              value: '10%',
              code: 'BOOST10',
              expiry: 'Expires 30 Sep 2026',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                NeptuneTierBadge(tier: 'Gold', tone: 'gold'),
                NeptuneTierBadge(tier: 'Silver', tone: 'silver'),
              ],
            ),
          ],
        ),
      ),
    ];

    return ContentScaffold(
      title: 'Pay',
      subtitle: 'QR pay, merchants, vouchers and top-ups.',
      actions: [
        NeptuneButton(
          label: 'Transfer',
          icon: Icons.swap_horiz,
          onPressed: () => app.go(NavDest.transfers),
        ),
      ],
      children: [
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 860) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [...left, ...right],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: left,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: right,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}