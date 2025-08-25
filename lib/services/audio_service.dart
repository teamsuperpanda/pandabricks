import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _menuMusic = AudioPlayer();
  final AudioPlayer _gameMusic = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer(); // Consolidated SFX player
  bool isSoundEffectsEnabled = true;

  final List<String> _gameSongs =
      List.generate(5, (i) => 'assets/audio/music/game/song${i + 1}.mp3');

  final Random _random = Random();
  int _lastPlayedIndex = -1;

  // Map to store pre-loaded sound effects
  final Map<String, AudioPlayer> _loadedSfx = {};

  Future<void> init() async {
    try {
      await _sfxPlayer.setAsset('assets/audio/sfx/panda_disappear.mp3');
      _loadedSfx['panda_disappear'] = _sfxPlayer;

      await _sfxPlayer.setAsset('assets/audio/sfx/flip.mp3');
      _loadedSfx['flip'] = _sfxPlayer;

      await _sfxPlayer.setAsset('assets/audio/sfx/gameover.mp3');
      _loadedSfx['game_over'] = _sfxPlayer;

      await _sfxPlayer.setAsset('assets/audio/sfx/pause.mp3');
      _loadedSfx['pause'] = _sfxPlayer;

      await _sfxPlayer.setAsset('assets/audio/sfx/row_clear.mp3');
      _loadedSfx['row_clear'] = _sfxPlayer;

      await _sfxPlayer.setAsset('assets/audio/sfx/bomb_explode.mp3');
      _loadedSfx['bomb_explode'] = _sfxPlayer;

    } catch (e) {
      debugPrint('Audio initialization error: $e');
    }
  }

  Future<void> playSound(String soundName) async {
    if (!isSoundEffectsEnabled) return;

    try {
      final player = _loadedSfx[soundName];
      if (player != null) {
        await player.seek(Duration.zero);
        await player.play();
      }
    } catch (e) {
      debugPrint('Error playing sound $soundName: $e');
    }
  }

  // Initialize menu music
  Future<void> initMenuMusic() async {
    try {
      await _menuMusic.setAsset('assets/audio/music/menu.mp3');
      await _menuMusic.setLoopMode(LoopMode.all);
    } catch (e) {
      debugPrint('Error initializing menu music: $e');
    }
  }

  // Game music methods
  Future<void> setupGameMusic() async {
    _gameSongs.shuffle();
    await _playNextGameSong();

    _gameMusic.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNextGameSong();
      }
    });
  }

  Future<void> _playNextGameSong() async {
    try {
      int nextIndex;
      do {
        nextIndex = _random.nextInt(_gameSongs.length);
      } while (nextIndex == _lastPlayedIndex);

      _lastPlayedIndex = nextIndex;
      String songPath = _gameSongs[nextIndex];
      debugPrint('Attempting to play song: $songPath');
      await _gameMusic.setAsset(songPath);
      await _gameMusic.play();
    } catch (e) {
      debugPrint('Error playing next game song: $e');
      // Try next song if current one fails
      if (_lastPlayedIndex < _gameSongs.length - 1) {
        _lastPlayedIndex++;
        _playNextGameSong();
      }
    }
  }

  // Control methods
  void playMenuMusic() {
    _menuMusic.play();
  }

  void pauseMenuMusic() {
    _menuMusic.pause();
  }

  void playGameMusic() {
    _gameMusic.play();
  }

  void pauseGameMusic() {
    _gameMusic.pause();
  }

  void stopGameMusic() {
    _gameMusic.stop();
  }

  void setSoundEffectsEnabled(bool enabled) {
    isSoundEffectsEnabled = enabled;
  }

  // Cleanup
  void dispose() {
    _menuMusic.dispose();
    _gameMusic.dispose();
    _sfxPlayer.dispose();
  }

  void stopMenuMusic() {
    _menuMusic.stop();
  }

  void stopAllSounds() {
    _sfxPlayer.stop();
    _gameMusic.stop();
    _menuMusic.stop();
  }
}
