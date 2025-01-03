import 'package:pandabricks/models/mode_model.dart';

class Modes {
  static ModeModel easy = ModeModel(
    name: 'Easy',
    initialSpeed: 100,
    speedIncrease: 0,
    scoreThreshold: 0,
    pandabrickSpawnPercentage: 20,
    specialBlocksSpawnPercentage: 0,
    rowClearScore: 1,
  );

  static ModeModel normal = ModeModel(
    name: 'Normal',
    initialSpeed: 100,
    speedIncrease: 10,
    scoreThreshold: 1000,
    pandabrickSpawnPercentage: 5,
    specialBlocksSpawnPercentage: 0,
    rowClearScore: 1,
  );

  static ModeModel bambooblitz = ModeModel(
    name: 'Bamboo Blitz',
    initialSpeed: 30,
    speedIncrease: 20,
    scoreThreshold: 500,
    pandabrickSpawnPercentage: 5,
    specialBlocksSpawnPercentage: 10,
    rowClearScore: 2,
    flipThreshold: 3000,
  );

  static String getModeName(ModeModel mode) => mode.name;
}
