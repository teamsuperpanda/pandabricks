import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/widgets/home/audio_settings.dart';
import 'package:provider/provider.dart';

void main() {
  group('AudioSettings', () {
    testWidgets('renders music and sfx toggles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>(
              create: (_) => AudioProvider(enablePlatformAudio: false),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AudioSettings(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Music'), findsOneWidget);
      expect(find.text('SFX'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('toggles music on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>(
              create: (_) => AudioProvider(enablePlatformAudio: false),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AudioSettings(),
            ),
          ),
        ),
      );

      await tester.pump();

      final switches = find.byType(Switch);
      await tester.tap(switches.first);
      await tester.pump();
    });
  });
}
