import 'package:pandabricks/models/mode_model.dart';

class Modes {
  static ModeModel easy = ModeModel(
    id: ModeId.easy,
    name: 'Easy',
    initialSpeed: 100,
    speedIncrease: 0,
    scoreThreshold: 0,
    pandabrickSpawnPercentage: 10,
    specialBlocksSpawnPercentage: 0,
    rowClearScore: 1,
  );

  static ModeModel normal = ModeModel(
    id: ModeId.normal,
    name: 'Normal',
    initialSpeed: 100,
    speedIncrease: 10,
    scoreThreshold: 1000,
    pandabrickSpawnPercentage: 5,
    specialBlocksSpawnPercentage: 0,
    rowClearScore: 1,
  );

  static ModeModel bambooblitz = ModeModel(
    id: ModeId.bambooblitz,
    name: 'Bamboo Blitz',
    initialSpeed: 100,
    speedIncrease: 30,
    scoreThreshold: 500,
    pandabrickSpawnPercentage: 5,
    specialBlocksSpawnPercentage: 10,
    rowClearScore: 2,
    flipThreshold: 3000,
  );

  static String getModeName(ModeModel mode) => mode.name;
  static ModeModel byId(ModeId id) {
    switch (id) {
      case ModeId.easy:
        return easy;
      case ModeId.normal:
        return normal;
      case ModeId.bambooblitz:
        return bambooblitz;
    }
  }
}
