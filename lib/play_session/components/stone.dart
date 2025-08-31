import 'package:bubble_pop/play_session/bubble_pop_flame.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // Changed from palette import

import '/main.dart';

// Represents a stone that blocks the pipe.
class Stone extends SpriteComponent with HasGameRef<BubblePopFlameGame> {
  // Fixed: Use Flutter Colors instead of BasicPalette
  static final _paint = Paint()
    ..color = Colors.grey
    ..filterQuality = FilterQuality.high;

  Stone() : super(size: Vector2.all(40));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Placeholder for a stone image.
    sprite = await gameRef.loadSprite('stone.png');
    paint = _paint;
    anchor = Anchor.center;
  }
}