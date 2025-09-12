import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../game_internals/level_state.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';

/// You Won overlay that appears when the player wins
class YouWonScreen extends StatelessWidget {
  final VoidCallback onNextLevel;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  final LevelState levelState;

  const YouWonScreen({
    super.key,
    required this.levelState,
    required this.onNextLevel,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgressController>();

    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
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
                // You Won Title
                Text(
                  'You Won!',
                  style: TextStyle(
                    fontFamily: 'Permanent Marker',
                    fontSize: 32,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Level ${levelState.currentLevel} Completed!',
                  style: TextStyle(
                    fontSize: 18,
                    color: palette.ink,
                  ),
                ),

                const SizedBox(height: 20),

                // Final Score
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
                        '${levelState.score}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: palette.ink,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Next Level button
                    ElevatedButton.icon(
                      onPressed: () {
                        levelState.nextLevel();
                        onRestart;
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next Level'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    // Restart button
                    ElevatedButton.icon(
                        onPressed: () {
                          levelState.reset();
                          onRestart();
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
                  onPressed: onMainMenu,
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
    );
  }
}
