import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/logic/score_logic.dart';

void main() {
  late ScoreLogic scoreLogic;

  setUp(() {
    scoreLogic = ScoreLogic(rowClearScore: 1);
  });

  group('Score Calculation Tests', () {
    test('should calculate correct score for single line', () {
      int points = scoreLogic.updateScore(1);
      expect(points, 100);
      expect(scoreLogic.score, 100);
    });

    test('should calculate correct score for multiple lines', () {
      int points = scoreLogic.updateScore(4); // Tetris
      expect(points, 800);
      expect(scoreLogic.score, 800);
    });

    test('should accumulate score correctly', () {
      scoreLogic.updateScore(1); // 100 points
      scoreLogic.updateScore(2); // 300 points
      expect(scoreLogic.score, 400);
    });
  });
}
