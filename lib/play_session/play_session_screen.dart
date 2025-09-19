// File: lib/src/play_session/play_session_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart' hide Level;

import '../ads/banner_ad_widget.dart';
import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';
import 'bubble_pop_game.dart';
import '../screens/game_over_screen.dart';
import '../screens/you_won_screen.dart';

class PlaySessionScreen extends StatefulWidget {
  final int level;

  const PlaySessionScreen({required this.level, super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  late DateTime _startOfPlay;
  bool _isMenuVisible = false;

  // Create a global key for the BubblePopGame widget
  final GlobalKey<BubblePopGameState> _gameKey = GlobalKey<BubblePopGameState>();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [
        Provider.value(value: widget.level),
        ChangeNotifierProvider(
          create: (context) => LevelState(
            onWin: (LevelState levelState) => _playerWon(levelState), // Pass levelState
            onLose: (LevelState levelState) => _playerLost(levelState),
          )..startLevel(widget.level),
        ),
      ],
      child: Consumer<LevelState>(
        builder: (context, levelState, child) {
          final adsController = context.watch<AdsController>();

          return PopScope(
            // Prevent the user from exiting the screen with the system back button
            canPop: false,
            // Show the pause menu when a back event is invoked
            onPopInvoked: (bool didPop) {
              if (!didPop) {
                _showPauseMenu(levelState);
              }
            },
            child: Scaffold(
              backgroundColor: Colors.transparent, // Set Scaffold background to transparent
              body: Container(
                decoration: BoxDecoration(
                  color: palette.backgroundPlaySession, // Fallback color
                  image: const DecorationImage(
                    image: AssetImage('assets/images/play_screen_background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: BubblePopGame(key: _gameKey),
                          ),
                          SafeArea(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkResponse(
                                  onTap: () {
                                    _showPauseMenu(levelState);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: palette.backgroundSettings,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_new,
                                      color: palette.ink,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (levelState.isGameOver && levelState.didWin)
                            SizedBox.expand(
                              child: IgnorePointer(
                                child: Confetti(isStopped: false),
                              ),
                            ),
                          if (levelState.isGameOver && levelState.didWin)
                            YouWonScreen(
                              levelState: levelState,
                              onNextLevel: _nextLevel,
                              onRestart: _restartGame,
                              onMainMenu: _goToMainMenu,
                            ),
                          if (levelState.isGameOver && !levelState.didWin)
                            GameOverScreen(
                              levelState: levelState,
                              onRestart: _restartGame,
                            ),
                          if (_isMenuVisible) _buildPauseMenu(levelState, palette),

                          // New button for rewarded ads
                          if (levelState.freezeBubblesRemaining == 0 && adsController.isRewardedAdLoaded)
                            Positioned(
                              top: 50,
                              right: 10,
                              child: IconButton(
                                icon: Icon(Icons.ice_skating, color: palette.ink, size: 40),
                                onPressed: () {
                                  _gameKey.currentState?.pauseGame();
                                  adsController.showRewardedAd(
                                    onUserEarnedReward: () {
                                      levelState.addFreezeBubble();
                                    },
                                    onAdDismissed: () {
                                      _gameKey.currentState?.resumeGame();
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const BannerAdWidget(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // The pause menu widget
  Widget _buildPauseMenu(LevelState levelState, Palette palette) {
    return Center(
      child: Card(
        color: Colors.transparent, // Set the card color to transparent
        margin: const EdgeInsets.all(20),
        child: Container( // Add a container to hold the background color and padding
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: palette.backgroundPlaySession.withOpacity(0.8), // Use a semi-transparent color
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Game Paused',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: palette.ink),
              ),
              const SizedBox(height: 20),
              // Display game stats here
              Text('Score: ${levelState.score}', style: TextStyle(color: palette.ink)),
              Text('Stones: ${levelState.stones}', style: TextStyle(color: palette.ink)),
              Text('Level: ${levelState.currentLevel}', style: TextStyle(color: palette.ink)),
              Text('Water Flow: ${levelState.waterFlowPercentage.toStringAsFixed(0)}%', style: TextStyle(color: palette.ink)),
              Text('Bubbles Popped: ${levelState.bubblesPopped}', style: TextStyle(color: palette.ink)),
              Text('Goal: ${levelState.goalText}', style: TextStyle(color: palette.ink)),
              const SizedBox(height: 20),
              // Buttons
              ElevatedButton(
                onPressed: () {
                  _resumeGame();
                },
                child: const Text('Resume'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _exitGame();
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show the pause menu and pause the game
  void _showPauseMenu(LevelState levelState) {
    _gameKey.currentState?.pauseGame();
    setState(() {
      _isMenuVisible = true;
    });
  }

  // resume the game
  void _resumeGame() {
    _gameKey.currentState?.resumeGame();
    setState(() {
      _isMenuVisible = false;
    });
  }

  // Exit the game and navigate back
  void _exitGame() {
    GoRouter.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _startOfPlay = DateTime.now();

    final adsController = context.read<AdsController>();
    adsController.preloadAd();
  }

  Future<void> _playerLost(LevelState levelState) async {
    print('DEBUG: _playerLost called!');
    //final levelState = context.read<LevelState>();
    final playerProgress = context.read<PlayerProgressController>();
    final audioController = context.read<AudioController>();
    _log.info('Player Progress Level ${levelState.currentLevel} lost');

    await playerProgress.recordGamePlayed();
    await playerProgress.setHighScore(levelState.score);
    await playerProgress.recordBubblesPopped(levelState.bubblesPopped);

    audioController.playSfx(SfxType.gameOver);
  }

  void _nextLevel() {
    final levelState = context.read<LevelState>();
    final adsController = context.read<AdsController>();

    adsController.preloadAd();
    levelState.nextLevel();
  }

  void _restartGame() {
    final levelState = context.read<LevelState>();
    final adsController = context.read<AdsController>();

    adsController.preloadAd();
    levelState.reset();
  }

  void _goToMainMenu() {
    GoRouter.of(context).go('/');
  }

  Future<void> _playerWon(LevelState levelState) async {
    print('DEBUG: _playerWon called!');
    _log.info('Level ${widget.level} won');
    final playerProgress = context.read<PlayerProgressController>();
    final audioController = context.read<AudioController>();
    //final levelState = context.read<LevelState>();

    _log.info('Player Progress Level ${levelState.currentLevel} won');

    await playerProgress.recordGamePlayed();
    await playerProgress.setHighScore(levelState.score);
    await playerProgress.recordBubblesPopped(levelState.bubblesPopped);

    // Calculate and record stars based on score
    final stars = _calculateStars(levelState.score, levelState.currentLevel, true);
    await playerProgress.recordLevelCompletion(levelState.currentLevel, stars: stars);
    playerProgress.setLevelReached(levelState.currentLevel);

    audioController.playSfx(SfxType.victory);
  }

  // This helper method needs to be added to calculate stars
  int _calculateStars(int score, int level, bool achievedGoal) {
    // Must achieve the level goal to get any stars
    if (!achievedGoal) {
      return 0;
    }

    // Base star for completing the goal
    int stars = 1;

    // Additional stars based on performance
    if (score >= 500) {
      stars = 3;
    } else if (score >= 300) {
      stars = 2;
    }

    return stars;
  }
}