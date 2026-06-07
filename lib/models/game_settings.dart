import 'package:pandabricks/models/game_types.dart';

export 'package:pandabricks/models/game_types.dart'
    show CustomGameConfig, GameMode;

class GameSettings {
  const GameSettings({required this.mode, this.customConfig})
    : assert(mode != GameMode.custom || customConfig != null);

  const GameSettings.classic() : mode = GameMode.classic, customConfig = null;
  const GameSettings.timeChallenge()
    : mode = GameMode.timeChallenge,
      customConfig = null;
  const GameSettings.blitz() : mode = GameMode.blitz, customConfig = null;
  const GameSettings.custom(CustomGameConfig config)
    : mode = GameMode.custom,
      customConfig = config;
  final GameMode mode;
  final CustomGameConfig? customConfig;

  int get boardWidth => customConfig?.boardWidth ?? 10;
  int get boardHeight => customConfig?.boardHeight ?? 20;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSettings &&
          mode == other.mode &&
          customConfig == other.customConfig;

  @override
  int get hashCode => Object.hash(mode, customConfig);

  @override
  String toString() => 'GameSettings(mode: $mode, customConfig: $customConfig)';
}
