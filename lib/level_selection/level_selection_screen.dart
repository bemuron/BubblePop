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
      backgroundColor: Colors.transparent, // Set Scaffold background to transparent
      body: Container(
        decoration: BoxDecoration(
          color: palette.backgroundLevelSelection, // Fallback color
          image: const DecorationImage(
            image: AssetImage('assets/images/level_selection_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ResponsiveScreen(
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
                      //GoRouter.of(context).pop(); // Corrected back button logic
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
                  fontSize: 35,
                  color: palette.whitePen,
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
                  children: List.generate(6, (index) {
                    final level = index + 1;
                    final config = LevelConfig.getLevel(level);
                    final isUnlocked = level <= playerProgress.highestLevelReached + 1;
                    final stars = playerProgress.starsForLevel[level] ?? 0;

                    if (isUnlocked) {
                      return _LevelCard(
                        level: level,
                        config: config,
                        stars: stars,
                        onTap: () {
                          audioController.playSfx(SfxType.buttonTap);
                          GoRouter.of(context).go('/play/$level');
                        },
                      );
                    } else {
                      return const _LockedLevelCard();
                    }
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
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final LevelConfig config;
  final int stars; // New parameter
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.config,
    required this.stars,
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
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    config.goal,
                    style: TextStyle(
                      fontSize: 20,
                      color: palette.ink.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    size: 16,
                    color: index < stars ? Colors.amber : Colors.grey[300],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedLevelCard extends StatelessWidget {
  const _LockedLevelCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Card(
      elevation: 4,
      color: Colors.grey.withOpacity(0.5),
      child: InkWell(
        onTap: () {}, // Do nothing when tapped
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 48,
              color: palette.ink.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'Locked',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: palette.ink.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}