import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameSfx { rowClear, columnClear, bombExplosion }

const Map<GameSfx, String> _sfxAssets = {
  GameSfx.rowClear: 'audio/sfx/row_clear.mp3',
  GameSfx.columnClear: 'audio/sfx/panda_disappear.mp3',
  GameSfx.bombExplosion: 'audio/sfx/row_clear.mp3',
};

class AudioProvider extends ChangeNotifier {
  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  AudioPlayer? _player;
  AudioPlayer? _sfxPlayer;
  bool _isGameMusic = false;
  String? _currentlyPlaying;
  String? _lastGameTrack; // Track the last played game track to avoid duplicates
  final bool _enablePlatformAudio;

  // Public getter for testing purposes
  @visibleForTesting
  String? get currentlyPlaying => _currentlyPlaying;

  // Public setters for testing purposes
  @visibleForTesting
  set player(AudioPlayer? value) => _player = value;
  @visibleForTesting
  set sfxPlayer(AudioPlayer? value) => _sfxPlayer = value;

  AudioProvider({bool enablePlatformAudio = true}) : _enablePlatformAudio = enablePlatformAudio {
    if (enablePlatformAudio) {
      // Creating an AudioPlayer touches platform channels. Skip in tests.
      _player = AudioPlayer();
      _sfxPlayer = AudioPlayer(playerId: 'sfx');
      loadPreferences(null);
    }
  }

  // Public getters for audio settings
  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  static const String menuTrack = 'audio/music/menu.mp3';
  static const List<String> gameTracks = [
    'audio/music/game/song1.mp3',
    'audio/music/game/song2.mp3',
    'audio/music/game/song3.mp3',
    'audio/music/game/song4.mp3',
    'audio/music/game/song5.mp3',
    'audio/music/game/song6.mp3',
  ];

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (_musicEnabled) {
      if (_isGameMusic) {
        playGameMusic();
      } else {
        playMenuMusic();
      }
    } else {
      stopMusic();
    }
    if (_enablePlatformAudio) {
      savePreferences(null);
    }
    notifyListeners();
  }

  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
    if (_enablePlatformAudio) {
      savePreferences(null);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _player?.dispose();
    _sfxPlayer?.dispose();
    super.dispose();
  }

  Future<void> playMenuMusic() async {
    _isGameMusic = false;
    if (!_musicEnabled) return;
    if (_currentlyPlaying == menuTrack) return; // Already playing menu music
    
    try {
      // Only call plugin methods when player is available (i.e., not in tests)
      if (_player != null) {
        await _player!.stop();
        await _player!.play(AssetSource(menuTrack), volume: 0.5);
        await _player!.setReleaseMode(ReleaseMode.loop);
      }
      _currentlyPlaying = menuTrack;
    } catch (e) {
      debugPrint('Error playing menu music: $e');
    }
  }

  Future<void> playGameMusic() async {
    _isGameMusic = true;
    if (!_musicEnabled) return;
    
    try {
      if (_player != null) {
        await _player!.stop();
      }
      // Select a track that's different from the last one played
      final availableTracks = gameTracks.where((track) => track != _lastGameTrack).toList();
      final track = availableTracks[Random().nextInt(availableTracks.length)];
      if (_player != null) {
        await _player!.play(AssetSource(track), volume: 0.5);
        await _player!.setReleaseMode(ReleaseMode.loop);
      }
      _lastGameTrack = track;
      _currentlyPlaying = track;
    } catch (e) {
      debugPrint('Error playing game music: $e');
    }
  }

  Future<void> stopMusic() async {
    if (_player != null) {
      await _player!.stop();
    }
    _currentlyPlaying = null;
  }

  Future<void> playSfx(GameSfx effect, {double volume = 1.0}) async {
    if (!_sfxEnabled) return;
    final asset = _sfxAssets[effect];
    if (asset == null) return;

    try {
      // Only call plugin methods when player is available (i.e., not in tests)
      if (_sfxPlayer != null) {
        await _sfxPlayer!.stop();
        await _sfxPlayer!.play(AssetSource(asset), volume: volume);
      }
    } catch (e) {
      debugPrint('Error playing sfx $asset: $e');
    }
  }

  @visibleForTesting
  Future<void> loadPreferences(SharedPreferences? injectedPrefs) async {
    try {
      final prefs = injectedPrefs ?? await SharedPreferences.getInstance();
      _musicEnabled = prefs.getBool('musicEnabled') ?? true;
      _sfxEnabled = prefs.getBool('sfxEnabled') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  @visibleForTesting
  Future<void> savePreferences(SharedPreferences? injectedPrefs) async {
    try {
      final prefs = injectedPrefs ?? await SharedPreferences.getInstance();
      await prefs.setBool('musicEnabled', _musicEnabled);
      await prefs.setBool('sfxEnabled', _sfxEnabled);
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }
}