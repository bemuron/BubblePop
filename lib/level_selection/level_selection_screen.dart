// File: lib/src/level_selection/level_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/banner_ad_widget.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final audioController = context.watch<AudioController>();
    final playerProgress = context.watch<PlayerProgressController>();

    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          children: [
            // Back button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    audioController.playSfx(SfxType.buttonTap);
                    GoRouter.of(context).go('/');
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
            ),

            // Title
            Text(
              'Select Level',
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 32,
                color: palette.ink,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Level grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: List.generate(5, (index) {
                  final level = index + 1;
                  final config = LevelConfig.getLevel(level);

                  return _LevelCard(
                    level: level,
                    config: config,
                    onTap: () {
                      audioController.playSfx(SfxType.buttonTap);
                      GoRouter.of(context).go('/play/$level');
                    },
                  );
                }),
              ),
            ),
          ],
        ),
        rectangularMenuArea: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BannerAdWidget(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final LevelConfig config;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.config,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Level number
              Text(
                'Level $level',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: palette.ink,
                ),
              ),

              const SizedBox(height: 8),

              // Level info
              Text(
                'Stones: ${config.initialStones}',
                style: TextStyle(
                  fontSize: 14,
                  color: palette.ink.withOpacity(0.7),
                ),
              ),

              Text(
                'Freeze: ${config.freezeBubbles}',
                style: TextStyle(
                  fontSize: 14,
                  color: palette.ink.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 8),

              // Goal
              Text(
                config.goal,
                style: TextStyle(
                  fontSize: 12,
                  color: palette.ink.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Difficulty indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final filled = index < _getDifficultyLevel(level);
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: filled ? Colors.amber : Colors.grey[300],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getDifficultyLevel(int level) {
    // Return 1-5 stars based on difficulty
    switch (level) {
      case 1: return 1;
      case 2: return 2;
      case 3: return 3;
      case 4: return 4;
      default: return 5; // Level 5+ is max difficulty
    }
  }
}