import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_provider_test.mocks.dart'; // Generated file

@GenerateMocks([AudioPlayer, SharedPreferences])
void main() {
  group('AudioProvider', () {
    late AudioProvider audioProvider;
    late MockAudioPlayer mockPlayer;
    late MockAudioPlayer mockSfxPlayer;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() async {
      mockPlayer = MockAudioPlayer();
      mockSfxPlayer = MockAudioPlayer();
      mockSharedPreferences = MockSharedPreferences();

      // Mock SharedPreferences.getInstance()
      SharedPreferences.setMockInitialValues({});
      when(mockSharedPreferences.getBool(any)).thenReturn(true); // Default to enabled
      when(mockSharedPreferences.setBool(any, any)).thenAnswer((_) async => true);
      
      // Provide the mock instance when getInstance is called
      // This is a bit tricky as getInstance is static. We'll rely on setMockInitialValues
      // and ensure our mock is used by the provider.
      
      audioProvider = AudioProvider(enablePlatformAudio: false); // Prevent internal AudioPlayer creation
      audioProvider.player = mockPlayer;
      audioProvider.sfxPlayer = mockSfxPlayer;
      await audioProvider.loadPreferences(mockSharedPreferences); // Manually load preferences
    });

    test('initialization sets music and sfx enabled to true by default', () {
      // This test already uses enablePlatformAudio: false, so no change needed here.
      expect(audioProvider.musicEnabled, isTrue);
      expect(audioProvider.sfxEnabled, isTrue);
    });

    test('toggleMusic toggles musicEnabled state', () {
      expect(audioProvider.musicEnabled, isTrue);
      audioProvider.toggleMusic();
      expect(audioProvider.musicEnabled, isFalse);
      audioProvider.toggleMusic();
      expect(audioProvider.musicEnabled, isTrue);
    });

    test('toggleSfx toggles sfxEnabled state', () {
      expect(audioProvider.sfxEnabled, isTrue);
      audioProvider.toggleSfx();
      expect(audioProvider.sfxEnabled, isFalse);
      audioProvider.toggleSfx();
      expect(audioProvider.sfxEnabled, isTrue);
    });

    test('playMenuMusic plays menu track when music is enabled', () async {
      await audioProvider.playMenuMusic();
      verify(mockPlayer.play(argThat(isA<AssetSource>().having((p0) => p0.path, 'path', AudioProvider.menuTrack)), volume: 0.5)).called(1);
      verify(mockPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
    });

    test('playMenuMusic does not play when music is disabled', () async {
      audioProvider.toggleMusic(); // Disable music
      await audioProvider.playMenuMusic();
      verifyNever(mockPlayer.play(any, volume: anyNamed('volume')));
    });

    test('playGameMusic plays a game track when music is enabled', () async {
      await audioProvider.playGameMusic();
      verify(mockPlayer.play(argThat(isA<AssetSource>().having((p0) => p0.path, 'path', isIn(AudioProvider.gameTracks))), volume: 0.5)).called(1);
      verify(mockPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
    });

    test('playGameMusic does not play when music is disabled', () async {
      audioProvider.toggleMusic(); // Disable music
      await audioProvider.playGameMusic();
      verifyNever(mockPlayer.play(any, volume: anyNamed('volume')));
    });

    test('stopMusic stops the player and clears currently playing track', () async {
      await audioProvider.stopMusic();
      verify(mockPlayer.stop()).called(1);
      expect(audioProvider.currentlyPlaying, isNull);
    });

    test('playSfx plays sfx when sfx is enabled', () async {
      await audioProvider.playSfx(GameSfx.rowClear);
      verify(mockSfxPlayer.play(argThat(isA<AssetSource>().having((p0) => p0.path, 'path', 'audio/sfx/row_clear.mp3')), volume: 1.0)).called(1);
    });

    test('playSfx does not play when sfx is disabled', () async {
      audioProvider.toggleSfx(); // Disable sfx
      await audioProvider.playSfx(GameSfx.rowClear);
      verifyNever(mockSfxPlayer.play(any, volume: anyNamed('volume')));
    });

    test('dispose disposes audio players', () {
      audioProvider.dispose();
      verify(mockPlayer.dispose()).called(1);
      verify(mockSfxPlayer.dispose()).called(1);
    });
  });
}