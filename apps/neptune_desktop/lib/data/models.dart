// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// The domain model for the demo banking app. Amounts are doubles; format at the
// edge with `fmt.dart`. Mutable bits (e.g. card freeze, permission flags) live
// here so AppState can flip them and notify.

import 'package:flutter/foundation.dart';

enum AccountKind { current, savings, business }

@immutable
class Account {
  final String id;
  final String name;
  final AccountKind kind;
  final String maskedNumber;
  final String iban;
  final double balance;
  final String currency;

  const Account({
    required this.id,
    required this.name,
    required this.kind,
    required this.maskedNumber,
    required this.iban,
    required this.balance,
    this.currency = 'LYD',
  });
}

enum CardScheme { visa, mastercard }

class BankCard {
  final String id;
  final String holder;
  final String last4;
  final String expiry;
  final CardScheme scheme;
  final String label;
  final double monthlySpend;
  final double monthlyLimit;
  bool frozen;

  BankCard({
    required this.id,
    required this.holder,
    required this.last4,
    required this.expiry,
    required this.scheme,
    required this.label,
    required this.monthlySpend,
    required this.monthlyLimit,
    this.frozen = false,
  });

  String get schemeLabel => scheme == CardScheme.visa ? 'Visa' : 'Mastercard';
}

@immutable
class Txn {
  final String id;
  final String title;
  final String subtitle;

  /// Positive = credit (money in), negative = debit (money out).
  final double amount;
  final String date;
  final String category;
  final String currency;

  const Txn({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.category,
    this.currency = 'LYD',
  });

  bool get isCredit => amount >= 0;
}

@immutable
class Beneficiary {
  final String id;
  final String name;
  final String maskedAccount;
  final String bank;

  const Beneficiary({
    required this.id,
    required this.name,
    required this.maskedAccount,
    required this.bank,
  });
}

@immutable
class Approval {
  final String id;
  final String title;
  final String subtitle;
  final double amount;

  const Approval({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
  });
}

@immutable
class AuditEntry {
  final String actor;
  final String action;
  final String time;

  const AuditEntry({required this.actor, required this.action, required this.time});
}

class TeamMember {
  final String name;
  final String role;
  final String status;
  bool canApprove;

  TeamMember({
    required this.name,
    required this.role,
    required this.status,
    this.canApprove = false,
  });
}
