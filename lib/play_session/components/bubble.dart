import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../audio/sounds.dart';
import '../bubble_pop_flame.dart';
import '../../game_internals/level_state.dart';
import 'stone.dart';

class Bubble extends SpriteComponent with HasGameRef<BubblePopFlameGame>, TapCallbacks {
  final BubbleSize bubbleSize;
  late final Paint _paint;
  late final int _tapsRequired;
  late final double _bubbleScale;

  double speed = 100.0;
  bool isPopped = false;
  bool isFrozen = false;
  int _tapsReceived = 0;

  Bubble({this.bubbleSize = BubbleSize.normal}) : super() {
    _tapsRequired = LevelState.getTapsRequired(bubbleSize);
    _bubbleScale = LevelState.getBubbleScale(bubbleSize);

    // Set size based on bubble type
    size = Vector2.all(40 * _bubbleScale);

    // Set color based on size
    _paint = Paint()
      ..color = _getBubbleColor()
      ..filterQuality = FilterQuality.high;
  }

  Color _getBubbleColor() {
    switch (bubbleSize) {
      case BubbleSize.normal:
        return Colors.blue;
      case BubbleSize.medium:
        return Colors.orange;
      case BubbleSize.large:
        return Colors.red;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Try to load size-specific sprite
      String spriteName = 'bubble_${bubbleSize.name}.png';
      sprite = await gameRef.loadSprite(spriteName);
    } catch (e) {
      // Fallback to colored circle
      paint = _paint;
    }

    anchor = Anchor.center;

    // Add tap indicator if multi-tap bubble
    if (_tapsRequired > 1) {
      _addTapIndicator();
    }
  }

  void _addTapIndicator() {
    final indicator = TextComponent(
      text: '$_tapsRequired',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16 * _bubbleScale,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 2,
              color: Colors.black,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(indicator);
  }

  void _updateTapIndicator() {
    // Remove old indicator
    children.whereType<TextComponent>().forEach((component) {
      component.removeFromParent();
    });

    // Add new indicator
    final remainingTaps = _tapsRequired - _tapsReceived;
    if (remainingTaps > 0) {
      final indicator = TextComponent(
        text: '$remainingTaps',
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.white,
            fontSize: 16 * _bubbleScale,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        anchor: Anchor.center,
        position: size / 2,
      );
      add(indicator);
    }
  }

  @override
  void update(double dt) {
    if (gameRef.levelState?.isGameOver ?? true) return;
    if (isPopped || isFrozen) return;

    y -= speed * dt; // Move UP the screen

    // If the bubble reaches the top, it becomes stones
    if (y + size.y < 0) {
      _createStones();
      removeFromParent();
    }
  }

  void _createStones() {
    final stonesCount = LevelState.getStonesCreated(bubbleSize);
    final stoneSize = 40.0; // Standard stone size

    for (int i = 0; i < stonesCount; i++) {
      // Find position for this stone
      final stoneX = x + (i * (stoneSize * 0.8)) - ((stonesCount - 1) * (stoneSize * 0.8) / 2);

      // Find existing stones to stack properly
      final stonesAtPosition = gameRef.children.query<Stone>().where((stone) {
        return (stone.x - stoneX).abs() < stoneSize;
      }).toList();

      double stoneY = 0; // Start at top of screen
      if (stonesAtPosition.isNotEmpty) {
        final lowestY = stonesAtPosition.map((s) => s.y).reduce((a, b) => a < b ? a : b);
        stoneY = lowestY + stoneSize;
      }

      final stone = Stone()
        ..position = Vector2(stoneX, stoneY)
        ..size = Vector2.all(stoneSize)
        ..anchor = anchor;
      gameRef.add(stone);
    }

    // Add stones to game state
    gameRef.addStones(stonesCount);
  }

  void onBubbleTap() {
    if (isPopped || (gameRef.levelState?.isGameOver ?? true)) return;

    _tapsReceived++;

    // Add tap effect
    add(ScaleEffect.by(
      Vector2.all(0.1),
      EffectController(duration: 0.1, reverseDuration: 0.1),
    ));

    // Update tap indicator for multi-tap bubbles
    if (_tapsRequired > 1) {
      _updateTapIndicator();
    }

    // Check if bubble should pop
    if (_tapsReceived >= _tapsRequired) {
      onBubblePop();
    } else {
      // Play tap sound for partial taps
      gameRef.audioController?.playSfx(SfxType.buttonTap);
    }
  }

  void onBubblePop() {
    if (isPopped) return;
    isPopped = true;

    // Award points based on bubble size
    int points = 10;
    switch (bubbleSize) {
      case BubbleSize.normal:
        points = 10;
        break;
      case BubbleSize.medium:
        points = 25;
        break;
      case BubbleSize.large:
        points = 50;
        break;
    }

    gameRef.onBubblePopped(points);

    add(ScaleEffect.to(
      Vector2.zero(),
      EffectController(duration: 0.2),
      onComplete: () => removeFromParent(),
    ));
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (gameRef.levelState?.isGameOver ?? true) return false;

    onBubbleTap();
    return true;
  }
}