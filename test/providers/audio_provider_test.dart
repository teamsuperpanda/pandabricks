import 'package:flutter_test/flutter_test.dart';
import '../mocks/mock_audio_provider.dart';

void main() {
  group('AudioProvider Tests', () {
    late MockAudioProvider audioProvider;

    setUp(() {
      audioProvider = MockAudioProvider();
    });

    test('should have music enabled by default', () {
      expect(audioProvider.musicEnabled.value, isTrue);
    });

    test('should have sfx enabled by default', () {
      expect(audioProvider.sfxEnabled.value, isTrue);
    });

    test('should toggle music setting', () {
      expect(audioProvider.musicEnabled.value, isTrue);
      
      audioProvider.toggleMusic();
      expect(audioProvider.musicEnabled.value, isFalse);
      
      audioProvider.toggleMusic();
      expect(audioProvider.musicEnabled.value, isTrue);
    });

    test('should toggle sfx setting', () {
      expect(audioProvider.sfxEnabled.value, isTrue);
      
      audioProvider.toggleSfx();
      expect(audioProvider.sfxEnabled.value, isFalse);
      
      audioProvider.toggleSfx();
      expect(audioProvider.sfxEnabled.value, isTrue);
    });

    test('should notify listeners when music is toggled', () {
      bool notified = false;
      audioProvider.addListener(() {
        notified = true;
      });
      
      audioProvider.toggleMusic();
      expect(notified, isTrue);
    });

    test('should notify listeners when sfx is toggled', () {
      bool notified = false;
      audioProvider.addListener(() {
        notified = true;
      });
      
      audioProvider.toggleSfx();
      expect(notified, isTrue);
    });

    test('should play menu music when requested', () {
      audioProvider.playMenuMusic();
      expect(audioProvider.currentlyPlaying, equals(MockAudioProvider.menuTrack));
      expect(audioProvider.isGameMusic, isFalse);
    });

    test('should play game music when requested', () {
      audioProvider.playGameMusic();
      expect(audioProvider.currentlyPlaying, equals(MockAudioProvider.gameTracks[0]));
      expect(audioProvider.isGameMusic, isTrue);
    });

    test('should stop music when requested', () {
      audioProvider.playMenuMusic();
      expect(audioProvider.currentlyPlaying, isNotNull);
      
      audioProvider.stopMusic();
      expect(audioProvider.currentlyPlaying, isNull);
    });

    test('should not play music when music is disabled', () {
      audioProvider.toggleMusic(); // Disable music
      expect(audioProvider.musicEnabled.value, isFalse);
      
      audioProvider.playMenuMusic();
      expect(audioProvider.currentlyPlaying, isNull);
    });

    test('should have correct menu track constant', () {
      expect(MockAudioProvider.menuTrack, equals('audio/music/menu.mp3'));
    });

    test('should have correct game tracks constants', () {
      expect(MockAudioProvider.gameTracks, hasLength(6));
      expect(MockAudioProvider.gameTracks[0], equals('audio/music/game/song1.mp3'));
      expect(MockAudioProvider.gameTracks[5], equals('audio/music/game/song6.mp3'));
    });
  });
}
