// LOCAL-ONLY capture harness for the README/pub.dev screenshot showing the
// R6/R9 additions (loaders, splash, AppBar variants) — not part of the
// published example entry point. Same RepaintBoundary.toImage technique as
// main.dart's SHOTS harness (engine-rendered, not a browser screenshot).
// Build with `--dart-define=SHOTS=true` to auto-capture then exit:
//   flutter build macos --target=lib/r11_screenshot_main.dart --dart-define=SHOTS=true
//   open build/macos/Build/Products/Release/neptune_flutter_ui_example.app
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

const bool kShots = bool.fromEnvironment('SHOTS');
const String kShotsDir = String.fromEnvironment('SHOTS_DIR', defaultValue: '/tmp/npt_shots');

void main() => runApp(const R11ShotApp());

class R11ShotApp extends StatefulWidget {
  const R11ShotApp({super.key});

  @override
  State<R11ShotApp> createState() => _R11ShotAppState();
}

class _R11ShotAppState extends State<R11ShotApp> {
  final GlobalKey _shotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (kShots) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _run());
    }
  }

  Future<void> _run() async {
    await Directory(kShotsDir).create(recursive: true);
    await Future<void>.delayed(const Duration(seconds: 2)); // fonts + motion settle
    await WidgetsBinding.instance.endOfFrame;
    final ro = _shotKey.currentContext?.findRenderObject();
    if (ro is RenderRepaintBoundary) {
      final image = await ro.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data != null) {
        await File('$kShotsDir/r6_additions.png').writeAsBytes(data.buffer.asUint8List());
      }
    }
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: NeptuneTheme.light('proteus'),
      builder: (context, child) => RepaintBoundary(key: _shotKey, child: child),
      home: const _Shot(),
    );
  }
}

class _Shot extends StatelessWidget {
  const _Shot();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;

    Widget appBarCard(NeptuneAppBarVariant v) => Container(
          decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant), borderRadius: shape.rSm),
          clipBehavior: Clip.antiAlias,
          child: NeptuneAppBar(
            title: 'Accounts',
            variant: v,
            leading: const Icon(Icons.arrow_back),
            actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
          ),
        );

    // Portrait 480x900 "phone-ish" frame (shared MainFlutterWindow size) —
    // one column, sized to fit without scrolling so the capture is repeatable.
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeptuneEyebrow('Loading & splash — 2.13.0', color: scheme.primary),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _labeled('Hourglass', const NeptuneHourglassLoader(size: 44)),
                _labeled('Spinner', const NeptuneSpinner(size: 40)),
                _labeled('Dots', const NeptuneDotsLoader(size: 40)),
                _labeled('Pulse', const NeptunePulseLoader(size: 44)),
                _labeled('Success', const NeptuneStatusMotion(status: NeptuneFlowStatus.success, size: 44)),
                _labeled('Rejected', const NeptuneStatusMotion(status: NeptuneFlowStatus.rejected, size: 44)),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: const NeptuneSplashScreen(
                  brandInitial: 'P',
                  brandName: 'Proteus',
                  caption: 'Loading your account…',
                ),
              ),
            ),
            const SizedBox(height: 18),
            NeptuneEyebrow('NeptuneAppBar variants', color: scheme.primary),
            const SizedBox(height: 10),
            appBarCard(NeptuneAppBarVariant.small),
            const SizedBox(height: 8),
            appBarCard(NeptuneAppBarVariant.medium),
          ],
        ),
      ),
    );
  }

  Widget _labeled(String label, Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 48, width: 48, child: Center(child: child)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9.5)),
      ],
    );
  }
}
