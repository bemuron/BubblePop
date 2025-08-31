import 'package:bubble_pop/play_session/bubble_pop_flame.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart'; // Added for TapCallbacks
import 'package:flutter/material.dart';

import '/main.dart';

// Game Over Menu overlay.
class GameOverMenu extends PositionComponent with HasGameRef<BubblePopFlameGame>, TapCallbacks {
  final VoidCallback onRestart;
  late final RectangleComponent background;
  late final TextComponent gameOverText;
  late final TextComponent restartText;

  GameOverMenu({required this.onRestart});

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // Added await

    // Create a semi-transparent background.
    background = RectangleComponent(
      size: gameRef.size,
      paint: Paint()..color = Colors.red.withOpacity(0.7),
    );
    add(background);

    // Game Over text.
    gameOverText = TextComponent(
      text: 'Game Over',
      textRenderer: TextPaint(
        style: const TextStyle( // Added const
          color: Colors.white, // Fixed: Use Colors.white instead of BasicPalette
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: gameRef.size / 2 - Vector2(0, 50),
    );
    add(gameOverText);

    // Restart button text.
    restartText = TextComponent(
      text: 'Tap to Restart',
      textRenderer: TextPaint(
        style: const TextStyle( // Added const
          color: Colors.white, // Fixed: Use Colors.white instead of BasicPalette
          fontSize: 24.0,
        ),
      ),
      anchor: Anchor.center,
      position: gameRef.size / 2 + Vector2(0, 50),
    );
    add(restartText);
  }

  // Handle tap on the menu - Updated for new TapCallbacks system
  @override
  bool onTapDown(TapDownEvent event) {
    onRestart(); // This calls the callback function passed from main game
    return true;
  }
}