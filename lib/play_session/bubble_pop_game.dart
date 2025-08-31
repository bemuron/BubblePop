// File: lib/src/play_session/bubble_pop_game.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../game_internals/level_state.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import 'bubble_pop_flame.dart';

/// Widget wrapper for the Flame game
class BubblePopGame extends StatefulWidget {
  const BubblePopGame({super.key});

  @override
  State<BubblePopGame> createState() => _BubblePopGameState();
}

class _BubblePopGameState extends State<BubblePopGame> {
  late BubblePopFlameGame game;

  @override
  void initState() {
    super.initState();
    game = BubblePopFlameGame();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LevelState, AudioController, AdsController>(
      builder: (context, levelState, audioController, adsController, child) {
        // Pass all controllers to the game
        game.levelState = levelState;
        game.audioController = audioController;
        game.adsController = adsController;

        return GameWidget<BubblePopFlameGame>.controlled(
          gameFactory: () => game,
        );
      },
    );
  }
}