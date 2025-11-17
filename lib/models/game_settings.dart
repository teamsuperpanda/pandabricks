import 'package:pandabricks/screens/game/game.dart';

/// Encapsulates game mode configuration for type-safe route argument passing.
/// 
/// This class provides a clean, type-safe way to pass game settings through
/// navigation, eliminating the need for loose type checking and string matching.
/// 
/// Example usage:
/// ```dart
/// // Classic mode
/// Navigator.of(context).pushNamed('/game', 
///   arguments: GameSettings(mode: GameMode.classic));
/// 
/// // Time challenge mode
/// Navigator.of(context).pushNamed('/game', 
///   arguments: GameSettings(mode: GameMode.timeChallenge));
/// 
/// // Custom mode with configuration
/// final config = CustomGameConfig(boardWidth: 8, timeLimit: Duration(minutes: 5));
/// Navigator.of(context).pushNamed('/game', 
///   arguments: GameSettings(mode: GameMode.custom, customConfig: config));
/// ```
class GameSettings {
  /// The game mode to play
  final GameMode mode;
  
  /// Configuration for custom game mode (required if mode is GameMode.custom)
  final CustomGameConfig? customConfig;
  
  const GameSettings({
    required this.mode,
    this.customConfig,
  }) : assert(
    mode != GameMode.custom || customConfig != null,
    'customConfig must be provided when mode is GameMode.custom',
  );
  
  /// Factory constructor for classic mode
  const GameSettings.classic() : mode = GameMode.classic, customConfig = null;
  
  /// Factory constructor for time challenge mode
  const GameSettings.timeChallenge() : mode = GameMode.timeChallenge, customConfig = null;
  
  /// Factory constructor for blitz mode
  const GameSettings.blitz() : mode = GameMode.blitz, customConfig = null;
  
  /// Factory constructor for custom mode
  GameSettings.custom(CustomGameConfig config) 
    : mode = GameMode.custom, 
      customConfig = config;
  
  /// Returns the board width, using custom config if available, otherwise default
  int get boardWidth => customConfig?.boardWidth ?? 10;
  
  /// Returns the board height, using custom config if available, otherwise default
  int get boardHeight => customConfig?.boardHeight ?? 20;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSettings &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          customConfig == other.customConfig;
  
  @override
  int get hashCode => mode.hashCode ^ customConfig.hashCode;
  
  @override
  String toString() => 'GameSettings(mode: $mode, customConfig: $customConfig)';
}
