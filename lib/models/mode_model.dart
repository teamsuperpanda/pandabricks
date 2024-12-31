class ModeModel {
  final String name;
  final int speed;
  final double speedIncrease;
  final int scoreThreshold;
  final int rowClearScore;
  final int pandabrickSpawnPercentage;
  final int specialBlocksSpawnPercentage;
  final int? flipThreshold;

  ModeModel({
    required this.name,
    required this.speed,
    required this.speedIncrease,
    required this.scoreThreshold,
    required this.rowClearScore,
    required this.pandabrickSpawnPercentage,
    required this.specialBlocksSpawnPercentage,
    this.flipThreshold,
  });

  // Helper methods for special blocks
  bool get hasSpecialBlocks => specialBlocksSpawnPercentage > 0;
  bool get hasPandaBlocks => pandabrickSpawnPercentage > 0;
  bool get hasFlipFeature => flipThreshold != null;
}
