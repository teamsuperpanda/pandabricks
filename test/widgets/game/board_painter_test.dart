import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/game/board_painter.dart';
import 'package:pandabricks/widgets/game/game_palette.dart';

void main() {
  group('BoardPainter', () {
    test('creates with default parameters', () {
      final painter = BoardPainter(
        width: 10,
        height: 20,
        cells: const [],
        palette: kGamePalette,
      );

      expect(painter.width, 10);
      expect(painter.height, 20);
    });

    test('shouldRepaint returns true when version changes', () {
      final old = BoardPainter(
        width: 10,
        height: 20,
        cells: const [],
        palette: kGamePalette,
        version: 1,
      );
      final neu = BoardPainter(
        width: 10,
        height: 20,
        cells: const [],
        palette: kGamePalette,
        version: 2,
      );

      expect(neu.shouldRepaint(old), isTrue);
    });

    test('shouldRepaint returns false when version is same', () {
      final old = BoardPainter(
        width: 10,
        height: 20,
        cells: const [],
        palette: kGamePalette,
        version: 1,
      );
      final neu = BoardPainter(
        width: 10,
        height: 20,
        cells: const [],
        palette: kGamePalette,
        version: 1,
      );

      expect(neu.shouldRepaint(old), isFalse);
    });

    test('shouldRepaint returns true when dimensions change', () {
      final old = BoardPainter(
        width: 10,
        height: 20,
        cells: const [],
        palette: kGamePalette,
        version: 1,
      );
      final neu = BoardPainter(
        width: 12,
        height: 20,
        cells: const [],
        palette: kGamePalette,
        version: 1,
      );

      expect(neu.shouldRepaint(old), isTrue);
    });
  });
}
