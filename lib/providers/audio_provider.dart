import 'dart:async';
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
      final sfxCache = AudioCache();
      _sfxCache = sfxCache;
      _player = AudioPlayer();
      _sfxPlayers = {
        for (final entry in _sfxAssets.entries)
          entry.key: AudioPlayer()..audioCache = sfxCache,
      };
      unawaited(_preloadSfx());
      if (musicEnabled == null && sfxEnabled == null) {
        unawaited(loadPreferences(null));
      }
    }
  }
  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  AudioPlayer? _player;
  AudioCache? _sfxCache;
  Map<GameSfx, AudioPlayer> _sfxPlayers = const {};
  SharedPreferences? _prefs;
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
  set sfxPlayers(Map<GameSfx, AudioPlayer> value) => _sfxPlayers = value;

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
        unawaited(playGameMusic());
      } else {
        unawaited(playMenuMusic());
      }
    } else {
      unawaited(stopMusic());
    }
    if (_enablePlatformAudio) {
      unawaited(savePreferences(null));
    }
    notifyListeners();
  }

  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
    if (_enablePlatformAudio) {
      unawaited(savePreferences(null));
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_player?.dispose());
    for (final player in _sfxPlayers.values) {
      unawaited(player.dispose());
    }
    super.dispose();
  }

  /// Preloads all SFX assets into the shared cache so playback avoids
  /// re-reading and re-decoding from disk on every effect.
  Future<void> _preloadSfx() async {
    try {
      await _sfxCache?.loadAll(_sfxAssets.values.toList());
    } catch (e) {
      logError('AudioProvider', e);
    }
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

  Future<void> resumeMusic() async {
    if (!_musicEnabled) return;
    final current = _currentlyPlaying;
    if (current != null) {
      try {
        await _player?.play(AssetSource(current), volume: 0.5);
        await _player?.setReleaseMode(ReleaseMode.loop);
      } catch (e) {
        logError('AudioProvider', e);
      }
      return;
    }
    if (_isGameMusic) {
      await playGameMusic();
    } else {
      await playMenuMusic();
    }
  }

  Future<void> stopMusic() async {
    try {
      await _player?.stop();
    } catch (e) {
      logError('AudioProvider', e);
    } finally {
      _currentlyPlaying = null;
    }
  }

  /// Plays a sound effect. Errors from audio plugin are silently logged.
  Future<void> playSfx(GameSfx effect) async {
    if (!_sfxEnabled) return;
    final asset = _sfxAssets[effect];
    if (asset == null) return;
    final player = _sfxPlayers[effect];
    if (player == null) return;
    // Ignore re-triggers while the same SFX is mid-play to avoid
    // stop()/play() interleaving truncating the current playback.
    if (player.state == PlayerState.playing) return;

    try {
      await player.stop();
      await player.play(AssetSource(asset), volume: 1);
    } catch (e) {
      logError('AudioProvider', e);
    }
  }

  /// Returns the injected [injectedPrefs] if provided, otherwise the cached
  /// [SharedPreferences] instance (fetched once and reused).
  Future<SharedPreferences> _prefsInstance(
    SharedPreferences? injectedPrefs,
  ) async {
    if (injectedPrefs != null) return injectedPrefs;
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Loads persisted audio preferences. Errors fall back to defaults and are logged.
  @visibleForTesting
  Future<void> loadPreferences(SharedPreferences? injectedPrefs) async {
    try {
      final prefs = await _prefsInstance(injectedPrefs);
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
      final prefs = await _prefsInstance(injectedPrefs);
      await prefs.setBool('musicEnabled', _musicEnabled);
      await prefs.setBool('sfxEnabled', _sfxEnabled);
    } catch (e) {
      logError('AudioProvider', e);
    }
  }
}
