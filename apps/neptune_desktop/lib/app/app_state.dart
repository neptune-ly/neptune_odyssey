// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// The single source of truth for the running app: the active brandprint (brand +
// light/dark + RTL/Arabic), the current nav destination, the demo data, and the
// mutations screens trigger. A plain ChangeNotifier — no external state package.

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/mock_data.dart';
import 'nav.dart';

class AppState extends ChangeNotifier {
  // ---- white-label brandprint ----------------------------------------------
  static const List<String> brands = ['neptune', 'triton', 'nereid', 'proteus'];

  String _brand = 'neptune';
  ThemeMode _mode = ThemeMode.light;
  bool _rtl = false;

  String get brand => _brand;
  ThemeMode get mode => _mode;
  bool get rtl => _rtl;
  bool get isDark => _mode == ThemeMode.dark;

  set brand(String value) {
    if (value == _brand || !brands.contains(value)) return;
    _brand = value;
    notifyListeners();
  }

  void cycleBrand() {
    final next = (brands.indexOf(_brand) + 1) % brands.length;
    _brand = brands[next];
    notifyListeners();
  }

  void toggleMode() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleRtl() {
    _rtl = !_rtl;
    notifyListeners();
  }

  // ---- navigation ----------------------------------------------------------
  NavDest _nav = NavDest.overview;
  NavDest get nav => _nav;

  void go(NavDest dest) {
    if (dest == _nav) return;
    _nav = dest;
    notifyListeners();
  }

  // ---- demo data -----------------------------------------------------------
  final List<Account> accounts = List.of(seedAccounts);
  final List<BankCard> cards = List.of(seedCards);
  final List<Txn> txns = List.of(seedTxns);
  final List<Beneficiary> beneficiaries = List.of(seedBeneficiaries);
  final List<Approval> approvals = List.of(seedApprovals);
  final List<AuditEntry> audit = List.of(seedAudit);
  final List<TeamMember> team = List.of(seedTeam);

  double get totalBalance =>
      accounts.fold(0, (sum, a) => sum + a.balance);

  double get monthIn => txns
      .where((t) => t.isCredit)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthOut => txns
      .where((t) => !t.isCredit)
      .fold(0.0, (sum, t) => sum + t.amount.abs());

  // ---- mutations -----------------------------------------------------------
  void toggleFreeze(BankCard card) {
    card.frozen = !card.frozen;
    notifyListeners();
  }

  void setCanApprove(TeamMember member, bool value) {
    member.canApprove = value;
    notifyListeners();
  }

  void resolveApproval(Approval approval) {
    approvals.removeWhere((a) => a.id == approval.id);
    notifyListeners();
  }
}
