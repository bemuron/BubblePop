// File: lib/src/play_session/bubble_pop_flame.dart
import 'dart:ui' hide TextStyle;

import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'dart:math';

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
        shadows: <Shadow>[
          Shadow(
            blurRadius: 2.0,
            color: Colors.black54,
            offset: Offset(1.0, 1.0),
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

    // Update UI displays
    if (levelState != null) {
      scoreDisplay.text = 'Score: ${levelState!.score}';
      stonesDisplay.text = 'Stones: ${levelState!.stones}/$maxStones';
    }
  }

  void _spawnBubble() {
    if (levelState?.isGameOver ?? true) return;

    // 10% chance for freeze bubble
    final isFreezeBubble = _random.nextDouble() < 0.1;
    final bubble = isFreezeBubble ? FreezeBubble() : Bubble();

    // Position at bottom with random X
    bubble.position = Vector2(
      _random.nextDouble() * (size.x - bubble.size.x),
      size.y,
    );

    // Varying speeds
    bubble.speed = 50.0 + _random.nextDouble() * 100.0;

    add(bubble);
  }

  /// Called when a regular bubble is popped
  void onBubblePopped() {
    levelState?.incrementScore();
    audioController?.playSfx(SfxType.buttonTap);
  }

  /// Called when a freeze bubble is popped
  void onFreezeBubblePopped() {
    add(FreezeEffect());
    audioController?.playSfx(SfxType.powerUp);
  }

  /// Called when a bubble turns into a stone
  void addStone() {
    levelState?.addStone();

    if ((levelState?.stones ?? 0) >= maxStones) {
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