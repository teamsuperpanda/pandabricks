import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/services/high_score_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
  });

  group('HighScoreService Tests', () {
    test('should store and retrieve high scores', () async {
      await HighScoreService.updateHighScore('Easy', 1000);
      int score = await HighScoreService.getHighScore('Easy');
      expect(score, 1000);
    });

    test('should only update if new score is higher', () async {
      await HighScoreService.updateHighScore('Normal', 1000);
      await HighScoreService.updateHighScore('Normal', 500);
      int score = await HighScoreService.getHighScore('Normal');
      expect(score, 1000);
    });

    test('should handle multiple modes independently', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await HighScoreService.updateHighScore('Easy', 1000);
      await HighScoreService.updateHighScore('Normal', 2000);
      await HighScoreService.updateHighScore('Bamboo Blitz', 3000);

      // Verify the values were stored
      expect(prefs.getInt('highScore_easy'), 1000);
      expect(prefs.getInt('highScore_normal'), 2000);
      expect(prefs.getInt('highScore_bambooblitz'), 3000);

      // Verify retrieval
      expect(await HighScoreService.getHighScore('Easy'), 1000);
      expect(await HighScoreService.getHighScore('Normal'), 2000);
      expect(await HighScoreService.getHighScore('Bamboo Blitz'), 3000);
    });

    test('should return 0 for non-existent scores', () async {
      int score = await HighScoreService.getHighScore('NonExistentMode');
      expect(score, 0);
    });
  });
}
