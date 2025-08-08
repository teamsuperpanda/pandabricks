import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/dialog/main/language_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';

void main() {
  testWidgets('LanguageDialog shows localized title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => LanguageDialog(onLanguageChanged: (_) {}),
                      );
                    },
                    child: const Text('Open'),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Check English by default
    expect(find.text('Language'), findsOneWidget);
  });
}
