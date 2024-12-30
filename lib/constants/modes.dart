import 'package:pandabricks/models/mode_model.dart';

class Modes {
  static ModeModel easy = ModeModel(
    name: 'Easy',
    speed: 100,
    speedIncrease: 0,
    scoreThreshold: 0,
    pandabrickSpawnPercentage: 25,
    rowClearScore: 100,
    // specialBlocksSpawnPercentage: 0
  );

  static ModeModel normal = ModeModel(
    name: 'Normal',
    speed: 100,
    speedIncrease: 1,
    scoreThreshold: 1000,
    pandabrickSpawnPercentage: 5,
    rowClearScore: 50,
    // specialBlocksSpawnPercentage: 0
  );

  static ModeModel bambooblitz = ModeModel(
    name: 'Bambooblitz',
    speed: 100,
    speedIncrease: 1,
    scoreThreshold: 500,
    pandabrickSpawnPercentage: 5,
    rowClearScore: 50,
    // specialBlocksSpawnPercentage: 20
  );

  static String getModeName(ModeModel mode) {
    if (mode == easy) return 'Easy';
    if (mode == normal) return 'Normal';
    if (mode == bambooblitz) return 'Bambooblitz';
    return 'Unknown';
  }
}
