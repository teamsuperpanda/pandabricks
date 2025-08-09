import 'package:mockito/mockito.dart';
import 'package:pandabricks/services/audio_service.dart';

class MockAudioService extends Mock implements AudioService {
  @override
  Future<void> playSound(String soundName) async {}

  @override
  Future<void> init() async {}

  @override
  void playGameMusic() {}

  @override
  void pauseGameMusic() {}

  @override
  void stopGameMusic() {}
}
