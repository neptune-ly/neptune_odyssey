// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Cards — the wallet management screen. A selectable row of card art across the
// top, then the management surface for the chosen card: freeze/limits/details/PIN
// controls, a monthly-spend limit meter, an "add a card" affordance, and a frozen
// banner when the selected card is on hold. Follows the Overview reference shape:
// `AppScope.of(context)` for data/actions, `ContentScaffold` + `Block` for the
// frame, `money()`/`number()` for amounts, and theme-only colours throughout.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../app/app_scope.dart';
import '../app/nav.dart';
import '../data/fmt.dart';
import '../data/models.dart';
import '../widgets/content_scaffold.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final cards = app.cards;

    // Keep the selection valid as data shifts (e.g. a card is removed).
    final selected = cards.isEmpty ? 0 : _selected.clamp(0, cards.length - 1);
    final BankCard? card = cards.isEmpty ? null : cards[selected];

    return ContentScaffold(
      title: 'Cards',
      subtitle: 'Freeze, set limits and manage your cards.',
      actions: [
        NeptuneButton(
          label: 'Add card',
          icon: Icons.add_card_outlined,
          onPressed: () => showNeptuneToast(context, 'Add card'),
        ),
      ],
      children: [
        // ---- the wallet: a selectable row/wrap of card art ----------------
        Block(
          title: 'Your cards',
          description: 'Tap a card to manage it.',
          child: LayoutBuilder(
            builder: (context, c) {
              // Two cards per row on wide windows, one when narrow; each card
              // keeps its native 1.586 aspect ratio.
              final twoUp = c.maxWidth >= 720;
              const gap = 16.0;
              final cardWidth = twoUp ? (c.maxWidth - gap) / 2 : c.maxWidth;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < cards.length; i++)
                    SizedBox(
                      width: cardWidth,
                      child: NeptuneCardArt(
                        holder: cards[i].holder,
                        last4: cards[i].last4,
                        expiry: cards[i].expiry,
                        scheme: cards[i].schemeLabel,
                        selected: i == selected,
                        onTap: () => setState(() => _selected = i),
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        // ---- management surface for the selected card --------------------
        if (card != null) ...[
          if (card.frozen)
            Block(
              title: 'Status',
              child: NeptuneBanner(
                message: 'This card is frozen.',
                icon: Icons.ac_unit,
              ),
            ),

          LayoutBuilder(
            builder: (context, c) {
              final controls = Block(
                title: 'Card controls',
                description: 'Manage ${card.label} ending ${card.last4}.',
                child: NeptuneCardControls(
                  frozen: card.frozen,
                  onControl: (action) {
                    if (action == 'freeze') app.toggleFreeze(card);
                    showNeptuneToast(context, 'Card: $action');
                  },
                ),
              );

              final limit = Block(
                title: 'Monthly limit',
                child: NeptuneLimitMeter(
                  value: card.monthlyLimit == 0
                      ? 0
                      : (card.monthlySpend / card.monthlyLimit).clamp(0, 1),
                  label: '${card.label} limit',
                  amount:
                      '${number(card.monthlySpend)} / ${number(card.monthlyLimit)} LYD',
                  warn: card.monthlyLimit != 0 &&
                      card.monthlySpend / card.monthlyLimit >= 0.9,
                ),
              );

              if (c.maxWidth < 720) {
                return Column(children: [controls, limit]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: controls),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: limit),
                ],
              );
            },
          ),
        ],

        // ---- add a card --------------------------------------------------
        Block(
          title: 'Order a new card',
          description: 'Add a physical or virtual card to your wallet.',
          child: NeptuneAddCard(
            label: 'Add a card',
            onTap: () => showNeptuneToast(context, 'Add card'),
          ),
        ),

        // Cross-link: where the money flows.
        Block(
          title: 'Spending',
          child: NeptuneAccountTile(
            name: 'Review recent activity',
            maskedNumber: 'See every card transaction',
            balance: money(app.monthOut, signed: false),
            onTap: () => app.go(NavDest.activity),
          ),
        ),
      ],
    );
  }
}
