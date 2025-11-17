import 'package:pandabricks/providers/audio_provider.dart';

// A test-safe provider that extends the real AudioProvider type so
// Provider<AudioProvider> lookups work in widget tests, but overrides
// audio behavior to avoid touching platform audio plugins.
class MockAudioProvider extends AudioProvider {
  MockAudioProvider() : super(enablePlatformAudio: false);
  // Keep separate mock state for assertions in tests.
  bool _isGameMusic = false;
  String? _currentlyPlaying;
  GameSfx? _lastSfx;
  bool _toggleMusicEnabledCalled = false;

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
    _toggleMusicEnabledCalled = true;
    // Store current state before toggling
    final wasEnabled = musicEnabled;
    final wasGameMusic = _isGameMusic;

    // Call parent toggle which will set the boolean and try to play music
    // But we override playGameMusic and playMenuMusic to prevent actual audio calls
    super.toggleMusic();

    // Now override the state based on what should happen
    if (!wasEnabled && musicEnabled) {
      // Music was just enabled - resume the previous type
      if (wasGameMusic) {
        _currentlyPlaying = gameTracks[0];
        _isGameMusic = true;
      } else {
        _currentlyPlaying = menuTrack;
        _isGameMusic = false;
      }
    } else if (wasEnabled && !musicEnabled) {
      // Music was just disabled
      _currentlyPlaying = null;
    }
  }

  @override
  void toggleSfx() {
    // Call the parent implementation to toggle the state
    super.toggleSfx();
  }

  @override
  Future<void> playMenuMusic() async {
    _isGameMusic = false;
    if (!musicEnabled) return;
    if (_currentlyPlaying == menuTrack) return; // Already playing menu music
    // Mock implementation - just track what should be playing
    _currentlyPlaying = menuTrack;
  }

  @override
  Future<void> playGameMusic() async {
    _isGameMusic = true;
    if (!musicEnabled) return;
    // Mock implementation - pick a deterministic track for testing
    _currentlyPlaying = gameTracks[0];
  }

  @override
  Future<void> stopMusic() async {
    _currentlyPlaying = null;
  }

  @override
  Future<void> playSfx(GameSfx effect, {double volume = 1.0}) async {
    if (!sfxEnabled) return;
    _lastSfx = effect;
  }

  // Test helper accessors
  @override
  String? get currentlyPlaying => _currentlyPlaying;
  bool get isGameMusic => _isGameMusic;
  GameSfx? get lastPlayedSfx => _lastSfx;
  bool get toggleMusicEnabledCalled => _toggleMusicEnabledCalled;
}
