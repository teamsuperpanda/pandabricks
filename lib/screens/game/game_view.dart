part of 'screen.dart';

class _GameView extends StatelessWidget {
  const _GameView({
    required this.backgroundAnimation,
    required this.inputHandler,
    required this.inputCallbacks,
    required this.pandaGame,
    required this.hud,
    required this.overlayBuilders,
    required this.onMainMenu,
    required this.onRestart,
    required this.onPause,
    required this.onRotate,
  });

  final Animation<double> backgroundAnimation;
  final GameInputHandler inputHandler;
  final GameInputCallbacks inputCallbacks;
  final PandaGame pandaGame;
  final ValueNotifier<HudSnapshot> hud;
  final Map<String, Widget Function(BuildContext, PandaGame)> overlayBuilders;
  final VoidCallback onMainMenu;
  final VoidCallback onRestart;
  final VoidCallback onPause;
  final VoidCallback onRotate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragStart: inputHandler.onHorizontalDragStart,
        onHorizontalDragUpdate: inputHandler.onHorizontalDragUpdate,
        onVerticalDragUpdate: inputHandler.onVerticalDragUpdate,
        onVerticalDragEnd: inputHandler.onVerticalDragEnd,
        child: Stack(
          children: [
            Semantics(
              label: 'Background',
              child: AnimatedBackground(gradientAnimation: backgroundAnimation),
            ),
            Semantics(
              label: 'Ambient particles',
              child: const AmbientParticles(),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      _GameHeader(
                        l10n: l10n,
                        hud: hud,
                        onMainMenu: onMainMenu,
                        onRestart: onRestart,
                        onPause: onPause,
                      ),
                      Semantics(
                        label: 'Score display',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ValueListenableBuilder<HudSnapshot>(
                            valueListenable: hud,
                            builder: (context, snapshot, _) => GameHUD(
                              score: snapshot.score,
                              level: snapshot.level,
                              lines: snapshot.lines,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: _GameBody(
                          l10n: l10n,
                          onRotate: onRotate,
                          pandaGame: pandaGame,
                          hud: hud,
                          overlayBuilders: overlayBuilders,
                        ),
                      ),
                      Semantics(
                        label: 'Game controls',
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                          child: GameControls(callbacks: inputCallbacks),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.l10n,
    required this.hud,
    required this.onMainMenu,
    required this.onRestart,
    required this.onPause,
  });

  final AppLocalizations l10n;
  final ValueNotifier<HudSnapshot> hud;
  final VoidCallback onMainMenu;
  final VoidCallback onRestart;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Semantics(
        label: 'Game controls header',
        child: Row(
          children: [
            DialogButton(
              shrinkWrap: true,
              icon: Icons.home,
              label: l10n.mainMenu,
              onTap: onMainMenu,
            ),
            const Spacer(),
            DialogButton(
              shrinkWrap: true,
              icon: Icons.refresh,
              label: l10n.restart,
              onTap: onRestart,
            ),
            const Spacer(),
            ValueListenableBuilder<HudSnapshot>(
              valueListenable: hud,
              builder: (context, snapshot, _) => DialogButton(
                shrinkWrap: true,
                icon: snapshot.isPaused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                label: snapshot.isPaused ? l10n.resume : l10n.pause,
                onTap: onPause,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody({
    required this.l10n,
    required this.onRotate,
    required this.pandaGame,
    required this.hud,
    required this.overlayBuilders,
  });

  final AppLocalizations l10n;
  final VoidCallback onRotate;
  final PandaGame pandaGame;
  final ValueNotifier<HudSnapshot> hud;
  final Map<String, Widget Function(BuildContext, PandaGame)> overlayBuilders;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _GamePlayfield(
                  onRotate: onRotate,
                  pandaGame: pandaGame,
                  overlayBuilders: overlayBuilders,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _GameSidePanel(
                  l10n: l10n,
                  hud: hud,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameSidePanel extends StatelessWidget {
  const _GameSidePanel({
    required this.l10n,
    required this.hud,
  });

  final AppLocalizations l10n;
  final ValueNotifier<HudSnapshot> hud;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HudSnapshot>(
      valueListenable: hud,
      builder: (context, snapshot, _) {
        final showTimer = snapshot.timeRemaining != null;
        return Semantics(
          label: 'Side panel',
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l10n.holdPiece, style: _labelStyle),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Hold piece preview',
                child: HoldPreview(hold: snapshot.hold),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l10n.next, style: _labelStyle),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Next piece preview',
                child: PiecePreview(next: snapshot.next),
              ),
              if (showTimer) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(l10n.timeLeft, style: _labelStyle),
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: _timerSemanticsLabel(snapshot.timeRemaining!),
                  child: TimerDisplay(timeRemaining: snapshot.timeRemaining!),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static final TextStyle _labelStyle = TextStyle(
    fontSize: 14,
    color: Colors.white.withValues(alpha: 220 / 255.0),
    fontWeight: FontWeight.w600,
  );

  static String _timerSemanticsLabel(Duration duration) {
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return 'Time remaining: ${duration.inMinutes}:$seconds';
  }
}

class _GamePlayfield extends StatelessWidget {
  const _GamePlayfield({
    required this.onRotate,
    required this.pandaGame,
    required this.overlayBuilders,
  });

  final VoidCallback onRotate;
  final PandaGame pandaGame;
  final Map<String, Widget Function(BuildContext, PandaGame)> overlayBuilders;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Game board',
      child: GestureDetector(
        onTap: onRotate,
        child: GlassMorphismCard(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AspectRatio(
                aspectRatio: pandaGame.sim.width / pandaGame.sim.height,
                child: GameWidget<PandaGame>(
                  game: pandaGame,
                  overlayBuilderMap: overlayBuilders,
                  autofocus: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
