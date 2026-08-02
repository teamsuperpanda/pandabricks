import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/screens/game/game.dart';
import 'package:pandabricks/screens/game/game_dialog_mediator.dart';

void main() {
  testWidgets('dispose cancels pending game-over dialog', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Text('Game')),
      ),
    );

    final audioProvider = AudioProvider(enablePlatformAudio: false);
    final game = Game(audioProvider: audioProvider)..isGameOver = true;
    final mediator = GameDialogMediator(
      navigator: navigatorKey.currentState!,
      game: game,
      audioProvider: audioProvider,
    );

    mediator.checkGameOver();
    mediator.dispose();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Game Over'), findsNothing);

    game.dispose();
    audioProvider.dispose();
  });
}
