import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart'; // Correct import for TapCallbacks
import 'dart:math';

import 'components/bubble.dart';
import 'components/freeze_bubble.dart';
import 'components/stone.dart';
import 'effects/freeze_effect.dart';
import 'overlays/game_over_menu.dart';
import 'overlays/main_menu.dart';

// The main entry point for the game.
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: GameWidget<BubblePop>.controlled(
        gameFactory: BubblePop.new,
      ),
    ),
  ));
}

// The main game class. It handles the game state and logic.
class BubblePop extends FlameGame with TapCallbacks {
  // Game state variables
  int score = 0;
  int stones = 0;
  bool isPlaying = false;
  final int maxStones = 10;
  final Random _random = Random();
  final TextPaint scoreTextPaint = TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ));

  // Game components
  late TimerComponent _bubbleSpawner;
  late TextComponent scoreDisplay;
  late TextComponent stonesDisplay;

  // The size of the game world.
  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // Sky blue background

  // Called once when the game starts.
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load assets and set up game components.
    // The background is a simple color, but you could load a sprite here.
    /*
    final background = SpriteComponent()
      ..sprite = await loadSprite('city_background.png')
      ..size = size
      ..anchor = Anchor.topLeft
      ..position = Vector2(0, 0);
    add(background);
    */

    // Initialize the UI text components.
    scoreDisplay = TextComponent(
      text: 'Score: 0',
      textRenderer: scoreTextPaint,
      position: Vector2(10, 10),
    );
    add(scoreDisplay);

    stonesDisplay = TextComponent(
      text: 'Stones: 0/$maxStones',
      textRenderer: scoreTextPaint,
      position: Vector2(10, 40),
    );
    add(stonesDisplay);

    // Set up the bubble spawner timer - but don't add it yet
    _bubbleSpawner = TimerComponent(
      period: 1.5,
      onTick: _spawnBubble,
      repeat: true,
    );
    // Don't add the timer here - only add it when game starts

    // Show the main menu initially.
    _showMainMenu();
  }

  // The main game loop - no manual timer update needed
  @override
  void update(double dt) {
    super.update(dt);
    // TimerComponent updates automatically when added to the game
  }

  // Handle tap events
  @override
  bool onTapDown(TapDownEvent event) {
    if (!isPlaying) {
      // Check if we have a main menu and start the game
      final mainMenus = children.query<MainMenu>();
      if (mainMenus.isNotEmpty) {
        _startGame();
        return true; // Consume the tap
      }
      return false; // Allow tap to pass through if no menu
    } else {
      // Find and handle taps on bubbles using the new query system
      final tappedBubbles = children.query<Bubble>().where((bubble) {
        // Check if tap position is within bubble bounds
        final bubbleRect = bubble.toRect();
        return bubbleRect.contains(event.localPosition.toOffset());
      }).toList();

      for (var bubble in tappedBubbles) {
        // Handle freeze bubble power-up
        if (bubble is FreezeBubble) {
          add(FreezeEffect());
          bubble.onBubblePop();
        } else {
          score++;
          scoreDisplay.text = 'Score: $score';
          bubble.onBubblePop();
        }
      }
      return true; // Consume the tap event
    }
  }

  // Spawns a new bubble.
  void _spawnBubble() {
    // Randomly choose between a regular bubble and a freeze bubble.
    final isFreezeBubble = _random.nextDouble() < 0.1; // 10% chance
    final bubble = isFreezeBubble ? FreezeBubble() : Bubble();

    // Position bubble at bottom of screen with random X position
    bubble.position = Vector2(
      _random.nextDouble() * (size.x - bubble.size.x),
      size.y, // Start just below the bottom of screen
    );

    // Give bubbles varying speeds (50-150 pixels per second)
    bubble.speed = 50.0 + _random.nextDouble() * 100.0;

    add(bubble);
  }

  // Game over state handler.
  void _gameOver() {
    isPlaying = false;
    // Remove the timer component to stop spawning
    _bubbleSpawner.removeFromParent();
    // Add the game over screen.
    add(GameOverMenu(onRestart: _restartGame));
  }

  // Starts the game.
  void _startGame() {
    // Clear the current children (bubbles, etc.) and reset state.
    children.query<MainMenu>().forEach((menu) => menu.removeFromParent());
    _resetGameState();
    isPlaying = true;

    // Add and start the timer component
    add(_bubbleSpawner);
  }

  // Restarts the game.
  void _restartGame() {
    children.query<GameOverMenu>().forEach((menu) => menu.removeFromParent());
    _resetGameState();
    isPlaying = true;

    // Add and start the timer component
    add(_bubbleSpawner);
  }

  // Resets all game state variables.
  void _resetGameState() {
    // Remove all bubbles and stones
    children.query<Bubble>().forEach((bubble) => bubble.removeFromParent());
    children.query<Stone>().forEach((stone) => stone.removeFromParent());

    // Remove timer if it exists
    if (_bubbleSpawner.isMounted) {
      _bubbleSpawner.removeFromParent();
    }

    score = 0;
    stones = 0;
    scoreDisplay.text = 'Score: $score';
    stonesDisplay.text = 'Stones: $stones/$maxStones';
  }

  // Shows the main menu overlay.
  void _showMainMenu() {
    add(MainMenu(onStart: _startGame));
  }

  // This method will be called by a Bubble when it transforms into a stone.
  void addStone() {
    stones++;
    stonesDisplay.text = 'Stones: $stones/$maxStones';
    if (stones >= maxStones) {
      _gameOver();
    }
  }
}