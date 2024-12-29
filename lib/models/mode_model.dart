class ModeModel {
    final String name; // Add this line
    final int speed; // Speed of the falling pieces
    final int speedIncrease; // Speed increase after certain conditions
    final int scoreThreshold; // Score threshold for level up
    final int pandabrickSpawnPercentage; // Percentage chance of pandabrick spawn
    final int specialBlocksSpawnPercentage; // Percentage chance of special blocks spawn

    ModeModel({
        required this.name, // Add this line
        required this.speed,
        required this.speedIncrease,
        required this.scoreThreshold,
        required this.pandabrickSpawnPercentage,
        required this.specialBlocksSpawnPercentage,
    });
}
