// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// The desktop navigation model: the ordered destinations of the side rail and
// their icons/labels. The shell renders these; screens index by [NavDest].

import 'package:flutter/material.dart';

enum NavDest {
  overview,
  accounts,
  cards,
  transfers,
  payments,
  activity,
  payees,
  corporate,
  settings,
}

@immutable
class NavMeta {
  final NavDest dest;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavMeta(this.dest, this.label, this.icon, this.selectedIcon);
}

/// The primary nav, in display order. Settings is pinned to the bottom by the
/// shell, the rest scroll above it.
const List<NavMeta> kNav = [
  NavMeta(NavDest.overview, 'Overview', Icons.dashboard_outlined, Icons.dashboard),
  NavMeta(NavDest.accounts, 'Accounts', Icons.account_balance_outlined, Icons.account_balance),
  NavMeta(NavDest.cards, 'Cards', Icons.credit_card_outlined, Icons.credit_card),
  NavMeta(NavDest.transfers, 'Transfer', Icons.swap_horiz_outlined, Icons.swap_horiz),
  NavMeta(NavDest.payments, 'Pay', Icons.qr_code_2_outlined, Icons.qr_code_2),
  NavMeta(NavDest.activity, 'Activity', Icons.receipt_long_outlined, Icons.receipt_long),
  NavMeta(NavDest.payees, 'Payees', Icons.people_outline, Icons.people),
  NavMeta(NavDest.corporate, 'Corporate', Icons.apartment_outlined, Icons.apartment),
  NavMeta(NavDest.settings, 'Settings', Icons.settings_outlined, Icons.settings),
];
