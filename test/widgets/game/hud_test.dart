import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:pandabricks/widgets/game/hud.dart';
import 'package:provider/provider.dart';

void main() {
  group('GameHUD', () {
    late LocaleProvider localeProvider;

    setUp(() {
      localeProvider = LocaleProvider();
    });

    testWidgets('displays score, level, and lines', (
      tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: GameHUD(score: 1000, level: 5, lines: 25),
            ),
          ),
        ),
      );

      expect(find.text('Score'), findsOneWidget);
      expect(find.text('Level'), findsOneWidget);
      expect(find.text('Lines'), findsOneWidget);
      expect(find.text('1000'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('displays zero values', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: GameHUD(score: 0, level: 1, lines: 0),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('displays large scores', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: GameHUD(score: 999999, level: 99, lines: 999),
            ),
          ),
        ),
      );

      expect(find.text('999999'), findsOneWidget);
      expect(find.text('99'), findsOneWidget);
      expect(find.text('999'), findsOneWidget);
    });
  });
}
