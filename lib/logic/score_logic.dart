
class ScoreLogic {
  final Map<int, int> _scoreMultipliers = {
    1: 100, // Single line
    2: 300, // Double line
    3: 500, // Triple line
    4: 800, // Tetris (4 lines)
  };

  int score = 0;
  final int rowClearScore;

  ScoreLogic({
    required this.rowClearScore,
  });

  int updateScore(int clearedLines) {
    // Calculate base points from number of lines cleared
    int basePoints = (_scoreMultipliers[clearedLines] ?? 0) * rowClearScore;

    // Add points to score
    score += basePoints;

    return basePoints;
  }
}
