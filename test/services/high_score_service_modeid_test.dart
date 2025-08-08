import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/logic/modes_logic.dart';
import 'package:pandabricks/services/high_score_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('HighScoreService stores by ModeId', () async {
    SharedPreferences.setMockInitialValues({});
    // Reset may not be available; set a small score then larger to ensure update path
    final updated1 = await HighScoreService.updateHighScoreForMode(Modes.easy, 100);
    expect(updated1, isTrue);

    final got1 = await HighScoreService.getHighScoreForMode(Modes.easy);
    expect(got1, 100);

    // smaller score shouldn't update
    final updated2 = await HighScoreService.updateHighScoreForMode(Modes.easy, 50);
    expect(updated2, isFalse);
    final got2 = await HighScoreService.getHighScoreForMode(Modes.easy);
    expect(got2, 100);
  });
}
