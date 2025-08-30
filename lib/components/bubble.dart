import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../components/stone.dart';

// Represents a regular bubble.
class Bubble extends SpriteComponent with HasGameRef<BubblePop>, TapCallbacks {
  static final _paint = Paint()
    ..color = Colors.blue
    ..filterQuality = FilterQuality.high;

  double speed = 100.0; // Changed from final to allow modification
  bool isPopped = false;
  bool isFrozen = false;

  Bubble() : super(size: Vector2.all(40));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('bubble_1.png');
    paint = _paint;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    // ← Modified this line to check isFrozen
    if (!gameRef.isPlaying || isPopped || isFrozen) return;

    y -= speed * dt; // Move UP the screen (y decreases = moves up)

    // If the bubble reaches the top, it becomes a stone.
    if (y + size.y < 0) { // Check if bubble has completely left the top
      // Find the highest stone at this X position to stack on top
      final stonesAtPosition = gameRef.children.query<Stone>().where((stone) {
        return (stone.x - x).abs() < size.x; // Stones within bubble width
      }).toList();

      double stoneY = 0; // Start at top of screen
      if (stonesAtPosition.isNotEmpty) {
        // Find the lowest Y position (highest stone visually) and stack on top
        final lowestY = stonesAtPosition.map((s) => s.y).reduce((a, b) => a < b ? a : b);
        stoneY = lowestY + size.y; // Stack on top of existing stone
      }

      final stone = Stone()
        ..position = Vector2(x, stoneY) // Place stone visibly at top, stacking if needed
        ..size = size
        ..anchor = anchor;
      gameRef.add(stone);
      gameRef.addStone();
      removeFromParent();
    }
  }

  void onBubblePop() {
    if (isPopped) return;
    isPopped = true;
    add(ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.2),
        onComplete: removeFromParent));
  }

  @override
  bool onTapDown(TapDownEvent event) {
    onBubblePop();
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    return true;
  }
}