import 'package:flame/components.dart';
import 'package:flame/events.dart'; // Added for TapCallbacks
import 'package:flutter/material.dart';

import '../main.dart';

// Main Menu overlay.
class MainMenu extends PositionComponent with HasGameRef<BubblePop>, TapCallbacks {
  final VoidCallback onStart;
  late final RectangleComponent background;
  late final TextComponent titleText;
  late final TextComponent startText;

  MainMenu({required this.onStart});

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // Added await

    // Create a semi-transparent background.
    background = RectangleComponent(
      size: gameRef.size,
      paint: Paint()..color = Colors.black.withOpacity(0.5),
    );
    add(background);

    // Title text.
    titleText = TextComponent(
      text: 'Bubble Blockade',
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
    add(titleText);

    // Start button text.
    startText = TextComponent(
      text: 'Tap to Start',
      textRenderer: TextPaint(
        style: const TextStyle( // Added const
          color: Colors.white, // Fixed: Use Colors.white instead of BasicPalette
          fontSize: 24.0,
        ),
      ),
      anchor: Anchor.center,
      position: gameRef.size / 2 + Vector2(0, 50),
    );
    add(startText);
  }

  // Handle tap on the menu - Updated for new TapCallbacks system
  @override
  bool onTapDown(TapDownEvent event) {
    onStart();
    return true;
  }
}