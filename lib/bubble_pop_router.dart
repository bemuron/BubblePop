// File: lib/src/bubble_pop_app.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'screens/main_menu_screen.dart';
import 'level_selection/level_selection_screen.dart';
import 'play_session/play_session_screen.dart';
import 'settings/settings_screen.dart';
import 'style/palette.dart';

/// The router describes the game's navigational hierarchy, from the main
/// screen through settings screens to each individual level.
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainMenuScreen(),
      routes: [
        GoRoute(
          path: 'play/:level',
          pageBuilder: (context, state) {
            final level = int.tryParse(state.pathParameters['level'] ?? '');
            if (level == null) {
              // The level parameter is malformed, so we redirect back to the
              // level selection screen.
              return const MaterialPage<void>(child: LevelSelectionScreen());
            }

            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: PlaySessionScreen(level: level),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final palette = context.read<Palette>();
                return FadeTransition(
                  opacity: animation,
                  child: Container(
                    color: palette.backgroundLevelSelection,
                    child: child,
                  ),
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/level-select',
          builder: (context, state) => const LevelSelectionScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
