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
import '../player_progress/player_progress.dart';
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
  PlayerProgressController? playerProgressController;

  // Game state
  final Random _random = Random();
  final int maxStones = 10;
  final double _spawnInterval = 0.8; // Time between bubble spawns
  late TimerComponent _bubbleSpawner;
  late TextComponent scoreDisplay;
  late TextComponent stonesDisplay;
  late TextComponent levelDisplay;
  late TextComponent bubblesPoppedDisplay; // New display for bubbles popped

  late WaterFlowBar waterFlowBar;
  late TextComponent waterFlowTextDisplay;
  late FreezeIndicator freezeIndicator;
  late TextComponent goalDisplay;
  bool isPaused = false;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18.0, // Reduced from 24
        fontWeight: FontWeight.bold,
        shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
      ),
    );

    final smallTextRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
      ),
    );

    final double padding = size.x * 0.02;
    final double iconSize = 20.0; // Reduced from 24
    final double spacing = 8.0; // Reduced from 10

    // Load icons
    final scoreIconSprite = await loadSprite('bubble_icon.png');
    final stonesIconSprite = await loadSprite('bubble_icon.png');
    final levelIconSprite = await loadSprite('bubble_icon.png');
    final waterIconSprite = await loadSprite('bubble_icon.png');
    final bubbleIconSprite = await loadSprite('bubble_icon.png');

    // TOP BAR - Full width for level info and water flow
    final topBar = PositionComponent(
      position: Vector2(padding, padding),
      size: Vector2(size.x - (padding * 2), 60),
    );
    add(topBar);

    // Left side - Level and basic stats
    final leftStats = PositionComponent(
      position: Vector2.zero(),
      size: Vector2(size.x * 0.4, topBar.height),
    );
    topBar.add(leftStats);

    // Level display
    final levelIcon = SpriteComponent(sprite: levelIconSprite, size: Vector2.all(iconSize));
    levelDisplay = TextComponent(
      text: 'Level 1',
      textRenderer: textRenderer,
      position: Vector2(iconSize + spacing, 0),
    );
    leftStats.add(levelIcon);
    leftStats.add(levelDisplay);

    // Score display
    final scoreIcon = SpriteComponent(sprite: scoreIconSprite, size: Vector2.all(iconSize));
    scoreDisplay = TextComponent(
      text: '0',
      textRenderer: smallTextRenderer,
      position: Vector2(iconSize + spacing, levelDisplay.height + spacing),
    );
    scoreIcon.position = Vector2(0, scoreDisplay.y);
    leftStats.add(scoreIcon);
    leftStats.add(scoreDisplay);

    // Right side - Water flow
    final rightStats = PositionComponent(
      position: Vector2(size.x * 0.6, 0),
      size: Vector2(size.x * 0.4, topBar.height),
      anchor: Anchor.topLeft,
    );
    topBar.add(rightStats);

    // Water flow percentage
    waterFlowTextDisplay = TextComponent(
      text: '100%',
      textRenderer: textRenderer,
      position: Vector2(0, 0),
      anchor: Anchor.topLeft,
    );
    rightStats.add(waterFlowTextDisplay);

    // Water flow bar
    waterFlowBar = WaterFlowBar()
      ..position = Vector2(0, waterFlowTextDisplay.height + spacing)
      ..size = Vector2(rightStats.width - iconSize - spacing, 15); // Set specific size
    rightStats.add(waterFlowBar);

    // MIDDLE BAR - Game stats
    final middleBar = PositionComponent(
      position: Vector2(padding, topBar.y + topBar.height + spacing),
      size: Vector2(size.x - (padding * 2), 40),
    );
    add(middleBar);

    // Bubbles popped
    final bubblesIcon = SpriteComponent(sprite: bubbleIconSprite, size: Vector2.all(iconSize));
    bubblesPoppedDisplay = TextComponent(
      text: 'Bubbles: 0',
      textRenderer: smallTextRenderer,
      position: Vector2(iconSize + spacing, 0),
    );
    middleBar.add(bubblesIcon);
    middleBar.add(bubblesPoppedDisplay);

    // Stones (right side of middle bar)
    final stonesIcon = SpriteComponent(sprite: stonesIconSprite, size: Vector2.all(iconSize));
    stonesDisplay = TextComponent(
      text: 'Stones: 0/10',
      textRenderer: smallTextRenderer,
      anchor: Anchor.topRight,
    );
    stonesIcon.position = Vector2(middleBar.width - stonesDisplay.width - iconSize - spacing, 0);
    stonesIcon.anchor = Anchor.topRight;
    stonesDisplay.position = Vector2(middleBar.width, 0);
    middleBar.add(stonesIcon);
    middleBar.add(stonesDisplay);

    // GOAL BAR - Full width, wrapping text
    final goalBar = PositionComponent(
      position: Vector2(padding, middleBar.y + middleBar.height + spacing),
      size: Vector2(size.x - (padding * 2), 50), // Taller to accommodate wrapped text
    );
    add(goalBar);

    // Goal display with text wrapping
    goalDisplay = TextComponent(
      text: levelState?.levelConfig?.goal ?? 'Loading...',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellowAccent,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
        ),
      ),
      position: Vector2(0, 0),
    );
    goalBar.add(goalDisplay);

    // Freeze indicator - positioned safely within screen bounds
    freezeIndicator = FreezeIndicator()
      ..position = Vector2(size.x - padding - 80, goalBar.y + goalBar.height + spacing);
    add(freezeIndicator);

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
    if (isPaused) {
      return;
    }
    super.update(dt);

    levelState?.update(dt);

    if (levelState != null) {
      scoreDisplay.text = '${levelState!.score}';
      bubblesPoppedDisplay.text = 'Bubbles: ${levelState!.bubblesPopped}';
      stonesDisplay.text = 'Stones: ${levelState!.stones}/$maxStones';
      levelDisplay.text = 'Level ${levelState!.currentLevel}';
      waterFlowBar.updatePercentage(levelState!.waterFlowPercentage);
      waterFlowTextDisplay.text = '${levelState!.waterFlowPercentage.toStringAsFixed(0)}%';
      freezeIndicator.updateFreezeCount(levelState!.freezeBubblesRemaining);

      // Update goal text and handle wrapping
      final goalText = levelState!.goalText;
      if (goalText.length > 40) {
        // Simple word wrapping for long goals
        final words = goalText.split(' ');
        final lines = <String>[];
        String currentLine = '';

        for (final word in words) {
          if ((currentLine + word).length > 35) {
            if (currentLine.isNotEmpty) {
              lines.add(currentLine.trim());
              currentLine = word + ' ';
            } else {
              lines.add(word);
            }
          } else {
            currentLine += word + ' ';
          }
        }
        if (currentLine.isNotEmpty) {
          lines.add(currentLine.trim());
        }

        goalDisplay.text = lines.take(2).join('\n'); // Max 2 lines
      } else {
        goalDisplay.text = goalText;
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

    add(bubble);
  }

  // Called to reward a user with a freeze bubble after a user has watched an ad
  void addFreezeBubble() {
    levelState?.addFreezeBubble();
    freezeIndicator.updateFreezeCount(levelState?.freezeBubblesRemaining ?? 0);
  }

  /// Called when a regular bubble is popped
  void onBubblePopped([int points = 10]) {
    print('🎈 DEBUG: onBubblePopped called with $points points');
    print('🎈 DEBUG: levelState is null: ${levelState == null}');

    if (levelState != null) {
      print('🎈 DEBUG: Before - Bubbles: ${levelState!.bubblesPopped}, Score: ${levelState!.score}');
    }

    levelState?.incrementScore(points);

    if (levelState != null) {
      print('🎈 DEBUG: After - Bubbles: ${levelState!.bubblesPopped}, Score: ${levelState!.score}');
    }
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
    print('🪨 DEBUG: addStones called with $count stones');
    print('🪨 DEBUG: levelState is null: ${levelState == null}');
    if (levelState != null) {
      print('🪨 DEBUG: Before - Stones: ${levelState!.stones}, Water: ${levelState!.waterFlowPercentage}%');
    }

    levelState?.addStones(count);

    if (levelState != null) {
      print('🪨 DEBUG: After - Stones: ${levelState!.stones}, Water: ${levelState!.waterFlowPercentage}%');
    }

    audioController?.playSfx(SfxType.buttonTap);
  }

  /// Called when a bubble turns into a stone
  void addStone() {
    levelState?.addStones(1);
    audioController?.playSfx(SfxType.buttonTap);
  }

  /// Pause the game
  void pauseGame() {
    isPaused = true;
    _bubbleSpawner.timer.pause();
  }

  /// Resume the game
  void resumeGame() {
    isPaused = false;
    _bubbleSpawner.timer.resume();
  }
}