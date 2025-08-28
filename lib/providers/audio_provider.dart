
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AudioProvider extends ChangeNotifier {
  final ValueNotifier<bool> musicEnabled = ValueNotifier<bool>(true);
  final ValueNotifier<bool> sfxEnabled = ValueNotifier<bool>(true);

  AudioPlayer? _player;
  bool _isGameMusic = false;
  String? _currentlyPlaying;
  final bool _enablePlatformAudio;

  AudioProvider({bool enablePlatformAudio = true}) : _enablePlatformAudio = enablePlatformAudio {
    if (enablePlatformAudio) {
      // Creating an AudioPlayer touches platform channels. Skip in tests.
      _player = AudioPlayer();
      _loadPreferences();
    }
  }

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
    if (_enablePlatformAudio) {
      _savePreferences();
    }
    notifyListeners();
  }

  void toggleSfx() {
    sfxEnabled.value = !sfxEnabled.value;
    if (_enablePlatformAudio) {
      _savePreferences();
    }
    notifyListeners();
  }

    @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  void playMenuMusic() async {
    _isGameMusic = false;
    if (!musicEnabled.value) return;
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

  void playGameMusic() async {
    _isGameMusic = true;
    if (!musicEnabled.value) return;
    debugPrint('Playing game music');
    try {
      if (_player != null) {
        await _player!.stop();
      }
      final track = gameTracks[Random().nextInt(gameTracks.length)];
      if (_player != null) {
        await _player!.play(AssetSource(track), volume: 0.5);
        await _player!.setReleaseMode(ReleaseMode.loop);
      }
      _currentlyPlaying = track;
    } catch (e) {
      debugPrint('Error playing game music: $e');
    }
  }

  void stopMusic() async {
    debugPrint('Stopping music');
    if (_player != null) {
      await _player!.stop();
    }
    _currentlyPlaying = null;
  }

  void disposePlayer() {
    _player?.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      musicEnabled.value = prefs.getBool('musicEnabled') ?? true;
      sfxEnabled.value = prefs.getBool('sfxEnabled') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('musicEnabled', musicEnabled.value);
      await prefs.setBool('sfxEnabled', sfxEnabled.value);
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }
}