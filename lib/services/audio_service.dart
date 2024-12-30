import 'package:just_audio/just_audio.dart';
import 'dart:math';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _menuMusic = AudioPlayer();
  final AudioPlayer _gameMusic = AudioPlayer();

  final List<String> _gameSongs =
      List.generate(6, (i) => 'audio/music/game/song${i + 1}.mp3');

  final Random _random = Random();
  int _lastPlayedIndex = -1;

  // Initialize menu music
  Future<void> initMenuMusic() async {
    await _menuMusic.setAsset('audio/music/menu.mp3');
    await _menuMusic.setLoopMode(LoopMode.all);
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

  // Cleanup
  void dispose() {
    _menuMusic.dispose();
    _gameMusic.dispose();
  }
}
