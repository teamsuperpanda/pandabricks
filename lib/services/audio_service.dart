import 'package:just_audio/just_audio.dart';
import 'dart:math';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _menuMusic = AudioPlayer();
  final AudioPlayer _gameMusic = AudioPlayer();
  final AudioPlayer _stabSound = AudioPlayer();
  final AudioPlayer _gameOverSound = AudioPlayer();
  bool isSoundEffectsEnabled = true;

  final List<String> _gameSongs =
      List.generate(6, (i) => 'audio/music/game/song${i + 1}.mp3');

  final Random _random = Random();
  int _lastPlayedIndex = -1;

  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    // Initialize the audio player and load sound assets
    await _player.setAsset('audio/sfx/panda_disappear.mp3');
    await _player.setAsset('audio/sfx/game_over.mp3');
  }

  Future<void> playSound(String soundName) async {
    if (!isSoundEffectsEnabled) return;

    try {
      switch (soundName) {
        case 'panda_disappear':
          await _player.setAsset('audio/sfx/panda_disappear.mp3');
          await _player.play();
          break;
        case 'game_over':
          await _player.setAsset('audio/sfx/game_over.mp3');
          await _player.play();
          break;
        case 'pause':
          await _player.setAsset('audio/sfx/pause.mp3');
          await _player.play();
          break;
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Initialize menu music
  Future<void> initMenuMusic() async {
    await _menuMusic.setAsset('audio/music/menu.mp3');
    await _menuMusic.setLoopMode(LoopMode.all);
  }

  // Game music methods
  Future<void> setupGameMusic() async {
    try {
      _gameSongs.shuffle();
      await _playNextGameSong();

      _gameMusic.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _playNextGameSong();
        }
      });

      // Load all sound effects first
      await Future.wait([
        _stabSound.setAsset('audio/sfx/stab.mp3'),
        _gameOverSound.setAsset('audio/sfx/gameover.mp3'),
      ]);

      print('Audio setup complete'); // Debug log
    } catch (e) {
      print('Error setting up audio: $e'); // Debug log
    }
  }

  Future<void> _playNextGameSong() async {
    int nextIndex;
    do {
      nextIndex = _random.nextInt(_gameSongs.length);
    } while (nextIndex == _lastPlayedIndex);

    _lastPlayedIndex = nextIndex;
    await _gameMusic.setAsset(_gameSongs[nextIndex]);
    await _gameMusic.play();
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
      if (_stabSound.playing) {
        await _stabSound.stop();
      }
      await _stabSound.seek(Duration.zero);
      await _stabSound.play();
      print('Stab sound played'); // Debug log
    } catch (e) {
      print('Error playing stab sound: $e'); // Debug log
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
      print('Game over sound played'); // Debug log
    } catch (e) {
      print('Error playing game over sound: $e'); // Debug log
    }
  }

  void setSoundEffectsEnabled(bool enabled) {
    isSoundEffectsEnabled = enabled;
  }

  // Cleanup
  void dispose() {
    _menuMusic.dispose();
    _gameMusic.dispose();
    _stabSound.dispose();
    _gameOverSound.dispose();
    _player.dispose();
  }
}
