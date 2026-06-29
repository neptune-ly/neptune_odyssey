// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Headless verification: every screen builds — across brands, light/dark, RTL,
// and at both a wide desktop size and a narrow (mobile-ish) size — with zero
// exceptions or layout overflows. This exercises each screen's responsive
// branches the way a real window would, but in CI.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import 'package:neptune_desktop/app/app_state.dart';
import 'package:neptune_desktop/app/nav.dart';
import 'package:neptune_desktop/app/neptune_app.dart';

void main() {
  // Don't hit the network for brand fonts during tests.
  NeptuneTheme.debugSkipFontLoading = true;

  Future<void> sweep(WidgetTester tester, AppState state, String label) async {
    for (final dest in NavDest.values) {
      state.go(dest);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$label · ${dest.name}');
    }
  }

  testWidgets('every screen builds across brands / modes / sizes', (tester) async {
    for (final brand in AppState.brands) {
      final state = AppState()..brand = brand;
      await tester.pumpWidget(NeptuneApp(state: state));

      // Wide desktop.
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpAndSettle();
      await sweep(tester, state, '$brand · wide');

      // Dark.
      state.toggleMode();
      await tester.pumpAndSettle();
      await sweep(tester, state, '$brand · dark');

      // RTL + Arabic faces, narrow (mobile-ish) width.
      state.toggleMode();
      state.toggleRtl();
      await tester.binding.setSurfaceSize(const Size(430, 920));
      await tester.pumpAndSettle();
      await sweep(tester, state, '$brand · rtl-narrow');
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('brand switch reskins live without exceptions', (tester) async {
    final state = AppState();
    await tester.pumpWidget(NeptuneApp(state: state));
    await tester.binding.setSurfaceSize(const Size(1280, 860));
    await tester.pumpAndSettle();
    for (final brand in AppState.brands) {
      state.brand = brand;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'switch → $brand');
    }
    await tester.binding.setSurfaceSize(null);
  });
}
