// File: lib/src/play_session/game_over_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';

/// Game Over overlay that appears when the player loses
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({
    super.key,
    required this.onRestart,
    required this.levelState, // Pass levelState directly
  });

  final VoidCallback onRestart;
  final LevelState levelState; // Add this parameter

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();
    final adsController = context.watch<AdsController>();

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: palette.backgroundSettings,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Game Over Title
                        Text(
                          'Game Over!',
                          style: TextStyle(
                            fontFamily: 'Permanent Marker',
                            fontSize: 32,
                            color: palette.ink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Current Score
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: palette.backgroundMain.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Final Score',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: palette.ink.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                '${widget.levelState.score}', // Use widget.levelState
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: palette.ink,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // High Score (if beaten)
                        if (widget.levelState.score > playerProgress.highScore)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber, width: 2),
                            ),
                            child: Text(
                              '🎉 New High Score! 🎉',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: palette.ink,
                              ),
                            ),
                          ),

                        const SizedBox(height: 30),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Continue with Ad button
                            ElevatedButton.icon(
                              onPressed: () {
                                // Preload another ad before showing
                                adsController.preloadAd();
                                adsController.showRewardedAd(
                                  onUserEarnedReward: () {
                                    // Reset stones to continue playing
                                    widget.levelState.reset();
                                    widget.onRestart();
                                  },
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Continue'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),

                            // Restart button
                            ElevatedButton.icon(
                              onPressed: () {
                                widget.onRestart(); // Use widget.onRestart
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Restart'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: palette.backgroundLevelSelection,
                                foregroundColor: palette.ink,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Main Menu button
                        TextButton(
                          onPressed: () {
                            GoRouter.of(context).go('/');
                          },
                          child: Text(
                            'Main Menu',
                            style: TextStyle(
                              color: palette.ink.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}