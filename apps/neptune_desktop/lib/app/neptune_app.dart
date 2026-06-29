// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// The MaterialApp. The active AppState brandprint drives the theme: brand →
// NeptuneTheme.light/dark, and RTL flips both Directionality and the Arabic font
// faces (NeptuneTheme(..., arabic: rtl)). Swap the brand at runtime and the whole
// desktop app reskins — white-label by construction.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../shell/desktop_shell.dart';
import 'app_scope.dart';
import 'app_state.dart';

class NeptuneApp extends StatelessWidget {
  /// Inject an [AppState] (tests drive navigation through it); defaults to a
  /// fresh seeded state in production.
  final AppState? state;

  const NeptuneApp({super.key, this.state});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state ?? AppState(),
      child: Builder(
        builder: (context) {
          final app = AppScope.of(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Neptune Odyssey',
            theme: NeptuneTheme.light(app.brand, arabic: app.rtl),
            darkTheme: NeptuneTheme.dark(app.brand, arabic: app.rtl),
            themeMode: app.mode,
            builder: (context, child) => Directionality(
              textDirection: app.rtl ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            ),
            home: const DesktopShell(),
          );
        },
      ),
    );
  }
}
