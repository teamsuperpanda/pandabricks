import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _menuMusic = AudioPlayer();
  final AudioPlayer _gameMusic = AudioPlayer();
  final AudioPlayer _flipSound = AudioPlayer();
  final AudioPlayer _gameOverSound = AudioPlayer();
  bool isSoundEffectsEnabled = true;

  final List<String> _gameSongs =
      List.generate(5, (i) => 'assets/audio/music/game/song${i + 1}.mp3');

  final Random _random = Random();
  int _lastPlayedIndex = -1;

  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    try {
      // Initialize with error handling
      await _initializeAudioPlayers();
    } catch (e) {
      debugPrint('Audio initialization error: $e');
      // Continue even if audio fails to initialize
    }
  }

  Future<void> _initializeAudioPlayers() async {
    try {
      // Load all sound effects with proper error handling
      await Future.wait([
        _player.setAsset('assets/audio/sfx/panda_disappear.mp3'),
        _flipSound.setAsset('assets/audio/sfx/flip.mp3'),
        _gameOverSound.setAsset('assets/audio/sfx/gameover.mp3'),
      ]).catchError((e) {
        debugPrint('Error loading sound effects: $e');
        return <Duration?>[];
      });
    } catch (e) {
      debugPrint('Error in _initializeAudioPlayers: $e');
    }
  }

  Future<void> playSound(String soundName) async {
    if (!isSoundEffectsEnabled) return;

    try {
      switch (soundName) {
        case 'panda_disappear':
          await _player.setAsset('assets/audio/sfx/panda_disappear.mp3');
          break;
        case 'game_over':
          await _player.setAsset('assets/audio/sfx/gameover.mp3');
          break;
        case 'pause':
          await _player.setAsset('assets/audio/sfx/pause.mp3');
          break;
      }
      await _player.seek(Duration.zero);
      await _player.play();
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

    // Load all sound effects first
    await Future.wait([
      _flipSound.setAsset('audio/sfx/flip.mp3'),
      _gameOverSound.setAsset('audio/sfx/gameover.mp3'),
    ]);
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

  Future<void> playStabSound() async {
    if (!isSoundEffectsEnabled) return;
    try {
      if (_flipSound.playing) {
        await _flipSound.stop();
      }
      await _flipSound.setAsset('assets/audio/sfx/flip.mp3');
      await _flipSound.seek(Duration.zero);
      await _flipSound.play();
    } catch (e) {
      debugPrint('Error playing stab sound: $e');
    }
  }

  Future<void> playGameOverSound() async {
    if (!isSoundEffectsEnabled) return;
    try {
      if (_gameOverSound.playing) {
        await _gameOverSound.stop();
      }
      await _gameOverSound.seek(Duration.zero);
      await _gameOverSound.play();
    } catch (e) {
      debugPrint('Error playing game over sound: $e');
    }
  }

  void setSoundEffectsEnabled(bool enabled) {
    isSoundEffectsEnabled = enabled;
  }

  // Cleanup
  void dispose() {
    _menuMusic.dispose();
    _gameMusic.dispose();
    _flipSound.dispose();
    _gameOverSound.dispose();
    _player.dispose();
  }

  void stopMenuMusic() {
    _menuMusic.stop();
  }
}
