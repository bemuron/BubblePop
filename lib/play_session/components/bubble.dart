import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../bubble_pop_flame.dart';
import 'stone.dart';

class Bubble extends SpriteComponent with HasGameRef<BubblePopFlameGame>, TapCallbacks {
  static final _paint = Paint()
    ..color = Colors.blue
    ..filterQuality = FilterQuality.high;

  double speed = 100.0;
  bool isPopped = false;
  bool isFrozen = false;

  Bubble() : super(size: Vector2.all(40));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      sprite = await gameRef.loadSprite('bubble_1.png');
    } catch (e) {
      // Fallback to colored circle
      paint = _paint;
    }
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    if (gameRef.levelState?.isGameOver ?? true) return;
    if (isPopped || isFrozen) return;

    y -= speed * dt; // Move UP the screen

    // If the bubble reaches the top, it becomes a stone.
    if (y + size.y < 0) {
      _createStone();
      removeFromParent();
    }
  }

  void _createStone() {
    // Find existing stones to stack properly
    final stonesAtPosition = gameRef.children.query<Stone>().where((stone) {
      return (stone.x - x).abs() < size.x;
    }).toList();

    double stoneY = 0; // Start at top of screen
    if (stonesAtPosition.isNotEmpty) {
      final lowestY = stonesAtPosition.map((s) => s.y).reduce((a, b) => a < b ? a : b);
      stoneY = lowestY + size.y;
    }

    final stone = Stone()
      ..position = Vector2(x, stoneY)
      ..size = size
      ..anchor = anchor;
    gameRef.add(stone);

    // This will trigger game over check
    gameRef.addStone();
  }

  void onBubblePop() {
    if (isPopped) return;
    isPopped = true;

    add(ScaleEffect.to(
      Vector2.zero(),
      EffectController(duration: 0.2),
      onComplete: () => removeFromParent(),
    ));
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (gameRef.levelState?.isGameOver ?? true) return false;

    gameRef.onBubblePopped(); // This handles score and audio
    onBubblePop();
    return true;
  }
}