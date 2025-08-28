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

  final double speed = 100.0;
  bool isPopped = false;
  bool isFrozen = false; // ← Add this property

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

    y -= speed * dt;

    // If the bubble reaches the top, it becomes a stone.
    if (y < 0) {
      final stone = Stone()
        ..x = x
        ..y = y
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