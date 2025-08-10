import 'package:pandabricks/providers/audio_provider.dart';

// A test-safe provider that extends the real AudioProvider type so
// Provider<AudioProvider> lookups work in widget tests, but overrides
// audio behavior to avoid touching platform audio plugins.
class MockAudioProvider extends AudioProvider {
  MockAudioProvider() : super(enablePlatformAudio: false);
  // Keep separate mock state for assertions in tests.
  bool _isGameMusic = false;
  String? _currentlyPlaying;

  // Static constants matching the real AudioProvider
  static const String menuTrack = 'audio/music/menu.mp3';
  static const List<String> gameTracks = [
    'audio/music/game/song1.mp3',
    'audio/music/game/song2.mp3',
    'audio/music/game/song3.mp3',
    'audio/music/game/song4.mp3',
    'audio/music/game/song5.mp3',
    'audio/music/game/song6.mp3',
  ];

  @override
  void toggleMusic() {
    // Use the inherited notifiers for UI bindings
    musicEnabled.value = !musicEnabled.value;
    if (musicEnabled.value) {
      if (_isGameMusic) {
        playGameMusic();
      } else {
        playMenuMusic();
      }
    } else {
      stopMusic();
    }
    notifyListeners();
  }

  @override
  void toggleSfx() {
    sfxEnabled.value = !sfxEnabled.value;
    notifyListeners();
  }

  @override
  void playMenuMusic() {
    _isGameMusic = false;
    if (!musicEnabled.value) return;
    if (_currentlyPlaying == menuTrack) return; // Already playing menu music
    // Mock implementation - just track what should be playing
    _currentlyPlaying = menuTrack;
  }

  @override
  void playGameMusic() {
    _isGameMusic = true;
    if (!musicEnabled.value) return;
    // Mock implementation - pick a deterministic track for testing
    _currentlyPlaying = gameTracks[0];
  }

  @override
  void stopMusic() {
    _currentlyPlaying = null;
  }

  @override
  void disposePlayer() {
    // No-op in tests
  }

  // Test helper accessors
  String? get currentlyPlaying => _currentlyPlaying;
  bool get isGameMusic => _isGameMusic;
}
