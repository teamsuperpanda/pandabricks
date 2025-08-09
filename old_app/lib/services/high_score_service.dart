import 'package:shared_preferences/shared_preferences.dart';
import 'package:pandabricks/logic/modes_logic.dart';

class HighScoreService {
  static const String _easyKey = 'highScore_easy';
  static const String _normalKey = 'highScore_normal';
  static const String _bambooblitzKey = 'highScore_bambooblitz';

  static Future<int> getHighScore(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (mode == Modes.easy.name) {
      return prefs.getInt(_easyKey) ?? 0;
    } else if (mode == Modes.normal.name) {
      return prefs.getInt(_normalKey) ?? 0;
    } else if (mode == Modes.bambooblitz.name) {
      return prefs.getInt(_bambooblitzKey) ?? 0;
    } else {
      return 0;
    }
  }

  static Future<bool> updateHighScore(String mode, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighScore = await getHighScore(mode);

    if (score > currentHighScore) {
      String key;
      if (mode == Modes.easy.name) {
        key = _easyKey;
      } else if (mode == Modes.normal.name) {
        key = _normalKey;
      } else if (mode == Modes.bambooblitz.name) {
        key = _bambooblitzKey;
      } else {
        return false;
      }
      await prefs.setInt(key, score);
      return true;
    }
    return false;
  }
}
