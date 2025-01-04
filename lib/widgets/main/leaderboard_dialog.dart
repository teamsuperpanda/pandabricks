import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/dialog/glowing_button.dart';
import 'package:pandabricks/services/games_services.dart';

class LeaderboardDialog extends StatelessWidget {
  final Map<String, int> highScores;
  final GamesServicesController gamesServices;

  const LeaderboardDialog({
    super.key,
    required this.highScores,
    required this.gamesServices,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF1A1A2E)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withAlpha((0.1 * 255).round()),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Leaderboards',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLeaderboardButton(
                  'EASY',
                  const Color(0xFF2ECC71),
                  highScores['Easy'] ?? 0,
                  () => gamesServices.showLeaderboard('Easy'),
                ),
                _buildLeaderboardButton(
                  'NORMAL',
                  const Color(0xFF3498DB),
                  highScores['Normal'] ?? 0,
                  () => gamesServices.showLeaderboard('Normal'),
                ),
                _buildLeaderboardButton(
                  'BLITZ',
                  const Color(0xFFE74C3C),
                  highScores['BambooBlitz'] ?? 0,
                  () => gamesServices.showLeaderboard('BambooBlitz'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardButton(
    String text,
    Color color,
    int score,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        GlowingButton(
          onPressed: onPressed,
          color: color,
          text: text,
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Fredoka',
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
