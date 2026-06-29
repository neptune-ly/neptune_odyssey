// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Seeded demo data so every screen has realistic content out of the box. This is
// the only place with hard-coded values; swap it for a repository/API later.

import 'models.dart';

const List<Account> seedAccounts = [
  Account(
    id: 'a1',
    name: 'Everyday',
    kind: AccountKind.current,
    maskedNumber: '•••• 4821',
    iban: 'LY83 0020 0001 2345 6789 01',
    balance: 12480.50,
  ),
  Account(
    id: 'a2',
    name: 'Savings',
    kind: AccountKind.savings,
    maskedNumber: '•••• 7390',
    iban: 'LY55 0021 0009 8765 4321 09',
    balance: 38250.00,
  ),
  Account(
    id: 'a3',
    name: 'Business',
    kind: AccountKind.business,
    maskedNumber: '•••• 1180',
    iban: 'LY12 0040 0005 5544 3322 11',
    balance: 154920.75,
    currency: 'LYD',
  ),
];

final List<BankCard> seedCards = [
  BankCard(
    id: 'c1',
    holder: 'LINA ATIYA',
    last4: '4821',
    expiry: '08/27',
    scheme: CardScheme.visa,
    label: 'Everyday debit',
    monthlySpend: 620,
    monthlyLimit: 1000,
  ),
  BankCard(
    id: 'c2',
    holder: 'LINA ATIYA',
    last4: '6642',
    expiry: '03/28',
    scheme: CardScheme.mastercard,
    label: 'Travel credit',
    monthlySpend: 1840,
    monthlyLimit: 5000,
  ),
];

const List<Txn> seedTxns = [
  Txn(id: 't1', title: 'Salary', subtitle: 'Neptune Fintech', amount: 3200.00, date: 'Today', category: 'Income'),
  Txn(id: 't2', title: 'Coffee Bar', subtitle: 'Card •••• 4821', amount: -4.50, date: 'Today', category: 'Food'),
  Txn(id: 't3', title: 'Grocery Market', subtitle: 'Card •••• 4821', amount: -86.40, date: 'Yesterday', category: 'Groceries'),
  Txn(id: 't4', title: 'Transfer to Sara N.', subtitle: 'Bank transfer', amount: -250.00, date: 'Yesterday', category: 'Transfer'),
  Txn(id: 't5', title: 'Pharmacy', subtitle: 'Card •••• 6642', amount: -32.10, date: 'Mon', category: 'Health'),
  Txn(id: 't6', title: 'Refund — Bookstore', subtitle: 'Card •••• 4821', amount: 18.00, date: 'Mon', category: 'Refund'),
  Txn(id: 't7', title: 'Electricity', subtitle: 'GECOL', amount: -74.20, date: 'Sun', category: 'Bills'),
  Txn(id: 't8', title: 'Fuel', subtitle: 'Card •••• 6642', amount: -45.00, date: 'Sun', category: 'Transport'),
  Txn(id: 't9', title: 'Top up — Wallet', subtitle: 'From Everyday', amount: -100.00, date: 'Sat', category: 'Wallet'),
  Txn(id: 't10', title: 'Restaurant', subtitle: 'Card •••• 4821', amount: -64.80, date: 'Sat', category: 'Food'),
  Txn(id: 't11', title: 'Freelance invoice', subtitle: 'Atlas Co.', amount: 900.00, date: 'Fri', category: 'Income'),
  Txn(id: 't12', title: 'Streaming', subtitle: 'Card •••• 6642', amount: -12.99, date: 'Fri', category: 'Subscriptions'),
];

const List<Beneficiary> seedBeneficiaries = [
  Beneficiary(id: 'b1', name: 'Sara Nuri', maskedAccount: '•••• 7390', bank: 'Neptune Bank'),
  Beneficiary(id: 'b2', name: 'Omar Khaled', maskedAccount: '•••• 2204', bank: 'Sahara Bank'),
  Beneficiary(id: 'b3', name: 'Atlas Co.', maskedAccount: '•••• 8810', bank: 'Jumhouria Bank'),
  Beneficiary(id: 'b4', name: 'Yusra Ben Ali', maskedAccount: '•••• 5567', bank: 'Neptune Bank'),
];

const List<Approval> seedApprovals = [
  Approval(id: 'p1', title: 'June payroll batch', subtitle: '42 payments', amount: 18200),
  Approval(id: 'p2', title: 'Supplier — Atlas Co.', subtitle: 'Invoice #4471', amount: 6400),
  Approval(id: 'p3', title: 'Vendor — GECOL', subtitle: 'Utilities Q2', amount: 2150),
];

const List<AuditEntry> seedAudit = [
  AuditEntry(actor: 'Lina A.', action: 'Approved transfer LYD 250.00', time: '12:04'),
  AuditEntry(actor: 'Omar K.', action: 'Created payroll batch (42)', time: '11:38'),
  AuditEntry(actor: 'System', action: 'Card •••• 6642 limit changed', time: '10:02'),
  AuditEntry(actor: 'Yusra B.', action: 'Added beneficiary Atlas Co.', time: 'Yesterday'),
];

final List<TeamMember> seedTeam = [
  TeamMember(name: 'Lina Atiya', role: 'Owner', status: 'Active', canApprove: true),
  TeamMember(name: 'Omar Khaled', role: 'Approver', status: 'Active', canApprove: true),
  TeamMember(name: 'Yusra Ben Ali', role: 'Accountant', status: 'Active'),
  TeamMember(name: 'Sami Trabelsi', role: 'Viewer', status: 'Invited'),
];
