// File: lib/src/play_session/bubble_pop_flame.dart
import 'dart:ui' hide TextStyle;

import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'dart:math';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import 'components/bubble.dart';
import 'components/freeze_bubble.dart';
import 'components/stone.dart';
import 'effects/freeze_effect.dart';

/// The main Flame game class for Bubble Pop
class BubblePopFlameGame extends FlameGame with TapCallbacks {
  // Dependencies injected from the widget
  LevelState? levelState;
  AudioController? audioController;
  AdsController? adsController;

  // Game state
  final Random _random = Random();
  final int maxStones = 10;
  late TimerComponent _bubbleSpawner;
  late TextComponent scoreDisplay;
  late TextComponent stonesDisplay;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize UI components
    final textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 2,
            color: Colors.black54,
          ),
        ],
      ),
    );

    scoreDisplay = TextComponent(
      text: 'Score: 0',
      textRenderer: textRenderer,
      position: Vector2(20, 50),
    );
    add(scoreDisplay);

    stonesDisplay = TextComponent(
      text: 'Stones: 0/$maxStones',
      textRenderer: textRenderer,
      position: Vector2(20, 80),
    );
    add(stonesDisplay);

    // Set up bubble spawner
    _bubbleSpawner = TimerComponent(
      period: 1.5,
      onTick: _spawnBubble,
      repeat: true,
    );
    add(_bubbleSpawner);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update level state
    levelState?.update(dt);

    // Update UI displays
    if (levelState != null) {
      scoreDisplay.text = 'Score: ${levelState!.score}';
      stonesDisplay.text = 'Stones: ${levelState!.stones}';

      // Update water flow display
      final waterFlowComponent = children.query<TextComponent>().where(
              (c) => c.text.startsWith('Water Flow:')
      ).firstOrNull;
      if (waterFlowComponent != null) {
        waterFlowComponent.text = 'Water Flow: ${levelState!.waterFlowPercentage.toStringAsFixed(1)}%';
      }

      // Update freeze bubbles display
      final freezeComponent = children.query<TextComponent>().where(
              (c) => c.text.startsWith('Freeze:')
      ).firstOrNull;
      if (freezeComponent != null) {
        freezeComponent.text = 'Freeze: ${levelState!.freezeBubblesRemaining}';
      }

      // Update level display
      final levelComponent = children.query<TextComponent>().where(
              (c) => c.text.startsWith('Level:')
      ).firstOrNull;
      if (levelComponent != null) {
        levelComponent.text = 'Level: ${levelState!.currentLevel}';
      }
    }
  }

  void _spawnBubble() {
    if (levelState?.isGameOver ?? true) return;

    // Randomly choose bubble type based on level configuration
    final bubbleSize = levelState!.getRandomBubbleSize();

    // 5% chance for freeze bubble (only if available)
    final isFreezeBubble = _random.nextDouble() < 0.05 &&
        (levelState?.freezeBubblesRemaining ?? 0) > 0;

    final bubble = isFreezeBubble ? FreezeBubble() : Bubble(bubbleSize: bubbleSize);

    // Position at bottom with random X
    bubble.position = Vector2(
      _random.nextDouble() * (size.x - bubble.size.x),
      size.y,
    );

    // Varying speeds based on size (larger = slower)
    double baseSpeed = 50.0 + _random.nextDouble() * 50.0;
    switch (bubbleSize) {
      case BubbleSize.large:
        baseSpeed *= 0.7; // Slower
        break;
      case BubbleSize.medium:
        baseSpeed *= 0.85;
        break;
      case BubbleSize.normal:
        break; // Normal speed
    }
    bubble.speed = baseSpeed;

    add(bubble);
  }

  /// Called when a regular bubble is popped
  void onBubblePopped([int points = 10]) {
    levelState?.incrementScore(points);
    audioController?.playSfx(SfxType.buttonTap);
  }

  /// Called when a freeze bubble is popped
  void onFreezeBubblePopped() {
    levelState?.useFreezeEffect();
    add(FreezeEffect());
    audioController?.playSfx(SfxType.powerUp);
  }

  /// Called when bubbles turn into stones
  void addStones(int count) {
    levelState?.addStones(count);
    audioController?.playSfx(SfxType.buttonTap);
  }

  /// Called when a bubble turns into a stone
  void addStone() {
    levelState?.addStones(1);

    if ((levelState?.stones ?? 0) >= maxStones) {
      // Game over - trigger the lose callback
      levelState?.setGameOver(won: false);
    }

    audioController?.playSfx(SfxType.buttonTap);
  }

  /// Pause the game
  void pauseGame() {
    _bubbleSpawner.timer.pause();
  }

  /// Resume the game
  void resumeGame() {
    _bubbleSpawner.timer.resume();
  }
}