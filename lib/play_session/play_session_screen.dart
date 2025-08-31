// File: lib/src/play_session/play_session_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
//import '../games_services/score.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';
import 'bubble_pop_game.dart';

class PlaySessionScreen extends StatefulWidget {
  const PlaySessionScreen({super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

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
          ),
        ),
      ],
      child: IgnorePointer(
        ignoring: _duringCelebration,
        child: Scaffold(
          backgroundColor: palette.backgroundPlaySession,
          body: Stack(
            children: [
              // The main game widget
              Positioned.fill(
                child: BubblePopGame(),
              ),

              // UI overlay for pause, score, etc.
              SafeArea(
                child: Stack(
                  children: [
                    // Back button
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

                    // Confetti overlay for celebration
                    SizedBox.expand(
                      child: Visibility(
                        visible: _duringCelebration,
                        child: IgnorePointer(
                          child: Confetti(
                            isStopped: !_duringCelebration,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _startOfPlay = DateTime.now();

    // Preload ad for when player loses
    final adsController = context.read<AdsController>();
    adsController.preloadAd();
  }

  bool _duringCelebration = false;

  Future<void> _playerLost() async {
    final levelState = context.read<LevelState>();
    final playerProgress = context.read<PlayerProgress>();
    final audioController = context.read<AudioController>();
    final adsController = context.read<AdsController>();

    // Record game completion and update high score
    await playerProgress.recordGamePlayed();
    await playerProgress.setHighScore(levelState.score);
    await playerProgress.recordBubblesPopped(levelState.bubblesPopped);

    audioController.playSfx(SfxType.gameOver);

    // Show interstitial ad after game over
    await adsController.showInterstitialAd();

    // Navigate back to main menu after a delay
    if (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      GoRouter.of(context).go('/');
    }
  }

  Future<void> _playerWon() async {
    final levelState = context.read<LevelState>();
    final playerProgress = context.read<PlayerProgress>();
    final audioController = context.read<AudioController>();

    // Record game completion and update high score
    await playerProgress.recordGamePlayed();
    await playerProgress.setHighScore(levelState.score);
    await playerProgress.recordBubblesPopped(levelState.bubblesPopped);

    audioController.playSfx(SfxType.victory);

    setState(() {
      _duringCelebration = true;
    });

    await Future.delayed(_preCelebrationDuration);

    if (!mounted) return;

    setState(() {
      _duringCelebration = false;
    });

    await Future.delayed(_celebrationDuration);

    if (!mounted) return;

    GoRouter.of(context).go('/');
  }
}