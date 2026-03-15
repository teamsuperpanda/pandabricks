import 'package:pandabricks/screens/game/game.dart';

class GameSettings {
  final GameMode mode;
  final CustomGameConfig? customConfig;

  const GameSettings({required this.mode, this.customConfig})
      : assert(mode != GameMode.custom || customConfig != null);

  const GameSettings.classic() : mode = GameMode.classic, customConfig = null;
  const GameSettings.timeChallenge() : mode = GameMode.timeChallenge, customConfig = null;
  const GameSettings.blitz() : mode = GameMode.blitz, customConfig = null;
  GameSettings.custom(CustomGameConfig config) : mode = GameMode.custom, customConfig = config;

  int get boardWidth => customConfig?.boardWidth ?? 10;
  int get boardHeight => customConfig?.boardHeight ?? 20;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSettings && mode == other.mode && customConfig == other.customConfig;

  @override
  int get hashCode => Object.hash(mode, customConfig);

  @override
  String toString() => 'GameSettings(mode: $mode, customConfig: $customConfig)';
}
