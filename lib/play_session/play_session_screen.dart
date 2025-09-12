// File: lib/src/play_session/play_session_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  //const PlaySessionScreen({super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  late DateTime _startOfPlay;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LevelState(
            onWin: _playerWon,
            onLose: _playerLost,
          )..startLevel(widget.level),
        ),
      ],
      child: Consumer<LevelState>(
        builder: (context, levelState, child) {
          return Scaffold(
            backgroundColor: palette.backgroundPlaySession,
            body: Stack(
              children: [
                Positioned.fill(child: BubblePopGame()),
                SafeArea(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkResponse(
                            onTap: () => GoRouter.of(context).pop(),
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
                    ],
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
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _startOfPlay = DateTime.now();

    final adsController = context.read<AdsController>();
    adsController.preloadAd();
  }

  Future<void> _playerLost() async {
    final levelState = context.read<LevelState>();
    final playerProgress = context.read<PlayerProgressController>();
    final audioController = context.read<AudioController>();

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

  Future<void> _playerWon() async {
    final playerProgress = context.read<PlayerProgressController>();
    final audioController = context.read<AudioController>();
    final levelState = context.read<LevelState>();

    await playerProgress.recordGamePlayed();
    await playerProgress.setHighScore(levelState.score);
    await playerProgress.recordBubblesPopped(levelState.bubblesPopped);

    audioController.playSfx(SfxType.victory);
  }
}