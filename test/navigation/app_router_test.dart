import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/dialogs/game/pause_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/models/game_settings.dart';
import 'package:pandabricks/navigation/app_router.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/screens/game/game.dart';
import 'package:pandabricks/screens/game/screen.dart';
import 'package:pandabricks/widgets/game/controls.dart';
import 'package:pandabricks/widgets/game/dialog_button.dart';
import 'package:pandabricks/widgets/game/hud.dart';
import 'package:pandabricks/widgets/game/preview.dart';
import 'package:pandabricks/widgets/game/timer_display.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('game route passes settings into game initialization', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = AppRouter().router;
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AudioProvider(enablePlatformAudio: false),
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    const cases = <GameSettings>[
      GameSettings.timeChallenge(),
      GameSettings.blitz(),
      GameSettings.custom(
        CustomGameConfig(
          timeLimit: Duration(minutes: 2),
          startingLevel: 4,
          boardWidth: 8,
          boardHeight: 16,
        ),
      ),
    ];

    for (final settings in cases) {
      router.go('/game', extra: settings);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(
        tester.widget<GameScreen>(find.byType(GameScreen)).settings,
        settings,
      );
      final game = Provider.of<Game>(
        tester.element(find.byType(GameHUD)),
        listen: false,
      );
      expect(game.gameMode, settings.mode);
      expect(game.customConfig, settings.customConfig);
      expect(game.width, settings.boardWidth);
      expect(game.height, settings.boardHeight);

      router.go('/');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }
  });

  testWidgets('game route falls back to classic for invalid extra', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = AppRouter().router;
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AudioProvider(enablePlatformAudio: false),
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    router.go('/game', extra: 'invalid');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      tester.widget<GameScreen>(find.byType(GameScreen)).settings,
      const GameSettings.classic(),
    );
  });

  testWidgets('game screen renders its view and wires the pause action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = AppRouter().router;
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AudioProvider(enablePlatformAudio: false),
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    router.go('/game', extra: const GameSettings.timeChallenge());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(GameHUD), findsOneWidget);
    expect(find.byType(PiecePreview), findsOneWidget);
    expect(find.byType(TimerDisplay), findsOneWidget);
    expect(find.byType(GameControls), findsOneWidget);
    expect(find.byType(DialogButton), findsNWidgets(3));

    final game = Provider.of<Game>(
      tester.element(find.byType(GameHUD)),
      listen: false,
    );
    expect(game.isPaused, isFalse);

    await tester.tap(find.widgetWithIcon(DialogButton, Icons.pause_rounded));
    await tester.pump();

    expect(game.isPaused, isTrue);
    expect(find.byType(PauseDialog), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DialogButton &&
            widget.shrinkWrap &&
            widget.icon == Icons.play_arrow_rounded,
      ),
      findsOneWidget,
    );
  });
}
