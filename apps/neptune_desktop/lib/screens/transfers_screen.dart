// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Transfer — a three-step send-money wizard (Amount → Review → Done) driven by a
// NeptuneStepper. Local wizard state (step, chosen payee, amount, source account)
// lives here; shared data/actions come from AppScope. Theme-only, RTL-safe.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../app/app_scope.dart';
import '../app/app_state.dart';
import '../app/nav.dart';
import '../data/fmt.dart';
import '../data/models.dart';
import '../widgets/content_scaffold.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  int _step = 0;
  Beneficiary? _payee;
  String _amount = '250.00';
  String _currency = 'LYD';
  int _fromIndex = 0;

  void _reset() {
    setState(() {
      _step = 0;
      _payee = null;
      _amount = '250.00';
      _currency = 'LYD';
      _fromIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final accounts = app.accounts;

    // Keep the source-account index in range if data shifts under us.
    final fromIndex =
        accounts.isEmpty ? 0 : _fromIndex.clamp(0, accounts.length - 1);

    return ContentScaffold(
      title: 'Transfer',
      subtitle: 'Send money to people and accounts.',
      actions: [
        NeptuneButton(
          label: 'Payees',
          icon: Icons.people_outline,
          variant: NeptuneButtonStyle.text,
          onPressed: () => app.go(NavDest.payees),
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 24),
          child: NeptuneStepper(
            steps: const ['Amount', 'Review', 'Done'],
            active: _step,
          ),
        ),
        if (_step == 0)
          _amountStep(context, app, accounts, fromIndex)
        else if (_step == 1)
          _reviewStep(context, accounts, fromIndex)
        else
          _doneStep(context),
      ],
    );
  }

  // ---- Step 0: Amount -------------------------------------------------------
  Widget _amountStep(
    BuildContext context,
    AppState app,
    List<Account> accounts,
    int fromIndex,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Block(
          title: 'Amount',
          description: 'How much would you like to send?',
          child: NeptuneCurrencyField(
            amount: _amount,
            currency: _currency,
            currencies: const ['LYD', 'USD', 'EUR'],
            onAmountChanged: (v) => setState(() => _amount = v),
            onCurrencyChanged: (c) => setState(() => _currency = c),
          ),
        ),
        Block(
          title: 'From',
          child: Column(
            children: [
              for (var i = 0; i < accounts.length; i++)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 8),
                  child: NeptuneMethodRow(
                    icon: Icons.account_balance,
                    title: accounts[i].name,
                    subtitle: accounts[i].maskedNumber,
                    selected: i == fromIndex,
                    onTap: () => setState(() => _fromIndex = i),
                  ),
                ),
            ],
          ),
        ),
        Block(
          title: 'To',
          child: Column(
            children: [
              for (final b in app.beneficiaries)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 8),
                  child: NeptuneBeneficiaryTile(
                    name: b.name,
                    account: b.maskedAccount,
                    selected: _payee == b,
                    onTap: () => setState(() => _payee = b),
                  ),
                ),
            ],
          ),
        ),
        NeptuneButton(
          label: 'Continue',
          icon: Icons.arrow_forward_rounded,
          expand: true,
          onPressed: _payee != null ? () => setState(() => _step = 1) : null,
        ),
      ],
    );
  }

  // ---- Step 1: Review -------------------------------------------------------
  Widget _reviewStep(
    BuildContext context,
    List<Account> accounts,
    int fromIndex,
  ) {
    final from = accounts[fromIndex];
    final payee = _payee!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Block(
          title: 'Review',
          description: 'Check the details before you send.',
          child: NeptuneTransferReview(
            fromLabel: '${from.name} • ${from.maskedNumber}',
            toLabel: payee.name,
            amount: _amount,
            fee: '0.00',
            total: _amount,
            currency: _currency,
          ),
        ),
        NeptuneButton(
          label: 'Confirm & send',
          icon: Icons.lock_outline,
          expand: true,
          onPressed: () => setState(() => _step = 2),
        ),
        const SizedBox(height: 8),
        NeptuneButton(
          label: 'Back',
          variant: NeptuneButtonStyle.text,
          expand: true,
          onPressed: () => setState(() => _step = 0),
        ),
      ],
    );
  }

  // ---- Step 2: Done ---------------------------------------------------------
  Widget _doneStep(BuildContext context) {
    final amt = double.tryParse(_amount) ?? 0;
    final payee = _payee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeptuneSuccess(
          title: 'Sent!',
          amount: money(amt, currency: _currency),
          subtitle: 'To ${payee?.name ?? 'recipient'}',
        ),
        const SizedBox(height: 8),
        NeptuneReceipt(
          title: 'Receipt',
          rows: [
            (label: 'Amount', value: money(amt, currency: _currency)),
            (label: 'Fee', value: money(0, currency: _currency)),
            (label: 'Total', value: money(amt, currency: _currency)),
          ],
          onShare: () => showNeptuneToast(context, 'Shared'),
        ),
        const SizedBox(height: 16),
        NeptuneButton(
          label: 'Done',
          icon: Icons.check_rounded,
          expand: true,
          onPressed: _reset,
        ),
      ],
    );
  }
}
