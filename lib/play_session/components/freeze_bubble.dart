import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';

import 'bubble.dart';
import '../effects/freeze_effect.dart';
import '../../game_internals/level_state.dart';

// Represents a freeze bubble that stops all other bubbles when popped.
class FreezeBubble extends Bubble {
  static final _freezePaint = Paint()
    ..color = Colors.lightBlueAccent
    ..filterQuality = FilterQuality.high;

  FreezeBubble() : super(bubbleSize: BubbleSize.normal);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      sprite = await gameRef.loadSprite('freeze_bubble.png');
    } catch (e) {
      paint = _freezePaint;
    }

    // Add glowing effect
    add(ScaleEffect.by(
      Vector2.all(0.1),
      EffectController(
        duration: 1.0,
        reverseDuration: 1.0,
        infinite: true,
      ),
    ));
  }

  @override
  void update(double dt) {
    if (gameRef.levelState?.isGameOver ?? true) return;
    if (isPopped || isFrozen) return;

    y -= speed * dt;

    // Freeze bubbles just disappear when they reach the top (don't turn into stones)
    if (y + size.y < 0) {
      removeFromParent();
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (gameRef.levelState?.isGameOver ?? true) return false;

    // Check if freeze bubbles are available
    if ((gameRef.levelState?.freezeBubblesRemaining ?? 0) > 0) {
      gameRef.onFreezeBubblePopped();
      onBubblePop();
    }
    return true;
  }
}