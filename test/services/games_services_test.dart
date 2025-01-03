import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pandabricks/services/games_services.dart';
import 'package:games_services/games_services.dart';
import 'package:flutter/services.dart';

// Generate mocks
@GenerateMocks([GoogleSignIn, GoogleSignInAccount])
import 'games_services_test.mocks.dart';

class MockGamesServices extends Mock implements GamesServices {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GamesServicesController controller;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    controller = GamesServicesController();
    controller.googleSignIn = mockGoogleSignIn;

    // Mock static methods of GamesServices
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('games_services'),
      (call) async {
        switch (call.method) {
          case 'signIn':
            return null;
          case 'submitScore':
            return null;
          case 'showLeaderboards':
            final leaderboardId = call.arguments['leaderboardID'] as String?;
            if (leaderboardId == null || leaderboardId.isEmpty) {
              throw PlatformException(
                code: 'INVALID_GAME_MODE',
                message: 'Invalid game mode',
              );
            }
            return null;
          default:
            throw PlatformException(
              code: 'UNSUPPORTED_METHOD',
              message: 'Method not implemented',
            );
        }
      },
    );
  });

  group('GamesServicesController', () {
    test('initialize - successful sign in', () async {
      // Arrange
      when(mockGoogleSignIn.signInSilently())
          .thenAnswer((_) async => mockAccount);

      // Act
      await controller.initialize();

      // Assert
      expect(await controller.isSignedIn, true);
      verify(mockGoogleSignIn.signInSilently()).called(1);
    });

    test('initialize - failed sign in', () async {
      // Arrange
      when(mockGoogleSignIn.signInSilently()).thenAnswer((_) async => null);
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      // Act
      await controller.initialize();

      // Assert
      expect(await controller.isSignedIn, false);
      verify(mockGoogleSignIn.signInSilently()).called(1);
      verify(mockGoogleSignIn.signIn()).called(1);
    });

    test('submitScore - when signed in', () async {
      // Arrange
      controller.setSignedIn(true); // Helper method we'll add

      // Act
      await controller.submitScore(
        score: 100,
        gameMode: 'easy',
      );

      // No direct verification possible as GamesServices is not mockable
      // We can only verify that no exception is thrown
    });

    test('submitScore - when not signed in', () async {
      // Arrange
      controller.setSignedIn(false); // Helper method we'll add

      // Act
      await controller.submitScore(
        score: 100,
        gameMode: 'easy',
      );

      // No score should be submitted when not signed in
    });

    test('showLeaderboard - validates game mode', () async {
      // Arrange
      controller.setSignedIn(true);

      // Act & Assert
      await expectLater(
        () => controller.showLeaderboard('invalid_mode'),
        throwsA(isA<PlatformException>().having(
          (e) => e.code,
          'code',
          'INVALID_GAME_MODE',
        )),
      );
    });
  });
}
