import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

const _outputDirectory = String.fromEnvironment('ODYSSEY3_SHOTS_DIR');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  NeptuneTheme.debugSkipFontLoading = true;

  setUpAll(() async {
    final root = Directory.current.parent.path;
    Future<void> loadFace(String family, String filePrefix) async {
      final fonts = FontLoader(family);
      for (final weight in [400, 600, 700]) {
        final bytes = await File(
          '$root/neptune_kmp_ui/odyssey-compose-ui/src/commonMain/'
          'composeResources/font/${filePrefix}_$weight.ttf',
        ).readAsBytes();
        fonts.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await fonts.load();
    }

    await loadFace('Hanken Grotesk', 'hanken_grotesk');
    await loadFace('Beiruti', 'beiruti');
  });

  testWidgets('captures Odyssey 3 foundation profiles', (tester) async {
    final boundaryKey = GlobalKey();
    final directory = Directory(_outputDirectory);
    directory.createSync(recursive: true);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const profiles = [
      _FoundationProfile('core_en_light', NeptuneOdyssey3Product.wallet,
          Brightness.light, false),
      _FoundationProfile(
          'core_ar_dark', NeptuneOdyssey3Product.wallet, Brightness.dark, true),
      _FoundationProfile('drive_en_light', NeptuneOdyssey3Product.drive,
          Brightness.light, false),
      _FoundationProfile(
          'drive_ar_dark', NeptuneOdyssey3Product.drive, Brightness.dark, true),
      _FoundationProfile('orbit_en_light', NeptuneOdyssey3Product.orbit,
          Brightness.light, false),
      _FoundationProfile(
          'orbit_ar_dark', NeptuneOdyssey3Product.orbit, Brightness.dark, true),
      _FoundationProfile('banking_en_light', NeptuneOdyssey3Product.banking,
          Brightness.light, false),
      _FoundationProfile('banking_ar_dark', NeptuneOdyssey3Product.banking,
          Brightness.dark, true),
    ];
    for (final profile in profiles) {
      final base = profile.brightness == Brightness.light
          ? NeptuneTheme.light('neptune', arabic: profile.arabic)
          : NeptuneTheme.dark('neptune', arabic: profile.arabic);
      final theme = NeptuneTheme.odyssey3(base,
          product: profile.product, arabic: profile.arabic);
      await tester.pumpWidget(MaterialApp(
        key: ValueKey(profile.filename),
        theme: theme,
        themeAnimationDuration: Duration.zero,
        builder: (context, child) => RepaintBoundary(
          key: boundaryKey,
          child: child!,
        ),
        home: Directionality(
          textDirection: profile.arabic ? TextDirection.rtl : TextDirection.ltr,
          child: _FoundationScreen(arabic: profile.arabic),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      final boundary = boundaryKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File('${directory.path}/${profile.filename}.png')
            .writeAsBytesSync(data!.buffer.asUint8List());
        image.dispose();
      });
    }
  }, skip: _outputDirectory.isEmpty);
}

class _FoundationProfile {
  const _FoundationProfile(
      this.filename, this.product, this.brightness, this.arabic);

  final String filename;
  final NeptuneOdyssey3Product product;
  final Brightness brightness;
  final bool arabic;
}

class _FoundationScreen extends StatelessWidget {
  const _FoundationScreen({required this.arabic});

  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final copy = arabic
        ? const _FoundationCopy(
            heading: 'رصيدك اليوم',
            body: 'نظرة واضحة على أموالك وخطواتك التالية.',
            label: 'الرصيد المتاح',
            amount: '12,480.00',
            field: 'المستفيد',
            primary: 'متابعة',
            secondary: 'إلغاء',
          )
        : const _FoundationCopy(
            heading: 'Your balance today',
            body: 'A clear view of your money and your next step.',
            label: 'AVAILABLE BALANCE',
            amount: '12,480.00',
            field: 'Recipient',
            primary: 'Continue',
            secondary: 'Cancel',
          );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(copy.heading, style: text.headlineLarge),
              const SizedBox(height: 8),
              Text(copy.body, style: text.bodyLarge),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(copy.label, style: text.labelLarge),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(copy.amount,
                              textDirection: TextDirection.ltr,
                              style: text.displaySmall),
                          const SizedBox(width: 8),
                          Text(arabic ? 'د.ل' : 'LYD', style: text.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(labelText: copy.field),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: () {}, child: Text(copy.primary)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () {}, child: Text(copy.secondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoundationCopy {
  const _FoundationCopy({
    required this.heading,
    required this.body,
    required this.label,
    required this.amount,
    required this.field,
    required this.primary,
    required this.secondary,
  });

  final String heading;
  final String body;
  final String label;
  final String amount;
  final String field;
  final String primary;
  final String secondary;
}
