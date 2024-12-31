import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pandabricks/services/high_score_service.dart';

void main() {
  group('HighScoreService', () {
    setUp(() async {
      // Initialize SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    test('updates high score when new score is higher', () async {
      // Test Easy mode
      expect(await HighScoreService.getHighScore('Easy'), 0);
      
      // Update with new high score
      await HighScoreService.updateHighScore('Easy', 100);
      expect(await HighScoreService.getHighScore('Easy'), 100);
      
      // Try updating with lower score
      await HighScoreService.updateHighScore('Easy', 50);
      expect(await HighScoreService.getHighScore('Easy'), 100);
      
      // Try updating with higher score
      await HighScoreService.updateHighScore('Easy', 150);
      expect(await HighScoreService.getHighScore('Easy'), 150);
    });
  });
} 