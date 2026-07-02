import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import 'package:neptune_studio/main.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  testWidgets('Studio boots to the control panel + preview', (tester) async {
    await tester.pumpWidget(const StudioApp());
    await tester.pump();

    expect(find.text('Neptune Odyssey Studio'), findsOneWidget);
    expect(find.byType(NeptuneCta), findsWidgets);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    expect(find.text('Generate & run'), findsOneWidget);
  });
}
