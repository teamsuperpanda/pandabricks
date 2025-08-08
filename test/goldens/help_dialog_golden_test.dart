import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/main/help_dialog.dart';

void main() {
  testWidgets('HelpDialog golden', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HelpDialog(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HelpDialog), findsOneWidget);
    // To enable golden: uncomment below line and provide baseline image.
    // await expectLater(find.byType(HelpDialog), matchesGoldenFile('goldens/help_dialog.png'));
  }, skip: true);
}
