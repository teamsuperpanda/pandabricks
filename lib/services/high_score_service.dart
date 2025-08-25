import 'package:shared_preferences/shared_preferences.dart';

class HighScoreService {
  static const String _easyKey = 'highScore_easy';
  static const String _normalKey = 'highScore_normal';
  static const String _bambooblitzKey = 'highScore_bambooblitz';

  static Future<int> getHighScore(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case 'Easy':
        return prefs.getInt(_easyKey) ?? 0;
      case 'Normal':
        return prefs.getInt(_normalKey) ?? 0;
      case 'Bamboo Blitz':
        return prefs.getInt(_bambooblitzKey) ?? 0;
      default:
        return 0;
    }
  }

  static Future<bool> updateHighScore(String mode, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighScore = await getHighScore(mode);

    if (score > currentHighScore) {
      String key;
      switch (mode) {
        case 'Easy':
          key = _easyKey;
          break;
        case 'Normal':
          key = _normalKey;
          break;
        case 'Bamboo Blitz':
          key = _bambooblitzKey;
          break;
        default:
          return false;
      }
      await prefs.setInt(key, score);
      return true;
    }
    return false;
  }
}
