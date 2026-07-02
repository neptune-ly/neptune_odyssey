// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// NeptuneDemoShell — a complete, running white-label demo app in ~10 lines.
// Composes the Welcome template + a 5-tab in-context shell (Home/Transfer/
// Cards/Insights/Profile) from the existing screen templates, wired to any
// BrandprintConfig — a client's real logo and colours in, a full bilingual
// (EN/AR) app out. This is what packages/create-neptune's `--client` flag and
// the desktop demo-factory app both build on: they only need to supply a
// config + a logo; every screen, string and interaction is already here.
// Theme-only, RTL-safe.

import 'package:flutter/material.dart';

import '../brandprint/codec.dart';
import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';
import '../widgets/neptune_buttons.dart';
import '../widgets/neptune_charts.dart';
import '../widgets/neptune_data_viz.dart';
import '../widgets/neptune_display.dart';
import '../widgets/neptune_dock.dart';
import '../widgets/neptune_fintech.dart';
import '../widgets/neptune_onboarding.dart';
import '../widgets/neptune_quick_actions.dart';
import '../widgets/neptune_selection_controls.dart';
import '../widgets/neptune_stat_card.dart';
import '../widgets/neptune_status_motion.dart';
import '../widgets/neptune_wallet_pay.dart';
import '../widgets/neptune_welcome.dart';
import 'neptune_templates.dart';

/// The bilingual copy a [NeptuneDemoShell] needs. Every field has a sensible
/// default in English/Arabic; override only what your client wants changed.
class NeptuneDemoStrings {
  final bool arabic;
  const NeptuneDemoStrings({this.arabic = false});

  String t(String en, String ar) => arabic ? ar : en;

  String get welcomeTitle => t('Banking that', 'مصرفيتك مع');
  String get welcomeEmphasis => t('moves with you.', 'الخليج الأول.');
  String get welcomeSub => t(
      'One account, every currency — send, spend and save, beautifully.',
      'حساب واحد لكل العملات — إرسال وإنفاق وادخار، بأناقة.');
  String get getStarted => t('Get started', 'ابدأ الآن');
  String get haveAccount => t('I already have an account', 'لديّ حساب بالفعل');
  String get goodMorning => t('Good morning', 'صباح الخير');
  String get availableBalance => t('Available balance', 'الرصيد المتاح');
  String get navHome => t('Home', 'الرئيسية');
  String get navTransfer => t('Transfer', 'تحويل');
  String get navCards => t('Cards', 'البطاقات');
  String get navInsights => t('Insights', 'إحصاءات');
  String get navProfile => t('Profile', 'حسابي');
  String get send => t('Send', 'إرسال');
  String get topUp => t('Top up', 'شحن');
  String get pay => t('Pay', 'الدفع');
  String get request => t('Request', 'طلب');
  String get recentActivity => t('Recent activity', 'آخر الحركات');
  String get sendTransfer => t('Send & transfer', 'الإرسال والتحويل');
  String get confirmSend => t('Confirm & send', 'تأكيد وإرسال');
  String get sendingTitle => t('Sending…', 'جارٍ الإرسال…');
  String get sendingSub =>
      t('Securely processing your transfer', 'نعالج تحويلك بأمان');
  String get successTitle => t('Transfer sent', 'تم التحويل بنجاح');
  String get doneLabel => t('Done', 'تم');
  String get myCards => t('My cards', 'بطاقاتي');
  String get thisMonth => t('This month', 'هذا الشهر');
  String get lastMonth => t('Last month', 'الشهر الماضي');
  String get spendByCategory => t('Spend by category', 'الإنفاق حسب الفئة');
  String get appearance => t('Appearance', 'المظهر');
  String get themeRow => t('Dark mode', 'الوضع الداكن');
  String get language => t('Language', 'اللغة');
  String get security => t('Security', 'الأمان');
  String get biometric => t('Biometric login', 'الدخول بالبصمة');
  String get logout => t('Log out', 'تسجيل الخروج');
  String get food => t('Food', 'مأكولات');
  String get bills => t('Bills', 'فواتير');
  String get transport => t('Transport', 'مواصلات');
  String get shopping => t('Shopping', 'تسوّق');
  String get salary => t('Salary', 'راتب');
  String get groceryMarket => t('Grocery Market', 'سوق المواد الغذائية');
  String get coffeeBar => t('Coffee Bar', 'مقهى');
  String get today => t('Today', 'اليوم');
  String get yesterday => t('Yesterday', 'أمس');
}

/// A complete, running branded demo app: the Welcome template, then a 5-tab
/// glass-dock shell (Home/Transfer/Cards/Insights/Profile) built entirely
/// from the existing Neptune Odyssey template widgets. Supply a
/// [BrandprintConfig] (a client's real seeds) and a [logo] (their real mark)
/// — everything else has a working default so the demo runs immediately.
class NeptuneDemoShellApp extends StatefulWidget {
  final BrandprintConfig brandprint;
  final String bankNameEn;
  final String bankNameAr;
  final Widget logo;
  final bool startArabic;
  final String customerName;
  final String customerNameAr;

  const NeptuneDemoShellApp({
    super.key,
    required this.brandprint,
    required this.bankNameEn,
    required this.bankNameAr,
    required this.logo,
    this.startArabic = false,
    this.customerName = 'Lina Atiya',
    this.customerNameAr = 'لينا عطية',
  });

  @override
  State<NeptuneDemoShellApp> createState() => _NeptuneDemoShellAppState();
}

class _NeptuneDemoShellAppState extends State<NeptuneDemoShellApp> {
  late bool _arabic = widget.startArabic;
  bool _dark = false;
  bool _inApp = false;

  @override
  Widget build(BuildContext context) {
    final l = NeptuneDemoStrings(arabic: _arabic);
    final bankName = _arabic ? widget.bankNameAr : widget.bankNameEn;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: bankName,
      theme: NeptuneTheme.fromConfig(widget.brandprint,
          brightness: Brightness.light, arabic: _arabic),
      darkTheme: NeptuneTheme.fromConfig(widget.brandprint,
          brightness: Brightness.dark, arabic: _arabic),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => Directionality(
        textDirection: _arabic ? TextDirection.rtl : TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
      home: _inApp
          ? _DemoTabShell(
              l: l,
              bankName: bankName,
              logo: widget.logo,
              customerName: _arabic ? widget.customerNameAr : widget.customerName,
              dark: _dark,
              arabic: _arabic,
              onToggleDark: (v) => setState(() => _dark = v),
              onToggleArabic: (v) => setState(() => _arabic = v),
              onLogout: () => setState(() => _inApp = false),
            )
          : Scaffold(
              body: Stack(children: [
                NeptuneWelcome(
                  brandInitial: bankName.characters.first,
                  brandName: bankName,
                  lockup: _BrandLockup(logo: widget.logo, name: bankName),
                  title: l.welcomeTitle,
                  emphasis: l.welcomeEmphasis,
                  supporting: l.welcomeSub,
                  primaryAction: NeptuneCta(
                    label: l.getStarted,
                    arrow: true,
                    onPressed: () => setState(() => _inApp = true),
                  ),
                  secondaryAction: NeptuneCta(
                    label: l.haveAccount,
                    tonal: true,
                    onPressed: () => setState(() => _inApp = true),
                  ),
                ),
                PositionedDirectional(
                  top: 18,
                  end: 18,
                  child: SafeArea(
                    child: NeptuneChip(
                      label: _arabic ? 'English' : 'العربية',
                      onTap: () => setState(() => _arabic = !_arabic),
                    ),
                  ),
                ),
              ]),
            ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  final Widget logo;
  final String name;

  const _BrandLockup({required this.logo, required this.name});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final type = Theme.of(context).extension<NptType>()!;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      logo,
      const SizedBox(width: 11),
      Text(name,
          style: TextStyle(
            fontFamily: type.display,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: scheme.onSurface,
          )),
    ]);
  }
}

class _DemoTabShell extends StatefulWidget {
  final NeptuneDemoStrings l;
  final String bankName;
  final Widget logo;
  final String customerName;
  final bool dark;
  final bool arabic;
  final ValueChanged<bool> onToggleDark;
  final ValueChanged<bool> onToggleArabic;
  final VoidCallback onLogout;

  const _DemoTabShell({
    required this.l,
    required this.bankName,
    required this.logo,
    required this.customerName,
    required this.dark,
    required this.arabic,
    required this.onToggleDark,
    required this.onToggleArabic,
    required this.onLogout,
  });

  @override
  State<_DemoTabShell> createState() => _DemoTabShellState();
}

class _DemoTabShellState extends State<_DemoTabShell> {
  int _tab = 0;
  int _transferStep = 0;
  NeptuneFlowStatus? _sendState;

  Future<void> _send() async {
    setState(() => _sendState = NeptuneFlowStatus.loading);
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (mounted) setState(() => _sendState = NeptuneFlowStatus.success);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final scheme = Theme.of(context).colorScheme;

    final screens = [
      NeptuneDashboardTemplate(
        greeting: l.goodMorning,
        customer: widget.customerName,
        balanceLabel: l.availableBalance,
        balance: 'LYD 24,830.75',
        balanceCaption: '•••• 4821',
        leading: SizedBox(width: 26, child: widget.logo),
        actions: [
          NeptuneQuickAction(icon: Icons.north_east, label: l.send, onTap: () {}),
          NeptuneQuickAction(icon: Icons.add_card_outlined, label: l.topUp, onTap: () {}),
          NeptuneQuickAction(icon: Icons.qr_code_rounded, label: l.pay, onTap: () {}),
          NeptuneQuickAction(icon: Icons.call_received_rounded, label: l.request, onTap: () {}),
        ],
        statPair: (l.thisMonth, '3,540', 'LYD', '−2.1%'),
        activityTitle: l.recentActivity,
        transactions: [
          NeptuneTxData(l.salary, '${l.today} · ${l.sendTransfer}', '+3,200.00 LYD', credit: true),
          NeptuneTxData(l.groceryMarket, '${l.today} · ${l.navCards}', '−86.40 LYD'),
          NeptuneTxData(l.coffeeBar, '${l.yesterday} · ${l.navCards}', '−4.50 LYD'),
        ],
      ),
      _sendState == null
          ? NeptuneTransferTemplate(
              step: _transferStep,
              payees: [
                NeptunePayeeData(l.t('Sara Nuri', 'سارة نوري'), '•••• 7390'),
                NeptunePayeeData(l.t('Omar K.', 'عمر ك.'), '•••• 1204'),
              ],
              confirmLabel: l.confirmSend,
              onPayee: (_) {},
              onContinue: () => setState(() => _transferStep = 1),
              onConfirm: _send,
            )
          : Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(32),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  NeptuneStatusMotion(status: _sendState!, size: 116),
                  const SizedBox(height: 22),
                  Text(
                    _sendState == NeptuneFlowStatus.loading
                        ? l.sendingTitle
                        : l.successTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: scheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sendState == NeptuneFlowStatus.loading
                        ? l.sendingSub
                        : 'LYD 250.00',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 26),
                  if (_sendState != NeptuneFlowStatus.loading)
                    NeptuneCta(
                      label: l.doneLabel,
                      expand: false,
                      onPressed: () => setState(() {
                        _sendState = null;
                        _transferStep = 0;
                      }),
                    ),
                ]),
              ),
            ),
      _CardsTab(l: l),
      _InsightsTab(l: l),
      _ProfileTab(
        l: l,
        customerName: widget.customerName,
        dark: widget.dark,
        arabic: widget.arabic,
        onToggleDark: widget.onToggleDark,
        onToggleArabic: widget.onToggleArabic,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      backgroundColor: scheme.surface,
      extendBody: true,
      body: SafeArea(bottom: false, child: screens[_tab]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 12),
        child: NeptuneDock(items: [
          NeptuneDockItem(icon: Icons.home_rounded, label: l.navHome, active: _tab == 0, onTap: () => setState(() => _tab = 0)),
          NeptuneDockItem(icon: Icons.swap_horiz_rounded, label: l.navTransfer, active: _tab == 1, onTap: () => setState(() => _tab = 1)),
          NeptuneDockItem(icon: Icons.credit_card_rounded, label: l.navCards, active: _tab == 2, onTap: () => setState(() => _tab = 2)),
          NeptuneDockItem(icon: Icons.donut_small_rounded, label: l.navInsights, active: _tab == 3, onTap: () => setState(() => _tab = 3)),
          NeptuneDockItem(icon: Icons.person_rounded, label: l.navProfile, active: _tab == 4, onTap: () => setState(() => _tab = 4)),
        ]),
      ),
    );
  }
}

class _CardsTab extends StatefulWidget {
  final NeptuneDemoStrings l;

  const _CardsTab({required this.l});

  @override
  State<_CardsTab> createState() => _CardsTabState();
}

class _CardsTabState extends State<_CardsTab> {
  bool _frozen = false;

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return NeptuneCardsTemplate(
      title: l.myCards,
      cards: const [
        NeptuneCardData(holder: 'LINA ATIYA', last4: '4821', expiry: '08/27', scheme: 'VISA'),
      ],
      frozen: _frozen,
      onControl: (a) => setState(() {
        if (a == 'freeze') _frozen = !_frozen;
      }),
      activityTitle: l.recentActivity,
      transactions: [
        NeptuneTxData(l.groceryMarket, '${l.today} · ${l.navCards}', '−86.40 LYD'),
        NeptuneTxData(l.coffeeBar, '${l.yesterday} · ${l.navCards}', '−4.50 LYD'),
      ],
    );
  }
}

class _InsightsTab extends StatelessWidget {
  final NeptuneDemoStrings l;

  const _InsightsTab({required this.l});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 110),
      children: [
        Row(children: [
          NeptuneBudgetRing(spent: 1240, limit: 2000, label: l.thisMonth),
          const SizedBox(width: 14),
          Expanded(
            child: Column(children: [
              NeptuneStatCard(label: l.thisMonth, value: '1,240', unit: 'LYD', delta: '−12%'),
              const SizedBox(height: 10),
              const SizedBox(width: double.infinity, height: 48, child: NeptuneSparkline(points: [4, 3, 5, 4, 6, 5, 7])),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        NeptuneSection(
          title: l.spendByCategory,
          child: NeptuneCompareBars(
            currentLabel: l.thisMonth,
            previousLabel: l.lastMonth,
            data: [
              NeptuneCompareData(l.food, 430, 510),
              NeptuneCompareData(l.bills, 380, 330),
              NeptuneCompareData(l.transport, 210, 260),
              NeptuneCompareData(l.shopping, 190, 140),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const NeptuneFxCard(fromCurrency: 'LYD', toCurrency: 'USD', rate: '0.2065', change: '+0.4%'),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final NeptuneDemoStrings l;
  final String customerName;
  final bool dark;
  final bool arabic;
  final ValueChanged<bool> onToggleDark;
  final ValueChanged<bool> onToggleArabic;
  final VoidCallback onLogout;

  const _ProfileTab({
    required this.l,
    required this.customerName,
    required this.dark,
    required this.arabic,
    required this.onToggleDark,
    required this.onToggleArabic,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 110),
      children: [
        NeptuneListTile(
          leading: NeptuneAvatar(initials: customerName.characters.first, size: 48),
          title: customerName,
          trailing: const NeptuneTierBadge(tier: 'Gold'),
        ),
        const SizedBox(height: 10),
        NeptuneSection(
          title: l.appearance,
          child: Column(children: [
            NeptuneListTile(
              leadingIcon: Icons.dark_mode_outlined,
              title: l.themeRow,
              trailing: NeptuneSwitch(value: dark, onChanged: onToggleDark),
            ),
            NeptuneListTile(
              leadingIcon: Icons.translate_rounded,
              title: l.language,
              trailing: NeptuneSegmented<bool>(
                value: arabic,
                segments: const [
                  NeptuneSegment(value: false, label: 'EN'),
                  NeptuneSegment(value: true, label: 'ع'),
                ],
                onChanged: onToggleArabic,
              ),
            ),
          ]),
        ),
        NeptuneSection(
          title: l.security,
          child: NeptuneListTile(
            leadingIcon: Icons.fingerprint_rounded,
            title: l.biometric,
            trailing: NeptuneSwitch(value: true, onChanged: (_) {}),
          ),
        ),
        const SizedBox(height: 8),
        NeptuneButton(
          label: l.logout,
          variant: NeptuneButtonStyle.outlined,
          icon: Icons.logout_rounded,
          onPressed: onLogout,
        ),
      ],
    );
  }
}
