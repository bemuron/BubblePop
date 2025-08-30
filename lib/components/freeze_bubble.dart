import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';

import 'bubble.dart';
import '../effects/freeze_effect.dart';

// Represents a freeze bubble that stops all other bubbles when popped.
class FreezeBubble extends Bubble {
  static final _freezePaint = Paint()
    ..color = Colors.lightBlueAccent
    ..filterQuality = FilterQuality.high;

  FreezeBubble() : super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Use a different sprite or color for freeze bubbles
    // You can replace this with a freeze bubble sprite
    try {
      sprite = await gameRef.loadSprite('bubble_2.png');
    } catch (e) {
      // Fallback to colored circle if sprite doesn't exist
      paint = _freezePaint;
    }
  }

  @override
  void update(double dt) {
    if (!gameRef.isPlaying || isPopped || isFrozen) return;

    y -= speed * dt; // Move UP the screen (y decreases = moves up)

    // Freeze bubbles just disappear when they reach the top (don't turn into stones)
    if (y + size.y < 0) {
      removeFromParent();
      // Don't call gameRef.addStone() - freeze bubbles don't become stones
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    // Add freeze effect when freeze bubble is popped
    gameRef.add(FreezeEffect());
    // The freeze bubble should pop and disappear immediately
    onBubblePop();
    return true;
  }
}