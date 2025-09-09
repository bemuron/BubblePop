import 'package:bubble_pop/play_session/bubble_pop_flame.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // Changed from palette import

import '/main.dart';

// Represents a stone that blocks the pipe.
class Stone extends RectangleComponent with HasGameRef<BubblePopFlameGame> {
  // Fixed: Use Flutter Colors instead of BasicPalette
  static final _paint = Paint()
    ..color = Colors.grey[600]!
    ..style = PaintingStyle.fill;

  Stone() : super(
    size: Vector2.all(40),
    paint: _paint,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Try to load stone sprite
      final stoneSprite = await gameRef.loadSprite('stone.png');
      // If we have a sprite, create a SpriteComponent instead
      final spriteComponent = SpriteComponent(
        sprite: stoneSprite,
        size: size,
        anchor: anchor,
      );
      parent?.add(spriteComponent);
      removeFromParent();
    } catch (e) {
      // Fallback to rectangle with border
      paint = Paint()
        ..color = Colors.grey[600]!
        ..style = PaintingStyle.fill;

      // Add border
      add(RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ));
    }

    anchor = Anchor.topLeft;
  }
}