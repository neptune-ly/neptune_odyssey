// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The composed screen templates from site/templates.html — library-level,
// data-parameterised, theme-only. Together with NeptuneWelcome (its own file)
// they cover all nine published templates: auth/OTP, KYC, retail dashboard,
// cards, transfer flow, wallet home and corporate approvals. Each template is
// a plain widget: hand it your data + callbacks and it wears the active brand.

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../widgets/neptune_balance_card.dart';
import '../widgets/neptune_corporate.dart';
import '../widgets/neptune_form_fields.dart';
import '../widgets/neptune_display.dart';
import '../widgets/neptune_secure_inputs.dart';
import '../widgets/neptune_stat_card.dart';
import '../widgets/neptune_buttons.dart';
import '../widgets/neptune_card_art.dart';
import '../widgets/neptune_card_controls.dart';
import '../widgets/neptune_data_viz.dart';
import '../widgets/neptune_money_inputs.dart';
import '../widgets/neptune_money_movement.dart';
import '../widgets/neptune_onboarding.dart';
import '../widgets/neptune_quick_actions.dart';
import '../widgets/neptune_shell_feedback.dart';
import '../widgets/neptune_shell_nav.dart';
import '../widgets/neptune_status_motion.dart';
import '../widgets/neptune_transaction_row.dart';
import '../widgets/neptune_wallet_pay.dart';
import '../widgets/neptune_welcome.dart';

// --- Auth / Login (templates.html §auth) --------------------------------------

/// Two-step sign-in: lockup + phone/IBAN entry, then the one-time code.
/// Drive [step] (0 = credentials, 1 = OTP) and handle [onContinue]/[onVerify].
class NeptuneAuthTemplate extends StatelessWidget {
  final String brandInitial;
  final String brandName;
  final Widget? lockup;
  final int step;
  final String title;
  final String supporting;
  final String phoneLabel;
  final String otpLabel;
  final String continueLabel;
  final String verifyLabel;
  final VoidCallback? onContinue;
  final VoidCallback? onVerify;
  final ValueChanged<String>? onOtp;

  const NeptuneAuthTemplate({
    super.key,
    required this.brandInitial,
    required this.brandName,
    this.lockup,
    this.step = 0,
    this.title = 'Welcome back',
    this.supporting = 'Sign in with your phone number or IBAN.',
    this.phoneLabel = 'Phone or IBAN',
    this.otpLabel = 'Enter the 6-digit code',
    this.continueLabel = 'Continue',
    this.verifyLabel = 'Verify',
    this.onContinue,
    this.onVerify,
    this.onOtp,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final type = Theme.of(context).extension<NptType>()!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 40, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            lockup ?? NeptuneBrandLockup(initial: brandInitial, name: brandName),
            const SizedBox(height: 36),
            Text(
              title,
              style: text.headlineMedium?.copyWith(
                fontFamily: type.display,
                fontWeight: type.displayFontWeight,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              supporting,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            if (step == 0) ...[
              NeptuneTextField(label: phoneLabel, prefixIcon: Icons.person_outline),
              const SizedBox(height: 16),
              NeptuneCta(label: continueLabel, arrow: true, onPressed: onContinue),
            ] else ...[
              Text(
                otpLabel,
                style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              NeptuneOtpInput(length: 6, onChanged: onOtp),
              const SizedBox(height: 20),
              NeptuneCta(label: verifyLabel, onPressed: onVerify),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// --- KYC / Onboarding (templates.html §kyc) ------------------------------------

/// Document-capture status for one side of an ID.
enum NeptuneKycCaptureState { pending, captured, verified }

/// KYC verification step: progress stepper, two capture tiles (front/back),
/// the account-limit meter this tier unlocks, and the continue CTA.
class NeptuneKycTemplate extends StatelessWidget {
  final List<String> steps;
  final int activeStep;
  final String title;
  final String supporting;
  final String frontLabel;
  final String backLabel;
  final NeptuneKycCaptureState frontState;
  final NeptuneKycCaptureState backState;
  final double limitValue;
  final String limitLabel;
  final String limitAmount;
  final String? notice;
  final String continueLabel;
  final VoidCallback? onCaptureFront;
  final VoidCallback? onCaptureBack;
  final VoidCallback? onContinue;

  const NeptuneKycTemplate({
    super.key,
    this.steps = const ['Identity', 'Selfie', 'Done'],
    this.activeStep = 0,
    this.title = 'Verify your identity',
    this.supporting = 'Photograph both sides of your national ID.',
    this.frontLabel = 'ID — front',
    this.backLabel = 'ID — back',
    this.frontState = NeptuneKycCaptureState.captured,
    this.backState = NeptuneKycCaptureState.pending,
    this.limitValue = 0.4,
    this.limitLabel = 'Tier limit after verification',
    this.limitAmount = '5,000 / 12,500 LYD',
    this.notice,
    this.continueLabel = 'Continue',
    this.onCaptureFront,
    this.onCaptureBack,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final type = Theme.of(context).extension<NptType>()!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
        children: [
          NeptuneStepper(steps: steps, active: activeStep),
          const SizedBox(height: 20),
          Text(
            title,
            style: text.headlineSmall?.copyWith(
              fontFamily: type.display,
              fontWeight: type.displayFontWeight,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(supporting,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
                child: _CaptureTile(
                    label: frontLabel, state: frontState, onTap: onCaptureFront)),
            const SizedBox(width: 12),
            Expanded(
                child: _CaptureTile(
                    label: backLabel, state: backState, onTap: onCaptureBack)),
          ]),
          const SizedBox(height: 18),
          NeptuneLimitMeter(
              value: limitValue, label: limitLabel, amount: limitAmount),
          if (notice != null) ...[
            const SizedBox(height: 14),
            NeptuneAlert(message: notice!, tone: NeptuneAlertTone.info),
          ],
          const SizedBox(height: 20),
          NeptuneCta(label: continueLabel, arrow: true, onPressed: onContinue),
        ],
      ),
    );
  }
}

class _CaptureTile extends StatelessWidget {
  final String label;
  final NeptuneKycCaptureState state;
  final VoidCallback? onTap;

  const _CaptureTile({required this.label, required this.state, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    final (IconData icon, NeptuneStatusTone tone, String chip) = switch (state) {
      NeptuneKycCaptureState.pending => (
          Icons.photo_camera_outlined,
          NeptuneStatusTone.neutral,
          'Pending'
        ),
      NeptuneKycCaptureState.captured => (
          Icons.check_circle_outline,
          NeptuneStatusTone.warning,
          'Review'
        ),
      NeptuneKycCaptureState.verified => (
          Icons.verified_outlined,
          NeptuneStatusTone.success,
          'Verified'
        ),
    };

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: shape.rMd,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(children: [
            Icon(icon, size: 34, color: scheme.primary),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: text.labelLarge?.copyWith(color: scheme.onSurface)),
            const SizedBox(height: 8),
            NeptuneStatusChip(label: chip, tone: tone),
          ]),
        ),
      ),
    );
  }
}

// --- Retail dashboard (templates.html §dashboard) --------------------------------

/// A transaction entry for the dashboard/wallet templates.
class NeptuneTxData {
  final String title;
  final String subtitle;
  final String amount;
  final bool credit;

  const NeptuneTxData(this.title, this.subtitle, this.amount,
      {this.credit = false});
}

/// The retail home: greeting bar, hero balance, quick actions, stat pair and
/// the latest activity — the exact §dashboard composition.
class NeptuneDashboardTemplate extends StatelessWidget {
  final String greeting;
  final String customer;
  final String balanceLabel;
  final String balance;
  final String? balanceCaption;
  final List<NeptuneQuickAction> actions;
  final (String, String, String, String)? statPair; // label,value,unit,delta ×2 packed
  final String activityTitle;
  final List<NeptuneTxData> transactions;
  final Widget? leading;

  const NeptuneDashboardTemplate({
    super.key,
    this.greeting = 'Good morning',
    this.customer = 'Lina Atiya',
    this.balanceLabel = 'Available balance',
    this.balance = 'LYD 12,480.50',
    this.balanceCaption,
    this.actions = const [],
    this.statPair,
    this.activityTitle = 'Latest activity',
    this.transactions = const [],
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: Column(children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 4),
          child: Row(children: [
            leading ?? const NeptuneAvatar(initials: 'L'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting,
                        style: text.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                    Text(customer,
                        style: text.titleLarge?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w700)),
                  ]),
            ),
            NeptuneBadge(
                count: 2,
                child: Icon(Icons.notifications_none_rounded,
                    color: scheme.onSurfaceVariant)),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 110),
            children: [
              NeptuneBalanceCard(
                  label: balanceLabel,
                  amount: balance,
                  caption: balanceCaption,
                  hero: true),
              const SizedBox(height: 14),
              if (actions.isNotEmpty) NeptuneQuickActions(actions: actions),
              if (statPair != null) ...[
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                      child: NeptuneStatCard(
                          label: statPair!.$1,
                          value: statPair!.$2,
                          unit: statPair!.$3,
                          delta: statPair!.$4)),
                  const SizedBox(width: 12),
                  const Expanded(
                      child: SizedBox(
                          height: 92,
                          child: NeptuneSparkline(
                              points: [3, 4, 4, 6, 5, 7, 8]))),
                ]),
              ],
              const SizedBox(height: 8),
              NeptuneSection(
                title: activityTitle,
                child: Column(children: [
                  for (final t in transactions)
                    NeptuneTransactionRow(
                        title: t.title,
                        subtitle: t.subtitle,
                        amount: t.amount,
                        isCredit: t.credit),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// --- Cards (templates.html §cards) ------------------------------------------------

/// One card in the cards-template carousel.
class NeptuneCardData {
  final String holder;
  final String last4;
  final String expiry;
  final String scheme;
  final bool virtual;

  const NeptuneCardData({
    required this.holder,
    required this.last4,
    required this.expiry,
    required this.scheme,
    this.virtual = false,
  });
}

/// The card-management screen: title + tier, swipeable card carousel, the
/// freeze/limits/details/PIN controls, spend meter and per-card activity.
class NeptuneCardsTemplate extends StatefulWidget {
  final String title;
  final String tier;
  final List<NeptuneCardData> cards;
  final bool frozen;
  final ValueChanged<String>? onControl;
  final double limitValue;
  final String limitLabel;
  final String limitAmount;
  final String activityTitle;
  final List<NeptuneTxData> transactions;
  final String addLabel;
  final VoidCallback? onAddCard;

  const NeptuneCardsTemplate({
    super.key,
    this.title = 'My cards',
    this.tier = 'Gold',
    this.cards = const [],
    this.frozen = false,
    this.onControl,
    this.limitValue = 0.62,
    this.limitLabel = 'Monthly spend',
    this.limitAmount = '620 / 1,000 LYD',
    this.activityTitle = 'This card',
    this.transactions = const [],
    this.addLabel = 'Add card',
    this.onAddCard,
  });

  @override
  State<NeptuneCardsTemplate> createState() => _NeptuneCardsTemplateState();
}

class _NeptuneCardsTemplateState extends State<NeptuneCardsTemplate> {
  final PageController _page = PageController(viewportFraction: 0.92);
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final type = Theme.of(context).extension<NptType>()!;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 110),
        children: [
          Row(children: [
            Expanded(
              child: Text(widget.title,
                  style: text.headlineSmall?.copyWith(
                      fontFamily: type.display,
                      fontWeight: type.displayFontWeight,
                      color: scheme.onSurface)),
            ),
            NeptuneTierBadge(tier: widget.tier),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            height: 210,
            child: PageView(
              controller: _page,
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                for (final c in widget.cards)
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.symmetric(horizontal: 6),
                    child: NeptuneCardArt(
                      holder: c.holder,
                      last4: c.last4,
                      expiry: c.expiry,
                      scheme: c.scheme,
                      virtual: c.virtual,
                      selected: widget.cards.indexOf(c) == _index,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          NeptuneCardControls(
              frozen: widget.frozen, onControl: widget.onControl ?? (_) {}),
          const SizedBox(height: 14),
          NeptuneLimitMeter(
              value: widget.limitValue,
              label: widget.limitLabel,
              amount: widget.limitAmount),
          const SizedBox(height: 8),
          NeptuneSection(
            title: widget.activityTitle,
            child: Column(children: [
              for (final t in widget.transactions)
                NeptuneTransactionRow(
                    title: t.title,
                    subtitle: t.subtitle,
                    amount: t.amount,
                    isCredit: t.credit),
            ]),
          ),
          const SizedBox(height: 8),
          NeptuneAddCard(label: widget.addLabel, onTap: widget.onAddCard),
        ],
      ),
    );
  }
}

// --- Transfer flow (templates.html §transfer) ---------------------------------

/// A payee for the transfer template.
class NeptunePayeeData {
  final String name;
  final String account;

  const NeptunePayeeData(this.name, this.account);
}

/// The three-step transfer flow: amount + beneficiary → review → outcome.
/// Fully driven: [step] 0..2; the outcome step renders the linked
/// hourglass → success/rejected motion via [outcome].
class NeptuneTransferTemplate extends StatelessWidget {
  final int step;
  final List<String> steps;
  final String amount;
  final String currency;
  final List<NeptunePayeeData> payees;
  final int selectedPayee;
  final ValueChanged<int>? onPayee;
  final String reviewFrom;
  final String fee;
  final String continueLabel;
  final String confirmLabel;
  final VoidCallback? onContinue;
  final VoidCallback? onConfirm;
  final NeptuneFlowStatus outcome;
  final String sendingTitle;
  final String successTitle;
  final String rejectedTitle;
  final String doneLabel;
  final VoidCallback? onDone;

  const NeptuneTransferTemplate({
    super.key,
    this.step = 0,
    this.steps = const ['Amount', 'Review', 'Done'],
    this.amount = '250.00',
    this.currency = 'LYD',
    this.payees = const [],
    this.selectedPayee = 0,
    this.onPayee,
    this.reviewFrom = 'Everyday •••• 4821',
    this.fee = '0.00',
    this.continueLabel = 'Continue',
    this.confirmLabel = 'Confirm & send',
    this.onContinue,
    this.onConfirm,
    this.outcome = NeptuneFlowStatus.loading,
    this.sendingTitle = 'Sending…',
    this.successTitle = 'Transfer sent',
    this.rejectedTitle = 'Transfer failed',
    this.doneLabel = 'Done',
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final payee = payees.isEmpty
        ? const NeptunePayeeData('—', '')
        : payees[selectedPayee.clamp(0, payees.length - 1)];

    if (step >= 2) {
      final sending = outcome == NeptuneFlowStatus.loading;
      final failed = outcome == NeptuneFlowStatus.rejected;
      return Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            NeptuneStatusMotion(status: outcome, size: 116),
            const SizedBox(height: 22),
            Text(
                sending
                    ? sendingTitle
                    : (failed ? rejectedTitle : successTitle),
                style: text.headlineSmall?.copyWith(color: scheme.onSurface)),
            const SizedBox(height: 8),
            Text('$currency $amount → ${payee.name}',
                style:
                    text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 26),
            if (!sending)
              NeptuneCta(label: doneLabel, onPressed: onDone, expand: false),
          ]),
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 110),
        children: [
          NeptuneStepper(steps: steps, active: step),
          const SizedBox(height: 18),
          if (step == 0) ...[
            NeptuneAmountInput(value: amount, currency: currency),
            const SizedBox(height: 14),
            NeptuneSection(
              title: 'Beneficiaries',
              child: Column(children: [
                for (var i = 0; i < payees.length; i++)
                  NeptuneBeneficiaryTile(
                    name: payees[i].name,
                    account: payees[i].account,
                    selected: i == selectedPayee,
                    onTap: onPayee == null ? null : () => onPayee!(i),
                  ),
              ]),
            ),
            const SizedBox(height: 16),
            NeptuneCta(label: continueLabel, arrow: true, onPressed: onContinue),
          ] else ...[
            NeptuneTransferReview(
              fromLabel: reviewFrom,
              toLabel: payee.name,
              amount: amount,
              fee: fee,
              total: amount,
              currency: currency,
            ),
            const SizedBox(height: 16),
            NeptuneCta(label: confirmLabel, arrow: true, onPressed: onConfirm),
          ],
        ],
      ),
    );
  }
}

// --- Wallet home (templates.html §wallet) ---------------------------------------

/// The payment-led wallet home: tiered header, wallet hero, pay actions,
/// merchants, QR pay and a voucher.
class NeptuneWalletTemplate extends StatelessWidget {
  final String title;
  final String tier;
  final String balanceLabel;
  final String balance;
  final List<NeptuneQuickAction> actions;
  final String merchantsTitle;
  final List<(String, String, String, String)> merchants; // name,cat,amount,time
  final String qrAmount;
  final String? qrMerchant;
  final (String, String, String, String)? voucher; // title,value,code,expiry

  const NeptuneWalletTemplate({
    super.key,
    this.title = 'Wallet',
    this.tier = 'Gold',
    this.balanceLabel = 'Wallet balance',
    this.balance = 'LYD 842.00',
    this.actions = const [],
    this.merchantsTitle = 'Recent merchants',
    this.merchants = const [],
    this.qrAmount = 'LYD 45.00',
    this.qrMerchant,
    this.voucher,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final type = Theme.of(context).extension<NptType>()!;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 110),
        children: [
          Row(children: [
            Expanded(
              child: Text(title,
                  style: text.headlineSmall?.copyWith(
                      fontFamily: type.display,
                      fontWeight: type.displayFontWeight,
                      color: scheme.onSurface)),
            ),
            NeptuneTierBadge(tier: tier),
          ]),
          const SizedBox(height: 14),
          NeptuneBalanceCard(label: balanceLabel, amount: balance, hero: true),
          const SizedBox(height: 14),
          if (actions.isNotEmpty) NeptuneQuickActions(actions: actions),
          const SizedBox(height: 8),
          NeptuneSection(
            title: merchantsTitle,
            child: Column(children: [
              for (final m in merchants)
                NeptuneMerchantRow(
                    name: m.$1, category: m.$2, amount: m.$3, time: m.$4),
            ]),
          ),
          const SizedBox(height: 8),
          NeptuneQrPay(amount: qrAmount, merchant: qrMerchant),
          if (voucher != null) ...[
            const SizedBox(height: 14),
            NeptuneVoucherCard(
                title: voucher!.$1,
                value: voucher!.$2,
                code: voucher!.$3,
                expiry: voucher!.$4),
          ],
        ],
      ),
    );
  }
}

// --- Corporate approvals (templates.html §corporate — web layout) ---------------

/// A pending approval for the corporate template.
class NeptuneApprovalData {
  final String title;
  final String subtitle;
  final String amount;

  const NeptuneApprovalData(this.title, this.subtitle, this.amount);
}

/// The corporate approvals workspace: side nav, page header and the approval
/// queue with batches + audit trail. Collapses below [NeptuneAppShell]'s
/// breakpoint like the web.
class NeptuneCorporateTemplate extends StatelessWidget {
  final String navTitle;
  final int navIndex;
  final List<(IconData, String)> navItems;
  final ValueChanged<int>? onNav;
  final String title;
  final String? subtitle;
  final List<NeptuneApprovalData> approvals;
  final void Function(int index, bool approved)? onDecide;
  final (String, String, String, String)? batch; // title,count,total,status
  final List<(String, String, String)> audit; // actor,action,time

  const NeptuneCorporateTemplate({
    super.key,
    this.navTitle = 'Corporate',
    this.navIndex = 0,
    this.navItems = const [
      (Icons.fact_check_outlined, 'Approvals'),
      (Icons.groups_outlined, 'Batches'),
      (Icons.receipt_long_outlined, 'Audit'),
    ],
    this.onNav,
    this.title = 'Approvals',
    this.subtitle,
    this.approvals = const [],
    this.onDecide,
    this.batch,
    this.audit = const [],
  });

  @override
  Widget build(BuildContext context) {
    return NeptuneAppShell(
      nav: NeptuneSideNav(children: [
        for (var i = 0; i < navItems.length; i++)
          NeptuneSideNavItem(
            icon: navItems[i].$1,
            label: navItems[i].$2,
            active: i == navIndex,
            onTap: onNav == null ? null : () => onNav!(i),
          ),
      ]),
      child: ListView(
        children: [
          NeptunePageHeader(title: title, subtitle: subtitle),
          for (var i = 0; i < approvals.length; i++) ...[
            NeptuneApprovalItem(
              title: approvals[i].title,
              subtitle: approvals[i].subtitle,
              amount: approvals[i].amount,
              onApprove: onDecide == null ? null : () => onDecide!(i, true),
              onReject: onDecide == null ? null : () => onDecide!(i, false),
            ),
            const SizedBox(height: 10),
          ],
          if (batch != null) ...[
            const SizedBox(height: 4),
            NeptuneBatchCard(
                title: batch!.$1,
                count: batch!.$2,
                total: batch!.$3,
                status: batch!.$4),
          ],
          if (audit.isNotEmpty) ...[
            const SizedBox(height: 12),
            NeptuneSection(
              title: 'Audit trail',
              child: Column(children: [
                for (final a in audit)
                  NeptuneAuditRow(actor: a.$1, action: a.$2, time: a.$3),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}
