// The POCKET composition, on one page: `pocket-drift`, `pocket-balance`, the
// card key light, the card flip and the six spot drawings — in both
// brightnesses and both directions.
//
// It is here rather than in `main.dart` because it is the reference render for
// a composition, not a widget catalogue entry: the argument of `pocket-balance`
// is what it LEAVES OUT, and you cannot see that in a list of components.
//
// Run it on a phone, not a desktop window:
//   flutter run -t lib/pocket_showcase_main.dart
//
// The faces come from the registry (`google_fonts`), not from bundled assets:
// `Reem Kufi` and `Readex Pro` are both in `kFonts`, and a published package's
// `example/` is bundled by `pub publish` — 600KB of TTF would ride along with
// every install of the library for the sake of one page.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// The brandprint this page exists to show. It is a REFERENCE of the levers,
/// not a client's identity: the seeds are the generic warm-navy pair the
/// pocket composition was designed against.
const BrandprintConfig kPocketBrandprint = BrandprintConfig(
  primary: Seed(l: 0.40, c: 0.125, h: 264),
  tertiary: Seed(l: 0.615, c: 0.205, h: 32),
  accentOnTertiary: true,
  warmGround: true,
  corners: Corners(xs: 12, sm: 18, md: 24, lg: 30, xl: 38, xxl: 52),
  displayWeight: 700,
  displayTracking: -0.03,
  fontDisplay: 'Reem Kufi',
  fontText: 'Readex Pro',
  fontNum: 'Readex Pro',
  loginShell: 'pocket-drift',
  dashboardHero: 'pocket-balance',
  contentTone: 'light-instant',
  glassTint: 'navy-steel',
  motion: 'light-quick-crisp',
  motif: 'arrow-drift',
  navShell: 'rule-bar',
  actionRow: 'rule-grid',
);

void main() => runApp(const PocketShowcaseApp());

class PocketShowcaseApp extends StatefulWidget {
  const PocketShowcaseApp({super.key});

  @override
  State<PocketShowcaseApp> createState() => _PocketShowcaseAppState();
}

// The page's state is also settable from the launch, so a capture sweep does
// not have to click anything: clicking a simulator means driving the HOST's
// mouse, and a blind click on someone's desktop is a bad way to take a
// screenshot. `--dart-define=SECTION=cards|art`, `--dart-define=RTL=true`,
// and the platform's own appearance for brightness.
const String _kSection = String.fromEnvironment('SECTION', defaultValue: 'home');
const bool _kRtl = bool.fromEnvironment('RTL');
const bool _kRevealed = bool.fromEnvironment('REVEALED');

class _PocketShowcaseAppState extends State<PocketShowcaseApp> {
  bool? _darkOverride;
  bool _rtl = _kRtl;

  bool _isDark(BuildContext context) =>
      _darkOverride ?? MediaQuery.platformBrightnessOf(context) == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final dark = _isDark(context);
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: NeptuneTheme.fromConfig(
          kPocketBrandprint,
          brightness: dark ? Brightness.dark : Brightness.light,
          arabic: _rtl,
        ),
        home: Directionality(
          textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
          child: _Showcase(
            dark: dark,
            rtl: _rtl,
            onDark: (v) => setState(() => _darkOverride = v),
            onRtl: (v) => setState(() => _rtl = v),
          ),
        ),
      );
    });
  }
}

class _Showcase extends StatefulWidget {
  const _Showcase({
    required this.dark,
    required this.rtl,
    required this.onDark,
    required this.onRtl,
  });

  final bool dark;
  final bool rtl;
  final ValueChanged<bool> onDark;
  final ValueChanged<bool> onRtl;

  @override
  State<_Showcase> createState() => _ShowcaseState();
}

class _ShowcaseState extends State<_Showcase> {
  bool _revealed = _kRevealed;
  bool _flipped = _kRevealed;
  int _section = switch (_kSection) { 'cards' => 1, 'art' => 2, _ => 0 };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rtl = widget.rtl;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Switcher(
              dark: widget.dark,
              rtl: widget.rtl,
              onDark: widget.onDark,
              onRtl: widget.onRtl,
              section: _section,
              onSection: (v) => setState(() => _section = v),
            ),
            Expanded(
              child: switch (_section) {
                0 => _home(rtl),
                1 => _cards(),
                _ => _art(),
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NeptuneDock(
        shell: NeptuneDockShell.rule,
        items: [
          NeptuneDockItem(
              icon: Icons.home_outlined,
              label: rtl ? 'الرئيسية' : 'Home',
              active: true),
          NeptuneDockItem(
              icon: Icons.account_balance_wallet_outlined,
              label: rtl ? 'الحسابات' : 'Accounts'),
          NeptuneDockItem(
              icon: Icons.credit_card, label: rtl ? 'البطاقات' : 'Cards'),
          NeptuneDockItem(
              icon: Icons.more_horiz, label: rtl ? 'المزيد' : 'More'),
        ],
      ),
      backgroundColor: scheme.surface,
    );
  }

  Widget _home(bool rtl) => ListView(
        padding: const EdgeInsetsDirectional.only(bottom: 32),
        children: [
          const SizedBox(height: 8),
          NeptunePocketBalance(
            eyebrow: rtl ? 'الرصيد المتاح  LYD' : 'AVAILABLE BALANCE  LYD',
            amount: '12,480.500',
            revealed: _revealed,
            revealLabel: rtl ? 'الرصيد المتاح' : 'Available balance',
            onRevealChanged: (v) => setState(() => _revealed = v),
            verbs: [
              NeptunePocketVerb(
                  label: rtl ? 'تحويل' : 'Transfer',
                  icon: Icons.north_east,
                  lead: true,
                  onTap: () {}),
              NeptunePocketVerb(
                  label: rtl ? 'كيو آر' : 'QR',
                  icon: Icons.qr_code_scanner,
                  onTap: () {}),
              NeptunePocketVerb(
                  label: rtl ? 'قسائم' : 'Vouchers',
                  icon: Icons.confirmation_number_outlined,
                  onTap: () {}),
              NeptunePocketVerb(
                  label: rtl ? 'خدمات' : 'Services',
                  icon: Icons.grid_view_outlined,
                  onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            child: NeptuneEyebrow(rtl ? 'الحركات المالية' : 'ACTIVITY'),
          ),
          const SizedBox(height: 8),
          for (final row in const [
            ('Salary — September', '5 Sep 2026', '+3,250.000'),
            ('Al-Madina Supermarket', '4 Sep 2026', '184.250'),
            ('Libyana top-up', '3 Sep 2026', '20.000'),
          ])
            NeptuneTransactionRow(
              title: row.$1,
              subtitle: row.$2,
              amount: row.$3,
              isCredit: row.$3.startsWith('+'),
              icon: Icons.receipt_long_outlined,
            ),
        ],
      );

  Widget _cards() => ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 32),
        children: [
          // The one motion moment a card owns: it is a physical object with
          // two faces, and turning it over is the only honest way to show the
          // second one.
          NeptuneCardFlip(
            showBack: _flipped,
            semanticLabel: 'Turn the card over',
            onTap: () => setState(() => _flipped = !_flipped),
            front: const NeptuneCardArt(
              holder: 'F. AL-MISRATI',
              last4: '4471',
              expiry: '08/29',
              scheme: 'MASTERCARD',
            ),
            back: const NeptuneCardArt(
              holder: 'CVV 4 2 9',
              last4: '4471',
              expiry: '08/29',
              scheme: 'BACK',
              virtual: true,
            ),
          ),
          const SizedBox(height: 20),
          const NeptuneCardArt(
            holder: 'F. AL-MISRATI',
            last4: '9082',
            expiry: '02/30',
            scheme: 'LOCAL',
            virtual: true,
          ),
        ],
      );

  Widget _art() => GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 32),
        childAspectRatio: 0.9,
        children: [
          for (final kind in NptSpotArtKind.values)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NeptuneSpotArt(kind, size: 120),
                const SizedBox(height: 8),
                Text(kind.name,
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
        ],
      );
}

class _Switcher extends StatelessWidget {
  const _Switcher({
    required this.dark,
    required this.rtl,
    required this.onDark,
    required this.onRtl,
    required this.section,
    required this.onSection,
  });

  final bool dark;
  final bool rtl;
  final ValueChanged<bool> onDark;
  final ValueChanged<bool> onRtl;
  final int section;
  final ValueChanged<int> onSection;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerLow,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          for (final (i, label) in const [(0, 'Home'), (1, 'Cards'), (2, 'Art')])
            TextButton(
              onPressed: () => onSection(i),
              child: Text(label,
                  style: TextStyle(
                      fontWeight:
                          section == i ? FontWeight.w700 : FontWeight.w400)),
            ),
          const Spacer(),
          IconButton(
            tooltip: 'Direction',
            onPressed: () => onRtl(!rtl),
            icon: Text(rtl ? 'AR' : 'EN',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          IconButton(
            tooltip: 'Brightness',
            onPressed: () => onDark(!dark),
            icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
    );
  }
}
