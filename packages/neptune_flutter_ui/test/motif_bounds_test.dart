// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// THE MOTIF IS A FILL LAYER, SO IT FILLS ITS BOX AND NOTHING ELSE.
//
// `sonarRings` draws concentric rings out to the farthest corner of the size
// it is handed, and `CustomPaint` does not clip. Dropped into the 132dp band a
// pre-login shell sizes for it, it painted rings of ~500dp radius through the
// band, across the whole page and over every field and label on it - which is
// the opposite of what the caller sized the band to say.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  testWidgets('the motif layer never paints outside its own box',
      (tester) async {
    final theme = NeptuneTheme.fromConfig(const BrandprintConfig(
      primary: Seed(l: 0.34, c: 0.132, h: 255),
      tertiary: Seed(l: 0.48, c: 0.087, h: 242),
      corners: Corners(xs: 6, sm: 10, md: 12, lg: 16, xl: 20, xxl: 28),
      displayWeight: 600,
      displayTracking: 0.01,
      fontDisplay: 'IBM Plex Sans Arabic',
      fontText: 'IBM Plex Sans Arabic',
      fontNum: 'IBM Plex Sans Arabic',
      loginShell: 'paper-lockup',
      dashboardHero: 'statement-ledger',
      contentTone: 'formal-authoritative',
      glassTint: 'oceanic',
      motion: 'calm-graceful',
      motif: 'sonar-rings',
    ));

    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: const Scaffold(
        body: Center(
          child: SizedBox(
            height: 132,
            width: 300,
            child: Stack(
              fit: StackFit.expand,
              children: [NeptuneMotifLayer(strength: 0.35)],
            ),
          ),
        ),
      ),
    ));

    // The clip is the contract: without it the painter's rings are unbounded
    // and the band the caller sized means nothing.
    final clip = tester.widget<ClipRect>(find.descendant(
      of: find.byType(NeptuneMotifLayer),
      matching: find.byType(ClipRect),
    ));
    expect(clip, isNotNull);
    expect(tester.getSize(find.byType(NeptuneMotifLayer)), const Size(300, 132));
  });
}
