// File: lib/src/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/banner_ad_widget.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgressController>();

    return Scaffold(
      backgroundColor: palette.backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 32,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: 40),

            // Sound toggle
            Card(
              child: SwitchListTile(
                title: const Text('Sound Effects'),
                value: settings.soundsOn,
                onChanged: (value) => settings.toggleSounds(),
              ),
            ),

            // Music toggle
            Card(
              child: SwitchListTile(
                title: const Text('Music'),
                value: settings.musicOn,
                onChanged: (value) => settings.toggleMusic(),
              ),
            ),

            const SizedBox(height: 20),

            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: palette.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('High Score: ${playerProgress.highScore}'),
                    Text('Games Played: ${playerProgress.gamesPlayed}'),
                    Text('Total Bubbles Popped: ${playerProgress.totalBubblesPopped}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Back button
            ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/'),
              child: const Text('Back to Menu'),
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