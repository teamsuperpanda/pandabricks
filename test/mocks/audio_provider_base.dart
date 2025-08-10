import 'package:flutter/foundation.dart';

/// Abstract base class for AudioProvider implementations
abstract class AudioProviderBase extends ChangeNotifier {
  ValueNotifier<bool> get musicEnabled;
  ValueNotifier<bool> get sfxEnabled;
  
  void toggleMusic();
  void toggleSfx();
  void playMenuMusic();
  void playGameMusic();
  void stopMusic();
  void disposePlayer();
}
