import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/screens/game/flame/panda_game.dart';
import 'package:pandabricks/screens/game/game.dart';
import '../../mocks/mock_audio_provider.dart';

void main() {
  group('PandaGame loop', () {
    late Game sim;
    late MockAudioProvider mockAudio;
    late ValueNotifier<HudSnapshot> hud;
    late PandaGame game;

    setUp(() async {
      // Build the simulation the same way the existing lifecycle tests do:
      // classic mode, default 10x20 board, mock audio.
      mockAudio = MockAudioProvider();
      sim = Game(audioProvider: mockAudio);
      hud = ValueNotifier<HudSnapshot>(
        const HudSnapshot(
          score: 0,
          level: 1,
          lines: 0,
          timeRemaining: null,
        ),
      );
      game = PandaGame(sim: sim, audioProvider: mockAudio, hud: hud);
      // onLoad is async: it builds the gradient cache used by render.
      await game.onLoad();
    });

    testWidgets('active piece descends and eventually locks over time', (
      tester,
    ) async {
      final initialY = sim.current!.position.y;
      final initialFilled = _countFilled(sim.board);
      expect(initialFilled, 0);

      // Drive ~3.6s of game time. At level 1 the drop interval is 800ms,
      // so the piece steps down about four to five times (or locks first).
      var maxY = initialY;
      for (var i = 0; i < 36; i++) {
        game.update(0.1);
        final y = sim.current?.position.y;
        if (y != null && y > maxY) maxY = y;
      }

      // Progression is deterministic under gravity regardless of the 7-bag:
      // either the piece moved below its spawn row, or it locked and left
      // filled cells on the board.
      final filled = _countFilled(sim.board);
      expect(maxY > initialY || filled > initialFilled, isTrue);
    });

    testWidgets('paused game does not advance the active piece', (
      tester,
    ) async {
      // Run one frame so the loop is warmed up, then pause.
      game.update(0.1);
      sim.togglePause();
      final yBefore = sim.current!.position.y;

      for (var i = 0; i < 10; i++) {
        game.update(0.1);
      }

      expect(sim.current!.position.y, yBefore);

      // Unpause so any later state stays consistent.
      sim.togglePause();
      expect(sim.isPaused, isFalse);
    });

    testWidgets('held direction moves immediately, then repeats after DAS', (
      tester,
    ) async {
      final startX = sim.current!.position.x;

      game.setHeldDirection(1);
      // A press performs one immediate move.
      expect(sim.current!.position.x, isNot(startX));
      final afterPressX = sim.current!.position.x;

      // ~0.5s of frames: DAS is 0.15s, then ARR repeats every 0.04s.
      for (var i = 0; i < 25; i++) {
        game.update(0.02);
      }
      final heldX = sim.current!.position.x;
      // GHOST pieces drift the opposite way, so compare absolute distance.
      expect((heldX - afterPressX).abs(), greaterThanOrEqualTo(2));

      // Releasing stops further movement.
      game.setHeldDirection(0);
      final releasedX = sim.current!.position.x;
      for (var i = 0; i < 10; i++) {
        game.update(0.02);
      }
      expect(sim.current!.position.x, releasedX);
    });

    testWidgets('held direction does not move while paused', (tester) async {
      game.setHeldDirection(0);
      sim.togglePause();
      final pausedX = sim.current!.position.x;

      game.setHeldDirection(1);
      for (var i = 0; i < 30; i++) {
        game.update(0.02);
      }

      expect(sim.current!.position.x, pausedX);
      sim.togglePause();
    });
  });
}

int _countFilled(List<List<int?>> board) {
  var count = 0;
  for (final row in board) {
    for (final cell in row) {
      if (cell != null) count++;
    }
  }
  return count;
}
