// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Neptune Odyssey Studio — the desktop client-demo factory. Drop a client's
// logo, watch the brand seeds get extracted live, tune the tone, preview the
// running Welcome screen in real time, then generate + launch a full branded
// demo (NeptuneDemoShellApp) with one click. Built on neptune_flutter_ui
// itself — Studio's own chrome AND the client preview are both real Odyssey
// widgets, not mockups.
//
// This app is dev tooling (not published); it shells `flutter build macos`
// against the sibling example app and writes the same gitignored
// lib/client_* files tools/client-demo/generate.mjs writes, so both paths to
// a client demo converge on one artifact.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';
import 'package:path/path.dart' as p;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudioApp());
}

class StudioApp extends StatelessWidget {
  const StudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neptune Odyssey Studio',
      theme: NeptuneTheme.light('proteus'),
      darkTheme: NeptuneTheme.dark('proteus'),
      themeMode: ThemeMode.system,
      home: const StudioHome(),
    );
  }
}

enum _Tone { formal, friendly, modern, calm }

const _tonePresets = <_Tone, ({
  Corners corners,
  String fontDisplay,
  String fontNum,
  int displayWeight,
  double displayTracking,
  String loginShell,
  String dashboardHero,
  String contentTone,
  String glassTint,
  String motion,
  String label,
})>{
  _Tone.formal: (
    corners: Corners(xs: 6, sm: 10, md: 14, lg: 20, xl: 28, xxl: 38),
    fontDisplay: 'Sora', fontNum: 'Sora',
    displayWeight: 700, displayTracking: -0.01,
    loginShell: 'shield-guilloche', dashboardHero: 'restrained-balance',
    contentTone: 'formal-authoritative', glassTint: 'navy-steel',
    motion: 'stable-minimal-authoritative', label: 'Formal',
  ),
  _Tone.friendly: (
    corners: Corners(xs: 12, sm: 18, md: 26, lg: 34, xl: 44, xxl: 56),
    fontDisplay: 'Bricolage Grotesque', fontNum: 'Hanken Grotesk',
    displayWeight: 700, displayTracking: -0.01,
    loginShell: 'arcade-arches', dashboardHero: 'warm-balance-cards',
    contentTone: 'warm-hospitable', glassTint: 'warm-amber',
    motion: 'calm-graceful', label: 'Friendly',
  ),
  _Tone.modern: (
    corners: Corners(xs: 4, sm: 8, md: 12, lg: 18, xl: 26, xxl: 36),
    fontDisplay: 'Space Grotesk', fontNum: 'Space Grotesk',
    displayWeight: 600, displayTracking: -0.03,
    loginShell: 'light-grid-spark', dashboardHero: 'wallet-hero',
    contentTone: 'light-instant', glassTint: 'violet-luminous',
    motion: 'light-quick-crisp', label: 'Modern',
  ),
  _Tone.calm: (
    corners: Corners(xs: 8, sm: 12, md: 16, lg: 24, xl: 32, xxl: 44),
    fontDisplay: 'Hanken Grotesk', fontNum: 'Hanken Grotesk',
    displayWeight: 700, displayTracking: -0.02,
    loginShell: 'depth-emblem', dashboardHero: 'balance-cards',
    contentTone: 'clear-calm', glassTint: 'oceanic',
    motion: 'smooth-fluid', label: 'Calm',
  ),
};

class StudioHome extends StatefulWidget {
  const StudioHome({super.key});

  @override
  State<StudioHome> createState() => _StudioHomeState();
}

enum _GenState { idle, building, launched, error }

class _StudioHomeState extends State<StudioHome> {
  Uint8List? _logoBytes;
  String? _logoPath;
  NptExtractedSeeds? _seeds;
  Oklch? _primaryOverride;
  Oklch? _accentOverride;
  _Tone _tone = _Tone.formal;
  bool _arabic = false;
  bool _dark = false;
  final _nameEn = TextEditingController(text: 'Sample Bank');
  final _nameAr = TextEditingController(text: 'مصرف تجريبي');
  _GenState _genState = _GenState.idle;
  String? _genError;

  Oklch get _primary => _primaryOverride ?? _seeds?.primary ?? const Oklch(0.48, 0.15, 258);
  Oklch get _tertiary => _accentOverride ?? _seeds?.accent ?? const Oklch(0.55, 0.10, 200);

  BrandprintConfig get _config {
    final t = _tonePresets[_tone]!;
    return BrandprintConfig(
      primary: Seed(l: _primary.l, c: _primary.c, h: _primary.h.round()),
      tertiary: Seed(l: _tertiary.l, c: _tertiary.c, h: _tertiary.h.round()),
      corners: t.corners,
      displayWeight: t.displayWeight,
      displayTracking: t.displayTracking,
      fontDisplay: t.fontDisplay,
      fontText: 'Hanken Grotesk',
      fontNum: t.fontNum,
      loginShell: t.loginShell,
      dashboardHero: t.dashboardHero,
      contentTone: t.contentTone,
      glassTint: t.glassTint,
      motion: t.motion,
    );
  }

  Future<void> _pickLogo() async {
    final file = await openFile(acceptedTypeGroups: const [
      XTypeGroup(label: 'logo', extensions: ['png', 'jpg', 'jpeg', 'pdf']),
    ]);
    if (file == null) return;

    setState(() {
      _logoPath = file.path;
      _seeds = null;
      _primaryOverride = null;
      _accentOverride = null;
    });

    var path = file.path;
    // Rasterize PDFs via macOS `sips` (built-in) — Dart has no PDF decoder.
    if (p.extension(path).toLowerCase() == '.pdf') {
      final out = p.join(Directory.systemTemp.path, 'npt_studio_logo.png');
      final r = await Process.run('sips', ['-s', 'format', 'png', '-Z', '1200', path, '--out', out]);
      if (r.exitCode != 0) {
        setState(() => _genError = 'Could not rasterize PDF: ${r.stderr}');
        return;
      }
      path = out;
    }

    // Design-tool exports (Illustrator/Figma/Sketch) are routinely tagged
    // Display P3 on macOS. dart:ui's raw pixel decode does NOT convert
    // profiled colour data to sRGB — it hands back the profile-native bytes,
    // which then get misread as sRGB and shift hues badly (a P3 navy reads
    // as azure). Normalize through the same `sips` we already shell out to,
    // so extraction always sees true sRGB bytes.
    final srgbOut = p.join(Directory.systemTemp.path, 'npt_studio_logo_srgb.png');
    final matched = await Process.run('sips',
        ['-m', '/System/Library/ColorSync/Profiles/sRGB Profile.icc', path, '--out', srgbOut]);
    if (matched.exitCode == 0) path = srgbOut;

    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return;

    final seeds = extractSeedsFromRgba(
      byteData.buffer.asUint8List(),
      frame.image.width,
      frame.image.height,
    );

    if (!mounted) return;
    setState(() {
      _logoBytes = bytes;
      _seeds = seeds;
    });
  }

  Future<void> _generateAndRun() async {
    if (_logoPath == null) return;
    setState(() {
      _genState = _GenState.building;
      _genError = null;
    });

    try {
      final exampleDir = _resolveExampleDir();
      final libDir = Directory(p.join(exampleDir, 'lib'))..createSync(recursive: true);
      final assetsDir = Directory(p.join(exampleDir, 'assets'))..createSync(recursive: true);

      // Reuse the already-decoded/rasterized PNG bytes for the logo asset.
      final logoOut = File(p.join(assetsDir.path, 'client_logo.png'));
      if (_logoBytes != null) {
        await logoOut.writeAsBytes(_logoBytes!);
      }

      final cfg = _config;
      final t = _tonePresets[_tone]!;
      final c = cfg.corners;
      final configDart = '''
// LOCAL-ONLY generated by Neptune Odyssey Studio — gitignored.
import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

const BrandprintConfig clientBrandprint = BrandprintConfig(
  primary: Seed(l: ${cfg.primary.l}, c: ${cfg.primary.c}, h: ${cfg.primary.h}),
  tertiary: Seed(l: ${cfg.tertiary.l}, c: ${cfg.tertiary.c}, h: ${cfg.tertiary.h}),
  corners: Corners(xs: ${c.xs}, sm: ${c.sm}, md: ${c.md}, lg: ${c.lg}, xl: ${c.xl}, xxl: ${c.xxl}),
  displayWeight: ${t.displayWeight},
  displayTracking: ${t.displayTracking},
  fontDisplay: '${t.fontDisplay}',
  fontText: 'Hanken Grotesk',
  fontNum: '${t.fontNum}',
  loginShell: '${t.loginShell}',
  dashboardHero: '${t.dashboardHero}',
  contentTone: '${t.contentTone}',
  glassTint: '${t.glassTint}',
  motion: '${t.motion}',
);

const String clientNameEn = ${_dartString(_nameEn.text)};
const String clientNameAr = ${_dartString(_nameAr.text)};

class ClientLogo extends StatelessWidget {
  final double height;
  const ClientLogo({super.key, this.height = 40});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: shape.rSm,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Image.asset('assets/client_logo.png', height: height),
    );
  }
}
''';
      final mainDart = '''
// LOCAL-ONLY generated by Neptune Odyssey Studio — gitignored.
import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import 'client_config.dart';

void main() => runApp(const NeptuneDemoShellApp(
      brandprint: clientBrandprint,
      bankNameEn: clientNameEn,
      bankNameAr: clientNameAr,
      logo: ClientLogo(height: 26),
      startArabic: $_arabic,
    ));
''';

      File(p.join(libDir.path, 'client_config.dart')).writeAsStringSync(configDart);
      File(p.join(libDir.path, 'client_main.dart')).writeAsStringSync(mainDart);

      final flutterBin = _resolveFlutterBin();
      final build = await Process.run(
        flutterBin,
        ['build', 'macos', '--debug', '--target=lib/client_main.dart'],
        workingDirectory: exampleDir,
      );
      if (build.exitCode != 0) {
        throw 'flutter build failed:\n${build.stderr}';
      }

      final appPath = p.join(exampleDir, 'build/macos/Build/Products/Debug/neptune_flutter_ui_example.app');
      await Process.run('open', [appPath]);

      if (!mounted) return;
      setState(() => _genState = _GenState.launched);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _genState = _GenState.error;
        _genError = '$e';
      });
    }
  }

  String _resolveExampleDir() {
    // apps/neptune_studio -> ../../packages/neptune_flutter_ui/example
    final here = Directory.current.path;
    return p.normalize(p.join(here, '../../packages/neptune_flutter_ui/example'));
  }

  String _resolveFlutterBin() {
    const candidate = '/Users/mtellesy/development/flutter/bin/flutter';
    if (File(candidate).existsSync()) return candidate;
    return 'flutter'; // fall back to PATH
  }

  void _setTone(_Tone t) => setState(() => _tone = t);
  void _setDark(bool v) => setState(() => _dark = v);
  void _setArabic(bool v) => setState(() => _arabic = v);
  void _setPrimary(Oklch c) => setState(() => _primaryOverride = c);
  void _setAccent(Oklch c) => setState(() => _accentOverride = c);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 380, child: _ControlPanel(state: this)),
          VerticalDivider(width: 1, color: scheme.outlineVariant),
          Expanded(child: _PreviewPanel(state: this)),
        ],
      ),
    );
  }
}

String _dartString(String s) => "'${s.replaceAll("'", "\\'")}'";

class _ControlPanel extends StatefulWidget {
  final _StudioHomeState state;

  const _ControlPanel({required this.state});

  @override
  State<_ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<_ControlPanel> {
  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      color: scheme.surfaceContainerLow,
      child: ListView(
        padding: const EdgeInsetsDirectional.all(20),
        children: [
          Text('Neptune Odyssey Studio',
              style: text.titleLarge?.copyWith(
                  color: scheme.onSurface, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Logo in, branded demo app out.',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 24),

          const NeptuneEyebrow('Logo'),
          const SizedBox(height: 8),
          _LogoDropZone(
            logoBytes: state._logoBytes,
            onTap: () async {
              await state._pickLogo();
              setState(() {});
            },
          ),
          const SizedBox(height: 20),

          if (state._seeds != null) ...[
            const NeptuneEyebrow('Extracted seeds'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: _SwatchTile(
                  label: 'Primary',
                  hex: state._primaryOverride != null
                      ? oklchToHex(state._primaryOverride!)
                      : state._seeds!.primaryHex,
                  onTap: () => _editSwatch(context, primary: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SwatchTile(
                  label: 'Accent',
                  hex: state._accentOverride != null
                      ? oklchToHex(state._accentOverride!)
                      : state._seeds!.accentHex,
                  onTap: () => _editSwatch(context, primary: false),
                ),
              ),
            ]),
            const SizedBox(height: 20),
          ],

          const NeptuneEyebrow('Bank name'),
          const SizedBox(height: 8),
          NeptuneTextField(
            label: 'English',
            controller: state._nameEn,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          NeptuneTextField(
            label: 'Arabic',
            controller: state._nameAr,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          const NeptuneEyebrow('Tone'),
          const SizedBox(height: 8),
          NeptuneSegmented<_Tone>(
            value: state._tone,
            segments: [
              for (final t in _Tone.values)
                NeptuneSegment(value: t, label: _tonePresets[t]!.label),
            ],
            onChanged: (v) => setState(() => state._setTone(v)),
          ),
          const SizedBox(height: 20),

          NeptuneListTile(
            leadingIcon: Icons.dark_mode_outlined,
            title: 'Dark preview',
            trailing: NeptuneSwitch(
              value: state._dark,
              onChanged: (v) => setState(() => state._setDark(v)),
            ),
          ),
          NeptuneListTile(
            leadingIcon: Icons.translate_rounded,
            title: 'Start in Arabic',
            trailing: NeptuneSwitch(
              value: state._arabic,
              onChanged: (v) => setState(() => state._setArabic(v)),
            ),
          ),
          const SizedBox(height: 24),

          NeptuneCta(
            label: switch (state._genState) {
              _GenState.building => 'Building…',
              _GenState.launched => 'Launched — Generate again',
              _ => 'Generate & run',
            },
            arrow: state._genState != _GenState.building,
            onPressed: state._logoPath == null || state._genState == _GenState.building
                ? null
                : () async {
                    await state._generateAndRun();
                    setState(() {});
                  },
          ),
          if (state._genState == _GenState.error && state._genError != null) ...[
            const SizedBox(height: 12),
            NeptuneAlert(message: state._genError!, tone: NeptuneAlertTone.danger),
          ],
        ],
      ),
    );
  }

  void _editSwatch(BuildContext context, {required bool primary}) {
    final state = widget.state;
    final controller = TextEditingController(
      text: primary
          ? (state._primaryOverride != null ? oklchToHex(state._primaryOverride!) : state._seeds!.primaryHex)
          : (state._accentOverride != null ? oklchToHex(state._accentOverride!) : state._seeds!.accentHex),
    );
    showNeptuneDialog<void>(
      context: context,
      title: primary ? 'Edit primary' : 'Edit accent',
      message: 'Enter a hex colour (e.g. #364680).',
      icon: Icons.palette_outlined,
      actions: [
        const NeptuneDialogAction(label: 'Cancel'),
        NeptuneDialogAction(
          label: 'Apply',
          primary: true,
          onPressed: () {
            try {
              final oklch = hexToOklch(controller.text.trim());
              setState(() {
                if (primary) {
                  state._setPrimary(oklch);
                } else {
                  state._setAccent(oklch);
                }
              });
            } catch (_) {
              // Invalid hex — silently ignore, keep prior value.
            }
          },
        ),
      ],
    );
  }
}

class _SwatchTile extends StatelessWidget {
  final String label;
  final String hex;
  final VoidCallback onTap;

  const _SwatchTile({required this.label, required this.hex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final color = Color(int.parse('FF${hex.substring(1)}', radix: 16));

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: shape.rSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape.rSm,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(10),
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                  Text(hex, style: text.labelLarge?.copyWith(color: scheme.onSurface)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _LogoDropZone extends StatelessWidget {
  final Uint8List? logoBytes;
  final VoidCallback onTap;

  const _LogoDropZone({required this.logoBytes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: shape.rMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape.rMd,
        child: Container(
          height: 96,
          padding: const EdgeInsetsDirectional.all(12),
          alignment: Alignment.center,
          child: logoBytes == null
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.upload_file_outlined, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 6),
                  Text('Click to choose a logo (PNG/JPG/PDF)',
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ])
              : Image.memory(logoBytes!, height: 64),
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  final _StudioHomeState state;

  const _PreviewPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = state._dark
        ? NeptuneTheme.fromConfig(state._config, brightness: Brightness.dark, arabic: state._arabic)
        : NeptuneTheme.fromConfig(state._config, brightness: Brightness.light, arabic: state._arabic);
    final outerScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: outerScheme.surface,
      child: Center(
        child: Container(
          width: 390,
          height: 780,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: outerScheme.outline, width: 2),
            boxShadow: [
              BoxShadow(color: outerScheme.shadow.withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, 20)),
            ],
          ),
          child: Theme(
            data: theme,
            child: Directionality(
              textDirection: state._arabic ? TextDirection.rtl : TextDirection.ltr,
              child: Builder(builder: (context) {
                final name = state._arabic ? state._nameAr.text : state._nameEn.text;
                return Scaffold(
                  body: NeptuneWelcome(
                    brandInitial: name.isEmpty ? 'N' : name.characters.first,
                    brandName: name,
                    lockup: state._logoBytes == null
                        ? null
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            Image.memory(state._logoBytes!, height: 26),
                            const SizedBox(width: 10),
                            Text(name, style: Theme.of(context).textTheme.titleMedium),
                          ]),
                    title: state._arabic ? 'مصرفيتك مع' : 'Banking that',
                    emphasis: state._arabic ? 'المستقبل.' : 'moves with you.',
                    supporting: state._arabic
                        ? 'حساب واحد لكل العملات — إرسال وإنفاق وادخار، بأناقة.'
                        : 'One account, every currency — send, spend and save, beautifully.',
                    primaryAction: const NeptuneCta(label: 'Get started', arrow: true),
                    secondaryAction: const NeptuneCta(label: 'I already have an account', tonal: true),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
