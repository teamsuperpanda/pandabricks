import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:pandabricks/services/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameSfx { rowClear, columnClear, bombExplosion }

const Map<GameSfx, String> _sfxAssets = {
  GameSfx.rowClear: 'audio/sfx/row_clear.mp3',
  GameSfx.columnClear: 'audio/sfx/panda_disappear.mp3',
  GameSfx.bombExplosion: 'audio/sfx/bomb_explosion.mp3',
};

class AudioProvider extends ChangeNotifier {
  AudioProvider({
    bool enablePlatformAudio = true,
    bool? musicEnabled,
    bool? sfxEnabled,
  }) : _enablePlatformAudio = enablePlatformAudio {
    if (musicEnabled != null) _musicEnabled = musicEnabled;
    if (sfxEnabled != null) _sfxEnabled = sfxEnabled;
    if (enablePlatformAudio) {
      _player = AudioPlayer();
      _sfxPlayer = AudioPlayer(playerId: 'sfx');
      if (musicEnabled == null && sfxEnabled == null) {
        loadPreferences(null);
      }
    }
  }
  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  AudioPlayer? _player;
  AudioPlayer? _sfxPlayer;
  bool _isGameMusic = false;
  String? _currentlyPlaying;
  String?
  _lastGameTrack; // Track the last played game track to avoid duplicates
  final bool _enablePlatformAudio;
  final Random _rng = Random();

  // Public getter for testing purposes
  @visibleForTesting
  String? get currentlyPlaying => _currentlyPlaying;

  // Public setters for testing purposes
  @visibleForTesting
  set player(AudioPlayer? value) => _player = value;
  @visibleForTesting
  set sfxPlayer(AudioPlayer? value) => _sfxPlayer = value;

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

  /// Plays menu background music. Errors from audio plugin are silently logged.
  Future<void> playMenuMusic() async {
    _isGameMusic = false;
    if (!_musicEnabled) return;
    if (_currentlyPlaying == menuTrack) return;

    try {
      await _player?.stop();
      await _player?.play(AssetSource(menuTrack), volume: 0.5);
      await _player?.setReleaseMode(ReleaseMode.loop);
      _currentlyPlaying = menuTrack;
    } catch (e) {
      logError('AudioProvider', e);
    }
  }

  /// Plays game background music. Errors from audio plugin are silently logged.
  Future<void> playGameMusic() async {
    _isGameMusic = true;
    if (!_musicEnabled) return;

    try {
      await _player?.stop();
      // Select a track that's different from the last one played
      final availableTracks = gameTracks
          .where((track) => track != _lastGameTrack)
          .toList();
      final track = availableTracks[_rng.nextInt(availableTracks.length)];
      await _player?.play(AssetSource(track), volume: 0.5);
      await _player?.setReleaseMode(ReleaseMode.loop);
      _lastGameTrack = track;
      _currentlyPlaying = track;
    } catch (e) {
      logError('AudioProvider', e);
    }
  }

  Future<void> stopMusic() async {
    await _player?.stop();
    _currentlyPlaying = null;
  }

  /// Plays a sound effect. Errors from audio plugin are silently logged.
  Future<void> playSfx(GameSfx effect) async {
    if (!_sfxEnabled) return;
    final asset = _sfxAssets[effect];
    if (asset == null) return;

    try {
      await _sfxPlayer?.stop();
      await _sfxPlayer?.play(AssetSource(asset), volume: 1);
    } catch (e) {
      logError('AudioProvider', e);
    }
  }

  /// Loads persisted audio preferences. Errors fall back to defaults and are logged.
  @visibleForTesting
  Future<void> loadPreferences(SharedPreferences? injectedPrefs) async {
    try {
      final prefs = injectedPrefs ?? await SharedPreferences.getInstance();
      _musicEnabled = prefs.getBool('musicEnabled') ?? true;
      _sfxEnabled = prefs.getBool('sfxEnabled') ?? true;
      notifyListeners();
    } catch (e) {
      logError('AudioProvider', e);
    }
  }

  /// Persists current audio preferences. Errors are silently logged.
  @visibleForTesting
  Future<void> savePreferences(SharedPreferences? injectedPrefs) async {
    try {
      final prefs = injectedPrefs ?? await SharedPreferences.getInstance();
      await prefs.setBool('musicEnabled', _musicEnabled);
      await prefs.setBool('sfxEnabled', _sfxEnabled);
    } catch (e) {
      logError('AudioProvider', e);
    }
  }
}
