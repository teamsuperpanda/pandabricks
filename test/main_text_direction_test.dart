import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/main.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Locale locale) async {
    final localeProvider = LocaleProvider(enablePersistence: false);
    await localeProvider.setLocale(locale);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AudioProvider(enablePlatformAudio: false),
          ),
          ChangeNotifierProvider.value(value: localeProvider),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  TextDirection appTextDirection(WidgetTester tester) {
    final materialApp = find.byType(MaterialApp);
    final context = tester.element(
      find.descendant(
        of: materialApp,
        matching: find.byType(Navigator),
      ),
    );
    return Directionality.of(context);
  }

  for (final locale in const [Locale('ar'), Locale('ur')]) {
    testWidgets('${locale.languageCode} uses right-to-left text direction', (
      tester,
    ) async {
      await pumpApp(tester, locale);

      expect(appTextDirection(tester), TextDirection.rtl);
    });
  }

  testWidgets('English preserves left-to-right text direction', (tester) async {
    await pumpApp(tester, const Locale('en'));

    expect(appTextDirection(tester), TextDirection.ltr);
  });
}
