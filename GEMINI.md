# Panda Bricks Project Overview (Managed by Gemini)

This `GEMINI.md` file provides an overview of the Panda Bricks project, its structure, and how the Gemini CLI agent interacts with it.

## Project Description
Panda Bricks is a Flutter-based game, a modern take on the classic falling blocks game with a panda theme.

## Build Instructions
To build this app, use the following command:

`flutter run -d chrome`

## To Do
// Potential Bugs
Check the local storage for music and sound effects

// Modes
Blitz mode needs to be created
Add sound effects for certain events

// Dialogs
Help dialog needs to be added
Settings dialog needs to be added - check against previous version

// Gen
Keyboard controls to be added
Accessibility
Refactor (some screen files are quite large)

// Store
Screenshots
Google Play Release notes
Store Listing


// Tests
Critical Tests Missing
Game Logic Tests
Game class core functionality - The main game logic in game.dart has no tests for:
Piece spawning and collision detection
Line clearing logic and scoring
Game over conditions
Time challenge mode timer logic
Piece rotation and movement validation
Board state management
Provider Tests
AudioProvider - Currently has basic tests but missing:
SharedPreferences integration testing
Music/sound effect state persistence
Error handling when audio fails to load/play
Widget Integration Tests
GameScreen widget - No tests for:
Game state changes updating the UI
Timer updates in time challenge mode
Game over flow triggering dialogs
Pause/resume functionality
User input handling (gestures, controls)
Navigation Tests
Route handling - No tests for:
Navigation between screens with proper state
Game mode parameter passing
Back button/navigation confirmation flows
Nice to Have Tests
Performance Tests
Game loop performance - Testing frame rates and memory usage during gameplay
Animation smoothness - Ensuring 60fps during piece movement and line clearing
Large board state handling - Testing with complex board configurations
Accessibility Tests
Screen reader compatibility - Testing semantic labels and navigation
Keyboard navigation - When keyboard controls are added
High contrast mode - Visual accessibility testing
Edge Case Tests
Network connectivity - How the app behaves offline
Device rotation - Layout handling on orientation changes
Background/foreground - Game pause/resume when app loses focus
Low memory conditions - Graceful degradation
User Experience Tests
Tutorial flow - When help dialog is implemented
Settings persistence - Complex preference combinations
Sound synchronization - Audio cues matching game events
Visual feedback - Animations and particle effects
Platform-Specific Tests
Web-specific - Browser compatibility, local storage limits
Mobile-specific - Touch gesture accuracy, device performance
Cross-platform consistency - Same behavior across platforms
The most critical gap is the complete lack of testing for the core game logic - this is where bugs would be most impactful to the user experience.