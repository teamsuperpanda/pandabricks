import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/dialogs/game/custom_game_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('CustomGameDialog Tests', () {
    late LocaleProvider localeProvider;

    setUp(() {
      localeProvider =         LocaleProvider(enablePersistence: false);
    });

    Widget buildTestWidget() {
      return ChangeNotifierProvider<LocaleProvider>.value(
        value: localeProvider,
        child: MaterialApp(
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                height: 600,
                child: SingleChildScrollView(
                  child: CustomGameDialog(),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders custom game dialog content', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Custom Game'), findsOneWidget);
      expect(find.text('Time Limit'), findsOneWidget);
      expect(find.text('Starting Level'), findsOneWidget);
      expect(find.text('Speed Multiplier'), findsOneWidget);
    });

    testWidgets('renders time limit buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('1 min'), findsOneWidget);
      expect(find.text('3 min'), findsOneWidget);
      expect(find.text('5 min'), findsOneWidget);
      expect(find.text('10 min'), findsOneWidget);
      expect(find.text('Unlimited'), findsOneWidget);
    });

    testWidgets('renders cancel and start buttons', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Start Game'), findsOneWidget);
    });

    testWidgets('renders special features section', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Special Features'), findsOneWidget);
      expect(find.text('Special Bricks'), findsOneWidget);
      expect(find.text('Score Multiplier'), findsOneWidget);
    });
  });
}
