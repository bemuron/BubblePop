// File: lib/src/play_session/bubble_pop_game.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../game_internals/level_state.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import 'bubble_pop_flame.dart';
import '../player_progress/player_progress.dart';

/// Widget wrapper for the Flame game
class BubblePopGame extends StatefulWidget {
  const BubblePopGame({super.key});

  @override
  State<BubblePopGame> createState() => BubblePopGameState();
}

class BubblePopGameState extends State<BubblePopGame> {
  late BubblePopFlameGame game;

  @override
  void initState() {
    super.initState();
    game = BubblePopFlameGame();
  }

  // Public methods to control the game state
  void pauseGame() {
    game.pauseGame();
  }

  void resumeGame() {
    game.resumeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<LevelState, AudioController, AdsController, PlayerProgressController>(
      builder: (context, levelState, audioController, adsController, playerProgressController, child) {
        // Pass all controllers to the game
        game.levelState = levelState;
        game.audioController = audioController;
        game.adsController = adsController;
        game.playerProgressController = playerProgressController; // Pass the player progress controller

        return GameWidget<BubblePopFlameGame>.controlled(
          gameFactory: () => game,
        );
      },
    );
  }
}