import 'package:pandabricks/models/mode_model.dart';

class Modes {
  static ModeModel easy = ModeModel(
    name: 'Easy',
    speed: 100,
    speedIncrease: 0,
    scoreThreshold: 0,
    pandabrickSpawnPercentage: 20,
    rowClearScore: 1,
    // specialBlocksSpawnPercentage: 0
  );

  static ModeModel normal = ModeModel(
    name: 'Normal',
    speed: 100,
    speedIncrease: 5,
    scoreThreshold: 2000,
    pandabrickSpawnPercentage: 5,
    rowClearScore: 1,
    // specialBlocksSpawnPercentage: 0
  );

  static ModeModel bambooblitz = ModeModel(
    name: 'Bambooblitz',
    speed: 100,
    speedIncrease: 10,
    scoreThreshold: 1500,
    pandabrickSpawnPercentage: 5,
    rowClearScore: 2,
    // specialBlocksSpawnPercentage: 20
  );

  static String getModeName(ModeModel mode) {
    if (mode == easy) return 'Easy';
    if (mode == normal) return 'Normal';
    if (mode == bambooblitz) return 'Bambooblitz';
    return 'Unknown';
  }
}
