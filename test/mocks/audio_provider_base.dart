import 'package:flutter/foundation.dart';
import 'package:pandabricks/providers/audio_provider.dart';

/// Abstract base class for AudioProvider implementations
abstract class AudioProviderBase extends ChangeNotifier {
  ValueNotifier<bool> get musicEnabled;
  ValueNotifier<bool> get sfxEnabled;
  
  void toggleMusic();
  void toggleSfx();
  void playMenuMusic();
  void playGameMusic();
  void stopMusic();
  Future<void> playSfx(GameSfx effect, {double volume = 1.0});
}
