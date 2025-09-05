// File: lib/main_menu/main_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/banner_ad_widget.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../player_progress/player_progress.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();
    final playerProgress = context.watch<PlayerProgressController>();

    // Update audio controller with current settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioController.updateSettings(
        musicOn: settingsController.musicOn,
        soundsOn: settingsController.soundsOn,
      );
    }); // Fixed: Use PlayerProgressController

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: ResponsiveScreen(
        squarishMainArea: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Title
              Text(
                'Bubble Pop',
                style: TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: 48,
                  color: palette.ink,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: palette.inkFullOpacity.withOpacity(0.3),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // High Score Display
              if (playerProgress.highScore > 0) // Fixed: Use highScore instead of highestLevelReached
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.backgroundSettings.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'High Score: ${playerProgress.highScore}', // Fixed: Use highScore
                    style: TextStyle(
                      fontSize: 20,
                      color: palette.ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Play Button
              ElevatedButton(
                onPressed: () {
                  audioController.playSfx(SfxType.buttonTap);
                  GoRouter.of(context).go('/level-select');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.backgroundLevelSelection,
                  foregroundColor: palette.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Play'),
              ),

              const SizedBox(height: 20),

              // Settings Button
              OutlinedButton(
                onPressed: () {
                  audioController.playSfx(SfxType.buttonTap);
                  GoRouter.of(context).go('/settings');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.ink,
                  side: BorderSide(color: palette.ink),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Settings'),
              ),
            ],
          ),
        ),
        rectangularMenuArea: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Banner Ad at the bottom
            BannerAdWidget(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}