import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:pandabricks/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService', () {
    late AudioService audioService;

    setUp(() {
      // Set up channel for audio mocking
      const MethodChannel channel =
          MethodChannel('com.ryanheise.audio_session');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return null;
      });

      audioService = AudioService();
    });

    test('sound effects can be toggled', () {
      // Should be enabled by default
      expect(audioService.isSoundEffectsEnabled, true);

      // Test disabling sound effects
      audioService.setSoundEffectsEnabled(false);
      expect(audioService.isSoundEffectsEnabled, false);

      // Test re-enabling sound effects
      audioService.setSoundEffectsEnabled(true);
      expect(audioService.isSoundEffectsEnabled, true);
    });

    test('singleton instance works correctly', () {
      final instance1 = AudioService();
      final instance2 = AudioService();

      // Should be the same instance
      expect(identical(instance1, instance2), true);

      // Changes to one instance should affect the other
      instance1.setSoundEffectsEnabled(false);
      expect(instance2.isSoundEffectsEnabled, false);
    });
  });
}
