import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../bubble_pop_flame.dart';

// Represents a stone that blocks the pipe.
class Stone extends RectangleComponent with HasGameRef<BubblePopFlameGame> {
  Stone() : super(
    size: Vector2.all(40),
    paint: Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill,
  ) {
    anchor = Anchor.topLeft;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Try to load stone sprite
      final stoneSprite = await gameRef.loadSprite('stone.png');
      // If we have a sprite, replace this component with a sprite component
      final spriteStone = SpriteComponent(
        sprite: stoneSprite,
        size: size,
        position: position,
        anchor: anchor,
      );
      parent?.add(spriteStone);
      removeFromParent();
      return;
    } catch (e) {
      print('Stone sprite not found, using colored rectangle: $e'); // Debug
    }

    // Fallback: Use colored rectangle with border
    paint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Add border for better visibility
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
    );

    // Add some texture/pattern
    final texturePaint = Paint()
      ..color = Colors.grey[500]!
      ..style = PaintingStyle.fill;

    // Draw some texture dots
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.3), 3, texturePaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.6), 2, texturePaint);
    canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.8), 2.5, texturePaint);
  }
}