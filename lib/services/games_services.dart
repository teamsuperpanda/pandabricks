import 'package:games_services/games_services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

class GamesServicesController {
  static const String easyLeaderboardId = 'CgkIwo7w47ENEAIQAA';
  static const String normalLeaderboardId = 'CgkIwo7w47ENEAIQAQ';
  static const String blitzLeaderboardId = 'CgkIwo7w47ENEAIQAg';

  // Make GoogleSignIn injectable for testing
  GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/games']);
  bool _isSignedIn = false;

  Future<bool> get isSignedIn async => _isSignedIn;

  Future<void> initialize() async {
    try {
      // First try Google Sign In
      final account =
          await googleSignIn.signInSilently() ?? await googleSignIn.signIn();
      if (account == null) {
        _isSignedIn = false;
        return;
      }

      // Then initialize Games Services
      await GamesServices.signIn();
      _isSignedIn = true;
    } catch (e) {
      _isSignedIn = false;
    }
  }

  Future<void> submitScore({
    required int score,
    required String gameMode,
  }) async {
    if (!_isSignedIn) return;

    try {
      String leaderboardId;
      switch (gameMode.toLowerCase()) {
        case 'easy':
          leaderboardId = easyLeaderboardId;
          break;
        case 'normal':
          leaderboardId = normalLeaderboardId;
          break;
        case 'bamboo blitz':
          leaderboardId = blitzLeaderboardId;
          break;
        default:
          throw PlatformException(
            code: 'INVALID_GAME_MODE',
            message: 'Invalid game mode',
          );
      }

      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: leaderboardId,
          value: score,
        ),
      );
    } catch (e) {
      // print('Error submitting score: $e');
    }
  }

  Future<void> showLeaderboard(String gameMode) async {
    if (!_isSignedIn) return;

    try {
      String leaderboardId;
      switch (gameMode.toLowerCase()) {
        case 'easy':
          leaderboardId = easyLeaderboardId;
          break;
        case 'normal':
          leaderboardId = normalLeaderboardId;
          break;
        case 'bamboo blitz':
          leaderboardId = blitzLeaderboardId;
          break;
        default:
          throw PlatformException(
            code: 'INVALID_GAME_MODE',
            message: 'Invalid game mode',
          );
      }

      await GamesServices.showLeaderboards(
        androidLeaderboardID: leaderboardId,
      );
    } catch (e) {
      // print('Error showing leaderboard: $e');
      rethrow;
    }
  }

  // Add helper method for testing
  @visibleForTesting
  void setSignedIn(bool value) {
    _isSignedIn = value;
  }
}
