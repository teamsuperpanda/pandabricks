import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/logic/score_logic.dart';

void main() {
  group('ScoreLogic', () {
    test('updateScore correctly calculates points for different line clears',
        () {
      final scoreLogic = ScoreLogic(
        rowClearScore: 1,
      );

      // Test single line clear (100 points)
      expect(scoreLogic.updateScore(1), 100);
      expect(scoreLogic.score, 100);

      // Test double line clear (300 points)
      expect(scoreLogic.updateScore(2), 300);
      expect(scoreLogic.score, 400);

      // Test Tetris - four lines (800 points)
      expect(scoreLogic.updateScore(4), 800);
      expect(scoreLogic.score, 1200);
    });
  });
}
