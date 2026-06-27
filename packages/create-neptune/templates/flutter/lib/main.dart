// {{PROJECT_TITLE}} — Neptune Odyssey starter (Flutter).
import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import 'dashboard.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '{{PROJECT_TITLE}}',
      debugShowCheckedModeBanner: false,
      // The same brandprint that themes web/React also themes Flutter.
      theme: NeptuneTheme.light('{{BRAND}}'),
      darkTheme: NeptuneTheme.dark('{{BRAND}}'),
      themeMode: ThemeMode.{{MODE}},
      home: const DashboardScreen(),
    );
  }
}
