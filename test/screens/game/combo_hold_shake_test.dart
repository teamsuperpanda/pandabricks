import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/screens/game/game.dart';
import '../../mocks/mock_audio_provider.dart';

void main() {
  group('Combo and back-to-back tracking', () {
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
    });

    test(
      'combo increments across consecutive clears and resets on no clear',
      () {
        final game = Game(audioProvider: mockAudio);
        final comboEvents = <(int, bool)>[];
        game.onCombo = (c, b2b) => comboEvents.add((c, b2b));

        _fillRows(game, 1);
        expect(game.clearLines(), 1);
        expect(game.combo, 1);

        _fillRows(game, 2);
        expect(game.clearLines(), 2);
        expect(game.combo, 2);

        // A non-clearing drop resets the combo to 0.
        expect(game.clearLines(), 0);
        expect(game.combo, 0);

        // The streak starts over after the reset.
        _fillRows(game, 1);
        expect(game.clearLines(), 1);
        expect(game.combo, 1);

        // Only the combo >= 2 clear warranted a popup.
        expect(comboEvents, [(2, false)]);
      },
    );

    test('combo bonus is applied once the combo is 2 or higher', () {
      final game = Game(audioProvider: mockAudio);

      _fillRows(game, 1);
      game.clearLines();
      expect(game.combo, 1);
      // clearLines awards no base line score; the combo bonus is 0 at combo 1.
      expect(game.score, 0);

      _fillRows(game, 1);
      game.clearLines();
      final comboBonus = 1 * Game.comboBonusPerLine * (2 - 1) * game.level;
      expect(game.score, comboBonus);
    });

    test(
      'two consecutive tetris clears set backToBack, a single clear breaks it',
      () {
        final game = Game(audioProvider: mockAudio);
        var popups = 0;
        game.onCombo = (c, b2b) => popups++;

        _fillRows(game, 4);
        game.clearLines();
        expect(game.combo, 1);
        expect(game.backToBack, isFalse);

        _fillRows(game, 4);
        game.clearLines();
        expect(game.combo, 2);
        expect(game.backToBack, isTrue);

        // A non-difficult clear resets the streak.
        _fillRows(game, 1);
        game.clearLines();
        expect(game.backToBack, isFalse);
        expect(game.combo, 3);

        // Popups fired for the second tetris and the following single clear
        // (combo >= 2), not for the first tetris.
        expect(popups, 2);
      },
    );
  });

  group('Hold piece', () {
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
    });

    test('first swap stashes the current piece and spawns a new one', () {
      final game = Game(audioProvider: mockAudio);
      expect(game.hold, isNull);
      expect(game.holdUsed, isFalse);

      final firstType = game.current!.type;
      game.swapHold();
      expect(game.hold, firstType);
      expect(game.holdUsed, isTrue);
      expect(game.current, isNotNull);
    });

    test('second swap in the same drop is blocked until the next lock', () {
      final game = Game(audioProvider: mockAudio);

      game.swapHold();
      final heldType = game.hold;
      final activeType = game.current!.type;

      game.swapHold();
      expect(game.hold, heldType);
      expect(game.current!.type, activeType);

      // Locking the piece makes hold available again.
      game.hardDrop();
      expect(game.holdUsed, isFalse);
      final beforeSwap = game.current!.type;

      game.swapHold();
      expect(game.current!.type, heldType);
      expect(game.hold, beforeSwap);
    });

    test('reset clears the held piece and usage flag', () {
      final game = Game(audioProvider: mockAudio);
      game.swapHold();
      expect(game.hold, isNotNull);

      game.reset();
      expect(game.hold, isNull);
      expect(game.holdUsed, isFalse);
    });
  });

  group('Targeted screen shake callbacks', () {
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
    });

    test('onBigClear fires for tetris but not single or double clears', () {
      final game = Game(audioProvider: mockAudio);
      var shakes = 0;
      game.onBigClear = () => shakes++;

      _fillRows(game, 1);
      game.clearLines();
      _fillRows(game, 2);
      game.clearLines();
      expect(shakes, 0);

      _fillRows(game, 3);
      game.clearLines();
      expect(shakes, 1);

      _fillRows(game, 4);
      game.clearLines();
      expect(shakes, 2);
    });

    test('onBigClear fires for a BOMB clear', () {
      final game = Game(audioProvider: mockAudio, gameMode: GameMode.blitz);
      var shakes = 0;
      game.onBigClear = () => shakes++;

      const targetX = 4;
      final targetY = game.height - 1;
      for (var x = 0; x < game.width; x++) {
        game.board[targetY][x] = 3;
      }
      for (var y = 0; y < game.height; y++) {
        game.board[y][targetX] = 3;
      }

      game.current = ActivePiece(
        type: FallingBlock.BOMB,
        rotation: Rotation.up,
        position: PointInt(targetX, targetY),
        isSpecialBlock: true,
      );
      game.hardDrop();

      expect(shakes, 1);
    });

    test('reset keeps the effect callbacks wired', () {
      final game = Game(audioProvider: mockAudio);
      var fired = false;
      game.onCombo = (c, b2b) => fired = true;
      game.onBigClear = () => fired = true;

      game.reset();
      _fillRows(game, 4);
      game.clearLines();
      expect(fired, isTrue);
    });
  });
}

void _fillRows(Game game, int count) {
  for (var y = game.height - count; y < game.height; y++) {
    for (var x = 0; x < game.width; x++) {
      game.board[y][x] = 0;
    }
  }
}
