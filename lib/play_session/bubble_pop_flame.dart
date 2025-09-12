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
import 'components/freeze_indicator.dart';
import 'components/freeze_bubble.dart';
import 'components/stone.dart';
import 'effects/freeze_effect.dart';
import 'components/water_flow_display.dart';

/// The main Flame game class for Bubble Pop
class BubblePopFlameGame extends FlameGame with TapCallbacks {
  // Dependencies injected from the widget
  LevelState? levelState;
  AudioController? audioController;
  AdsController? adsController;

  // Game state
  final Random _random = Random();
  final int maxStones = 10;
  final double _spawnInterval = 0.8; // Time between bubble spawns
  late TimerComponent _bubbleSpawner;
  late TextComponent scoreDisplay;
  late TextComponent stonesDisplay;
  late TextComponent levelDisplay;

  late WaterFlowBar waterFlowBar;
  late TextComponent waterFlowTextDisplay;
  late FreezeIndicator freezeIndicator;
  late TextComponent goalDisplay;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
      ),
    );

    final double padding = size.x * 0.02;
    final double columnWidth = size.x * 0.4;

    // Left Column
    final leftUI = PositionComponent(
      position: Vector2(padding, padding),
      size: Vector2(columnWidth, size.y * 0.3),
    );
    add(leftUI);

    scoreDisplay = TextComponent(
      text: 'Score: 0',
      textRenderer: textRenderer,
      position: Vector2(0, 0),
    );
    leftUI.add(scoreDisplay);

    stonesDisplay = TextComponent(
      text: 'Stones: 0/$maxStones',
      textRenderer: textRenderer,
      position: Vector2(0, scoreDisplay.height + 10),
    );
    leftUI.add(stonesDisplay);

    levelDisplay = TextComponent(
      text: 'Level: 1',
      textRenderer: textRenderer,
      position: Vector2(0, stonesDisplay.y + stonesDisplay.height + 10),
    );
    leftUI.add(levelDisplay);

    // Right Column
    final rightUI = PositionComponent(
      position: Vector2(size.x - padding, padding),
      anchor: Anchor.topRight,
      size: Vector2(columnWidth, size.y * 0.3),
    );
    add(rightUI);

    waterFlowTextDisplay = TextComponent(
      text: 'Water: 100%',
      textRenderer: textRenderer,
      position: Vector2(0, 0),
    );
    rightUI.add(waterFlowTextDisplay);

    waterFlowBar = WaterFlowBar()
      ..position = Vector2(0, waterFlowTextDisplay.height + 10);
    rightUI.add(waterFlowBar);

    freezeIndicator = FreezeIndicator()
      ..position = Vector2(0, waterFlowBar.y + waterFlowBar.height + 10);
    rightUI.add(freezeIndicator);

    goalDisplay = TextComponent(
      text: 'Goal: ${levelState?.levelConfig?.goal}',
      textRenderer: textRenderer,
      position: Vector2(0, levelDisplay.y + levelDisplay.height + 10),
    );
    leftUI.add(goalDisplay);


    // Bubble spawner
    _bubbleSpawner = TimerComponent(
      period: _spawnInterval,
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
      levelDisplay.text = 'Level: ${levelState!.currentLevel}';

      // Update the WaterFlowBar component's percentage
      waterFlowBar.updatePercentage(levelState!.waterFlowPercentage);

      // Update the WaterFlow Text component
      waterFlowTextDisplay.text = 'Water: ${levelState!.waterFlowPercentage.toStringAsFixed(0)}%';

      // Update the freeze indicator
      freezeIndicator.updateFreezeCount(levelState!.freezeBubblesRemaining);

      // Update the goal for the level
      goalDisplay.text = 'Goal: ${levelState!.goalText}';
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